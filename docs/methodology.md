**Methodology — GTO Flop Generator**
Purpose
- Provide a clear, reproducible process for generating `.gto` flop files from templates and scripts.

Core principles
- Reproducibility: generation should be deterministic when given the same inputs and configuration.
- Separation of concerns: templates, generation logic, and output are kept in separate folders (`templates/`, `src/python/`, `generated/`).
- Small, testable steps: each script should perform a single responsibility (generate, validate, or post-process).

Workflow
1. Prepare or select a template from `templates/`.
2. Run `generate_flops.py` or `generate_distinct_flops.py` in `src/python/` to generate flop list input files (for example `flops.txt` or `flops_1755.txt`).
3. Use `tools/ahk/test_file_create.ahk` to automate GTO+ with your template and generate one `.gto` file per flop into `generated/` (or your configured output directory).
4. Validate outputs using `gto_file_validate.py` before committing or publishing.

Naming and organization
- Generated files: use consistent, human-readable names (prefix with numeric index or category).
- Templates: include comments and placeholders for variables consumed by generators.
- Examples: keep a small representative set under `examples/` for documentation.

Validation & testing
- Add unit tests for parsers and validators in `tests/`.
- Use sample templates and small generated sets to test end-to-end functionality quickly.

Maintenance
- Keep `requirements.txt` updated for reproducibility.
- Document any algorithmic choices (card ordering, canonicalization rules) in this file.

Contributing
- Open an issue or PR with a clear description and small, focused changes. Provide tests where applicable.
