#pragma once
#include "fact_store.hpp"
#include "knowledge_base.hpp"
#include "model.hpp"
#include <vector>

namespace alp {

// Constraints violated in the given closure (every satisfying instance of a
// constraint body is one violation).
std::vector<Violation> violations(const KnowledgeBase&, const FactStore& closure);

// Evaluates P together with the model's abduced atoms and facts, then checks IC.
std::vector<Violation> violations(const KnowledgeBase&, const Model&);

bool satisfies_constraints(const KnowledgeBase&, const Model&);

}  // namespace alp
