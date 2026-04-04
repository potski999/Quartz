# Wiki Formatting & Interactivity Plan (Phase 2)

Based on your requirement to transform the split Markdown files into a professional, web-ready Wiki format without losing the original manual's context, here is the technical plan for Phase 2.

## 1. Smart Cross-Referencing (Auto-Linking)
To handle inline links natively, the script will build a complete "memory index" of every file it creates (mapping `1.3` to the exact filename `1.3 Editor Manual.md`). 

As it processes the text, it will use Pattern Matching to hunt for conversational references like:
* `"section 1.3"`
* `"paragraph 5.1.2"`
* `"see 14.2"`

When it finds one of these, it will automatically wrap it in an Obsidian Aliased Link format:
`[[1.3 Editor Manual|section 1.3]]`

**Why this works:** In Obsidian Reading Mode, this strictly displays as the neat text "**section 1.3**" but is fully clickable. When eventually published to the web via Obsidian Publish or MkDocs, it automatically translates into a flawless, standard HTML hyperlink.

## 2. Hierarchical Navigation (Map of Content)
Rather than relying on a monolithic 300-line Table of Contents, we will automate a Wikipedia-style drill-down structure:

* **The Master Index (`00 Home.md`):** The script dynamically generates this landing page, linking *only* to the main top-level chapters (1. Introduction, 2. Getting Started, 3. Game Modes... 14. Production).
* **Parent Page Routing:** Whenever the script generates a parent file (e.g., `1 Introduction.md`), it will automatically append an `"### In this Chapter"` section at the bottom containing an unordered bulleted list of links to its direct subsections (`1.1`, `1.2`, `1.3`). 

## 3. Original Page Number Handling
Interrupting the reading flow with inline `- 22 -` page numbers disrupts the modern Wiki experience. The script will sweep them completely out of the main text body and implement them invisibly.

**Selected Approach: The Bottom Meta-Callout**
As the python script reads a section and builds the file, it will quietly track any and all page numbers it passes over. At the very bottom of the generated `.md` file, it will inject a clean, collapsible Obsidian callout to hold them:

```markdown
***
> [!note]- Original Source Reference
> Content in this section was sourced from page(s) **22, 23** of the original War in Spain EBOOK.
```

**Why this works:** 
* Keeps your main text 100% pure and uninterrupted. 
* Standard web publishers render these note callouts beautifully (they often color-code and box them natively using modern Markdown flavours like GitHub/Obsidian syntax). 
* The original references are preserved perfectly out of the way for researchers or players who need the hardcore PDF correlation.

---
**Status:** Awaiting user approval to commit this logic via an updated python parser script.
