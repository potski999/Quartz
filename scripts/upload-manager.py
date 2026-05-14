"""
File Search Store Upload Manager
Reliable delete-before-upload pattern with correct metadata.

Modes:
  python upload-manager.py <filepath>         — Single file
  python upload-manager.py --git-diff          — Files changed since HEAD
  python upload-manager.py --reindex           — Delete all, upload all

Metadata schema:
  - url:      Full absolute URL (e.g. https://wis-wiki-manual.web.app/8-Ground-Units/...)
  - source:   Source type from frontmatter (e.g. "WIS Manual")

Rate limit: 2s delay between operations (free tier: ~5 req/min)
"""
import os, re, sys, time, json, requests
from google import genai
from google.genai import types
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()
client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))
API_KEY = os.getenv('GOOGLE_AI_API_KEY')
STORE_NAME = 'fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27'
BASE_URL = 'https://wis-wiki-manual.web.app'
VAULT_ROOT = Path('C:\\Users\\potsk\\Documents\\Obsidian\\Vault\\WIS Manual')
SCRIPT_DIR = Path(__file__).parent
RATE_LIMIT_DELAY = 3  # seconds between operations

# ── Helpers ────────────────────────────────────────────────

def sluggify(segment):
    """Match Quartz sluggify exactly."""
    return (segment
        .replace(' ', '-')
        .replace('&', '-and-')
        .replace('%', '-percent')
        .replace('?', '')
        .replace('#', ''))

def slugify_filepath(rel_path):
    """Convert relative vault path to Quartz slug."""
    rel = rel_path.replace('\\', '/')
    if rel.endswith('.md'):
        rel = rel[:-3]
    parts = rel.split('/')
    slugged = '/'.join(sluggify(p) for p in parts)
    if slugged.endswith('_index'):
        slugged = slugged[:-6] + 'index'
    if slugged == 'index':
        slugged = ''
    return slugged

def file_to_url(rel_path):
    """Convert vault-relative path to absolute URL."""
    slug = slugify_filepath(rel_path)
    return f'{BASE_URL}/{slug}' if slug else BASE_URL

def parse_frontmatter(content):
    """Extract frontmatter fields and body."""
    fm = {}
    rest = content
    m = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if m:
        for line in m.group(1).split('\n'):
            kv = re.match(r'(\w[\w_-]*)\s*:\s*(.+)', line)
            if kv:
                fm[kv.group(1)] = kv.group(2).strip()
        rest = content[m.end():]
    return fm, rest.strip()

def strip_image_links(content):
    content = re.sub(r'!\[.*?\]\(.*?\)', '', content)
    content = re.sub(r'\[\[.*?\.(png|jpg|jpeg|gif|webp)(\|[\d]+)?\]\]', '', content, flags=re.I)
    return content

def get_content_files():
    """Get all .md files from vault with metadata."""
    files = []
    for root, dirs, fns in os.walk(str(VAULT_ROOT)):
        for fn in fns:
            if not fn.endswith('.md'):
                continue
            full_path = Path(root) / fn
            try:
                with open(full_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            except:
                continue

            fm, body = parse_frontmatter(content)
            if fm.get('ai_search', '').lower() == 'false':
                continue

            # Relative path from vault root
            rel_path = str(full_path.relative_to(VAULT_ROOT))

            # Source from frontmatter type
            src_type = fm.get('type', 'WIS Manual').replace('_', ' ')

            # Body: strip frontmatter + image links
            clean = strip_image_links(body)

            files.append({
                'rel_path': rel_path,
                'display_name': fn[:-3],
                'url': file_to_url(rel_path),
                'source': src_type,
                'content': clean,
            })
    return files

def get_store_docs_by_name():
    """Map display_name → list of doc objects."""
    docs = list(client.file_search_stores.documents.list(parent=STORE_NAME))
    by_name = {}
    for d in docs:
        by_name.setdefault(d.display_name, []).append(d)
    return by_name

def sanitize_filename(name):
    """Strip non-ASCII chars from filename for Windows cp1252 safety."""
    return ''.join(c if ord(c) < 128 else '_' for c in name)

def upload_file(file_info):
    """Upload single file with metadata. Returns (new_doc_name, success)."""
    safe_name = sanitize_filename(file_info["display_name"])[:30]
    temp_file = SCRIPT_DIR / f'temp_upload_{safe_name}.txt'
    try:
        with open(temp_file, 'w', encoding='utf-8') as f:
            f.write(file_info['content'])

        op = client.file_search_stores.upload_to_file_search_store(
            file=str(temp_file),
            file_search_store_name=STORE_NAME,
            config=types.UploadToFileSearchStoreConfig(
                display_name=file_info['display_name'],
                custom_metadata=[
                    {"key": "url", "string_value": file_info['url']},
                    {"key": "source", "string_value": file_info['source']},
                ]
            )
        )
        new_name = op.response.document_name
        print(f'  OK Uploaded: {new_name}')
        return new_name, True
    except Exception as e:
        print(f'  FAIL Upload FAILED: {e}')
        return None, False
    finally:
        if temp_file.exists():
            temp_file.unlink()

def delete_doc(doc_name):
    """Delete a document with force=true via REST API."""
    url = f'https://generativelanguage.googleapis.com/v1beta/{doc_name}?force=true&key={API_KEY}'
    resp = requests.delete(url)
    if resp.status_code == 200:
        print(f'  OK Deleted: {doc_name}')
        return True
    else:
        print(f'  FAIL Delete FAILED ({resp.status_code}): {resp.text}')
        return False

def process_file(file_info, store_by_name, dry_run=False):
    """Upload (and delete old) for one file."""
    display = file_info['display_name']
    print(f'\n[{display}]')

    old_docs = store_by_name.get(display, [])

    if dry_run:
        print(f'  URL: {file_info["url"]}')
        print(f'  Source: {file_info["source"]}')
        print(f'  Existing copies: {len(old_docs)}')
        if old_docs:
            print(f'  Would delete: {old_docs[0].name}')
        return True

    # Upload
    new_name, ok = upload_file(file_info)
    if not ok:
        return False

    time.sleep(RATE_LIMIT_DELAY)

    # Delete old
    if old_docs:
        for old in old_docs:
            if old.name != new_name:
                delete_doc(old.name)
                time.sleep(RATE_LIMIT_DELAY)
    return True

# ── Modes ──────────────────────────────────────────────────

def mode_single_file(filepath):
    """Upload a single file by vault-relative path."""
    full_path = VAULT_ROOT / filepath
    if not full_path.exists():
        print(f'File not found: {full_path}')
        return

    with open(full_path, encoding='utf-8') as f:
        content = f.read()
    fm, body = parse_frontmatter(content)
    if fm.get('ai_search', '').lower() == 'false':
        print('Skipping: ai_search = false')
        return

    rel_path = str(full_path.relative_to(VAULT_ROOT))
    file_info = {
        'rel_path': rel_path,
        'display_name': full_path.stem,
        'url': file_to_url(rel_path),
        'source': fm.get('type', 'WIS Manual').replace('_', ' '),
        'content': strip_image_links(body),
    }
    store_by_name = get_store_docs_by_name()
    process_file(file_info, store_by_name)

def mode_git_diff():
    """Upload files changed since HEAD."""
    result = subprocess.run(
        ['git', 'diff', '--name-status', 'HEAD', '--', 'content/'],
        capture_output=True, text=True, cwd=SCRIPT_DIR.parent
    )
    all_files = {f['rel_path']: f for f in get_content_files()}
    changed = []
    for line in result.stdout.strip().split('\n'):
        if not line.strip():
            continue
        parts = line.split('\t')
        if len(parts) < 2:
            continue
        status = parts[0]
        git_path = parts[1]
        # git path is like "content/..." → vault-relative
        vault_rel = git_path.replace('content/', '', 1)
        if vault_rel in all_files:
            changed.append(all_files[vault_rel])
        elif status == 'D':
            print(f'  (deleted from git: {git_path})')

    if not changed:
        print('No changed .md files to upload.')
        return

    print(f'{len(changed)} changed files to process')
    store_by_name = get_store_docs_by_name()
    success = 0
    failures = []
    for f in changed:
        if process_file(f, store_by_name):
            success += 1
        else:
            failures.append(f['display_name'])
    print(f'\nDone. {success}/{len(changed)} files processed.')
    if failures:
        print(f'FAILED: {len(failures)} file(s) failed to upload:', file=sys.stderr)
        for name in failures:
            print(f'  - {name}', file=sys.stderr)
        sys.exit(1)

def mode_reindex():
    """Delete all docs, then upload all content files."""
    print('=== FULL RE-INDEX ===')
    print('Phase 1: Listing current documents...')
    store_by_name = get_store_docs_by_name()
    all_docs = [d for docs in store_by_name.values() for d in docs]

    # Gather files before prompting confirmation
    content_files = get_content_files()

    print(f'\nStore has {len(all_docs)} documents, will upload {len(content_files)} files.')
    confirm = input('Proceed with full re-index? (yes/no): ')
    if confirm.lower() != 'yes':
        print('Aborted.')
        return

    # Delete all
    print(f'\nPhase 2: Deleting {len(all_docs)} documents...')
    for d in all_docs:
        delete_doc(d.name)
        time.sleep(1)

    # Upload all
    print(f'\nPhase 3: Uploading all content files...')
    success = 0
    for i, f in enumerate(content_files, 1):
        print(f'[{i}/{len(content_files)}] ', end='')
        if process_file(f, {}, dry_run=False):
            success += 1
    print(f'\nDone. {success}/{len(content_files)} uploaded.')

def mode_dry_run():
    """Show what would be uploaded without doing it."""
    content_files = get_content_files()
    store_by_name = get_store_docs_by_name()
    print(f'Content files: {len(content_files)}')
    print(f'Current store docs: {sum(len(v) for v in store_by_name.values())}')
    print(f'Unique store names: {len(store_by_name)}\n')

    for f in content_files:
        process_file(f, store_by_name, dry_run=True)

# ── Entry ──────────────────────────────────────────────────

if __name__ == '__main__':
    import subprocess  # used by git-diff mode
    import argparse

    parser = argparse.ArgumentParser(description='File Search Store Upload Manager')
    parser.add_argument('file', nargs='?', help='Single file path (relative to vault root)')
    parser.add_argument('--git-diff', action='store_true', help='Upload files changed in git')
    parser.add_argument('--reindex', action='store_true', help='Delete all + re-upload all')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done')

    args = parser.parse_args()

    if args.dry_run:
        mode_dry_run()
    elif args.reindex:
        mode_reindex()
    elif args.git_diff:
        mode_git_diff()
    elif args.file:
        mode_single_file(args.file)
    else:
        parser.print_help()
