#pragma once
#include "inference.hpp"
#include "integrity.hpp"
#include <cstddef>
#include <vector>

namespace alp {

struct AbductionOptions {
    // Keep only explanations whose abduced set is subset-minimal.
    bool minimal_only = false;
    // Upper bound on the number of candidate ground abducible atoms. The search
    // enumerates subsets of the candidates, so it is exponential in this number.
    std::size_t max_candidates = 20;
};

// Finds sets of hypotheses Delta over the abducible predicates such that
//   P + Delta entails the goal (some instance of it holds) and
//   P + Delta satisfies every integrity constraint IC.
//
// Abducible predicates of arity k > 0 are grounded over the constants that
// occur in the program. Results are ordered by |Delta|, then lexicographically.
class AbductiveSolver {
    const KnowledgeBase& kb_;

public:
    explicit AbductiveSolver(const KnowledgeBase& kb) : kb_(kb) {}

    std::vector<Model> solve(const Atom& goal, const AbductionOptions& = {}) const;
    std::vector<Model> minimal_explanations(const Atom& goal) const;
};

}  // namespace alp
