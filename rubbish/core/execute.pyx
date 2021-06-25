from libc.stdlib cimport malloc

from rubbish.core.command cimport Command, SimpleCommand, CommandType

cdef extern from "_execute.c":
    cdef int _execute "execute" (char **)


cpdef int execute_command(Command command, input, output):
    if command.type == CommandType.cm_simple:
        return execute_simplecommand(<SimpleCommand>command, input, output)


cpdef int execute_simplecommand(SimpleCommand command, input, output):
    cdef char ** parameters = <char **>malloc(100 * sizeof(char *))
    cdef int i = 0, result
    for word in command.words:
        word_bytes = word.encode("utf-8")
        parameters[i] = <char *>malloc(sizeof(char) * 100)
        parameters[i] = word_bytes
        i += 1
    result = _execute(parameters)
    return result
