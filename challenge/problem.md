ezdxf 2D Polygon Buffer

Add a robust polygon
buffering operation for CAD style inflate and deflate workflows.

Add module ezdxf.math.buffer exposing a JoinStyle enum (MITER, ROUND,
BEVEL) and offset_polygon_2d(polygon, distance, *,
join_style=JoinStyle.ROUND, miter_limit=2.0,
arc_segment_angle=math.pi / 16.0) -> list[list[Vec2]]. Both names
must also be importable as `from ezdxf.math import JoinStyle,
offset_polygon_2d` and the re-exports must be the same objects.
Add wrapper offset_closed_polygon_2d(vertices, offset) ->
list[Vec2] to ezdxf.math.offset2d that returns the first polygon
produced by offset_polygon_2d using ROUND, or [] when none is.

polygon is a closed polygon given as an iterable of vertices. Z is
ignored. Consecutive duplicate vertices and a trailing duplicate of
the first vertex are silently removed; if fewer than three distinct
vertices remain the function returns [] regardless of distance.
Clockwise inputs are silently reversed so every returned polygon is
counter-clockwise. distance is signed: positive inflates, negative
deflates. With distance == 0 the function returns the normalised
polygon as the single element of a one-element list.

Each polygon in the return value is a simple, non-self-intersecting
closed polygon represented as a list of distinct Vec2 instances in
counter-clockwise orientation; the closing edge from the last to the
first vertex is implicit and the cyclic starting position is
unspecified. Inflating any non-degenerate polygon yields exactly one
polygon. Deflating yields one polygon or none.

An inflated output strictly contains the input. Every output vertex
on a straight portion of the offset boundary lies at unsigned distance
abs(distance) from the input boundary; vertices in a corner piece
follow the chosen join style. A deflated output is strictly contained
in the input, every output vertex lies at distance at least
abs(distance) from the input boundary, and a deflation whose
magnitude reaches or exceeds the inradius returns []. The operation
is invariant under translation and under uniform positive scaling of
input and distance by the same factor.

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

Wire the operation into entity selection: the existing Polygon class
in ezdxf.select gains buffered(distance, *, join_style=None,
miter_limit=2.0, arc_segment_angle=math.pi / 16.0) ->
list[Polygon]. It returns one or more ezdxf.select.Polygon shapes
whose boundaries come from offset_polygon_2d on this polygon's vertex
list, defaulting to ROUND when join_style is None, and returns [] if
the buffer does.
