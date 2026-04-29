import os
import re
from collections import defaultdict

MASTER_FILE = "War in Spain manual EBOOK.md"
TARGET_DIR = "."

def clean_filename(name):
    """Remove trailing whitespace and invalid characters for Windows filenames."""
    name = name.strip()
    return re.sub(r'[<>:"/\\|?*]', '', name)

def get_depth(heading_number):
    stripped = heading_number.strip('.')
    return len(stripped.split('.'))

def get_parent(heading_number):
    """Return the parent heading number, e.g. 1.2.3 -> 1.2"""
    parts = heading_number.strip('.').split('.')
    if len(parts) > 1:
        return ".".join(parts[:-1])
    return None

def main():
    if not os.path.exists(MASTER_FILE):
        print(f"Error: {MASTER_FILE} not found.")
        return

    with open(MASTER_FILE, "r", encoding="utf-8") as f:
        lines = f.readlines()

    heading_pattern = re.compile(r'^(\d+\.|\d+\.\d+(?:\.\d+)?)\s+(.+)$')
    # Use capture group for the page number digits
    page_num_pattern = re.compile(r'^[\-–]\s*(\d+)\s*[\-–]$')
    xref_pattern = re.compile(r'(?i)\b(section|paragraph|chapter|see)\s+(\d+(?:\.\d+){0,2})\b')

    # ---------------------------------------------------------
    # PASS 1: Sweep the file to build a map of all headings
    # ---------------------------------------------------------
    def parse_headings():
        in_body = False
        toc_intro_seen = False
        current_paragraph_lines = []
        headings = {}
        for line in lines:
            cleaned = line.replace('\x0c', '').replace('§', '-').rstrip()
            if not cleaned:
                current_paragraph_lines.clear()
                continue
            if page_num_pattern.match(cleaned):
                current_paragraph_lines.clear()
                continue
            
            heading_match = heading_pattern.match(cleaned)
            if heading_match and not current_paragraph_lines:
                num_part = heading_match.group(1).rstrip('.')
                text_part = heading_match.group(2)
                
                if len(text_part) < 120 and not text_part.lower().endswith("below.") and not text_part.lower().endswith("above."):
                    current_paragraph_lines.clear()
                    
                    if not in_body and num_part == "1" and "Introduction" in text_part:
                        if not toc_intro_seen:
                            toc_intro_seen = True
                        else:
                            in_body = True
                    
                    if in_body:
                        depth = get_depth(num_part)
                        if depth <= 3:
                            headings[num_part] = clean_filename(f"{num_part} {text_part}")
                            continue

            if in_body:
                current_paragraph_lines.append(cleaned.strip())
        return headings

    heading_map = parse_headings()
    
    # Build a hierarchy tree
    tree = defaultdict(list)
    top_levels = []
    # Sort numerically (1.1 before 1.10)
    sorted_nums = sorted(heading_map.keys(), key=lambda x: [int(p) for p in x.split('.')])
    for num in sorted_nums:
        parent = get_parent(num)
        # Verify the parent actually exists, otherwise it's a top level (or orphaned)
        if parent and parent in heading_map:
            tree[parent].append(num)
        else:
            top_levels.append(num)

    # ---------------------------------------------------------
    # PASS 2: Split files, convert links, build navigations
    # ---------------------------------------------------------
    current_file_handle = None
    in_body = False
    toc_intro_seen = False
    current_paragraph_lines = []
    current_pages = set()
    current_num_part = None

    def close_current_file():
        nonlocal current_file_handle, current_num_part, current_pages
        if current_file_handle:
            # Append TOC for children if any
            if current_num_part in tree:
                current_file_handle.write("\n### In this Chapter\n")
                for child_num in tree[current_num_part]:
                    child_name = heading_map[child_num]
                    current_file_handle.write(f"* [[{child_name}]]\n")
            
            # Append Page Numbers callout
            if current_pages:
                pages_str = ", ".join(sorted(list(current_pages), key=lambda x: int(x)))
                current_file_handle.write("\n***\n")
                current_file_handle.write("> [!note]- Original Source Reference\n")
                current_file_handle.write(f"> Content in this section was sourced from page(s) **{pages_str}** of the original PDF EBOOK.\n")
            
            current_file_handle.close()
            current_file_handle = None
            current_pages.clear()

    def process_xref(text):
        def replace_fn(match):
            prefix = match.group(1)
            num = match.group(2)
            if num in heading_map:
                fname = heading_map[num]
                return f"[[{fname}|{prefix} {num}]]"
            return match.group(0)
        return xref_pattern.sub(replace_fn, text)

    def flush_paragraph():
        if not current_paragraph_lines:
            return
        text = " ".join(current_paragraph_lines)
        text = process_xref(text) # convert links
        if current_file_handle:
            current_file_handle.write(text + "\n\n")
        current_paragraph_lines.clear()

    for line in lines:
        cleaned = line.replace('\x0c', '').replace('§', '-').rstrip()
        
        if not cleaned:
            flush_paragraph()
            continue

        page_match = page_num_pattern.match(cleaned)
        if page_match:
            flush_paragraph()
            page_val = page_match.group(1)
            current_pages.add(page_val)
            continue

        heading_match = heading_pattern.match(cleaned)
        if heading_match and not current_paragraph_lines:
            num_part = heading_match.group(1).rstrip('.')
            text_part = heading_match.group(2)
            
            if len(text_part) < 120 and not text_part.lower().endswith("below.") and not text_part.lower().endswith("above."):
                flush_paragraph()
                
                if not in_body and num_part == "1" and "Introduction" in text_part:
                    if not toc_intro_seen:
                        toc_intro_seen = True
                    else:
                        in_body = True
                
                if in_body:
                    depth = get_depth(num_part)
                    if depth <= 3:
                        close_current_file()
                        
                        current_num_part = num_part
                        filename = heading_map[num_part] + ".md"
                        filepath = os.path.join(TARGET_DIR, filename)
                        current_file_handle = open(filepath, "w", encoding="utf-8")
                        
                        hashes = "#" * depth
                        current_file_handle.write(f"{hashes} {num_part} {text_part}\n\n")
                        continue

        if in_body:
            current_paragraph_lines.append(cleaned.strip())

    flush_paragraph()
    close_current_file()

    # 3. Generate the 00 Home.md Master Index
    home_path = os.path.join(TARGET_DIR, "00 Home.md")
    with open(home_path, "w", encoding="utf-8") as f:
        f.write("# War in Spain 1936-39 Manual\n\n")
        for num in top_levels:
            f.write(f"## [[{heading_map[num]}]]\n")

    print("Phase 2 splitting complete.")

if __name__ == "__main__":
    main()
