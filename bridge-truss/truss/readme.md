# Truss Simulation Library

A lightweight Lua library for simulating two-dimensional truss structures. It models nodes as point masses and beams as spring-damper elements. The library supports gravity, external loads, fixed constraints, and automatic beam failure when force limits are exceeded. Physics updates use Velocity Verlet integration for stability.

## Installation

Place the `truss` directory in your project. Require the library using standard Lua module loading:

```lua
local Truss = require("truss")
```

## Quick Start

The following example demonstrates a simple triangular truss with two supports and a downward load:

```lua
local Truss = require("truss")

-- Create a new simulation world with default settings
local world = Truss.new()

-- Add three nodes at pixel coordinates
local n1 = world:add_node(100, 400)
local n2 = world:add_node(300, 400)
local n3 = world:add_node(200, 260)

-- Apply constraints: n1 is fully fixed, n2 is a vertical roller
world:pin(n1, true, true)
world:pin(n2, false, true)

-- Apply a downward load to the top node
world:set_load(n3, 5)

-- Connect nodes with beams
world:add_beam(n1, n2)
world:add_beam(n1, n3)
world:add_beam(n2, n3)

-- Initialize simulation state. Required before stepping.
world:start()

-- In your main update loop:
-- world:step(deltaTime)
```

## Simulation Lifecycle

1. Create a world using `Truss.new()`.
2. Add nodes and beams to define the structure.
3. Apply constraints and loads as needed.
4. Call `world:start()` to snapshot initial positions and reset velocities.
5. Call `world:step(dt)` repeatedly in your update loop.
6. Read node positions and beam forces to render or analyze the structure.
7. Call `world:reset()` if you need to rewind to the initial rest state.

## Core API Reference

### World Creation
`Truss.new(config)`
Returns a new World object. The optional `config` table overrides default physics constants.

### Topology
`world:add_node(x, y, opts)`
Adds a node at the given coordinates. Returns a 1-based integer index.
Options:
- `pin_x` (boolean): Fix horizontal movement
- `pin_y` (boolean): Fix vertical movement
- `load` (number): Scalar multiplier for external downward force

`world:add_beam(a, b)`
Connects two nodes by their indices. Returns the beam index, or nil if the beam already exists.

`world:remove_node(idx)`
Removes a node and all attached beams.

`world:remove_beam(idx)`
Removes a single beam.

### Constraints and Loads
`world:pin(idx, pin_x, pin_y)`
Updates horizontal and vertical constraints for a node.

`world:set_load(idx, load)`
Sets or clears an external load. The value is multiplied by the gravity constant during physics calculations. Pass nil to remove the load.

### Simulation Control
`world:start()`
Snapshots current positions as rest positions, clears velocities, resets beam forces, and computes initial forces. Must be called before the first step.

`world:step(dt)`
Advances the simulation by `dt` seconds. Automatically handles substeps and checks for beam failures.

`world:reset()`
Returns all nodes to their rest positions and clears velocities and forces.

### Queries and State
`world:broken_count()`
Returns the number of beams that have exceeded the fracture limit.

`world:is_fixed(idx)`
Returns true if a node is pinned in both x and y directions.

`world.on_beam_break`
Optional callback. Assign a function that receives the broken beam table.
Example: `world.on_beam_break = function(beam) print("Beam broke:", beam.n1, beam.n2) end`

### Accessing Runtime Data
- `world.nodes`: Array of node tables. Each contains `x, y, vx, vy, fx, fy, mass, rest_x, rest_y`.
- `world.beams`: Array of beam tables. Each contains `n1, n2, L0, force, broken`.
- `world.max_force`: Maximum absolute force recorded in the current step.
- `world.peak_force`: Maximum absolute force recorded since `start()` was called.

## Configuration Options

You can override any of the following defaults by passing a config table to `Truss.new()`.

| Key | Default | Description |
|-----|---------|-------------|
| EA | 40000000 | Axial stiffness (force per unit deformation) |
| MAX_F | 900000 | Force threshold for beam fracture |
| BEAM_WT | 0.5 | Beam mass per pixel of rest length |
| NODE_BASE_MASS | 10 | Base mass added to every node |
| G | 500 | Gravitational acceleration in pixels per second squared |
| ZETA_AXIAL | 0.70 | Damping ratio for axial vibrations |
| ZETA_ANGULAR | 0.05 | Damping ratio for lateral swinging motion |
| SUBSTEPS | 16 | Number of Verlet substeps per frame |
| DT_MAX | 0.2 | Maximum allowed delta time per frame |

Example with custom gravity and stiffness:
```lua
local world = Truss.new({ G = 300, EA = 20000000 })
```

## Advanced Example

This example shows how to handle beam breakage, read state after simulation, and customize damping:

```lua
local Truss = require("truss")

local world = Truss.new({
  G = 600,
  MAX_F = 500000,
  ZETA_AXIAL = 0.80,
  ZETA_ANGULAR = 0.10
})

local base = world:add_node(200, 400)
local top = world:add_node(200, 200, { load = 10 })

world:pin(base, true, true)
world:add_beam(base, top)

world.on_beam_break = function(bm)
  print("Structural failure at beam connecting nodes " .. bm.n1 .. " and " .. bm.n2)
end

world:start()

local dt = 0.016
for i = 1, 300 do
  world:step(dt)
  if world:broken_count() > 0 then
    break
  end
end

print("Final position of top node:", world.nodes[2].x, world.nodes[2].y)
print("Peak force recorded:", world.peak_force)
```

## Notes for Beginners

- All indices in Lua are 1-based. The first node or beam you add will have index 1.
- Coordinates are in pixels. Positive y moves downward, matching standard 2D graphics systems.
- External loads are scalars multiplied by the gravity constant. A load of 5 with G=500 applies a downward force equivalent to a 5 unit mass.
- The simulation uses substeps internally for stability. You can safely pass a single delta time from your main loop.
- Broken beams stop transmitting forces but remain in the beams array with `broken = true`. They still contribute to visual rendering if needed.