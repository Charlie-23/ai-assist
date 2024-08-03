import fastapi
from pydantic import BaseModel
from typing import List, Optional

app = fastapi.FastAPI()

class SingleConversation(BaseModel):
    user_message: str
    bot_message: str

class FunctionRequest(BaseModel):
    data: List[SingleConversation]
    prev_state: Optional[str] = None


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/chat")
def decode(request: FunctionRequest):
    response = "dummy response"
    return {
        "output": response,
        "state": "dummy state"
    }


@app.post("/summary")
def decode(request: FunctionRequest):
    response = "dummy response"
    return {
        "output": response,
        "state": "dummy state"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
