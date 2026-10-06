#include "alp/graph/fixed_point.hpp"
#include "alp/graph/adjacency.hpp"
#include <algorithm>
#include <set>

namespace alp::graph {

Pairs closure_by_fixed_point(const Graph& g) {
    const AdjacencyMatrix A(g);
    std::set<std::pair<std::size_t, std::size_t>> reached;
    Pairs delta;
    for (std::size_t i = 0; i < A.size(); ++i)
        for (std::size_t j : A.neighbors(i)) {
            reached.insert({i, j});
            delta.push_back({i, j});
        }

    while (!delta.empty()) {
        Pairs next;
        for (auto [i, j] : delta)
            for (std::size_t k : A.neighbors(j))
                if (reached.insert({i, k}).second) next.push_back({i, k});
        delta.swap(next);
    }
    return {reached.begin(), reached.end()};
}

}  // namespace alp::graph
