Add a triangulation engine to `trimesh.creation.triangulate_polygon`, selected with `engine="delaunay"`. It works on the required dependencies alone — no optional triangulation package, no scipy — and is the one chosen automatically when none of the optional engines are installed.

It returns counter-clockwise triangles exactly covering the polygon, and none at all when the polygon encloses no area. They are built from the rings' unique points, so a coordinate repeated in a ring counts once; each is used at least once and none are added. Every ring segment stays an edge, and every other shared edge is locally Delaunay.

Both hold however awkward the input. The result depends on the polygon alone, so rotating a ring's start or reversing its winding gives the identical triangles. And the geometric decisions are exact: points a rounding error away from collinear, or from sharing a circle, still come out on the correct side.

`min_angle` in degrees and `max_area` add vertices until no triangle is sharper or larger, leaving the boundary in place. A `min_angle` outside `0 < min_angle <= 30`, a non-positive `max_area`, either target on another engine, or either with `force_vertices`, all raise.
