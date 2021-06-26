cdef class Config:

    def __cinit__(self, unicode file = "", bint use_ansi = True):
        file_bytes = file.encode("utf-8")
        self._file = file_bytes
        self._use_ansi = use_ansi

    @property
    def file(self):
        return self._file.decode("utf-8") or None

    @file.setter
    def file(self, value):
        value_bytes = value.encode("utf-8") if value else b""
        self._file = value_bytes

    @property
    def interactive(self):
        return not bool(self._file)

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
