from libc.stdlib cimport malloc

from rubbish.core.command cimport Command, SimpleCommand, Connection, CommandType, TokenType

cdef extern from "<unistd.h>":
    cdef int pipe (int fds[2])

cdef extern from "_execute.c":
    cdef int _execute "execute" (char **)


cpdef int execute_command(Command command, input, output):
    if command.type == CommandType.cm_simple:
        return execute_simplecommand(<SimpleCommand>command, input, output)
    elif command.type == CommandType.cm_connection:
        return execute_connection(<Connection>command, input, output)


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

cpdef int execute_connection(Connection command, input, output):
    cdef int status = -1
    cdef int fds[2]
    if command.connector == TokenType.SEMI or command.connector == TokenType.AND:
        execute_command(command.first, input, output)
        status = execute_command(command.second, input, output)
    elif command.connector == TokenType.AND_AND:
        status = execute_command(command.first, input, output)
        if status == 0:
            status = execute_command(command.second, input, output)
    elif command.connector == TokenType.OR_OR:
        status = execute_command(command.first, input, output)
        if status != 0:
            status = execute_command(command.second, input, output)
    elif command.connector == TokenType.OR:
        status = pipe(fds)
        if status == 0:
            execute_command(command.first, input, fds[1])
            status = execute_command(command.second, fds[0], output)
    return status
