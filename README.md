# Website

The main website of the FuguBSD organization, at
[www.fugubsd.org](https://www.fugubsd.org/).

The site holds a description of FuguBSD and the list of the project websites.
The list is manual: when a project website appears or goes away, edit
`web/index.body.html` in the same change.

[fuguweb(1)](https://github.com/FuguBSD/FuguWeb) renders the site from
`.fuguwebrc` and `web/`.

## Documentation

The project is specification-first: the specification in [spec/](spec/index.md)
is the authoritative reference.

## Commands

```sh
make check       # spec-check + ste-lint + gitleaks + test
fuguweb build --out web/build
fuguweb check --out web/build
```

`make check` runs the Markdown format gate, and prettier runs through bunx. The
operator installs bun, for example from Homebrew. The manifest does not provide
it, because the format gate needs `bunx` before a target can run.

`make deps` installs gitleaks, the tool of the secret gate, and signify, which
`fuguweb rotate-key` needs to sign the key manifest. It installs the `tool`
environment before every other environment, so the gate tool is present for each
chain. The rotation workflow holds no rotation logic of its own: it installs
`fuguweb` from a release and calls it, per FuguWeb WEB-ROTATE. `deps/SHA256.txt`
records the sha256 digest of each versioned download, and `make deps` compares
the downloaded bytes against it. The CI gate installs gitleaks the same way, so
one pin serves the operator gate and the CI gate.

## Commit scopes

`web`, `spec`, `ci`.

## License

ISC. See [LICENSE](LICENSE).
