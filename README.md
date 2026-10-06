<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. Licensed under the GNU Affero General Public License version 3 only. -->

# alp-harness

IBM HLASM for z/Architecture. The Python package was removed. It was a string checker, not an assembler and not a resolver.

What is here is the native pipeline start: a lexical scan (`src/lexer/alplex.asm`), a backward-chaining resolver (`src/horn/hornres.asm`), and a sparse semiring vector-matrix step (`src/sparse/vxmexec.asm`). Layouts are in `dsects/layouts.asm`. The calling convention and return codes are in `docs/ABI.md`.

This has not been assembled. It is not a 10,000-line program. Padding it to that count would be the same failure as the Python stub.

Licensed under the GNU Affero General Public License version 3 only.
