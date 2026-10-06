// ALP/GraphBLAS backend tests (built only with -DALP_GRAPHBLAS_ENABLE=ON): every result is
// compared with the independent BFS closure.
#include "alp/graph/graphblas_backend.hpp"
#include "alp/graph/operations.hpp"
#include "alp/graph/reachability.hpp"
#include "check.hpp"
#include <algorithm>

using namespace alp;
using namespace alp::graph;
using namespace alp_test;

static void expect_matches_oracle(const Graph& g, const char* what) {
    const auto expected = transitive_closure_reference(g);
    const auto actual = GraphBLASBackend().transitive_closure(g);
    if (actual != expected) std::cerr << "mismatch on " << what << "\n";
    CHECK(actual == expected);
}

static void test_fixed_cases() {
    Graph empty;
    expect_matches_oracle(empty, "empty graph");

    Graph nodes_only;
    nodes_only.add_node("a");
    nodes_only.add_node("b");
    expect_matches_oracle(nodes_only, "nodes without edges");

    Graph one;
    one.add_edge("a", "b");
    expect_matches_oracle(one, "single edge");

    Graph loop;
    loop.add_edge("a", "a");
    expect_matches_oracle(loop, "self loop");

    Graph cycle;
    cycle.add_edge("a", "b");
    cycle.add_edge("b", "c");
    cycle.add_edge("c", "a");
    cycle.add_edge("c", "d");
    expect_matches_oracle(cycle, "cycle with tail");
    CHECK(GraphBLASBackend().transitive_closure(cycle).size() == 9 + 3);

    Graph sample;
    sample.add_edge("a", "b");
    sample.add_edge("b", "c");
    sample.add_edge("c", "d");
    sample.add_edge("a", "e");
    sample.add_edge("e", "f");
    expect_matches_oracle(sample, "sample graph");
    const auto r = GraphBLASBackend().transitive_closure(sample);
    CHECK(r.size() == 9);
    CHECK(std::is_sorted(r.begin(), r.end()));
}

static void test_random_graphs() {
    for (std::uint64_t seed = 1; seed <= 100; ++seed) {
        Rng rng(seed);
        Graph g;
        const std::size_t n = 1 + rng.below(30), m = rng.below(3 * n + 1);
        for (std::size_t i = 0; i < n; ++i) g.add_node("v" + std::to_string(i));
        for (std::size_t k = 0; k < m; ++k)
            g.add_edge("v" + std::to_string(rng.below(n)), "v" + std::to_string(rng.below(n)));
        expect_matches_oracle(g, ("random graph, seed " + std::to_string(seed)).c_str());
    }
}

static void test_chain_and_repeated_use() {
    Graph chain;
    const int n = 200;
    for (int i = 0; i < n; ++i) chain.add_edge("n" + std::to_string(i), "n" + std::to_string(i + 1));
    expect_matches_oracle(chain, "chain of 200");
    CHECK(GraphBLASBackend().transitive_closure(chain).size() == 200u * 201u / 2u);
    expect_matches_oracle(chain, "second call (ALP runtime is re-entered cleanly)");
}

static void test_facade() {
    CHECK(Reachability::graphblas_available());
    CHECK(Reachability().backend_name() == "alp-graphblas");
    Graph g;
    g.add_edge("a", "b");
    g.add_edge("b", "c");
    CHECK(Reachability(Backend::GraphBLAS).compute(g) == Reachability(Backend::Reference).compute(g));
}

int main() {
    test_fixed_cases();
    test_random_graphs();
    test_chain_and_repeated_use();
    test_facade();
    return finish("graphblas");
}
