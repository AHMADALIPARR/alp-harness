// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include "hpc_termination/domain.hpp"
#include <set>
#include <functional>

namespace hpc::termination {

static void collect_term_constants(const Term& t, ActiveDomain& d) {
    if (t.kind == TermKind::Constant) d.constants.insert(t.name);
    if (t.kind == TermKind::Function) {
        d.has_unbounded_function_generation = true;
        for (const auto& a : t.args) collect_term_constants(a, d);
    }
}

ActiveDomain compute_active_domain(const Program& p) {
    ActiveDomain d;
    for (const auto& f : p.facts) for (const auto& t : f.args) collect_term_constants(t, d);
    for (const auto& r : p.rules) {
        for (const auto& t : r.head.args) if (t.kind == TermKind::Constant) collect_term_constants(t, d);
        for (const auto& a : r.body) for (const auto& t : a.args) if (t.kind == TermKind::Constant) collect_term_constants(t, d);
    }
    d.finite = !d.has_unbounded_function_generation;
    return d;
}

static void predicates_arity(const Program& p, std::set<std::pair<std::string,std::size_t>>& s) {
    for (const auto& f : p.facts) s.insert({f.predicate,f.args.size()});
    for (const auto& r : p.rules) {
        s.insert({r.head.predicate,r.head.args.size()});
        for (const auto& b : r.body) s.insert({b.predicate,b.args.size()});
    }
}

std::size_t herbrand_base_bound(const Program& p, const ActiveDomain& d) {
    std::set<std::pair<std::string,std::size_t>> pa;
    predicates_arity(p, pa);
    std::size_t total = 0;
    std::size_t n = d.constants.size();
    for (const auto& [pred, arity] : pa) {
        std::size_t count = 1;
        for (std::size_t i=0; i<arity; ++i) count *= n;
        total += count;
    }
    return total;
}

} // namespace hpc::termination
