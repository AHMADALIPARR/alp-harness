#include "alp/graph/graphblas_backend.hpp"
#include <graphblas.hpp>
#include <algorithm>
#include <memory>
#include <stdexcept>
#include <string>

namespace alp::graph {

namespace {

struct ClosureJob {
    const Graph* graph = nullptr;
    Pairs result;
    std::string error;
};

using BoolRing = grb::Semiring<grb::operators::logical_or<bool>, grb::operators::logical_and<bool>,
                               grb::identities::logical_false, grb::identities::logical_true>;

void check(grb::RC rc, const char* what) {
    if (rc != grb::SUCCESS)
        throw std::runtime_error(std::string("ALP/GraphBLAS ") + what + " failed: " + grb::toString(rc));
}

grb::Matrix<bool> adjacency(std::size_t n, const std::vector<std::size_t>& I,
                            const std::vector<std::size_t>& J) {
    grb::Matrix<bool> M(n, n, I.size());
    // plain array: std::vector<bool> has no addressable elements
    std::unique_ptr<bool[]> vals(new bool[I.size()]);
    std::fill_n(vals.get(), I.size(), true);
    check(grb::buildMatrixUnique(M, I.data(), J.data(), vals.get(), I.size(), grb::SEQUENTIAL),
          "adjacency construction");
    return M;
}

void closure_program(const ClosureJob& in, ClosureJob& out) {
    try {
        const Graph& g = *in.graph;
        const std::size_t n = g.index().size();
        if (n == 0 || g.edges().empty()) return;

        std::vector<std::size_t> I, J;
        for (const auto& e : g.edges()) {
            I.push_back(e.source);
            J.push_back(e.target);
        }

        const grb::Matrix<bool> A = adjacency(n, I, J);
        const BoolRing ring;

        // Reachable set so far, kept host-side as a sorted unique pair list.
        // ALP's matrix eWiseApply is element-wise (intersecting), not a union,
        // so R + R*A is formed on the host and R is rebuilt each round.
        Pairs reach;
        for (std::size_t k = 0; k < I.size(); ++k) reach.emplace_back(I[k], J[k]);
        std::sort(reach.begin(), reach.end());
        reach.erase(std::unique(reach.begin(), reach.end()), reach.end());

        for (;;) {
            std::vector<std::size_t> RI, RJ;
            for (const auto& p : reach) { RI.push_back(p.first); RJ.push_back(p.second); }
            const grb::Matrix<bool> R = adjacency(n, RI, RJ);

            grb::Matrix<bool> step(n, n, 1);  // R * A, sized by the RESIZE phase
            check(grb::mxm(step, R, A, ring, grb::RESIZE), "mxm (resize)");
            check(grb::mxm(step, R, A, ring, grb::EXECUTE), "mxm");

            Pairs merged = reach;
            for (const auto& nz : step) merged.emplace_back(nz.first.first, nz.first.second);
            std::sort(merged.begin(), merged.end());
            merged.erase(std::unique(merged.begin(), merged.end()), merged.end());

            const bool converged = merged.size() == reach.size();
            reach = std::move(merged);
            if (converged) break;
        }

        out.result = std::move(reach);
        return;
    } catch (const std::exception& e) {
        out.error = e.what();
    }
}

}  // namespace

Pairs GraphBLASBackend::transitive_closure(const Graph& g) const {
    ClosureJob in, out;
    in.graph = &g;
    grb::Launcher<grb::AUTOMATIC> launcher;
    const grb::RC rc = launcher.exec(&closure_program, in, out, false);
    if (rc != grb::SUCCESS)
        throw std::runtime_error(std::string("ALP/GraphBLAS launch failed: ") + grb::toString(rc));
    if (!out.error.empty()) throw std::runtime_error(out.error);
    return std::move(out.result);
}

}  // namespace alp::graph
