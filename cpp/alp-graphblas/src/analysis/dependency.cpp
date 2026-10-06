#include "alp/analysis/dependency.hpp"
#include <algorithm>
#include <functional>
#include <limits>
#include <stdexcept>

namespace alp::analysis {

static bool pred_less(const Predicate& a, const Predicate& b) {
    if (a.name != b.name) return a.name < b.name;
    return a.arity < b.arity;
}

DependencyGraph::DependencyGraph() : component_of(pred_less) {}
Stratification::Stratification() : levels_(pred_less) {}
Stratification::Stratification(const KnowledgeBase& kb) : levels_(pred_less) { compute(kb); }

void DependencyGraph::build(const KnowledgeBase& kb) {
    predicates.clear();
    edges.clear();
    components.clear();
    component_of.clear();
    stratified = true;

    std::set<Predicate, decltype(&pred_less)> seen(pred_less);
    for (const auto& fact : kb.facts()) seen.insert(fact.predicate);
    for (const auto& rule : kb.rules()) {
        seen.insert(rule.head.predicate);
        for (const auto& literal : rule.body) seen.insert(literal.atom.predicate);
    }
    predicates.assign(seen.begin(), seen.end());

    for (const auto& rule : kb.rules()) {
        for (const auto& literal : rule.body) {
            edges.push_back({rule.head.predicate, literal.atom.predicate, literal.negated});
        }
    }

    std::map<Predicate, std::size_t, decltype(&pred_less)> ids(pred_less);
    for (std::size_t i = 0; i < predicates.size(); ++i) ids[predicates[i]] = i;
    std::vector<std::vector<std::size_t>> adjacency(predicates.size());
    for (const auto& edge : edges) adjacency[ids[edge.from]].push_back(ids[edge.to]);

    std::vector<int> index(predicates.size(), -1), low(predicates.size(), -1);
    std::vector<bool> on_stack(predicates.size(), false);
    std::vector<std::size_t> stack;
    int next_index = 0;
    std::function<void(std::size_t)> visit = [&](std::size_t v) {
        index[v] = low[v] = next_index++;
        stack.push_back(v);
        on_stack[v] = true;
        for (const auto w : adjacency[v]) {
            if (index[w] == -1) {
                visit(w);
                low[v] = std::min(low[v], low[w]);
            } else if (on_stack[w]) {
                low[v] = std::min(low[v], index[w]);
            }
        }
        if (low[v] == index[v]) {
            StrongComponent component;
            component.id = components.size();
            while (true) {
                const auto w = stack.back();
                stack.pop_back();
                on_stack[w] = false;
                component.predicates.push_back(predicates[w]);
                component_of[predicates[w]] = component.id;
                if (w == v) break;
            }
            std::sort(component.predicates.begin(), component.predicates.end(), pred_less);
            components.push_back(std::move(component));
        }
    };
    for (std::size_t i = 0; i < predicates.size(); ++i) if (index[i] == -1) visit(i);

    for (const auto& edge : edges) {
        auto from = component_of.at(edge.from);
        auto to = component_of.at(edge.to);
        if (from == to && edge.negative) stratified = false;
    }
}

const StrongComponent* DependencyGraph::component(const Predicate& p) const {
    auto it = component_of.find(p);
    return it == component_of.end() ? nullptr : &components.at(it->second);
}

std::vector<Predicate> DependencyGraph::dependencies(const Predicate& p, bool include_negative) const {
    std::vector<Predicate> out;
    for (const auto& edge : edges)
        if (edge.from == p && (include_negative || !edge.negative)) out.push_back(edge.to);
    std::sort(out.begin(), out.end(), pred_less);
    out.erase(std::unique(out.begin(), out.end()), out.end());
    return out;
}

std::vector<Predicate> DependencyGraph::dependents(const Predicate& p, bool include_negative) const {
    std::vector<Predicate> out;
    for (const auto& edge : edges)
        if (edge.to == p && (include_negative || !edge.negative)) out.push_back(edge.from);
    std::sort(out.begin(), out.end(), pred_less);
    out.erase(std::unique(out.begin(), out.end()), out.end());
    return out;
}

bool DependencyGraph::has_negative_cycle() const {
    if (!stratified) return true;
    return false;
}

std::vector<std::vector<Predicate>> DependencyGraph::cycles() const {
    std::vector<std::vector<Predicate>> out;
    for (const auto& component : components) {
        if (component.predicates.size() > 1) out.push_back(component.predicates);
        else if (!component.predicates.empty()) {
            const auto& p = component.predicates.front();
            for (const auto& edge : edges)
                if (edge.from == p && edge.to == p) { out.push_back(component.predicates); break; }
        }
    }
    return out;
}

void Stratification::compute(const KnowledgeBase& kb) {
    levels_.clear();
    valid_ = true;
    DependencyGraph graph;
    graph.build(kb);
    if (!graph.stratified) { valid_ = false; return; }

    bool changed = true;
    while (changed) {
        changed = false;
        for (const auto& edge : graph.edges) {
            auto from = levels_[edge.from];
            auto to = levels_[edge.to];
            const auto required = to + (edge.negative ? 1U : 0U);
            if (from < required) { levels_[edge.from] = required; changed = true; }
        }
    }
}

std::size_t Stratification::level(const Predicate& p) const {
    auto it = levels_.find(p);
    return it == levels_.end() ? 0 : it->second;
}
bool Stratification::contains(const Predicate& p) const { return levels_.contains(p); }
bool Stratification::valid() const noexcept { return valid_; }

} // namespace alp::analysis
