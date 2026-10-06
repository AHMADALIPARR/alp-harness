#include "alp/graph/bridge.hpp"
#include "alp/graph/operations.hpp"
#include "alp/unification.hpp"

namespace alp::graph {

namespace {
alp::Atom pattern(const alp::Predicate& p) {
    alp::Atom a{p, {}};
    for (std::size_t i = 0; i < p.arity; ++i) a.arguments.push_back(alp::Term::variable("V" + std::to_string(i)));
    return a;
}
}  // namespace

std::vector<alp::Atom> GraphPredicateBridge::execute(const alp::Atom& q, const Graph& g) const {
    const alp::Predicate& p = q.predicate;
    if (!supports(p)) return {};

    if (p.name == "node") {
        std::vector<alp::Atom> out;
        for (std::size_t i = 0; i < g.index().size(); ++i) out.push_back({p, {alp::Term::constant(g.index().name(i))}});
        return out;
    }
    if (p.name == "edge") {
        Pairs pairs;
        for (const auto& e : g.edges()) pairs.push_back({e.source, e.target});
        return materialize(g, pairs, p);
    }
    if (p.name == "connected") return materialize(g, symmetric_closure(g), p);
    // reachable, path
    return materialize(g, reachability_.compute(g), p);
}

bool GraphPredicateBridge::query(const alp::Atom& q, const Graph& g) const {
    for (const auto& a : execute(q, g)) {
        alp::Substitution s;
        if (alp::Unifier::unify(q, a, s)) return true;
    }
    return false;
}

std::vector<alp::Atom> GraphPredicateBridge::saturate(const std::vector<alp::Atom>& atoms) const {
    const Graph g = extract_graph(atoms);
    std::set<std::string> known;
    for (const auto& a : atoms) known.insert(alp::to_string(a));

    std::vector<alp::Atom> out;
    for (const auto& p : registry_.predicates())
        for (auto& a : execute(pattern(p), g))
            if (known.insert(alp::to_string(a)).second) out.push_back(std::move(a));
    return out;
}

FactStore evaluate_with_graph(const KnowledgeBase& kb, const GraphPredicateBridge& bridge,
                              const std::vector<alp::Atom>& seed) {
    InferenceEngine engine(kb);
    std::vector<alp::Atom> seeds = seed;
    for (;;) {
        FactStore store = engine.evaluate(seeds);
        const auto added = bridge.saturate(store.all());
        if (added.empty()) return store;
        seeds.insert(seeds.end(), added.begin(), added.end());
    }
}

}  // namespace alp::graph
