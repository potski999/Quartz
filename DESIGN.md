# War In Spain — Design System

> **Canonical source:** The master design system lives in the [wis-wiki](https://github.com/potski999/wis-wiki) repo.
> This file covers project-specific layout and Quartz integration only.

> Category: Historical Strategy / Wargame Reference
> Terminal/developer monospace aesthetic with cool oklch palette. Compact, precise, code-editor feel.

## 1. Visual Theme & Atmosphere

The site uses a terminal/developer monospace aesthetic built on a cool oklch palette. The entire experience sits on a near-white cool background (`oklch(98% 0.005 250)`) with a true white surface (`oklch(100% 0 0)`) for cards and cells. Text is a deep cool near-black (`oklch(22% 0.02 240)`), never pure black. Borders use a soft cool gray (`oklch(90% 0.008 240)`) that creates subtle grid lines when used as a background color with 1px gaps.

![War In Spain Landing Page](./assets/screenshots/landing-page.png)
<!-- Screenshot placeholder: replace with actual 1100px-wide landing page screenshot -->

## 1.5 Visual Reference

Screenshots of the implemented design system components. Replace placeholder paths with actual screenshots captured from the browser.

### Full Landing Page

![War In Spain Full Landing Page](./assets/screenshots/landing-page-full.png)
<!-- Full 1100px width landing page screenshot showing all sections stacked -->

### Navigation

![Navigation Component](./assets/screenshots/nav.png)
<!-- Sticky nav: 56px height, frosted glass bg, WIS Wiki logo left (clickable), nav-links right -->

### Hero Section

![Hero Section](./assets/screenshots/hero.png)
<!-- 2-col grid: 42px mono headline left (green year), 16/10 video right, 4 stats row + 3 action buttons + tagline + tagline-note -->

### Resources Grid

![Resources Grid](./assets/screenshots/resources.png)
<!-- Auto-fill grid (minmax 320px, 1fr), 16px gap, bordered cards, → green arrows, 14px headings, 12px muted descriptions, placeholder cards at 0.5 opacity -->

### Factions Grid

![Factions Grid](./assets/screenshots/factions.png)
<!-- 2-col bordered grid: 40px icons, faction names, subtitles, descriptions, unit lists with green counts -->

### History Section & Timeline

![History Section](./assets/screenshots/history.png)
<!-- 2-col: text left (14px mono), timeline right (2px green border, 8px dots, dates + events) -->

### CTA Section

![CTA Section](./assets/screenshots/cta.png)
<!-- Centered: 32px mono heading, 14px description, dual buttons (btn-lg-green primary + btn-lg-dark secondary) -->

### Footer

![Footer](./assets/screenshots/footer.png)
<!-- Flex row: 11px mono uppercase, copyright left (2026 WIS Wiki), footer-links right, top border -->

## 2. Color Palette & Roles

Defined as CSS custom properties on `:root` in `styles.css`:

| Variable | oklch Value | Hex Equivalent | Role |
|----------|-------------|---------------|------|
| `--bg` | `oklch(98% 0.005 250)` | #fafafa | Page background — cool near-white |
| `--surface` | `oklch(100% 0 0)` | #ffffff | Card/cell backgrounds — true white |
| `--fg` | `oklch(22% 0.02 240)` | #1a1a1a | Primary text, headings |
| `--muted` | `oklch(50% 0.018 240)` | #737373 | Secondary text, captions, descriptions |
| `--border` | `oklch(90% 0.008 240)` | #e5e5e5 | Borders, grid lines |
| `--accent` | `oklch(58% 0.16 145)` | #2d9e5f | Green — primary CTAs, links, timeline markers, stats |
| `--accent-warm` | `oklch(58% 0.16 35)` | #d97706 | Orange — secondary button hover state |

### Derived Colors (used inline)
| Color | Value | Usage |
|-------|-------|-------|
| Nav background | `oklch(99% 0.003 250 / 0.85)` | Sticky nav with 85% opacity + backdrop blur |
| Heading accent (year) | `var(--accent)` | `.hero-content h1 .year` — green highlight on dates |
| Button dark bg | `var(--fg)` → hover `var(--accent)` | `.btn-sm-dark`, `.btn-lg-dark` — dark button, greens on hover |
| Button green bg | `var(--accent)` → hover opacity 0.9 | `.btn-sm-green`, `.btn-lg-green` — green button, dims on hover |
| WIP banner bg | `var(--accent-warm)` | Full-width orange/coral banner on work-in-progress pages |

### Color Roles Summary
- **Backgrounds**: `--bg` for page, `--surface` for cards/cells, nav uses `--bg` at 85% opacity
- **Text**: `--fg` for primary, `--muted` for secondary/meta, `--accent` for highlights
- **Borders**: `--border` for all borders and grid backgrounds (1px gap trick)
- **Interactive**: `--accent` (green) for primary actions, `--accent-warm` (orange) for secondary hover

## 3. Typography Rules

### Font Stacks (CSS Variables)

```css
--font-display: -apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', system-ui, sans-serif;
--font-body:    -apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', system-ui, sans-serif;
--font-mono:    'JetBrains Mono', 'IBM Plex Mono', ui-monospace, Menlo, monospace;
```

**Note:** Despite defining `--font-body` and `--font-display` as system fonts, the actual implementation applies `--font-mono` to nearly all elements. The `body` uses `--font-body` but all component classes override with `--font-mono`.

### Type Scale & Usage

| Selector | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|----------|------|------|--------|-------------|----------------|-------|
| `.hero-content h1` | `--font-mono` | 42px | 400 | 1.1 | -1px | Hero headline |
| `.hero-content h1 .year` | `--font-mono` | 42px | 400 | 1.1 | -1px | Year highlight (green) |
| `.cta-section h2` | `--font-mono` | 32px | 400 | — | — | CTA headline |
| `.section-header h2` | `--font-mono` | 24px | 600 | — | — | Section headings |
| `.stat-value` | `--font-mono` | 28px | 600 | — | — | Stat numbers |
| `.hero-video` / grid | — | — | — | — | — | Aspect ratio 16/10 |
| `.news-announce` | `--font-mono` | 18px | — | — | — | News announcement text |
| `.faction h3` | `--font-mono` | 18px | 600 | — | — | Faction names |
| `.hero-content .tagline` | `--font-mono` | 14px | — | 1.6 | — | Hero subtitle |
| `.history-text p` | `--font-mono` | 14px | — | 1.7 | — | Body text |
| `.cta-section p` | `--font-mono` | 14px | — | — | — | CTA description |
| `.btn-lg-*` | `--font-mono` | 14px | — | — | 1px uppercase | Large buttons |
| `.resource-card h3` | `--font-mono` | 14px | 600 | — | — | Resource titles |
| `.faction p` | `--font-mono` | 13px | — | 1.6 | — | Faction descriptions |
| `.section-header p` | `--font-mono` | 13px | — | — | — | Section descriptions |
| `.hero-content .tagline-note` | `--font-mono` | 13px | — | — | — | Publisher credit text |
| `.scenarios-list` | `--font-mono` | 13px | — | 1.8 | — | Scenarios listing |
| `.logo` | `--font-mono` | 13px | 600 | — | 0.5px | Logo text (WIS dark, Wiki green) |
| `.resource-card p` | `--font-mono` | 12px | — | 1.6 | — | Resource descriptions |
| `.timeline-event` | `--font-mono` | 12px | — | — | — | Timeline events |
| `.btn-sm-*` | `--font-mono` | 12px | — | — | 0.5px uppercase | Small buttons |
| `.wip-banner` | `--font-mono` | 12px | — | — | 0.5px uppercase | WIP banner |
| `.nav-links a` | `--font-mono` | 12px | — | — | 0.5px uppercase | Nav links |
| `.stat-label` | `--font-mono` | 11px | — | — | 0.5px uppercase | Stat labels |
| `.faction .subtitle` | `--font-mono` | 11px | — | — | 0.5px uppercase | Faction subtitles |
| `.faction-units` | `--font-mono` | 11px | — | — | — | Unit lists |
| `.faction-units strong` | `--font-mono` | 10px | — | — | 0.5px uppercase | Unit category labels |
| `.timeline-date` | `--font-mono` | 11px | — | — | 0.5px uppercase | Timeline dates |
| `.footer-links a`, `.copyright` | `--font-mono` | 11px | — | — | 0.5px uppercase | Footer text |

### Typography Principles
- **Monospace everywhere**: Nearly all text uses `--font-mono` — the site reads like a terminal or code editor
- **Weight restraint**: Only two weights used — 400 (default) and 600 (headings, stats, labels). No bold/700
- **Uppercase labels**: Nav links, buttons, stat labels, subtitles, footer links all use `text-transform: uppercase` with `letter-spacing: 0.5px`
- **Tabular nums**: Year and stat values use `font-variant-numeric: tabular-nums` for alignment
- **Logo**: "WIS" in dark (`--fg`), "Wiki" in green (`--accent`). Clickable link to landing page

## 4. Component Stylings

### Navigation (`.container` inside `nav`)
```
position: sticky; top: 0; z-index: 100
background: oklch(99% 0.003 250 / 0.85)
backdrop-filter: blur(12px)
border-bottom: 1px solid var(--border)
height: 56px
```
- **Logo** (`.logo`): 13px mono, weight 600, letter-spacing 0.5px. Wrapped in `<a href="https://wis-wiki.web.app/">`. `WIS` uses `--fg` (dark), `<span>Wiki</span>` uses `--accent` (green). No underline, pointer cursor
- **Nav links** (`.nav-links`): flex row, gap 32px, 12px mono uppercase, `--muted` color → `--accent` on hover
- **Nav right**: No CTA button. Only nav links appear in the nav bar. Action buttons live in the hero section

### Hero Section (`.hero`)
```
padding: 80px 0 64px
border-bottom: 1px solid var(--border)
```
- **Grid** (`.hero-grid`): 2-col (`1fr 1fr`), gap 48px, align center
- **Headline** (`.hero-content h1`): 42px mono, weight 400, line-height 1.1, letter-spacing -1px. `.year` spans use `--accent` green, `tabular-nums`
- **Tagline** (`.hero-content .tagline`): 14px mono, `--muted`, line-height 1.6, margin-bottom 12px
- **Tagline note** (`.hero-content .tagline-note`): 13px mono, `--muted`, margin-bottom 24px. Used for publisher credit text
- **Stats** (`.hero-stats`): flex row, gap 32px, margin-bottom 24px. `.stat-value`: 28px mono 600. `.stat-label`: 11px mono uppercase `--muted`
- **Hero buttons** (`.hero-buttons`): flex row, gap 12px, flex-wrap wrap. Contains action buttons (`.btn-sm-dark`)
- **Video** (`.hero-video`): aspect-ratio 16/10, 1px `--border` border, `--surface` background. iframe fills 100%

### Section Headers (`.section-header`)
```
margin-bottom: 40px
```
- **Heading** (`h2`): 24px mono, weight 600. Uses `// ` prefix in HTML (code comment style)
- **Description** (`p`): 13px mono, `--muted`

### Resource Grid (`.resources-grid`)
```
grid-template-columns: repeat(auto-fill, minmax(320px, 1fr))
gap: 16px
```
- Extensible auto-fill layout — cards flow naturally as more are added. No layout changes needed.
- **Cards** (`.resource-card`): `<a>` or `<span>` elements. `--surface` background, 1px `--border` border, 24px padding, `display: block`, `text-decoration: none`. Hover: border-color and box-shadow shift to `--accent`
- **Placeholder cards** (`.resource-card.placeholder`): `opacity: 0.5`, `cursor: default`. Hover: no border/color change
- **Card heading** (`h3`): 14px mono 600, flex with gap 8px. `::before` pseudo-element: `→` arrow in `--accent` green
- **Card description** (`p`): 12px mono, `--muted`, line-height 1.6

### Factions Grid (`.factions-grid`)
```
grid-template-columns: 1fr 1fr
gap: 1px; background: var(--border); border: 1px solid var(--border)
```
- **Faction cell** (`.faction`): `--surface` background, 32px padding
- **Header** (`.faction-header`): flex row, gap 12px, margin-bottom 16px
- **Icon** (`.faction-icon`): 40x40px, `--bg` background, 1px `--border` border, 18px mono centered
- **Name** (`h3`): 18px mono 600
- **Subtitle** (`.subtitle`): 11px mono uppercase `--muted`, letter-spacing 0.5px
- **Description** (`p`): 13px mono `--muted`, line-height 1.6
- **Unit list** (`.faction-units`): 11px mono. `strong`: 10px uppercase `--fg`, block display. `ul`: no list-style, `--muted`. `li`: 4px 0 padding, 1px `--border` bottom, flex with space-between. `.count`: `--accent` green, `tabular-nums`

### History Section (`.history-content`)
```
grid-template-columns: 2fr 1fr
gap: 48px
```
- **Text** (`.history-text p`): 14px mono, line-height 1.7, `--muted`, margin-bottom 16px
- **Scenarios list** (`.scenarios-list`): 13px mono, `--muted`, line-height 1.8, margin-top 16px. `strong`: `--fg`
- **Timeline** (`.timeline`): `border-left: 2px solid var(--accent)`, padding-left 20px
- **Timeline item** (`.timeline-item`): margin-bottom 24px, relative position
- **Timeline dot**: `::before` pseudo — 8x8px square, `--accent` background, absolute at -24px left, 6px top
- **Date** (`.timeline-date`): 11px mono uppercase `--accent`, letter-spacing 0.5px
- **Event** (`.timeline-event`): 12px mono `--fg`

### CTA Section (`.cta-section`)
```
text-align: center
padding: 96px 0
```
- **Heading** (`h2`): 32px mono, weight 400
- **Description** (`p`): 14px mono `--muted`, margin-bottom 32px
- **Buttons** (`.cta-buttons`): flex center, gap 16px, flex-wrap wrap
- Buttons use the composable button system (see Button System below)

### Button System (composable size + color)

Two dimensions: **size** (sm/lg) and **color** (dark/green). All buttons: `--font-mono`, `text-transform: uppercase`, `display: inline-block`, `border: none`.

| Class | Font Size | Padding | Background | Text | Hover Effect |
|-------|-----------|---------|------------|------|--------------|
| `.btn-sm-dark` | 12px | 8px 16px | `--fg` (dark) | `--bg` (light) | `--accent` (green) |
| `.btn-sm-green` | 12px | 8px 16px | `--accent` (green) | `--bg` (light) | `opacity: 0.9` |
| `.btn-lg-dark` | 14px | 16px 48px | `--fg` (dark) | `--bg` (light) | `--accent` (green) |
| `.btn-lg-green` | 14px | 16px 48px | `--accent` (green) | `--bg` (light) | `opacity: 0.9` |

**Usage pattern:** Apply the class to any `<a>` or `<button>`. All 4 combinations are available on any page.

```html
<!-- Small dark button (hero action buttons, nav buttons) -->
<a class="btn-sm-dark" href="...">TEXT</a>

<!-- Small green button (compact primary action) -->
<a class="btn-sm-green" href="...">TEXT</a>

<!-- Large dark button (news, secondary CTA) -->
<a class="btn-lg-dark" href="...">TEXT</a>

<!-- Large green button (primary CTA) -->
<a class="btn-lg-green" href="...">TEXT</a>
```

### WIP Banner (`.wip-banner`)
```
background: var(--accent-warm)
color: var(--surface)
text-align: center
font-family: var(--font-mono)
font-size: 12px
padding: 8px 16px
text-transform: uppercase
letter-spacing: 0.5px
```
Full-width bar placed below nav on work-in-progress pages. Uses warm orange/coral for visibility.

### News Section (`.news-announce`, `.news-buttons`)
```
.news-announce: 18px mono, --fg, margin-bottom 32px
.news-buttons: flex row, gap 16px, flex-wrap, margin-top 24px
```
Simple announcement layout: heading text followed by action buttons. Used on `news.html`.

### Footer (`footer`)
```
padding: 32px 0
border-top: 1px solid var(--border)
```
- **Container**: flex row, space-between, center aligned
- **Links** (`.footer-links`): flex row, gap 24px, no list-style. `a`: 11px mono uppercase `--muted` → `--fg` on hover
- **Copyright** (`.copyright`): 11px mono `--muted`. Text: "© 2026 WIS Wiki. Developed for the WIS community."

## 5. Layout Principles

### Container
```css
.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 24px;
}
```
All content is constrained to 1100px centered with 24px horizontal padding.

### Grid System
Grids use a 1px-gap trick where `background: var(--border)` on the grid container creates the grid lines, and child cells use `--surface` background:
```css
.grid {
  display: grid;
  gap: 1px;
  background: var(--border);
  border: 1px solid var(--border);
}
.cell {
  background: var(--surface);
}
```

**Grid variants:**
- `.hero-grid`: `grid-template-columns: 1fr 1fr`, gap 48px
- `.resources-grid`: `repeat(auto-fill, minmax(320px, 1fr))`, gap 16px (extensible — cards flow naturally)
- `.factions-grid`: `grid-template-columns: 1fr 1fr`, gap 1px (border trick)
- `.history-content`: `grid-template-columns: 2fr 1fr`, gap 48px

### Spacing Scale
| Element | Padding/Margin |
|---------|----------------|
| Section vertical | 64px 0 |
| Hero vertical | 80px 0 64px |
| CTA vertical | 96px 0 |
| Resource card | 24px |
| Faction cell | 32px |
| Button (sm) | 8px 16px |
| Button (lg) | 16px 48px |
| Stat gap | 32px |
| Hero grid gap | 48px |
| Hero buttons gap | 12px |
| CTA buttons gap | 16px |
| History gap | 48px |
| Section header margin | 40px bottom |
| Tagline margin-bottom | 12px |
| Tagline-note margin-bottom | 24px |

### Border System
All borders use `var(--border)` (`oklch(90% 0.008 240)`):
- Sections: `border-bottom: 1px solid var(--border)`
- Nav: `border-bottom: 1px solid var(--border)`
- Footer: `border-top: 1px solid var(--border)`
- Video/cells: `border: 1px solid var(--border)`
- Grid containers: `border: 1px solid var(--border)` + `background: var(--border)` (1px gap trick)
- Unit list items: `border-bottom: 1px solid var(--border)`

## 6. Responsive Behavior

Single breakpoint at **768px** (`@media (max-width: 768px)`):

### Layout Changes
| Component | Desktop (>768px) | Mobile (≤768px) |
|-----------|------------------|-----------------|
| `.hero-grid` | `grid-template-columns: 1fr 1fr`, gap 48px | `1fr`, gap 32px |
| `.hero-content h1` | 42px | 28px |
| `.resources-grid` | auto-fill, `minmax(320px, 1fr)` | 1-col (`1fr`) |
| `.factions-grid` | 2-col (`1fr 1fr`) | 1-col (`1fr`) |
| `.history-content` | 2-col (`2fr 1fr`), gap 48px | 1-col (`1fr`) |
| `.nav-links` | flex row, gap 32px | `display: none` (hidden) |

### Mobile-Specific Rules
- Hero headline shrinks from 42px to 28px
- All multi-column grids collapse to single column
- Navigation links are completely hidden (no hamburger menu implemented)
- Container padding remains `0 24px` at all sizes
- No touch-target adjustments — design is desktop-first with basic mobile collapse

## 8. Quartz Layout Integration

The Quartz-powered Manual site (`wis-wiki-manual.web.app`) is customised to match the WIS Wiki design system and enable seamless navigation between subsites.

### Navigation Elements

| Element | Location | Text | Links to |
|---|---|---|---|
| Navbar logo | Top left (fixed) | WIS Wiki | `https://wis-wiki.web.app/` |
| Navbar nav | Top right | RESOURCES, VIDEOS, HISTORY, SCENARIOS, MANUAL | Main site pages / Manual root |
| Quartz sidebar | Left panel | WIS Manual | `https://wis-wiki-manual.web.app/` |
| Footer | Bottom | Manual, Videos, Forum | Respective URLs |

The navbar and footer are Quartz components (`NavBar.tsx`, `WikiFooter.tsx`) in `quartz/components/`. They render identical HTML to the WIS-Wiki-Web navbar/footer and are SPA-aware, re-rendered on each navigation so the active MANUAL link stays highlighted.

### CSS Variable Aliases

Quartz uses its own CSS variable naming. WIS-Wiki names are aliased in `quartz/styles/custom.scss`:

| WIS-Wiki Name | Quartz Source |
|---|---|
| `--bg` | `--light` |
| `--fg` | `--darkgray` |
| `--muted` | `--gray` |
| `--border` | `--lightgray` |
| `--accent` | `--secondary` |
| `--accent-warm` | `--tertiary` |
| `--font-mono` | `--codeFont` |

### Layout Changes (`quartz.layout.ts`)

- Added `NavBar()` to the `header` slot (fixed position at top of page)
- Replaced `Component.Footer()` with `WikiFooter()`
- Removed `Component.ArticleTitle()` from `beforeBody` (page titles removed from content area)
- Sidebar title renamed from `WIS Wiki` to `WIS Manual`, linking to `https://wis-wiki-manual.web.app/`

### Explorer Font Size

Reduced in `quartz/styles/custom.scss` for a more compact sidebar:
- Explorer container: `0.8rem`
- Folder/file entries: `0.85rem`


## 7. Agent Prompt Guide

### Quick Reference
- **Page background**: `oklch(98% 0.005 250)` (`--bg`)
- **Card/surface background**: `oklch(100% 0 0)` (`--surface`)
- **Primary text**: `oklch(22% 0.02 240)` (`--fg`)
- **Secondary text**: `oklch(50% 0.018 240)` (`--muted`)
- **Borders/grid lines**: `oklch(90% 0.008 240)` (`--border`)
- **Primary accent (green)**: `oklch(58% 0.16 145)` (`--accent`)
- **Secondary accent (orange)**: `oklch(58% 0.16 35)` (`--accent-warm`)
- **Nav background**: `oklch(99% 0.003 250 / 0.85)` with `backdrop-filter: blur(12px)`
- **Monospace font**: `'JetBrains Mono', 'IBM Plex Mono', ui-monospace, Menlo, monospace`
- **System font**: `-apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', system-ui, sans-serif`
- **Container**: `max-width: 1100px`, `padding: 0 24px`
- **Grid trick**: `gap: 1px; background: var(--border)` on container, `--surface` on cells (used in factions-grid)
- **Breakpoint**: `768px`
- **Buttons**: `btn-sm-dark`, `btn-sm-green`, `btn-lg-dark`, `btn-lg-green` — composable size + color
- **Logo**: `WIS` (dark) + `<span>Wiki</span>` (green), clickable link to `https://wis-wiki.web.app/`

### Example Prompts

**Hero section:**
> "Create a hero section with 80px top / 64px bottom padding and border-bottom. Use a 2-col grid (1fr 1fr) with 48px gap. Headline: 42px JetBrains Mono weight 400, line-height 1.1, letter-spacing -1px, color oklch(22% 0.02 240). Highlight years in oklch(58% 0.16 145) green with tabular-nums. Tagline: 14px mono, oklch(50% 0.018 240), line-height 1.6. Stats row: 28px mono 600 for values (tabular-nums), 11px uppercase mono for labels. Right column: 16/10 aspect-ratio video iframe with 1px border."

**Resource grid:**
> "Build an auto-fill grid: grid-template-columns repeat(auto-fill, minmax(320px, 1fr)), gap 16px. Cards: white background, 1px border, 24px padding, display block, text-decoration none. Hover: border-color and box-shadow shift to green. Headings: 14px JetBrains Mono weight 600 with a → pseudo-element in green. Descriptions: 12px mono, oklch(50% 0.018 240), line-height 1.6. Placeholder cards: opacity 0.5, cursor default, no hover change."

**Factions grid:**
> "Create a 2-col grid (1fr 1fr) with the 1px border gap trick. Faction cells: 32px padding. Header: flex row with 40x40px icon (oklch(98% 0.005 250) bg, 1px border). Name: 18px mono 600. Subtitle: 11px uppercase mono, oklch(50% 0.018 240), letter-spacing 0.5px. Description: 13px mono, line-height 1.6. Unit list: 11px mono, strong labels at 10px uppercase, li items with 1px bottom border, count spans in green tabular-nums."

**Timeline:**
> "Build a timeline with border-left: 2px solid oklch(58% 0.16 145), padding-left 20px. Items: 24px bottom margin, relative position. Dot: 8x8px absolute, -24px left, 6px top, green background. Date: 11px uppercase mono in green, letter-spacing 0.5px. Event: 12px mono in oklch(22% 0.02 240)."

**CTA section:**
> "Center-aligned CTA with 96px vertical padding. Heading: 32px JetBrains Mono weight 400. Description: 14px mono, oklch(50% 0.018 240), 32px bottom margin. Buttons: flex center, 16px gap. Primary: btn-lg-green class (green bg, white text, 16px 48px padding, 14px uppercase mono, letter-spacing 1px). Secondary: btn-lg-dark class (dark bg, light text, same padding, hover to green)."

**Navigation:**
> "Sticky nav, top 0, z-index 100. Background: oklch(99% 0.003 250 / 0.85) with backdrop-filter blur(12px). Border-bottom: 1px solid oklch(90% 0.008 240). Height: 56px. Container: flex space-between center. Logo: wrapped in <a> link, 13px JetBrains Mono weight 600, letter-spacing 0.5px. WIS in dark, Wiki in green. Nav links: flex row 32px gap, 12px uppercase mono, oklch(50% 0.018 240) → green on hover. No CTA button in nav."

### Design Consistency Rules
1. **Monospace everything** — nearly all text uses JetBrains Mono / IBM Plex Mono
2. **oklch palette** — all colors use oklch notation, no hex/rgb
3. **1px gap grid trick** — background color creates grid lines, cells get `--surface` (used in factions-grid)
4. **`// ` prefix** — section headers use code comment style prefix
5. **Uppercase labels** — nav, buttons, stats, subtitles: `text-transform: uppercase; letter-spacing: 0.5px`
6. **Two accent colors** — green (`--accent`) for primary, orange (`--accent-warm`) for WIP banner
7. **768px breakpoint** — single mobile breakpoint, grids collapse to 1-col, nav links hide
8. **No border-radius** — all elements are square/rectangular, no rounded corners used anywhere
9. **`font-variant-numeric: tabular-nums`** — used on year/stat values for alignment
10. **Weight 600 for emphasis** — headings, stats, labels use 600; everything else is 400
11. **Composable buttons** — 4 classes: `btn-sm-dark`, `btn-sm-green`, `btn-lg-dark`, `btn-lg-green`. Size + color are fixed together, not separate modifiers
12. **Clickable logo** — `WIS` (dark) + `Wiki` (green) wraps `<a href="https://wis-wiki.web.app/">` on every page
