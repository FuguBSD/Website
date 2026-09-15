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

`deps/KEYS.txt` of the org pack pins one published key by URL and digest. A
consumer whose `dist` entry carries no recorded digest reaches the signify tier,
and it reads that key. Step 1 removed the file that the earlier URL answered.

This repository is not a broken consumer. `deps/SHA256.txt` records the digest
of each distribution that a key step installs, per SITE-ROTATE-32. A key step
therefore needs no published key.

## Work

1. The specification, the caller and the guards.
2. The pins of `deps/Darwin.txt` and `deps/Linux.txt`, and the digest that
   `deps/SHA256.txt` records for each one. The pins name Fugu v0.5.1 and FuguWeb
   v0.6.2. Each release carries a signed `SHA256` manifest, so SITE-ROTATE-32
   holds every digest to that manifest.
3. The operator writes the App credentials of each environment, and the
   deployment-branch rule of each one, per SITE-ROTATE-4 and SITE-ROTATE-27.
4. The operator runs the workflow with the step `mint`, the purpose `root`, the
   directory `releng` and the bootstrap flag. The run writes the `keys` block,
   the first key and the manifest in one commit, per SITE-KEYS-5.
5. The operator repeats step 4 for the `admin` directory.
6. The operator mints each subordinate key that a directory needs, such as the
   `release` purpose of `releng`.
7. Delete `plans/002-key-directories/`.

## Status

### What lands now

Steps 1 and 2 landed. The operator then ran step 3 for the `releng` environment,
step 4, and step 6 for the `release` purpose. The `releng` directory stands, and
`fugureleng-1-release` signs a release again. The two pins of step 2 name
releases that it signed.

### What waits, and on what

The `admin` directory waits on the operator. Step 3 gives it the App credentials
and the deployment-branch rule, and step 5 then mints its root key. Step 6 then
mints each subordinate key that it needs. Step 7 waits on step 5.

### What this plan does not resolve

The declaration of each new key in FuguBSD/Tooling, per SITE-ROTATE-11 and
SITE-ROTATE-21. Tooling holds the files that a declaration writes, so it is an
operator step of the rollout and not a step of this plan. Tooling declares
`fugureleng-1-release` today, and each `admin` key takes the same step.

The consumers that the signify tier serves. Each one takes a sync of
`deps/KEYS.txt`, or a recorded digest of its own. That work belongs to the
consumer and to Tooling.
