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
make check       # spec-check + ste-lint + test
make format-md   # Markdown, JSON and YAML formatting check
fuguweb build --out web/build
fuguweb check --out web/build
```

## Commit scopes

`web`, `spec`, `ci`.

## License

ISC. See [LICENSE](LICENSE).
