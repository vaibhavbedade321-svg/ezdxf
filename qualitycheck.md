
# Code Quality Reference Checklist

When implementing new features or making multi-file modifications to this repository, run the following strict quality controls.

## 1. Unused Variables & Imports (Flake8)
Zero Unused Variables and Zero Unused Imports. Verify with Flake8 targeting `F401` (imports) and `F841` (local variables).

```bash
python -m flake8 <modified_files> --select=F401,F841
```
*Expected Output*: Empty (0 matches).

## 2. Hardcoding Check
Zero magic numbers in algorithm loops or core data structures.
- Replace literals (e.g., `+ 1e-10`, fixed shape dimensions) with class constants, config arguments (`self._epsilon`), or math expressions (`math.inf`).

## 3. Redundancy and Dead Code
- **Redundant Blocks**: Consolidate overlapping conditionals. Use structured boolean logic to split execution paths cleanly.
- **Dead Methods**: Purge methods with no callers within the framework or test suite. No "just-in-case" code.

## 4. Test Decoupling
- Test against **public API boundaries**, not internal state variables.
- Do not test internal arrays (`_tree`, `_n_step_buffers`). Test integration behavior (`tree.sample()`, `memory.get_sampling_weights()`).
- New components must work as drop-in replacements where generic components were used prior (backward compatibility).

## 5. Codebase Style Consistency
Match the conventions of the existing codebase:
- **Constructor signatures**: Use keyword-only args (`*`) if the base class and sibling classes use them.
- **Type annotations**: Use the same style as the rest of the codebase (modern `X | None` vs older `Optional[X]`). Check what `from __future__ import annotations` enables.
- **Docstrings**: If existing classes in the module have `:param`/`:return` docstrings, all new public classes and methods must too. Keep them simple and natural — avoid unnecessarily fancy language.
- **Context managers**: Place related operations inside the same context scope (e.g. IS weight application inside `torch.autocast` if sibling agents do the same).

