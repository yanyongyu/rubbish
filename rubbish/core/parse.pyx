from libc.stdio cimport FILE
from libc.stdlib cimport malloc

from rubbish.core.command cimport COMMAND, Command


cdef extern from "lexial.yy.c":
    cdef void yyset_in (FILE * input)
    cdef int yylex ()

cdef extern from "grammar.tab.c":
    cdef int yyparse ()


cpdef Command parse(unicode input):
    cdef COMMAND *c_command = <COMMAND *>malloc(sizeof(COMMAND))
    return Command.from_ptr(c_command)
