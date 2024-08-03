import fastapi
from pydantic import BaseModel
from typing import List, Dict

app = fastapi.FastAPI()

class SingleConversation(BaseModel):
    user_message: str
    bot_message: str

class FunctionRequest(BaseModel):
    data: List[SingleConversation]


@app.get("/health")
def health():
    return {"status": "oks"}


@app.post("/chat")
def decode(request: FunctionRequest):
    response = "dummy response"
    return response


@app.post("/summary")
def decode(request: FunctionRequest):
    response = "dummy response"
    return response

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
