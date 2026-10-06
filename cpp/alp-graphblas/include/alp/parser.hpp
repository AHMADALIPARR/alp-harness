#pragma once
#include "knowledge_base.hpp"
#include <stdexcept>
#include <string>

namespace alp {

struct ParseError : std::runtime_error {
    int line;
    int column;
    ParseError(int l, int c, const std::string& msg)
        : std::runtime_error(std::to_string(l) + ":" + std::to_string(c) + ": " + msg), line(l), column(c) {}
};

// Syntax (one clause per '.'):
//   fact.                         edge(a,b).
//   head <- body.                 reachable(X,Z) <- edge(X,Y), reachable(Y,Z).
//   head :- body.                 (alias of <-)
//   false <- body.                integrity constraint (also `<- body.` / `:- body.`)
//   abducible(name).              abducible predicate of arity 0
//   abducible(name/arity).        abducible predicate of the given arity
// Body literals may be negated with `not`. Variables start with an uppercase
// letter or '_' (a lone '_' is anonymous). '%' starts a line comment.
// Throws ParseError for syntax errors and for clauses the knowledge base rejects.
KnowledgeBase parse_program(const std::string&);
KnowledgeBase parse_file(const std::string&);

// Parses a single atom such as `reachable(a,X)` (no trailing '.').
Atom parse_atom(const std::string&);

}  // namespace alp
