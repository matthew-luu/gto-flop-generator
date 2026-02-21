#!/usr/bin/env python3
"""Generate standardized poker solver study folders.

Creates this hierarchy:
    {root}/{POT_TYPE}/{POSITION}/{STACK_DEPTH}/{TREE_CONFIG}/{FLOP_FAMILY}/{TEXTURE_BUCKET}

Additionally:
- Ensures each leaf directory contains a `.gitkeep` file so Git tracks empty folders.
- Never deletes or overwrites existing files.

Examples:
    python generate_study_folders.py
    python generate_study_folders.py --root "./solved" --dry-run
"""

from __future__ import annotations

import argparse
from itertools import combinations_with_replacement
from pathlib import Path
from typing import Iterable

POT_TYPES = ("SRP", "3BP", "4BP")
POSITIONS = (
    # Button open scenarios
    "BTN_vs_SB",
    "BTN_vs_BB",
    # Cutoff open scenarios
    "CO_vs_BTN",
    "CO_vs_SB",
    "CO_vs_BB",
    # Hijack open scenarios
    "HJ_vs_CO",
    "HJ_vs_BTN",
    "HJ_vs_SB",
    "HJ_vs_BB",
    # Lojack / UTG+1 open scenarios
    "LJ_vs_HJ",
    "LJ_vs_CO",
    "LJ_vs_BTN",
    "LJ_vs_SB",
    "LJ_vs_BB",
    # UTG open scenarios
    "UTG_vs_LJ",
    "UTG_vs_HJ",
    "UTG_vs_CO",
    "UTG_vs_BTN",
    "UTG_vs_SB",
    "UTG_vs_BB",
    # Blind vs Blind
    "SB_vs_BB",
)
STACK_DEPTHS = ("100bb",)
TREE_CONFIGS = ("33-66",)
AHML_LEVELS = ("A", "H", "M", "L")
TEXTURE_BUCKETS = ("RB", "TT", "MT")


def build_rank_structures(levels: Iterable[str]) -> list[str]:
    """Return unique 3-card AHML structures using combinations with replacement.

    This yields canonical (deduplicated) patterns such as:
    AAA, AAH, AHM, AHL, HLL, MML, LLL, etc.
    """
    return ["".join(pattern) for pattern in combinations_with_replacement(levels, 3)]


def build_target_paths(root: Path) -> list[Path]:
    rank_structures = build_rank_structures(AHML_LEVELS)
    targets: list[Path] = []

    for pot_type in POT_TYPES:
        for position in POSITIONS:
            for stack_depth in STACK_DEPTHS:
                for tree_config in TREE_CONFIGS:
                    for flop_family in rank_structures:
                        base = root / pot_type / position / stack_depth / tree_config / flop_family
                        for texture in TEXTURE_BUCKETS:
                            targets.append(base / texture)

    return targets


def ensure_gitkeep(folder: Path, dry_run: bool) -> bool:
    """Ensure `.gitkeep` exists inside `folder`.

    Returns True if a new `.gitkeep` was created, otherwise False.
    """
    gitkeep_path = folder / ".gitkeep"

    if gitkeep_path.exists():
        return False

    if dry_run:
        print(f"[DRY-RUN] touch {gitkeep_path}")
        return False

    # Safe: does not overwrite existing files (we checked exists()).
    gitkeep_path.touch(exist_ok=False)
    return True


def create_folders_and_gitkeep(paths: Iterable[Path], dry_run: bool) -> tuple[int, int, int]:
    """Create leaf folders (if missing) and ensure `.gitkeep` in each leaf.

    Returns:
        (folders_created, gitkeeps_created, total_leaf_dirs)
    """
    folders_created = 0
    gitkeeps_created = 0
    total_leaf_dirs = 0

    for folder in paths:
        total_leaf_dirs += 1

        if dry_run:
            print(f"[DRY-RUN] mkdir -p {folder}")
        else:
            if not folder.exists():
                folder.mkdir(parents=True, exist_ok=True)
                folders_created += 1
            # If it exists, we leave it alone (no deletion/moves).

        # Add `.gitkeep` at leaf level regardless; it won't overwrite anything.
        if folder.exists() or dry_run:
            if ensure_gitkeep(folder, dry_run=dry_run):
                gitkeeps_created += 1

    return folders_created, gitkeeps_created, total_leaf_dirs


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate empty standardized poker solver study folder structure (with .gitkeep at leaf level).",
    )
    parser.add_argument(
        "--root",
        default="./solved",
        help='Root folder for generated structure (default: "./solved")',
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print actions without making changes.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root)

    target_paths = build_target_paths(root)
    folders_created, gitkeeps_created, total_leaf_dirs = create_folders_and_gitkeep(
        target_paths, dry_run=args.dry_run
    )

    if args.dry_run:
        print(f"Dry run complete. Leaf folders planned: {total_leaf_dirs}")
    else:
        print(
            f"Leaf folders planned: {total_leaf_dirs} | "
            f"Folders created: {folders_created} | "
            f".gitkeep created: {gitkeeps_created}"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())