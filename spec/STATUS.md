# Implementation register

This register is the one record of implementation state. One row exists for each
unit of the specification. A unit is one design element of one specification
document. The [conventions](index.md#conventions) define the unit IDs. Each row
describes the current state only. A row must not carry a plan name or a
reference to an earlier state. A note can carry the date of a recorded fact.

## States

| State   | Meaning                                                              |
| ------- | -------------------------------------------------------------------- |
| open    | No code implements the unit.                                         |
| partial | Code implements a part of the unit. The note names each absent part. |
| done    | Code implements the full unit. The note links the code or the tests. |
| n-a     | No code can implement the unit. It exists for citation only.         |

The "Done by" column names a phase of the [roadmap](ROADMAP.md), or "—" when no
phase applies.

## Units

| Unit                                 | State | Done by | Note                                                                         |
| ------------------------------------ | ----- | ------- | ---------------------------------------------------------------------------- |
| [SITE-CONTENT](site.md#site-content) | done  | —       | [index.body.html](../web/index.body.html)                                    |
| [SITE-BUILD](site.md#site-build)     | done  | —       | [.fuguwebrc](../.fuguwebrc), [publish.yml](../.github/workflows/publish.yml) |

## Update protocol

1. The change that implements a unit, or a part of a unit, sets the state of the
   unit in this register, in the same change.
2. A `partial` note names each absent rule or part.
3. A `done` note holds at least one relative link to code or to tests.

## Code roots

The drift gate maps each document to the code that implements it.

| Document | Roots                          |
| -------- | ------------------------------ |
| site.md  | `web`, `.fuguwebrc`, `.github` |

## Retired IDs

| ID  |
| --- |
