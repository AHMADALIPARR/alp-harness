// Runs the shipped .alp programs end to end (the working directory is the repository root).
#include "alp/abduction.hpp"
#include "alp/analysis/validation.hpp"
#include "alp/graph/bridge.hpp"
#include "alp/inference.hpp"
#include "alp/integrity.hpp"
#include "alp/logic/sld.hpp"
#include "alp/parser.hpp"
#include "check.hpp"

using namespace alp;
using namespace alp_test;

static KnowledgeBase load(std::initializer_list<const char*> files) {
    KnowledgeBase kb;
    for (const char* f : files) kb.merge(parse_file(std::string("alp/") + f));
    return kb;
}

static std::set<std::string> answers(const KnowledgeBase& kb, const Atom& goal) {
    return keys(InferenceEngine::solutions(goal, InferenceEngine(kb).evaluate()));
}

static void test_every_program_parses_and_validates() {
    for (const char* f : {"examples/agent_planning.alp", "examples/diagnosis.alp", "examples/graph_reachability.alp",
                          "examples/grass_wet.alp", "examples/birds.alp", "library/agents.alp", "library/constraints.alp",
                          "library/defaults.alp", "library/graph.alp", "library/reasoning.alp"}) {
        const auto kb = load({f});
        const auto report = analysis::validate_program(kb);
        if (!report.valid()) std::cerr << f << " does not validate\n";
        CHECK(report.valid());
        InferenceEngine(kb).evaluate();  // stratified: does not throw
    }
}

static void test_grass_wet() {
    const auto kb = load({"examples/grass_wet.alp"});
    AbductiveSolver solver(kb);
    const Atom goal = A("grass_is_wet");

    // grass_is_wet is an observation to explain, not a fact of the program
    CHECK(!keys(kb.facts()).contains("grass_is_wet"));

    // the defaults (`not sprinkler_off`, `not pipes_frozen`) already explain it: the minimal explanation is {}
    const auto minimal = solver.minimal_explanations(goal);
    CHECK(minimal.size() == 1 && minimal[0].abduced.empty());

    const auto all = solver.solve(goal);
    CHECK(all.size() > 1);
    bool has_broken = false;
    for (const auto& m : all) {
        const auto k = keys(m.abduced);
        has_broken = has_broken || k == (std::set<std::string>{"sprinkler_broken"});
        // the sun is shining, so rain and cold are excluded by the integrity constraints
        CHECK(!k.contains("it_rained_last_night") && !k.contains("cold_last_night"));
        CHECK(!(k.contains("sprinkler_turned_on") && k.contains("sprinkler_off")));
        CHECK(m.valid);
    }
    CHECK(has_broken);
}

static void test_diagnosis() {
    const auto kb = load({"examples/diagnosis.alp"});
    AbductiveSolver solver(kb);
    const auto alarm = solver.minimal_explanations(A("alarm"));
    CHECK(alarm.size() == 1 && keys(alarm[0].abduced) == (std::set<std::string>{"frayed_wire"}));
    // fan and coolant are known to be fine; the only other candidate is the unrelated healthy(pump)
    const auto all = solver.solve(A("alarm"));
    CHECK(all.size() == 2);
    for (const auto& m : all) {
        const auto k = keys(m.abduced);
        CHECK(k.contains("frayed_wire") && !k.contains("fan_failed") && !k.contains("coolant_leak"));
    }
    CHECK(InferenceEngine(kb).query(A("faulty", {C("pump")})));
    CHECK(!InferenceEngine(kb).query(A("faulty", {C("pump")}), {A("healthy", {C("pump")})}));
    const auto faulty = solver.minimal_explanations(A("faulty", {C("pump")}));
    CHECK(faulty.size() == 1 && faulty[0].abduced.empty());
}

static void test_graph_reachability() {
    const auto kb = load({"examples/graph_reachability.alp"});
    const std::set<std::string> from_a{"reachable(a,b)", "reachable(a,c)", "reachable(a,d)", "reachable(a,e)", "reachable(a,f)"};
    CHECK(answers(kb, A("reachable", {C("a"), V("X")})) == from_a);

    logic::SLDResolver sld(kb);
    std::set<std::string> top_down;
    for (const auto& a : sld.solve(A("reachable", {C("a"), V("X")}))) top_down.insert(to_string(a.proofs[0].conclusion));
    CHECK(top_down == from_a);

    graph::GraphPredicateBridge bridge(graph::Backend::Auto);
    const FactStore s = graph::evaluate_with_graph(kb, bridge);
    CHECK(keys(InferenceEngine::solutions(A("reachable", {C("a"), V("X")}), s)) == from_a);
}

static void test_agents() {
    const auto kb = load({"examples/agent_planning.alp"});
    CHECK(answers(kb, A("can_execute", {V("A"), V("X")})) ==
          (std::set<std::string>{"can_execute(alice,send_email)", "can_execute(bob,send_email)"}));
    CHECK(answers(kb, A("blocked", {V("A"), V("X")})) == (std::set<std::string>{"blocked(alice,delete_files)"}));
    CHECK(answers(kb, A("agent_ready", {V("A")})) == (std::set<std::string>{"agent_ready(alice)"}));

    // the library versions of the same rules give the same answers on the same facts
    auto lib = load({"library/agents.alp", "library/constraints.alp"});
    lib.assert_fact(A("agent", {C("alice")}));
    lib.assert_fact(A("action", {C("alice"), C("delete_files")}));
    lib.assert_fact(A("conflict", {C("alice")}));
    const FactStore s = InferenceEngine(lib).evaluate();
    CHECK(violations(lib, s).size() == 1);  // conflict(alice) is not permitted
    lib.assert_fact(A("permitted", {C("alice")}));
    CHECK(violations(lib, InferenceEngine(lib).evaluate()).empty());
}

static void test_defaults() {
    const auto kb = load({"examples/birds.alp"});
    CHECK(answers(kb, A("flies", {V("X")})) == (std::set<std::string>{"flies(tweety)"}));
    auto lib = load({"library/defaults.alp"});
    lib.assert_fact(A("bird", {C("tweety")}));
    lib.assert_fact(A("penguin", {C("pingu")}));
    CHECK(answers(lib, A("flies", {V("X")})) == (std::set<std::string>{"flies(tweety)"}));
}

static void test_graph_library() {
    auto kb = load({"library/graph.alp", "library/reasoning.alp"});
    for (auto [a, b] : {std::pair{"a", "b"}, {"b", "c"}, {"d", "e"}}) kb.assert_fact(A("edge", {C(a), C(b)}));
    CHECK(answers(kb, A("node", {V("X")})).size() == 5);
    CHECK(answers(kb, A("reachable", {C("a"), V("X")})) == (std::set<std::string>{"reachable(a,b)", "reachable(a,c)"}));
    CHECK(answers(kb, A("connected", {C("c"), V("X")})) == (std::set<std::string>{"connected(c,b)"}));
    CHECK(answers(kb, A("path", {V("X"), V("Y")})).size() == 4);
    CHECK(answers(kb, A("unreachable", {C("a"), V("X")})) ==
          (std::set<std::string>{"unreachable(a,a)", "unreachable(a,d)", "unreachable(a,e)"}));
    kb.assert_fact(A("same", {C("x"), C("y")}));
    kb.assert_fact(A("same", {C("y"), C("z")}));
    CHECK(answers(kb, A("same", {C("z"), C("x")})).size() == 1);
}

int main() {
    test_every_program_parses_and_validates();
    test_grass_wet();
    test_diagnosis();
    test_graph_reachability();
    test_agents();
    test_defaults();
    test_graph_library();
    return finish("integration");
}
