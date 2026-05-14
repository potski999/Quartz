import os
from google import genai
from dotenv import load_dotenv
load_dotenv()

client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))

# Get the store
stores = list(client.file_search_stores.list())
for s in stores:
    if 'WIS Wiki' in s.display_name:
        print(f"Store: {s.name}")
        # List documents
        docs = list(client.file_search_stores.documents.list(parent=s.name))
        print(f"Documents in store: {len(docs)}")
        for d in docs[:5]:
            print(f"  - {d.display_name}")
        break