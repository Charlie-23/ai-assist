import fastapi
from prompts import get_guidance_messages, get_follow_up_messages, get_return_question_messages, get_summary_messages
from ai_models import get_groq_chat_completion
from models import FunctionRequest
from state import get_state

app = fastapi.FastAPI()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/chat")
def decode(request: FunctionRequest):
    state = get_state(request)
    if state == "guidance":
        messages = get_guidance_messages(request.data)
    elif state == "follow_up":
        messages = get_follow_up_messages(request.data)
    elif state == "return_question":
        messages = get_return_question_messages(request.data)
    
    result = get_groq_chat_completion(messages)

    # log the request and response
    print("\ndata:", request.data)
    print("\nprev_state:", request.prev_state)
    print("\nstate:", state)
    print("\nresult:", result)
    
    if result["status"] == "error":
        return {
            "output": "Failed to get response from GROQ",
            "state": "error"
        }

    result["state"] = state
    return result


@app.post("/summary")
def decode(request: FunctionRequest):
    messages = get_summary_messages(request.data)
    result = get_groq_chat_completion(messages)
    if result["status"] == "error":
        return {
            "output": "Failed to get response from GROQ",
            "state": "error"
        }
    
    return result

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
