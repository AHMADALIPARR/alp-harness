#include "alp/inference.hpp"
#include "alp/matching.hpp"
#include "alp/stratification.hpp"
#include "alp/unification.hpp"
#include <set>
#include <stdexcept>

namespace alp {

FactStore InferenceEngine::evaluate(const std::vector<Atom>& seed, std::size_t max_rounds,
                                    EvaluationStats* stats) const {
    const Stratification strata = stratify(kb_);

    FactStore store;
    for (const auto& f : kb_.facts()) store.add(f, "fact");
    for (const auto& a : seed) {
        if (!is_ground(a)) throw std::invalid_argument("seed atom must be ground: " + to_string(a));
        store.add(a, "assumption");
    }

    EvaluationStats local;
    for (const auto& stratum : strata.rule_strata) {
        // predicates defined in this stratum: only their new atoms can enable further derivations
        std::set<Predicate> recursive;
        for (std::size_t ri : stratum) recursive.insert(kb_.rules()[ri].head.predicate);

        FactStore delta;  // atoms this stratum produced in the previous round
        for (bool first = true, changed = true; changed; first = false) {
            if (max_rounds && local.rounds >= max_rounds) {
                local.converged = false;
                if (stats) *stats = local;
                return store;
            }
            ++local.rounds;
            changed = false;
            FactStore next_delta;

            auto apply = [&](const HornClause& rule, std::vector<Match> matches) {
                for (auto& m : matches) {
                    Atom head = apply_substitution(rule.head, m.theta);
                    if (store.add(head, "rule: " + to_string(rule), std::move(m.positive), std::move(m.negative))) {
                        next_delta.add(head);
                        changed = true;
                    }
                }
            };

            for (std::size_t ri : stratum) {
                const HornClause& rule = kb_.rules()[ri];
                if (first) {
                    apply(rule, match_body(rule.body, store));  // naive: everything is new
                    continue;
                }
                // semi-naive: one literal over a recursive predicate must match a new atom
                for (std::size_t li = 0; li < rule.body.size(); ++li) {
                    const Literal& lit = rule.body[li];
                    if (lit.negated || !recursive.contains(lit.atom.predicate)) continue;
                    const Pivot pivot{li, &delta};
                    apply(rule, match_body(rule.body, store, &pivot));
                }
            }
            delta = std::move(next_delta);
        }
    }
    if (stats) *stats = local;
    return store;
}

std::vector<Atom> InferenceEngine::fixed_point(const std::vector<Atom>& seed) const {
    return evaluate(seed).all();
}

std::vector<Atom> InferenceEngine::solutions(const Atom& goal, const FactStore& store) {
    std::vector<Atom> out;
    for (const auto& f : store.with_predicate(goal.predicate)) {
        Substitution s;
        if (Unifier::unify(goal, f, s)) out.push_back(f);
    }
    return out;
}

bool InferenceEngine::query(const Atom& goal, const std::vector<Atom>& seed) const {
    return !solutions(goal, evaluate(seed)).empty();
}

}  // namespace alp
