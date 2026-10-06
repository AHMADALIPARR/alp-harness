#pragma once
#include "alp/knowledge_base.hpp"
#include "alp/model.hpp"
#include <string>

namespace alp::io {

std::string serialize_term(const Term& term);
std::string serialize_atom(const Atom& atom);
std::string serialize_literal(const Literal& literal);
std::string serialize_clause(const HornClause& clause);
std::string serialize_constraint(const IntegrityConstraint& constraint);
std::string serialize_program(const KnowledgeBase& kb);
std::string serialize_model(const Model& model);

KnowledgeBase deserialize_program(const std::string& text);

} // namespace alp::io
