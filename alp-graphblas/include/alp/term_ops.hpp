#pragma once
#include "alp/term.hpp"
#include "alp/substitution.hpp"
#include <cstddef>
#include <functional>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace alp {

struct TermMetrics {
    std::size_t nodes{0};
    std::size_t variables{0};
    std::size_t constants{0};
    std::size_t compounds{0};
    std::size_t maximum_depth{0};
    std::size_t maximum_arity{0};
};

struct TermOrder {
    bool operator()(const Term& a, const Term& b) const;
};

struct TermHash {
    std::size_t operator()(const Term& term) const noexcept;
};

std::size_t term_size(const Term& term);
std::size_t term_depth(const Term& term);
std::size_t term_variable_count(const Term& term);
std::size_t term_constant_count(const Term& term);
std::size_t term_compound_count(const Term& term);
std::size_t term_maximum_arity(const Term& term);
TermMetrics term_metrics(const Term& term);

bool is_linear(const Term& term);
bool contains_variable(const Term& term, const std::string& name);
bool contains_functor(const Term& term, const std::string& functor);
bool contains_constant(const Term& term, const std::string& constant);

std::set<std::string> variable_names(const Term& term);
std::set<std::string> functor_names(const Term& term);
std::set<std::string> constant_names(const Term& term);
std::map<std::string, std::size_t> variable_occurrences(const Term& term);

Term rename_variables(const Term& term, const std::function<std::string(const std::string&)>& rename);
Term freshen_variables(const Term& term, std::size_t serial);
Term normalize_variables(const Term& term);
Term canonicalize(const Term& term);

std::vector<const Term*> preorder(const Term& term);
std::vector<const Term*> postorder(const Term& term);
std::vector<std::vector<std::size_t>> paths(const Term& term);
const Term* at_path(const Term& term, const std::vector<std::size_t>& path);

Term replace_subterm(const Term& term, const std::vector<std::size_t>& path, const Term& replacement);
Term map_terms(const Term& term, const std::function<Term(const Term&)>& mapper);
Term fold_terms(const Term& term, const std::function<Term(const Term&, const std::vector<Term>&)>& folder);

int compare_terms(const Term& a, const Term& b);
bool variant_equal(const Term& a, const Term& b);
std::string skeleton(const Term& term);
std::string signature(const Term& term);
std::string fingerprint(const Term& term);

} // namespace alp
