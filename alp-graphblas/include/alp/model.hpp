#pragma once
#include "atom.hpp"
#include "clause.hpp"
#include "proof.hpp"
#include <string>
#include <vector>

namespace alp {

struct AbductiveHypothesis {
    Atom atom;
};

struct Violation {
    IntegrityConstraint constraint;
    std::vector<Atom> witnesses;  // positive body instances that triggered the violation
};

struct Model {
    std::vector<Atom> facts;    // facts of P
    std::vector<Atom> abduced;  // hypotheses assumed in this model
    std::vector<Atom> derived;  // everything else the rules derived
    std::vector<Atom> answers;  // instances of the abductive goal that hold (if a goal was given)
    std::vector<IntegrityConstraint> constraints;
    std::vector<Proof> proofs;  // one-step derivation of every derived atom
    std::vector<Violation> violations;
    bool valid{true};
};

std::string to_string(const Violation&);
std::string to_string(const Model&);

}  // namespace alp
