#include "alp/matching.hpp"
#include "alp/unification.hpp"
#include <stdexcept>

namespace alp {

std::vector<Match> match_body(const std::vector<Literal>& body, const FactStore& store, const Pivot* pivot) {
    std::vector<Match> states(1);

    for (std::size_t li = 0; li < body.size(); ++li) {
        const Literal& lit = body[li];
        if (lit.negated) continue;
        const FactStore& source = (pivot && pivot->literal == li) ? *pivot->delta : store;
        std::vector<Match> next;
        for (const auto& st : states) {
            const Atom q = apply_substitution(lit.atom, st.theta);
            // a ground first argument selects its bucket directly instead of scanning the predicate
            const bool indexed = !q.arguments.empty() && is_ground(q.arguments[0]);
            const auto& candidates = indexed ? source.with_first_argument(q.predicate, q.arguments[0])
                                             : source.with_predicate(q.predicate);
            for (const auto& fact : candidates) {
                Substitution u = st.theta;
                if (!Unifier::unify(q, fact, u)) continue;
                Match m{std::move(u), st.positive, st.negative};
                m.positive.push_back(fact);
                next.push_back(std::move(m));
            }
        }
        states.swap(next);
        if (states.empty()) return states;
    }

    for (const auto& lit : body) {
        if (!lit.negated) continue;
        std::vector<Match> next;
        for (auto& st : states) {
            const Atom q = apply_substitution(lit.atom, st.theta);
            if (!is_ground(q))
                throw std::logic_error("non-ground negated literal: " + to_string(q));
            if (store.contains(q)) continue;
            st.negative.push_back(q);
            next.push_back(std::move(st));
        }
        states.swap(next);
        if (states.empty()) return states;
    }
    return states;
}

}  // namespace alp
