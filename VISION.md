# Vision

wip-site is a maintenance page that looks deliberate: one HTML file, one
stylesheet, no JavaScript, no web fonts and no network request, deployed by
copying two files. Everything else here follows from the constraint that the page
has to load for everyone, instantly, at the exact moment the rest of a site
cannot. This document is about keeping that promise as the page grows up — and
about the few things a page like this should be able to do that it cannot yet.

## Where wip-site is today

Two files are the whole deployment: `index.html` at 213 lines and `index.css` at
about 1,200, which is 7.6 kB of markup and 26.8 kB of CSS — 2.1 kB and 6.8 kB
gzipped, about 9 kB over the wire with no second host in the path. There is no
build step, no package manifest and no test suite; the artefact is the source.

The look is a frosted card over a drifting grid with a rotating gold hairline, a
light sweep, aurora glows, a scanline and film grain, and it is drawn entirely in
CSS: `@keyframes` move `transform`, `opacity` and gradient positions only, so the
work stays on the compositor and a weak phone does not stutter. Every colour,
radius, easing and type family is a custom property at the top of `index.css`;
further down nothing visual is hard-coded, so a mood change is a token edit.

Theming has two layers and no script. `color-scheme: light dark` plus
`light-dark()` tokens mean the page is decided at first paint from the reader's
own settings; a three-radio switch in the card header overrides it, driven by
`:has(:checked)` and only rendered where both `light-dark()` and `:has()` exist.
The override lasts the page view because there is nowhere to remember it, which
is the intended trade — a status page should not depend on storage. Below the
tokens sit `@media (prefers-reduced-motion: reduce)` and
`(prefers-contrast: more)` blocks, a 640px breakpoint and a short-height one.

The markup is semantic rather than scenic: one `<h1>`, a `<dl>` of service,
state and return, a console-style list of status rows, a `role="progressbar"`
with `aria-valuetext` and no `aria-valuenow` (it is honestly indeterminate), a
`visually-hidden` label on each theme radio, every decorative layer
`aria-hidden`, `noindex, nofollow`, a description and a light/dark `theme-color`,
and an inline SVG favicon as a data URI. All addresses are relative, so the page
works from `/maintenance/` as well as from a root.

Deployment is four `maak` tasks: `deploy` copies the two files into
`~/srv/http/wip-site.jointhefreeworld.org` (or `WIP_SITE_DEPLOY_DIR`), `link`
symlinks them into a checkout so edits are live during an incident, `undeploy`
removes exactly those two files, and `serve` runs a local HTTP server. A GitHub
workflow runs `maak deploy` on every push to `trunk`, so a merge is a deploy. The
manual carries the recipes that put the page in front of a broken site — nginx
`return 503` with `error_page`, Apache `ErrorDocument` plus a rewrite — and the
advice to send `Retry-After`.

What constrains the future is the shape of those choices. No JavaScript means no
storage, no clock and no client-side state: anything live — a real progress bar, a
real expected return, a date — must be in the file or be emitted by whatever
serves it. Two files and no build means no preprocessor, no autoprefixing and no
fallback generation, so every modern CSS feature is used with a `@supports` guard
and a fallback palette rather than compiled down. The copy is generic and
English, written in the first person plural, and it is edited in place, which
means the page has one voice and no notion of an instance.

## The vision

1. **A deployment is one file.** `maak bundle` emits `index.html` with the
   stylesheet inlined and the decoration optionally dropped, so putting a site
   into maintenance is one `install` — or one file attached to a message at three
   in the morning — while the two-file form stays for live editing during an
   incident.

2. **The page can tell the truth about its own outage.** The service name, a dated
   message, an expected return and a link to wherever the real status lives are
   fields with an obvious home, and the artefact can be emitted per vhost from
   them, instead of the values being sentences a maintainer edits under pressure.

3. **The budget is a number in the repository.** Gzipped bytes, request count and
   the time to first paint on a throttled phone are written down, and a check
   fails when `index.css` crosses them — because "it loads instantly" is a claim
   that decays silently otherwise.

4. **It holds up in the states nobody designs for.** Printed, forced into a
   high-contrast palette, read at 320px, zoomed to 400%, with images blocked, and
   with every animation refused: the page is still legible, and the card still
   has an edge.

5. **It speaks the languages the rest of the community does.** The copy is one
   template rendered per locale — no script at the edge selects it, and none is
   needed to read it.

## Features that are in scope and not built yet

- **A print stylesheet.** A page designed as a card in a viewport has to become
  one sheet on paper: the decoration must vanish, the gradients become ink, and
  the progress bar must still read as indeterminate in monochrome. The hard part
  is that print is the one medium where the design's whole vocabulary — glow,
  grain, sheen — is a liability.
- **Forced colours.** The card's edges are rgba hairlines and the accents are
  custom properties, which a forced-colour mode discards. The hard part is a
  `forced-colors` block that keeps the hierarchy with system colours and real
  borders, and a theme switch that remains operable when colours are not ours.
- **A single-file bundle.** Inlining is easy; keeping the tokens editable and the
  incident workflow intact afterwards is not, and a bundle that silently drifts
  from the two source files would be worse than no bundle.
- **The long-outage variant.** "Soon" is honest at nine in the morning and false
  by evening. The hard part is a second copy that can carry a date and a status
  link without turning the page into a template with eleven fields.
- **Retry-After and the recipes as one thing.** The proxy snippets live in the
  manual; the header they should send is prose. The hard part is a documented
  pair — page and header — that a maintainer can paste without reading three
  sections.
- **Localisation.** With no script and no build, a language must live in the file
  or in the path. The hard part is choosing one of those without duplicating a
  1,200-line stylesheet per language.
- **`prefers-reduced-data`.** The aurora, the grain and the scanline are cheap on
  a compositor and not free on a metered connection. The hard part is a media
  query that drops atmosphere without dropping the hierarchy.

## New features that would be worth having

- **A family of one-job pages.** A 404, a 410, a 500 and a "this moved" page
  sharing these tokens and this stylesheet, so a site's bad days look like the
  site. Speculative, and the change that would turn a page into a small kit.
- **A printable poster variant** with a QR code drawn as inline SVG, pointing at
  whatever status page exists — no request, no dependency, and something to tape
  to a wall next to a switch.
- **An Atom or JSON status feed** linked from the head, so a monitoring tool or a
  reader's own client can see the same claim the page makes. Needs an emitter,
  which is a build step by another name — worth it only if the emitter is the
  same ten lines that produce the page.
- **A one-line "we are back" page**, the mirror of this one, sharing its tokens,
  so the end of an incident is as deliberate as its middle.

## Contributions that would move the needle

1. **Write the print stylesheet.** An afternoon, and the change a reader notices
   the first time they print the page or save it as a PDF. It needs no decisions
   from anybody and no JavaScript.
2. **A forced-colours pass.** An hour of testing in a high-contrast mode, a real
   border on the card and system colours in the switch. It closes the most likely
   accessibility failure this design has.
3. **`maak bundle`.** A few hours with `sed` or ten lines of Guile: inline the
   stylesheet, keep a marker saying it was generated, and make `deploy` able to
   use either form.
4. **A budget check in CI.** An hour: gzip both files, compare against two
   numbers in the repository, fail the workflow. Cheap insurance for the only
   property this project actually sells.
5. **The long-outage copy.** An hour of writing, and the hardest hour in an
   incident is the one spent rewriting a page that says "soon".
6. **A localisation template.** A day: one template, an emitted page per locale,
   and the theme switch unchanged — because it never depended on a word.

## Compared to related projects

| Project | What it is | Where wip-site differs |
| --- | --- | --- |
| Uptime Kuma | A self-hosted monitoring service with dashboards and public status pages, in Node.js with a database and a JavaScript front end. | Uptime Kuma watches things and reports; wip-site occupies the address and asserts. Kuma can tell you a service is down but cannot serve the page from the machine that is down, unless it is hosted elsewhere. |
| Gatus | A health-check driven status page: endpoints, conditions, badges, and a generated dashboard. | Gatus is honest because it is measured; wip-site is honest because it is written. Gatus needs a running process and a database, which is exactly what an outage may have taken. |
| Cachet and Statping-ng | Self-hosted status pages with incidents, components and history, backed by PHP or Go and a database. | They model an incident; wip-site is one incident. Neither fits in two files, and both are down when their host is. |
| Atlassian Statuspage, Instatus | Hosted status pages with subscribers, incident history and machine-readable feeds, off your infrastructure. | The closest thing to "reachable while you are broken", and what to use if the outage is the interesting part. wip-site is free software, self-hosted, has no account and no JavaScript, and states one thing rather than tracking many. |
| nginx's built-in 503 body, Apache's stock `ErrorDocument` | The page a misconfigured or overloaded server returns by default. | They are honest and they are plain. wip-site is the same status with a considered page, a theme and an accessible structure — which is what makes a reader trust the site is coming back. |
| Hugo and Jekyll maintenance themes, "under construction" templates | Static-site themes and free HTML snippets for a down or unfinished page. | The same idea, without the constraint: most ship analytics, a webfont or a build step. wip-site's whole design is what it refuses to load. |

What the others do that wip-site could still add: the truth of a measured status
(Gatus, Uptime Kuma), an incident history and a feed (Statuspage, Cachet), and a
component list for a site with more than one part. Where wip-site is ahead and
should stay ahead: two files with no build, no JavaScript at all, no webfont and
no network request, relative addresses that survive a subdirectory, a theme
switch that is honest about lasting one page view, decoration that costs the
compositor only, an indeterminate progress bar that does not lie about a number,
and copy written the way an operator would say it.

## In the long run

The bet under all of it is that an artefact beats a service: the only status page
that loads during an outage is one served by whatever is still answering. That
argues for staying on this side of the line — banners, timers, subscriber lists
and incident histories all argue for a service, and each of them is a reason the
page could be unavailable exactly when it is needed.

The second bet is a house style: these tokens and this card could be what an
outage looks like across the community's sites, so a reader who lands on one
recognises it immediately. The third is that budgets, written down and checked,
are what keep a two-file page a two-file page over years of small additions —
the drift that turns an instant page into a slow one is always one commit at a
time, and always well intentioned.

## Using this document

Two items here are worth an afternoon and need no discussion: the print
stylesheet and the forced-colours pass. Two are decisions worth arguing about:
whether a bundle exists, and whether a language lives in the file. The rest are
speculation in the project's own character, and nobody owns them.

*This document describes intent, not commitments.*
