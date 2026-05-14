"""
File Search Store Manager
Compares content/ with File Search Store and provides diagnostic/mgmt options.
"""

import os
import re
import glob
from google import genai
from google.genai import types
from dotenv import load_dotenv
import argparse

load_dotenv()
client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))
STORE_NAME = 'fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27'

def strip_image_links(content):
    content = re.sub(r'!\[.*?\]\(.*?\)', '', content)
    content = re.sub(r'\[\[.*?\.(png|jpg|jpeg|gif|webp)(\|[\d]+)?\]\]', '', content, flags=re.I)
    return content

def get_content_files(content_path):
    """Get all .md files from content/"""
    files = {}
    for root, dirs, filenames in os.walk(content_path):
        for fn in filenames:
            if fn.endswith('.md'):
                full_path = os.path.join(root, fn)
                title = fn[:-3]
                
                try:
                    with open(full_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    if 'ai_search: false' in content[:200].lower():
                        continue
                    
                    content = strip_image_links(content)
                    content = re.sub(r'^---\s*[\s\S]*?---\s*', '', content).strip()
                    files[title] = {'path': full_path, 'content': content}
                except Exception as e:
                    print(f"Error reading {full_path}: {e}")
    return files

def get_store_docs():
    """Get all documents from File Search Store"""
    docs = list(client.file_search_stores.documents.list(parent=STORE_NAME))
    
    grouped = {}
    for d in docs:
        if d.display_name not in grouped:
            grouped[d.display_name] = []
        grouped[d.display_name].append(d)
    
    return grouped

def analyze():
    """Analyze store vs content"""
    content_path = os.path.join(os.path.dirname(__file__), '..', 'content')
    content_files = get_content_files(content_path)
    store_docs = get_store_docs()
    
    content_titles = set(content_files.keys())
    store_titles = set(store_docs.keys())
    
    in_content_not_store = content_titles - store_titles
    in_store_not_content = store_titles - content_titles
    in_both = content_titles & store_titles
    
    print("=" * 60)
    print("FILE SEARCH STORE ANALYSIS")
    print("=" * 60)
    print(f"Content files (ai_search:true): {len(content_titles)}")
    print(f"Store documents (unique names):  {len(store_titles)}")
    print(f"Total in store (including dupes): {sum(len(v) for v in store_docs.values())}")
    print()
    
    print(f"In content, NOT in store ({len(in_content_not_store)}):")
    for t in sorted(in_content_not_store):
        print(f"  - {t}")
    print()
    
    print(f"In store, NOT in content ({len(in_store_not_content)}):")
    for t in sorted(in_store_not_content):
        print(f"  - {t} ({len(store_docs[t])} versions)")
    print()
    
    print(f"In both ({len(in_both)}):")
    for t in sorted(in_both):
        versions = len(store_docs[t])
        if versions > 1:
            print(f"  - {t} ({versions} versions - DUPLICATES!)")
        else:
            print(f"  - {t} (OK)")
    
    duplicates = {t: len(docs) for t, docs in store_docs.items() if len(docs) > 1}
    print()
    print(f"TOTAL DUPLICATES: {len(duplicates)} documents with multiple versions")
    print(f"Total wasted slots: {sum(v-1 for v in duplicates.values())}")
    
    return {
        'content_titles': content_titles,
        'store_titles': store_titles,
        'store_docs': store_docs,
        'in_content_not_store': in_content_not_store,
        'duplicates': duplicates
    }

def upload_missing(dry_run=False):
    """Upload files that are in content but not in store"""
    content_path = os.path.join(os.path.dirname(__file__), '..', 'content')
    content_files = get_content_files(content_path)
    store_docs = get_store_docs()
    
    missing = set(content_files.keys()) - set(store_docs.keys())
    print(f"{'[DRY RUN] ' if dry_run else ''}Found {len(missing)} missing files to upload")
    
    if dry_run:
        for title in sorted(missing):
            print(f"  Would upload: {title}")
        return
    
    total = len(missing)
    for i, title in enumerate(sorted(missing), 1):
        print(f"[{i}/{total}] Uploading: {title}...", end=" ", flush=True)
        content = content_files[title]['content']
        temp_file = f"scripts/temp_{title[:30]}.txt"
        with open(temp_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        try:
            result = client.file_search_stores.upload_to_file_search_store(
                file=temp_file,
                file_search_store_name=STORE_NAME,
                config=types.UploadToFileSearchStoreConfig(display_name=title)
            )
            print("OK")
        except Exception as e:
            print(f"FAILED: {e}")
        
        os.remove(temp_file)
    
    print(f"Done. Uploaded {total} files.")

def verify():
    """Verify store integrity"""
    store_docs = get_store_docs()
    
    print("Verifying store documents...")
    issues = []
    
    for title, docs in store_docs.items():
        if len(docs) > 1:
            issues.append(f"{title}: {len(docs)} versions (DUPLICATE)")
    
    if issues:
        print(f"ISSUES FOUND: {len(issues)}")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("No issues found. Store is clean.")
    
    return len(issues) == 0

def stats():
    """Show store statistics"""
    store_docs = get_store_docs()
    
    print("=" * 60)
    print("STORE STATISTICS")
    print("=" * 60)
    print(f"Total documents: {sum(len(v) for v in store_docs.values())}")
    print(f"Unique names: {len(store_docs)}")
    
    version_counts = {}
    for docs in store_docs.values():
        v = len(docs)
        version_counts[v] = version_counts.get(v, 0) + 1
    
    print("\nVersion distribution:")
    for v, count in sorted(version_counts.items()):
        print(f"  {v} version(s): {count} documents")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Manage File Search Store')
    parser.add_argument('command', choices=['analyze', 'upload-missing', 'verify', 'stats'],
                       help='Command to run')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without actually doing it')
    
    args = parser.parse_args()
    
    if args.command == 'analyze':
        analyze()
    elif args.command == 'upload-missing':
        upload_missing(dry_run=args.dry_run)
    elif args.command == 'verify':
        verify()
    elif args.command == 'stats':
        stats()