# WIS Wiki Web

Static wiki and resource hub for **War in Spain 1936-39**, a theatre-level operational wargame by Matrix Games and Joint Warfare Simulations.

**Live site:** [wis-wiki.web.app](https://wis-wiki.web.app)

## Overview

WIS Wiki provides players with a curated collection of resources to learn and master the game:

- **Searchable Manual** — Full game manual in wiki format for quick reference
- **Video Tutorials** — 7-part tutorial series covering the Balearics Scenario by Cannae Gaming
- **Historical Context** — Timelines, faction breakdowns, and background for each scenario
- **Scenarios & Campaigns** — All 10 scenarios with dates, objectives, and historical summaries
- **Community Links** — Direct access to the Matrix Games forum and YouTube playlist

## Tech Stack

- Static HTML/CSS (no JavaScript framework)
- Terminal/monospace design aesthetic with oklch color palette
- Composable button system (size + color modifiers)
- Auto-fill grid layouts for extensible content cards
- Firebase Hosting with GitHub Actions CI/CD

## Project Structure

```
wis-wiki-web/
├── public/               # Firebase serves this directory
│   ├── index.html          # Landing page
│   ├── videos.html         # Video tutorials
│   ├── scenarios.html      # Scenarios & campaigns
│   ├── history.html        # Historical context
│   ├── news.html           # News & announcements
│   ├── styles.css          # Shared stylesheet
│   └── images/             # Static assets (empty, ready for future use)
├── scripts/
│   └── Github_Push.ps1   # Commit/push helper
├── DESIGN.md             # Design system docs
├── firebase.json         # Firebase Hosting config
├── .firebaserc           # Firebase project config
└── .github/
    └── workflows/
        └── deploy.yml    # Auto-deploy on push to main
```

## Development

No build step required. All files are served as-is by Firebase Hosting.

### Local Testing

Install Firebase CLI and run the emulator:

```bash
firebase init hosting
firebase emulators:start
```

### Deployment

Push to `main` branch — GitHub Actions deploys automatically via `firebase deploy`.

Manual deploy:

```bash
firebase deploy --only hosting
```

## Deployed Sites

| Site | URL |
|------|-----|
| WIS Wiki | https://wis-wiki.web.app |
| WIS Wiki Manual | https://wis-wiki-manual.web.app |

## License

Developed for the WIS community. Not affiliated with Matrix Games or Joint Warfare Simulations.
