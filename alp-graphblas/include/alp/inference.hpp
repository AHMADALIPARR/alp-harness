#pragma once
#include "fact_store.hpp"
#include "knowledge_base.hpp"
#include <cstddef>
#include <vector>

namespace alp {

// Bottom-up evaluation of the Horn program P under stratified negation as
// failure. Evaluation proceeds stratum by stratum to a fixed point, so a
// negated literal is only consulted once its predicate is completely
// computed. `seed` atoms (abduced hypotheses, externally materialized graph
// predicates) are treated as additional base facts.
struct EvaluationStats {
    std::size_t rounds = 0;  // rule-application sweeps over all strata
    bool converged = true;   // false if max_rounds stopped the evaluation early
};

class InferenceEngine {
    const KnowledgeBase& kb_;

public:
    explicit InferenceEngine(const KnowledgeBase& kb) : kb_(kb) {}

    // Throws std::invalid_argument if the program is not stratified or a seed atom is not ground.
    // `max_rounds` (0 = unlimited) bounds the total number of sweeps; a result
    // cut short that way is a subset of the fixed point (see EvaluationStats).
    FactStore evaluate(const std::vector<Atom>& seed = {}, std::size_t max_rounds = 0,
                       EvaluationStats* stats = nullptr) const;

    std::vector<Atom> fixed_point(const std::vector<Atom>& seed = {}) const;

    // Instances of `goal` that hold in the given store.
    static std::vector<Atom> solutions(const Atom& goal, const FactStore&);
    bool query(const Atom& goal, const std::vector<Atom>& seed = {}) const;
};

}  // namespace alp
