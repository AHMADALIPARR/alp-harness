# ALP/GraphBLAS Horn-Clause Runtime

Production-oriented C++ runtime for Horn-clause logic, abductive hypotheses, integrity constraints, negation as failure, and graph predicates lowered to the real ALP/GraphBLAS API.

## Build and test

ALP is optional. Without it the graph layer uses a built-in reference closure, which is also the oracle the ALP backend is tested against.

```sh
# logic + reference graph backend only
cmake -S . -B build -DALP_GRAPHBLAS_ENABLE=OFF
cmake --build build -j && ctest --test-dir build --output-on-failure

# with ALP/GraphBLAS (ALP_ROOT is an *install* root: include/graphblas.hpp,
# lib/libalp_utils, lib/sequential/libgraphblas)
cmake -S . -B build -DALP_ROOT=/path/to/alp-install -DALP_GRAPHBLAS_ENABLE=ON
cmake --build build -j && ctest --test-dir build --output-on-failure
```

At runtime add `lib/sequential` and `lib` of the ALP install to `LD_LIBRARY_PATH`.
Verified: 7/7 tests without ALP, 8/8 with ALP (reference backend, `grbcxx -b reference` flags).

## CLI

```sh
alp [--query ATOM] [--abduce ATOM] [--all] [--proof] [--graph]
    [--backend auto|reference|graphblas] [--demo] FILES...
```

Programs live in `alp/library` (graph, reasoning, defaults, constraints, agents) and `alp/examples`.

## Modules

- `alp_logic`: terms, unification, parser, knowledge base validation (range restriction), stratification, semi-naive bottom-up evaluation, SLD resolution with tabling, abduction, integrity constraints, provenance, serialization.
- `alp_graph`: graph model, CSR adjacency, reachability backends, predicate bridge (`node/1`, `edge/2`, `connected/2`, `reachable/2`, `path/2`), DOT/edge-list/MatrixMarket export.

## Semantics

`P`, `A`, and `IC` are separate: Horn rules derive facts; abducibles are hypotheses considered by the abductive solver (all or subset-minimal explanations); integrity constraints (`false <- body`) reject candidate models. Negation-as-failure requires a stratified program; negation through recursion is rejected. Facts must be ground and rules safe.

`connected/2` is the symmetric closure of `edge/2`; `reachable/2` and `path/2` are directed. `maximum_answers` caps answers per resolution call.

## GraphBLAS backend

Transitive closure uses the ALP/GraphBLAS C++ API: `grb::Matrix<bool>`, `buildMatrixUnique`, and `grb::mxm` over a Boolean (OR, AND) semiring, iterated to a fixed point inside a `grb::Launcher`. ALP's matrix `eWiseApply` is element-wise rather than a union, so `R ∪ R·A` is accumulated on the host and R is rebuilt each round. Results are checked against the reference closure on random graphs.

No LLM, probabilistic inference, embeddings, or RAG is used.

## License

Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0). See [LICENSE](LICENSE).

Copyright 2026 SnapKitty Collective
