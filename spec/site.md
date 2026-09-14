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
  word leads every key name of the block, and FuguWeb WEB-KEYS-2 refuses two
  blocks that name one word.

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
  App, `<PREFIX>_APP_ID` and `<PREFIX>_APP_PRIVATE_KEY`. The callee binds the
  environment from an input, and it mints its token from that App.
- **SITE-ROTATE-27** — Each environment must hold a deployment-branch rule that
  names `main` alone. `workflow_dispatch` runs the workflow file of the chosen
  ref. A person with write access can otherwise reach the App credentials
  through a branch of their own. The rule is a repository setting, and no file
  of this repository can carry it. The operator sets it.
- **SITE-ROTATE-14** — The workflow must call the reusable workflow of FuguWeb,
  and must hold no step of its own. It must pin the callee to a commit, because
  the callee runs beside a private key. Its dispatch must take the step, the
  purpose, the type, the directory and the bootstrap flag. It must also take the
  address and the expiry of an OpenPGP mint, and the file of an import.
- **SITE-ROTATE-29** — The directory must be a choice input. The workflow must
  derive each value that the directory decides. Those values are the path in
  this tree, the environment, the secret prefix, the published prefix and the
  visibility list. A run must never pair one directory with the secrets of
  another.
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
  release URL. `scripts/deps` then verifies the signed manifest of that release
  with the declared key. A plain `cpanm` of a URL reads the tarball with no
  check at all.
- **SITE-ROTATE-11** — Each step must open a pull request against
  FuguBSD/Tooling that declares the key, with the published URL and the sha256
  of the file. A rotation without it breaks `make deps` in each consumer. The
  callee declares no key, per FuguWeb WEB-ACTIONS-10, so the caller reads the
  outputs of the call.
- **SITE-ROTATE-21** — That pull request must write `deps/KEYS.txt` and
  `org/sync/deps/KEYS.txt`. Tooling syncs the org pack into itself, so one copy
  alone leaves the other stale and fails the drift gate.
- **SITE-ROTATE-22** — A mint must append its line, which is the whole trust
  order. The current key leads the file, and the next key stands under it. A
  promote must lift its line to the top, and the caller must hold no such edit,
  because D-01 takes site content alone. A promote must stop, and it must name
  the work that a maintainer does.
- **SITE-ROTATE-25** — The branch of that pull request must carry the run
  identifier, so a second run of one step opens its own pull request.
- **SITE-ROTATE-26** — The clone of FuguBSD/Tooling must get a git credential
  helper, because `gh repo clone` leaves a remote that carries no credential.
  The helper must read the token from the environment when git runs it. A token
  that the shell expands earlier would reach the configuration file, and a token
  in the remote URL would reach the command line.
