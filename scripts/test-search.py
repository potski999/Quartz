import os
from google import genai
from google.genai import types
from dotenv import load_dotenv
load_dotenv()

client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))

# Store ID from earlier
STORE_NAME = "fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27"

# Test queries
queries = [
    "What is an AKL ship?",
    "How do I capture a port?",
    "What is detection level?"
]

print(f"Testing search against store: {STORE_NAME}\n")

for query in queries:
    print(f"Query: {query}")
    print("-" * 40)
    
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=query,
        config=types.GenerateContentConfig(
            tools=[types.Tool(
                file_search=types.FileSearch(
                    file_search_store_names=[STORE_NAME]
                )
            )]
        )
    )
    
    print(f"Answer: {response.text}")
    
    # Get grounding metadata for citations
    if response.candidates and response.candidates[0].grounding_metadata:
        metadata = response.candidates[0].grounding_metadata
        print(f"\nSources:")
        if hasattr(metadata, 'grounding_chunks') and metadata.grounding_chunks:
            for chunk in metadata.grounding_chunks[:3]:
                if hasattr(chunk, 'source') and chunk.source:
                    print(f"  - {chunk.source.title}")
        elif hasattr(metadata, 'sources') and metadata.sources:
            for src in metadata.sources[:3]:
                print(f"  - {src}")
    
    print("\n" + "=" * 50 + "\n")