<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->

# Foundry components kept from cpp-foundry

Source: [SNAPKITTYWEST/SNAPKITTYWEST cpp-foundry](https://github.com/SNAPKITTYWEST/SNAPKITTYWEST/tree/main/cpp-foundry). The build directory, the NASM SHA-256, and the PIRTM linker were not copied. The upstream README's 17/17 claim was not copied. These files have not been built in this repository.

Kept, because they sit next to a gate and a sparse product:

- `gate` — emission gate, neutrality and beneficence checks, triple-lock
- `certify` — post-step certificate from a step history
- `pmat` — graded sparse matrix, insert rejects a grading violation
- `spectral` — Gershgorin and power-iteration bound before a step
- `recurrence` — bounded iteration
- `audit` and `sha256` — chained hash of an admitted step
- `goldilocks` — field used by the copied tests, not the Horn semiring

`g++ -std=c++20` compiled the kept sources and `src/test.cpp` on this machine and printed 24/24 passed. That run excluded the linker test. It is not a GitHub Actions run.
