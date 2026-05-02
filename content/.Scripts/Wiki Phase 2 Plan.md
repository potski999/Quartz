---
draft: true
---

# WIS Web Application – Revised Architecture Plan

## The Three Content Types

You are building three distinct things with different update patterns:

| Type | Content | Updates | Examples |
|---|---|---|---|
| **Manual Wiki** | War in Spain manual, converted from PDF | Rarely — when game patches | Quartz HTML, already built |
| **Game App** | Kanban, Map, OOB, AI Assistant, Scenario DB | Regularly — as features added | Full-stack Next.js |
| **Blog / Articles** | Videos, personal experience, forum summaries | Frequently — ongoing content | Your analysis, promotions |

These have different needs but can share one domain and one hosting platform.

---

## Simplifying the Architecture: One Repo, One Project, One Domain

### The mental model

```
wis-wiki.com/              ← Landing page  (Next.js)
wis-wiki.com/manual/       ← Quartz wiki   (static HTML, served as files)
wis-wiki.com/app/          ← Game tools    (Next.js dynamic)
wis-wiki.com/blog/         ← Articles      (Next.js + MDX)
```

One GitHub repository. One Firebase project. One domain.

### Repository structure

```
wis-wiki/
├── vault/              ← Obsidian MD files (source of truth for wiki + LLM)
├── quartz/             ← Quartz config (builds vault/ → HTML)
├── app/                ← Next.js application
│   ├── app/            ← Next.js App Router pages
│   │   ├── page.tsx    ← Landing page
│   │   ├── app/        ← Game tools routes
│   │   └── blog/       ← Blog routes
│   ├── public/
│   │   ├── manual/     ← Quartz HTML output (copied here at build)
│   │   └── knowledge_base.json  ← Pre-built from vault MD files
│   └── package.json
├── data/               ← CSV scenario files
└── .github/workflows/  ← CI/CD pipeline
```

### GitHub Actions build pipeline (on push to main)

```yaml
1. Build Quartz → output HTML
2. Copy Quartz output → app/public/manual/
3. Run Generate-KnowledgeBase script → app/public/knowledge_base.json
4. Import any new CSVs → Cloud SQL (if data/ changed)
5. Build Next.js
6. Deploy to Firebase App Hosting
```

This means updating the manual is: **edit vault → git push → done**. The pipeline handles the rest automatically.

---

## The MD Files in the Cloud — You Do NOT Need Them Stored Separately

### The problem restated
Once Quartz converts MD to HTML, an LLM cannot easily read HTML. You need the text content accessible to the AI assistant.

### The solution — compile to a single static JSON at build time

A build script reads all 339 vault MD files and produces `knowledge_base.json`:

```json
[
  {
    "file": "4.2.1.2 Hex Side Types",
    "title": "4.2.1.2 Hex Side Types",
    "url": "/manual/4-The-Main-Map-Display/4.2.1.2-Hex-Side-Types",
    "terms": ["Reef", "Wadi", "Impassable Mountain", "Major River"],
    "content": "There are eleven distinct types of hex sides..."
  },
  ...
]
```

**Size:** ~700KB uncompressed, ~200KB gzipped. Served as a static file.

**The AI assistant then works as two simple API calls:**

```javascript
// Step 1: identify relevant sections (LLM reads the index)
const kb = await fetch('/knowledge_base.json').then(r => r.json())
const relevant = await gemini.generate(
  `Which sections of this index answer: "${userQuestion}"? Return section titles only.\n${JSON.stringify(kb.map(s => ({title: s.title, terms: s.terms})))}`
)

// Step 2: answer using full content of those sections
const sections = kb.filter(s => relevant.includes(s.title))
const answer = await gemini.generate(
  `Answer this question using only these manual sections: "${userQuestion}"\n\n${sections.map(s => s.content).join('\n\n')}`
)

// Return answer with links to HTML wiki pages
return { answer, links: sections.map(s => s.url) }
```

**This is the entire AI assistant backend.** No vector database, no embeddings, no RAG framework. Just two Gemini API calls. The total extra infrastructure cost is zero — `knowledge_base.json` is a static file.

> [!NOTE]
> If you later decide richer semantic search is needed, the same JSON can be sent to Vertex AI to generate embeddings and stored in Firestore's vector search. But start without it — it may never be necessary.

---

## The Three Content Types in Detail

### 1. Manual Wiki (Quartz)

**Status:** Mostly done. Clean up remaining items, then lock it.

**In the new structure:** Quartz builds to `app/public/manual/`. Next.js serves it as static files at `/manual/`. A rewrite rule maps `/manual/*` to the Quartz HTML files.

**Maintenance:** Near zero once published. The CI/CD pipeline rebuilds it automatically if the vault changes.

---

### 2. Game App — Kanban, Map, OOB, AI Assistant

**Framework:** Next.js (App Router). Deployed via Firebase App Hosting.

#### Kanban
- **Firestore** — stores user cards. Real-time sync built in.
- **Firebase Auth** — Google Sign-In (simplest for users familiar with Google accounts)
- Cards reference scenario unit IDs from the SQL database
- No special architecture — just standard Next.js + Firestore client SDK

#### Scenario Database
- **Firebase Data Connect** (Cloud SQL PostgreSQL) — import CSVs once
- Auto-generates a type-safe GraphQL API for the Next.js app
- Query example: "Show all ships available to Republican player in Scenario 3 of type AKL"

#### Map View
- The game map image used as a background
- SVG or Canvas hex grid overlay
- Unit markers positioned by hex coordinates from the CSV data
- Clicking a unit opens its data panel

#### OOB Diagrams
- **D3.js** (tree layout) + **milsymbol.js** (NATO symbols)
- OOB hierarchy comes from CSV data (`unit_id`, `parent_id`, `echelon`)
- This is the same technique spatialillusions.com uses, just driven by your game data instead of manual input

---

### 3. Blog / Articles

**Framework:** Next.js + MDX. No extra infrastructure.

- Write posts as `.mdx` files in `app/posts/`
- Next.js renders them as HTML at `/blog/post-name`
- Can embed custom components (video embeds, game unit cards, interactive charts)
- Full control over styling — matches the rest of the site

This is genuinely a "write MD, push to GitHub, it appears online" workflow. No CMS, no database, no maintenance.

---

## Copyright and Domain

### Domain

`wis-wiki.com` is a reasonable choice — descriptive, not claiming any trademark. The abbreviation WIS is not itself trademarked by Matrix/Slitherine (the game is "War in Spain 1936-39").

Add a clear disclaimer on the landing page:
> *"Unofficial fan companion. Not affiliated with Matrix Games or Slitherine. War in Spain 1936-39 is the property of Matrix Games/Slitherine."*

### What is and isn't acceptable

| Content | Status |
|---|---|
| Summarising/explaining rules in your own words | ✅ Generally accepted fan content |
| Publishing the manual verbatim | ⚠️ Copyright risk — keep the manual wiki behind a login, or note it's for purchasers |
| OOB data from the game | ✅ Game data (stats, numbers) is facts, not copyrightable |
| Your own analysis, videos, articles | ✅ Fully yours |
| Tools that use the game data | ✅ Tools are not reproductions |

> [!IMPORTANT]
> The safest approach for the manual wiki is to require users to confirm they own the game before accessing it, or to keep it unlisted from search engines (`noindex`). This signals it's a player tool, not a piracy site.

---

## Multiple Firebase Projects vs Subdomains

**You don't need multiple Firebase projects.** One Firebase project can host multiple sites on subdomains:
- `wis-wiki.com` — the main Next.js app (landing + app + blog)
- `manual.wis-wiki.com` — the Quartz wiki (if you prefer it separate)

But given the unified Next.js structure above, even this separation is unnecessary — the manual is just served under `/manual/` on the same app.

**Multiple Firebase projects make sense only if** you want separate billing, separate teams, or truly unrelated applications. Not needed here.

---

## Starting Point — The Right First Step

The biggest risk of this project is trying to build everything at once. The correct first step is:

**Phase 1: Move the existing wiki to Firebase, set up the monorepo, get CI/CD working.**

This gives you:
- The wiki live on the new domain
- A working deployment pipeline from GitHub
- A landing page (even if simple initially)
- A foundation every subsequent feature is built on

**After that, each phase adds one feature to the existing working site.**

### Immediate actions remaining in the vault before Phase 1

1. Fix remaining broken cross-refs
2. Move 7.x files to subfolder
3. Set `draft: false` on all clean files
4. Generate `_chunk_index.md` (becomes `knowledge_base.json` in Phase 5)

### Phase 1 tasks (Infrastructure setup)

1. Create Firebase project (Blaze plan — pay-as-you-go, not expensive)
2. Register `wis-wiki.com` (Google Domains or Namecheap)
3. Create GitHub monorepo with the structure above
4. Set up Quartz build in CI/CD pipeline
5. Deploy to Firebase — confirm wiki is live at new domain
6. Add basic Next.js landing page

**This is achievable without deep web development experience.** Firebase App Hosting is designed to deploy a Next.js app from GitHub with minimal configuration — it's closer to "connect your repo and click deploy" than writing infrastructure code.
