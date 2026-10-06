#pragma once
#include "alp/knowledge_base.hpp"
#include "alp/analysis/dependency.hpp"
#include <string>
#include <vector>

namespace alp::analysis {

enum class DiagnosticSeverity { note, warning, error };
struct Diagnostic { DiagnosticSeverity severity{DiagnosticSeverity::note}; std::string code; std::string message; Predicate predicate{}; };
struct ValidationReport { std::vector<Diagnostic> diagnostics; bool valid() const; std::size_t errors() const; std::size_t warnings() const; };

ValidationReport validate_program(const KnowledgeBase& kb);
ValidationReport validate_rule(const HornClause& rule);
ValidationReport validate_atom(const Atom& atom);
ValidationReport validate_constraint(const IntegrityConstraint& constraint);

} // namespace alp::analysis
