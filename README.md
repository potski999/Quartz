# WIS Wiki Manual

Static wiki manual for **War in Spain 1936-39**, a theatre-level operational wargame by Matrix Games and Joint Warfare Simulations.

**Live site:** [wis-wiki-manual.web.app](https://wis-wiki-manual.web.app)

## Overview

WIS Wiki Manual provides a searchable, wiki-formatted version of the full game manual. Content is sourced from an Obsidian Vault and transformed into static HTML via Quartz 4.

- **Source**: Obsidian Vault (symlinked to `content/`)
- **Output**: Static HTML deployed to Firebase Hosting
- **Content status**: Stable — reflects the original game manual PDF, cleaned and normalized

## Tech Stack

- **Quartz 4** — Static site generator transforming Markdown content
- **Node.js 22+** — Required runtime
- **Firebase Hosting** — Live deployment
- **GitHub Actions** — CI/CD on push to `v4` branch

For Quartz configuration details, see:
- `.skills/quartz-basics/` — Build and deployment commands
- `.skills/quartz-design/` — Styling customization

## Styling Customizations

The default Quartz appearance has been modified to match wis-wiki-web:

- **Dark mode disabled** — Darkmode component removed from layout
- **Colors aligned** — Configured in `quartz.config.ts` to match the WIS design palette
- **Typography** — JetBrains Mono (headers/code), Inter (body)

See `DESIGN.md` for full design system details.

## Project Structure

```
wis-wiki-manual/
├── content/                  # Symlink to Obsidian Vault (Markdown source)
├── public/                   # Generated HTML output (served by Firebase)
├── quartz.config.ts          # Quartz site configuration
├── quartz.layout.ts          # Page layout and components
├── styles.css                # Shared stylesheet (reference only)
├── scripts/
│   ├── generate-and-upload-index.js  # Index generator (Node.js)
│   ├── test-upload.py                # Python upload script
│   ├── interactive-search.py          # Search testing
│   ├── cleanup-duplicates.py          # Duplicate cleanup (not functional)
│   └── Github_Deployment.ps1          # Build, commit, push helper
├── docs/
│   └── prd-agentic-search.md          # Agentic search PRD
├── .github/workflows/        # Auto-deploy on merge to v4
├── .firebaserc               # Firebase project config
└── package.json              # Node.js dependencies
```

## Agentic Search System (Document Upload Only)

The manual uses **Google Gemini File Search** for AI-powered search.

- **Store ID**: `fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27`
- **Index**: 536 documents (verified complete)
- **Model**: gemini-2.0-flash (semantic search)

> **Important**: This repo handles document **upload** only. Search functionality lives in wis-wiki-web (Module C) with Firebase Cloud Functions backend to protect the API key.

### Scripts (Document Management)

| Script | Purpose |
|--------|---------|
| `scripts/incremental-upload.py` | Uses git diff to upload changed files to store |
| `scripts/store-manager.py` | Analyze store, upload missing files, verify integrity |
| `scripts/interactive-search.py` | Interactive search testing (rate-limited) |

### Usage

```bash
# Upload changed files (detected via git diff)
python scripts/incremental-upload.py

# Check store vs content
python scripts/store-manager.py analyze

# Upload missing files
python scripts/store-manager.py upload-missing
```

### Rate Limits (Free Tier)
- 5 requests/minute max
- 1 concurrent request
- Add 12+ second delays between queries to avoid hitting limit

### Requirements

- **API Key**: `GOOGLE_AI_API_KEY` environment variable (WIS-Wiki-Search key from Google AI Studio)
- **Rate Limits**: Free tier - 5 requests/minute, 1 concurrent. Add 12+ second delays between queries.
- **Note**: This repo handles document upload only. Search key is "WIS-Wiki-Search" - for production search, key must be protected in Firebase Cloud Functions (wis-wiki-web), never in frontend code.

## Development

### Local Testing

Build and serve locally to preview changes:

```bash
npx quartz build
npx quartz build --serve
```

Opens local server at http://localhost:8080

### Deployment

Run `scripts/Github_Deployment.ps1` — this builds the site, prompts for a commit message, commits changes, and pushes to the `v4` branch. GitHub Actions automatically deploys to Firebase on merge to `v4`.

Agents cannot deploy directly to the live site.

## Site Relationship

WIS Wiki Manual is a subsite of **wis-wiki.web.app** (the main site with landing pages, tutorials, and navigation). Links from wis-wiki-web point to specific pages in the manual.

> **Note**: If page structure or paths change in `content/`, update corresponding links in wis-wiki-web.

## Deployed Sites

| Site | URL |
|------|-----|
| WIS Wiki (main) | https://wis-wiki.web.app |
| WIS Wiki Manual | https://wis-wiki-manual.web.app |

## License

Developed for the WIS community. Not affiliated with Matrix Games or Joint Warfare Simulations.