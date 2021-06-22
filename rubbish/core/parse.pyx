# cdef extern from "_parse.c":
#     enum command_type:
#         cm_simple
#         cm_connection
#     _COMMAND _parse "parse" (char* input)
from rubbish.core.command cimport CommandType

cpdef void parse(unicode input):
    # TODO
    pass
