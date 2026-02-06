import os
import requests
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    # Fallback to hardcoded key if env fails (temporary debug)
    # Ideally should rely on .env, but let's be safe for this diagnostics script
    api_key = "<GROQ_API_KEY_REDACTED>"

url = "https://api.groq.com/openai/v1/models"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

try:
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        models = response.json()['data']
        print("✅ Active Groq Models:")
        for model in models:
            if 'vision' in model['id']:
                print(f"👁️  VISION: {model['id']}")
            else:
                print(f"🔹 {model['id']}")
    else:
        print(f"❌ Error: {response.status_code} - {response.text}")
except Exception as e:
    print(f"❌ Exception: {e}")
