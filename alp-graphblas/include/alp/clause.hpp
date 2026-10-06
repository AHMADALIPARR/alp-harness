#pragma once
#include "atom.hpp"
#include <string>
#include <vector>

namespace alp {

struct Literal {
    Atom atom;
    bool negated{false};
};

struct HornClause {
    Atom head;
    std::vector<Literal> body;
};

// Body-only clause: a model is rejected if every literal of the body holds in it.
struct IntegrityConstraint {
    std::vector<Literal> body;
};

std::string to_string(const Literal&);
std::string to_string(const HornClause&);
std::string to_string(const IntegrityConstraint&);

}  // namespace alp
