#pragma once
#include "alp/knowledge_base.hpp"
#include "alp/proof.hpp"
#include "alp/substitution.hpp"
#include "alp/unification.hpp"
#include <cstddef>
#include <map>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace alp::logic {

struct Answer {
    Substitution substitution;       // bindings of the goal's variables
    std::vector<Proof> proofs;       // a derivation tree of the answer atom
    std::vector<Atom> residual_goals;  // always empty: answers are ground (programs are range-restricted)
};

struct ResolutionOptions {
    std::size_t maximum_depth{1024};   // bound on call nesting; deeper calls are not expanded
    std::size_t maximum_answers{0};    // 0 = all; otherwise the first N answers (after full evaluation)
    bool use_clause_index{true};       // look rules up by head predicate instead of scanning all
    bool use_tabling{true};            // memoize calls and iterate to a fixed point (needed for recursion through cycles)
    bool allow_negation_as_failure{true};  // false: every negated literal fails
    bool deterministic{true};          // return answers sorted by their text
};

struct ResolutionStatistics {
    std::size_t calls{0};
    std::size_t unification_attempts{0};
    std::size_t successful_unifications{0};
    std::size_t rule_expansions{0};
    std::size_t failed_goals{0};       // negated literals that failed
    std::size_t table_hits{0};
    std::size_t table_inserts{0};      // answers added to tables
    std::size_t maximum_depth{0};
    std::size_t passes{0};             // fixed-point passes over the call graph
    bool truncated{false};             // maximum_depth or the pass limit cut the search: answers may be incomplete
};

class ClauseIndex {
    using RuleId = std::size_t;
    std::unordered_map<std::string, std::vector<RuleId>> by_signature_;
    static std::string signature(const Predicate& predicate);
public:
    ClauseIndex() = default;
    explicit ClauseIndex(const KnowledgeBase& kb);
    void rebuild(const KnowledgeBase& kb);
    void add(RuleId id, const HornClause& clause);
    const std::vector<RuleId>& candidates(const Predicate& predicate) const;
    bool empty() const noexcept;
    std::size_t bucket_count() const noexcept;
};

// Goal-directed (top-down) evaluation of the Horn program with tabling.
//
// Each distinct call (up to variable renaming) owns a table of ground answers.
// A pass evaluates the goal, consulting tables for repeated calls; passes are
// repeated until no table grows, which makes the result complete and sound for
// range-restricted programs even with left recursion and cycles.
// Negation as failure is evaluated by a nested, fully completed resolution of the
// ground atom, so it is sound for stratified programs (std::invalid_argument
// is thrown from solve() for programs with negation inside a recursive cycle).
// The answers coincide with those of the bottom-up InferenceEngine.
class SLDResolver {
    struct Support {
        std::string source;
        std::vector<Atom> premises;
        std::vector<Atom> failed_negations;
    };
    struct Table {
        std::vector<Atom> answers;
        std::unordered_set<std::string> keys;
    };

    const KnowledgeBase& kb_;
    ResolutionOptions options_;
    ClauseIndex index_;
    ResolutionStatistics statistics_;

    // state of one solve()
    std::map<Predicate, std::vector<Atom>> base_;
    std::unordered_map<std::string, std::vector<Atom>> base_by_first_;  // predicate + first argument
    std::unordered_set<std::string> kb_fact_keys_;
    std::unordered_map<std::string, Table> tables_;
    std::unordered_map<std::string, Support> supports_;
    std::unordered_set<std::string> visited_;
    std::unordered_map<std::string, bool> negation_cache_;
    bool grew_{false};
    std::size_t serial_{0};

    static std::string variant_key(const Atom& atom);
    std::vector<Atom> call(const Atom& target, std::size_t depth);
    void join(const std::vector<const Literal*>& body, std::size_t position, const Substitution& theta,
              std::vector<Atom>& premises, std::vector<Atom>& negations, const HornClause& renamed,
              const HornClause& original, std::size_t depth, Table& table);
    bool negation_holds(const Atom& ground);
    Proof proof_of(const Atom& atom, std::size_t guard) const;
    std::vector<Answer> run(const Atom& goal, const std::vector<Atom>& seed, bool check_stratification);

public:
    explicit SLDResolver(const KnowledgeBase& kb, ResolutionOptions options = {});
    std::vector<Answer> solve(const Atom& goal, const std::vector<Atom>& seed = {});
    bool entails(const Atom& goal, const std::vector<Atom>& seed = {});
    const ResolutionStatistics& statistics() const noexcept { return statistics_; }
    void reset_statistics() noexcept { statistics_ = {}; }
};

}  // namespace alp::logic
