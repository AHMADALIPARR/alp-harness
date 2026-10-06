#pragma once
#include "fixed_point.hpp"
#include "graph.hpp"
#include "../atom.hpp"
#include <set>
#include <vector>

namespace alp::graph {

// The predicates executed by the graph backend:
//   node/1       every node
//   edge/2       direct edges
//   connected/2  connected by an edge in either direction (symmetric closure of edge/2)
//   reachable/2  transitive closure of edge/2 (path of length >= 1)
//   path/2       same relation as reachable/2
class GraphPredicateRegistry {
    std::set<alp::Predicate> predicates_;

public:
    GraphPredicateRegistry();
    bool supports(const alp::Predicate&) const;
    std::set<alp::Predicate> predicates() const { return predicates_; }
};

// Builds a graph from the node/1 and edge/2 atoms in `atoms` (other atoms are ignored).
Graph extract_graph(const std::vector<alp::Atom>& atoms);

// Turns index pairs into ground atoms `predicate(name_i, name_j)`.
std::vector<alp::Atom> materialize(const Graph&, const Pairs&, const alp::Predicate&);
std::vector<alp::Atom> materialize_reachable(const Graph&, const Pairs&);

}  // namespace alp::graph
