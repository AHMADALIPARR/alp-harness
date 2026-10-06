#include "alp/io/serialization.hpp"
#include "alp/parser.hpp"
#include <algorithm>
#include <sstream>

namespace alp::io {

std::string serialize_term(const Term& term) { return to_string(term); }
std::string serialize_atom(const Atom& atom) { return atom.to_string(); }

std::string serialize_literal(const Literal& literal) {
    return std::string(literal.negated ? "not " : "") + literal.atom.to_string();
}

std::string serialize_clause(const HornClause& clause) {
    std::ostringstream out;
    out << clause.head.to_string();
    if (!clause.body.empty()) {
        out << " <- ";
        for (std::size_t i = 0; i < clause.body.size(); ++i) {
            if (i) out << ", ";
            out << serialize_literal(clause.body[i]);
        }
    }
    out << ".";
    return out.str();
}

std::string serialize_constraint(const IntegrityConstraint& constraint) {
    std::ostringstream out;
    out << "false <- ";
    for (std::size_t i = 0; i < constraint.body.size(); ++i) {
        if (i) out << ", ";
        out << serialize_literal(constraint.body[i]);
    }
    out << ".";
    return out.str();
}

std::string serialize_program(const KnowledgeBase& kb) {
    std::vector<std::string> lines;
    for (const auto& fact : kb.facts()) lines.push_back(fact.to_string() + ".");
    for (const auto& rule : kb.rules()) lines.push_back(serialize_clause(rule));
    for (const auto& predicate : kb.abducibles())
        lines.push_back("abducible(" + predicate.name + (predicate.arity ? "/" + std::to_string(predicate.arity) : "") + ").");
    for (const auto& constraint : kb.constraints()) lines.push_back(serialize_constraint(constraint));
    std::sort(lines.begin(), lines.end());
    std::ostringstream out;
    for (const auto& line : lines) out << line << '\n';
    return out.str();
}

std::string serialize_model(const Model& model) {
    std::vector<std::string> lines;
    for (const auto& fact : model.facts) lines.push_back("fact " + fact.to_string());
    for (const auto& fact : model.abduced) lines.push_back("abduced " + fact.to_string());
    for (const auto& fact : model.derived) lines.push_back("derived " + fact.to_string());
    for (const auto& violation : model.violations)
        lines.push_back("violation " + serialize_constraint(violation.constraint));
    std::sort(lines.begin(), lines.end());
    std::ostringstream out;
    out << (model.valid ? "valid" : "invalid") << '\n';
    for (const auto& line : lines) out << line << '\n';
    return out.str();
}

KnowledgeBase deserialize_program(const std::string& text) { return parse_program(text); }

} // namespace alp::io
