#pragma once
#include "knowledge_base.hpp"
#include <cstddef>
#include <vector>

namespace alp {

// Rules grouped by stratum, lowest first. A rule belongs to the stratum of its
// head predicate; a predicate sits strictly above every predicate it uses
// under negation and at or above every predicate it uses positively.
struct Stratification {
    std::vector<std::vector<std::size_t>> rule_strata;  // indices into kb.rules()
};

// Throws std::invalid_argument if negation occurs inside a recursive cycle.
Stratification stratify(const KnowledgeBase&);

}  // namespace alp
