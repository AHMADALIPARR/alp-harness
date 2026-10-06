#include "alp/abduction.hpp"
#include "alp/unification.hpp"
#include <algorithm>
#include <cstdint>
#include <stdexcept>

namespace alp {

namespace {

// All ground atoms p(c1..ck) for an abducible p/k over the given constants.
void ground_candidates(const Predicate& p, const std::vector<std::string>& universe,
                       std::size_t limit, std::vector<Atom>& out) {
    std::vector<std::size_t> idx(p.arity, 0);
    if (p.arity > 0 && universe.empty()) return;
    for (;;) {
        if (out.size() >= limit + 1)
            throw std::runtime_error("abducible search space exceeds deterministic enumeration bound");
        Atom a{p, {}};
        for (std::size_t i : idx) a.arguments.push_back(Term::constant(universe[i]));
        out.push_back(std::move(a));
        std::size_t pos = 0;
        while (pos < idx.size() && ++idx[pos] == universe.size()) idx[pos++] = 0;
        if (pos == idx.size()) break;
    }
}

// Next integer with the same number of set bits (Gosper's hack).
std::uint64_t next_combination(std::uint64_t v) {
    const std::uint64_t t = v | (v - 1);
    return (t + 1) | (((~t & -~t) - 1) >> (__builtin_ctzll(v) + 1));
}

}  // namespace

std::vector<Model> AbductiveSolver::solve(const Atom& goal, const AbductionOptions& opts) const {
    const auto consts = kb_.constants();
    const std::vector<std::string> universe(consts.begin(), consts.end());

    std::vector<Atom> candidates;
    for (const auto& p : kb_.abducibles()) ground_candidates(p, universe, opts.max_candidates, candidates);
    const std::size_t n = candidates.size();
    if (n > opts.max_candidates)
        throw std::runtime_error("abducible search space exceeds deterministic enumeration bound");

    const InferenceEngine engine(kb_);
    std::vector<Model> out;
    std::vector<std::uint64_t> found;  // masks of accepted explanations

    auto consider = [&](std::uint64_t mask) {
        if (opts.minimal_only)
            for (std::uint64_t f : found)
                if ((f & mask) == f) return;  // a subset already explains the goal

        Model m;
        m.facts = kb_.facts();
        m.constraints = kb_.constraints();
        for (std::size_t i = 0; i < n; ++i)
            if (mask & (std::uint64_t(1) << i)) m.abduced.push_back(candidates[i]);

        const FactStore store = engine.evaluate(m.abduced);
        m.answers = InferenceEngine::solutions(goal, store);
        if (m.answers.empty()) return;
        m.violations = violations(kb_, store);
        m.valid = m.violations.empty();
        if (!m.valid) return;

        for (const auto& a : store.all()) {
            const auto* d = store.derivation(a);
            if (d && d->source.rfind("rule:", 0) == 0) m.derived.push_back(a);
        }
        m.proofs = store.derivation_steps();
        found.push_back(mask);
        out.push_back(std::move(m));
    };

    for (std::size_t k = 0; k <= n; ++k) {
        std::uint64_t mask = k == 0 ? 0 : (std::uint64_t(1) << k) - 1;
        const std::uint64_t limit = std::uint64_t(1) << n;
        for (;;) {
            consider(mask);
            if (k == 0) break;
            mask = next_combination(mask);
            if (mask >= limit) break;
        }
    }
    return out;
}

std::vector<Model> AbductiveSolver::minimal_explanations(const Atom& goal) const {
    AbductionOptions o;
    o.minimal_only = true;
    return solve(goal, o);
}

}  // namespace alp
