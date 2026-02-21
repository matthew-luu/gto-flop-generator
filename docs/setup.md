# GTO Flop Generator — Setup

## Prerequisites

- Python 3.8+ installed and available in `PATH`.

No external Python dependencies are required for the current scripts.

## Quick start (Windows PowerShell)

From the repository root:

```powershell
python .\src\python\generate_flops.py
python .\src\python\generate_distinct_flops.py
```

## Output location behavior

The generator scripts write to the current working directory.

- Running from repo root creates `flops.txt` and `flops_1755.txt` in repo root.
- To place outputs under `generated/`, run from that folder:

```powershell
Push-Location .\generated
python ..\src\python\generate_flops.py
python ..\src\python\generate_distinct_flops.py
Pop-Location
```

## Validate `.gto` files

Run the validator in the folder you want to scan:

```powershell
Push-Location .\generated
python ..\src\python\gto_file_validate.py
Pop-Location
```

`gto_file_validate.py` checks:

- exact duplicate filenames,
- logical duplicate board names (ignoring numeric prefix),
- count against `EXPECTED_COUNT` (default `1755`).

To scan another folder path, edit `FOLDER` in `src/python/gto_file_validate.py`.

## Related docs

- Methodology: `docs/methodology.md`
- Overview and repo layout: `README.md`
