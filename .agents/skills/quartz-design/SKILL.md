---
name: quartz-design
description: How to customize the visual design of a Quartz site—colors, typography, dark mode, and custom CSS.
---

# Quartz Design

This skill covers how to customize the appearance of a Quartz 4 site.

## When to Use This Skill

Use this skill when:
- Changing colors to match a brand or design system
- Modifying typography (fonts)
- Removing or configuring dark mode
- Adding custom CSS
- Understanding design limitations

## Color Configuration

Colors are defined in `quartz.config.ts` under `theme.colors`.

### Light Mode Colors

```typescript
colors: {
  lightMode: {
    light: "#faf8f8",        // Page background
    lightgray: "#e5e5e5",    // Borders
    gray: "#b8b8b8",         // Graph links
    darkgray: "#4e4e4e",     // Body text
    dark: "#2b2b2b",        // Headers, icons
    secondary: "#284b63",      // Links, current graph nodes
    tertiary: "#84a59d",      // Hover states
    highlight: "rgba(143, 159, 169, 0.15)",  // Internal links bg
    textHighlight: "#fff23688",                      // Highlighted text bg
  },
}
```

### Dark Mode Colors

Similarly configured under `darkMode`:

```typescript
darkMode: {
  light: "#161618",
  lightgray: "#393639",
  gray: "#646464",
  darkgray: "#d4d4d4",
  dark: "#ebebec",
  secondary: "#7b97aa",
  tertiary: "#84a59d",
  highlight: "rgba(143, 159, 169, 0.15)",
  textHighlight: "#b3aa0288",
},
```

### Matching an Existing Color Palette

To approximate another site's colors:

1. Identify the hex values from the source design
2. Map them to the closest Quartz color role:
   - Page background → `light` or `dark` (for dark mode)
   - Text color → `darkgray` or `darkgray`
   - Accent/links → `secondary`
   - Borders → `lightgray`
3. Update the values in `quartz.config.ts`

Example mapping from WIS design (oklch approximations):

```typescript
lightMode: {
  light: "#fafafa",        // Near-white background
  lightgray: "#e5e5e5",    // Borders
  gray: "#999999",
  darkgray: "#444444",      // Body text
  dark: "#222222",         // Headers
  secondary: "#3a8d6e",    // Green accent (WIS accent)
  tertiary: "#d97706",    // Orange/warm accent
  highlight: "rgba(58, 141, 110, 0.15)",
  textHighlight: "#fef08a",
},
```

## Typography Configuration

Fonts are defined in `quartz.config.ts` under `theme.typography`:

```typescript
typography: {
  header: "Schibsted Grotesk",  // Headings
  body: "Source Sans Pro",     // Body text
  code: "IBM Plex Mono",      // Code blocks
}
```

### Requirements

- Must be available on Google Fonts
- Enter the exact Google Fonts name (case-sensitive)
- Fonts will be loaded from Google's CDN

### Common Font Options

| Font | Use |
|------|-----|
| JetBrains Mono | Monospace for code/developer feel |
| IBM Plex Mono | Alternative monospace |
| Inter | Clean sans-serif |
| Source Sans Pro | Readable body text |
| Schibsted Grotesk | Modern display font |
| Roboto | Standard sans-serif |

## Dark Mode

### Removing Dark Mode Entirely

To remove the dark mode toggle, edit `quartz.layout.ts`:

Find and remove `{ Component: Component.Darkmode() }` from the components array:

```typescript
// BEFORE
Component.Flex({
  components: [
    { Component: Component.Search(), grow: true },
    { Component: Component.Darkmode() },      // REMOVE THIS
    { Component: Component.ReaderMode() },
  ],
}),
```

```typescript
// AFTER
Component.Flex({
  components: [
    { Component: Component.Search(), grow: true },
    // Dark mode removed
    { Component: Component.ReaderMode() },
  ],
}),
```

Remove from both `defaultContentPageLayout` and `defaultListPageLayout`.

### Keeping Dark Mode but Changing Default

The dark mode component respects system preferences by default and stores user preference in localStorage. To change the default, edit `quartz/components/scripts/darkmode.inline.ts`.

## Custom CSS

For additional styling beyond config options, edit `quartz/styles/custom.scss`:

```scss
@use "./base.scss";

// Custom styles here
// These load after base styles
```

### Common Customizations

```scss
@use "./base.scss";

// Change link colors
a {
  color: var(--quartz-color-secondary);
}

// Custom heading styles
h1, h2, h3 {
  font-weight: 600;
}

// Page-specific styles
.page {
//  padding: 2rem;
}
```

## Design Limitations

### What Cannot Be Changed

- **Layout structure**: The 2-column layout (sidebar + content) is fixed
- **Border-radius**: Quartz uses rounded corners by default
- **Font origins**: Only Google Fonts are supported (not self-hosted)
- **CSS variable imports**: Cannot import external CSS files
- **Complete layout matching**: Difficult to replicate exact layouts from other systems

### What Can Be Matched (Approximately)

- Color palette (hex values)
- Typography (Google Fonts)
- Page title
- Component visibility (show/hide)
- Custom CSS overrides

## Recommendations

### For Consistent Multi-Site Design

1. Keep the same base color palette across sites
2. Use the same typography family
3. Remove dark mode if consistency is priority
4. Accept minor differences in spacing/layout

### Documenting Design Exceptions

If certain elements cannot match, document acceptable differences:

```markdown
## Design Exceptions (Quartz)

The following elements differ from the main site design but are acceptable:

- Layout: Quartz's 2-column layout, sidebar on left
- No dark mode removal for design consistency
- Typography: Uses system font fallbacks
```

## Related Skills

- See `quartz-basics` for build and deployment commands
- See AGENTS.md for project structure conventions