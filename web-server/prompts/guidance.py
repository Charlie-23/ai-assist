from utils.constants import GENERIC_SYSTEM_PROMPT
from typing import List
from models import SingleConversation


system_prompt = GENERIC_SYSTEM_PROMPT + """
Now you are provided with a conversation history between a user and a bot. This also includes user's responses to some of the bot's questions.
You have a good description of the user's problem and the user's response to the bot's questions. You need to provide a response to the user's latest message as well as their problem.
This is major part of the conversation and you need to provide a detailed response to the user's problem.
Try to keep your response detailed and within 500 characters.
Try to use bullet points to break down the response into smaller parts.
This message will appear on the chat screen so try to make it as user friendly as possible.
"""

def get_guidance_messages(data: List[SingleConversation]):
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