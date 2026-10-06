#include "alp/integrity.hpp"
#include "alp/inference.hpp"
#include "alp/matching.hpp"

namespace alp {

std::vector<Violation> violations(const KnowledgeBase& kb, const FactStore& closure) {
    std::vector<Violation> out;
    for (const auto& c : kb.constraints())
        for (auto& m : match_body(c.body, closure)) out.push_back({c, std::move(m.positive)});
    return out;
}

std::vector<Violation> violations(const KnowledgeBase& kb, const Model& m) {
    // base atoms of the model: its hypotheses plus any facts beyond the program's own
    std::vector<Atom> seed = m.abduced;
    seed.insert(seed.end(), m.facts.begin(), m.facts.end());
    return violations(kb, InferenceEngine(kb).evaluate(seed));
}

bool satisfies_constraints(const KnowledgeBase& kb, const Model& m) {
    return violations(kb, m).empty();
}

}  // namespace alp
