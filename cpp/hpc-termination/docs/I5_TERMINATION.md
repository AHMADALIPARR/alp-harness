<!-- SPDX-License-Identifier: AGPL-3.0-only -->
<!-- Copyright (C) 2026 Ahmad Ali Parr. GNU Affero General Public License version 3 only. -->
<!-- From SNAPKITTYWEST/alp-harness pull request 1, hpc-termination-v0.1.tar.gz. -->

# HPC I5 — Termination

## Normative statement

The selected evaluation strategy terminates for the compiled query. I5 is a property of the `(program, query-plan)` pair. A planner may emit a terminating plan only when it can produce a termination certificate.

## Certificates

```text
NonRecursive { strata, topo_order }
Stratified   { strata, finite-domain bound }
Rejected     { reason }
```

## R1 — finite non-recursive evaluation

The predicate dependency graph is condensed into SCCs. If every SCC is a singleton without a self-loop, evaluation is topological and finite over finite relations.

## R2 — positive recursion

For positive Horn/Datalog recursion, HPC requires a finite active domain and range restriction. Evaluation is monotone:

```text
I0 = EDB
I(n+1) = I(n) union T_P(I(n))
```

and terminates at the least fixed point. The Herbrand-base cardinality supplies a conservative iteration bound.

Semi-naive evaluation may optimize the process without changing semantics.

## R3 — stratified negation

Signed predicate dependencies are stratified when no SCC contains a negative edge. Strata satisfy:

```text
positive: s(head) >= s(body)
negative: s(head) >  s(body)
```

Each stratum is evaluated to a positive fixed point before the next stratum.

## R4 — no certificate, no TRUE

Failure to establish termination is never converted to TRUE. The planner rejects the plan or the execution result is UNKNOWN according to the caller's verdict policy.

## Security/correctness boundary

This subrepo certifies the *evaluation strategy*, not arbitrary runtime behavior. Resource exhaustion, backend failures, or external-system nondeterminism remain execution-layer obligations.
