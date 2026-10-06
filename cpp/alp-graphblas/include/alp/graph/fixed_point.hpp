#pragma once
#include "graph.hpp"
#include <cstddef>
#include <utility>
#include <vector>

namespace alp::graph {

using Pairs = std::vector<std::pair<std::size_t, std::size_t>>;

// Transitive closure A+ by semi-naive iteration over the Boolean semiring:
//   R0 = A,  delta0 = A,  delta(k+1) = (delta(k) * A) \ R(k),  R(k+1) = R(k) + delta(k+1)
// until delta is empty. Result is sorted by (row, column). This is the plain
// C++ counterpart of the iteration the ALP backend performs with grb::mxm.
Pairs closure_by_fixed_point(const Graph&);

}  // namespace alp::graph
