<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->

# Security

alp-harness has no security boundary and no supported deployment. There is no network service in this repository. The Affero clause applies if you modify the program and run it as a service. This tree does not do that.

## Reporting

Open a GitHub issue on [AHMADALIPARR/alp-harness](https://github.com/AHMADALIPARR/alp-harness) if you have a concrete input that makes a check admit a program the source says it rejects, or reject a program the source says it admits. Include the commit and the input. Do not send credentials, tokens, or private keys. There is nowhere in this repository to put them.

There is no private disclosure channel and no bounty.

## What is in scope

A bug in `certify` that returns `established` for a negative cycle, a head variable that does not occur in a positive body atom, or a function term in a head. A bug in the C++ parser or the range-restriction check in `cpp/alp-graphblas` that accepts an unsafe rule. A license file that adds a second grant.

## What is not a vulnerability

The assembler has not been assembled. A reading of `asm/horn/hornres.asm` is not a demonstrated memory-safety failure. The Prolog queries have not been run. The Lean fragment has not been checked with `lake`. The Curry-labeled files are Haskell 2018 text. The Perl and Crystal stages have not been compiled. The GraphBLAS backend is not built in CI. Absence of those runs is a gap in the tree, not an incident.

`certify` does not reject a function term that appears only in a body. That is the check as written. A report that this should change is a design issue, and it belongs in a pull request with a failing test.
