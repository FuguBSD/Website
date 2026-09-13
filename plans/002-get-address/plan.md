# 002 — The install address of FuguBench

## Status

It lands now, and it waits on nothing in this repository. FuguBench
DIST-INSTALL-3 waits on it. This site serves a stub that runs the release
script, and not the release script itself. FuguBench must reword FuguBench
DIST-INSTALL-3 in a change of its own.

Implements: SITE-GET.

## Purpose

FuguBench writes `install.sh` into each release. A document and a reader need
one address that stays the same across a release. This site is the one place
that serves such an address, so the stub lands here.

## Steps

### 1. The file `web/get`

Add the file with mode 644, and with this content:

```sh
#!/bin/sh
# The install address of FuguBench. The published command is:
#	curl -fsSL https://fugubsd.org/get | sh

set -e

url=https://github.com/FuguBSD/FuguBench/releases/latest/download/install.sh
script=$(curl -fsSL "$url")
exec sh -c "$script"
```

The mode is 644. The visitor pipes the file to `sh`, and no one runs the file
from the checkout.

The assignment holds the fetch, and `set -e` stops the run when the fetch fails.
A pipeline into `sh` runs an empty script on a failed fetch, and it exits 0.
`curl` fetches this file in the published command, so `curl` is on the host.

The file needs no entry in `.fuguwebrc`, per SITE-GET-1.

### 2. The test `t/ci/get.t`

`make test` runs `prove` on `t/ci/*.t`, so the test lands there. It must assert
three facts about `web/get`:

- `sh -n web/get` exits 0. The stub is POSIX shell.
- The stub holds the release URL
  `https://github.com/FuguBSD/FuguBench/releases/latest/download/install.sh`.
- The stub runs `curl` and `sh`, and no other command. The test reads each word
  that starts a command, and it fails on a word outside that pair.

### 3. The register

Set the `SITE-GET` row of the register to `done`, with a link to `web/get` and
to `t/ci/get.t`.

### 4. This plan

Delete this plan directory in the same change.

## Proof

- `fuguweb build --out web/build` copies `web/get` to `web/build/get`, byte for
  byte.
- `fuguweb check --out web/build` passes.
- `make check` passes. It runs the test of step 2.
