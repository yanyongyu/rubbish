import os.path

cdef class Config:

    def __cinit__(self, unicode init_file = "", unicode history_file = "", bint use_ansi = True, **args):
        init_file_bytes = init_file.encode("utf-8")
        self._init_file = init_file_bytes

        history_file_bytes = history_file.encode("utf-8")
        self._history_file = history_file_bytes

        self._use_ansi = use_ansi

    @property
    def init_file(self):
        return (
            self._init_file.decode("utf-8") or os.path.expanduser("~/.rubbishrc")
        )

    @init_file.setter
    def init_file(self, value):
        value_bytes = value.encode("utf-8") if value else b""
        self._init_file = value_bytes

    @property
    def history_file(self):
        return (
            self._history_file.encode("utf-8") or os.path.expanduser("~/.rubbish_history")
        )

    @history_file.setter
    def history_file(self, value):
        value_bytes = value.encode("utf-8") if value else b""
        self._history_file = value_bytes

    @property
    def use_ansi(self):
        return self._use_ansi

    @use_ansi.setter
    def use_ansi(self, value):
        self._use_ansi = value


cpdef void set_config(Config config):
    global global_config
    global_config = config


cpdef Config get_config():
    return global_config

cdef Config global_config = Config()
