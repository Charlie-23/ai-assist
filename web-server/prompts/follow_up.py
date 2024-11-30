from utils.constants import GENERIC_SYSTEM_PROMPT
from typing import List
from models import SingleConversation


system_prompt = GENERIC_SYSTEM_PROMPT + """
Now you are provided with a conversation history between a user and a bot. User has asked a follow-up. You need to provide a response to the user's follow-up question.
Since this is a follow up try to keep your response crisp and within 200 characters.
"""

def get_follow_up_messages(data: List[SingleConversation]):
    messages = []
    messages.append({
        "role": "system",
        "content": system_prompt
    })
    for conversation in data:
        messages.append({
            "role": "assistant",
            "content": conversation.bot_message
        })
        messages.append({
            "role": "user",
            "content": conversation.user_message
        })

    return messages