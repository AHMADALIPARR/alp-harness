#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (C) 2026 Ahmad Ali Parr
# Runs the stages this tree can compile without ALP, GHC, Crystal, Lean, or SWI-Prolog.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
echo "perl ancestor"
perl "$root/compiler/ir/lower.pl" < "$root/compiler/ir/ancestor.ir"
echo "compiled C++ suites are built by the caller; this script checks the IR fixture"
test -s "$root/compiler/ir/ancestor.ir"
echo "fixture present"
