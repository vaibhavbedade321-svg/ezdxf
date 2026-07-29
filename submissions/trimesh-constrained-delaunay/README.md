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

- `problem.md` — problem description, 189 words, ready to paste
- `test.patch` — `test.sh` + `tests/test_delaunay_fe0bc1.py`
- `solution.patch` — `trimesh/triangulation.py` + `trimesh/creation.py` wiring
- `Dockerfile` — build environment

## Size

| Patch | NBNCC lines |
| --- | --- |
| `solution.patch` | 454 |
| `test.patch` | 384 |
| combined | 838 |

Counted as added lines less blank, comment and docstring lines.

## Verification performed

Fresh worktree at the base commit, patches applied with `git apply`:

| State | `./test.sh base` | `./test.sh new` |
| --- | --- | --- |
| `test.patch` only | 61 passed | 23 failed |
| `test.patch` + `solution.patch` | 61 passed | 23 passed |

Both patches pass `git apply --check`. The new suite runs in under 3s, the
base suite in about 30s.

## Why this task is fresh

- No pull request (open, merged or closed) adds a built-in triangulation
  engine; searches for `delaunay` and `triangulate_polygon` return only
  unrelated work.
- Issue #2370, "ValueError: No available triangulation engine!", shows the
  failure this removes is one users actually hit.
- The `engine=` registry, `force_vertices` and the `triangle` engine's `pq30`
  quality flags already exist, so both the engine and its quality targets slot
  into mechanisms the maintainers built.

## Why it is hard

The shortcuts are closed off. The description requires the engine to run on the
required dependencies alone, and one test re-runs it in a subprocess where
`mapbox_earcut`, `manifold3d`, `triangle` and `scipy` are all made
unimportable, so neither an existing engine nor `scipy.spatial.Delaunay` can be
borrowed. Producing a result that is at once an exact cover, free of inserted
vertices, constrained to every ring segment and locally Delaunay everywhere
else requires point insertion, constraint recovery and inside/outside
classification. The quality targets then require Delaunay refinement on top:
encroachment-driven segment splitting, circumcenter insertion, and a walking
point location, since a brute-force search makes refinement quadratic.

## Test coverage

Convex, concave, star and comb polygons; regular polygons where every vertex is
cocircular; one through nine holes; annulus; thin slot holes; collinear edge
vertices; duplicated points; both ring windings; degenerate zero-area input;
extreme scales (1e-4 and 1e6); real CAD geometry from the repository's own DXF
corpus; extrusion to a watertight solid; minimum-angle and maximum-area
refinement including boundary preservation, argument validation, and rejection
of quality targets by the other engines.

## Review responses

- The engine-availability test no longer touches `trimesh.creation._engines`.
  Both isolation tests run in a subprocess which replaces `builtins.__import__`
  so the optional packages raise `ModuleNotFoundError`, and sets
  `sys.modules[name] = None` so `importlib.util.find_spec` reports them as
  missing. Automatic engine selection is therefore exercised purely through the
  public `triangulate_polygon` call. Verified directly: `from scipy.spatial
  import Delaunay` and `import mapbox_earcut` both exit non-zero inside the
  subprocess, while `has_module("mapbox_earcut")` returns False.
- Both quality targets are covered for rejection by the other engines and for
  rejection when paired with `force_vertices`.
- The test file carries an unpredictable suffix,
  `tests/test_delaunay_fe0bc1.py`, so an implementer cannot collide with it.
- The description states the accepted `min_angle` range, that a zero-area
  polygon yields no triangles, and that a coordinate repeated within a ring
  counts as one vertex.
- Every assertion in the suite maps to a clause of the description. The one
  bound that did not (a hard-coded longest-edge limit on a strip polygon) has
  been dropped in favour of the shared invariant check.
- The Dockerfile pins every dependency and performs no project install; the
  package is imported from `/app`. Verified in a clean virtualenv holding only
  those pins.
