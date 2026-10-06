#pragma once
#include "predicates.hpp"
#include "reachability.hpp"
#include "../atom.hpp"
#include "../inference.hpp"
#include <vector>

namespace alp::graph {

// The explicit boundary between graph execution and logic. It never rewrites
// the Horn program: it executes the supported graph predicates on a Graph and
// returns the results as ordinary ground atoms for unification and evaluation.
class GraphPredicateBridge {
    GraphPredicateRegistry registry_;
    Reachability reachability_;

public:
    explicit GraphPredicateBridge(Backend b = Backend::Auto) : reachability_(b) {}

    bool supports(const alp::Predicate& p) const { return registry_.supports(p); }

    // The full relation of q's predicate over `g` (empty if the predicate is unsupported).
    std::vector<alp::Atom> execute(const alp::Atom& q, const Graph& g) const;
    // True if some tuple of the relation unifies with q.
    bool query(const alp::Atom& q, const Graph& g) const;

    // Graph predicates computed from the node/edge atoms in `atoms` that are not yet in `atoms`.
    std::vector<alp::Atom> saturate(const std::vector<alp::Atom>& atoms) const;

    const Reachability& reachability() const { return reachability_; }
};

// Evaluates the program with graph predicates executed by the bridge. Edges
// may themselves be derived by rules: the evaluation is repeated with the
// bridge's results as seed atoms until nothing new is produced.
// Graph predicates are monotone; avoid defining node/edge through negation.
FactStore evaluate_with_graph(const KnowledgeBase&, const GraphPredicateBridge&,
                              const std::vector<alp::Atom>& seed = {});

}  // namespace alp::graph
