# Questlib notation reference

A love2d module for creating, playing, editing and saving text quests.

---

## Values and references

Variables are stored in a flat `values` table with string keys.

```lua
values = {
    gold          = 10,
    name          = "aria",
    status        = "active",
    met_alchemist = false,
}
```

A reference to a variable is written as `<varname>` — a string wrapped in angle brackets.
A bare value without angle brackets is a literal (number, string, or boolean).

```lua
"<gold>"      -- reference: resolves to values["gold"]
10            -- literal number
"active"      -- literal string
true          -- literal boolean
```

Positional references use `p1`, `p2`, `p3`, ... as keys:

```lua
"<p1>"        -- values["p1"]
"<p2>"        -- values["p2"]
```

---

## Expression types

All expressions are plain lua tables. The type is inferred from the operator at position 2 (or position 1 for CTE).

### COMP — comparison

Produces a boolean.

```
{value1, op, value2}
```

Operators: `==  !=  <  >  <=  >=`

```lua
{"<gold>",       ">=", 10}
{"<gold>",       "==", 0}
{"<status>",     "==", "active"}
{"<reputation>", ">=", 70}
```

### EXPR — arithmetic expression

Produces a number. Used as a value inside COMP or ASSI.

```
{value1, op, value2}
```

Operators: `+  -  *  /  %`

```lua
{"<price>", "*", 2}
{"<gold>",  "+", "<bonus>"}
```

The evaluator distinguishes COMP from EXPR by the operator symbol.

### ASSI — assignment

Used inside jump `effects`. Mutates `values`.

```
{target, op, value}
```

Operators: `=  +=  -=  *=  /=`

```lua
{"<gold>",          "-=", 5}
{"<gold>",          "=",  0}
{"<met_alchemist>", "=",  true}
{"<score>",         "+=", {"<bonus>", "*", 2}}  -- EXPR as value
```

### CTE — conditional expression

Produces one of two values depending on a condition.

```
{"?", condition, then_val, else_val}
```

`else_val` is optional and defaults to `nil`.
`condition` is any expression that produces a boolean (typically a COMP).

```lua
{"?", {"<gold>", ">=", 10}, "branch_a", "branch_b"}
{"?", {"<reputation>", ">=", 70}, "branch_a", "branch_b"}
```

Nesting is allowed:

```lua
{"?", {"<gold>", ">=", 10},
    {"?", {"<reputation>", ">=", 5}, "rich and known", "rich"},
    "poor"
}
```

Right-hand side of COMP may be an EXPR:

```lua
{"?", {"<gold>", ">=", {"<price>", "*", 2}}, true, false}
```

CTE as a value inside ASSI — price doubles if the player has more than 1000 gold:

```lua
{"<price>", "*=", {"?", {"<gold>", ">", 1000}, 2, 1}}
```

---

## Text format

Node text is a lua table of segments. Each segment is either a plain string or a CTE that resolves to a string.

```lua
text = {
    "you enter the tavern. ",
    {"?", {"<gold>", ">=", 10}, "you are **wealthy**", "your pockets are `empty`"},
    " the innkeeper looks at **<name>**.",
}
```

The evaluator walks the table, resolves each segment, then parses inline markdown.

### Inline markdown

Standard markdown subset is used for styling within string segments.

| syntax         | meaning       |
|----------------|---------------|
| `**text**`     | bold          |
| `*text*`       | italic        |
| `` `text` ``   | monospace     |
| `~~text~~`     | strikethrough |
| `<varname>`    | variable reference, resolves and renders as highlight |

### Evaluated output (segments)

The evaluator returns a flat list of segment tables.

```lua
-- text at gold = 3, name = "aria"
{
    { text = "you enter the tavern. " },
    { text = "your pockets are " },
    { text = "empty",    style = "m"  },  -- monospace from `empty`
    { text = ". the innkeeper looks at " },
    { text = "aria",     style = "bh" },  -- bold + highlight from **<name>**
}
```

`style` is a string mask. Flags are combined freely:

| flag | meaning       |
|------|---------------|
| `b`  | bold          |
| `i`  | italic        |
| `m`  | monospace     |
| `s`  | strikethrough |
| `h`  | highlight     |

A segment with no style flags omits the `style` field entirely.
Variable references (`<varname>`) always receive the `h` flag unless overridden by surrounding markup.

---

## Quest structure

### Quest

```lua
{
    id          = "my_quest",
    title       = "the alchemist",
    description = "a short quest about gold and reputation",
    variables   = {
        gold          = 10,
        reputation    = 0,
        met_alchemist = false,
    },
    start_node  = "intro",
    nodes       = { ... },
}
```

### Node

```lua
{
    id   = "tavern",
    text = {
        "the innkeeper eyes you. ",
        {"?", {"<gold>", ">=", 10}, "he nods *respectfully*", "he sneers"},
        ". you have **<gold>** coins.",
    },
    jumps = { ... },
}
```

### Jump

```lua
{
    id        = "buy_ale",
    label     = "buy ale (5 coins)",
    condition = {"<gold>", ">=", 5},       -- COMP, optional
    effects   = {
        {"<gold>", "-=", 5},               -- list of ASSI
    },
    target    = "tavern_drink",            -- node id
}
```

`condition` is optional. If absent, the jump is always shown.
`effects` is applied in order when the jump is taken.
Jumps are presented to the player in randomised order.

---

## Evaluator rules

1. A string matching `^<[%w_]+>$` is a variable reference — look up in `values`.
2. A table with `t[1] == "?"` is a CTE — evaluate condition, recurse into then or else.
3. A table with `t[2]` matching `== != < > <= >=` is a COMP — return boolean.
4. A table with `t[2]` matching `+ - * / %` is an EXPR — return number.
5. A table with `t[2]` matching `= += -= *= /=` is an ASSI — mutate values, return nil.
6. Anything else is a literal — return as-is.
