#pragma once
#include "alp/knowledge_base.hpp"
#include <cstddef>
#include <map>
#include <set>
#include <string>
#include <vector>

namespace alp::analysis {

struct PredicateDependency {
    Predicate from;
    Predicate to;
    bool negative{false};
};

struct StrongComponent {
    std::size_t id{0};
    std::vector<Predicate> predicates;
};

struct DependencyGraph {
    std::vector<Predicate> predicates;
    std::vector<PredicateDependency> edges;
    std::vector<StrongComponent> components;
    bool stratified{true};
    std::map<Predicate, std::size_t, bool(*)(const Predicate&, const Predicate&)> component_of;

    DependencyGraph();
    void build(const KnowledgeBase& kb);
    const StrongComponent* component(const Predicate& p) const;
    std::vector<Predicate> dependencies(const Predicate& p, bool include_negative = true) const;
    std::vector<Predicate> dependents(const Predicate& p, bool include_negative = true) const;
    bool has_negative_cycle() const;
    std::vector<std::vector<Predicate>> cycles() const;
};

class Stratification {
    std::map<Predicate, std::size_t, bool(*)(const Predicate&, const Predicate&)> levels_;
    bool valid_{true};
public:
    Stratification();
    explicit Stratification(const KnowledgeBase& kb);
    void compute(const KnowledgeBase& kb);
    std::size_t level(const Predicate& p) const;
    bool contains(const Predicate& p) const;
    bool valid() const noexcept;
    const auto& levels() const noexcept { return levels_; }
};

} // namespace alp::analysis
