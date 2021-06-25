cdef class Config:

    def __cinit__(self, bint interactive = False, bint use_ansi = True):
        self._interactive = interactive
        self._use_ansi = use_ansi

    @property
    def interactive(self):
        return self._interactive

    @interactive.setter
    def interactive(self, value):
        self._interactive = value

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
