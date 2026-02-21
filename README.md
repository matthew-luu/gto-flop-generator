# GTO Flop Generator

Utilities for generating Texas Hold'em flop combinations and suit-isomorphic canonical flops for GTO+ workflows.

This repository contains tooling and templates only. It does **not** include proprietary solver outputs.

## What this repo does

- Generates all raw flop combinations from a 52-card deck (`22,100` total).
- Generates canonical (suit-isomorphic) flops (`1,755` total).
- Generates a standardized solver study folder tree with leaf-level `.gitkeep` files.
- Provides a validator for `.gto` file sets (duplicate checks + count sanity check).
- Includes a sample GTO+ template and small AutoHotkey helper scripts.

## Repository layout

- `src/python/`
	- `generate_flops.py` — writes all raw flops to `flops.txt`.
	- `generate_distinct_flops.py` — writes canonical flops to `flops_1755.txt`.
	- `generate_study_folders.py` — creates standardized study folders (with `.gitkeep` in leaf directories).
	- `gto_file_validate.py` — validates `.gto` files in a folder.
- `templates/`
	- `BTN_vs_BB_SRP_Template.gto` — template example.
- `generated/`
	- Example generated outputs (`flops.txt`, `flops_1755.txt`).
- `tools/ahk/`
	- Optional local AutoHotkey utility scripts.
- `docs/`
	- Additional setup and methodology notes.

## Requirements

- Python 3.8+ (Windows-friendly scripts; no external Python dependencies required).

## Quick start (Windows PowerShell)

From the repository root:

```powershell
python .\src\python\generate_flops.py
python .\src\python\generate_distinct_flops.py
python .\src\python\generate_study_folders.py
```

## Generate study folder tree

`generate_study_folders.py` creates this leaf directory hierarchy under the selected root:

`{root}/{POT_TYPE}/{POSITION}/{STACK_DEPTH}/{TREE_CONFIG}/{FLOP_FAMILY}/{TEXTURE_BUCKET}`

Defaults and options:

- Default root: `./solved`
- `--root <path>` to write elsewhere
- `--dry-run` to print planned actions without making changes

Examples:

```powershell
python .\src\python\generate_study_folders.py
python .\src\python\generate_study_folders.py --root .\generated\study-tree --dry-run
```

Behavior notes:

- Creates folders only if missing.
- Ensures `.gitkeep` exists in each leaf folder.
- Never deletes or overwrites existing files.

## Output behavior

The generator scripts currently write output files to the **current working directory**.

- If run from repo root, outputs are created in repo root.
- If you want files under `generated/`, run from that folder:

```powershell
Push-Location .\generated
python ..\src\python\generate_flops.py
python ..\src\python\generate_distinct_flops.py
Pop-Location
```

## Validate a `.gto` folder

`gto_file_validate.py` scans `.gto` files in `FOLDER` (default: current directory), checks:

- exact duplicate filenames,
- logical duplicates when ignoring numeric prefix,
- optional count check against `EXPECTED_COUNT` (default `1755`).

Example:

```powershell
Push-Location .\generated
python ..\src\python\gto_file_validate.py
Pop-Location
```

To validate another folder, edit `FOLDER` in `src/python/gto_file_validate.py`.

## Notes

- Canonicalization in `generate_distinct_flops.py` normalizes suit isomorphisms and emits a stable sorted list.
- The repo intentionally separates templates, generation logic, and generated artifacts.

## Documentation

- Setup notes: `docs/setup.md`
- Methodology: `docs/methodology.md`

## License

See `LICENSE`.
