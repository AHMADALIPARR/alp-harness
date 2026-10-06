#include "alp/clause.hpp"

namespace alp {

namespace {
std::string body_to_string(const std::vector<Literal>& body) {
    std::string s;
    for (std::size_t i = 0; i < body.size(); ++i) {
        if (i) s += ", ";
        s += to_string(body[i]);
    }
    return s;
}
}  // namespace

std::string to_string(const Literal& l) {
    return (l.negated ? "not " : "") + to_string(l.atom);
}

std::string to_string(const HornClause& c) {
    if (c.body.empty()) return to_string(c.head) + ".";
    return to_string(c.head) + " <- " + body_to_string(c.body) + ".";
}

std::string to_string(const IntegrityConstraint& c) {
    return "false <- " + body_to_string(c.body) + ".";
}

}  // namespace alp
