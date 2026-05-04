ezdxf 2D Polygon Buffer

Add a robust polygon
buffering operation for CAD style inflate and deflate workflows.

Add a new module ezdxf.math.buffer exposing a JoinStyle enum with
values MITER, ROUND and BEVEL and a function
offset_polygon_2d(polygon, distance, *, join_style=JoinStyle.ROUND,
miter_limit=2.0, arc_segment_angle=math.pi / 16.0) -> list[list[Vec2]].
Both names must additionally be importable as `from ezdxf.math import
JoinStyle, offset_polygon_2d` and the re-exports must be the identical
class and function objects. Add a convenience wrapper
offset_closed_polygon_2d(vertices, offset) -> list[Vec2] to
ezdxf.math.offset2d that returns the first polygon produced by
offset_polygon_2d using the round join style, or an empty list when
none is produced.

polygon is a closed polygon given as an iterable of vertices. The Z
component of each vertex is ignored. The function silently removes
consecutive duplicate vertices and a trailing duplicate of the first
vertex; if fewer than three distinct vertices remain the function
returns an empty list regardless of distance. Clockwise inputs are
silently reversed so that every returned polygon is counter-clockwise.
distance is signed: positive inflates, negative deflates. With
distance == 0 the function returns the normalised polygon (after
deduplication and orientation reversal) as the single element of a
one-element list.

Each polygon in the return value is a simple, non-self-intersecting
closed polygon represented as a list of distinct Vec2 instances in
counter-clockwise orientation; the closing edge from the last to the
first vertex is implicit and the cyclic starting position is
unspecified. Inflating any non-degenerate polygon yields exactly one
polygon. Deflating yields one polygon or none.

An inflated output strictly contains the input polygon. Every output
vertex on a straight portion of the offset boundary lies at unsigned
distance abs(distance) from the input polygon's boundary; vertices
emitted as part of a corner piece follow the chosen join style. A
deflated output is strictly contained in the input polygon and every
output vertex lies at distance at least abs(distance) from the input
boundary; a deflation whose magnitude reaches or exceeds the
polygon's inradius returns []. The operation is invariant under
translation and under uniform positive scaling of the input and
distance by the same factor.

MITER joins extend the two adjacent parallel offset lines until they
meet at a single miter point; when that point lies further than
miter_limit * abs(distance) from the original corner the join falls
back to the same two endpoints a BEVEL join produces. BEVEL joins
emit those two parallel offset endpoints with no points between them.
ROUND joins approximate the corresponding arc on the offset circle
around the input vertex such that no chord between consecutive arc
vertices subtends more than arc_segment_angle radians. Concave
corners always join the two adjacent parallel offset edges at their
analytical line/line intersection regardless of the requested style.

miter_limit < 1.0 raises ValueError. arc_segment_angle <= 0 raises
ValueError. Multi-component output for deflations that split a
polygon at a narrow neck is out of scope.
