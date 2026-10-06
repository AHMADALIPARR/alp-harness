<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->

# Contributing

This is the development tree of alp-harness. It is not a release, and it is not a verified compiler. A pull request is useful when it changes a check that already exists, or adds a check together with a case that fails before the change and passes after it.

The license is the GNU Affero General Public License version 3 only. A contribution is made under that grant. Do not add a second license file. Do not add a Python file. The tree check rejects `.py`.

## What has been run

The reference C++ tests in `cpp/alp-graphblas` have completed on GitHub Actions with `ALP_GRAPHBLAS_ENABLE=OFF`. That job does not build ALP/GraphBLAS, the assembler, the Prolog, the Lean fragment, the Curry-labeled Haskell, the Perl IR, or the Crystal fixpoint.

`cpp/hpc-termination` is the I5 certificate package from SNAPKITTYWEST pull request 1. Its tests are `cpp/hpc-termination/tests/test_termination.cpp`. They have not been run in the commit that added the edge cases. Run them before treating a certificate change as done:

```sh
cmake -S cpp/hpc-termination -B build/hpc
cmake --build build/hpc
ctest --test-dir build/hpc --output-on-failure
```

## What a change may say

Say what the source does. Say which command was run, and on which commit. Do not call a `native_decide` equation a proof of `prolog/dialogue/dialog_kb.pl`. Do not call the Kahn sort in `curry/Stratified.hs` an evaluation of `gt`. Do not call the assembler assembled. Do not call the reference closure a GraphBLAS result.

A termination certificate from `certify` is a rejection or an admission under the checks in `cpp/hpc-termination/src/termination.cpp`. It is not a proof that a bottom-up engine terminates on every input. A function term that appears only in a rule body is not rejected. That is the current rule. A test that records it is a regression test, not a claim that the rule is the one you want.

## Reporting a bug

Open a GitHub issue. Include the command, the commit, and the input that fails. A certificate bug needs the `Program` that was passed to `certify` and the `reason` string that came back. A parser bug needs the `.alp` text. An assembler bug cannot be confirmed here: there is no assembler in this workspace.

## A pull request

Keep the change in the directory that owns it.

| Change | Directory |
| --- | --- |
| Horn runtime, parser, graph | `cpp/alp-graphblas/` |
| I5 certificate | `cpp/hpc-termination/` |
| Assembler | `asm/`, `jcl/` |
| Agent kernel, dialogue | `prolog/` |
| Speech-act fragment | `lean/` |
| Curry-labeled checkers | `curry/` |
| Perl IR, Crystal fixpoint | `compiler/ir/`, `compiler/aot/` |

Add a test that fails on the old source. Do not add a test that returns success without reading the result. Do not pad a file to a line count. Do not leave `TODO`, `FIXME`, or `NOT_IMPLEMENTED` on a path the test calls.

The C++ standard for `cpp/alp-graphblas` is C++20. The certificate package is C++17. Do not mix those requirements in one target.

## How to add a certificate test

Put the case in `cpp/hpc-termination/tests/test_termination.cpp` and call it from `main`. Assert `established`, `kind`, and `reason` when the reason is part of the contract. The reasons the source emits are `UnstratifiedProgram`, `InfiniteHerbrandUniverse`, `InfiniteHerbrandUniverse(<rule id>)`, and `UnsafeOrUngroundedRule`. A new reason needs the test and the branch that produces it in the same change.

Build with the commands above. If the build is not available, say so in the pull request. Do not write that the tests passed.
