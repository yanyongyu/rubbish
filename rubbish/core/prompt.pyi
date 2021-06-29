from prompt_toolkit.history import FileHistory
from prompt_toolkit.completion import PathCompleter

def get_username() -> str: ...
def get_hostname() -> str: ...
def get_cwd() -> str: ...
def get_promptchar() -> str: ...
def get_prompt() -> str: ...

class History(FileHistory): ...
class Completer(PathCompleter): ...
