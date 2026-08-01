Add a triangulation engine to `trimesh.creation.triangulate_polygon`, selected with `engine="delaunay"`, working on the required dependencies alone: no optional triangulation package, no scipy. It is chosen automatically when no optional engine is installed.

It returns counter-clockwise triangles which exactly cover the polygon, and none at all when the polygon encloses no area. They are built from the rings' unique points, so a repeated coordinate counts once, each used at least once and none added. Every ring segment stays an edge, and every other shared edge is locally Delaunay.

Rotating a ring's start or reversing its winding gives identical triangles, holes included. Orientation and circle decisions are exact, so points a rounding error from collinear or cocircular still fall on the correct side.

`min_angle` in degrees and `max_area` add vertices until no triangle is sharper or larger, and finish for any target in range. The outline is untouched: an added boundary vertex lies on the boundary it came from, and the shared edges which are not boundary stay locally Delaunay. A `min_angle` outside `0 < min_angle <= 30`, a non-positive `max_area`, either target on another engine, or either with `force_vertices`, all raise `ValueError`.
