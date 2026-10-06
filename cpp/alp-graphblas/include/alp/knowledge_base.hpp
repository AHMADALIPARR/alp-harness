#pragma once
#include "clause.hpp"
#include <set>
#include <string>
#include <unordered_set>
#include <vector>

namespace alp {

// Holds the three separate collections of the framework:
//   P  - facts and Horn rules (with negation as failure in bodies)
//   A  - abducible predicates
//   IC - integrity constraints
//
// All mutators validate their input and throw std::invalid_argument:
//   * facts must be ground;
//   * every variable of a rule head, and every variable of a negated literal
//     (in rules and constraints), must occur in a positive body literal
//     (range restriction), which makes negation as failure well defined.
class KnowledgeBase {
    std::vector<Atom> facts_;
    std::unordered_set<std::string> fact_keys_;
    std::vector<HornClause> rules_;
    std::vector<IntegrityConstraint> constraints_;
    std::set<Predicate> abducibles_;

public:
    void assert_fact(const Atom&);
    void add_rule(const HornClause&);
    void add_constraint(const IntegrityConstraint&);
    void add_abducible(const Predicate&);

    const std::vector<Atom>& facts() const { return facts_; }
    const std::vector<HornClause>& rules() const { return rules_; }
    const std::vector<IntegrityConstraint>& constraints() const { return constraints_; }

    // Adds everything from `other` (validated again, duplicates of facts are ignored).
    void merge(const KnowledgeBase& other);

    bool is_abducible(const Predicate&) const;
    std::vector<Predicate> abducibles() const;

    // Constants occurring anywhere in the program (the Herbrand universe used
    // to ground abducible predicates of arity > 0).
    std::set<std::string> constants() const;
};

}  // namespace alp
