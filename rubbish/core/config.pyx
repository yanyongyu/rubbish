cdef class Config:
    cdef bint _use_ansi

    def __cinit__(self, bint use_ansi = True):
        self._use_ansi = use_ansi

    @property
    def use_ansi(self):
        return self._use_ansi

    @use_ansi.setter
    def use_ansi(self, value):
        self._use_ansi = value
