from colorama import Fore, Back

cdef extern from "_prompt.h":
    const char* _get_username "get_username" ()
    const char* _get_hostname "get_hostname" ()
    const char* _get_cwd "get_cwd" ()
    const char* _get_promptchar "get_promptchar" ()


cpdef unicode get_prompt():
    cdef unicode username = _get_username().decode("utf-8")
    cdef unicode hostname = _get_hostname().decode("utf-8")
    cdef unicode cwd = _get_cwd().decode("utf-8")
    cdef unicode promptchar = _get_promptchar().decode("utf-8")
    cdef unicode prompt = "["
    prompt += Fore.RED + username + Fore.RESET
    prompt += "@"
    prompt += Fore.GREEN + hostname + Fore.RESET
    prompt += "]:"
    prompt += Fore.CYAN + cwd + Fore.RESET
    prompt += promptchar
    return prompt
