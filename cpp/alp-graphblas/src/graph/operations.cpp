#include "alp/graph/operations.hpp"
#include "alp/graph/adjacency.hpp"
#include "alp/graph/predicates.hpp"
#include <algorithm>
#include <deque>
#include <limits>
#include <set>

namespace alp::graph {

namespace {

using Pair = std::pair<std::size_t, std::size_t>;

std::vector<Pair> to_vector(const std::set<Pair>& s) { return {s.begin(), s.end()}; }

std::vector<std::size_t> in_degrees(const Graph& g) {
    std::vector<std::size_t> deg(g.index().size());
    const AdjacencyMatrix A(g);
    for (std::size_t i = 0; i < A.size(); ++i)
        for (std::size_t j : A.neighbors(i)) ++deg[j];
    return deg;
}

std::vector<Atom> pairs_to_atoms(const Graph& g, const std::vector<Pair>& pairs, const char* name) {
    return materialize(g, pairs, Predicate{name, 2});
}

}  // namespace

GraphStatistics statistics(const Graph& graph) {
    GraphStatistics s;
    s.vertices = graph.index().size();
    s.edges = graph.edges().size();
    std::vector<std::size_t> in(s.vertices), out(s.vertices);
    std::set<Pair> unique;
    for (const auto& edge : graph.edges()) {
        if (edge.source == edge.target) ++s.self_loops;
        if (!unique.insert({edge.source, edge.target}).second) ++s.duplicate_edges;
        ++out[edge.source];
        ++in[edge.target];
    }
    for (std::size_t i = 0; i < s.vertices; ++i) {
        s.maximum_out_degree = std::max(s.maximum_out_degree, out[i]);
        s.maximum_in_degree = std::max(s.maximum_in_degree, in[i]);
        if (!in[i] && !out[i]) ++s.isolated_vertices;
    }
    return s;
}

std::vector<std::size_t> out_neighbors(const Graph& graph, std::size_t vertex) {
    const AdjacencyMatrix A(graph);
    if (vertex >= A.size()) return {};
    const auto n = A.neighbors(vertex);
    return {n.begin(), n.end()};
}

std::vector<std::size_t> in_neighbors(const Graph& graph, std::size_t vertex) {
    std::vector<std::size_t> out;
    for (const auto& edge : graph.edges())
        if (edge.target == vertex) out.push_back(edge.source);
    std::sort(out.begin(), out.end());
    out.erase(std::unique(out.begin(), out.end()), out.end());
    return out;
}

std::size_t out_degree(const Graph& graph, std::size_t v) { return out_neighbors(graph, v).size(); }
std::size_t in_degree(const Graph& graph, std::size_t v) { return in_neighbors(graph, v).size(); }

std::vector<std::size_t> sources(const Graph& graph) {
    const auto in = in_degrees(graph);
    std::vector<std::size_t> out;
    for (std::size_t i = 0; i < in.size(); ++i)
        if (!in[i]) out.push_back(i);
    return out;
}

std::vector<std::size_t> sinks(const Graph& graph) {
    const AdjacencyMatrix A(graph);
    std::vector<std::size_t> out;
    for (std::size_t i = 0; i < A.size(); ++i)
        if (A.neighbors(i).empty()) out.push_back(i);
    return out;
}

std::vector<std::size_t> isolated(const Graph& graph) {
    const auto in = in_degrees(graph);
    const AdjacencyMatrix A(graph);
    std::vector<std::size_t> out;
    for (std::size_t i = 0; i < in.size(); ++i)
        if (!in[i] && A.neighbors(i).empty()) out.push_back(i);
    return out;
}

bool has_edge(const Graph& graph, std::size_t s, std::size_t t) {
    return std::any_of(graph.edges().begin(), graph.edges().end(),
                       [&](const Edge& e) { return e.source == s && e.target == t; });
}

bool has_path(const Graph& graph, std::size_t source, std::size_t target) {
    return shortest_path(graph, source, target).found;
}

PathResult shortest_path(const Graph& graph, std::size_t source, std::size_t target) {
    PathResult result;
    const std::size_t n = graph.index().size();
    if (source >= n || target >= n) return result;

    const AdjacencyMatrix A(graph);
    constexpr std::size_t none = std::numeric_limits<std::size_t>::max();
    std::vector<std::size_t> parent(n, none);
    std::vector<bool> seen(n, false);
    std::deque<std::size_t> queue{source};
    seen[source] = true;
    while (!queue.empty()) {
        const std::size_t v = queue.front();
        queue.pop_front();
        if (v == target) break;
        for (std::size_t w : A.neighbors(v))
            if (!seen[w]) {
                seen[w] = true;
                parent[w] = v;
                queue.push_back(w);
            }
    }
    if (!seen[target]) return result;

    result.found = true;
    for (std::size_t v = target;; v = parent[v]) {
        result.vertices.push_back(v);
        if (v == source) break;
    }
    std::reverse(result.vertices.begin(), result.vertices.end());
    return result;
}

std::vector<Pair> symmetric_closure(const Graph& graph) {
    std::set<Pair> s;
    for (const auto& e : graph.edges()) {
        s.insert({e.source, e.target});
        s.insert({e.target, e.source});
    }
    return to_vector(s);
}

std::vector<Pair> reflexive_closure(const Graph& graph) {
    std::set<Pair> s;
    for (const auto& e : graph.edges()) s.insert({e.source, e.target});
    for (std::size_t i = 0; i < graph.index().size(); ++i) s.insert({i, i});
    return to_vector(s);
}

std::vector<Pair> transitive_closure_reference(const Graph& graph) {
    const AdjacencyMatrix A(graph);
    std::set<Pair> reached;
    for (std::size_t source = 0; source < A.size(); ++source) {
        std::vector<bool> seen(A.size(), false);
        std::deque<std::size_t> queue;
        for (std::size_t next : A.neighbors(source))
            if (!seen[next]) {
                seen[next] = true;
                queue.push_back(next);
            }
        while (!queue.empty()) {
            const std::size_t v = queue.front();
            queue.pop_front();
            reached.insert({source, v});
            for (std::size_t w : A.neighbors(v))
                if (!seen[w]) {
                    seen[w] = true;
                    queue.push_back(w);
                }
        }
    }
    return to_vector(reached);
}

std::vector<Atom> materialize_edges(const Graph& graph) {
    std::vector<Pair> pairs;
    for (const auto& e : graph.edges()) pairs.push_back({e.source, e.target});
    return pairs_to_atoms(graph, pairs, "edge");
}

std::vector<Atom> materialize_nodes(const Graph& graph) {
    std::vector<Atom> out;
    for (std::size_t i = 0; i < graph.index().size(); ++i)
        out.push_back({{"node", 1}, {Term::constant(graph.index().name(i))}});
    return out;
}

std::vector<Atom> materialize_connected(const Graph& graph) {
    return pairs_to_atoms(graph, symmetric_closure(graph), "connected");
}

std::vector<Atom> materialize_reachable_reference(const Graph& graph) {
    return pairs_to_atoms(graph, transitive_closure_reference(graph), "reachable");
}

}  // namespace alp::graph
