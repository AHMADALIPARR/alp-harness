// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2026 Ahmad Ali Parr
// GNU Affero General Public License version 3 only.
// From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz.

#include "hpc_termination/dependency_graph.hpp"
#include <algorithm>
#include <functional>
#include <map>
#include <set>

namespace hpc::termination {

DependencyGraph build_dependency_graph(const Program& p) {
    DependencyGraph g;
    for (const auto& r : p.rules) {
        g.predicates.insert(r.head.predicate);
        for (const auto& b : r.body) {
            g.predicates.insert(b.predicate);
            g.edges.push_back({r.head.predicate, b.predicate, b.sign});
        }
    }
    for (const auto& f : p.facts) g.predicates.insert(f.predicate);
    std::sort(g.edges.begin(), g.edges.end(), [](const Edge& a, const Edge& b) {
        if (a.from != b.from) return a.from < b.from;
        if (a.to != b.to) return a.to < b.to;
        return static_cast<int>(a.sign) < static_cast<int>(b.sign);
    });
    g.edges.erase(std::unique(g.edges.begin(), g.edges.end(), [](const Edge& a, const Edge& b) {
        return a.from == b.from && a.to == b.to && a.sign == b.sign;
    }), g.edges.end());
    return g;
}

std::vector<std::vector<std::string>> strongly_connected_components(const DependencyGraph& g) {
    std::map<std::string, std::vector<std::string>> adj;
    for (const auto& p : g.predicates) adj[p] = {};
    for (const auto& e : g.edges) adj[e.from].push_back(e.to);

    std::map<std::string,int> index, low;
    std::set<std::string> stack_set;
    std::vector<std::string> stack;
    std::vector<std::vector<std::string>> result;
    int next = 0;

    std::function<void(const std::string&)> visit = [&](const std::string& v) {
        index[v] = low[v] = next++;
        stack.push_back(v);
        stack_set.insert(v);
        for (const auto& w : adj[v]) {
            if (!index.count(w)) {
                visit(w);
                low[v] = std::min(low[v], low[w]);
            } else if (stack_set.count(w)) {
                low[v] = std::min(low[v], index[w]);
            }
        }
        if (low[v] == index[v]) {
            std::vector<std::string> component;
            while (true) {
                auto w = stack.back(); stack.pop_back(); stack_set.erase(w);
                component.push_back(w);
                if (w == v) break;
            }
            std::sort(component.begin(), component.end());
            result.push_back(std::move(component));
        }
    };
    for (const auto& p : g.predicates) if (!index.count(p)) visit(p);
    return result;
}

bool has_negative_cycle(const DependencyGraph& g) {
    const auto sccs = strongly_connected_components(g);
    std::map<std::string,int> component;
    for (int i=0; i<(int)sccs.size(); ++i) for (const auto& p : sccs[i]) component[p]=i;
    for (const auto& e : g.edges) {
        if (e.sign == Sign::Negative && component[e.from] == component[e.to]) return true;
    }
    return false;
}

} // namespace hpc::termination
