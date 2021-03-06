from libc.stdlib cimport malloc
from libc.string cimport strlen
from libc.stdio cimport FILE, fwrite, fflush

from rubbish.core.command import CommandType
from rubbish.core.config cimport global_config
from rubbish.core.command cimport COMMAND, Command

cdef extern from "<stdio.h>":
    cdef FILE * open_memstream(char **, size_t *)

cdef extern from "lexical.yy.c":
    # cdef int yylex ()
    cdef void yyset_in (FILE * input)
    # cdef void yyset_out (FILE * output)

cdef extern from "grammar.tab.c":
    cdef int command_end
    cdef int eof_encountered
    cdef int _is_interactive "is_interactive"
    cdef int yyparse ()
    cdef COMMAND *global_command


cdef char *input_bp
cdef size_t input_size
cdef FILE *fake_input = open_memstream(&input_bp, &input_size)
yyset_in(fake_input)

# cdef char *output_bp
# cdef size_t output_size
# cdef FILE *fake_output = open_memstream(&output_bp, &output_size)
# yyset_out(fake_output)


cpdef list parse(unicode input, bint interactive = True):
    cdef char *temp
    cdef int result
    cdef Command command
    cdef COMMAND *c_command

    global command_end
    global _is_interactive
    global eof_encountered

    # init parse
    result = 0
    commands = []
    command_end = 1
    eof_encountered = 0
    _is_interactive = interactive


    # ensure not ended with escaped newline
    if input.rstrip().endswith("\\"):
        if _is_interactive:
            raise MoreInputNeeded
        else:
            raise SyntaxError("Syntax error")

    # write to input buffer
    if input:
        input_bytes = input.encode("utf-8")
        temp = input_bytes
        fwrite(temp, sizeof(char), strlen(temp), fake_input)
    else:
        return commands

    # parse result
    while result == 0 and eof_encountered == 0:

        result = yyparse()

        c_command = global_command

        # parsed single command
        if result == 0 and c_command is not NULL:
            command = Command.from_ptr(c_command)
            commands.append(command)
            continue
        # single line input continue in interactive mode
        elif command_end == 0:
            raise MoreInputNeeded
        # input get nothing but valid
        elif result == 0:
            continue

        fflush(fake_input)
        raise SyntaxError("Syntax error")
    return commands


cpdef list parse_file(unicode filename):
    with open(filename, "r") as f:
        input = f.read()

    return parse(input, True)


class MoreInputNeeded(Exception):
    pass
