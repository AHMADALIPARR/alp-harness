#include "alp/inference.hpp"
#include "alp/logic/runtime.hpp"
#include "alp/logic/sld.hpp"
#include "alp/parser.hpp"
#include "check.hpp"
#include <algorithm>
#include <chrono>

using namespace alp;
using namespace alp_test;

static void test_forward_chaining() {
    const auto kb = parse_program(R"(
        edge(a,b). edge(b,c). edge(c,d).
        reachable(X,Y) <- edge(X,Y).
        reachable(X,Z) <- edge(X,Y), reachable(Y,Z).
    )");
    InferenceEngine e(kb);
    const FactStore store = e.evaluate();
    CHECK(store.contains(A("reachable", {C("a"), C("d")})));
    CHECK(!store.contains(A("reachable", {C("d"), C("a")})));
    CHECK(store.size() == 3 + 6);
    CHECK(e.query(A("reachable", {C("a"), V("X")})));
    CHECK(InferenceEngine::solutions(A("reachable", {C("a"), V("X")}), store).size() == 3);

    // full proof tree: reachable(a,d) <- edge(a,b), reachable(b,d) <- ...
    const Proof p = store.proof(A("reachable", {C("a"), C("d")}));
    CHECK(p.source.rfind("rule:", 0) == 0);
    CHECK(p.premises.size() == 2);
    CHECK(p.premises[0].conclusion == A("edge", {C("a"), C("b")}) && p.premises[0].source == "fact");
    CHECK_THROWS(store.proof(A("reachable", {C("d"), C("a")})), std::out_of_range);
    CHECK(store.derivation_steps().size() == 6);
}

static void test_seed_atoms() {
    const auto kb = parse_program("q(X) <- p(X). r <- q(a).");
    InferenceEngine e(kb);
    CHECK(!e.query(A("r")));
    CHECK(e.query(A("r"), {A("p", {C("a")})}));
    const FactStore s = e.evaluate({A("p", {C("a")})});
    CHECK(s.derivation(A("p", {C("a")}))->source == "assumption");
    CHECK_THROWS(e.evaluate({A("p", {V("X")})}), std::invalid_argument);  // seeds must be ground
}

static void test_negation_is_stratified() {
    // `r` is written before the rules it depends on, and negates `s` first in its body:
    // the result must not depend on rule order, body order or iteration order.
    const auto kb = parse_program(R"(
        r(X) <- not s(X), p(X).
        s(X) <- q(X), not u(X).
        p(a). p(b). q(a). q(b). u(b).
    )");
    const FactStore s = InferenceEngine(kb).evaluate();
    CHECK(s.contains(A("s", {C("a")})));
    CHECK(!s.contains(A("s", {C("b")})));
    CHECK(!s.contains(A("r", {C("a")})));
    CHECK(s.contains(A("r", {C("b")})));
    const Proof pr = s.proof(A("r", {C("b")}));
    bool saw_naf = false;
    for (const auto& q : pr.premises) saw_naf = saw_naf || q.source == "not derivable";
    CHECK(saw_naf);
}

static void test_unstratified_is_rejected() {
    const auto kb = parse_program("move(a,b). move(b,a). win(X) <- move(X,Y), not win(Y).");
    CHECK_THROWS(InferenceEngine(kb).evaluate(), std::invalid_argument);
    logic::SLDResolver sld(kb);
    CHECK_THROWS(sld.solve(A("win", {V("X")})), std::invalid_argument);
    const auto r = logic::FixedPointEngine(kb).run();  // reports instead of throwing
    CHECK(!r.stratified && r.closure.empty());
    logic::DerivationOptions lenient;
    lenient.reject_unstratified_program = false;
    CHECK_THROWS(logic::FixedPointEngine(kb, lenient).run(), std::invalid_argument);
}

static void test_fixed_point_engine_options() {
    const auto kb = parse_program("e(a,b). e(b,c). e(c,d). r(X,Y) <- e(X,Y). r(X,Z) <- e(X,Y), r(Y,Z). n(X) <- e(X,_), not has_in(X). has_in(X) <- e(_,X).");
    const auto full = logic::FixedPointEngine(kb).run();
    CHECK(full.fixed_point && full.stratified);
    CHECK(full.closure.size() == 3 + 6 + 3 + 1);  // + has_in(b,c,d) + n(a)
    CHECK(full.proofs.size() == 10);
    CHECK(full.iterations >= 2);

    logic::DerivationOptions capped;
    capped.maximum_iterations = 1;
    const auto cut = logic::FixedPointEngine(kb, capped).run();
    CHECK(!cut.fixed_point && cut.iterations == 1);
    CHECK(cut.closure.size() < full.closure.size());

    logic::DerivationOptions no_naf;
    no_naf.apply_negative_literals = false;
    CHECK(logic::FixedPointEngine(kb, no_naf).run().closure.size() == 3 + 6 + 3);  // n/1 (uses `not`) is skipped

    logic::DerivationOptions no_seed, no_proofs;
    no_seed.include_seed = false;
    no_proofs.record_proofs = false;
    CHECK(logic::FixedPointEngine(kb, no_seed).run({A("e", {C("d"), C("z")})}).closure.size() == full.closure.size());
    CHECK(logic::FixedPointEngine(kb, no_proofs).run().proofs.empty());
    CHECK(logic::FixedPointEngine(kb).run({A("e", {C("d"), C("z")})}).closure.size() > full.closure.size());
}

static void test_sld_basics() {
    const auto kb = parse_program(R"(
        parent(alice,bob). parent(bob,carol).
        ancestor(X,Y) <- parent(X,Y).
        ancestor(X,Z) <- parent(X,Y), ancestor(Y,Z).
        bird(tweety). bird(pingu). penguin(pingu).
        flies(X) <- bird(X), not penguin(X).
    )");
    logic::SLDResolver r(kb);
    CHECK(r.entails(A("ancestor", {C("alice"), C("carol")})));
    CHECK(!r.entails(A("ancestor", {C("carol"), C("alice")})));
    const auto answers = r.solve(A("ancestor", {C("alice"), V("Y")}));
    CHECK(answers.size() == 2);
    CHECK(apply_substitution(V("Y"), answers[0].substitution) == C("bob"));  // sorted by text
    CHECK(apply_substitution(V("Y"), answers[1].substitution) == C("carol"));
    CHECK(answers[1].proofs.size() == 1 && answers[1].proofs[0].conclusion == A("ancestor", {C("alice"), C("carol")}));
    CHECK(r.entails(A("flies", {C("tweety")})));
    CHECK(!r.entails(A("flies", {C("pingu")})));
    CHECK(r.solve(A("flies", {V("X")})).size() == 1);
    CHECK(r.statistics().calls > 0 && r.statistics().passes >= 1 && !r.statistics().truncated);

    logic::ResolutionOptions limited;
    limited.maximum_answers = 1;
    CHECK(logic::SLDResolver(kb, limited).solve(A("ancestor", {V("X"), V("Y")})).size() == 1);
    logic::ResolutionOptions no_naf;
    no_naf.allow_negation_as_failure = false;
    CHECK(!logic::SLDResolver(kb, no_naf).entails(A("flies", {C("tweety")})));
    logic::ResolutionOptions no_index;
    no_index.use_clause_index = false;
    CHECK(logic::SLDResolver(kb, no_index).solve(A("ancestor", {V("X"), V("Y")})).size() == 3);

    // seed atoms act as extra facts
    CHECK(r.entails(A("ancestor", {C("carol"), C("dan")}), {A("parent", {C("carol"), C("dan")})}));
}

// Left recursion and cycles used to be cut off (incomplete answers) by the loop check.
static void test_sld_cycles_and_left_recursion() {
    const auto kb = parse_program(R"(
        e(a,b). e(b,c). e(c,a). e(c,d).
        left(X,Y) <- e(X,Y).
        left(X,Z) <- left(X,Y), e(Y,Z).
        p(X,Y) <- e(X,Y).
        p(X,Z) <- q(X,Y), e(Y,Z).
        q(X,Y) <- p(X,Y).
    )");
    logic::SLDResolver r(kb);
    const FactStore bottom_up = InferenceEngine(kb).evaluate();
    for (const char* pred : {"left", "p", "q"}) {
        const Atom goal = A(pred, {V("X"), V("Y")});
        std::set<std::string> top_down;
        for (const auto& a : r.solve(goal)) top_down.insert(to_string(apply_substitution(goal, a.substitution)));
        CHECK(top_down == keys(InferenceEngine::solutions(goal, bottom_up)));
    }
    CHECK(r.solve(A("left", {C("b"), V("Y")})).size() == 4);  // b reaches c, a, b (via the cycle) and d
    CHECK(r.entails(A("left", {C("a"), C("a")})));            // a -> b -> c -> a

    logic::ResolutionOptions untabled;
    untabled.use_tabling = false;
    untabled.maximum_depth = 40;
    const auto cut = logic::SLDResolver(kb, untabled).solve(A("left", {C("a"), V("Y")}));
    CHECK(!cut.empty());  // terminates thanks to the depth bound
    // with tabling the recursion above stays shallow; a chain makes depth matter
    const auto chain = parse_program("e(a,b). e(b,c). e(c,d). e(d,f). r(X,Y) <- e(X,Y). r(X,Z) <- e(X,Y), r(Y,Z).");
    logic::ResolutionOptions shallow_options;
    shallow_options.maximum_depth = 1;
    logic::SLDResolver shallow(chain, shallow_options);
    CHECK(shallow.solve(A("r", {C("a"), V("Y")})).size() < 4);
    CHECK(shallow.statistics().truncated);  // incompleteness is reported, not silent
    logic::SLDResolver deep(chain);
    CHECK(deep.solve(A("r", {C("a"), V("Y")})).size() == 4 && !deep.statistics().truncated);
}

// Property: top-down SLD answers == bottom-up answers on random graphs, with recursion and negation.
static void test_sld_matches_bottom_up_on_random_graphs() {
    for (std::uint64_t seed = 1; seed <= 60; ++seed) {
        Rng rng(seed);
        const std::size_t n = 2 + rng.below(8);
        std::string prog = "node(n0).\n";
        for (std::size_t i = 0; i < n; ++i) prog += "node(n" + std::to_string(i) + ").\n";
        const std::size_t m = rng.below(2 * n + 1);
        for (std::size_t k = 0; k < m; ++k)
            prog += "e(n" + std::to_string(rng.below(n)) + ",n" + std::to_string(rng.below(n)) + ").\n";
        prog += R"(
            r(X,Y) <- e(X,Y).
            r(X,Z) <- r(X,Y), r(Y,Z).
            s(X,Z) <- e(X,Y), s(Y,Z).
            s(X,Y) <- e(X,Y).
            unreach(X,Y) <- node(X), node(Y), not r(X,Y).
            lonely(X) <- node(X), not on_cycle(X), not has_out(X).
            on_cycle(X) <- r(X,X).
            has_out(X) <- e(X,_).
        )";
        const auto kb = parse_program(prog);
        const FactStore bottom_up = InferenceEngine(kb).evaluate();
        logic::SLDResolver sld(kb);
        for (const char* pred : {"r", "s", "unreach"}) {
            const Atom goal = A(pred, {V("X"), V("Y")});
            std::set<std::string> top_down;
            for (const auto& a : sld.solve(goal)) top_down.insert(to_string(apply_substitution(goal, a.substitution)));
            CHECK(top_down == keys(InferenceEngine::solutions(goal, bottom_up)));
        }
        const Atom lonely = A("lonely", {V("X")});
        std::set<std::string> top_down;
        for (const auto& a : sld.solve(lonely)) top_down.insert(to_string(apply_substitution(lonely, a.substitution)));
        CHECK(top_down == keys(InferenceEngine::solutions(lonely, bottom_up)));
    }
}

// formerly a 6000-line generated file
static void test_large_program() {
    const int n = 2000;
    std::string program;
    for (int i = 0; i < n; ++i) {
        program += "fact_" + std::to_string(i) + "(v" + std::to_string(i) + ").\n";
        program += "base_" + std::to_string(i) + "(w" + std::to_string(i) + ").\n";
        program += "copy_" + std::to_string(i) + "(X) <- fact_" + std::to_string(i) + "(X).\n";
    }
    const auto kb = parse_program(program);
    CHECK(kb.facts().size() == 2 * n);
    CHECK(kb.rules().size() == static_cast<std::size_t>(n));
    const auto result = logic::FixedPointEngine(kb).run();
    CHECK(result.fixed_point);
    CHECK(result.closure.size() == 3 * n);
    CHECK(result.iterations <= 3);
}

static void test_long_chain_scales() {
    std::string program;
    for (int i = 0; i < 300; ++i) program += "e(n" + std::to_string(i) + ",n" + std::to_string(i + 1) + ").\n";
    program += "r(X,Y) <- e(X,Y). r(X,Z) <- e(X,Y), r(Y,Z).\n";
    const auto kb = parse_program(program);
    const FactStore store = InferenceEngine(kb).evaluate();
    CHECK(store.with_predicate({"r", 2}).size() == 300u * 301u / 2u);
    logic::SLDResolver sld(kb);
    CHECK(sld.solve(A("r", {C("n0"), V("Y")})).size() == 300);
    CHECK(sld.entails(A("r", {C("n0"), C("n300")})));
}

template <class F>
static void timed(const char* name, F f) {
    const auto t0 = std::chrono::steady_clock::now();
    f();
    const double sec = std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();
    if (sec > 1.0) std::cerr << "note: " << name << " took " << sec << " s\n";
}

int main() {
#define RUN(t) timed(#t, t)
    RUN(test_forward_chaining);
    RUN(test_seed_atoms);
    RUN(test_negation_is_stratified);
    RUN(test_unstratified_is_rejected);
    RUN(test_fixed_point_engine_options);
    RUN(test_sld_basics);
    RUN(test_sld_cycles_and_left_recursion);
    RUN(test_sld_matches_bottom_up_on_random_graphs);
    RUN(test_large_program);
    RUN(test_long_chain_scales);
    return finish("horn");
}
