#include "alp/analysis/dependency.hpp"
#include "alp/analysis/validation.hpp"
#include "alp/constraints/constraint.hpp"
#include "alp/inference.hpp"
#include "alp/integrity.hpp"
#include "alp/logic/runtime.hpp"
#include "alp/parser.hpp"
#include "alp/provenance.hpp"
#include "check.hpp"

using namespace alp;
using namespace alp_test;

static void test_violations() {
    const auto kb = parse_program(R"(
        agent(alice). agent(bob).
        conflict(alice). conflict(bob). permitted(bob).
        action(alice, delete_files). forbidden(alice, delete_files). permitted(alice, delete_files).
        false <- conflict(A), not permitted(A).
        false <- agent(A), action(A,X), forbidden(A,X), permitted(A,X).
    )");
    const FactStore closure = InferenceEngine(kb).evaluate();
    const auto v = violations(kb, closure);
    CHECK(v.size() == 2);  // conflict(alice) is unpermitted; alice may do something forbidden
    CHECK(to_string(v[0].constraint) == "false <- conflict(A), not permitted(A).");
    CHECK(v[0].witnesses.size() == 1 && v[0].witnesses[0] == A("conflict", {C("alice")}));
    CHECK(v[1].witnesses.size() == 4);
    CHECK(to_string(v[0]).find("conflict(alice)") != std::string::npos);

    // each violating instance is reported once
    const auto kb2 = parse_program("p(a). p(b). false <- p(X).");
    CHECK(violations(kb2, InferenceEngine(kb2).evaluate()).size() == 2);
    const auto kb3 = parse_program("p(a). false <- p(X), q(X).");
    CHECK(violations(kb3, InferenceEngine(kb3).evaluate()).empty());
}

static void test_model_builder() {
    const auto kb = parse_program(R"(
        sun_is_shining. wet <- rain. wet <- sprinkler.
        abducible(rain). abducible(sprinkler).
        false <- rain, sun_is_shining.
    )");
    logic::ModelBuilder mb(kb);
    const Model good = mb.from_hypothesis({A("sprinkler")});
    CHECK(good.valid && good.violations.empty());
    CHECK(keys(good.abduced) == (std::set<std::string>{"sprinkler"}));
    CHECK(keys(good.derived) == (std::set<std::string>{"wet"}));  // facts and hypotheses are not "derived"
    CHECK(keys(good.facts) == (std::set<std::string>{"sun_is_shining"}));
    CHECK(satisfies_constraints(kb, good));

    const Model bad = mb.from_hypothesis({A("rain")});
    CHECK(!bad.valid && bad.violations.size() == 1);
    CHECK(!satisfies_constraints(kb, bad));
    CHECK(to_string(bad).find("invalid") != std::string::npos);

    // extra facts extend the program, they are not hypotheses
    const Model with_facts = mb.from_facts({A("rain")});
    CHECK(!with_facts.valid && with_facts.abduced.empty());
    CHECK(keys(with_facts.facts).contains("rain"));
    CHECK(!mb.validate(with_facts).valid);
}

static void test_dependency_analysis() {
    const auto kb = parse_program(R"(
        a(X) <- b(X).
        b(X) <- c(X).
        c(X) <- a(X).
        c(x).
        top(X) <- a(X), not other(X).
        other(y).
    )");
    analysis::DependencyGraph g;
    g.build(kb);
    CHECK(g.stratified);
    CHECK(!g.has_negative_cycle());
    CHECK(g.cycles().size() == 1 && g.cycles()[0].size() == 3);
    CHECK(g.component({"a", 1}) == g.component({"c", 1}));
    CHECK(g.component({"a", 1}) != g.component({"top", 1}));
    CHECK(g.component({"nothing", 9}) == nullptr);
    const auto deps = g.dependencies({"a", 1});
    CHECK(deps.size() == 1 && deps[0] == (Predicate{"b", 1}));
    CHECK(g.dependencies({"top", 1}).size() == 2);
    CHECK(g.dependencies({"top", 1}, false).size() == 1);
    CHECK(g.dependents({"a", 1}).size() == 2);  // c and top

    analysis::Stratification strat(kb);
    CHECK(strat.valid());
    CHECK(strat.level({"other", 1}) == 0 && strat.level({"top", 1}) == 1);
    CHECK(strat.level({"a", 1}) == 0);

    const auto bad = parse_program("m(a,b). win(X) <- m(X,Y), not win(Y).");
    analysis::DependencyGraph gb;
    gb.build(bad);
    CHECK(!gb.stratified && gb.has_negative_cycle());
    CHECK(!analysis::Stratification(bad).valid());
}

static void test_validation() {
    using analysis::DiagnosticSeverity;
    const auto clean = parse_program("edge(a,b). reachable(X,Y) <- edge(X,Y). reachable(X,Z) <- edge(X,Y), reachable(Y,Z).");
    const auto report = analysis::validate_program(clean);
    CHECK(report.valid() && report.errors() == 0 && report.warnings() == 0);  // joins are not warnings

    // diagnostics for clauses that never went through the KnowledgeBase checks
    HornClause unsafe{A("p", {V("X")}), {Literal{A("q", {V("Y")}), false}}};
    const auto r1 = analysis::validate_rule(unsafe);
    CHECK(!r1.valid());
    bool head_error = false;
    for (const auto& d : r1.diagnostics) head_error = head_error || d.code == "RULE_UNSAFE_HEAD_VARIABLE";
    CHECK(head_error);

    HornClause neg{A("p", {V("X")}), {Literal{A("q", {V("X")}), false}, Literal{A("r", {V("X"), V("Z")}), true}}};
    bool neg_error = false;
    for (const auto& d : analysis::validate_rule(neg).diagnostics) neg_error = neg_error || d.code == "RULE_UNSAFE_NEGATION";
    CHECK(neg_error);

    const auto singleton = analysis::validate_rule(HornClause{A("p", {V("X")}), {Literal{A("q", {V("X"), V("Y")}), false}}});
    CHECK(singleton.valid() && singleton.warnings() == 1 && singleton.diagnostics[0].code == "RULE_SINGLETON_VARIABLE");
    CHECK(analysis::validate_rule(HornClause{A("p", {V("X")}), {Literal{A("q", {V("X"), V("_Y")}), false}}}).warnings() == 0);

    CHECK(!analysis::validate_atom(Atom{Predicate{"p", 2}, {C("a")}}).valid());  // arity mismatch
    CHECK(!analysis::validate_atom(Atom{Predicate{"", 0}, {}}).valid());
    CHECK(!analysis::validate_constraint(IntegrityConstraint{}).valid());

    const auto typo = parse_program("p(a). q(X) <- p(X), pp(X).");
    const auto r2 = analysis::validate_program(typo);
    bool undefined = false;
    for (const auto& d : r2.diagnostics)
        undefined = undefined || (d.code == "UNDEFINED_PREDICATE" && d.predicate == (Predicate{"pp", 1}));
    CHECK(undefined && r2.valid() && r2.warnings() == 1);

    const auto unstrat = parse_program("m(a,b). win(X) <- m(X,Y), not win(Y).");
    CHECK(!analysis::validate_program(unstrat).valid());
}

static void test_provenance() {
    const auto kb = parse_program("a. b <- a. c <- b. d <- c, not e.");
    const FactStore store = InferenceEngine(kb).evaluate();
    Model m;
    m.facts = kb.facts();
    m.proofs = store.derivation_steps();
    const ProvenanceGraph g = build_provenance(m);
    CHECK(g.acyclic());
    CHECK(g.nodes().size() == 5);  // a b c d and the negated e
    std::size_t d = 0;
    for (const auto& node : g.nodes())
        if (node.conclusion == A("d")) d = node.id;
    CHECK(g.ancestors(d).size() == 4);  // a, b, c and the negated e
    CHECK(g.roots().size() == 2);  // a and e have no parents
    CHECK(g.descendants(0).size() == 3);  // a -> b -> c -> d
    CHECK(g.canonical_text() == build_provenance(m).canonical_text());

    Model manual;
    manual.facts.push_back(A("a"));
    manual.proofs.push_back({A("b"), "rule", {{A("a"), "fact", {}}}});
    const auto g2 = build_provenance(manual);
    CHECK(g2.nodes().size() == 2 && g2.acyclic() && g2.ancestors(1).size() == 1);
}

static void test_constraint_store() {
    constraints::ConstraintStore store;
    store.add(std::make_shared<constraints::BooleanConstraint>("x", true));
    store.add(std::make_shared<constraints::BooleanConstraint>("y", false));
    CHECK_THROWS(store.add(nullptr), std::invalid_argument);

    constraints::MapContext ctx;
    CHECK(store.consistent(ctx) && store.violations(ctx).empty());  // nothing assigned yet
    CHECK(!ctx.is_assigned("x"));
    ctx.assign("x", C("true"));
    ctx.assign("y", C("true"));
    CHECK(ctx.is_assigned("x") && ctx.value("x")->as_constant().name == "true");
    CHECK(!store.consistent(ctx));
    CHECK(store.violations(ctx) == std::vector<std::string>{"boolean(y)"});
    ctx.assign("y", C("false"));  // overwrite
    CHECK(store.consistent(ctx) && store.violations(ctx).empty());
    ctx.assign("x", C("maybe"));  // not a boolean
    CHECK(store.violations(ctx) == std::vector<std::string>{"boolean(x)"});
}

int main() {
    test_violations();
    test_model_builder();
    test_dependency_analysis();
    test_validation();
    test_provenance();
    test_constraint_store();
    return finish("integrity");
}
