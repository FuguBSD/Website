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

| Unit                                 | State   | Done by | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------------ | ------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [SITE-CONTENT](site.md#site-content) | done    | —       | [index.body.html](../web/index.body.html)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| [SITE-BUILD](site.md#site-build)     | done    | —       | [.fuguwebrc](../.fuguwebrc), [publish.yml](../.github/workflows/publish.yml)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| [SITE-KEYS](site.md#site-keys)       | partial | —       | [rotate-key.yml](../.github/workflows/rotate-key.yml) derives each value that a directory decides, and the org word of SITE-KEYS-6 is one of them: `fugureleng` for `releng`, and `fuguadmin` for `admin`. The `releng` directory stands. `.fuguwebrc` holds its `keys` block, and `web/releng` holds each key file, the `SHA256` manifest and the `SHA256.sig` signature. The site serves `https://www.fugubsd.org/releng/fugureleng-1-release.pub`, and `deps/KEYS.txt` of the org pack pins that URL. Absent: the `admin` directory. SITE-KEYS-1 therefore holds for one directory, and SITE-KEYS-2, SITE-KEYS-3, SITE-KEYS-4, SITE-KEYS-5 and SITE-KEYS-7 hold for `releng` alone.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| [SITE-ROTATE](site.md#site-rotate)   | partial | —       | [rotate-key.yml](../.github/workflows/rotate-key.yml), [rotate-key.t](../t/ci/rotate-key.t). The caller pins the reusable workflow of FuguWeb to the commit of the v0.6.2 tag, and the callee holds SITE-ROTATE-5 at that commit. Absent: the `ADMIN` secrets and variables of SITE-ROTATE-1, because no `admin` mint has run. The organization holds the `releng` slot secrets, and the variables `RELENG_ROOT_SLOT` and `RELENG_RELEASE_SLOT`. Absent: `ADMIN_APP_ID` and `ADMIN_APP_PRIVATE_KEY` of SITE-ROTATE-4, which the operator writes by hand. The `releng` environment holds `RELENG_APP_ID` and `RELENG_APP_PRIVATE_KEY`. Absent: the declaration of each `admin` key in FuguBSD/Tooling, per SITE-ROTATE-11, SITE-ROTATE-21 and SITE-ROTATE-22. Tooling declares `fugureleng-1-release` in `deps/KEYS.txt` and in `org/sync/deps/KEYS.txt`, and the operator writes each declaration by hand. Absent: the read of the callee outputs. FuguWeb WEB-ACTIONS-2 and WEB-ACTIONS-10 give the caller that work, and the caller holds no step, per SITE-ROTATE-14. Absent: the deployment-branch rule of the `admin` environment, per SITE-ROTATE-27. The `releng` environment holds its rule, and the operator sets each one. |

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

| ID             | Where the requirement went                            |
| -------------- | ----------------------------------------------------- |
| SITE-ROTATE-3  | FuguWeb WEB-ROTATE-2, the key pair                    |
| SITE-ROTATE-6  | FuguWeb WEB-ROTATE-2, the serial                      |
| SITE-ROTATE-7  | FuguWeb WEB-ROTATE-6, the signer of a mint            |
| SITE-ROTATE-8  | FuguWeb WEB-ROTATE-3 and -6, the first mint           |
| SITE-ROTATE-9  | FuguWeb WEB-ACTIONS-7, the move of the variable       |
| SITE-ROTATE-10 | FuguWeb WEB-ROTATE-6, the signer of a promote         |
| SITE-ROTATE-12 | SITE-KEYS-7, the retention of a published key file    |
| SITE-ROTATE-13 | FuguWeb WEB-ACTIONS-12, the removal of each key file  |
| SITE-ROTATE-16 | FuguWeb WEB-ACTIONS-7, the mask of a new key          |
| SITE-ROTATE-17 | FuguWeb WEB-ACTIONS-4, the secret name of an input    |
| SITE-ROTATE-18 | FuguWeb WEB-ACTIONS-7, the order of the writes        |
| SITE-ROTATE-19 | FuguWeb WEB-ACTIONS-8, the start of the publish       |
| SITE-ROTATE-20 | FuguWeb WEB-ACTIONS-7, the read of the published site |
| SITE-ROTATE-23 | FuguWeb WEB-ACTIONS-7, the store before the commit    |
| SITE-ROTATE-24 | FuguWeb WEB-ACTIONS-8, the run that no step watches   |
| SITE-ROTATE-25 | Gone with the pull request that no job opens          |
| SITE-ROTATE-26 | Gone with the clone that no job makes                 |
