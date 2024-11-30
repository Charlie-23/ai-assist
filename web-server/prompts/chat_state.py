from typing import List
from models import SingleConversation


system_prompt = """
You are provided with a conversation between a user and a bot.
The bot is designed to help users with their queries, like a counselor.
Based on the last message you need to decide the next state of the conversation.
The states are:
- guidance: When the user is has finished describing their issue and ready for some guidance.
- return_question: When more information is needed from the user to provide guidance.

Usually, the conversation starts with user describing their issue, then the bot asks for more information and then provides guidance.
The return question are generally 4-5 questions that the bot asks to understand the issue better.
In somecases, the user might not be interested in providing more information and the bot needs to provide guidance based on the information available.
"""

def get_chat_state_messages(data: List[SingleConversation]):
    messages = []
    global system_prompt
    system_prompt += "Currently number of messages in the conversation are: " + str(len(data)) + "\n"
    messages.append({
        "role": "system",
        "content": system_prompt
    })
    prompt = "Conversation:"
    for conversation in data:
        prompt += "\n" + "Bot: " + conversation.bot_message
        prompt += "\n" + "User: " + conversation.user_message

    prompt += "\n\n" + """Based on the last message, you need to decide the next state of the conversation.
    Reply with the state name only in lowercase. Again, the states are:
    - guidance
    - return_question 
    """
    messages.append({
        "role": "user",
        "content": prompt
    })

    return messages