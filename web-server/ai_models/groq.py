import requests
from utils.constants import GROQ_CHAT_COMPLETION_URL, GROQ_CHAT_COMPLETION_API_KEY

def get_groq_chat_completion(messages):
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {GROQ_CHAT_COMPLETION_API_KEY}"
    }
    data = {
        "messages": messages,
        "max_tokens": 1024,
        "model": "llama3-70b-8192",
        "temperature": 0.5,
    }
    response = requests.post(GROQ_CHAT_COMPLETION_URL, json=data, headers=headers)
    if response.status_code != 200:
        return {
            "status": "error",
            "message": "Failed to get response from GROQ"
        }
    
    response_data = response.json()
    output = response_data["choices"][0]["message"]["content"]
    return {
        "status": "success",
        "output": output
    }
