# WIS-Wiki Manual: TODO

## Agentic Search Implementation (from PRD: docs/prd-agentic-search.md)

### Module A: Index Generator (wis-wiki-manual/scripts/)
- [x] Create script to read MD files from content/ (symlinked to vault)
- [x] Add image link stripping (remove `![](*.png/jpg/gif)` before upload)
- [x] Upload directly to File Search Store (no intermediate JSON needed)
- [x] Add file type validation (.md, .txt, .json, .csv only)
- [x] Store now has all 536 content files (verified complete)
- [x] Create Python upload script (Node.js SDK doesn't support File Search uploads)
- [x] Use git diff to detect changed files (works reliably)
- [x] Store manager script for verification and uploads (scripts/store-manager.py)
- [x] Tested incremental upload with 11 changed files (1 uploaded, 10 skipped ai_search:false)
- [ ] Add delete-before-upload pattern for updating existing docs
- [ ] Integrate with GitHub_Deployment.ps1 trigger
- [ ] Note: This repo handles document UPLOAD only, NOT search (search goes in wis-wiki-web Module C)

### Module B: Store Manager (new repo: wis-wiki-search-admin)
- [ ] Create standalone admin tool for File Search Store management
- [ ] Add transcript upload from YouTube API
- [ ] Implement full re-index option (delete all, re-upload all)
- [ ] Add FAQ document upload capability

### Module C: Search App (wis-wiki-web)
- [ ] Create "Ask the Manual" chat interface page
- [ ] Implement Firebase Auth (Google + Email providers)
- [ ] Add rate limiting (10/hour, 100/day per user)
- [ ] Implement query length limit (500 chars max)
- [ ] Build source citation display with clickable links
- [ ] Add URL mapping based on subsite metadata
- [ ] Build user search history (Firestore storage)
- [ ] Add user deletion capability for privacy

### Integration Testing
- [ ] Test semantic search: "AKL" returns ship type
- [ ] Test semantic search: "detection range of destroyer" synthesizes answer
- [ ] Test rate limiting triggers correctly
- [ ] Test unauthenticated user access denied
- [ ] Test source citation navigation to correct URL

### Known Issues
- **Rate Limits (Free Tier)**: 5 requests/minute, 1 concurrent. Scripts must add delays (12+ sec between queries) to avoid hitting limit.
- **Search Not in This Repo**: wis-wiki-manual handles document upload only. Search goes in wis-wiki-web (Module C) with Cloud Functions backend.
- **API Key Security**: Search requires separate Gemini API key - must NEVER be exposed in frontend. Use Firebase Cloud Functions to proxy requests.
- **Store ID**: `fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27`
- **Document Deletion Not Possible**: File Search API doesn't allow deleting indexed documents (cleanup script failed) - need delete-before-upload pattern for updates

---

## Completed
- [x] PRD created: docs/prd-agentic-search.md
- [x] README updated to reflect actual project (Quartz, Obsidian Vault)
- [x] Scripts folder cleaned (archive created, redundant files removed)
- [x] AI search frontmatter verification (545 true, 11 false, 0 missing)
- [x] Module A: 737 documents indexed in File Search Store
- [x] Testing scripts created (interactive-search.py, quick-test.py)
- [x] Store ID: fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27
- [x] Remove ArticleTitle from Quartz layout (page title no longer appears above content)
- [x] Add WIS-Wiki navbar and footer to Quartz pages (NavBar.tsx, WikiFooter.tsx)
- [x] Reduce Explorer sidebar font size (quartz/styles/custom.scss)
- [x] Update Quartz sidebar link text to "WIS Manual" linking to https://wis-wiki-manual.web.app/
- [x] CSS variable aliases added (WIS-Wiki names to Quartz variables in custom.scss)
- [x] Quartz improvement plan fully implemented and verified
- [x] Quartz_Config.MD created (replaces Improvement Plan) — current-state reference
- [x] Confirmed working: navbar/footer on all pages, Explorer font size reduced, ArticleTitle removed, page titles display correctly via breadcrumbs, accent-warm hover on sidebar, CSS variables aliased
