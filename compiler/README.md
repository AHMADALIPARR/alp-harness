<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->

# Compiler pipeline

Three stages, not wired to `cpp/alp-graphblas` or the assembler.

- `verify/Horn.hs` checks arity, head shape, range restriction, and defined predicates, then emits `RULE` lines. The demo program is `edge` and `path`.
- `verify/HornReingest.hs` is the parent, father, and ancestor program, with the ancestor base clause present.
- `verify/Stratified.hs` checks the temperature, fan, overheated, and dangerous program. `gt` is a builtin. A dependency cycle fails verification. It does not evaluate `gt`.
- `ir/lower.pl` reads those `RULE` lines, runs a bounded bottom-up fixpoint, and writes `target.json`.
- `aot/synthesize.cr` reads `target.json` and repeats the fixpoint. The fiber version in the paste was not added: it mutated one hash from several fibers and also ran a second sequential loop.

The incomplete tabled engine, with `evaluate` returning an empty list, was not added.

None of these files has been compiled or run in this repository.

The I5 termination package from SNAPKITTYWEST pull request 1 is `cpp/hpc-termination/`. It is a separate CMake project. It has not been built here.
