from utils.constants import GENERIC_SYSTEM_PROMPT
from typing import List
from models import SingleConversation


system_prompt = GENERIC_SYSTEM_PROMPT + """
Now you are provided with a whole conversation history between a user and a bot. 
You need to provide a short crisp and actionable summary of the conversation.
This summary will be used to provide a quick overview of the conversation to the user.
Try to keep the summary within 500 characters.

Use bullet points to break down the summary into smaller parts.
"""

def get_summary_messages(data: List[SingleConversation]):
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