import os.path
from typing import Set, Iterable

from prompt_toolkit.document import Document
from prompt_toolkit.history import FileHistory
from prompt_toolkit.completion import PathCompleter, Completion, CompleteEvent

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

    def get_completions(
        self, document: Document, complete_event: CompleteEvent
    ) -> Iterable[Completion]:
        found_so_far: Set[str] = set()
        text = document.text_before_cursor.split()[-1]

        if len(text) < self.min_input_len:
            return

        try:
            if self.expanduser:
                text = os.path.expanduser(text)

            dirname = os.path.dirname(text)
            if dirname:
                directories = [
                    os.path.dirname(os.path.join(p, text)) for p in self.get_paths()
                ]
            else:
                directories = self.get_paths()

            prefix = os.path.basename(text)

            filenames = []
            for directory in directories:
                if os.path.isdir(directory):
                    for filename in os.listdir(directory):
                        if filename.startswith(prefix):
                            filenames.append((directory, filename))

            filenames = sorted(filenames, key=lambda k: k[1])

            for directory, filename in filenames:
                completion = filename[len(prefix) :]
                full_name = os.path.join(directory, filename)

                if os.path.isdir(full_name):
                    filename += "/"
                elif self.only_directories:
                    continue

                if not self.file_filter(full_name):
                    continue

                completion = Completion(completion, 0, display=filename)
                text_if_applied = (
                    document.text[:document.cursor_position + completion.start_position]
                    + completion.text
                    + document.text[document.cursor_position:]
                )
                if text_if_applied == document.text:
                    continue

                if text_if_applied in found_so_far:
                    continue

                found_so_far.add(text_if_applied)
                yield completion
        except OSError:
            pass
