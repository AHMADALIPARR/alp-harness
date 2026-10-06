#pragma once
#include <compare>
#include <cstddef>
#include <string>

namespace alp {

struct Predicate {
    std::string name;
    std::size_t arity{};

    bool operator==(const Predicate&) const = default;
    auto operator<=>(const Predicate&) const = default;
};

inline std::string to_string(const Predicate& p) { return p.name + "/" + std::to_string(p.arity); }

}  // namespace alp
