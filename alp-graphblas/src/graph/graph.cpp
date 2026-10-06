#include "alp/graph/graph.hpp"
#include <algorithm>

namespace alp::graph {

void Graph::add_node(const std::string& n) { index_.intern(n); }

void Graph::add_edge(const std::string& from, const std::string& to) {
    const Edge e{index_.intern(from), index_.intern(to)};
    const auto same = [&](const Edge& x) { return x.source == e.source && x.target == e.target; };
    if (std::none_of(edges_.begin(), edges_.end(), same)) edges_.push_back(e);
}

bool Graph::has_edge(const std::string& from, const std::string& to) const {
    if (!index_.contains(from) || !index_.contains(to)) return false;
    const std::size_t s = index_.id(from), t = index_.id(to);
    return std::any_of(edges_.begin(), edges_.end(),
                       [&](const Edge& x) { return x.source == s && x.target == t; });
}

}  // namespace alp::graph
