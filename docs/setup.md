**GTO Flop Generator — Setup

Prerequisites
- Python 3.8+ (Windows: install from python.org)
- Git (optional)

Quick start
1. Open a terminal in the repository root.
2. Create and activate a virtual environment:
```powershell
python -m venv .venv
.\.venv\Scripts\Activate
```
3. Install dependencies if a `requirements.txt` exists:
```powershell
pip install -r requirements.txt
```
4. Run the generator (examples):
```powershell
python src\python\generate_flops.py
python src\python\generate_distinct_flops.py
```

Project layout (important paths)
- `src/python/` — core Python scripts used to generate and validate `.gto` files.
- `templates/` — `.gto` template files used as input for generation.
- `generated/` — generated `.gto` outputs (usually ignored by Git).
- `tools/ahk/` — optional helper AHK scripts used locally for testing.

Notes
- If you plan to publish the package, consider converting `src/python` into a package (`__init__.py`) and adding `pyproject.toml`.
- Add any external Python libraries used to `requirements.txt` so CI and contributors can install them easily.
