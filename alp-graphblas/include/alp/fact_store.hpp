#pragma once
#include "atom.hpp"
#include "proof.hpp"
#include <map>
#include <string>
#include <unordered_map>
#include <vector>

namespace alp {

// A set of ground atoms with a per-predicate index and the derivation of each
// atom (which rule produced it, from which premises).
class FactStore {
public:
    struct Derivation {
        std::string source;                  // "fact", "assumption" or "rule: <clause>"
        std::vector<Atom> premises;          // positive body instances
        std::vector<Atom> failed_negations;  // negated body instances that were not derivable
    };

    // Returns true if the atom was new.
    bool add(const Atom&, std::string source = "fact", std::vector<Atom> premises = {},
             std::vector<Atom> failed_negations = {});
    bool contains(const Atom&) const;

    const std::vector<Atom>& all() const { return atoms_; }
    const std::vector<Atom>& with_predicate(const Predicate&) const;
    // Atoms of the predicate whose first argument equals `first` (a ground term). O(1) lookup.
    const std::vector<Atom>& with_first_argument(const Predicate&, const Term& first) const;
    std::size_t size() const { return atoms_.size(); }

    const Derivation* derivation(const Atom&) const;
    // Full proof tree for a stored atom (throws std::out_of_range if absent).
    Proof proof(const Atom&) const;
    // One-step proofs (premises are leaves) for every non-base atom.
    std::vector<Proof> derivation_steps() const;

private:
    std::vector<Atom> atoms_;
    std::unordered_map<std::string, Derivation> derivations_;
    std::map<Predicate, std::vector<Atom>> by_predicate_;
    std::unordered_map<std::string, std::vector<Atom>> by_first_argument_;  // key: predicate + first argument
    static std::string first_key(const Predicate&, const Term& first);
};

}  // namespace alp
