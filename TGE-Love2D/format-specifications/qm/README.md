# Space Rangers Quest (.qm) Binary Format Specification

This document describes the **legacy `.qm` quest binary format** used in *Space Rangers 2 / Dominators* and compatible engines (e.g. OpenSR).
It is based on reverse engineering, the OpenSR source code, and the 010 Editor template by VirRus77.

This specification applies **only to `.qm` files**, not to `.qmm`.

---

## General Notes

- All integer values are **little-endian**.
- Strings are stored as **UTF-16LE** (2 bytes per character).
- The format uses many **reserved / unknown fields** that must be read or skipped to keep alignment.
- The number of parameters is **fixed** per file and defined by the header magic.

---

## String Encodings

### BoolLengthString

```
int32 exist
int32 length
if exist == 1:
    wchar[length] characters   // UTF-16LE
```

- `exist = 0` → string is null / empty
- `exist = 1` → string present

### BoolLengthStringUse

```
int32 exist
if exist == 1:
    int32 length
    wchar[length] characters   // UTF-16LE
```

Used for most strings in `.qm`.

---

## Header

```
int32 magic
int32 unknown1

byte  questGiverRaces
byte  doneImmediately
int32 unknown2

byte  planetRaces
int32 unknown3

byte  playerTypes
int32 unknown4

byte  playerRaces
int32 relation

int32 pixelWidth
int32 pixelHeight
int32 sizeHorizontal
int32 sizeVertical

int32 unknown5
uint32 pathCount
uint32 difficulty
```

### Magic Values

| Magic        | Parameter Count |
|--------------|-----------------|
| 0x423A35D2   | 24              |
| 0x423A35D3   | 48              |
| 0x423A35D4   | 96              |

The magic value defines how many parameters exist **globally** in the quest.

---

## Parameters

There are exactly **CountParameters** parameter entries.

### Parameter Structure

```
int32 min
int32 max
int32 mid

byte  type               // normal / fail / success / death
int32 unknown1

byte  showOnZero
byte  minCritical
byte  active
byte  rangesCount
byte  unknown2[3]

byte  isMoney

string name

Range[rangesCount]

string critText
string startText
```

### Range

```
int32 from
int32 to
string text
```

---

## Global Quest Strings

```
string toStar
string parsec
string artefact
string toPlanet
string date
string money
string fromPlanet
string fromStar
string ranger
```

---

## Counts

```
int32 locationCount
int32 transitionCount
```

---

## Result Texts

```
string winnerText
string descriptionText
string unknownText
```

---

## Locations

There are **locationCount** locations.

### Location Header

```
int32 dayPassed
int32 x
int32 y
int32 id

byte start
byte success
byte fail
byte death
byte empty
```

The final location type is derived from these flags.

---

### Location Modifiers

For **every parameter**, a modifier block exists:

```
Modifier[CountParameters]
```

This block always exists, even if all modifiers are inactive.

### Modifier Structure

```
int32 unknown1

int32 rangeFrom
int32 rangeTo
int32 value

int32 visibility          // 0 = no change, 1 = show, 2 = hide

byte  units               // reserved
byte  percent
byte  assign
byte  expression

string expression
```

#### AcceptValue

```
int32 count
byte  include
int32[count] values
```

#### ModValue

```
int32 count
byte  include
int32[count] values
```

```
string unknownText        // usually crit text or padding
```

---

### Location Descriptions

```
string descriptions[10]
```

There are always **10 description slots**.

---

### Location Text Formula

```
byte  descriptionExpression
int32 unknown
string unknown1
string unknown2
string expression
```

---

## Transitions

There are **transitionCount** transitions.

### Transition Header

```
double priority
int32  dayPassed
int32  id
int32  fromLocationId
int32  toLocationId

byte   unknown
byte   alwaysVisible
int32  passCount
int32  position
```

---

### Transition Modifiers

```
Modifier[CountParameters]
```

Same structure as location modifiers.

---

### Transition Texts

```
string globalCondition
string title
string description
```

---

## Key Differences from .qmm

- `.qm` uses **fixed-size modifier arrays** (one per parameter).
- `.qmm` stores **only changed modifiers** with explicit parameter indices.
- `.qm` contains many reserved / legacy fields.
- `.qmm` is more compact and versioned.

These formats are **not compatible** and must be parsed separately.

---

## Status

This specification is sufficient to:
- parse `.qm` files correctly,
- convert `.qm` to structured data,
- re-encode `.qm` with correct alignment.

Unknown fields should be preserved when rewriting.

---

## References

- OpenSR source code (`QM.cpp`, `Parser.cpp`)
- 010 Editor template by VirRus77
- Reverse engineering and binary inspection
