from models import FunctionRequest
from prompts import get_chat_state_messages
from ai_models import get_groq_chat_completion

def get_state(request: FunctionRequest):
    data = request.data
    if request.prev_state == None or request.prev_state == "":
        if len(data) < 4:
            return "return_question"
        else:
            return "follow_up"
    if request.prev_state == "return_question":
        if len(data) < 4:
            if is_indicating_skip_to_guidance(data):
                return "guidance"
            else:
                return "return_question"
        else:
            if is_indicating_ask_return_question(data):
                return "return_question"
            else:
                return "guidance"
    elif request.prev_state == "guidance":
        return "follow_up"
    elif request.prev_state == "follow_up":
        return "follow_up"
    elif request.prev_state == "return_question":
        return "return_question"

    return "guidance"



def is_indicating_skip_to_guidance(data):
    messages = get_chat_state_messages(data)
    response = get_groq_chat_completion(messages)
    print(response)
    if response["status"] == "error":
        return False
    
    if response["output"].lower().strip() == "guidance":
        return True
    return False


def is_indicating_ask_return_question(data):
    messages = get_chat_state_messages(data)
    response = get_groq_chat_completion(messages)
    print(response)
    if response["status"] == "error":
        return False
    
    if response["output"].lower().strip() == "return_question":
        return True
    return False


