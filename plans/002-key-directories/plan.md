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

Five consumers break: FuguBench, FuguSeed, FuguTTX, FuguVM and FuguWeb. Measured
on 2026-09-15. To measure it again, list the organization:

```sh
gh repo list FuguBSD --limit 50 --json name --jq '.[].name'
```

Then read `deps/Linux.txt`, `deps/Darwin.txt` and `deps/OpenBSD.txt` of each
name for a `dist` entry. Read `deps/SHA256.txt` of the same name for a digest of
that URL. A `dist` entry with no recorded digest breaks. Fourteen of the names
pin the key.

Do not count the clones of `Projects/`. That list is short, and it gives a low
number. The workspace holds no clone of FuguBench, and none of FuguSeed, and
both of them break.

FuguWeb is on both sides of that list. It is one of the five, and its reusable
workflow is the one that a key step of this site runs. FuguWeb therefore had to
repair its own `make deps` before it made the release that this repository pins.
That order was not in this plan.

This repository is not one of the five. `deps/SHA256.txt` records the digest of
each distribution that a key step installs, per SITE-ROTATE-32. A key step
therefore runs while the site serves no key directory.

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
6. Delete `plans/002-key-directories/`.

## Status

### What lands now

Step 1 landed. This change moves the FuguWeb pin to v0.6.1. That release names
the install root of the key workflow, so `fuguweb` and its modules both reach
the later steps.

### What waits, and on what

Steps 2 to 6 wait on the operator. Step 3 waits on step 2, because a run without
the App credentials mints no token.

### What this plan does not resolve

The declaration of each new key in FuguBSD/Tooling, per SITE-ROTATE-11 and
SITE-ROTATE-21. Tooling holds the files that a declaration writes, so it is an
operator step of the rollout and not a step of this plan. It waits on the key of
step 3, because a declaration needs the published URL and the digest of a key
file.

The five consumers that the signify tier serves. Each one takes a recorded
digest, or the new key of the declaration. That work belongs to the consumer and
to Tooling. FuguWeb is done, because it recorded the digest of its own Fugu
dependency and then it released v0.6.1. Four consumers remain.
