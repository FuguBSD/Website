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
