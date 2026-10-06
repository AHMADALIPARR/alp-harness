#include "alp/model.hpp"

namespace alp {

namespace {
void append_list(std::string& s, const char* label, const std::vector<Atom>& v) {
    s += label;
    s += ":";
    for (const auto& a : v) s += " " + to_string(a);
    s += "\n";
}
}  // namespace

std::string to_string(const Violation& v) {
    std::string s = to_string(v.constraint);
    if (!v.witnesses.empty()) {
        s += "  [";
        for (std::size_t i = 0; i < v.witnesses.size(); ++i) {
            if (i) s += ", ";
            s += to_string(v.witnesses[i]);
        }
        s += "]";
    }
    return s;
}

std::string to_string(const Model& m) {
    std::string s;
    append_list(s, "abduced", m.abduced);
    append_list(s, "derived", m.derived);
    if (!m.answers.empty()) append_list(s, "answers", m.answers);
    s += m.valid ? "valid\n" : "invalid\n";
    for (const auto& v : m.violations) s += "violates: " + to_string(v) + "\n";
    return s;
}

}  // namespace alp
