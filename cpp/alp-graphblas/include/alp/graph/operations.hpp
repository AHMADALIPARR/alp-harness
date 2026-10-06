#pragma once
#include "alp/atom.hpp"
#include "alp/graph/graph.hpp"
#include <cstddef>
#include <optional>
#include <set>
#include <string>
#include <utility>
#include <vector>

namespace alp::graph {

struct GraphStatistics {
    std::size_t vertices{0};
    std::size_t edges{0};
    std::size_t self_loops{0};
    std::size_t duplicate_edges{0};
    std::size_t isolated_vertices{0};
    std::size_t maximum_out_degree{0};
    std::size_t maximum_in_degree{0};
};

struct ReachabilityPair { std::size_t source{}; std::size_t target{}; bool operator==(const ReachabilityPair&) const = default; };
struct PathResult { bool found{false}; std::vector<std::size_t> vertices; };

GraphStatistics statistics(const Graph& graph);
std::vector<std::size_t> out_neighbors(const Graph& graph, std::size_t vertex);
std::vector<std::size_t> in_neighbors(const Graph& graph, std::size_t vertex);
std::size_t out_degree(const Graph& graph, std::size_t vertex);
std::size_t in_degree(const Graph& graph, std::size_t vertex);
std::vector<std::size_t> sources(const Graph& graph);
std::vector<std::size_t> sinks(const Graph& graph);
std::vector<std::size_t> isolated(const Graph& graph);

bool has_edge(const Graph& graph, std::size_t source, std::size_t target);
// True if `target` can be reached from `source`. The trivial path is included, so
// has_path(g, v, v) is true; contrast with transitive_closure_reference, where (v, v)
// appears only if v lies on a cycle.
bool has_path(const Graph& graph, std::size_t source, std::size_t target);
PathResult shortest_path(const Graph& graph, std::size_t source, std::size_t target);

// Both directions of every edge.
std::vector<std::pair<std::size_t,std::size_t>> symmetric_closure(const Graph& graph);
// Edges plus (v, v) for every vertex.
std::vector<std::pair<std::size_t,std::size_t>> reflexive_closure(const Graph& graph);
// Independent BFS-based transitive closure (paths of length >= 1), used to cross-check
// the fixed-point and ALP/GraphBLAS backends.
std::vector<std::pair<std::size_t,std::size_t>> transitive_closure_reference(const Graph& graph);

std::vector<Atom> materialize_edges(const Graph& graph);
std::vector<Atom> materialize_nodes(const Graph& graph);
// connected/2 is the symmetric closure of edge/2.
std::vector<Atom> materialize_connected(const Graph& graph);
std::vector<Atom> materialize_reachable_reference(const Graph& graph);

} // namespace alp::graph
