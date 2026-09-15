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

| Unit                                 | State   | Done by | Note                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------ | ------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [SITE-CONTENT](site.md#site-content) | done    | —       | [index.body.html](../web/index.body.html)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| [SITE-BUILD](site.md#site-build)     | done    | —       | [.fuguwebrc](../.fuguwebrc), [publish.yml](../.github/workflows/publish.yml)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| [SITE-KEYS](site.md#site-keys)       | done    | —       | [.fuguwebrc](../.fuguwebrc), [web/releng](../web/releng), [web/admin](../web/admin), [rotate-key.yml](../.github/workflows/rotate-key.yml). Each directory stands. `.fuguwebrc` holds one `keys` block for each directory, and one `key` block for each key file. The org word is `fugureleng` for `releng`, and `fuguadmin` for `admin`. Each key file lives in the directory of its block. Each directory holds a `SHA256` manifest, a `SHA256.sig` signature, and a `current` key of the purpose `root`. Each root key is a signify key, and it signs the manifest of its directory. Each other key signs the root key file of its directory, which is the binding of FuguWeb WEB-TRUST. The bootstrap mint of each directory wrote the block, the first key and the manifest in one commit. No commit removed a key file, and a step of the workflow removes a binding file alone. The `admin` block names the contact address and the expiry of `security.txt`, and the `releng` block names neither.                                                                                                                                                                                                                                                                                                                                                                                                       |
| [SITE-ROTATE](site.md#site-rotate)   | partial | —       | [rotate-key.yml](../.github/workflows/rotate-key.yml), [rotate-key.t](../t/ci/rotate-key.t). The caller pins the reusable workflow of FuguWeb to the commit of the v0.6.2 tag, and the callee holds SITE-ROTATE-5 at that commit. The organization holds `RELENG_ROOT_KEY_A`, `RELENG_RELEASE_KEY_A`, `ADMIN_ROOT_KEY_A` and `ADMIN_CONTACT_KEY_A`, and each `_SLOT` variable names the slot `A`. Absent: the `_KEY_B` secret of each purpose of SITE-ROTATE-1. A mint writes the idle slot alone, so the first mint of a next key writes that secret. Each `releng` secret reaches this repository and each repository that releases a distribution, and each `admin` secret reaches this repository alone. SITE-ROTATE-2 therefore holds. The `releng` environment holds `RELENG_APP_ID` and `RELENG_APP_PRIVATE_KEY`, and the `admin` environment holds `ADMIN_APP_ID` and `ADMIN_APP_PRIVATE_KEY`. SITE-ROTATE-4 therefore holds for each environment. Each environment holds a deployment-branch rule that names `main` alone, so SITE-ROTATE-27 holds. Tooling declares `fugureleng-1-release` in `deps/KEYS.txt` and in `org/sync/deps/KEYS.txt`, per SITE-ROTATE-11 and SITE-ROTATE-21. An `admin` key signs no release, so no `admin` key takes a declaration. The caller holds no step, per SITE-ROTATE-14, so the operator reads each callee output from the run and writes each declaration by hand. |

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
