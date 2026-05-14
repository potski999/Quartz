# PRD: WIS Wiki Agentic Search

## Problem Statement

The WIS Wiki Manual currently uses Quartz's built-in Flexsearch for content discovery. This has fundamental limitations:

1. **Token filtering** — excludes words under 4 characters (e.g., "AKL" ship type never found)
2. **No semantic understanding** — cannot find "how to capture a port" when answer uses "take control" or "seize"
3. **No cross-section synthesis** — cannot combine information from multiple related sections
4. **No summarization** — returns exact matches, not synthesized answers

Users need a NotebookLM-style experience: natural language questions with comprehensive answers and clickable source citations.

## Solution

Implement agentic search using **Google Gemini File Search** — a fully managed RAG system requiring no infrastructure, with near-free pricing and built-in semantic search + citations.

## User Stories

1. As a registered WIS Wiki user, I want to ask natural language questions about game rules so that I get comprehensive answers even when I don't know the exact keywords
2. As a registered user, I want to see my search history so that I can revisit previous questions and their answers
3. As the site owner, I want to restrict search to authenticated users only so that I can prevent bot spam and control costs
4. As the site owner, I want rate limiting (10 queries/hour, 100/day) so that a single user cannot exhaust my API budget
5. As the site owner, I want to add new content to the search index incrementally so that I only pay for new tokens, not re-indexing everything
6. As a user, I want clickable source citations so that I can navigate directly to the relevant manual section
7. As the site owner, I want a single search store with metadata filtering so that I can search across the Manual, FAQs, and future content types together
8. As the site owner, I want the search app to be independent of content deployment so that failures in one don't affect the other
9. As the site owner, I want to include YouTube video transcripts in search so that users can find answers from the tutorial videos
10. As the site owner, I want to generate and upload the search index during the GitHub Deployment process so that content changes automatically update the search

## Implementation Decisions

### Architecture: Three Independent Modules

| Module | Location | Purpose |
|--------|----------|---------|
| **Module A: Index Generator** | wis-wiki-manual/scripts/ | Reads content/, detects changed files via git diff, uploads to File Search Store. Does NOT handle search. |
| **Module B: Store Manager** | wis-wiki-search-admin (new repo) | Standalone tool to manage the File Search Store (add transcripts, FAQs, full re-index, verify integrity) |
| **Module C: Search App** | wis-wiki-web (Next.js + Firebase Cloud Functions) | "Ask the Manual" chat interface for end users. Uses Cloud Functions to proxy Gemini API calls (protects secret API key) |

### Single Store with Metadata

- One File Search Store named "WIS Wiki Knowledge Base"
- Documents include metadata: `{source: "manual", subsite: "wis-wiki-manual"}` or `{source: "faq", subsite: "wis-wiki-faq"}`
- Query filters by source when needed
- URL mapping uses subsite metadata to prepend correct domain

### Embedding Model

- **Model**: gemini-embedding-2 (not gemini-embedding-001)
- **Multimodal**: Disabled — text-only, no image embedding
- **Image link handling**: Upload process must strip image markdown (e.g., `![](image.png)`) from MD files before indexing. This is safe because the images in the MD files do not contain searchable information.
- **File type validation**: Module must check file extension before upload (.md, .txt, .json, .csv supported; reject images, PDFs, etc.)

### Authentication & Rate Limiting

- **Required**: Firebase Auth (Google + Email) - no unauthenticated search
- Firestore collection `users/{uid}` stores: `{email, verified, role, queryCount, lastQueryDate}`
- Rate limit logic: Check last 24 hours of queries, reject if > 100
- Hourly limit: > 10 queries = reject with "Try again later" message
- **Enforce delays**: Free tier allows only 5 requests/minute and 1 concurrent request. App must enforce minimum 12-second delay between queries to stay under limit.

### Security Requirements

- **Separate API Key**: Search requires its own Gemini API key named "WIS-Wiki-Search" (not the Firebase hosting key). This key must NEVER be exposed in frontend code.
- **Backend Proxy**: All search requests must go through Firebase Cloud Functions. The frontend calls the function, the function makes the Gemini API call with the secret key, returns result to user.
- **Key storage**: "WIS-Wiki-Search" API key stored in Firebase Cloud Functions environment variables, not in frontend code.
- **IP restrictions**: For production, restrict key to Firebase server IPs. For local testing, key may need temporary IP restriction removal or use a separate test key.
- **Environment**: This repo uses `GOOGLE_AI_API_KEY` (WIS-Wiki-Search) for document uploads. Search requires a separate key in wis-wiki-web Cloud Functions.

### Query Input Controls

- Max 500 characters (prevent "Tell me everything" abuse)
- Max 5 source chunks returned (NotebookLM style, not overwhelming)
- System prompt instructs model to be concise

### Data Flow

```
GitHub_Deployment.ps1 triggers
          │
          ▼
Module A reads MD files, strips image links
          │
          ▼
Upload directly to File Search Store
          │
          ▼
wis-wiki-web uses store name from config
         │
         ▼
User query → Gemini API → Answer + Sources → Display → Log to Firestore
```

### Content Types

| Type | Format | Token Estimate | Update Frequency |
|------|--------|-----------------|------------------|
| Manual MD files | .md | ~150K tokens (816KB) | Rare (game updates) |
| FAQs | .md | ~10K tokens | Frequent |
| Video transcripts | .txt | ~50K tokens (8 hours) | Occasional |

### Pricing (Verified)

- Indexing: $0.15 per 1M tokens (one-time per document)
- Storage: Free
- Queries: Free (gemini-2.0-flash free tier)
- **Monthly cost: Pennies** (only incremental indexing for new content)

### Configuration

```json
// wis-wiki-web config/search-config.json
{
  "fileSearchStore": "fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27",
  "rateLimits": { "hourly": 10, "daily": 100 },
  "maxQueryLength": 500,
  "maxSources": 5
}
```

**Note**: The File Search Store was created and populated. Store ID: `fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27`

**Important**: Billing must be enabled in Google AI Studio for the Gemini API to function (even free tier requires billing connected).

**TODO**: Verify document count in store matches content/ after excluding images.

## Testing Decisions

| Test Scenario | Expected Result |
|---------------|------------------|
| Query "AKL" | Returns ship type answer (semantic, not keyword) |
| Query "detection range of destroyer" | Finds relevant sections, synthesizes answer |
| 11 queries in 1 hour | 11th rejected with "Rate limit exceeded" |
| Unauthenticated user accesses /ask | Redirected to login |
| Click source citation | Navigates to correct subsite URL |
| Add new MD file, re-run indexer | New file searchable within 1 hour |
| Full re-index option | All 545 files re-indexed (one-time cost ~$0.02) |

## Out of Scope

- Multiple Firebase projects (using one project for both sites is acceptable)
- Real-time search updates (index updates happen at deployment time)
- Voice search or multimodal input (text only for v1)
- User-to-user query sharing
- Export search results to PDF/markdown

## Further Notes

1. **Document Immutability**: File Search documents cannot be updated in-place. Update flow: list → delete (force: true) → upload new version. Module A must implement this pattern.

2. **Storage Calculation**: Embeddings add ~3x file size. For 1MB of MD, expect ~3MB in store. Well under free tier limits.

3. **Fallback**: If API quota unexpectedly reached, display friendly "Service temporarily unavailable" rather than error.

4. **User History Privacy**: Store query text and answers associated with user account. Allow user deletion. Do not expose to other users.

5. **Video Transcripts**: YouTube provides transcripts via API. These should be saved as .txt files and uploaded as separate documents to the same store with metadata `{source: "transcript", videoId: "xxx"}`.