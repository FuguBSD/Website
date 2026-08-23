# Website

The main website of the FuguBSD organization, at
[www.fugubsd.org](https://www.fugubsd.org/).

The site holds a description of FuguBSD and the list of the project websites.
The list is manual: when a project website appears or goes away, edit
`web/index.body.html` in the same change.

[fuguweb(1)](https://github.com/FuguBSD/FuguWeb) renders the site from
`.fuguwebrc` and `web/`. On a push to `main`, the publish workflow builds the
site and deploys it to GitHub Pages through the shared `web-publish.yml`
workflow of [Tooling](https://github.com/FuguBSD/Tooling).

The project is specification-first: the content follows the specification.

## Documentation

The specification in [spec/](spec/index.md) is the authoritative reference. Read
[spec/DECISIONS.md](spec/DECISIONS.md) before you make a plan.

## Commands

```sh
make check       # spec-check + ste-lint + test
make prettier    # Markdown, JSON and YAML formatting check
fuguweb build --out web/build
fuguweb check --out web/build
```

## Commit scopes

`web`, `spec`, `ci`.

## License

ISC. See [LICENSE](LICENSE).
