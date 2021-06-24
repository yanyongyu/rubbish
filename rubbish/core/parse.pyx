from libc.stdlib cimport malloc
from libc.string cimport strlen
from libc.stdio cimport FILE, fwrite, fflush

from rubbish.core.command import CommandType
from rubbish.core.command cimport COMMAND, Command

cdef extern from "<stdio.h>":
    cdef FILE * open_memstream(char **, size_t *)

cdef extern from "_global.h":
    cdef int command_end
    cdef int interactive

cdef extern from "lexical.yy.c":
    cdef void yyset_in (FILE * input)
    # cdef void yyset_out (FILE * output)

cdef extern from "grammar.tab.c":
    cdef COMMAND *global_command
    cdef int yyparse ()


cdef char *input_bp
cdef size_t input_size
cdef FILE *fake_input = open_memstream(&input_bp, &input_size)
yyset_in(fake_input)

# cdef char *output_bp
# cdef size_t output_size
# cdef FILE *fake_output = open_memstream(&output_bp, &output_size)
# yyset_out(fake_output)


cpdef Command parse(unicode input):
    cdef int result
    cdef char *temp
    cdef COMMAND *c_command
    cdef Command command

    input_bytes = input.encode("utf-8")
    temp = input_bytes
    fwrite(temp, sizeof(char), strlen(temp), fake_input)

    # reset state
    command_end = 1

    result = yyparse()

    c_command = global_command

    # print(result, c_command is NULL, command_end, interactive)
    if result == 0:
        command = Command.from_ptr(c_command)
        return command
    return None
