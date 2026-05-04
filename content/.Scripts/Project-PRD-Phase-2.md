# WIS Web App - Phase 2 PRD (Living Document)

## 1. Project Vision
To transform the "War in Spain" static manual into a premium, interactive web application that serves as the ultimate companion for players.

## 2. Core Components
| Component | Technology | Description |
|---|---|---|
| **Manual Wiki** | Quartz 4.0 | The existing Obsidian notes converted to searchable HTML. |
| **Web App** | Next.js (App Router) | The "Shell" containing the landing page, tools, and blog. |
| **AI Assistant** | Gemini API (Vertex AI) | A semantic search tool that answers rule questions using the manual. |
| **Scenario DB** | Firebase Data Connect | A PostgreSQL database for unit stats and scenario data. |
| **Hosting** | Firebase App Hosting | Integrated Google infrastructure for global delivery. |

## 3. The AI Search Architecture (Lite-RAG)
To avoid high costs and complexity, we will use a "Static Index" approach:

### 3.1 Metadata Strategy
Files are identified for the AI assistant using Obsidian Frontmatter:
- **`type`**: Categorizes the source (e.g., `WIS_Manual`, `Dev_Notes`, `Personal_Analysis`).
- **`ai_search` (Boolean)**: A hidden field (replaces the visible `KB_Compile` tag). If `true`, the script includes this file in the AI index.
- **Benefits**: This keeps the UI clean in Quartz while giving the build script precise instructions.

### 3.2 The Build Pipeline
1. **Source**: Developer pushes updates to GitHub.
2. **Compile**: A GitHub Action runs `Generate-KnowledgeBase.ps1`.
3. **Filter**: The script only selects files where `ai_search: true`.
4. **Output**: Produces `knowledge_base.json` (Title, URL, Content).
5. **Deploy**: The JSON and Quartz HTML are deployed to Firebase.

## 4. Implementation Roadmap
### Phase 2.1: Infrastructure & Cleanup (Current Focus)
- [ ] **Task 1**: Migrate visible `KB_Compile` tags to a hidden `ai_search: true` frontmatter key.
- [ ] **Task 2**: Create `Generate-KnowledgeBase.ps1` to produce the JSON.
- [ ] **Task 3**: Initialize the Firebase Project and GitHub Monorepo.
- [ ] **Task 4**: Set up the Landing Page "Under Construction" on the new domain.

### Phase 2.2: The AI Integration
- [ ] **Task 5**: Create the Secure API Proxy (Firebase Function).
- [ ] **Task 6**: Implement the "Ask the Manual" chat interface.

---

## 5. Decision Log & Refinements
- **2026-05-03**: Decided against full Vector RAG in favor of Static JSON Indexing to save costs and reduce latency.
- **2026-05-03**: Decided to use hidden frontmatter (`ai_search`) instead of visible tags to keep the Quartz UI professional.
