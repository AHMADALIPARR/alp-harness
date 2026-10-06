// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#pragma once
#include <cstddef>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace hpc::termination {

enum class Sign { Positive, Negative };

enum class TermKind { Constant, Variable, Function };

struct Term {
    TermKind kind{TermKind::Constant};
    std::string name;
    std::vector<Term> args;
    static Term constant(std::string n) { return {TermKind::Constant, std::move(n), {}}; }
    static Term variable(std::string n) { return {TermKind::Variable, std::move(n), {}}; }
    static Term function(std::string n, std::vector<Term> a) { return {TermKind::Function, std::move(n), std::move(a)}; }
    bool operator<(const Term& o) const;
};

struct Atom {
    std::string predicate;
    std::vector<Term> args;
    Sign sign{Sign::Positive};
};

struct Rule {
    std::string id;
    Atom head;
    std::vector<Atom> body;
};

struct Program {
    std::vector<Atom> facts;
    std::vector<Rule> rules;
};

struct Edge {
    std::string from;
    std::string to;
    Sign sign;
};

struct DependencyGraph {
    std::set<std::string> predicates;
    std::vector<Edge> edges;
};

struct Stratum {
    std::set<std::string> predicates;
    int index{0};
    std::vector<std::string> topological_order;
    bool recursive{false};
};

struct ActiveDomain {
    std::set<std::string> constants;
    bool finite{true};
    bool has_unbounded_function_generation{false};
};

struct TerminationCertificate {
    enum class Kind { NonRecursive, Stratified, Rejected };
    Kind kind{Kind::Rejected};
    std::vector<Stratum> strata;
    std::size_t bound{0};
    std::string reason;
};

struct TerminationResult {
    bool established{false};
    TerminationCertificate certificate;
};

} // namespace hpc::termination
