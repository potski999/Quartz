import os
import re
import subprocess
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()
client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))
STORE_NAME = 'fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27'

def strip_image_links(content):
    content = re.sub(r'!\[.*?\]\(.*?\)', '', content)
    content = re.sub(r'\[\[.*?\.(png|jpg|jpeg|gif|webp)(\|[\d]+)?\]\]', '', content, flags=re.I)
    return content

result = subprocess.run(
    ['git', 'diff', '--name-status', 'HEAD', '--', 'content/'],
    capture_output=True, text=True, cwd=os.path.dirname(__file__) + '/..'
)

print("Git changed files:")
print(result.stdout)

changed_files = []
for line in result.stdout.strip().split('\n'):
    if not line:
        continue
    status, filepath = line.split('\t')
    if filepath.endswith('.md'):
        changed_files.append((status, filepath))

print(f"\n{len(changed_files)} changed .md files to upload:")

for status, filepath in changed_files:
    print(f"  {status}: {filepath}")
    
    full_path = os.path.join(os.path.dirname(__file__), '..', filepath)
    
    if not os.path.exists(full_path):
        print(f"    File not found, skipping")
        continue
    
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'ai_search: false' in content[:200].lower():
        print(f"    Skipping (ai_search: false)")
        continue
    
    title = os.path.basename(filepath)[:-3]
    content = strip_image_links(content)
    content = re.sub(r'^---\s*[\s\S]*?---\s*', '', content).strip()
    
    temp_file = f"scripts/temp_upload_{title[:20]}.txt"
    with open(temp_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    try:
        result = client.file_search_stores.upload_to_file_search_store(
            file=temp_file,
            file_search_store_name=STORE_NAME,
            config=types.UploadToFileSearchStoreConfig(display_name=title)
        )
        print(f"    Uploaded: {result.response.document_name}")
    except Exception as e:
        print(f"    Error: {e}")
    
    os.remove(temp_file)

print(f"\nDone. Uploaded {len(changed_files)} changed documents.")