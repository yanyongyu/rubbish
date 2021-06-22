from libc.stdlib cimport malloc

from rubbish.core.command cimport COMMAND, Command


cpdef Command parse(unicode input):
    cdef COMMAND *c_command = <COMMAND *>malloc(sizeof(COMMAND))
    return Command.from_ptr(c_command)
