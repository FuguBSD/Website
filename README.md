# Website

The main website of the FuguBSD organization, at
[www.fugubsd.org](https://www.fugubsd.org/). The site holds a description of
FuguBSD and the list of the project websites.

[fuguweb(1)](https://github.com/FuguBSD/FuguWeb) renders the site from
`.fuguwebrc` and `web/`. The list of project websites is manual: when a project
website appears or goes away, edit `web/index.body.html` in the same change.

## Commands

```sh
make deps        # install gitleaks and signify
make check       # run every gate; run it before each commit
make test        # run the test suite
make format-fix  # fix the Markdown, JSON and YAML formatting
```
