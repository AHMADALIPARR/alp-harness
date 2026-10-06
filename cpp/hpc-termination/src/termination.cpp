// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include "hpc_termination/termination.hpp"
#include <map>
#include <set>
#include <functional>

namespace hpc::termination {

static bool variable_in_term(const Term& t, const std::string& v) {
    if (t.kind == TermKind::Variable) return t.name == v;
    for (const auto& a : t.args) if (variable_in_term(a,v)) return true;
    return false;
}

static std::set<std::string> variables(const Atom& a) {
    std::set<std::string> out;
    std::function<void(const Term&)> walk = [&](const Term& t) {
        if (t.kind == TermKind::Variable) out.insert(t.name);
        for (const auto& x : t.args) walk(x);
    };
    for (const auto& t : a.args) walk(t);
    return out;
}

bool range_restricted(const Program& p) {
    for (const auto& r : p.rules) {
        std::set<std::string> positive_vars;
        for (const auto& b : r.body) if (b.sign == Sign::Positive) {
            const auto vs=variables(b); positive_vars.insert(vs.begin(),vs.end());
        }
        for (const auto& v : variables(r.head)) if (!positive_vars.count(v)) return false;
        // Constraint safety: a negative atom is also not a binder.
        for (const auto& b : r.body) {
            if (b.predicate == "gt" || b.predicate == "ge" || b.predicate == "lt" || b.predicate == "le" || b.predicate == "eq" || b.predicate == "neq") {
                for (const auto& v : variables(b)) if (!positive_vars.count(v)) return false;
            }
        }
    }
    return true;
}

bool rule_can_generate_fresh_terms(const Rule& r) {
    // A function term in the head can recursively create an unbounded Herbrand universe.
    std::function<bool(const Term&)> has_function = [&](const Term& t) {
        if (t.kind == TermKind::Function) return true;
        for (const auto& a : t.args) if (has_function(a)) return true;
        return false;
    };
    for (const auto& t : r.head.args) if (has_function(t)) return true;
    return false;
}

TerminationResult certify(const Program& p) {
    TerminationResult result;
    const auto g = build_dependency_graph(p);
    if (has_negative_cycle(g)) {
        result.certificate.kind = TerminationCertificate::Kind::Rejected;
        result.certificate.reason = "UnstratifiedProgram";
        return result;
    }

    for (const auto& r : p.rules) {
        if (rule_can_generate_fresh_terms(r)) {
            result.certificate.kind = TerminationCertificate::Kind::Rejected;
            result.certificate.reason = "InfiniteHerbrandUniverse(" + r.id + ")";
            return result;
        }
    }
    if (!range_restricted(p)) {
        result.certificate.kind = TerminationCertificate::Kind::Rejected;
        result.certificate.reason = "UnsafeOrUngroundedRule";
        return result;
    }

    const auto domain = compute_active_domain(p);
    if (!domain.finite) {
        result.certificate.kind = TerminationCertificate::Kind::Rejected;
        result.certificate.reason = "InfiniteHerbrandUniverse";
        return result;
    }

    const auto strata = stratify(p,g);
    bool recursive=false;
    for (const auto& s : strata) if (s.recursive) recursive=true;

    result.certificate.strata = strata;
    result.certificate.bound = herbrand_base_bound(p,domain);
    result.certificate.kind = recursive ? TerminationCertificate::Kind::Stratified : TerminationCertificate::Kind::NonRecursive;
    result.established = true;
    return result;
}

} // namespace hpc::termination
