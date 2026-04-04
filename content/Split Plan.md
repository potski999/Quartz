# Markdown Manual Split Methodology

Based on your requirements and the structure of the master document, here is the detailed technical plan for parsing, cleaning, and splitting the `War in Spain manual EBOOK.md` file using a Python script.

## Phase 1: Data Ingestion & Sanitization
1. **Load Master File:** Read the entire file line by line.
2. **Form Feed Removal:** The PDF extractor left invisible form-feed characters (e.g., `\x0c` or ``) throughout the text, often right before page numbers. These will be stripped out.
3. **Bullet Point Conversion:** Search for the strange `§` character. Replace it with a standard markdown bullet `- `. 

## Phase 2: Paragraph Merging
The PDF extraction chopped single paragraphs into multiple lines with hard line breaks. We will iterate through the lines and merge them:
1. **Identify Breaks:** Empty lines, section headers, and page numbers (e.g., `- 22 -` or `– 22 –`) act as natural breaks.
2. **Merge Consecutive Lines:** We will collect consecutive lines of regular text and join them together with a single space. 
   * *Example:* If lines 1, 2, and 3 are text without blank lines between them, they become one single flowing paragraph. This restores the proper flow and allows Obsidian to wrap the text dynamically based on the window size.
   * *Bullet points* (starting with our new `-`) will also be correctly merged if the bullet text spans multiple lines.

## Phase 3: Section Identification & Markdown Enhancement
As we process the consolidated paragraphs, we will identify headings:
1. **Heading Regex Matching:** Look for text matching the pattern `Number. Text` up to 3 decimals deep, for example:
   * **Level 1:** `1. Introduction`
   * **Level 2:** `1.1 New Game Engine`
   * **Level 3:** `1.3.1 User Created Scenarios`
2. **Markdown Heading Injection:** By default, your document doesn't have the `#` hashes for Markdown headings. The script will inject the correct number of `#` based on the section depth (e.g., `# 1. Introduction` and `### 1.3.1 User Created Scenarios`) so that they properly appear in your Obsidian outliner and formatting.

## Phase 4: Splitting & File Generation 
1. **Skip the Table of Contents:** The parser will ignore the massive Table of Contents at the start and will formally begin file generation when it encounters the first real major heading in the text body (`1. Introduction`).
2. **File Handoff:**
   * When a recognized heading (up to 3 levels deep) is found, the script closes the currently open file.
   * It creates a new file using the section heading as the filename, cleaning any characters that Windows forbids (like `:`, `?`, etc.).
   * The actual heading text is written as the very first line.
   * All subsequent paragraphs, tables, and page numbers are written to this file until the next valid heading is triggered.
3. **Overwrite Capability:** Existing files (except your master document) sharing the newly generated names will be overwritten automatically to reflect the newly merged and cleaned paragraphs. Your master `War in Spain manual EBOOK.md` will NEVER be modified.

---
### Next Steps
If you are satisfied with this plan, I will write the Python script right into your Vault and execute it.
