Add a triangulation engine to `trimesh.creation.triangulate_polygon`, selected with `engine="delaunay"`. It must work on the required dependencies alone, using neither an optional triangulation package nor scipy, and it is chosen automatically when no optional engine is installed.

It returns counter-clockwise triangles which exactly cover the polygon, and none at all when the polygon encloses no area. They are built from the unique points of the rings, so a coordinate repeated in a ring counts once, each used by at least one triangle and none added. Every ring segment stays an edge, and every other shared edge is locally Delaunay.

Both hold however awkward the input. The result depends on the polygon, not on how its rings are written: rotating a ring's start or reversing its winding gives the identical triangles. The geometric decisions are exact, so points a rounding error away from collinear, or from sharing a circle, still come out on the correct side.

`min_angle` in degrees and `max_area` add vertices until no triangle is sharper or larger, leaving the boundary in place. A `min_angle` outside `0 < min_angle <= 30`, a non-positive `max_area`, either target on another engine, or either with `force_vertices`, all raise.
