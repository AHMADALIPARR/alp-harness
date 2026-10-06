#include "alp/graph/adjacency.hpp"
#include <algorithm>

namespace alp::graph {

void AdjacencyMatrix::rebuild(const Graph& g) {
    n_ = g.index().size();
    std::vector<std::vector<std::size_t>> rows(n_);
    for (const auto& e : g.edges()) rows[e.source].push_back(e.target);

    row_ptr_.assign(1, 0);
    col_idx_.clear();
    for (auto& r : rows) {
        std::sort(r.begin(), r.end());
        r.erase(std::unique(r.begin(), r.end()), r.end());
        col_idx_.insert(col_idx_.end(), r.begin(), r.end());
        row_ptr_.push_back(col_idx_.size());
    }
}

std::span<const std::size_t> AdjacencyMatrix::neighbors(std::size_t row) const {
    return {col_idx_.data() + row_ptr_.at(row), col_idx_.data() + row_ptr_.at(row + 1)};
}

bool AdjacencyMatrix::has(std::size_t row, std::size_t col) const {
    auto n = neighbors(row);
    return std::binary_search(n.begin(), n.end(), col);
}

}  // namespace alp::graph
