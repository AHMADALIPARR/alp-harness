"""alp-harness command line."""

from __future__ import annotations

import sys

from alp_harness.assembly import HarnessError
from alp_harness.horn import HornError
from alp_harness.program import run


def main() -> int:
    source = sys.stdin.read() if len(sys.argv) == 1 else open(sys.argv[1], encoding="utf-8").read()
    try:
        notes = run(source)
    except (HarnessError, HornError) as error:
        print(f"REJECT {error}", file=sys.stderr)
        return 1
    print("ACCEPT")
    for note in notes:
        print(note)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
