#pragma once
#include "term.hpp"
#include "predicate.hpp"
#include <set>
#include <string>
#include <vector>
namespace alp {
struct Atom { Predicate predicate; std::vector<Term> arguments; bool operator==(const Atom&) const = default; std::string to_string() const; };
std::string to_string(const Atom&);
bool structurally_equal(const Atom&, const Atom&);
bool is_ground(const Atom&);
void collect_variables(const Atom&, std::set<std::string>&);
}
