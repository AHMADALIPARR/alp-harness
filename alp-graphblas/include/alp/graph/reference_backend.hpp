#pragma once
#include "fixed_point.hpp"

namespace alp::graph {

// Dependency-free transitive closure. It is the fallback when the library is
// built without ALP (-DALP_GRAPHBLAS_ENABLE=OFF) and the oracle that the test
// suite compares the ALP/GraphBLAS backend against. It is not a replacement
// for the ALP backend in production builds.
class ReferenceBackend {
public:
    Pairs transitive_closure(const Graph& g) const { return closure_by_fixed_point(g); }
};

}  // namespace alp::graph
