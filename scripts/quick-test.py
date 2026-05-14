import os
from google import genai
from google.genai import types
from dotenv import load_dotenv
load_dotenv()

client = genai.Client(api_key=os.getenv('GOOGLE_AI_API_KEY'))
STORE_NAME = 'fileSearchStores/wis-wiki-knowledge-base-bmdldaysrw27'

SYSTEM_INSTRUCTION = """You are a helpful assistant answering questions about the War in Spain 1936-39 game manual. 
IMPORTANT: Only use the provided File Search store to answer questions. 
If no relevant information is found in the store, respond with "I don't have information about that in the game manual."
Do NOT use general knowledge or make up answers. Always base your response on the documents in the store."""

queries = [
    'What is the detection level in the game?',
    'How many ports are in the map?',
    'How do you set up a PBEM game?'
]

for q in queries:
    print(f'\n=== Query: {q} ===')
    response = client.models.generate_content(
        model='gemini-2.0-flash',
        contents=q,
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM_INSTRUCTION,
            tools=[types.Tool(file_search=types.FileSearch(file_search_store_names=[STORE_NAME]))]
        )
    )
    print(response.text[:500])