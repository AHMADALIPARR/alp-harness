"""Load a program with a Horn section and an assembly section."""

from __future__ import annotations

from alp_harness.assembly import HarnessError, check, parse
from alp_harness.horn import ground_atoms
from alp_harness.horn import parse as parse_horn


def split(source: str) -> tuple[str, str]:
    horn: list[str] = []
    assembly: list[str] = []
    section = "alp"
    for raw in source.splitlines():
        word = raw.strip().upper()
        if word == "HORN":
            section = "horn"
            continue
        if word == "ALP":
            section = "alp"
            continue
        (horn if section == "horn" else assembly).append(raw)
    return "\n".join(horn), "\n".join(assembly)


def run(source: str) -> list[str]:
    horn_source, assembly_source = split(source)
    derived = ground_atoms(parse_horn(horn_source)) if horn_source.strip() else set()
    try:
        return check(parse(assembly_source), derived)
    except HarnessError:
        raise
