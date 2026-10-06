#include "alp/logic/sld.hpp"
#include "alp/stratification.hpp"
#include "alp/term_ops.hpp"
#include <algorithm>
#include <stdexcept>

namespace alp::logic {

// --- clause index ---------------------------------------------------------------------------

std::string ClauseIndex::signature(const Predicate& p) { return p.name + "/" + std::to_string(p.arity); }

ClauseIndex::ClauseIndex(const KnowledgeBase& kb) { rebuild(kb); }

void ClauseIndex::rebuild(const KnowledgeBase& kb) {
    by_signature_.clear();
    const auto& rules = kb.rules();
    for (std::size_t i = 0; i < rules.size(); ++i) add(i, rules[i]);
}

void ClauseIndex::add(RuleId id, const HornClause& clause) {
    by_signature_[signature(clause.head.predicate)].push_back(id);
}

const std::vector<ClauseIndex::RuleId>& ClauseIndex::candidates(const Predicate& p) const {
    static const std::vector<RuleId> empty;
    auto it = by_signature_.find(signature(p));
    return it == by_signature_.end() ? empty : it->second;
}

bool ClauseIndex::empty() const noexcept { return by_signature_.empty(); }
std::size_t ClauseIndex::bucket_count() const noexcept { return by_signature_.size(); }

// --- resolver ---------------------------------------------------------------------------------

namespace {

// Gives every variable of the clause a name that cannot clash with the caller's.
HornClause standardize_apart(const HornClause& clause, std::size_t serial) {
    auto rename = [serial](const Atom& a) {
        Atom out = a;
        for (auto& t : out.arguments) t = freshen_variables(t, serial);
        return out;
    };
    HornClause out = clause;
    out.head = rename(clause.head);
    for (auto& l : out.body) l.atom = rename(l.atom);
    return out;
}

constexpr std::size_t kMaxPasses = 100000;

std::string first_key(const Predicate& p, const Term& first) {
    return p.name + "/" + std::to_string(p.arity) + "|" + to_string(first);
}

}  // namespace

SLDResolver::SLDResolver(const KnowledgeBase& kb, ResolutionOptions options)
    : kb_(kb), options_(options), index_(kb) {}

// Calls that differ only in variable names share a table.
std::string SLDResolver::variant_key(const Atom& atom) {
    std::vector<Term> args;
    for (const auto& t : atom.arguments) args.push_back(t);
    return to_string(normalize_variables(Term::compound(atom.predicate.name, std::move(args)))) + "/" +
           std::to_string(atom.predicate.arity);
}

std::vector<Atom> SLDResolver::call(const Atom& target, std::size_t depth) {
    ++statistics_.calls;
    statistics_.maximum_depth = std::max(statistics_.maximum_depth, depth);

    const std::string key = variant_key(target);
    Table scratch;  // used instead of a shared table when tabling is off
    Table& table = options_.use_tabling ? tables_[key] : scratch;

    if (options_.use_tabling) {
        if (!visited_.insert(key).second) {  // already evaluated (or in progress) in this pass
            ++statistics_.table_hits;
            return table.answers;
        }
    }
    if (depth > options_.maximum_depth) {
        statistics_.truncated = true;
        return table.answers;
    }

    auto add_answer = [&](const Atom& answer, Support support) {
        const std::string k = to_string(answer);
        if (!table.keys.insert(k).second) return;
        table.answers.push_back(answer);
        supports_.try_emplace(k, std::move(support));
        grew_ = true;
        ++statistics_.table_inserts;
    };

    // facts (and seed atoms)
    const bool indexed = !target.arguments.empty() && is_ground(target.arguments[0]);
    const std::vector<Atom>* facts = nullptr;
    if (indexed) {
        if (auto it = base_by_first_.find(first_key(target.predicate, target.arguments[0])); it != base_by_first_.end())
            facts = &it->second;
    } else if (auto it = base_.find(target.predicate); it != base_.end()) {
        facts = &it->second;
    }
    if (facts) {
        for (const auto& fact : *facts) {
            ++statistics_.unification_attempts;
            Substitution s;
            if (!Unifier::unify(target, fact, s)) continue;
            ++statistics_.successful_unifications;
            add_answer(fact, {kb_fact_keys_.contains(to_string(fact)) ? "fact" : "assumption", {}, {}});
        }
    }

    // rules
    std::vector<std::size_t> all_ids;
    const std::vector<std::size_t>* ids = &all_ids;
    if (options_.use_clause_index) {
        ids = &index_.candidates(target.predicate);
    } else {
        for (std::size_t i = 0; i < kb_.rules().size(); ++i) all_ids.push_back(i);
    }
    for (const std::size_t id : *ids) {
        const HornClause& original = kb_.rules()[id];
        const HornClause renamed = standardize_apart(original, ++serial_);
        ++statistics_.rule_expansions;
        Substitution theta;
        ++statistics_.unification_attempts;
        if (!Unifier::unify(target, renamed.head, theta)) continue;
        ++statistics_.successful_unifications;

        // positive literals first, negated ones last: they are ground by then (range restriction)
        std::vector<const Literal*> body;
        for (const auto& l : renamed.body) if (!l.negated) body.push_back(&l);
        for (const auto& l : renamed.body) if (l.negated) body.push_back(&l);

        std::vector<Atom> premises, negations;
        join(body, 0, theta, premises, negations, renamed, original, depth, table);
    }
    return table.answers;
}

void SLDResolver::join(const std::vector<const Literal*>& body, std::size_t position, const Substitution& theta,
                       std::vector<Atom>& premises, std::vector<Atom>& negations, const HornClause& renamed,
                       const HornClause& original, std::size_t depth, Table& table) {
    if (position == body.size()) {
        const Atom head = apply_substitution(renamed.head, theta);
        if (!is_ground(head)) throw std::logic_error("non-ground rule instance: " + to_string(head));
        const std::string k = to_string(head);
        if (table.keys.insert(k).second) {
            table.answers.push_back(head);
            supports_.try_emplace(k, Support{"rule: " + to_string(original), premises, negations});
            grew_ = true;
            ++statistics_.table_inserts;
        }
        return;
    }

    const Literal& lit = *body[position];
    const Atom q = apply_substitution(lit.atom, theta);

    if (lit.negated) {
        if (!is_ground(q)) throw std::logic_error("non-ground negated literal: " + to_string(q));
        if (!options_.allow_negation_as_failure || negation_holds(q)) {
            ++statistics_.failed_goals;
            return;
        }
        negations.push_back(q);
        join(body, position + 1, theta, premises, negations, renamed, original, depth, table);
        negations.pop_back();
        return;
    }

    for (const Atom& answer : call(q, depth + 1)) {
        Substitution next = theta;
        ++statistics_.unification_attempts;
        if (!Unifier::unify(q, answer, next)) continue;
        ++statistics_.successful_unifications;
        premises.push_back(answer);
        join(body, position + 1, next, premises, negations, renamed, original, depth, table);
        premises.pop_back();
    }
}

// True if the ground atom is derivable. Evaluated by an independent, completed resolution so that
// it never observes a table that is still growing.
bool SLDResolver::negation_holds(const Atom& ground) {
    const std::string key = to_string(ground);
    if (auto it = negation_cache_.find(key); it != negation_cache_.end()) return it->second;

    std::vector<Atom> seed;  // atoms of base_ that are not program facts
    for (const auto& [pred, atoms] : base_)
        for (const auto& a : atoms)
            if (!kb_fact_keys_.contains(to_string(a))) seed.push_back(a);

    SLDResolver nested(kb_, options_);
    const bool holds = !nested.run(ground, seed, false).empty();
    statistics_.calls += nested.statistics_.calls;
    statistics_.unification_attempts += nested.statistics_.unification_attempts;
    statistics_.successful_unifications += nested.statistics_.successful_unifications;
    statistics_.rule_expansions += nested.statistics_.rule_expansions;
    statistics_.failed_goals += nested.statistics_.failed_goals;
    statistics_.table_hits += nested.statistics_.table_hits;
    statistics_.table_inserts += nested.statistics_.table_inserts;
    statistics_.passes += nested.statistics_.passes;
    statistics_.maximum_depth = std::max(statistics_.maximum_depth, nested.statistics_.maximum_depth);
    statistics_.truncated = statistics_.truncated || nested.statistics_.truncated;
    negation_cache_[key] = holds;
    return holds;
}

Proof SLDResolver::proof_of(const Atom& atom, std::size_t guard) const {
    auto it = supports_.find(to_string(atom));
    if (it == supports_.end() || guard == 0) return Proof{atom, "unknown", {}};
    Proof p{atom, it->second.source, {}};
    for (const auto& prem : it->second.premises) p.premises.push_back(proof_of(prem, guard - 1));
    for (const auto& n : it->second.failed_negations) p.premises.push_back(Proof{n, "not derivable", {}});
    return p;
}

std::vector<Answer> SLDResolver::run(const Atom& goal, const std::vector<Atom>& seed, bool check_stratification) {
    statistics_ = {};
    if (check_stratification) (void)stratify(kb_);  // throws std::invalid_argument if not stratified

    base_.clear();
    base_by_first_.clear();
    kb_fact_keys_.clear();
    tables_.clear();
    supports_.clear();
    negation_cache_.clear();
    std::unordered_set<std::string> seen;
    auto add_base = [&](const Atom& a, bool is_fact) {
        if (!seen.insert(to_string(a)).second) return;
        if (is_fact) kb_fact_keys_.insert(to_string(a));
        base_[a.predicate].push_back(a);
        if (!a.arguments.empty()) base_by_first_[first_key(a.predicate, a.arguments[0])].push_back(a);
    };
    for (const auto& f : kb_.facts()) add_base(f, true);
    for (const auto& a : seed) {
        if (!is_ground(a)) throw std::invalid_argument("seed atom must be ground: " + to_string(a));
        add_base(a, false);
    }

    std::vector<Atom> found;
    for (;;) {
        grew_ = false;
        visited_.clear();
        ++statistics_.passes;
        found = call(goal, 0);
        if (!options_.use_tabling || !grew_) break;
        if (statistics_.passes >= kMaxPasses) {
            statistics_.truncated = true;
            break;
        }
    }

    if (options_.deterministic)
        std::sort(found.begin(), found.end(), [](const Atom& a, const Atom& b) { return to_string(a) < to_string(b); });
    if (options_.maximum_answers && found.size() > options_.maximum_answers) found.resize(options_.maximum_answers);

    std::vector<Answer> out;
    for (const auto& atom : found) {
        Answer a;
        Unifier::unify(goal, atom, a.substitution);
        a.proofs.push_back(proof_of(atom, 100000));
        out.push_back(std::move(a));
    }
    return out;
}

std::vector<Answer> SLDResolver::solve(const Atom& goal, const std::vector<Atom>& seed) {
    return run(goal, seed, true);
}

bool SLDResolver::entails(const Atom& goal, const std::vector<Atom>& seed) {
    return !solve(goal, seed).empty();
}

}  // namespace alp::logic
