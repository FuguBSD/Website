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

The organization publishes its public keys here. A consumer fetches a key and
verifies a release with it. FuguWeb holds the key directory, per FuguWeb
WEB-KEYS, and this site holds the description and the key files.

- **SITE-KEYS-1** — The site must publish two key directories. The `releng`
  directory holds the keys that sign the releases, at
  `https://www.fugubsd.org/releng`. The `admin` directory holds the keys that
  reach the administrators, at `https://www.fugubsd.org/admin`. `.fuguwebrc`
  must hold one `keys` block for each one.
- **SITE-KEYS-2** — Each key must live in the directory of its block,
  `web/releng` or `web/admin`. One `key` block must describe each key.
- **SITE-KEYS-3** — The `SHA256` manifest and the `SHA256.sig` signature of each
  directory are source files. The site build cannot sign, so a step of the
  rotation workflow writes both.
- **SITE-KEYS-4** — Each directory must hold one `current` key of the purpose
  `root`, and that key must be a signify key. The root signs the manifest of its
  directory, and each other key of the directory holds a binding over the root.
  FuguWeb WEB-TRUST states each binding rule.
- **SITE-KEYS-5** — A `keys` block and the first key of its directory must land
  in one commit. A block that names a directory which holds no key fails the
  whole load. A bootstrap mint therefore writes the block, the first key and the
  manifest together.
- **SITE-KEYS-6** — Each `keys` block must take an `org` word of its own. The
  word is `fugureleng` for the `releng` directory, and `fuguadmin` for the
  `admin` directory. The word leads every key name of the block, and FuguWeb
  WEB-KEYS-2 refuses two blocks that name one word.
- **SITE-KEYS-7** — A key file of the `releng` or the `admin` directory must
  stay published, a retired key file included. A consumer that pins an old key
  verifies a release that the key signed. A step of the rotation workflow
  removes a binding file alone, per FuguWeb WEB-TRUST-5 and WEB-TRUST-7.
- **SITE-KEYS-8** — The `admin` block must name the contact address and the
  expiry of `security.txt`, and the `releng` block must name neither. The
  address is `mailto:security@fugubsd.org`, and it reaches the administrators.
  The expiry must stay in the future. The operator must move it before it
  passes. FuguWeb WEB-KEYS-3 takes the two values in one block alone.

<a id="site-rotate"></a>

## The rotation workflow

A workflow of this repository mints each key and rotates it. No human handles a
private key at any point.

The workflow is a thin caller. FuguWeb holds the order of the steps in the
reusable workflow `keys-rotate.yml`, per FuguWeb WEB-ACTIONS. The `fuguweb`
verbs hold every trust rule, per FuguWeb WEB-ROTATE and WEB-TRUST. This
repository takes site content alone, per D-01.

- **SITE-ROTATE-1** — Two organization secrets must hold the private keys of one
  purpose, and one organization variable must name the active slot. The names
  are `<PREFIX>_<PURPOSE>_KEY_A`, `<PREFIX>_<PURPOSE>_KEY_B` and
  `<PREFIX>_<PURPOSE>_SLOT`. The prefix is `RELENG` for the `releng` directory,
  and `ADMIN` for the `admin` directory.
- **SITE-ROTATE-2** — Each secret of `releng` must be visible to this
  repository, and to each repository that releases a Perl distribution. Each
  secret of `admin` must be visible to this repository alone. A repository that
  releases nothing must hold no private key: it verifies with the published one.
- **SITE-ROTATE-4** — Each directory must take an environment of its own,
  `releng` or `admin`. The environment must hold the credentials of a GitHub
  App, `<PREFIX>_APP_ID` and `<PREFIX>_APP_PRIVATE_KEY`. The operator writes
  each one, because no file of this repository can carry a secret. The callee
  binds the environment from an input, and it mints its token from that App.
- **SITE-ROTATE-5** — A run must report the repositories that its token reaches,
  before it writes a secret, and must never print the token. A token without the
  organization permission fails at the write of a secret, and that message names
  neither the App nor the permission.
- **SITE-ROTATE-27** — Each environment must hold a deployment-branch rule that
  names `main` alone. `workflow_dispatch` runs the workflow file of the chosen
  ref. A person with write access can otherwise reach the App credentials
  through a branch of their own. The rule is a repository setting, and no file
  of this repository can carry it. The operator sets it.
- **SITE-ROTATE-14** — The workflow must call the reusable workflow of FuguWeb,
  and must hold no step of its own. It must pin the callee to a commit, because
  the callee runs beside a private key. Its dispatch must take the step, the
  purpose, the type, the directory, the bootstrap flag and the subordinate
  purposes. The purpose must default to `root`, because each directory takes its
  root key first, per SITE-KEYS-4. It must also take the address and the expiry
  of an OpenPGP mint, and the file of an import. A root step binds each
  subordinate key again, per FuguWeb WEB-TRUST-7, and an empty value binds none.
- **SITE-ROTATE-29** — The directory must be a choice input. The workflow must
  derive each value that the directory decides. Those values are the path in
  this tree, the environment, the org word, the secret prefix, the published
  prefix and the visibility list. A run must never pair one directory with the
  secrets of another.
- **SITE-ROTATE-30** — The caller must hold `permissions`, `concurrency` and
  `secrets: inherit`, per FuguWeb WEB-ACTIONS-14. The permissions must grant
  `contents: write` for the commit of the key directory, and `actions: write`
  for the publish that the callee starts.
- **SITE-ROTATE-15** — The deps manifest must pin the version of each
  distribution that a key step installs. The callee installs with `make deps` of
  this repository, per FuguWeb WEB-ACTIONS-5, and it runs that code beside a
  private key. A later release must not reach that key before a human reads the
  change.
- **SITE-ROTATE-28** — Each `dist` entry of the manifest must name a versioned
  release URL. A versioned URL names one set of bytes, and `deps/SHA256.txt`
  keys its digest on that URL. A plain `cpanm` of a URL reads the tarball with
  no check at all.
- **SITE-ROTATE-32** — `deps/SHA256.txt` must record the digest of each `dist`
  entry. `scripts/deps` reads a recorded digest before the signify tier, so a
  key step of this repository reads no published key. Each digest must agree
  with the signed `SHA256` manifest of its release.
- **SITE-ROTATE-31** — The deps manifest must install the command of each signer
  that a key step runs. `signify(1)` makes a signify key and signs with it, and
  `gpg(1)` makes an OpenPGP key and signs with it. Perl holds no private key
  operation, so a step that finds no command writes no key.
- **SITE-ROTATE-11** — The operator must declare each new key that signs a
  release in FuguBSD/Tooling. The declaration must hold the published URL and
  the sha256 of the key file. The operator must not declare a root key. A root
  key signs no release, and each declared key verifies every signify-tier
  download, per Tooling SYNC-KEYS-10. A consumer that reaches the signify tier
  fails `make deps` until the declaration lands. The callee outputs the URL and
  the digest, per FuguWeb WEB-ACTIONS-2, and it declares no key, per FuguWeb
  WEB-ACTIONS-10.
- **SITE-ROTATE-21** — The declaration must write `deps/KEYS.txt` and
  `org/sync/deps/KEYS.txt`. Tooling syncs the org pack into itself, so one copy
  alone leaves the other stale and fails the drift gate.
- **SITE-ROTATE-22** — The line order of `deps/KEYS.txt` is the trust order, and
  the current key leads the file. The operator must append the line of a release
  mint under the current key. The operator must lift the line of a release
  promote to the top. The caller holds no such edit, because D-01 takes site
  content alone.
