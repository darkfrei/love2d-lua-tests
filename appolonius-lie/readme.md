# appolonius-li

A solver for the generalized Apollonius problem via Lie sphere geometry
(LÖVE2D / Lua).

A point, a circle, and a line are all encoded as the same 5-dimensional
vector on the Lie quadric in R^{3,2}. Whether two oriented cycles are
tangent is a single scalar condition (the Lie bilinear form is zero),
with no branching on "point / circle / line".

## Files

- `appolonius-li.lua` -- the module itself: cycle constructors, the Lie
  form, a decoder back to (a,b,r) / (a,b) / (nx,ny,p), and the solver
  `solve_apollonius` / `solve_apollonius_all`.
- `main.lua` -- an interactive LÖVE2D test bed covering all 10 classical
  types of the Apollonius problem. Window is 1920x1080 and resizable,
  set directly in `love.load` (no `conf.lua`).

## Running

```
love .
```

(run it from the folder that contains `main.lua` and `appolonius-li.lua`;
LÖVE picks up `main.lua` automatically).

## Controls

- `1`-`9`, `0` -- jump directly to a problem type (`0` = the 10th, PPP)
- `Tab` / `Right` -- next problem type
- `Left` -- previous problem type
- drag a handle (a circle's center, a point, or a line's endpoint) with
  the mouse to move it
- scroll the mouse wheel over a circle to change its radius
- `R` -- reset the current problem type to its default layout
- `Esc` -- quit

Input shapes are drawn in blue. Cycles found by the solver are drawn in
green (circles), yellow (points), or orange (lines).

## The 10 problem types

Every combination of point (P), line (L), circle (C) taken 3 at a time:

| key | type | notes |
|---|---|---|
| 1 | CCC | up to 8 solutions |
| 2 | CCL | |
| 3 | CCP | |
| 4 | CLL | |
| 5 | CLP | |
| 6 | CPP | |
| 7 | LLL | incircle + 3 excircles of a triangle -- exactly 4 solutions |
| 8 | LLP | |
| 9 | LPP | |
| 0 | PPP | circumcircle -- exactly 1 solution |

All 10 were run through the solver directly (outside LÖVE) before
shipping this; LLL gave exactly 4 solutions and PPP gave exactly 1,
matching the classical results.

## Math, in brief

A cycle (a, b, r) maps to the vector `(r, a, b, -1, (a^2+b^2-r^2)/2)`; a
point is the special case r=0; a line is the r -> infinity limit, kept
in the module as its own encoding `(1, nx, ny, 0, p)`. The bilinear form:

```
<x,y> = -x0*y0 + x1*y1 + x2*y2 + x3*y4 + x4*y3
```

Every valid cycle vector lies on the quadric `<x,x>=0`. Two oriented
cycles are tangent if and only if `<x,y>=0`.

Given three cycles x, y, z, the solver looks for a vector q orthogonal
to all three (a linear system, generically a 2-dimensional null space)
that also lies on the quadric (`<q,q>=0`, a quadratic equation inside
that null space). Trying all orientation combinations of x, y, z
recovers the classical up-to-8 solutions of the Apollonius problem.

## Module API (`appolonius-li.lua`)

| function | description |
|---|---|
| `Cycle.circle(a, b, r)` | circle centered at (a,b), signed radius r |
| `Cycle.point(a, b)` | a point = a circle of zero radius |
| `Cycle.line(nx, ny, p)` | the line nx*x + ny*y = p |
| `Cycle.line_through(ax, ay, bx, by)` | the line through two points |
| `Cycle.dot(x, y)` | the Lie bilinear form |
| `Cycle.norm(x)` | `<x,x>` |
| `Cycle.is_valid(x)` | whether the vector lies on the quadric |
| `Cycle.is_tangent(x, y)` | oriented tangency test |
| `Cycle.reverse(x)` | same locus, opposite orientation |
| `Cycle.decode(x)` | vector -> `"circle", a, b, r` / `"point", a, b` / `"line", nx, ny, p` |
| `Cycle.solve_apollonius(x, y, z)` | 0-2 solutions for this exact orientation (or `"infinite", u, v`) |
| `Cycle.solve_apollonius_all(x, y, z)` | tries all 4 orientation combinations, filters out trivial/duplicate results |

## Known limitations

- `solve_apollonius` assumes the general case (the three cycles are
  linearly independent); on a degenerate configuration (all three
  cycles tangent at one point) it raises an `assert`.
- `solve_apollonius_all` skips the `"infinite"` case rather than
  enumerating the resulting pencil of solutions -- handle that
  separately via `solve_apollonius` if you need it.