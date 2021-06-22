from rubbish.core.color_control cimport Fore

cdef extern from "_prompt.h":
    const char* _get_username "get_username" ()
    const char* _get_hostname "get_hostname" ()
    const char* _get_cwd "get_cwd" ()
    const char* _get_promptchar "get_promptchar" ()


cpdef unicode get_username():
    return _get_username().decode("utf-8")


cpdef unicode get_hostname():
    return _get_hostname().decode("utf-8")


cpdef unicode get_cwd():
    return _get_cwd().decode("utf-8")


cpdef unicode get_promptchar():
    return _get_promptchar().decode("utf-8")


cpdef unicode get_prompt():
    cdef unicode username = get_username()
    cdef unicode hostname = get_hostname()
    cdef unicode cwd = get_cwd()
    cdef unicode promptchar = get_promptchar()
    cdef unicode prompt = "["
    prompt += Fore.RED + username + Fore.RESET
    prompt += "@"
    prompt += Fore.GREEN + hostname + Fore.RESET
    prompt += "]:"
    prompt += Fore.CYAN + cwd + Fore.RESET
    prompt += promptchar
    return prompt
