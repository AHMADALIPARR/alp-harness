#pragma once
#include "clause.hpp"
#include "fact_store.hpp"
#include "substitution.hpp"
#include <vector>

namespace alp {

struct Match {
    Substitution theta;
    std::vector<Atom> positive;  // instances of the positive body literals that matched
    std::vector<Atom> negative;  // instances of the negated literals that were not derivable
};

// Restricts one positive literal of the body (by its index in the body vector) to the atoms of
// `delta`; used for semi-naive evaluation, where at least one literal must match a new atom.
struct Pivot {
    std::size_t literal;
    const FactStore* delta;
};

// All ways of satisfying `body` in `store`. Positive literals are joined first
// (in written order), negated literals are then checked as failure to find the
// ground instance in the store, so the written order of the body is irrelevant.
// Throws std::logic_error if a negated literal is non-ground after the join.
std::vector<Match> match_body(const std::vector<Literal>& body, const FactStore& store,
                              const Pivot* pivot = nullptr);

}  // namespace alp
