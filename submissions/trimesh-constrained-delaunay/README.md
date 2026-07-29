# Submission: built-in constrained Delaunay triangulation engine (trimesh)

| Field | Value |
| --- | --- |
| Repo | https://github.com/mikedh/trimesh |
| Commit | `a513c0e2cfa6dfbd3121a6dfd8ceb002b9ef55d8` (2026-06-24) |
| Language | Python |
| Category | Enhancement |
| License | MIT |
| Stars | 3.6k |

## Files

- `problem.md` — problem description (paste into the description field)
- `test.patch` — `test.sh` + `tests/test_delaunay.py`
- `solution.patch` — `trimesh/triangulation.py` + `trimesh/creation.py` wiring
- `Dockerfile` — build environment

## Solution size

286 effective lines (449 added lines less 50 blank, 14 comment, 99 docstring).

## Verification performed

Clean worktree at the base commit, patches applied with `git apply`:

| State | `./test.sh base` | `./test.sh new` |
| --- | --- | --- |
| `test.patch` only | 61 passed | 15 failed |
| `test.patch` + `solution.patch` | 61 passed | 15 passed |

Both patches apply cleanly with `git apply --check`.

## Why this task is fresh

- No pull request (open, merged or closed) adds a built-in triangulation
  engine; searches for `delaunay` and `triangulate_polygon` turn up only
  unrelated work.
- Issue #2370, "ValueError: No available triangulation engine!", shows the
  failure this removes is one users actually hit.
- The `engine=` registry and the `force_vertices` argument already exist, so
  the addition slots into a mechanism the maintainers built.

## Why it is hard

The obvious shortcuts are closed off. The description requires the engine to
run on the required dependencies alone, and one test re-runs the engine in a
subprocess where `mapbox_earcut`, `manifold3d`, `triangle` and `scipy` are all
made unimportable, so neither an existing engine nor `scipy.spatial.Delaunay`
can be borrowed. Producing a triangulation that is simultaneously exact in
coverage, free of inserted vertices, constrained to every ring segment, and
locally Delaunay everywhere else means implementing point insertion, constraint
recovery and inside/outside classification.

## Test coverage

Convex, concave, star and comb polygons; regular polygons where every vertex is
cocircular; one through nine holes; annulus; thin slot holes; collinear edge
vertices; duplicated points; both ring windings; degenerate zero-area input;
extreme scales (1e-4 and 1e6); real CAD geometry from the repository's own DXF
corpus; extrusion of the result to a watertight solid.
