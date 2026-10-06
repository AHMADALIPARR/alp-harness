<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->
<!-- From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz. -->

# HPC — Horn Predicate Compiler / I5 Termination Subrepo

This subrepo implements the normative I5 termination certification layer for the Horn Predicate Compiler.

## Implemented

- Signed predicate dependency graph
- Tarjan SCC decomposition
- Negative-cycle detection
- Stratification
- Non-recursive topological plans
- Active-domain extraction
- Herbrand-base bound calculation
- Range-restriction checks
- Function-term fresh-generation rejection
- NonRecursive / Stratified / Rejected certificates
- Planner-facing termination result
- Tests for the running example, positive recursion, negative cycles, function generation, and unsafe rules

## Build

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

## Run

```sh
./build/hpc-termination
```

## Design rule

`TRUE` is unreachable from this component unless `certify()` establishes a termination certificate. This component does not silently repair an invalid program.

## Scope

This is a termination-certification subrepo, not the complete HPC compiler. Parsing, Horn execution, SQL, GraphBLAS, SMT, proof closure, and verdict aggregation belong to their respective HPC components.
