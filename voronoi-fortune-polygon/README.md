# Voronoi (Lua / LOVE2D)

A small library for computing Voronoi diagrams clipped to a convex bounding
polygon. Built for LOVE2D, but the core algorithm has no rendering
dependency and can be adapted to other environments with minimal changes.

## How it works

The library splits the problem into two separate steps.

1. Topology: Fortune's sweep-line algorithm is used only to determine which
   sites are neighbors (the Delaunay neighbor graph). This runs in
   O(n log n) time. No edge geometry is stored during the sweep, only pairs
   of neighboring sites.
2. Geometry: for each site, the actual cell polygon is computed by clipping
   the bounding polygon against the perpendicular bisector of the site and
   each of its neighbors, using Sutherland-Hodgman half-plane clipping.

This approach works with any convex bounding polygon, not just a rectangle,
and avoids the complexity of tracking polygon boundary intersections
directly inside the sweep.

If a site ends up with no neighbors after the sweep (a rare, degenerate
case), the library falls back to clipping against every other valid site
for that one site only.

## Limitations

- The bounding polygon must be convex. A warning is printed if it is not.
  Behavior with a non-convex polygon is not guaranteed.
- Sites with identical x coordinates are nudged internally by a tiny
  epsilon to keep the sweep well defined. This only affects internal
  processing order, not the coordinates you get back.
- Sites outside the bounding polygon are marked invalid and excluded from
  the diagram, but they remain in the sites list.
- Exactly collinear triples of sites cause the sweep to skip a circle
  event (see `diagram.lastFallbackCount` below), since the circumcircle
  is undefined for collinear points. This is rare with continuous
  coordinates, but common if sites are placed at integer pixel
  coordinates (as `math.random(minX, maxX)` returns), since three
  integer points landing exactly on one line is far more likely than
  with real-valued coordinates. If you generate random sites, add a
  small fractional jitter (see `main.lua`'s `randomSiteInPolygon`) rather
  than placing them at exact integer coordinates.

## Files

- `voronoi.lua`: the library. Framework independent except for the `draw*`
  and `exportGraphToClipboard` methods, which call LOVE2D functions.
- `polygon_utils.lua`: standalone polygon/geometry helpers used by the
  demo (bounding boxes, centroid, area, edge/vertex picking, shared-border
  detection, convex hull, random point sampling). No dependency on any
  global demo state.
- `recursive_subdivision.lua`: builds and maintains the recursive Voronoi
  hierarchy (see Recursive subdivision below) - generation, recomputing
  leaves, adjacency, and 4-coloring. Depends on `voronoi.lua` and
  `polygon_utils.lua`.
- `main.lua`: a LOVE2D demo showing how to use the library - state, input
  handling, and the `love.*` callbacks. Requires the three files above.
- `conf.lua`: LOVE2D window configuration (default resolution, resizing).

## Installation

Copy `voronoi.lua` into your project and require it:

```lua
local Voronoi = require("voronoi")
```

## Basic usage

```lua
local Voronoi = require("voronoi")

-- create a diagram with a bounding polygon (flat list of x, y pairs)
local diagram = Voronoi.new({50, 50, 750, 50, 750, 550, 50, 550})

-- add sites
diagram:addSite(200, 200)
diagram:addSite(400, 300)
diagram:addSite(600, 150)

-- compute the diagram
diagram:update()

-- read the resulting cells
for i, cell in ipairs(diagram.cells) do
    if cell.valid then
        -- cell.polygon is a flat {x1, y1, x2, y2, ...} list
    end
end
```

Call `diagram:update()` again any time you add, remove, or move a site, or
change the bounding polygon.

## API reference

### Voronoi.new(boundingPolygon)

Creates a new diagram. `boundingPolygon` is optional, a flat list of
`x, y` coordinates with at least three points. If omitted, a default
rectangle is used.

### diagram:setBoundingPolygon(polygon)

Sets or replaces the bounding polygon. Prints a warning if the polygon is
not convex.

### diagram:addSite(x, y)

Adds a site at the given coordinates. Returns the created site table, or
nil if a site already exists at those exact coordinates. The returned
table can be used to attach custom data, for example a color.

### diagram:addSites(list)

Adds multiple sites at once. `list` is an array of tables with `x` and `y`
fields.

### diagram:removeSiteByIndex(index)

Removes the site and its cell at the given index.

### diagram:removeLastSite()

Removes the most recently added site.

### diagram:clearSites()

Removes all sites and cells.

### diagram:update()

Recomputes the diagram: validates sites against the bounding polygon, runs
the sweep to find neighbors, clips cell polygons, and rebuilds the vertex
and edge lists. Call this after any change to sites or the bounding
polygon.

As a side effect, `diagram.delaunayEdges` is rebuilt: a flat, deduplicated
list of `{a = site, b = site}` pairs representing which sites actually
border each other inside the bounding polygon. This is derived from the
computed edges (`edge.cells`), not directly from the infinite-plane
Delaunay neighbor graph used internally for clipping: two sites can be
true Delaunay neighbors on the infinite plane while a third site's cell
fully separates them everywhere inside the bounding polygon, in which
case they will NOT appear in `delaunayEdges`, since they don't actually
border each other in this diagram.

`diagram.lastFallbackCount` is also set: the number of sites for which
Fortune's sweep found no neighbors and the O(n) safety-net fallback had
to run instead. This should normally be 0. A nonzero value usually means
some sites are exactly (or nearly) collinear; see Limitations above.
This fallback affects only the internal clipping neighbor set, not
`delaunayEdges`, which is always derived from the actual computed cells.

### diagram:getCell(mx, my)

Returns the index and cell table containing the given point, or nil.

### diagram:getVertex(mx, my)

Returns the index and vertex table near the given point (within a small
radius), or nil.

### diagram:getEdge(mx, my)

Returns the index and edge table near the given point (within a small
distance), or nil.

### diagram:exportGraphToClipboard()

Copies the current vertex and edge graph to the system clipboard as Lua
source code (requires LOVE2D).

### Drawing helpers (require LOVE2D)

- `diagram:drawBoundingPolygon(mode)`
- `diagram:drawSite(index, mode, radius)`
- `diagram:drawSites(mode, radius)`
- `diagram:drawCell(index, mode)`
- `diagram:drawCells(mode)`
- `diagram:drawVertices(mode, radius)`
- `diagram:drawDelaunay()`: draws lines between sites whose cells actually
  border each other inside the bounding polygon. This matches the true
  Delaunay triangulation for sites away from the boundary, but can differ
  near it, see `diagram.delaunayEdges` below.

`mode` follows LOVE2D conventions, either "fill" or "line".

### Static utilities

- `Voronoi.pointInPolygon(x, y, polygon)`: point in polygon test using ray
  casting. Works with any polygon, convex or not.
- `Voronoi.isConvex(polygon)`: returns true if the polygon is convex.

## Data structures

### site

```
{
    x = number,
    y = number,
    valid = boolean,   -- true if inside the bounding polygon
    cell = table,      -- reference to the corresponding cell
}
```

Any extra fields you add (such as `color`) are preserved as is.

### cell

```
{
    site = table,      -- reference to the owning site
    valid = boolean,
    polygon = {x1, y1, x2, y2, ...},
    vertices = {vertex, vertex, ...},
    edges = {edge, edge, ...},
}
```

### vertex

```
{
    x = number,
    y = number,
    id = number,
    cells = {cell, cell, ...},
    edges = {edge, edge, ...},
}
```

### edge

```
{
    v1 = vertex,
    v2 = vertex,
    cells = {cell, cell, ...},
}
```

## Running the demo

Place `voronoi.lua`, `polygon_utils.lua`, `recursive_subdivision.lua`,
`main.lua`, and `conf.lua` in the same folder and run
with LOVE2D:

```
love .
```

The window opens at 1920x1080 (FullHD) by default and is resizable; drag
its edges or maximize it as usual. To change the default resolution, edit
`t.window.width` and `t.window.height` in `conf.lua`. The demo's random
bounding polygon is generated relative to the current window size, so it
scales sensibly whichever resolution or aspect ratio you start with.

Controls:

- Left click on empty space inside the polygon: add a site.
- Left click and drag a site: move it.
- Left click and drag a bounding polygon vertex: move it.
- Left click and drag a bounding polygon edge: move the whole edge (both
  of its vertices together).
- Short left click on a bounding polygon edge (press and release without
  dragging): insert a new vertex on that edge at the clicked point.
- Right click a site: delete it.
- Right click a bounding polygon vertex: delete it (refused if the polygon
  would drop below three vertices).
- Hovering over a site, a polygon vertex, or a polygon edge highlights it.
  This always stays active, independent of the key 1 toggle below.
- 1: toggle the on-screen instructions text only. Vertex handles, hover
  highlights, and all editing (dragging, adding, deleting) stay fully
  active and visible regardless of this toggle.
- 2: generate a new random convex bounding polygon, keeping the current
  sites (sites that fall outside the new polygon become invalid).
- 3: generate a new set of random sites, keeping the current bounding
  polygon.
- 4: delete all sites.
- 5: relax sites with one step of Lloyd's algorithm, moving each site to
  the centroid of its own cell.
- 6: toggle the Delaunay triangulation overlay.
- 7: toggle recursive subdivision mode (see below). Turning it on clears
  the diagram's own sites, since they are not used in this mode. The
  first time it's turned on, it generates a fresh hierarchy; toggling it
  off and back on again reuses the same site coordinates.
- 8: reroll the recursive subdivision with brand new random sites at
  every level, using the current bounding polygon as the root shape. Also
  turns the mode on if it was off.

## Recursive subdivision

Since a cell polygon of a convex-bounded diagram is itself always convex
(the intersection of convex regions is convex), it can be fed straight
back into `Voronoi.new(...)` as the bounding polygon for a brand new,
independent diagram. No changes to the library are needed for this.

The demo (`main.lua`) uses this to build a hierarchy of a fixed number of
levels (`recursiveMaxDepth`, default 8). Each level is a flat list of
sites at fixed, absolute coordinates (`recursiveLayers[depth]`), generated
once (or on an explicit reroll, key 8) and never moved automatically.
Rendering recomputes the whole hierarchy from scratch every time
(`RecursiveSubdivision.computeLeaves`): starting from the root bounding
polygon, it drops all of level 1's sites into a fresh `Voronoi` instance,
then for each resulting cell, drops all of level 2's sites into another
fresh `Voronoi` instance bounded by that cell, and so on down to the
deepest level. A site only ever ends up subdividing whichever cell it
geometrically falls inside *at that moment* - this is exactly the
library's ordinary `site.valid` / `pointInPolygon` check, nothing custom.

Since `recursiveLayers[depth]` is one flat list shared across the entire
tree (not split up per branch), a naive implementation would feed every
point at that depth - including ones that obviously belong to a
completely unrelated branch - into every single node's throwaway
`Voronoi` instance, relying on `addSite`/`update()` alone to sort out
which ones are actually valid there. That works, but it means paying for
a full Fortune's sweep over hundreds of irrelevant points per node, which
gets extremely slow for a large hierarchy (multiple seconds for a full
FullHD hierarchy in testing). `computeLeaves` instead pre-filters with a
plain `Voronoi.pointInPolygon` check - far cheaper than a full sweep -
before constructing each node's Voronoi instance, so its actual
computation only ever involves the handful of points (usually 0 to 4)
that truly belong to it.

The point of fixing the coordinates instead of rerolling them on every
recompute is that dragging the outer bounding polygon (or, in principle,
editing anything further up the hierarchy) never corrupts the lower
levels: cells simply reshape around the fixed points, a point that no
longer falls inside any cell just stops contributing (like any other
invalid site), and a point that drifts into a different cell than before
belongs to that cell instead, automatically, on the very next recompute.
Since recomputation only depends on the current geometry and never
reintroduces randomness, it's cheap enough to run on every mouse-move
event while dragging a bounding polygon vertex or edge, so the whole
hierarchy visibly reshapes live as you drag.

Rendering (`recursiveLeaves`) is a flat list of leaf polygons. Each one
is filled using a proper 4-coloring of the map: `RecursiveSubdivision.
buildLeafAdjacency` determines which leaves actually share a border (not
just which vertices coincide - see below), and `RecursiveSubdivision.
colorLeaves` assigns one of `RecursiveSubdivision.defaultFourColors` to
each leaf so that no two bordering leaves ever get the same color. This
is the classic four color theorem setting: any planar map can be colored
this way with only 4 colors.

An earlier version of `colorLeaves` used DSATUR with backtracking, but
DSATUR's core rule ("color whichever uncolored vertex currently has the
most distinctly-colored neighbors") needs an O(n) rescan of every
remaining vertex at each step, and still failed to find a full 4-coloring
within a reasonable attempt budget on real generated hierarchies of a few
hundred to a couple thousand leaves - the fallback color showed up far
more than "rare". The current implementation instead uses smallest-last
(degeneracy) ordering: repeatedly peel off whichever remaining vertex
currently has the lowest residual degree (using bucket queues, so this
only touches each edge a constant number of times, close to O(n + m)
overall), then color in the reverse of that peeling order, taking the
lowest available color at each step. Benchmarked against the old DSATUR
approach on real generated hierarchies of up to about 1100 leaves,
smallest-last ordering alone already found a full 4-coloring in a single
pass in most cases, one to two orders of magnitude faster - because
peeling by residual degree only ever touches a vertex's immediate
neighbors, never the whole remaining vertex set. `colorLeaves` still
tries a few restarts (`restartAttempts`, default 3) with a randomized
tiebreak for diversity among equal-degree vertices.

Whatever conflicts remain after a given restart's greedy pass (typically
none, and rarely more than a handful even on graphs with over a thousand
leaves) are handed to Kempe chain repair, applied to *every* restart
attempt rather than only to whichever one happened to have the fewest
raw conflicts before repair. That distinction matters: an attempt with
fewer raw conflicts isn't necessarily easier to repair than one with
more, so picking the "best" attempt before repair and only fixing that
one can end up keeping a harder-to-repair coloring over an easier one -
in testing, this was the actual reason a couple of leaves would
occasionally end up in the fallback color even after repair, not a flaw
in the repair logic itself.

The repair step (`kempeChainRepair`) itself also runs multiple passes
over the leftover conflicts rather than a single left-to-right scan: for
a conflicted leaf, it picks one of its neighbors' colors and a second
color, then flips every leaf reachable from that neighbor through leaves
colored only one of those two colors (a "Kempe chain") to the other
color. This never breaks validity anywhere else in the map - that's the
classical argument behind Kempe chains - so if the flip frees up a color
for the conflicted leaf, it's always safe to apply. Fixing one leaf this
way can change colors elsewhere in the graph, which can in turn free up
a color for some *other* conflicted leaf that appeared earlier in the
same left-to-right scan and had already been given up on for that pass;
repeating the pass until it makes no further progress (bounded to 5
passes) catches those knock-on fixes instead of leaving a leaf in
fallback purely because of scan order. Only in the extremely unlikely
case a conflict survives everything above does a leaf get drawn in
`RecursiveSubdivision.defaultFallbackColor` instead of silently repeating
a neighbor's color - in stress testing (50 randomly generated full-size
hierarchies, up to about 1300 leaves each), this happened for exactly one
leaf in one hierarchy out of 50.

Determining adjacency isn't just a matter of matching vertex coordinates
between leaves, because two neighboring leaves in the hierarchy are very
often subdivided to different depths on either side of their shared
border: one side might have a single long edge facing several shorter
edges on the other side (a "T-junction"), so vertex-for-vertex matching
would miss the connection entirely. `PolygonUtils.sharesBorder` instead
checks, for every edge pair between two leaves, whether they're collinear
and overlap by more than a tiny length - which correctly detects a shared
border regardless of how differently each side happened to subdivide.
Bounding-box overlap (`PolygonUtils.boundsOverlap`) is checked first as a
cheap rejection test, since the vast majority of leaf pairs aren't
anywhere near each other and don't need the more expensive per-edge
check. Both tolerances (the bounding-box epsilon and the collinearity
check) are deliberately tight, well under a pixel: these edges come from
exact geometric clipping, not noisy measurements, so a loose tolerance
mostly just risks false-positive adjacency between deep, tiny cells that
pass close to each other without truly sharing a border - which inflates
the graph for no real reason and was the main cause of frequent
fallback-colored leaves before this was tightened.

Coloring is recomputed less often than the leaf geometry itself: dragging
a bounding polygon vertex or edge keeps `recursiveLeaves` live-updated
every frame (cheap), but only re-solves adjacency and coloring
(`recolorRecursiveLeaves` in `main.lua`) when the drag ends, or on
explicit triggers (reroll, toggling the mode on, picking a new root
polygon) - full recoloring is meaningfully more expensive than just
recomputing leaf outlines, and the leaf boundaries barely change between
one drag frame and the next anyway, so there's little benefit to redoing
it on every single frame.

Both adjacency and coloring are recomputed every time
`regenerateRecursiveLeaves` runs, including live during dragging, same as
the leaf polygons themselves.

Generation (`RecursiveSubdivision.generateLayers`) is a separate step
from the recompute described above, and it processes the tree level by
level (breadth-first), not branch by branch (depth-first): every polygon
still alive at depth N gets a chance to subdivide before any of them
proceeds to depth N+1. For each one, it rolls a random subdivision count
via `randomSubdivisionCount` - mostly 2, sometimes 3, rarely 4, weighted
by `recursiveCountWeights` (65% / 28% / 7% by default) - and places that
many points strictly inside that specific polygon, using a throwaway
`Voronoi` instance per polygon purely to learn its cell shapes for the
next level down. This matters for two separate reasons:

- Merely scattering points independently over the whole root polygon
  (ignoring where the actual cells at that depth are) can easily leave
  some cells - usually small ones, or ones far from the root's centroid -
  with zero points by pure chance, so they'd never subdivide further and
  would show up as a flat, unsubdivided patch. Placing points per actual
  polygon avoids that.
- Processing level by level rather than branch by branch matters because
  of `recursiveMaxTotalSites` (see below): with a depth-first walk, the
  first-explored branch could recurse all the way to `recursiveMaxDepth`
  and spend the whole site budget on itself, leaving every other branch -
  including large ones, purely due to traversal order - stuck with no
  subdivision at all. Spending the budget level by level instead means it
  runs out (if it ever does) evenly across whatever is still being
  subdivided at that depth, not lopsidedly against whichever branch
  happened to be visited last.

The result is still stored as one flat list of fixed coordinates per
depth (`recursiveLayers[depth]`), exactly like before, so the later
recompute step is unaffected by any of this and remains just as cheap and
just as safe to run during dragging.

After a branch's points are placed, they're relaxed twice (one step of
Lloyd's algorithm, twice: move each site to its own cell's centroid,
recompute, repeat) before recursing into the next level - the same
Lloyd's step as the standalone relax feature (key 5), just applied
automatically per branch at generation time. This is purely cosmetic: it
tends to produce more evenly sized cells with fewer thin slivers than raw
random placement, and doesn't affect dragging safety, which only depends
on the final coordinates being fixed, not on how they were chosen. The
relaxed coordinates, not the original random ones, are what get stored
into `recursiveLayers[depth]` and used from then on.

Before subdividing a polygon, `walk` also checks its area against
`recursiveMinAreaFraction` (0.1% of the root polygon's area by default):
below that, the polygon stops subdividing and stays a leaf, however
shallow. This only ever affects small cells - a large cell's area never
drops near the threshold just because other, unrelated cells are tiny -
so big regions keep subdividing normally down to `recursiveMaxDepth`
while thin slivers and other small leftover slices stop early instead of
fracturing into a dense tangle of barely visible lines.

With the default depth of 8 and mostly-2-sometimes-more sites per cell,
the hierarchy can produce a few hundred leaf cells at generation time.
After that, dragging the root polygon can still leave a cell with zero
points inside it if the distortion is severe enough to push all of its
points out - that's expected and matches ordinary invalid-site behavior,
not a bug; press 8 to reroll if you want full coverage again.
`recursiveMaxDepth`, `recursiveCountWeights`, and
`recursiveMinAreaFraction` are plain, easily adjustable local variables in
`main.lua`; every intermediate diagram in the hierarchy is cheap
regardless, since none of them ever holds more than one branch's worth of
sites (2 to 4) at a time.

## Roadmap

- Support for non-convex bounding polygons. This requires either splitting
  the polygon into convex parts before clipping, or tracking intersections
  between the sweep and the polygon boundary directly.
- Benchmarking for larger numbers of sites, and possible optimization of
  the neighbor lookup fallback path.
