import os
from google import genai
from dotenv import load_dotenv
load_dotenv()

client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))

# Get all documents and check for duplicates
stores = list(client.file_search_stores.list())
store = None
for s in stores:
    if 'WIS Wiki' in s.display_name:
        store = s
        break

if not store:
    print("Store not found!")
    exit()

docs = list(client.file_search_stores.documents.list(parent=store.name))
print(f"Total documents: {len(docs)}")

# Find duplicates by display_name
names = {}
for d in docs:
    name = d.display_name
    if name not in names:
        names[name] = []
    names[name].append(d.name)

duplicates = {k: v for k, v in names.items() if len(v) > 1}

print(f"\nDuplicate documents:")
for name, doc_names in duplicates.items():
    print(f"  '{name}': {len(doc_names)} copies")
    for n in doc_names:
        print(f"    - {n}")

# For now, let's just show unique count
unique_names = set(d.display_name for d in docs)
print(f"\nUnique document names: {len(unique_names)}")