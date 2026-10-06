#pragma once
#include "alp/model.hpp"
#include <cstddef>
#include <cstdint>
#include <map>
#include <string>
#include <vector>

namespace alp {

struct ProofNode {
    std::size_t id{0};
    Atom conclusion;
    std::string rule;
    std::vector<std::size_t> parents;
};

class ProvenanceGraph {
    std::vector<ProofNode> nodes_;
    std::map<std::string, std::size_t> by_atom_;
public:
    std::size_t intern(const Atom& atom, std::string rule = "fact");
    void add_edge(std::size_t parent, std::size_t child);
    const ProofNode& node(std::size_t id) const;
    const std::vector<ProofNode>& nodes() const noexcept;
    std::vector<std::size_t> roots() const;
    std::vector<std::size_t> ancestors(std::size_t id) const;
    std::vector<std::size_t> descendants(std::size_t id) const;
    bool acyclic() const;
    std::string canonical_text() const;
};

ProvenanceGraph build_provenance(const Model& model);

} // namespace alp
