#pragma once
#include "fixed_point.hpp"

namespace alp::graph {

#ifdef ALP_GRAPHBLAS_ENABLED
// Transitive closure with the ALP/GraphBLAS C++ API: grb::mxm over the Boolean
// semiring (OR, AND), accumulated with grb::eWiseApply over the OR monoid until
// the number of nonzeros stops growing. Manages the ALP runtime itself through
// grb::Launcher<grb::AUTOMATIC>, so it must not be called from inside another
// ALP program. Throws std::runtime_error on any ALP error.
class GraphBLASBackend {
public:
    Pairs transitive_closure(const Graph&) const;
};
#endif

}  // namespace alp::graph
