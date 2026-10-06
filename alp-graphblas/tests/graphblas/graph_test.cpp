// Graph layer tests that run in every build (ALP enabled or not): graph core, closure algorithms
// checked against each other, the five graph predicates, the bridge and the graph utilities.
#include "alp/graph/adjacency.hpp"
#include "alp/graph/bridge.hpp"
#include "alp/graph/export.hpp"
#include "alp/graph/operations.hpp"
#include "alp/parser.hpp"
#include "check.hpp"

using namespace alp;
using namespace alp::graph;
using namespace alp_test;

static Graph sample() {
    Graph g;
    g.add_edge("a", "b");
    g.add_edge("b", "c");
    g.add_edge("c", "d");
    g.add_edge("a", "e");
    g.add_edge("e", "f");
    return g;
}

static Graph random_graph(std::uint64_t seed) {
    Rng rng(seed);
    Graph g;
    const std::size_t n = 1 + rng.below(12), m = rng.below(3 * n + 1);
    for (std::size_t i = 0; i < n; ++i) g.add_node("v" + std::to_string(i));
    for (std::size_t k = 0; k < m; ++k)
        g.add_edge("v" + std::to_string(rng.below(n)), "v" + std::to_string(rng.below(n)));
    return g;
}

static void test_graph_core() {
    Graph g = sample();
    CHECK(g.index().size() == 6 && g.edges().size() == 5);
    g.add_edge("a", "b");  // duplicate
    CHECK(g.edges().size() == 5);
    CHECK(g.has_edge("a", "b") && !g.has_edge("b", "a") && !g.has_edge("a", "zzz"));
    g.add_node("lonely");
    CHECK(g.index().contains("lonely") && g.index().size() == 7);
    CHECK(g.index().name(g.index().id("c")) == "c");
    CHECK_THROWS(g.index().id("missing"), std::out_of_range);
    CHECK_THROWS(g.index().name(99), std::out_of_range);

    const AdjacencyMatrix m(g);
    CHECK(m.size() == 7 && m.nnz() == 5);
    CHECK(m.has(g.index().id("a"), g.index().id("e")) && !m.has(g.index().id("e"), g.index().id("a")));
    CHECK(m.neighbors(g.index().id("a")).size() == 2);
    CHECK(m.neighbors(g.index().id("lonely")).empty());
    CHECK_THROWS(m.neighbors(99), std::out_of_range);
}

static void test_closure_algorithms_agree() {
    for (std::uint64_t seed = 1; seed <= 200; ++seed) {
        const Graph g = random_graph(seed);
        const auto fixed = closure_by_fixed_point(g);
        const auto bfs = transitive_closure_reference(g);
        CHECK(fixed == bfs);
        CHECK(Reachability(Backend::Reference).compute(g) == bfs);
        // closure is transitive and contains the edges
        const std::set<std::pair<std::size_t, std::size_t>> set(fixed.begin(), fixed.end());
        for (const auto& e : g.edges()) CHECK(set.contains({e.source, e.target}));
        for (auto [i, j] : fixed)
            for (auto [k, l] : fixed)
                if (j == k) CHECK(set.contains({i, l}));
    }
    // cycles: (v,v) only for vertices on a cycle
    Graph cyc;
    cyc.add_edge("x", "y");
    cyc.add_edge("y", "x");
    cyc.add_edge("y", "z");
    cyc.add_edge("w", "w");
    const auto c = transitive_closure_reference(cyc);
    CHECK(c.size() == 4 + 2 + 1);  // {x,y}^2, x->z, y->z, w->w
    CHECK(closure_by_fixed_point(Graph{}).empty());
}

static void test_reachability_backend_selection() {
    const Graph g = sample();
    CHECK(Reachability(Backend::Reference).backend_name() == "reference");
    CHECK(Reachability(Backend::Reference).compute(g).size() == 9);  // a:{b,c,d,e,f} b:{c,d} c:{d} e:{f}
    if (Reachability::graphblas_available()) {
        CHECK(Reachability().backend_name() == "alp-graphblas");
    } else {
        CHECK(Reachability().backend_name() == "reference");
        CHECK_THROWS(Reachability(Backend::GraphBLAS).compute(g), std::runtime_error);
    }
}

static void test_predicates_and_bridge() {
    const Graph g = sample();
    GraphPredicateBridge bridge(Backend::Reference);
    for (const char* p : {"edge", "connected", "reachable", "path"}) CHECK(bridge.supports({p, 2}));
    CHECK(bridge.supports({"node", 1}));
    CHECK(!bridge.supports({"edge", 3}) && !bridge.supports({"other", 2}));

    const Atom any2 = A("edge", {V("X"), V("Y")});
    CHECK(bridge.execute(A("node", {V("X")}), g).size() == 6);
    CHECK(bridge.execute(any2, g).size() == 5);
    CHECK(bridge.execute(A("connected", {V("X"), V("Y")}), g).size() == 10);  // both directions
    CHECK(bridge.execute(A("reachable", {V("X"), V("Y")}), g).size() == 9);
    CHECK(keys(bridge.execute(A("path", {V("X"), V("Y")}), g)).contains("path(a,d)"));
    CHECK(bridge.execute(A("unknown", {V("X")}), g).empty());

    CHECK(bridge.query(A("reachable", {C("a"), C("d")}), g));
    CHECK(!bridge.query(A("reachable", {C("d"), C("a")}), g));
    CHECK(bridge.query(A("connected", {C("d"), C("c")}), g));  // symmetric
    CHECK(!bridge.query(A("edge", {C("d"), C("c")}), g));
    CHECK(bridge.query(A("reachable", {C("a"), V("Y")}), g));
    CHECK(!bridge.query(A("reachable", {C("f"), V("Y")}), g));

    // extract_graph reads node/1 and edge/2 atoms only
    const Graph back = extract_graph({A("edge", {C("p"), C("q")}), A("node", {C("r")}), A("other", {C("s")})});
    CHECK(back.index().size() == 3 && back.edges().size() == 1);

    // saturate adds only what is missing
    const auto base = materialize_edges(g);
    const auto added = bridge.saturate(base);
    CHECK(keys(added).contains("reachable(a,f)") && keys(added).contains("connected(b,a)") && keys(added).contains("node(a)"));
    CHECK(!keys(added).contains("edge(a,b)"));
}

static void test_evaluate_with_graph() {
    // edges are derived by a rule; reachability then comes from the graph backend
    const auto kb = parse_program(R"(
        link(a,b). link(b,c). link(c,d).
        edge(X,Y) <- link(X,Y).
        far(X,Y) <- reachable(X,Y), not connected(X,Y).
    )");
    GraphPredicateBridge bridge(Backend::Reference);
    const FactStore store = evaluate_with_graph(kb, bridge);
    CHECK(store.contains(A("reachable", {C("a"), C("d")})));
    CHECK(store.contains(A("far", {C("a"), C("c")})) && store.contains(A("far", {C("a"), C("d")})));
    CHECK(!store.contains(A("far", {C("a"), C("b")})));  // adjacent
    CHECK(!store.contains(A("far", {C("b"), C("a")})));  // not reachable
    // same answers as plain rules
    const auto plain = parse_program(R"(
        link(a,b). link(b,c). link(c,d).
        edge(X,Y) <- link(X,Y).
        reachable(X,Y) <- edge(X,Y).
        reachable(X,Z) <- edge(X,Y), reachable(Y,Z).
        connected(X,Y) <- edge(X,Y).
        connected(X,Y) <- edge(Y,X).
        far(X,Y) <- reachable(X,Y), not connected(X,Y).
    )");
    const FactStore expected = InferenceEngine(plain).evaluate();
    CHECK(keys(store.with_predicate({"far", 2})) == keys(expected.with_predicate({"far", 2})));
    CHECK(keys(store.with_predicate({"reachable", 2})) == keys(expected.with_predicate({"reachable", 2})));
}

static void test_operations() {
    const Graph g = sample();
    const auto id = [&](const char* n) { return g.index().id(n); };
    const auto s = statistics(g);
    CHECK(s.vertices == 6 && s.edges == 5 && s.self_loops == 0 && s.maximum_out_degree == 2 && s.maximum_in_degree == 1);
    CHECK(out_degree(g, id("a")) == 2 && in_degree(g, id("a")) == 0 && in_degree(g, id("d")) == 1);
    CHECK(out_neighbors(g, id("a")).size() == 2 && in_neighbors(g, id("d")) == std::vector<std::size_t>{id("c")});
    CHECK(sources(g) == std::vector<std::size_t>{id("a")});
    CHECK(sinks(g).size() == 2);
    CHECK(isolated(g).empty());
    CHECK(has_edge(g, id("a"), id("b")) && !has_edge(g, id("b"), id("a")));
    CHECK(has_path(g, id("a"), id("d")) && !has_path(g, id("d"), id("a")) && has_path(g, id("a"), id("a")));
    const auto p = shortest_path(g, id("a"), id("f"));
    CHECK(p.found && p.vertices == (std::vector<std::size_t>{id("a"), id("e"), id("f")}));
    CHECK(!shortest_path(g, id("f"), id("a")).found && !shortest_path(g, 99, 0).found);
    CHECK(shortest_path(g, id("a"), id("d")).vertices.size() == 4);
    CHECK(symmetric_closure(g).size() == 10 && reflexive_closure(g).size() == 5 + 6);

    Graph h = sample();
    h.add_node("iso");
    h.add_edge("loop", "loop");
    const auto hs = statistics(h);
    CHECK(hs.self_loops == 1 && hs.isolated_vertices == 1);
    CHECK(isolated(h).size() == 1 && h.index().name(isolated(h)[0]) == "iso");

    CHECK(materialize_edges(g).size() == 5 && materialize_nodes(g).size() == 6);
    CHECK(materialize_connected(g).size() == 10 && materialize_reachable_reference(g).size() == 9);
}

static void test_export() {
    const Graph g = sample();
    const std::string edges = to_edge_list(g);
    const Graph back = from_edge_list(edges);
    CHECK(back.edges().size() == 5 && back.index().size() == 6 && back.has_edge("e", "f"));
    CHECK(to_dot(g).find("\"a\" -> \"b\";") != std::string::npos);
    Graph quoted;
    quoted.add_edge("say \"hi\"", "b");
    CHECK(to_dot(quoted).find("\"say \\\"hi\\\"\" -> \"b\";") != std::string::npos);
    const std::string mm = to_matrix_market(g);
    CHECK(mm.rfind("%%MatrixMarket matrix coordinate pattern general\n6 6 5\n", 0) == 0);
    CHECK(mm.find("\n1 2\n") != std::string::npos);
}

// formerly a 500-line file of pasted add_edge calls
static void test_long_chain() {
    Graph g;
    const int n = 500;
    for (int i = 0; i < n; ++i) g.add_edge("n" + std::to_string(i), "n" + std::to_string(i + 1));
    CHECK(statistics(g).vertices == 501 && statistics(g).edges == 500);
    CHECK(has_path(g, 0, 500));
    CHECK(shortest_path(g, 0, 500).vertices.size() == 501);
    CHECK(transitive_closure_reference(g).size() == 500u * 501u / 2u);
    CHECK(closure_by_fixed_point(g).size() == 500u * 501u / 2u);
}

int main() {
    test_graph_core();
    test_closure_algorithms_agree();
    test_reachability_backend_selection();
    test_predicates_and_bridge();
    test_evaluate_with_graph();
    test_operations();
    test_export();
    test_long_chain();
    return finish("graph");
}
