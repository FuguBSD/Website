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

| Unit                                 | State   | Done by | Note                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------------ | ------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [SITE-CONTENT](site.md#site-content) | done    | —       | [index.body.html](../web/index.body.html)                                                                                                                                                                                                                                                                                                                                                                            |
| [SITE-BUILD](site.md#site-build)     | done    | —       | [.fuguwebrc](../.fuguwebrc), [publish.yml](../.github/workflows/publish.yml)                                                                                                                                                                                                                                                                                                                                         |
| [SITE-KEYS](site.md#site-keys)       | done    | —       | [.fuguwebrc](../.fuguwebrc), [web/keys](../web/keys). The first mint wrote the `keys` block, the `key` block, `fugubsd-1-release.pub`, `SHA256` and `SHA256.sig` in one commit.                                                                                                                                                                                                                                      |
| [SITE-ROTATE](site.md#site-rotate)   | partial | —       | [rotate-key.yml](../.github/workflows/rotate-key.yml), [rotate-key.t](../t/ci/rotate-key.t). Partly: SITE-ROTATE-1, because the first mint filled slot A and the variable, and slot B stays empty until the next mint. Absent: SITE-ROTATE-22, the order that a promote needs. Absent: SITE-ROTATE-27, the deployment-branch rule of the `releng` environment, which is a repository setting that the operator sets. |

## Update protocol

1. The change that implements a unit, or a part of one, sets the unit state in
   this register in the same change.
2. A `partial` note names each absent rule or part.
3. A `done` note holds at least one relative link to code or to tests.

## Code roots

The drift gate maps each document to the code that implements it.

| Document | Roots                                                  |
| -------- | ------------------------------------------------------ |
| site.md  | `web`, `.fuguwebrc`, `.github`, `scripts`, `t`, `deps` |

## Retired IDs

| ID             | Where the requirement went                    |
| -------------- | --------------------------------------------- |
| SITE-ROTATE-3  | FuguWeb WEB-ROTATE-2, the key pair            |
| SITE-ROTATE-6  | FuguWeb WEB-ROTATE-2, the serial              |
| SITE-ROTATE-7  | FuguWeb WEB-ROTATE-6, the signer of a mint    |
| SITE-ROTATE-8  | FuguWeb WEB-ROTATE-3 and -6, the first mint   |
| SITE-ROTATE-10 | FuguWeb WEB-ROTATE-6, the signer of a promote |
