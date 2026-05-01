# CLAUDE.md — gpcx.cc

A reference for Claude working in this repo. Read this first.

---

## What this is

gpcx.cc — Kenny Gorman's personal cycling zine. "Ride stories & garage experiments." A Jekyll 4 static site with a strong opinionated voice, custom layouts on top of the `minima` theme, and a few special sections (Stories, Notes, Film Roll, Digest, Origin).

- **URL:** https://gpcx.cc
- **Repo:** `git@github-gpcx:kgorman/gpcx.git` (origin/main)
- **Voice/tone:** see `docs/tone-guide.md` — lowercase bias, conversational, dirt-real, no marketing-speak. Match it when editing or drafting copy.

---

## Stack

| Piece | Detail |
| --- | --- |
| Generator | Jekyll 4.3.x |
| Ruby | 3.2.2 (`Gemfile`, `.ruby-version`) |
| Theme | `minima ~> 2.5` (overridden heavily) |
| Plugins | `jekyll-feed`, `jekyll-seo-tag`, `jekyll-sitemap` + custom `_plugins/read_file_filter.rb` |
| Fonts | Literata (Google Fonts) |
| Analytics | GoatCounter (`gpcx.goatcounter.com`) — scroll-engaged + read-to-end events fire from `_layouts/post.html` |
| Newsletter | Substack (`gpcx.substack.com`) — linked, not embedded |
| Comments | None (Disqus block in `post.html` is dormant — `site.disqus.shortname` not set) |

---

## Hosting and deploy — IMPORTANT

**The site is hosted on Render.** Render auto-deploys from `git push` to `main`. There is no GitHub Actions workflow, no separate deploy script, no rsync, no S3, no CNAME file in repo. Render's build/publish settings live in the Render dashboard — not in the repo. The repo has historical commits referencing the migration (e.g. `df31a7a Add Jekyll and minima dependencies for Render deploy`).

### What "publish" / "republish" means

Commit and push to `origin/main`. That's the entire deploy. Do **not** ask the user how to deploy or look for a build script — pushing is the deploy.

```bash
git add <specific files>
git commit -m "..."
git push origin main
```

Render builds Jekyll server-side and serves `_site/`. `bundle exec jekyll build` is **only** for local previewing — never required to publish.

### Local preview (when needed)

```bash
bundle exec jekyll serve
# or just build
bundle exec jekyll build
```

### Push hygiene

- The working tree often has many unrelated modified files (image re-saves, page edits in flight). When committing a fix, **add files by name** — never `git add -A` or `git add .`.
- Render builds on every push, so don't push WIP commits unless you mean to publish them.
- If a push is rejected due to remote ahead, `git pull --rebase origin main` and resolve. Stash any unstaged work first.

---

## Repo layout

```
_config.yml             # site config — title, plugins, header_pages, defaults
_data/
  digests.yml           # Substack digest entries (drives /digest/)
  film-roll.yml         # photo metadata (drives /film-roll/)
_includes/
  head.html             # <head> — fonts, SEO tag, GoatCounter
  header.html           # site header + nav (Notes, Stories, Film Roll, Origin Story, Subscribe)
  footer.html           # © line + IG/Substack icons
  navigation.html       # filter nav (used in some flows)
  newsletter.html       # currently empty
  breadcrumbs.html      # JSON-LD breadcrumb schema for posts
_layouts/
  base.html             # outermost shell (html, head, header, main, footer)
  default.html          # wrapper used by pages
  home.html             # the index — loops site.posts, applies primary_tag, has client-side filter
  post.html             # post template — header image, content, related posts, GoatCounter events
  film-roll.html        # alternate film-roll layout for individual filmroll *posts* (rare)
_plugins/
  read_file_filter.rb   # `{{ '/path' | read_file }}` Liquid filter
_posts/                 # YYYY-MM-DD-slug.md — the stories
assets/
  main.scss             # ~860 lines — imports minima then overrides everything
  images/               # post images (1200px wide, JPEG, <300KB target)
  images/film-roll/     # film roll photos + *_full_res.jpg originals
  icons/                # SVGs for IG / Substack
bin/
  bundle                # Bundler binstub
  extract_exif.sh       # extracts EXIF for film-roll photos (no GPS)
docs/                   # workflow guides (read these for content tasks)
  tone-guide.md
  image-resize-guide.md
  photo-layout-guide.md
  film-roll-workflow.md
index.md                # home (uses layout: home)
stories.md              # /stories/ — filters posts with tag "stories"
notes.md                # /notes/   — filters posts with tag "notes"
film-roll.md            # /film-roll/ — renders _data/film-roll.yml as a numbered grid
digest.md               # /digest/  — renders _data/digests.yml (links out to Substack)
origin.md               # /origin_story/ — single page, the "why"
robots.txt              # sitemap pointer
Gemfile / Gemfile.lock  # Ruby deps
```

---

## Content model

### Tag taxonomy (load-bearing)

Posts are routed by their **first matched tag**, not by directory. `_layouts/home.html` checks tags in this priority order:

1. `notes` → Notes feed
2. `stories` → Stories feed
3. `filmroll` → Film Roll (mostly bypassed now in favor of `_data/film-roll.yml`)
4. `origin` → Origin
5. fallback → `stories`

If a post needs to appear under a section, it must have that tag. `stories.md` and `notes.md` filter `site.posts` by tag at render time.

### Post frontmatter — canonical example

```yaml
---
layout: post                  # set by _config.yml defaults; usually omit
title: "Marg Shack Run Number 2"
date: 2026-04-12
last_modified_at: 2026-04-12
categories: [stories, journey]
tags: [stories, night-riding, crew, emtb, fun]
author: "Kenny Gorman"        # also defaulted via _config.yml
excerpt: "3 margs in 30 minutes is redline. It's now dark."
description: "Five guys, three margaritas, and a night ride through Emma Long Park."  # REQUIRED for SEO
headimage: "/assets/images/margs02_main.jpeg"
image: "/assets/images/margs02_main.jpeg"   # REQUIRED — used by jekyll-seo-tag for og:image / twitter:image
headimage_position: "center center"   # optional CSS object-position when fixed-height crop kicks in
homeimage: /assets/images/margs02_alt.jpeg # optional override on home grid only
---
```

**Required for every post:** `title`, `date`, `tags`, `excerpt`, `description`, `headimage`, `image`. Without `image:` social cards have no preview. Without `description:` the meta description falls back to first paragraph.

**Convention:** `image:` should mirror `headimage:` unless you want a different social-share image specifically.

**Image precedence on home grid:** `homeimage` → `headimage` → `image`.
**Image on post page:** `headimage` (rendered as banner with rounded corners; if `headimage_position` is set, it crops to 400px tall with that anchor).
**SEO/social card:** `image` is the canonical one for `jekyll-seo-tag`.

### Post filename

`_posts/YYYY-MM-DD-slug.md` — Jekyll requires the date prefix. Permalinks come from minima defaults; e.g. a post tagged `stories` with `categories: [stories, journey]` renders at `/stories/journey/YYYY/MM/DD/slug.html`.

### Excerpt

`excerpt:` in frontmatter wins. Otherwise minima takes the first paragraph. Home grid truncates to 40 words.

---

## Pages

| Page | Permalink | Source | Purpose |
| --- | --- | --- | --- |
| Home | `/` | `index.md` (`layout: home`) | All posts, client-side tag filter via `?filter=` |
| Stories | `/stories/` | `stories.md` | `tags contains "stories"` |
| Notes | `/notes/` | `notes.md` | `tags contains "notes"` |
| Film Roll | `/film-roll/` | `film-roll.md` + `_data/film-roll.yml` | Numbered photo grid with lightbox |
| Digest | `/digest/` | `digest.md` + `_data/digests.yml` | Outbound Substack links |
| Origin | `/origin_story/` | `origin.md` (`layout: page`) | Single-page story |

`_config.yml`'s `header_pages` list controls the order of nav links rendered in `_includes/header.html` — but the actual hardcoded nav links in `header.html` take precedence (it lists Notes, Stories, Film Roll, Origin Story, Subscribe explicitly). If you add a top-level page, you almost always need to also edit `_includes/header.html`.

---

## Styling

`assets/main.scss` is the single source. It begins with `@import "minima";` then overrides aggressively (~860 lines). Don't reach into the minima gem — override in `main.scss`.

### Visual rules

- Body font: **Literata**, 1.08rem, line-height 1.8, color `#1f1f1f`.
- All `<img>` get `border-radius: 8px`.
- `.post-image` (home grid thumbnails): 100% × 250px, `object-fit: cover`.
- Page-level body classes are used for top-padding tweaks: `body.page-notes`, `body.page-stories`, `body.page-film-roll`, `body.page-origin-story`. Set with `body_class:` in frontmatter.
- Tag pills `.tag-stories` / `.tag-notes` / `.tag-filmroll` / `.tag-origin` are styled in main.scss.

### Photo layout helpers (Markdown-friendly HTML)

These classes are styled in `main.scss` and mobile-responsive. Documented in `docs/photo-layout-guide.md`.

**Single photo with caption:**
```html
<div class="photo-caption">
  <img src="/assets/images/x.jpg" alt="...">
  <span class="caption">caption text</span>
</div>
```

**Two photos side-by-side (stacks on mobile):**
```html
<div class="photo-grid">
  <div><img src="/assets/images/a.jpg" alt="..."><span class="caption">a</span></div>
  <div><img src="/assets/images/b.jpg" alt="..."><span class="caption">b</span></div>
</div>
```

**Plain image:** standard markdown `![alt](/assets/images/x.jpg)` is fine.

### Lightbox

Both `film-roll.html` (post-level) and `film-roll.md` (page-level) ship their own inline `openLightbox()` / `closeLightbox()` functions. They're nearly identical but technically duplicated — be careful editing one without the other if behavior should match.

---

## Images

- **Location:** `assets/images/` for posts, `assets/images/film-roll/` for film roll.
- **Sizing:** Max 1200px wide. Use `sips -Z 1200 file.jpg` on macOS. See `docs/image-resize-guide.md`.
- **Filenames:** lowercase, descriptive, underscores or hyphens (e.g. `margs02_bikes.jpeg`).
- **Target weight:** under 300KB ideal, up to ~600KB ok.
- **Film Roll has a "full res" pattern:** the on-page image is the resized one (`photo.jpg`); the original is kept alongside as `photo_full_res.jpg` for download links. The full workflow lives in `docs/film-roll-workflow.md` — follow it when the user says "build the film roll."

---

## Common tasks

### Add a new post

1. Create `_posts/YYYY-MM-DD-slug.md` with the frontmatter shown above.
2. Tag it correctly — `stories` for long-form, `notes` for short. Order matters (home picks the first match).
3. Drop images in `assets/images/`, resize to 1200px wide, add `headimage` to frontmatter.
4. `git add` the post + new images, commit, push to `main`. Done.

### Add a film roll photo

Run the workflow in `docs/film-roll-workflow.md`. Short version:
1. Drop originals in `assets/images/film-roll/`.
2. Rename originals to `*_full_res.<ext>`, then create web copies via `sips -Z 1200`.
3. Optionally run `./bin/extract_exif.sh` to read camera metadata.
4. Append entry to `_data/film-roll.yml` (image, optional caption, date, camera, lens, settings, photographer, full_res).
5. Commit and push.

### Add a Substack digest

Append to `_data/digests.yml` with `title`, `subtitle`, `date`, `url`, `image`, `excerpt`. The `/digest/` page renders it automatically.

### Edit voice/copy

Read `docs/tone-guide.md` first. Match it.

### Resize images

`sips -Z 1200 file.jpg`. Batch loops are in `docs/image-resize-guide.md`.

---

## SEO

- `jekyll-seo-tag` is invoked via `{% seo %}` in `_includes/head.html`. It produces `<title>`, canonical, og:*, twitter:*, and JSON-LD `BlogPosting` schema. Don't hand-roll meta tags — let the plugin handle it.
- `jekyll-feed` produces `/feed.xml` (RSS). `jekyll-sitemap` produces `/sitemap.xml`. Both are referenced from `robots.txt`.
- Site-level `image:` in `_config.yml` is the **fallback** social card. Must be landscape (~16:9, ≥1200×630) for `summary_large_image` to render. Currently `recon_header.jpg` (1200×675).
- Post-level `image:` is what `{% seo %}` pulls for og:image / twitter:image. **Always set it** — convention is to mirror `headimage`.
- Post-level `description:` becomes meta description and og:description. Aim ~140–160 chars. Don't reuse the excerpt — write a search-intent line.
- `_data/authors.yml` doesn't exist; site author is set as a hash in `_config.yml` (`author: { name, url }`). Per-post `author:` is still a string ("Kenny Gorman") because the post.html byline expects a string.
- Twitter card is `summary_large_image`. No Twitter handle is configured (the site has no Twitter account); seo-tag may still emit `twitter:creator` content using the author name — accept it.
- Schema.org `BlogPosting` microdata is rendered in `_layouts/post.html` (also h-entry / p-name microformats). Breadcrumb JSON-LD lives in `_includes/breadcrumbs.html`.
- Analytics: GoatCounter (`gpcx.goatcounter.com`). `_layouts/post.html` fires `?scroll-engaged` and `?read-to-end` events for engagement tracking.

## Things that have bitten me before

- **Don't assume GitHub Pages.** This is Render. `git push` is the publish step.
- **Don't `git add -A`.** The working tree usually has unrelated in-flight changes. Stage by file.
- **Tag taxonomy is load-bearing.** A post with no `stories`/`notes`/`filmroll`/`origin` tag falls through to "stories" by default in `_layouts/home.html`. If a post isn't showing up where expected, check tags first.
- **Three image-precedence chains exist.** Home uses `homeimage → headimage → image`; the post page uses `headimage` only as the banner; jekyll-seo-tag uses `image` only. Set all three correctly — convention is `image == headimage`.
- **`subscribe.md` is empty** and `subscribe` isn't routed — the nav link goes straight to Substack via `_includes/header.html`. Don't try to "fix" the empty file.
- **`_includes/header.html` has hardcoded nav.** `_config.yml`'s `header_pages` is set but not the source of truth for the rendered nav. Edit the include directly.
- **Lightbox JS is duplicated** across `film-roll.md` and `_layouts/film-roll.html`. Keep them in sync.
- **`Gemfile.lock` is empty** in repo. Render regenerates it on each build, so dep versions float within the `~>` constraints. If a build breaks after a Render image change, regenerate locally with `bundle install` and commit the lockfile.

---

## Quick reference

```bash
# preview locally
bundle exec jekyll serve

# publish (the only step)
git add <files>
git commit -m "..."
git push origin main
```

That's it. Render takes care of the rest.
