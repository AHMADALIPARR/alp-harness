#pragma once
#include "alp/knowledge_base.hpp"
#include "alp/model.hpp"
#include "alp/analysis/dependency.hpp"
#include "alp/logic/sld.hpp"
#include <cstddef>
#include <map>
#include <string>
#include <vector>

namespace alp::logic {

struct DerivationOptions {
    std::size_t maximum_iterations{0};
    bool include_seed{true};         // false: ignore the seed atoms
    bool record_proofs{true};        // one-step proof for every derived atom
    bool apply_negative_literals{true};  // false: skip rules that contain `not`
    bool reject_unstratified_program{true};
};

struct DerivationResult {
    std::vector<Atom> closure;       // facts, seed and everything derived (empty if unstratified)
    std::vector<Proof> proofs;
    std::size_t iterations{0};       // sweeps performed, including the final one that changes nothing
    bool fixed_point{false};         // false if maximum_iterations stopped the run
    bool stratified{true};
};

// Forward chaining to a fixed point, evaluated stratum by stratum so negation as
// failure is sound (see InferenceEngine). Programs with negation inside a
// recursive cycle are rejected: with reject_unstratified_program the result has
// stratified == false and an empty closure; without it std::invalid_argument is thrown.
class FixedPointEngine {
    const KnowledgeBase& kb_;
    DerivationOptions options_;
public:
    explicit FixedPointEngine(const KnowledgeBase& kb, DerivationOptions options = {});
    DerivationResult run(const std::vector<Atom>& seed = {}) const;
};

class ModelBuilder {
    const KnowledgeBase& kb_;
public:
    explicit ModelBuilder(const KnowledgeBase& kb) : kb_(kb) {}
    Model from_facts(const std::vector<Atom>& facts) const;
    Model from_hypothesis(const std::vector<Atom>& abduced) const;
    Model validate(Model model) const;
};

} // namespace alp::logic
