---
name: quartz-basics
description: How to set up, build, and maintain a Quartz-powered site from Markdown content.
---

# Quartz Basics

This skill covers the essential operations for working with Quartz 4 to generate a static site from Markdown files.

## When to Use This Skill

Use this skill when:
- Setting up a new Quartz project
- Building the site from content
- Deploying to Firebase hosting
- Updating basic configuration (page title, base URL)
- Pulling updates from the upstream Quartz repository

## Project Structure

A Quartz project has this structure:

```
quartz/                    # Quartz source code
├── content/               # Markdown source files (your Obsidian Vault)
│   └── (your .md files)
├── public/                # Generated HTML output (for hosting)
├── quartz.config.ts       # Main configuration
├── quartz.layout.ts       # Page layout and components
├── quartz/styles/        # CSS and styling
└── package.json          # Node.js dependencies
```

## Key Concepts

### Content Flow
1. Markdown files in `content/` folder
2. Quartz parses and processes each file
3. HTML output generated in `public/` folder
4. Host the `public/` folder on any static host (Firebase, Netlify, Vercel, GitHub Pages)

### Configuration Files
- `quartz.config.ts` — Site settings (title, fonts, colors, plugins)
- `quartz.layout.ts` — Which components appear on pages (header, sidebar, footer)

## Commands

### Build the Site

```bash
npm run build
```

This creates the static HTML files in the `public/` folder.

### Serve Locally (for testing)

```bash
npm run serve
# or
npm run dev
```

Opens a local server at http://localhost:8080

### Clean Build Output

```bash
npm run clean
```

Removes the `public/` folder.

## Basic Configuration

### Changing Page Title

In `quartz.config.ts`:

```typescript
configuration: {
  pageTitle: "Your Site Name",
  // ...
}
```

This changes the title shown in the browser tab and page header.

### Changing Base URL

In `quartz.config.ts`:

```typescript
configuration: {
  baseUrl: "your-site.web.app",
  // ...
}
```

Set this to your deployed domain (without https://).

### Ignoring Files

In `quartz.config.ts`:

```typescript
configuration: {
  ignorePatterns: ["private", "templates", ".obsidian"],
  // ...
}
```

Files matching these patterns won't be published.

## Content Guidelines

- Use standard Markdown (.md files)
- Frontmatter is supported (YAML between --- delimiters)
- Internal links: `[[wikilinks]]` or standard Markdown links
- Images: Place in `content/` or use absolute URLs
- Callouts: Supported via > [!note] syntax

## Deployment to Firebase

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init` (select Hosting)
4. Deploy: `firebase deploy`

The `public/` folder is what gets hosted.

## Updating from Upstream

If you forked from the original Quartz repo (jackyzha0/quartz):

```bash
# Add upstream remote if not present
git remote add upstream https://github.com/jackyzha0/quartz.git

# Fetch updates
git fetch upstream

# Merge upstream/v4 into your branch
git merge upstream/v4
```

Resolve any conflicts if they arise. Your custom configurations in `quartz.config.ts` and `quartz.layout.ts` should be preserved.

## Troubleshooting

### Build fails
- Check Node.js version (requires Node 22+)
- Run `npm install` to ensure dependencies are installed
- Check for syntax errors in .md files

### Content not showing
- Verify files are in `content/` folder
- Check ignorePatterns in config
- Ensure files have .md extension

### Links not working
- Use relative paths for internal links
- Avoid spaces in filenames, or use hyphens