from utils.constants import GENERIC_SYSTEM_PROMPT
from typing import List
from models import SingleConversation


system_prompt = GENERIC_SYSTEM_PROMPT + """
Now you are provided with a conversation history between a user and a bot. User has started descirbing their issue. This may also includes user's responses to some of the bot's questions.
You need to ask a probing question to get more information about the user's problem.
Keep your question crisp and ask for specific details.
Also try to keep your question within 100-200 characters.
"""

def get_return_question_messages(data: List[SingleConversation]):
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