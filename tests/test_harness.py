import unittest

from alp_harness.assembly import HarnessError, check, parse
from alp_harness.horn import parse as parse_horn
from alp_harness.horn import solve
from alp_harness.horn import Atom
from alp_harness.program import run


class AssemblyTest(unittest.TestCase):
    def test_shortest_path_accepts(self) -> None:
        notes = check(parse(open("examples/shortest.alp", encoding="utf-8").read()))
        self.assertTrue(any("min-plus" in note for note in notes))

    def test_subtraction_is_not_a_monoid(self) -> None:
        with self.assertRaises(HarnessError):
            check(parse(open("examples/bad.alp", encoding="utf-8").read()))


class HornTest(unittest.TestCase):
    def test_rule_fires_for_the_matching_constants(self) -> None:
        clauses = parse_horn("admin(ada, proj).\nplan(proj).\ncan(U, P) :- admin(U, P), plan(P).\n")
        self.assertTrue(solve(clauses, Atom("can", ("ada", "proj"))))
        self.assertFalse(solve(clauses, Atom("can", ("ada", "other"))))

    def test_negation_as_failure_is_not_classical(self) -> None:
        clauses = parse_horn("blocked(ada).\nopen(U) :- not(blocked(U)).\n")
        self.assertFalse(solve(clauses, Atom("open", ("ada",))))
        self.assertTrue(solve(clauses, Atom("open", ("bea",))))


class ProgramTest(unittest.TestCase):
    def test_require_uses_a_derived_atom(self) -> None:
        notes = run(open("examples/policy.alp", encoding="utf-8").read())
        self.assertTrue(any("required can(ada,proj)" in note for note in notes))

    def test_underived_require_rejects(self) -> None:
        with self.assertRaises(HarnessError):
            run("HORN\nadmin(ada, proj).\nALP\nREQUIRE can(ada,proj)\n")


if __name__ == "__main__":
    unittest.main()
