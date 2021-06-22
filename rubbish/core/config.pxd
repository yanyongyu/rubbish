cdef Config global_config

cdef class Config:
    cdef bint _use_ansi

cpdef void set_config(Config config)
cpdef Config get_config()
