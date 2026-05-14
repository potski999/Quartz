# Quartz Configuration — WIS Manual

> Current state reference for all non-default Quartz customisations.
> Use this to reproduce the setup in a new Quartz subsite or recover from a clean install.

---

## 1. Component Files (added/modified)

| File | Purpose |
|------|---------|
| `quartz/components/NavBar.tsx` | Fixed-position navbar: WIS Wiki logo + nav links (Resources, Videos, History, Scenarios, Manual active) |
| `quartz/components/WikiFooter.tsx` | Replaces default footer: Manual, Videos, Forum links + copyright |
| `quartz/components/PageTitle.tsx` | Custom page title: "WIS Manual" linking to `https://wis-wiki-manual.web.app/` |
| `quartz/components/index.ts` | Exports `NavBar`, `WikiFooter` (added alongside existing exports) |

### NavBar Details (`NavBar.tsx`)

| Element | Text | Links to |
|---------|------|----------|
| Logo | WIS Wiki | `https://wis-wiki.web.app/` |
| Nav link 1 | RESOURCES | `https://wis-wiki.web.app/index.html#resources` |
| Nav link 2 | VIDEOS | `https://wis-wiki.web.app/videos.html` |
| Nav link 3 | HISTORY | `https://wis-wiki.web.app/history.html` |
| Nav link 4 | SCENARIOS | `https://wis-wiki.web.app/scenarios.html` |
| Nav link 5 | MANUAL | `/` (manual root, `.active` class) |

- `position: fixed; top: 0; left: 0; right: 0; z-index: 1000`
- All links open in same tab (WIS Wiki subsite convention)
- CSS is embedded in `NavBar.css` static property (esbuild bundles it)

### Footer Details (`WikiFooter.tsx`)

| Element | Links to |
|---------|----------|
| Manual | `/` (manual root) |
| Videos | `https://wis-wiki.web.app/videos.html` |
| Forum | `https://forums.matrixgames.com/viewforum.php?f=12043` |
| Copyright | — |

- CSS is embedded in `WikiFooter.css` static property

### PageTitle Details (`PageTitle.tsx`)

- Text: "WIS Manual"
- Links to: `https://wis-wiki-manual.web.app/`
- Replaces default sidebar page title

---

## 2. Layout (`quartz.layout.ts`)

### `sharedPageLayout`

| Slot | Change |
|------|--------|
| `head` | `Component.Head()` (default) |
| `header` | `Component.NavBar()` — fixed-position navbar |
| `afterBody` | Empty |
| `footer` | `Component.WikiFooter()` — replaces `Component.Footer()` |

### `defaultContentPageLayout`

| Slot | Contents |
|------|----------|
| `beforeBody` | Breadcrumbs (conditional: not on index), ContentMeta, TagList |
| `left` | PageTitle ("WIS Manual"), MobileOnly(Spacer), Flex(Search + ReaderMode), Explorer (folderClickBehavior: "link") |
| `right` | Graph, DesktopOnly(TableOfContents), Backlinks |

### `defaultListPageLayout`

| Slot | Contents |
|------|----------|
| `beforeBody` | Breadcrumbs, ContentMeta |
| `left` | PageTitle, MobileOnly(Spacer), Flex(Search + ReaderMode), Explorer |
| `right` | Empty |

### Key Changes from Default

- **`Component.ArticleTitle()` removed** from both `beforeBody` arrays
- **`Component.Footer()` replaced** with `WikiFooter()` in `sharedPageLayout`
- **`NavBar()` added** to `header` in `sharedPageLayout`
- **Custom `PageTitle()`** replaces default sidebar title (text + link)

---

## 3. Config (`quartz.config.ts`)

| Setting | Value |
|---------|-------|
| `pageTitle` | `"WIS Manual"` |
| `pageTitleSuffix` | `""` (empty) |
| `enableSPA` | `true` |
| `enablePopovers` | `true` |
| `analytics` | Plausible |
| `locale` | `"en-US"` |
| `baseUrl` | `"wis-wiki-manual.web.app"` |
| `ignorePatterns` | `["private", "templates", ".obsidian"]` |
| `defaultDateType` | `"modified"` |

### Theme — Colors (oklch → hex mapped to WIS design system)

| Role | Light Mode | Dark Mode (disabled) |
|------|-----------|---------------------|
| `light` (`--bg`) | `#fafafa` | `#fafafa` (forced to light) |
| `lightgray` (`--border`) | `#e5e5e5` | `#e5e5e5` |
| `gray` (`--muted`) | `#737373` | `#999999` |
| `darkgray` (`--fg`) | `#444444` | `#444444` |
| `dark` (headings) | `#1a1a1a` | `#222222` |
| `secondary` (`--accent`) | `#2d9e5f` | `#7b97aa` |
| `tertiary` (`--accent-warm`) | `#d97706` | `#84a59d` |
| `highlight` | `rgba(45, 158, 95, 0.15)` | `rgba(143, 159, 169, 0.15)` |
| `textHighlight` | `#fef08a` | `#b3aa0288` |

Note: Dark mode is effectively disabled — `html[data-saved-theme="dark"]` in `custom.scss` forces light-mode hex values.

### Theme — Typography

| Role | Font |
|------|------|
| `header` | `"JetBrains Mono"` |
| `body` | `"Inter"` |
| `code` | `"JetBrains Mono"` |

- `fontOrigin`: `"googleFonts"`
- `cdnCaching`: `true`

### Plugins (transformers, filters, emitters)

Standard Quartz v4.5.2 defaults. Notable:
- `SyntaxHighlighting`: theme `github-light` / `github-dark`, `keepBackground: false`
- `ObsidianFlavoredMarkdown`: `enableInHtmlEmbed: false`
- `CrawlLinks`: `markdownLinkResolution: "shortest"`
- `ContentIndex`: `enableSiteMap: true`, `enableRSS: true`
- `CustomOgImages`: **commented out** (speed)

---

## 4. Custom Styles (`quartz/styles/custom.scss`)

### CSS Variable Aliases

| WIS-Wiki Name | Quartz Source |
|---------------|---------------|
| `--bg` | `--light` |
| `--fg` | `--darkgray` |
| `--muted` | `--gray` |
| `--border` | `--lightgray` |
| `--accent` | `--secondary` |
| `--accent-warm` | `--tertiary` |
| `--font-mono` | `--codeFont` |
| `--font-body` | `--bodyFont` |
| `--font-display` | `--bodyFont` |

### Dark Mode Override

```scss
html[data-saved-theme="dark"] {
  --light: #fafafa;
  --lightgray: #e5e5e5;
  --gray: #999999;
  --darkgray: #444444;
  --dark: #222222;
}
```

### Layout Adjustments

| Rule | Purpose |
|------|---------|
| `body { padding-top: 56px; }` | Compensate for fixed navbar |
| `#quartz-body .sidebar { top: 56px; }` | Sidebar starts below navbar |
| `header:has(.wis-nav) { margin: 0 !important; }` | Nullify header wrapper margin with fixed navbar |
| `#quartz-body .page-header { margin-top: 2rem; }` | Reduce page-header top margin |
| `article { max-width: 800px; }` | Tighter content width |

### Explorer Font Size

```scss
.explorer { font-size: 0.8rem; }
.folder-container div > a,
.folder-container div > button span { font-size: 0.85rem; }
```

### Other Tweaks

- Link underline on hover (bottom border transition)
- Callout left border colour uses `--secondary` (green)
- Monospace font override for `code`, `pre`, `.code`

---

## 5. Navigation Map (User-Facing)

| Element | Location | Text | Links to |
|---------|----------|------|----------|
| Navbar logo | Top left (fixed) | WIS Wiki | `https://wis-wiki.web.app/` |
| Navbar nav | Top right | RESOURCES, VIDEOS, HISTORY, SCENARIOS, **MANUAL** | Main site pages / Manual root |
| Quartz sidebar | Left panel | WIS Manual | `https://wis-wiki-manual.web.app/` |
| Footer | Bottom | Manual, Videos, Forum | Respective URLs |

---

## 6. Build & Deployment

- **Build**: `npx quartz build` — outputs to `public/`
- **Verify**: Open `public/index.html` locally or run `npx quartz serve`
- **Hosting**: Firebase hosting at `wis-wiki-manual.web.app` (`firebase.json` configured for `public/`)
