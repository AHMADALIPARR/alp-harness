#include "alp/logic/runtime.hpp"
#include "alp/inference.hpp"
#include "alp/integrity.hpp"

namespace alp::logic {

FixedPointEngine::FixedPointEngine(const KnowledgeBase& kb, DerivationOptions options)
    : kb_(kb), options_(options) {}

DerivationResult FixedPointEngine::run(const std::vector<Atom>& seed) const {
    DerivationResult result;
    analysis::DependencyGraph graph;
    graph.build(kb_);
    result.stratified = graph.stratified;
    if (!result.stratified && options_.reject_unstratified_program) return result;

    // Optionally evaluate without the rules that use negation as failure.
    const KnowledgeBase* program = &kb_;
    KnowledgeBase positive_only;
    if (!options_.apply_negative_literals) {
        for (const auto& f : kb_.facts()) positive_only.assert_fact(f);
        for (const auto& r : kb_.rules()) {
            bool negated = false;
            for (const auto& l : r.body) negated = negated || l.negated;
            if (!negated) positive_only.add_rule(r);
        }
        program = &positive_only;
    }

    EvaluationStats stats;
    const FactStore store = InferenceEngine(*program).evaluate(
        options_.include_seed ? seed : std::vector<Atom>{}, options_.maximum_iterations, &stats);
    result.closure = store.all();
    if (options_.record_proofs) result.proofs = store.derivation_steps();
    result.iterations = stats.rounds;
    result.fixed_point = stats.converged;
    return result;
}

namespace {
Model build(const KnowledgeBase& kb, const std::vector<Atom>& extra, bool as_hypotheses) {
    Model model;
    model.facts = kb.facts();
    model.constraints = kb.constraints();
    for (const auto& a : extra) (as_hypotheses ? model.abduced : model.facts).push_back(a);

    const FactStore store = InferenceEngine(kb).evaluate(extra);
    for (const auto& a : store.all()) {
        const auto* d = store.derivation(a);
        if (d && d->source.rfind("rule:", 0) == 0) model.derived.push_back(a);
    }
    model.proofs = store.derivation_steps();
    model.violations = violations(kb, store);
    model.valid = model.violations.empty();
    return model;
}
}  // namespace

// `facts` are additional base facts: they extend the program's facts.
Model ModelBuilder::from_facts(const std::vector<Atom>& facts) const { return build(kb_, facts, false); }

// `abduced` are hypotheses: recorded separately from the program's facts.
Model ModelBuilder::from_hypothesis(const std::vector<Atom>& abduced) const { return build(kb_, abduced, true); }

Model ModelBuilder::validate(Model model) const {
    model.violations = violations(kb_, model);
    model.valid = model.violations.empty();
    return model;
}

}  // namespace alp::logic
