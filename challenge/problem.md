# ezdxf: Robust 2D Polygon Buffer (Inflate / Deflate)

## Goal

Add a new module `ezdxf.math.buffer` that implements a robust polygon
offset / buffer operation for closed 2D polygons. The existing
`ezdxf.math.offset_vertices_2d` helper produces only an unclosed,
self-intersecting offset polyline with sharp corners and is unable to
handle deflations that consume the polygon. The CAD use case (boundary
inflation around features, deflation for clearance checks) requires a more
capable function.

## Public API

The module must expose exactly two public symbols:

```python
class JoinStyle(enum.Enum):
    MITER = "miter"
    ROUND = "round"
    BEVEL = "bevel"

def offset_polygon_2d(
    polygon: Iterable[UVec],
    distance: float,
    *,
    join_style: JoinStyle = JoinStyle.ROUND,
    miter_limit: float = 2.0,
    arc_segment_angle: float = math.pi / 16.0,
) -> list[list[Vec2]]:
    ...
```

`Vec2` and `UVec` are imported from `ezdxf.math` (the public re-exports).
The two public symbols must be importable in three ways:

1. `from ezdxf.math.buffer import JoinStyle, offset_polygon_2d` - the
   primary location of the implementation.
2. `from ezdxf.math import JoinStyle, offset_polygon_2d` - re-exported
   from the math package's public namespace. The re-exported objects must
   be the *same* class / function (verified with `is`).
3. The companion module `ezdxf.math.offset2d` must expose a convenience
   wrapper:

   ```python
   def offset_closed_polygon_2d(
       vertices: Iterable[UVec], offset: float
   ) -> list[Vec2]:
       """Offset of a closed polygon as a single list of Vec2 vertices.

       Uses the round join style. Returns ``[]`` if the polygon is fully
       consumed by a deflation. ``offset == 0`` returns the input.
       """
   ```

   Add `"offset_closed_polygon_2d"` to the module's `__all__`.

No other public symbols may be added to `ezdxf.math.buffer`.

## Inputs

- `polygon` is a closed polygon described by its vertices. Z components are
  ignored. The polygon may or may not include a duplicate of the first
  vertex at the end. Consecutive duplicate vertices must be silently
  removed. The polygon is interpreted as a simple polygon (non
  self-intersecting); behaviour for self-intersecting input is unspecified.
- `distance` is a signed scalar. A positive value inflates the polygon
  (moves the boundary outward), a negative value deflates it (moves the
  boundary inward), and `0` returns the normalised input as-is.
- `join_style` controls how convex corners are joined when the offset
  separates adjacent edges. Concave corners always use the analytical
  intersection of the two adjacent parallel offset edges.
- `miter_limit` only applies when `join_style` is `JoinStyle.MITER`. When
  the resulting miter point would be further than `miter_limit *
  abs(distance)` from the original corner the join must fall back to a
  bevel chord. `miter_limit < 1.0` is invalid and must raise `ValueError`.
- `arc_segment_angle` only applies to `JoinStyle.ROUND`. It is the maximum
  angle (in radians) of a single chord approximating the arc. Smaller
  values produce smoother arcs. Must be `> 0`; otherwise raise
  `ValueError`.

## Outputs

- The return value is a list of polygons. Each polygon is a list of
  distinct `Vec2` instances in counter-clockwise orientation. The closing
  edge from the last to the first vertex is implicit; the first vertex
  must NOT be repeated at the end.
- Inflating any non-degenerate polygon yields exactly one polygon.
- Deflating may yield zero polygons (the polygon is fully consumed) or
  one polygon. (Multi-component output for splitting at narrow necks is
  not required.)
- An empty input, a single-vertex input, or a two-vertex input yields an
  empty list.
- A clockwise input must be silently reversed so that the returned
  polygon is counter-clockwise.

## Required behaviour

### Geometry

1. The output boundary is everywhere at distance `abs(distance)` from the
   original polygon boundary, except along corner pieces (bevel chords or
   arc approximations) where the geometry is dictated by the join style.
2. For an inflated polygon, every vertex of the input must lie inside or
   on the boundary of the (single) output polygon at distance no greater
   than `abs(distance)` from it.
3. For a deflated polygon, every vertex of the output must lie inside the
   input polygon at distance at least `abs(distance)` from its boundary.
4. Deflating by a value whose magnitude exceeds the polygon's inradius
   must return an empty list.

### Join styles

5. `JoinStyle.MITER` joins extend the adjacent parallel offset lines until
   they meet at the miter point. When the miter exceeds the limit, the
   join falls back to the same vertices a bevel join would produce
   (`prev_offset_end`, `curr_offset_start`).
6. `JoinStyle.BEVEL` joins emit the two offset edge endpoints (chord) and
   nothing in between.
7. `JoinStyle.ROUND` joins approximate a circular arc on the offset
   circle around the input vertex. The chord between any two consecutive
   arc vertices subtends at most `arc_segment_angle` radians. The arc
   sweeps in the direction consistent with traversing the (CCW) output
   polygon.

### Orientation invariants

8. All returned polygons have positive signed area (CCW).
9. The function is invariant under translation: translating the input by
   any vector `(tx, ty)` produces a translated output by the same vector.
10. The function is invariant under uniform scaling: scaling input
    coordinates and `distance` by the same factor `k > 0` scales the
    output by `k`.

## Validation rules

11. `miter_limit < 1.0` raises `ValueError`.
12. `arc_segment_angle <= 0` raises `ValueError`.

## Suggested approach (informative, non-binding)

The standard way to implement this is in three phases:

1. **Raw offset construction.** Compute the parallel offset of every
   input edge by `distance` along its right-hand normal (so a positive
   distance moves the edge outward for a CCW polygon). At each corner,
   choose between filling the gap (round/miter/bevel) or computing the
   line-line intersection of the two adjacent offset edges based on the
   sign of the corner's cross product and the sign of `distance`.
2. **Self-intersection cleanup.** The raw polyline may cross itself.
   Detect proper crossings, split the polyline at those crossings, and
   trace simple sub-loops in the resulting planar embedding. Loops with
   the wrong winding correspond to spurious geometry generated by the
   crossings and must be discarded.
3. **Geometric validation.** Discard any sub-loop whose vertices lie
   closer to the original boundary than `abs(distance)`. This is what
   makes deflations exceeding the inradius return an empty list rather
   than a topologically valid but geometrically invalid polygon.

You are free to use any algorithm. You may not introduce new third-party
dependencies; only the existing `ezdxf` runtime dependencies (`numpy`,
`pyparsing`, `typing_extensions`, `fonttools`) are available.

## Out of scope

- Open polylines / end caps. Only closed polygons are supported.
- 3D polygons. The Z coordinate is silently ignored.
- Multi-component output when a deflation splits a polygon into several
  disjoint pieces. Returning a single approximate polygon for such cases
  is acceptable. (Tests do not cover this case.)
- Performance optimisations. A clear `O(n^2)` implementation is fine
  for the test polygons (all under 20 vertices).

## Self-verification

Before declaring success, ensure the following invariants hold for your
implementation by writing throwaway scripts that exercise them:

- A square inflated by `d` with miter joins is a square enlarged by `d`
  in every direction (area = `(side + 2d)^2`).
- A square inflated by `d` with bevel joins has 8 vertices and area
  `side^2 + 4 * side * d + 2 * d^2`.
- A square inflated by `d` with round joins has area approaching
  `side^2 + 4 * side * d + pi * d^2` as `arc_segment_angle` -> 0.
- Inflating twice with miter produces the same area as inflating once by
  the sum.
- Deflating an `s x s` square by exactly `s/2` returns `[]`.
- Reversing the input vertex order produces the same output polygons.
