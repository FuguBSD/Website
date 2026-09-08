# The main website

The site describes FuguBSD and lists the project websites. This document
specifies the content and the publication.

<a id="site-content"></a>

## Content

- **SITE-CONTENT-1** — The site must hold a description of FuguBSD and the list
  of the project websites.
- **SITE-CONTENT-2** — The project list is manual. A change that adds or removes
  a project website must edit `web/index.body.html` in the same change.
- **SITE-CONTENT-3** — All prose must comply with ASD-STE100 Simplified
  Technical English.

<a id="site-build"></a>

## Build and publication

- **SITE-BUILD-1** — fuguweb(1) must render the site from `.fuguwebrc` and
  `web/`, and `fuguweb check` must pass on the build.
- **SITE-BUILD-2** — The publish workflow must be a thin caller of the shared
  web publish workflow of Tooling, per Tooling WFL-WEB.
- **SITE-BUILD-3** — The site must publish at `www.fugubsd.org`. The
  Repositories project holds the Pages settings, per Repositories SET-PAGES.

<a id="site-keys"></a>

## The published keys

The organization publishes its public keys here, so a consumer install can fetch
a key and verify a release with it. FuguWeb holds the key directory, per FuguWeb
WEB-KEYS, and this site holds the description and the key files.

- **SITE-KEYS-1** — `.fuguwebrc` must hold one `keys` block with the
  organization word `fugubsd`, and the published prefix
  `https://www.fugubsd.org/keys`.
- **SITE-KEYS-2** — Each key must live in `web/keys/`, and one `key` block must
  describe it.
- **SITE-KEYS-3** — `web/keys/SHA256` and `web/keys/SHA256.sig` are source
  files. The site build cannot sign, so the rotation workflow writes both.
- **SITE-KEYS-4** — The first key must be `fugubsd-1-release.pub`, a signify key
  that signs the release assets.
- **SITE-KEYS-5** — The description block and the first key must land in one
  commit. A block that names an empty key directory fails every build.

<a id="site-rotate"></a>

## The rotation workflow

A workflow of this repository generates each release key and rotates it. No
human handles the private key at any point.

The workflow holds the credential, the organization state and the publication.
It holds no rotation logic: `fuguweb rotate-key` writes the key directory, and
FuguWeb WEB-ROTATE states every trust rule of that command. This repository
takes site content alone, per D-01.

- **SITE-ROTATE-1** — Two organization secrets `SIGNIFY_RELEASE_KEY_A` and
  `SIGNIFY_RELEASE_KEY_B` must hold the private keys, and the organization
  variable `SIGNIFY_RELEASE_SLOT` must name the active slot.
- **SITE-ROTATE-2** — Each secret must be visible to every repository that
  releases a Perl distribution, and to this repository. The shared release
  workflow runs in the caller, and this repository reads the active key to sign
  a manifest. A repository that releases nothing must hold no private key: it
  verifies with the published one.
- **SITE-ROTATE-4** — The workflow must mint its token from the release
  engineering GitHub App, and must bind the `releng` environment that holds the
  App credentials.
- **SITE-ROTATE-5** — The workflow must report the repositories that the token
  reaches, before it writes a secret, and must never print the token.
- **SITE-ROTATE-14** — The workflow must call `fuguweb rotate-key` for each
  step. It must install `fuguweb` from a release, and never from a checkout.
- **SITE-ROTATE-15** — Each install must run in its own step, before the step
  that mints the token, and must name the version that it installs. This job
  runs the installed code beside a private key, so a later release must not
  reach that key before a human reads the change.
- **SITE-ROTATE-16** — The workflow must mask the private key that a mint
  writes, and must pass it to a secret by file and never on a command line.
- **SITE-ROTATE-17** — Each secret name must carry the purpose word. The
  `secrets` context cannot build a name from an input, so the workflow must name
  its secrets literally, and it must refuse a purpose that it cannot address. A
  rotation of one purpose must never write the slot of another.
- **SITE-ROTATE-9** — The promote step must move the variable to the other slot.
- **SITE-ROTATE-18** — The workflow must move the organization variable only
  after the published site serves what the run wrote. The variable names the
  active slot, so a run that moved it and then failed would name a key that the
  site does not serve.
- **SITE-ROTATE-23** — The workflow must write the private key into the idle
  slot before it commits the key directory. No reader reaches the idle slot
  until the variable names it, and a later write could publish a key whose
  private half no slot holds.
- **SITE-ROTATE-19** — The workflow must start the publish of the site itself. A
  push that `GITHUB_TOKEN` makes raises no workflow run, so the site would never
  rebuild and the published URL would answer 404. `workflow_dispatch` is the one
  event that the token can raise.
- **SITE-ROTATE-24** — The workflow must watch no run of the publish. The
  publish holds a concurrency group, so one run can cancel another and a run
  identifier tells nothing. The site itself is the fact to read.
- **SITE-ROTATE-20** — The workflow must confirm that the published site serves
  every file that the run wrote, byte for byte, before it declares a key
  anywhere. A promote writes no key file, and a cache can answer 200 with older
  bytes.
- **SITE-ROTATE-11** — Each step must open a pull request against
  FuguBSD/Tooling that declares the key, with the published URL and the sha256
  of the file. A rotation without it breaks `make deps` in each consumer.
- **SITE-ROTATE-21** — That pull request must write `deps/KEYS.txt` and
  `org/sync/deps/KEYS.txt`. Tooling syncs the org pack into itself, so one copy
  alone leaves the other stale and fails the drift gate.
- **SITE-ROTATE-22** — A mint must append its line, which is the whole trust
  order: the current key leads the file, and the next key stands under it. A
  promote must lift its line to the top, and this workflow must hold no such
  edit, because D-01 takes site content alone. A promote must stop, and it must
  name the work that a maintainer does.
- **SITE-ROTATE-25** — The branch of that pull request must carry the run
  identifier, so a second run of one step opens its own pull request.
- **SITE-ROTATE-12** — A retired key file must stay published, so a release that
  it signed still verifies.
- **SITE-ROTATE-13** — The workflow must remove every private key file that it
  wrote, whatever the outcome of the run.
