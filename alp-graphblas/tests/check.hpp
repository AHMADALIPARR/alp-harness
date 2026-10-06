#pragma once
// Minimal test helpers. CHECK stays active in Release builds (unlike assert).
#include "alp/atom.hpp"
#include "alp/term.hpp"
#include <cstdint>
#include <iostream>
#include <set>
#include <string>
#include <vector>

namespace alp_test {

inline int failures = 0;

#define CHECK(cond)                                                                      \
    do {                                                                                 \
        if (!(cond)) {                                                                   \
            std::cerr << __FILE__ << ":" << __LINE__ << ": CHECK failed: " #cond "\n";   \
            ++alp_test::failures;                                                        \
        }                                                                                \
    } while (0)

#define CHECK_THROWS(expr, ExceptionType)                                                \
    do {                                                                                 \
        bool thrown_ = false;                                                            \
        try {                                                                            \
            (void)(expr);                                                                \
        } catch (const ExceptionType&) {                                                 \
            thrown_ = true;                                                              \
        } catch (...) {                                                                  \
        }                                                                                \
        if (!thrown_) {                                                                  \
            std::cerr << __FILE__ << ":" << __LINE__ << ": expected " #ExceptionType " from " #expr "\n"; \
            ++alp_test::failures;                                                        \
        }                                                                                \
    } while (0)

inline int finish(const char* name) {
    if (failures) {
        std::cerr << name << ": " << failures << " check(s) FAILED\n";
        return 1;
    }
    std::cout << name << ": all checks passed\n";
    return 0;
}

inline alp::Term V(const char* n) { return alp::Term::variable(n); }
inline alp::Term C(const char* n) { return alp::Term::constant(n); }
inline alp::Term F(const char* n, std::vector<alp::Term> args) { return alp::Term::compound(n, std::move(args)); }
inline alp::Atom A(const char* n, std::vector<alp::Term> args = {}) {
    return alp::Atom{alp::Predicate{n, args.size()}, std::move(args)};
}

inline std::set<std::string> keys(const std::vector<alp::Atom>& atoms) {
    std::set<std::string> out;
    for (const auto& a : atoms) out.insert(alp::to_string(a));
    return out;
}

// Deterministic pseudo-random numbers (no dependence on the standard library's distributions).
struct Rng {
    std::uint64_t state;
    explicit Rng(std::uint64_t seed) : state(seed * 6364136223846793005ULL + 1442695040888963407ULL) {}
    std::uint64_t next() {
        state = state * 6364136223846793005ULL + 1442695040888963407ULL;
        return state >> 33;
    }
    std::size_t below(std::size_t n) { return static_cast<std::size_t>(next() % n); }
};

}  // namespace alp_test
