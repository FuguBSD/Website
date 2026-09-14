# 002 — The two key directories

Implements: SITE-KEYS. Implements: SITE-ROTATE.

## Purpose

This plan gives the site two key directories. The `releng` directory holds the
keys that sign the releases, and the `admin` directory holds the keys that reach
the administrators. Each directory takes a root of trust of its own, per
SITE-KEYS-4.

The design, the thin caller and the guards land in one change. A run of the
rotation workflow then writes each key, because no human handles a private key.

## Why the order matters

`deps/KEYS.txt` of the org pack pins one published key by URL and digest, and
this change removes the file that the URL answers. A consumer whose `dist` entry
carries no recorded digest reaches the signify tier, and its `make deps` then
fails.

Measured on 2026-09-15, over the clones of this workspace: eleven repositories
pin that key, and three of them hold such an entry. The three are FuguTTX,
FuguVM and FuguWeb.

This repository is not one of them. `deps/SHA256.txt` records the digest of each
distribution that a key step installs, per SITE-ROTATE-32. A key step therefore
runs while the site serves no key directory.

## Work

1. The specification, the caller and the guards. This change.
2. The operator writes the App credentials of each environment, and the
   deployment-branch rule of each one, per SITE-ROTATE-4 and SITE-ROTATE-27.
3. The operator runs the workflow with the step `mint`, the purpose `root`, the
   directory `releng` and the bootstrap flag. The run writes the `keys` block,
   the first key and the manifest in one commit, per SITE-KEYS-5.
4. The operator repeats step 3 for the `admin` directory.
5. The operator mints each subordinate key that a directory needs, such as the
   `release` purpose of `releng`.
6. The operator declares each new key in FuguBSD/Tooling, per SITE-ROTATE-11 and
   SITE-ROTATE-21.
7. Delete `plans/002-key-directories/`.

## Status

### What lands now

Step 1.

### What waits, and on what

Steps 2 to 7 wait on the operator. Step 3 waits on step 2, because a run without
the App credentials mints no token. Step 6 waits on the key of step 3, because a
declaration needs the published URL and the digest of a key file.

### What this plan does not resolve

The three consumers that the signify tier serves. Each one takes a recorded
digest, or the new key of step 6. That work belongs to the consumer and to
Tooling.
