#!/usr/bin/env python3
"""
Validate that all grammar_id references used in library/profile files exist
in the canonical syllabus grammar_paths.

Usage:
  python validate_grammar_ids.py \
    --syllabus syllabus.v1.2.json \
    --library class_structure_library.json \
    --profiles profiler_template.json another_student_profile.json

Exit codes:
  0 = ok
  2 = unknown grammar_ids found
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from difflib import get_close_matches
from pathlib import Path
from typing import Any, Iterable, Set, Dict, List, Tuple


GRAMMAR_PREFIX = "grammar_paths."


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as e:
        raise RuntimeError(f"Failed to read JSON from {path}: {e}") from e


def walk_json(obj: Any) -> Iterable[Any]:
    """Yield all values in a JSON-like structure."""
    if isinstance(obj, dict):
        for v in obj.values():
            yield from walk_json(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from walk_json(v)
    else:
        yield obj


def collect_valid_grammar_ids_from_syllabus(syllabus: Any) -> Set[str]:
    """
    Collect grammar IDs by traversing keys under grammar_paths.
    Strategy:
      - Find the "grammar_paths" dict wherever it is.
      - Produce dotted-path IDs for every node and leaf.
    """
    # Find a dict key exactly 'grammar_paths'
    grammar_paths = None

    def find_grammar_paths(node: Any) -> Any | None:
        if isinstance(node, dict):
            if "grammar_paths" in node and isinstance(node["grammar_paths"], dict):
                return node["grammar_paths"]
            for v in node.values():
                found = find_grammar_paths(v)
                if found is not None:
                    return found
        elif isinstance(node, list):
            for v in node:
                found = find_grammar_paths(v)
                if found is not None:
                    return found
        return None

    grammar_paths = find_grammar_paths(syllabus)
    if grammar_paths is None:
        raise RuntimeError("Could not find a 'grammar_paths' object inside the syllabus JSON.")

    valid: Set[str] = set()

    def recurse(d: Any, prefix: str) -> None:
        if isinstance(d, dict):
            for k, v in d.items():
                new_prefix = f"{prefix}{k}"
                # Add node ID
                valid.add(new_prefix)
                # Recurse if nested structure
                if isinstance(v, (dict, list)):
                    recurse(v, new_prefix + ".")
        elif isinstance(d, list):
            # Sometimes a node might contain lists; walk deeper
            for v in d:
                recurse(v, prefix)

    recurse(grammar_paths, GRAMMAR_PREFIX)
    return valid


def extract_grammar_ids(obj: Any) -> Set[str]:
    """
    Extract grammar IDs from known conventions:
      - keys: 'grammar_id', 'grammar_ids', 'g'
      - values can be string or list[str]
    Also catches any string value that starts with 'grammar_paths.' (defensive).
    """
    found: Set[str] = set()

    def add_value(v: Any) -> None:
        if isinstance(v, str) and v.startswith(GRAMMAR_PREFIX):
            found.add(v)
        elif isinstance(v, list):
            for x in v:
                add_value(x)

    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in {"grammar_id", "grammar_ids", "g"}:
                add_value(v)
            # recurse regardless
            found |= extract_grammar_ids(v)
    elif isinstance(obj, list):
        for v in obj:
            found |= extract_grammar_ids(v)
    else:
        if isinstance(obj, str) and obj.startswith(GRAMMAR_PREFIX):
            found.add(obj)

    return found


@dataclass
class ValidationResult:
    used: Set[str]
    valid: Set[str]
    unknown: Set[str]
    suggestions: Dict[str, List[str]]


def validate(used: Set[str], valid: Set[str], suggest_n: int = 3, cutoff: float = 0.75) -> ValidationResult:
    unknown = {gid for gid in used if gid not in valid}
    suggestions: Dict[str, List[str]] = {}
    if unknown:
        valid_list = sorted(valid)
        for bad in sorted(unknown):
            suggestions[bad] = get_close_matches(bad, valid_list, n=suggest_n, cutoff=cutoff)
    return ValidationResult(used=used, valid=valid, unknown=unknown, suggestions=suggestions)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--syllabus", required=True, type=Path)
    ap.add_argument("--library", required=False, type=Path)
    ap.add_argument("--profiles", nargs="*", type=Path, default=[])
    ap.add_argument("--cutoff", type=float, default=0.75, help="Similarity cutoff for suggestions (0-1)")
    args = ap.parse_args()

    syllabus = load_json(args.syllabus)
    valid = collect_valid_grammar_ids_from_syllabus(syllabus)

    used: Set[str] = set()

    # Library file
    if args.library:
        lib = load_json(args.library)
        used |= extract_grammar_ids(lib)

    # Profiles
    for p in args.profiles:
        prof = load_json(p)
        used |= extract_grammar_ids(prof)

    res = validate(used=used, valid=valid, cutoff=args.cutoff)

    print(f"Valid grammar IDs in syllabus: {len(res.valid)}")
    print(f"Grammar IDs referenced (library/profiles): {len(res.used)}")
    print(f"Unknown grammar IDs: {len(res.unknown)}")

    if res.unknown:
        print("\n❌ Unknown IDs found:")
        for bad in sorted(res.unknown):
            sug = res.suggestions.get(bad) or []
            if sug:
                print(f"  - {bad}  (did you mean: {', '.join(sug)})")
            else:
                print(f"  - {bad}")
        return 2

    print("\n✅ All referenced grammar_ids exist in the syllabus.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
