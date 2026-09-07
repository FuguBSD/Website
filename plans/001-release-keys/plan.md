# 001 — The release keys of FuguBSD

## Status

Proposed.

## Purpose

FuguBSD signs its releases, and a consumer install verifies the signature. The
verification needs a published public key. No key is published, so no consumer
can verify anything.

This site is the publication point. This plan adds the key directory to the
site, and it adds the workflow that generates each key and rotates it.

## Why this blocks the organization

`scripts/deps` of the org pack verifies a download in two tiers. The digest tier
needs a recorded sha256. The signify tier needs a published key, and
`deps/KEYS.txt` of Tooling declares each key by URL and digest.

`deps/KEYS.txt` declares no key today. Three consumers therefore cannot sync the
org pack: FuguTTX, FuguVM and FuguWeb each hold a `dist` entry on a stable URL,
which takes no useful digest and needs the signify tier. The Perl release
workflow of Tooling also cannot sign, because no key exists to sign with.

The first key publishes here, and it unblocks all of it.

## Evidence

### The site can publish a key directory

FuguWeb holds the key directory, and the WEB-KEYS unit of its specification
states the contract. A `keys` block names the source directory and the
organization word, and one `key` block for each key holds the status and the
dates. The build copies each key file and the manifest pair as they stand. It
generates the `KEYS` file, the human page, the Web Key Directory tree and
`security.txt`.

The publish workflow installs fuguweb from the latest release, so this work
needs the FuguWeb release that carries WEB-KEYS.

### The site build cannot sign

A site build runs no `signify(1)`, and the Pages runner holds no key. The
manifest pair `web/keys/SHA256` and `web/keys/SHA256.sig` is therefore a source
file. The rotation workflow writes both, and it commits them.

### The apex serves the well-known paths

Measured on 2026-09-07. `fugubsd.org` resolves to the GitHub Pages addresses,
and it answers with a 301 to `https://www.fugubsd.org/`. The redirect keeps the
path and the query. The Repositories project does not manage DNS, per
Repositories SET-PAGES-3, and the records already exist at the registrar.

The first key is a signify key, which holds no email address, so this plan
generates no Web Key Directory tree. The question of whether gpg follows the
redirect arrives with the first OpenPGP key, and not with this plan.

### The credential exists

FuguBSD holds a GitHub App for release engineering. It is installed on the
organization, its repository access is FuguBSD/Tooling only, and its permissions
are organization secrets and variables, with Tooling contents and pull requests.

This repository holds an Actions environment named `releng`. The environment
holds the secrets `RELENG_APP_ID` and `RELENG_PRIVATE_KEY`. No key material and
no token needs a human.

## Design

### The key names

A key file is `<org>-<serial>-<purpose>.<ext>`, and `Fugu::KeyDir` holds the
pattern. The organization word is `fugubsd`. The serial starts at 1 for each
purpose, and each rotation of that purpose adds one. The purpose names what the
key signs, so `release` signs the release assets.

The first key is `fugubsd-1-release.pub`. Its untrusted comment is
`fugubsd-1-release public key`, which is what `signify -G -c fugubsd-1-release`
writes.

### The published tree

    web/keys/fugubsd-1-release.pub   the key, byte for byte
    web/keys/SHA256                  the digest of every key file
    web/keys/SHA256.sig              the signature of the manifest

The build then publishes:

    https://www.fugubsd.org/keys/fugubsd-1-release.pub
    https://www.fugubsd.org/keys/SHA256
    https://www.fugubsd.org/keys/SHA256.sig
    https://www.fugubsd.org/keys/index.html

Tooling `deps/KEYS.txt` names the first URL and the sha256 of that file.

### The description

    keys "keys" {
    	org = fugubsd
    	url = https://www.fugubsd.org/keys
    }

    key "fugubsd-1-release" {
    	status = current
    	since  = 2026-09-07
    }

The block names no contact, so the build writes no `security.txt`. A contact
needs an expiry, and an expiry that nothing renews becomes a stale promise. The
contact arrives with the first OpenPGP key.

### The two secret slots

Two organization secrets hold the private keys, and one organization variable
names the active slot:

| Name                    | Kind     | Value                 |
| ----------------------- | -------- | --------------------- |
| `SIGNIFY_RELEASE_KEY_A` | secret   | a signify private key |
| `SIGNIFY_RELEASE_KEY_B` | secret   | the other slot        |
| `SIGNIFY_RELEASE_SLOT`  | variable | `A` or `B`            |

The names are fixed, and the variable moves. A workflow that named one fixed
secret could not rotate without a human, and a workflow that renamed a secret
would break every caller that reads it.

Each secret takes the visibility of the repositories that release a Perl
distribution: Fugu, FuguVM, FuguWeb and FuguTTX. `perl-release.yml` runs in the
caller's repository, so a secret that only this repository reads is useless to
it.

A workflow reads the active key with
`secrets[format('SIGNIFY_RELEASE_KEY_{0}', vars.SIGNIFY_RELEASE_SLOT)]`.

The key pair comes from `signify -G -n`, with no passphrase. CI cannot answer a
passphrase prompt, so the secret is the whole protection of the private key.

### The rotation workflow

`.github/workflows/rotate-key.yml` runs on a manual dispatch. It takes the
purpose, which defaults to `release`, and the step, which is `mint` or
`promote`.

The job binds `environment: releng`, because both App secrets live there. A job
without that binding reads neither one.

It mints an installation token with `actions/create-github-app-token`. It passes
no `repositories` input: the organization permissions of the installation are
what the secret writes need, and the installation reaches Tooling alone in any
case.

**The first run is special.** The directory holds no key of the purpose. The
workflow generates serial 1, sets its status to `current`, writes the private
key into slot A, sets the variable to `A`, and signs the manifest with the key
itself. There is no `next` key and no second step.

**The mint step, on a later run.** The workflow reads the highest serial of the
purpose and adds one, through `Fugu::KeyDir->next_serial`. It generates the
pair, writes the public key with a `key` block of status `next`, and writes the
private key into the inactive slot. The variable does not move. It rewrites
`keys/SHA256` over every key file and signs it with the **current** key, so the
current key vouches for the next one. It commits to this repository, and it
opens a pull request against Tooling that adds the next key as the second line
of `org/sync/deps/KEYS.txt`.

**The promote step.** It runs after the Tooling pull request merges and after
each consumer syncs it. It sets the `next` key to `current` and the old
`current` key to `retired`. It flips the variable to the other slot. It signs
`keys/SHA256` with the new current key. It opens a pull request against Tooling
that moves the new key to the top of `deps/KEYS.txt`.

The pull request is a requirement and not an option. It is the human review that
stops a compromised current key from minting a successor that every consumer
trusts.

### The token check

No session has minted a token from this App. The first run must therefore report
what the token carries before it writes a secret. The report names the
installation permissions, and it never names the token. A token with no
organization permission fails at the write, and the message of that failure does
not name the cause.

### The tool environment

`deps/Linux.txt` gains `tool pkg signify-openbsd`. The workflow runs
`make deps tool` and gets the command. The manifest holds no other line, so no
digest file is needed.

## The units

The implementation adds two units to `spec/site.md`:

- `SITE-KEYS` — the published key directory: the description blocks, the
  published paths, and the rule that the manifest pair is a source file.
- `SITE-ROTATE` — the rotation workflow: the two secret slots, the variable, the
  App credential, the first run, the mint step, the promote step, and the
  Tooling pull request.

The implementation sets both rows in `spec/STATUS.md`.

## Work

1. `deps/Linux.txt`: the file, with `tool pkg signify-openbsd`.
2. `.fuguwebrc`: the `keys` block and the `key` block of the first key.
3. `.github/workflows/rotate-key.yml`: the workflow above.
4. `spec/site.md` and `spec/STATUS.md`: the two units and their rows.
5. Run the workflow once, on the `release` purpose, and let it commit
   `web/keys/`.
6. Delete `plans/001-release-keys/`.

## Status

### What lands now

Every step above. The FuguWeb release that carries WEB-KEYS must publish first,
because the publish workflow installs fuguweb from the latest release.

### What waits

- Tooling declares the key in `org/sync/deps/KEYS.txt`, from the pull request
  that step 5 opens. That work belongs to Tooling.
- The three blocked consumers sync the org pack after that merge.
- `perl-release.yml` of Tooling signs each Perl release with the key.

### What this plan does not resolve

The first OpenPGP key. It needs a contact, an expiry, a `KEYS` file and a Web
Key Directory tree, and it needs a check that gpg follows the apex redirect. A
signify key and an OpenPGP key take two purposes, per Fugu LIB-KEYDIR-2, so the
OpenPGP key starts at serial 1 of its own purpose. It is the next change.

Decision 6 of the deps verification work puts the private key in CI. The
signature then proves that the asset store holds the bytes that CI built. It
does not prove that CI is honest. The operator accepts that cost.
