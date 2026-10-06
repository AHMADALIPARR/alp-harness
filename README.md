# alp-harness

A constraint harness with two program forms and one checker.

The assembly section is the structured part of IBM's Assembly Language Processor: `IF`/`ELSE`/`ENDIF`, `WHILE`/`ENDWHILE`, and arithmetic. The algebraic lines are the ALP/GraphBLAS idea: a monoid is an associative operator with an identity, a semiring is a pair of those, and `VXM` or `REDUCE` must name a declared one.

The Horn section is definite clauses plus negation as failure. `REQUIRE atom` in the assembly section is accepted only when backward chaining derives that ground atom. A successful resolution is not a proof term, and `not` is not classical negation. Operator laws are a table.

```
HORN
admin(ada, proj).
plan(proj).
can(U, P) :- admin(U, P), plan(P).
ALP
SEMIRING path min-plus
REQUIRE can(ada,proj)
VXM y, x, dist, path
```

```sh
PYTHONPATH=src python -m alp_harness examples/policy.alp
PYTHONPATH=src python -m unittest discover -s tests -v
```

This does not assemble x86 and does not run a sparse matrix kernel.
