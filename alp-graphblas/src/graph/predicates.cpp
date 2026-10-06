#include "alp/graph/predicates.hpp"

namespace alp::graph {

GraphPredicateRegistry::GraphPredicateRegistry() {
    predicates_ = {{"node", 1}, {"edge", 2}, {"connected", 2}, {"reachable", 2}, {"path", 2}};
}

bool GraphPredicateRegistry::supports(const alp::Predicate& p) const { return predicates_.contains(p); }

Graph extract_graph(const std::vector<alp::Atom>& atoms) {
    Graph g;
    for (const auto& a : atoms) {
        if (a.predicate == alp::Predicate{"node", 1} && is_ground(a)) {
            g.add_node(alp::to_string(a.arguments[0]));
        } else if (a.predicate == alp::Predicate{"edge", 2} && is_ground(a)) {
            g.add_edge(alp::to_string(a.arguments[0]), alp::to_string(a.arguments[1]));
        }
    }
    return g;
}

std::vector<alp::Atom> materialize(const Graph& g, const Pairs& pairs, const alp::Predicate& p) {
    std::vector<alp::Atom> out;
    out.reserve(pairs.size());
    for (auto [i, j] : pairs)
        out.push_back({p, {alp::Term::constant(g.index().name(i)), alp::Term::constant(g.index().name(j))}});
    return out;
}

std::vector<alp::Atom> materialize_reachable(const Graph& g, const Pairs& r) {
    return materialize(g, r, {"reachable", 2});
}

}  // namespace alp::graph
