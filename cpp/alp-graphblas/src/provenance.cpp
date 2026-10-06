#include "alp/provenance.hpp"
#include <algorithm>
#include <sstream>
#include <stdexcept>
#include <functional>
#include <unordered_set>

namespace alp {

std::size_t ProvenanceGraph::intern(const Atom& atom, std::string rule) {
    const auto key = atom.to_string();
    auto it = by_atom_.find(key);
    if (it != by_atom_.end()) return it->second;
    const auto id = nodes_.size();
    nodes_.push_back({id, atom, std::move(rule), {}});
    by_atom_.emplace(key, id);
    return id;
}

void ProvenanceGraph::add_edge(std::size_t parent, std::size_t child) {
    if (parent >= nodes_.size() || child >= nodes_.size()) throw std::out_of_range("provenance node");
    auto& parents = nodes_[child].parents;
    if (std::find(parents.begin(), parents.end(), parent) == parents.end()) parents.push_back(parent);
    std::sort(parents.begin(), parents.end());
}

const ProofNode& ProvenanceGraph::node(std::size_t id) const { return nodes_.at(id); }
const std::vector<ProofNode>& ProvenanceGraph::nodes() const noexcept { return nodes_; }

std::vector<std::size_t> ProvenanceGraph::roots() const {
    std::vector<std::size_t> out;
    for (const auto& node : nodes_) if (node.parents.empty()) out.push_back(node.id);
    return out;
}

std::vector<std::size_t> ProvenanceGraph::ancestors(std::size_t id) const {
    std::vector<std::size_t> out;
    std::unordered_set<std::size_t> seen;
    std::vector<std::size_t> stack{ id };
    while (!stack.empty()) {
        auto current = stack.back(); stack.pop_back();
        if (!seen.insert(current).second) continue;
        if (current != id) out.push_back(current);
        for (auto parent : nodes_.at(current).parents) stack.push_back(parent);
    }
    std::sort(out.begin(), out.end());
    return out;
}

std::vector<std::size_t> ProvenanceGraph::descendants(std::size_t id) const {
    std::vector<std::vector<std::size_t>> children(nodes_.size());
    for (const auto& node : nodes_) for (auto parent : node.parents) children[parent].push_back(node.id);
    std::vector<std::size_t> out;
    std::unordered_set<std::size_t> seen;
    std::vector<std::size_t> stack{ id };
    while (!stack.empty()) {
        auto current = stack.back(); stack.pop_back();
        if (!seen.insert(current).second) continue;
        if (current != id) out.push_back(current);
        for (auto child : children[current]) stack.push_back(child);
    }
    std::sort(out.begin(), out.end());
    return out;
}

bool ProvenanceGraph::acyclic() const {
    enum class Mark { white, gray, black };
    std::vector<Mark> marks(nodes_.size(), Mark::white);
    std::function<bool(std::size_t)> visit = [&](std::size_t id) {
        if (marks[id] == Mark::gray) return false;
        if (marks[id] == Mark::black) return true;
        marks[id] = Mark::gray;
        for (auto parent : nodes_[id].parents) if (!visit(parent)) return false;
        marks[id] = Mark::black;
        return true;
    };
    for (std::size_t i = 0; i < nodes_.size(); ++i) if (!visit(i)) return false;
    return true;
}

std::string ProvenanceGraph::canonical_text() const {
    std::ostringstream out;
    for (const auto& node : nodes_) {
        out << node.id << "|" << node.rule << "|" << node.conclusion.to_string() << "|";
        for (std::size_t i = 0; i < node.parents.size(); ++i) {
            if (i) out << ',';
            out << node.parents[i];
        }
        out << '\n';
    }
    return out.str();
}

ProvenanceGraph build_provenance(const Model& model) {
    ProvenanceGraph graph;
    for (const auto& fact : model.facts) graph.intern(fact, "fact");
    for (const auto& fact : model.abduced) graph.intern(fact, "abduction");
    for (const auto& proof : model.proofs) {
        auto child = graph.intern(proof.conclusion, proof.source);
        for (const auto& premise : proof.premises) {
            auto parent = graph.intern(premise.conclusion, premise.source);
            graph.add_edge(parent, child);
        }
    }
    return graph;
}

} // namespace alp
