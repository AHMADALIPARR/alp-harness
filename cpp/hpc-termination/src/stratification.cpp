// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include "hpc_termination/stratification.hpp"
#include <algorithm>
#include <map>
#include <queue>
#include <set>

namespace hpc::termination {

std::vector<Stratum> stratify(const Program&, const DependencyGraph& g) {
    std::map<std::string,int> level;
    for (const auto& x : g.predicates) level[x] = 0;

    // Bellman-style relaxation of the stratification inequalities:
    // head >= body for +, head > body for -.
    const std::size_t n = g.predicates.size();
    for (std::size_t i=0; i<n; ++i) {
        bool changed = false;
        for (const auto& e : g.edges) {
            const int required = level[e.to] + (e.sign == Sign::Negative ? 1 : 0);
            if (level[e.from] < required) { level[e.from] = required; changed = true; }
        }
        if (!changed) break;
    }

    std::map<int,std::set<std::string>> groups;
    for (const auto& [pname, s] : level) groups[s].insert(pname);

    std::vector<Stratum> out;
    for (const auto& [idx, preds] : groups) {
        Stratum s; s.index = idx; s.predicates = preds;
        std::set<std::string> indegree_zero = preds;
        std::map<std::string,int> indeg;
        for (const auto& x : preds) indeg[x]=0;
        for (const auto& e : g.edges) {
            if (preds.count(e.from) && preds.count(e.to) && e.sign == Sign::Positive) {
                ++indeg[e.to]; indegree_zero.erase(e.to);
            }
        }
        std::queue<std::string> q;
        for (const auto& x : indegree_zero) q.push(x);
        while (!q.empty()) {
            auto v=q.front(); q.pop(); s.topological_order.push_back(v);
            for (const auto& e : g.edges) if (e.sign == Sign::Positive && e.from==v && preds.count(e.to)) {
                if (--indeg[e.to]==0) q.push(e.to);
            }
        }
        s.recursive = s.topological_order.size() != preds.size();
        if (s.recursive) {
            s.topological_order.clear();
            s.topological_order.assign(preds.begin(), preds.end());
        }
        out.push_back(std::move(s));
    }
    return out;
}

} // namespace hpc::termination
