import os, re
from google import genai
from google.genai import types
from dotenv import load_dotenv
load_dotenv()

client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))

STORE_NAME = "fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27"

SYSTEM_INSTRUCTION = """You are a helpful assistant answering questions about the War in Spain 1936-39 game manual. 
IMPORTANT: Only use the provided File Search store to answer questions. 
If no relevant information is found in the store, respond with "I don't have information about that in the game manual."
Do NOT use general knowledge or make up answers. Always base your response on the documents in the store."""

def fetch_doc_metadata(doc_name):
    """Fetch document metadata from the File Search Store."""
    try:
        doc = client.file_search_stores.documents.get(name=doc_name)
        meta = {m.key: m.string_value for m in doc.custom_metadata}
        return doc.display_name, meta.get('url', ''), meta.get('source', '')
    except Exception:
        return doc_name.split('/')[-1], '', ''

print("=" * 60)
print("WIS Wiki Manual - Search Testing")
print("=" * 60)
print(f"Store: {STORE_NAME}")
print("Type 'quit' to exit\n")

while True:
    query = input("Question: ").strip()
    if query.lower() == 'quit':
        break
    if not query:
        continue
    
    print("\nSearching...")
    
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=query,
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_INSTRUCTION,
            tools=[types.Tool(
                file_search=types.FileSearch(
                    file_search_store_names=[STORE_NAME]
                )
            )]
        )
    )
    
    print(f"\nAnswer:\n{response.text}")
    
    # Show structured grounding data with metadata
    if response.candidates and response.candidates[0].grounding_metadata:
        meta = response.candidates[0].grounding_metadata
        if hasattr(meta, 'grounding_chunks') and meta.grounding_chunks:
            print(f"\n--- Sources ({len(meta.grounding_chunks)} chunks) ---")
            seen_docs = set()
            for chunk in meta.grounding_chunks:
                rc = getattr(chunk, 'retrieved_context', None)
                doc_name = rc.uri if rc else ''
                if doc_name and doc_name not in seen_docs:
                    seen_docs.add(doc_name)
                    display_name, url, source = fetch_doc_metadata(doc_name)
                    print(f"  [{display_name}]")
                    if url:
                        print(f"    URL: {url}")
                    if source:
                        print(f"    Source: {source}")
        if hasattr(meta, 'web_search_grounding') and meta.web_search_grounding:
            print(f"\n  WARNING: Web search grounding was used (not file search!)")
    
    print("\n" + "=" * 60)