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

## Generate `.gto` files with AutoHotkey (AHK)

Use `tools/ahk/test_file_create.ahk` to automate GTO+ and save one `.gto` file per flop.

### Prerequisites

- AutoHotkey v2 installed.
- GTO+ running (`GTO.exe`) and visible on screen.
- A flop list file (for example `generated/flops_1755.txt`).
- A template file (for example `templates/BTN_vs_BB_SRP_Template.gto`).

### Configure the script

Open `tools/ahk/test_file_create.ahk` and set these variables near the top:

- `templatePath` → full path to your template `.gto` file.
- `filePath` → full path to your flop list (`3` cards per line, e.g. `Ah Kd 7c`).
- `outputDir` → folder where generated `.gto` files should be saved.

The click coordinates are tuned to one UI layout. If your GTO+ window layout/scale differs, adjust coordinate values in the script before running.

### Run

From repo root in PowerShell:

```powershell
& "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" ".\tools\ahk\test_file_create.ahk"
```

### Stop safely

While the script is running, press `Ctrl+Alt+S` to stop it.

## Related docs

- Methodology: `docs/methodology.md`
- Overview and repo layout: `README.md`
