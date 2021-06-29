import os.path
from prompt_toolkit.history import FileHistory
from prompt_toolkit.completion import PathCompleter

from rubbish.core.color_control cimport Fore

cdef extern from "_prompt.c":
    cdef const char* _get_username "get_username" ()
    cdef const char* _get_hostname "get_hostname" ()
    cdef const char* _get_cwd "get_cwd" ()
    cdef const char* _get_promptchar "get_promptchar" ()


cpdef unicode get_username():
    return _get_username().decode("utf-8")


cpdef unicode get_hostname():
    return _get_hostname().decode("utf-8")


cpdef unicode get_cwd():
    user_home = os.path.expanduser("~")
    cwd = _get_cwd().decode("utf-8")
    return cwd.replace(user_home, "~") if cwd.startswith(user_home) else cwd


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
    prompt += "\n" + promptchar
    return prompt


class History(FileHistory):
    pass


class Completer(PathCompleter):
    pass
