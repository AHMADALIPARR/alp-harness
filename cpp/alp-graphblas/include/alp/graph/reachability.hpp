#pragma once
#include "fixed_point.hpp"
#include "graph.hpp"
#include <string>

namespace alp::graph {

enum class Backend {
    Auto,       // ALP/GraphBLAS when the library was built with it, otherwise Reference
    Reference,  // dependency-free C++ closure (fallback and test oracle)
    GraphBLAS,  // ALP/GraphBLAS; throws std::runtime_error if not compiled in
};

// Transitive closure of the edge relation: (i, j) is returned iff there is a
// path of one or more edges from i to j. The result is sorted by (i, j).
class Reachability {
    Backend backend_;

public:
    explicit Reachability(Backend b = Backend::Auto) : backend_(b) {}

    Pairs compute(const Graph&) const;

    static bool graphblas_available();
    std::string backend_name() const;
};

}  // namespace alp::graph
