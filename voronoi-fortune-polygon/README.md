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
- `main.lua`: a LOVE2D demo showing how to use the library.
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

Place `voronoi.lua`, `main.lua`, and `conf.lua` in the same folder and run
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
- 8: reroll the recursive subdivision with brand new random sites (and
  colors) at every level, using the current bounding polygon as the root
  shape. Also turns the mode on if it was off.

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
(`computeRecursiveLeaves`): starting from the root bounding polygon, it
drops all of level 1's sites into a fresh `Voronoi` instance, then for
each resulting cell, drops all of level 2's sites into another fresh
`Voronoi` instance bounded by that cell, and so on down to the deepest
level. A site only ever ends up subdividing whichever cell it
geometrically falls inside *at that moment* - this is exactly the
library's ordinary `site.valid` / `pointInPolygon` check, nothing custom.

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

Each leaf's fill color is inherited from its level-1 ancestor site,
assigned once when that site's coordinates are generated and never
re-rolled independently, so live recomputation during dragging never
causes colors to flicker; only the cell outlines move.

Generation (`generateRecursiveLayers`) is a separate step from the
recompute described above, and it does its own walk down the tree: it
actually places `recursiveSitesPerCell` (default 2) points strictly
inside every polygon it visits, using a throwaway `Voronoi` instance per
branch purely to learn that branch's cell shapes, before moving on to the
next level. This matters because merely scattering, say, 2^depth points
independently over the whole root polygon (ignoring where the actual
cells at that depth are) can easily leave some cells - usually small ones
or ones far from the root's centroid - with zero points by pure chance,
so they'd never subdivide further and would show up as a flat,
unsubdivided patch. Guaranteeing per-cell coverage at generation time
avoids that. The result is still stored as one flat list of fixed
coordinates per depth (`recursiveLayers[depth]`), exactly like before, so
the later recompute step is unaffected by this and remains just as cheap
and just as safe to run during dragging.

With the default depth of 8 and 2 sites per cell, the hierarchy can
produce up to 256 leaf cells at generation time. After that, dragging the
root polygon can still leave a cell with zero points inside it if the
distortion is severe enough to push both of its points out - that's
expected and matches ordinary invalid-site behavior, not a bug; press 8
to reroll if you want full coverage again. `recursiveMaxDepth` and
`recursiveSitesPerCell` are plain, easily adjustable local variables in
`main.lua`; every intermediate diagram in the hierarchy is cheap
regardless, since none of them ever holds more than one branch's worth of
sites at a time.

## Roadmap

- Support for non-convex bounding polygons. This requires either splitting
  the polygon into convex parts before clipping, or tracking intersections
  between the sweep and the polygon boundary directly.
- Benchmarking for larger numbers of sites, and possible optimization of
  the neighbor lookup fallback path.