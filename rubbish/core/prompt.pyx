from colorama import Fore, Back

cdef extern from "_prompt.h":
    const char* _get_prompt "get_prompt" ()


cpdef bytes get_prompt():
    cdef const char* c_prompt = _get_prompt()
    cdef bytes prompt = b""
    prompt += c_prompt
    return prompt
