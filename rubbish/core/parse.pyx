from libc.stdio cimport FILE
from libc.stdlib cimport malloc

from rubbish.core.command cimport COMMAND, Command


cdef extern from "lexial.yy.c":
    void yyset_in (FILE * input)
    int yylex ()

cdef extern from "grammar.tab.c":
    int yyparse ()


cpdef Command parse(unicode input):
    cdef COMMAND *c_command = <COMMAND *>malloc(sizeof(COMMAND))
    return Command.from_ptr(c_command)
