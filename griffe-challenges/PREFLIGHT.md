# Submission pre-flight — run BEFORE any review, in this order

Every gate below exists because a reviewer flagged its absence once. Each is
mechanical: run it, fix what it finds, only then submit.

## Gate 1 — Probe before documenting (prevents: Behaviors / spec-describes-a-bug)
For every rule the spec states, write a 5-line probe against the repo FIRST and
document what the code actually does. Never write a spec sentence from memory
of what the solution "should" do.
Caught this session: re-exported member removal was documented as REMOVED while
the code double-counted it as BREAKING+REMOVED; KIND_CHANGED was documented
while the repo already reported kind changes as breakages (dead code).

## Gate 2 — Bidirectional prompt<->test map (prevents: Undocumented Requirement AND Description Quality FAIL)
Build the explicit table both ways:
- every assertion -> the spec sentence licensing it (no sentence = unfair test)
- every spec sentence -> the test enforcing it (no test = removable claim,
  false-positive gap, or over-specification)
Caught this session: annotation-symmetry (tested, undocumented); as_dict keys,
ignore first-segment semantics, --ignore repeatable (documented, untested);
"Change record", "short detail", markdown grouping (documented, untestable
prescriptions -> description FAIL).

## Gate 3 — Divergent-solver run (prevents: Test Fairness FAIL, hidden traps)
Write a second, independent, spec-compliant implementation that makes every
OPPOSITE stylistic choice: different casing, different output layout, different
wording, different internal structure, different loader path. Run the suite
against it. Every failure is either a real spec deviation (fine) or an
over-pinned assertion (fix the test).
Caught this session: counts keyed uppercase while the rest of the API is
lowercase; literal enum-string and first-line pins in renderer tests.

## Gate 4 — Output assertions are token-presence only (prevents: presentation pins)
Rendered/CLI text may be asserted ONLY as case-insensitive presence of
documented tokens (level name, changed paths). Never: line position, exact
strings, bullet shape, empty-stdout on error paths. Error paths assert exit
codes only, unless the message is documented.

## Gate 5 — Public-interface tests only (prevents: implementation coupling)
grep the test file for: `_internal`, `monkeypatch`, `setattr`, private helper
names. Must be zero. To observe side effects (e.g. option forwarding), use the
repo's own public hooks (extensions, callbacks), not spies on internal
functions.

## Gate 6 — Strictest-counter numbers (prevents: LOC/format rejections)
- LOC: count with blanks, comments, imports AND docstrings excluded; 450+ must
  hold under that counter. Never the flattering count.
- problem.md: <=500 words, pure ASCII (byte-check), zero bullets, zero
  headers, natural prose.
- test.patch: test.sh + test files only, zero comments (shebang allowed),
  `new file mode 100755` on test.sh.
- Verify from the JUnit XML itself: base green on clean repo; new suite
  N/N failed with 0 passed without the solution; N/N passed with it.

## Residual risk that no gate removes
Reviewer bots oscillate (one demanded markdown grouping be documented; the next
failed the description FOR documenting it). Budget for at most 1 cleanup round
per challenge; when two bots directly conflict, satisfy the FAIL-issuing one
and keep the WARNING-issuing one advisory.
