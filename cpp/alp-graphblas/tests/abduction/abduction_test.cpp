#include "alp/abduction.hpp"
#include "alp/parser.hpp"
#include "check.hpp"

using namespace alp;
using namespace alp_test;

static std::set<std::string> explanation(const Model& m) { return keys(m.abduced); }

static void test_constraints_prune_explanations() {
    const auto kb = parse_program(R"(
        sun_is_shining.
        grass_is_wet <- rain.
        grass_is_wet <- sprinkler.
        abducible(rain). abducible(sprinkler).
        false <- rain, sun_is_shining.
    )");
    const auto models = AbductiveSolver(kb).solve(A("grass_is_wet"));
    CHECK(models.size() == 1);  // {rain} and {rain,sprinkler} violate the constraint
    CHECK(explanation(models[0]) == (std::set<std::string>{"sprinkler"}));
    CHECK(models[0].valid && models[0].violations.empty());
    CHECK(models[0].answers.size() == 1 && models[0].answers[0] == A("grass_is_wet"));
    CHECK(keys(models[0].derived) == (std::set<std::string>{"grass_is_wet"}));
    CHECK(!models[0].proofs.empty());
}

static void test_all_versus_minimal() {
    const auto kb = parse_program("wet <- rain. wet <- sprinkler. abducible(rain). abducible(sprinkler).");
    AbductiveSolver solver(kb);
    const auto all = solver.solve(A("wet"));
    CHECK(all.size() == 3);  // {rain} {sprinkler} {rain,sprinkler}, ordered by size
    CHECK(all[0].abduced.size() == 1 && all[1].abduced.size() == 1 && all[2].abduced.size() == 2);
    const auto minimal = solver.minimal_explanations(A("wet"));
    CHECK(minimal.size() == 2);
    CHECK(explanation(minimal[0]) == (std::set<std::string>{"rain"}));
    CHECK(explanation(minimal[1]) == (std::set<std::string>{"sprinkler"}));
}

static void test_empty_explanation_when_goal_already_holds() {
    const auto kb = parse_program("p. abducible(q).");
    const auto minimal = AbductiveSolver(kb).minimal_explanations(A("p"));
    CHECK(minimal.size() == 1 && minimal[0].abduced.empty());
    CHECK(AbductiveSolver(kb).solve(A("p")).size() == 2);  // {} and {q}
}

static void test_negation_as_failure_in_explanations() {
    const auto kb = parse_program(R"(
        safe <- not fault.
        alarm <- fault.
        abducible(fault).
    )");
    AbductiveSolver solver(kb);
    CHECK(explanation(solver.minimal_explanations(A("safe"))[0]).empty());
    const auto alarm = solver.minimal_explanations(A("alarm"));
    CHECK(alarm.size() == 1 && explanation(alarm[0]) == (std::set<std::string>{"fault"}));
    CHECK(solver.solve(A("safe")).size() == 1);  // with fault abduced, safe no longer holds
}

static void test_abducibles_of_arity_greater_than_zero() {
    const auto kb = parse_program(R"(
        machine(m1). machine(m2).
        works(X) <- machine(X), not broken(X).
        alarm <- machine(X), broken(X).
        abducible(broken/1).
    )");
    AbductiveSolver solver(kb);
    const auto alarm = solver.minimal_explanations(A("alarm"));
    CHECK(alarm.size() == 2);
    CHECK(explanation(alarm[0]) == (std::set<std::string>{"broken(m1)"}));
    CHECK(explanation(alarm[1]) == (std::set<std::string>{"broken(m2)"}));

    // goals with variables report every holding instance
    const auto works = solver.minimal_explanations(A("works", {V("X")}));
    CHECK(works.size() == 1 && works[0].abduced.empty());
    CHECK(keys(works[0].answers) == (std::set<std::string>{"works(m1)", "works(m2)"}));
    const auto m1 = solver.solve(A("works", {C("m1")}));
    CHECK(m1.size() == 2);  // {} and {broken(m2)}
}

static void test_no_explanation() {
    const auto kb = parse_program("wet <- rain. abducible(rain). false <- rain.");
    CHECK(AbductiveSolver(kb).solve(A("wet")).empty());
    CHECK(AbductiveSolver(kb).solve(A("unrelated")).empty());
}

static void test_search_space_bound() {
    std::string program = "abducible(h/1).\n";
    for (int i = 0; i < 25; ++i) program += "c(k" + std::to_string(i) + ").\n";
    program += "goal <- c(X), h(X).\n";
    const auto kb = parse_program(program);
    CHECK_THROWS(AbductiveSolver(kb).solve(A("goal")), std::runtime_error);

    // within the bound, the same program is solved
    std::string small = "abducible(h/1).\n";
    for (int i = 0; i < 3; ++i) small += "c(k" + std::to_string(i) + ").\n";
    small += "goal <- c(X), h(X).\n";
    CHECK(AbductiveSolver(parse_program(small)).minimal_explanations(A("goal")).size() == 3);
}

int main() {
    test_constraints_prune_explanations();
    test_all_versus_minimal();
    test_empty_explanation_when_goal_already_holds();
    test_negation_as_failure_in_explanations();
    test_abducibles_of_arity_greater_than_zero();
    test_no_explanation();
    test_search_space_bound();
    return finish("abduction");
}
