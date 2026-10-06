#include "alp/analysis/dependency.hpp"
#include "alp/io/lexer.hpp"
#include "alp/io/serialization.hpp"
#include "alp/parser.hpp"
#include "check.hpp"

using namespace alp;
using namespace alp_test;

static void test_basic_syntax() {
    const auto kb = parse_program(R"(
        % a comment
        edge(a,b).        % trailing comment
        edge(b, c).
        reachable(X,Y) <- edge(X,Y).
        reachable(X,Z) :- edge(X,Y), reachable(Y,Z).
        abducible(rain).
        abducible(broken/2).
        false <- rain, sun.
        <- a, b.
        :- c, not d.
        zero().
        n(42).
        t(f(a, g(b))).
    )");
    CHECK(kb.facts().size() == 5);  // edge x2, zero, n(42), t(...)
    CHECK(kb.rules().size() == 2);
    CHECK(kb.constraints().size() == 3);
    CHECK(kb.is_abducible({"rain", 0}));
    CHECK(kb.is_abducible({"broken", 2}));
    CHECK(!kb.is_abducible({"broken", 0}));
    CHECK(to_string(kb.rules()[1]) == "reachable(X,Z) <- edge(X,Y), reachable(Y,Z).");
    CHECK(keys(kb.facts()).contains("t(f(a,g(b)))"));
    CHECK(keys(kb.facts()).contains("zero"));
}

static void test_keywords_are_whole_words() {
    // identifiers that merely start with a keyword must not be mistaken for it
    const auto kb = parse_program(R"(
        false_alarm.
        nothing(a).
        notes(b).
        abducible_things(c).
        ok(X) <- notes(X), not nothing(b).
        falsehood <- false_alarm.
    )");
    CHECK(kb.facts().size() == 4);
    CHECK(kb.rules().size() == 2);
    CHECK(kb.constraints().empty());
    CHECK(kb.abducibles().empty());
    CHECK(kb.rules()[0].body[1].negated);
    CHECK(kb.rules()[0].body[1].atom.predicate.name == "nothing");
}

static void test_anonymous_variables() {
    const auto kb = parse_program("node(X) <- edge(X,_). node(Y) <- edge(_,Y). pair(X) <- edge(X,_), edge(_,X).");
    CHECK(kb.rules().size() == 3);
    // the two `_` of one clause are different variables
    const auto& body = kb.rules()[2].body;
    CHECK(!(body[0].atom.arguments[1] == body[1].atom.arguments[0]));
}

static void test_errors() {
    CHECK_THROWS(parse_program("p(a"), ParseError);
    CHECK_THROWS(parse_program("p(a)"), ParseError);        // missing '.'
    CHECK_THROWS(parse_program("p(a) <- ."), ParseError);   // empty body
    CHECK_THROWS(parse_program("p(a) $ q."), ParseError);   // bad character
    CHECK_THROWS(parse_program("abducible(p/x)."), ParseError);
    CHECK_THROWS(parse_program("p(X)."), ParseError);       // facts must be ground
    CHECK_THROWS(parse_program("p(X) <- q(Y)."), ParseError);       // unsafe head variable
    CHECK_THROWS(parse_program("p(X) <- q(X), not r(X,Y)."), ParseError);  // unsafe negation
    CHECK_THROWS(parse_program("p(X) <- q(X), not r(X,_)."), ParseError);  // anonymous in negation
    CHECK_THROWS(parse_program("false <- not a(X)."), ParseError);

    try {
        parse_program("a.\nb(");
        CHECK(false);
    } catch (const ParseError& e) {
        CHECK(e.line == 2);
        CHECK(std::string(e.what()).rfind("2:", 0) == 0);
    }
    try {
        parse_program("a.\n\n  q(X) <- r(Y).");
        CHECK(false);
    } catch (const ParseError& e) {
        CHECK(e.line == 3 && e.column == 3);
        CHECK(std::string(e.what()).find("unsafe") != std::string::npos);
    }
    CHECK_THROWS(parse_file("/nonexistent/file.alp"), std::runtime_error);
}

static void test_parse_atom() {
    const Atom a = parse_atom("reachable(a,X)");
    CHECK(a.predicate == (Predicate{"reachable", 2}));
    CHECK(a.arguments[0] == C("a") && a.arguments[1] == V("X"));
    CHECK(parse_atom("goal.").predicate == (Predicate{"goal", 0}));
    CHECK_THROWS(parse_atom("p(a) q"), ParseError);
}

static void test_serialization_round_trip() {
    const auto kb = parse_program(R"(
        edge(a,b). edge(b,c).
        reachable(X,Y) <- edge(X,Y).
        reachable(X,Z) <- edge(X,Y), reachable(Y,Z).
        unreachable(X,Y) <- edge(X,_), edge(_,Y), not reachable(X,Y).
        abducible(healthy/1). abducible(rain).
        false <- rain, healthy(a).
    )");
    const std::string text = io::serialize_program(kb);
    const auto copy = io::deserialize_program(text);
    CHECK(io::serialize_program(copy) == text);  // deterministic and stable
    CHECK(copy.facts().size() == kb.facts().size());
    CHECK(copy.rules().size() == kb.rules().size());
    CHECK(copy.constraints().size() == kb.constraints().size());
    CHECK(copy.is_abducible({"healthy", 1}) && copy.is_abducible({"rain", 0}));
    CHECK(!copy.is_abducible({"healthy", 0}));
    CHECK(io::serialize_atom(A("p", {C("a"), V("X")})) == "p(a,X)");
    CHECK(io::serialize_clause(kb.rules()[0]) == "reachable(X,Y) <- edge(X,Y).");
}

static void test_lexer() {
    io::Lexer lexer("p(X) <- not q(a), false. % c\n 'quoted atom' 12");
    const auto tokens = lexer.all();
    std::vector<io::TokenKind> kinds;
    for (const auto& t : tokens) kinds.push_back(t.kind);
    using K = io::TokenKind;
    const std::vector<K> expected{K::identifier, K::lparen, K::variable, K::rparen, K::arrow, K::not_keyword,
                                  K::identifier, K::lparen, K::identifier, K::rparen, K::comma, K::false_keyword,
                                  K::dot, K::quoted_atom, K::integer, K::eof_token};
    CHECK(kinds == expected);
    CHECK(tokens[13].text == "quoted atom");
    CHECK(tokens[13].position.line == 2);
    CHECK(std::string(io::token_kind_name(K::arrow)) == "arrow");
}

int main() {
    test_basic_syntax();
    test_keywords_are_whole_words();
    test_anonymous_variables();
    test_errors();
    test_parse_atom();
    test_serialization_round_trip();
    test_lexer();
    return finish("parser");
}
