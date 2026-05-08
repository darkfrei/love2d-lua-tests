# Questlib

A Love2D module for writing, running, and saving text-based quests.
Quest data is written in plain Lua tables. No external dependencies.

---

## Module overview

The module is split into four layers:

- `questlib` (init.lua) -- public API, entry point for the game
- `runtime` -- manages state, resolves nodes and choices
- `validator` -- checks quest data for structural errors before loading
- `evaluator` -- resolves expressions and parses inline text

---

## Public API

```lua
local questlib = require('questlib')
```

### questlib.load(data)

Validates and loads a quest table. Enters the start node and returns its state.
Throws an error if validation fails.

```lua
local node = questlib.load(require('my_quest'))
```

### questlib.choose(index)

Executes a choice by its display index. Applies effects, resolves the transition,
and returns the new node state. Returns nil if the choice is disabled or consumed.

```lua
local node = questlib.choose(1)
```

### questlib.step()

Re-enters the current node without making a choice. Useful after manually
modifying state with set_state.

```lua
local node = questlib.step()
```

### questlib.get_state() / questlib.set_state(t)

Read or write the current variables table directly.

```lua
local state = questlib.get_state()
state.gold = state.gold + 100
questlib.set_state(state)
```

### questlib.save_state(path) / questlib.load_state(path)

Serialize and restore the variables table to/from a file.

```lua
questlib.save_state("saved_quest.lua")
```

```lua
questlib.load_state("saved_quest.lua")
```

### questlib.reset()

Clears all runtime state. Call before loading a new quest.

```lua
questlib.reset()
```

---

## Node state (return value)

Every function that advances the quest returns a node state table:

```lua
{
  id    = "tavern",
  text   = { ... },   -- flat list of rendered segments (see Text output)
  stats   = { ... },   -- flat list of rendered stat segments
  after_text = { ... },  -- rendered transition text from the previous choice, or nil
  choices  = {
    { index = 1, id = "buy_ale", label = "Buy ale", enabled = true },
    { index = 2, id = "leave",  label = "Leave",  enabled = false },
  }
}
```

`text`, `stats`, and `after_text` are all flat segment lists ready for rendering.
`choices` is the display list in sorted order. Use `index` to call `questlib.choose`.

---

## Variables

Variables are a flat key-value table defined under `variables` in the quest.
All keys are strings, values may be numbers, strings, or booleans.

```lua
variables = {
  gold    = 10,
  name    = "aria",
  has_key  = false,
  reputation = 0,
}
```

A reference to a variable is written as a string wrapped in angle brackets: `"<gold>"`.
This syntax is recognised by the evaluator in expressions and in inline text.

A bare value without angle brackets is a literal:

```lua
"<gold>"  -- variable reference, resolves to values["gold"]
10     -- literal number
"active"  -- literal string
true    -- literal boolean
```

---

## Expressions

All expressions are plain Lua tables. The operator at position 2 determines the type.

### Comparison (COMP)

Produces a boolean. Used in conditions, ternary conditions, and visibility rules.

Operators: `== != < > <= >=`

```lua
{"<gold>",    ">=", 10}
{"<status>",   "==", "active"}
{"<comms_on>",  "==", true}
```

### Arithmetic (EXPR)

Produces a number. Used as a value inside COMP or ASSI.

Operators: `+ - * / %`

```lua
{"<price>", "*", 2}
{"<gold>", "+", "<bonus>"}
```

### Assignment (ASSI)

Mutates a variable. Used inside effects only.

Operators: `= += -= *= /=`

```lua
{"<gold>",  "-=", 5}
{"<has_key>", "=", true}
{"<score>",  "+=", {"<bonus>", "*", 2}}
```

### Ternary

Evaluates a condition and returns one of two values. The else branch is optional.

```lua
{"?", condition, then_val, else_val}
```

```lua
{"?", {"<gold>", ">=", 10}, "rich", "poor"}
{"?", "has_credits", "Shop open", "Shop closed"}  -- condition ref
{"?", {"<gold>", ">=", 10},
  {"?", {"<rep>", ">", 5}, "rich and known", "rich"},
  "poor"
}
```

The condition may be a COMP expression or a string reference to `shared_conditions`.

---

## Quest file structure

A quest is a single Lua table returned from a file.

```lua
return {
  id     = "my_quest",
  start_node = "intro",
  variables = { ... },

  shared_conditions = { ... },
  shared_effects  = { ... },
  shared_snippets  = { ... },
  shared_stats   = { ... },
  shared_choices  = { ... },

  nodes = { ... },
}
```

All `shared_` sections are dictionaries keyed by id.
They are optional -- inline definitions inside nodes are always valid.

---

## shared_conditions

Named condition expressions. Referenced by string key in visible, enabled,
ternary conditions, and snippet conditions.

```lua
shared_conditions = {
  has_gold  = {"<gold>",    ">=", 10},
  has_key   = {"<has_key>",  "==", true},
  threat_high = {"<threat>",   ">", 5},
  comms_on  = {"<comms>",   "==", true},
}
```

Usage by reference:

```lua
visible = "has_gold"
enabled = "has_key"
{"?", "threat_high", "Alert: CRITICAL", "Alert: Normal"}
```

---

## shared_effects

Named effect lists. Each entry is an array of ASSI expressions.
Referenced by string key in choice effects.

```lua
shared_effects = {
  spend_gold = {
    {"<gold>", "-=", 10}
  },
  siphon_fuel = {
    {"<fuel>", "+=", 25},
    {"<fuel>", "=", {"?", {"<fuel>", ">", 100}, 100, "<fuel>"}},
    {"<threat>", "+=", 2},
  },
}
```

Usage by reference:

```lua
effects = "spend_gold"
effects = "siphon_fuel"
```

Inline effects (not shared) are written as an array directly on the choice:

```lua
effects = {
  {"<gold>", "-=", 5},
  {"<visited>", "=", true},
}
```

---

## shared_snippets

Named expressions or strings inserted into text by reference.
A snippet is either a plain string or a ternary that resolves to a string.

```lua
shared_snippets = {
  power_status = {"?", "has_fuel",
    "Reactor output: **stable**.",
    "Reactor output: **critical**."},
    
  comms_status = {"?", "comms_on",
    "Long-range comms: **online**.",
    "Long-range comms: **offline**."},
  threat_line = "Threat Level: <threat>",
}
```

Used in text or stats arrays:

```lua
text = {
  "The hub hums. ",
  {"snippet", "power_status"},
  " Comms report: ",
  {"snippet", "comms_status"},
}
```

The ternary condition inside a snippet may be a string reference to `shared_conditions`
or a full COMP expression.

---

## shared_stats

Named stat groups. Each group is an array of strings, ternary expressions, or snippet refs.
Expanded inline when referenced by key inside a node's stats array.

```lua
shared_stats = {
  global = {
    "Crew: <player_name>",
    "Credits: <credits>",
    "Fuel: <fuel>%",
    {"snippet", "threat_line"},
    {"?", "threat_high", "Alert: ==CRITICAL==", "Alert: Normal"},
  }
}
```

Usage inside a node:

```lua
stats = { "global", "Location: Engineering Bay" }
```

String entries in stats are resolved in order: if the key exists in shared_stats,
it is expanded; otherwise the string is treated as a literal text line.

---

## shared_choices

Named choices available across all nodes. Referenced by string key inside
a node's choices array.

```lua
shared_choices = {
  return_hub = {
    label  = "Head back to the Central Hub",
    priority = 10,
    transition = { target = "hub" }
  },
  global_rest = {
    label  = "Rest and let the scrubbers cycle (+15 oxygen, -10 credits)",
    visible = {"<oxygen>", "<", 90},
    enabled = "has_credits",
    priority = 2,
    once   = true,
    effects = "rest_quarters",
    transition = {
      text  = {"Scrubbers ran a full cycle. **Oxygen +15. Credits -10.**"},
      target = "hub"
    }
  },
}
```

Shared choices get their `id` injected automatically from the dictionary key.
This id is used for `once` and `consumed` tracking.

---

## Nodes

Each node is an entry in the `nodes` array.

```lua
{
  id   = "engineering",
  text  = { ... },
  stats  = { ... },
  choices = { ... },
}
```

### text

Array of strings, ternary expressions, and snippet refs.
Strings may contain inline markdown and variable references (`<varname>`).

```lua
text = {
  "The reactor hums. ",
  {"snippet", "power_status"},
  "\nFuel remaining: **<fuel>%**.",
  {"?", {"<fuel>", "<=", 10}, " **Warning: critical.**", ""},
}
```

### stats

Array of strings, ternary expressions, and snippet refs.
Strings are either a shared_stats group key or a literal stat line.

```lua
stats = {
  "global",
  "Location: Engineering Bay",
  "Reactor: ==Unstable==",
  {"?", "comms_on", "Comms: **Active**", "Comms: ==Dead=="},
}
```

### choices

Array of shared choice keys (strings) and inline choice tables, in display order.

```lua
choices = {
  "global_rest",
  {
    id    = "siphon",
    label  = "Siphon fuel from auxiliary tanks (+25 fuel, +2 threat)",
    visible = "fuel_not_full",
    enabled = "siphon_limit",
    priority = 0,
    effects = "siphon_fuel",
    transition = {
      text  = {"Auxiliary reserves drained. **Fuel: <fuel>%.**"},
      target = "engineering"
    }
  },
  "return_hub"
}
```

---

## Choice fields

| field   | type          | description                   |
|------------|-------------------------|--------------------------------------------------|
| id     | string         | unique identifier, required for once/consumed  |
| label   | string         | display text shown to the player         |
| visible  | cond ref or COMP    | hides choice if false, default true       |
| enabled  | cond ref or COMP    | greys out choice if false, still shown      |
| priority  | number         | lower = shown first, default 0          |
| once    | boolean         | hidden after first use              |
| consumed  | boolean         | hidden after first use, also removes from node  |
| effects  | effect ref or ASSI list | applied when choice is taken           |
| transition | table          | text and/or target node after choice is taken  |

Only one of `once` and `consumed` may be set on a single choice.

### Transition

```lua
transition = {
  text  = {"Array repaired. **Credits: <credits>.**"},
  target = "comms_room"
}
```

`text` is optional. If omitted, no after_text is produced.
`target` is optional. If omitted, the current node is re-entered.
`text` follows the same format as node text (strings, ternary, snippet refs).

---

## Text output (rendered segments)

The evaluator returns a flat array of segment tables. Each segment has a `text` field
and an optional `style` field.

```lua
{ text = "the innkeeper nods " }
{ text = "respectfully", style = "i" }
{ text = "aria",     style = "bh" }
```

Style flags:

| flag | meaning    |
|------|---------------|
| b  | bold     |
| i  | italic    |
| m  | monospace   |
| s  | strikethrough |
| h  | highlight   |

Flags combine freely. A segment with no styling omits the style field.

### Inline markdown

| syntax    | style flag |
|--------------|------------|
| `**text**`  | b (bold)  |
| `*text*`   | i (italic) |
| `` `text` `` | m (mono)  |
| `~~text~~`  | s (strike) |
| `==text==`  | h (highlight, used for place names and titles) |

Variable references inside strings (`<varname>`) are always rendered with the h flag.

---

## Evaluator rules

Resolution order inside `evaluator.resolve`:

1. A string matching `^<[%w_]+>$` is a variable reference -- look up in values.
2. A table with `t[1] == "?"` is a ternary -- evaluate condition, recurse into then or else.
3. A table with `t[2]` in `== != < > <= >=` is a COMP -- return boolean.
4. A table with `t[2]` in `+ - * / %` is an EXPR -- return number.
5. A table with `t[2]` in `= += -= *= /=` is an ASSI -- mutate values, return nil.
6. Anything else is returned as a literal.

Condition string references (`"has_gold"`, `"comms_on"`) are resolved to their
COMP expression by the runtime before being passed to the evaluator.
The evaluator itself only sees raw expressions, never string keys.

---

## Validation

`questlib.load` runs a full validation pass before entering the runtime.
Errors are printed with a path and description:

```
[VALIDATION ERROR] nodes.engineering.choices[1].enabled: cond ref not found (got: has_gold_typo)
[VALIDATION ERROR] shared_effects.siphon_fuel[2]: must be assignment (got: >=)
```

Validation checks:

- All referenced conditions, effects, snippets, choices exist in their shared maps
- Expressions have the correct structure and operator
- Assignments are only used in effect context
- Choice flags (once, consumed) are not combined
- start_node exists in the nodes array
- Every node has an id and a text array

---

## Minimal quest example

```lua
return {
  id     = "demo",
  start_node = "start",
  variables = { gold = 10, visited_market = false },

  shared_conditions = {
    is_rich = {"<gold>", ">=", 20},
  },

  nodes = {
    {
      id  = "start",
      text = { "You stand at a crossroads. You have **<gold>** coins." },
      choices = {
        {
          id     = "go_market",
          label   = "Visit the market",
          effects  = { {"<visited_market>", "=", true} },
          transition = { target = "market" }
        },
        {
          id     = "go_forest",
          label   = "Enter the forest",
          transition = { target = "forest" }
        },
      }
    },
    {
      id  = "market",
      text = {
        "The market is busy. ",
        {"?", "is_rich", "Merchants eye you with interest.", "Merchants ignore you."},
      },
      choices = {
        {
          id     = "buy",
          label   = "Buy supplies (-10 gold)",
          enabled  = "is_rich",
          effects  = { {"<gold>", "-=", 10} },
          transition = { text = {"You spend 10 gold."}, target = "start" }
        },
        { id = "leave", label = "Leave", transition = { target = "start" } },
      }
    },
    {
      id  = "forest",
      text = { "The forest is quiet. Nothing happens." },
      choices = {
        { id = "back", label = "Go back", transition = { target = "start" } }
      }
    },
  }
}
```
