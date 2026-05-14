import os
from google import genai
from dotenv import load_dotenv
load_dotenv()

client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))

# Get store
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

# Group by display name, keep only latest (by name - last in alphabetical is latest)
names = {}
for d in docs:
    name = d.display_name
    if name not in names:
        names[name] = []
    names[name].append(d.name)

duplicates = {k: v for k, v in names.items() if len(v) > 1}

print(f"Documents with duplicates: {len(duplicates)}")

# Delete all but the last one (sorted alphabetically, last has newest ID)
total_to_delete = 0
for name, doc_names in duplicates.items():
    # Sort and keep the last (newest)
    doc_names_sorted = sorted(doc_names)
    to_delete = doc_names_sorted[:-1]  # All but last
    
    print(f"Keeping: {doc_names_sorted[-1]}")
    for d in to_delete:
        print(f"  Deleting: {d}")
        try:
            client.file_search_stores.documents.delete(name=d)
            total_to_delete += 1
        except Exception as e:
            print(f"    Error: {e}")

print(f"\nTotal deleted: {total_to_delete}")