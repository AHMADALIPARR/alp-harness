#include "alp/graph/reachability.hpp"
#include "alp/graph/graphblas_backend.hpp"
#include "alp/graph/reference_backend.hpp"
#include <stdexcept>

namespace alp::graph {

bool Reachability::graphblas_available() {
#ifdef ALP_GRAPHBLAS_ENABLED
    return true;
#else
    return false;
#endif
}

std::string Reachability::backend_name() const {
    const bool gb = backend_ == Backend::GraphBLAS || (backend_ == Backend::Auto && graphblas_available());
    return gb ? "alp-graphblas" : "reference";
}

Pairs Reachability::compute(const Graph& g) const {
    if (backend_name() == "alp-graphblas") {
#ifdef ALP_GRAPHBLAS_ENABLED
        return GraphBLASBackend().transitive_closure(g);
#else
        throw std::runtime_error("ALP/GraphBLAS backend requested but not compiled in");
#endif
    }
    return ReferenceBackend().transitive_closure(g);
}

}  // namespace alp::graph
