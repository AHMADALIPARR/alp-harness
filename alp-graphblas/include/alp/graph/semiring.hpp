#pragma once

namespace alp::graph {

// The Boolean semiring used for reachability: addition is OR, multiplication
// is AND, the additive identity is false and the multiplicative identity is
// true. The ALP/GraphBLAS backend instantiates the same algebra with
// grb::operators::logical_or / logical_and.
struct BooleanSemiringTag {
    static constexpr bool add(bool a, bool b) { return a || b; }
    static constexpr bool mul(bool a, bool b) { return a && b; }
    static constexpr bool zero() { return false; }
    static constexpr bool one() { return true; }
};

}  // namespace alp::graph
