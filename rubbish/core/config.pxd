cdef Config global_config

cdef class Config:
    cdef bint _use_ansi
    cdef bint _interactive

cpdef void set_config(Config config)
cpdef Config get_config()
