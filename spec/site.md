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

- **SITE-ROTATE-1** — Two organization secrets `SIGNIFY_RELEASE_KEY_A` and
  `SIGNIFY_RELEASE_KEY_B` must hold the private keys, and the organization
  variable `SIGNIFY_RELEASE_SLOT` must name the active slot.
- **SITE-ROTATE-2** — Each secret must be visible to the repositories that
  release a Perl distribution, because the shared release workflow runs in the
  caller.
- **SITE-ROTATE-3** — The key pair must come from `signify -G -n`, with no
  passphrase. CI cannot answer a passphrase prompt.
- **SITE-ROTATE-4** — The workflow must mint its token from the release
  engineering GitHub App, and must bind the `releng` environment that holds the
  App credentials.
- **SITE-ROTATE-5** — The workflow must report the reach of the token before it
  writes a secret, and must never print the token.
- **SITE-ROTATE-6** — The mint step must take the highest serial of the purpose
  and add one. It must write the private key into the idle slot, and must leave
  the variable alone.
- **SITE-ROTATE-7** — The mint step must sign the manifest with the current key,
  so the current key vouches for the next one.
- **SITE-ROTATE-8** — The first mint of a purpose finds no current key. It must
  make the new key `current` at once, and the key must sign its own manifest.
- **SITE-ROTATE-9** — The promote step must make the `next` key `current`, must
  retire the old current key with an `until` date, and must move the variable to
  the other slot.
- **SITE-ROTATE-10** — The promote step must sign the manifest with the key that
  it makes current.
- **SITE-ROTATE-11** — Each step must open a pull request against
  FuguBSD/Tooling that declares the key in `deps/KEYS.txt`, with the published
  URL and the sha256 of the file. A rotation without it breaks `make deps` in
  each consumer.
- **SITE-ROTATE-12** — A retired key file must stay published, so a release that
  it signed still verifies.
- **SITE-ROTATE-13** — The workflow must remove every private key file that it
  wrote, whatever the outcome of the run.
