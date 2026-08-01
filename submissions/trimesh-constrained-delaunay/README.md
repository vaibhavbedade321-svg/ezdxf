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

- `problem.md` — problem description, 190 words, ready to paste
- `test.patch` — `test.sh` + `tests/test_delaunay_fe0bc1.py`
- `solution.patch` — `trimesh/triangulation.py` + `trimesh/creation.py` wiring
- `Dockerfile` — build environment

## Size

| Patch | NBNCC lines |
| --- | --- |
| `solution.patch` | 486 |
| `test.patch` | 652 |
| combined | 1138 |

Counted as added lines less blank, comment and docstring lines.

## Verification performed

Fresh worktree at the base commit, patches applied with `git apply`:

| State | `./test.sh base` | `./test.sh new` |
| --- | --- | --- |
| `test.patch` only | 61 passed | 30 failed |
| `test.patch` + `solution.patch` | 61 passed | 30 passed |

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

## Difficulty

Two requirements carry the difficulty, both stated in the description so no
agent fails on something it was not told.

**The result depends on the polygon, not the input order.** Rotating a ring's
start vertex or reversing its winding has to give the identical triangle set.
An implementation which inserts vertices in the order they arrive picks a
different diagonal on cocircular input, which is exactly what a square or a
regular n-gon is.

**The predicates are exact.** The orientation and circle tests decide cases
that are a rounding error from degenerate, so the suite evaluates the local
Delaunay property in exact arithmetic rather than with a tolerance.

Measured against the suite, an implementation which uses float predicates and
input order — the textbook build — fails `test_annulus`,
`test_independent_of_ring_order`, `test_near_degenerate`,
`test_regular_polygons` and `test_near_collinear`. The annulus is a plain
circle with a hole, so the exactness requirement bites on ordinary geometry
and not only on the contrived cases. At larger coordinate scales float
predicates make the flip loop cycle rather than fail, so those runs hang
instead of finishing.

## Boundary recovery coverage

An adjudication found a candidate which passed the suite while refusing to
triangulate a valid polygon, raising out of its constraint recovery on
`Polygon([(31,7),(15,6),(226,95),(1,1),(3,6),(11,56),(0,-1)])`. The suite had
no polygon which reached that path.

`test_far_flung_vertices` closes it: fourteen valid simple polygons, that one
included, whose vertices are spread over several hundred units while most sit
within a dozen of the origin, each run at three scales. A boundary segment on
these crosses most of the triangulation before it can be recovered, which is
what makes flip based recovery stall. Any implementation which raises, or
which quietly drops a boundary segment, fails the shared invariant check
because it requires every ring segment to survive as an edge.

The reference triangulates all fourteen at every scale, and a sweep of 616
further valid polygons drawn the same way passes with no failures. The
reference's own flip loop now raises rather than giving up quietly if it ever
fails to place a segment, so a stall can never be mistaken for a result.

## Concave and off-origin coverage

A second adjudication found a candidate failing two more prompt-required
cases which the suite never reached.

`test_concave_polygons` covers the first: forty-one valid simple concave
polygons with fractional coordinates, including the reported
`Polygon([(8.467,0.103),(7.625,3.444),(2.417,-9.895),(4.997,-3.292)])`, each
run at two scales. These are everyday shapes where a reflex corner puts one
vertex inside the hull of the others.

`test_refinement_far_from_origin` covers the second: a U-shape, an L-shape and
a square, each translated by nothing, a thousand, a million and ten million,
against four quality targets. Every corner in those shapes is a right angle or
wider, so the targets are reachable without moving the boundary, and a run
which raises has a real defect rather than an impossible request. The gap
between neighbouring floats grows with the coordinates, so a vertex placed
half way along an edge has to land somewhere new even a long way out.

The reference passes all forty-one concave polygons at both scales and all
forty-eight refinement combinations.

## Refinement domain coverage

A third adjudication found a candidate whose area refinement crashed on a
plain triangle, `Polygon([(0,0),(4,0),(0,3)])` with `max_area=1.0`. Every
refinement case in the suite used a rectangle, an L or a U, so the boundary
splitting was never asked to work on a domain with only three sides.

`test_refinement_domain_shapes` widens it from specific shapes to a class:
four triangles, a rectangle, a regular pentagon and hexagon, an L, a big L, a
plus, a square with a hole and a triangle with a triangular hole. Each is
refined to a minimum angle and to two area targets expressed as a fraction of
its own area, thirty-six runs in all.

An area target is always reachable, since any triangle can be cut down
further, which makes it a fair demand on any domain at all. The minimum angle
is set at ten degrees, which every corner in these shapes is wide enough to
allow without the boundary moving. The reference passes all thirty-six.

## Exception type

The suite asserts `ValueError` for a rejected quality target, while the
description previously said only that such cases raise. The description now
names `ValueError`, which is what `triangulate_polygon` already raises for its
existing failure, "No available triangulation engine!", so the type follows
the convention already in the file rather than adding a new one. Naming it
keeps the check meaningful: a solution which returns quietly, or raises
something unrelated to the argument being wrong, still fails.

## Calibration

Four solver runs all failed, and every one of them failed inside refinement or
constraint recovery: area refinement raising on a skinny triangle, recovery
failing on a concave quadrilateral, a duplicate Steiner point on a holed
polygon, and one run timing out on refinement that never converged. None of
them failed on the two requirements the task is actually built around.

The description now states the encroachment rule that keeps refinement
terminating: split a boundary segment at its midpoint when a vertex lies
inside its diametral circle, and split the encroached segment rather than
placing a circumcenter which would fall inside one. That is the standard rule
and it is the piece every run got wrong, so stating it moves the difficulty
back onto exactness and order independence, which stay untouched.

The refinement cases were also thinned from eighty-four combinations to
forty-eight by dropping duplicated target and offset pairings. Every shape and
every offset is still covered, so nothing the earlier adjudications found is
reopened, but a correct implementation which is simply slower than the
reference is no longer at risk of running out of wall clock.

## Revision response

**P6, prescriptive refinement.** The sentence naming midpoint splitting,
diametral circles and circumcenter substitution is gone. The paragraph now
states outcomes only: the targets are met, refinement finishes for any target
in range, an added boundary vertex lies on the boundary it came from, and the
shared edges which are not boundary stay locally Delaunay. Nothing in the
description names an algorithm, so the accompanying obligation to test those
specific steps disappears with it.

**Local Delaunay after refinement.** The refined helper now runs the same
exact circle test as the plain one. A piece of boundary is the only edge used
by a single face, so anything shared by two faces is interior and is checked,
which excludes split boundary subsegments without needing to track them.

**Interior ring invariance.** The exact triangle set is now compared across
every rotation and both windings of a hole ring, crossed with every rotation
of the exterior, rather than only comparing face counts.

**Inclusive angle limit.** `min_angle=30` is accepted and its result checked
against the thirty degree bound, and `min_angle=30.5` is rejected alongside
the existing out-of-range cases.

## Base commit currency

Upstream is ahead of `a513c0e` and has touched `creation.py` in that window.
The overlap is incidental, since adding an engine has to touch the engine
list, and the feature has not shipped upstream. Rebasing onto a newer commit
is possible if wanted; it needs the patches regenerated and the full cycle
rerun, and nothing in the review depends on it.

## Hole boundary preservation

The boundary preservation test used to refine one rectangle and measure every
single-use edge against the exterior ring only, so a refiner which pulled a
hole out of shape had nothing checking it.

It now runs four cases, three of them holed, and measures against
`polygon.boundary`, which covers the interior rings as well as the outside.
Two of the holed cases are chosen so refinement has to cut the hole ring up:
the count of boundary edges lying on a hole comes out higher than the number
of segments the hole started with, which is only possible if the added
vertices landed on the hole itself rather than beside it. The remaining cases
assert the weaker form, that the hole is still walled off by at least as many
boundary edges as it had segments.
