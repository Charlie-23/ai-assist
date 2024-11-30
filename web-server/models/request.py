from pydantic import BaseModel
from typing import List, Optional


class SingleConversation(BaseModel):
    user_message: str
    bot_message: str

class FunctionRequest(BaseModel):
    data: List[SingleConversation]
    prev_state: Optional[str] = None