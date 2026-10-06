#pragma once
#include "graph.hpp"
#include <cstddef>
#include <span>
#include <vector>

namespace alp::graph {

// Boolean adjacency matrix of a graph in CSR form (sorted, duplicate-free rows).
class AdjacencyMatrix {
    std::size_t n_ = 0;
    std::vector<std::size_t> row_ptr_{0};
    std::vector<std::size_t> col_idx_;

public:
    AdjacencyMatrix() = default;
    explicit AdjacencyMatrix(const Graph& g) { rebuild(g); }

    void rebuild(const Graph&);
    std::size_t size() const { return n_; }
    std::size_t nnz() const { return col_idx_.size(); }
    std::span<const std::size_t> neighbors(std::size_t row) const;
    bool has(std::size_t row, std::size_t col) const;
};

}  // namespace alp::graph
