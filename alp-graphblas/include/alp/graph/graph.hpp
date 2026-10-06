#pragma once
#include "graph_index.hpp"
#include <cstddef>
#include <string>
#include <vector>

namespace alp::graph {

struct Edge {
    std::size_t source{}, target{};
};

// Directed graph over named nodes. Parallel edges are collapsed.
class Graph {
    GraphIndex index_;
    std::vector<Edge> edges_;

public:
    void add_node(const std::string&);
    void add_edge(const std::string& from, const std::string& to);
    bool has_edge(const std::string& from, const std::string& to) const;

    const GraphIndex& index() const { return index_; }
    const std::vector<Edge>& edges() const { return edges_; }
};

}  // namespace alp::graph
