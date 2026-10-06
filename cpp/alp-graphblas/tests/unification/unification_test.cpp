#include "alp/term_ops.hpp"
#include "alp/unification.hpp"
#include "check.hpp"

using namespace alp;
using namespace alp_test;

static void test_unify() {
    Substitution s;
    CHECK(Unifier::unify(A("edge", {V("X"), C("b")}), A("edge", {C("a"), V("Y")}), s));
    CHECK(apply_substitution(V("X"), s) == C("a"));
    CHECK(apply_substitution(V("Y"), s) == C("b"));

    Substitution occurs;
    CHECK(!Unifier::unify(V("X"), F("f", {V("X")}), occurs));  // occurs check

    Substitution clash;
    CHECK(!Unifier::unify(C("a"), C("b"), clash));
    CHECK(!Unifier::unify(A("p", {C("a")}), A("q", {C("a")}), clash));  // different predicates
    CHECK(!Unifier::unify(A("p", {C("a")}), A("p", {C("a"), C("b")}), clash));  // different arity

    Substitution deep;  // f(X, g(Y)) = f(g(Z), g(a))  =>  X = g(Z), Y = a
    CHECK(Unifier::unify(F("f", {V("X"), F("g", {V("Y")})}), F("f", {F("g", {V("Z")}), F("g", {C("a")})}), deep));
    CHECK(to_string(apply_substitution(V("X"), deep)) == "g(Z)");
    CHECK(apply_substitution(V("Y"), deep) == C("a"));

    Substitution chain;  // X = Y, Y = a  =>  X resolves to a
    CHECK(Unifier::unify(V("X"), V("Y"), chain));
    CHECK(Unifier::unify(V("Y"), C("a"), chain));
    CHECK(apply_substitution(V("X"), chain) == C("a"));

    Substitution shared;  // p(X, X) = p(a, b) must fail
    CHECK(!Unifier::unify(A("p", {V("X"), V("X")}), A("p", {C("a"), C("b")}), shared));
}

static void test_composition() {
    Substitution a, b;
    a.bind("X", V("Y"));
    b.bind("Y", C("c"));
    const Substitution c = compose_substitution(a, b);
    CHECK(apply_substitution(V("X"), c) == C("c"));
    CHECK(apply_substitution(V("Y"), c) == C("c"));
}

static void test_ground_helpers() {
    CHECK(is_ground(C("a")));
    CHECK(!is_ground(V("X")));
    CHECK(is_ground(F("f", {C("a"), F("g", {C("b")})})));
    CHECK(!is_ground(F("f", {C("a"), F("g", {V("X")})})));
    CHECK(is_ground(A("p", {C("a")})));
    CHECK(!is_ground(A("p", {V("X")})));
    std::set<std::string> vars;
    collect_variables(A("p", {V("X"), F("f", {V("Y"), V("X")})}), vars);
    CHECK(vars == (std::set<std::string>{"X", "Y"}));
}

static void test_term_ops() {
    const Term t = F("f", {V("X"), F("g", {C("a"), V("X")})});
    CHECK(term_size(t) == 5);
    CHECK(term_depth(t) == 2);
    CHECK(term_variable_count(t) == 2);
    CHECK(term_constant_count(t) == 1);
    CHECK(term_compound_count(t) == 2);
    CHECK(term_maximum_arity(t) == 2);
    CHECK(!is_ground(t));
    CHECK(!is_linear(t));
    CHECK(is_linear(F("f", {V("X"), V("Y")})));
    CHECK(contains_functor(t, "g"));
    CHECK(!contains_functor(t, "h"));
    CHECK(contains_constant(t, "a"));
    CHECK(contains_variable(t, "X"));
    CHECK(variable_names(t) == (std::set<std::string>{"X"}));
    CHECK(functor_names(t) == (std::set<std::string>{"f", "g"}));
    CHECK(constant_names(t) == (std::set<std::string>{"a"}));
    CHECK(variable_occurrences(t).at("X") == 2);

    const Term n = normalize_variables(t);
    CHECK(variant_equal(t, n));
    CHECK(!(t == n));
    CHECK(to_string(n) == "f(_V0,g(a,_V0))");
    CHECK(!variant_equal(F("p", {V("X"), V("X")}), F("p", {V("X"), V("Y")})));
    CHECK(to_string(freshen_variables(t, 7)) == "f(X$7,g(a,X$7))");

    CHECK(at_path(t, {1, 0}) != nullptr && at_path(t, {1, 0})->as_constant().name == "a");
    CHECK(at_path(t, {5}) == nullptr);
    CHECK(paths(t).size() == term_size(t));
    CHECK(to_string(replace_subterm(t, {1, 0}, C("z"))) == "f(X,g(z,X))");
    CHECK(preorder(t).size() == 5 && postorder(t).size() == 5);
    CHECK(preorder(t).front() == &t && postorder(t).back() == &t);

    CHECK(compare_terms(C("a"), C("b")) < 0);
    CHECK(compare_terms(C("b"), C("a")) > 0);
    CHECK(compare_terms(t, t) == 0);
    CHECK(TermHash{}(t) == TermHash{}(t));
    CHECK(TermHash{}(C("a")) != TermHash{}(C("b")));
    CHECK(skeleton(t).find("f/2") != std::string::npos);
    CHECK(fingerprint(F("p", {V("X")})) == fingerprint(F("p", {V("Y")})));

    const Term mapped = map_terms(t, [](const Term& x) { return x.is_variable() ? C("k") : x; });
    CHECK(to_string(mapped) == "f(k,g(a,k))");
}

static void test_many_constants() {  // formerly ~1000 pasted blocks
    for (int i = 0; i < 1000; ++i) {
        const std::string name = "c" + std::to_string(i);
        const Term a = Term::constant(name), b = Term::constant(name);
        CHECK(a == b);
        CHECK(to_string(a) == name);
        CHECK(is_ground(a));
        CHECK(term_size(a) == 1 && term_depth(a) == 0);
        CHECK(contains_constant(a, name));
        CHECK(!contains_constant(a, name + "x"));
    }
}

int main() {
    test_unify();
    test_composition();
    test_ground_helpers();
    test_term_ops();
    test_many_constants();
    return finish("unification");
}
