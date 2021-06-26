import os.path
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, memset

from rubbish.core.command cimport Command, SimpleCommand, Connection, CommandType, TokenType

cdef extern from "<unistd.h>":
    cdef int pipe (int fd[2])
    cdef int close (int fd)
    cdef int chdir (char* path)

cdef extern from "_execute.c":
    cdef int _execute "execute" (char **, int, int)


cpdef int execute_command(Command command, int input, int output):
    if command.type == CommandType.cm_simple:
        return execute_simplecommand(<SimpleCommand>command, input, output)
    elif command.type == CommandType.cm_connection:
        return execute_connection(<Connection>command, input, output)


cpdef int execute_simplecommand(SimpleCommand command, int input, int output):
    cdef char ** parameters
    cdef int i = 0, result

    if command.words[0] == "cd":
        return cd(command.words[1] if len(command.words) == 2 else None)

    parameters = <char **>malloc(100 * sizeof(char *))
    memset(parameters, 0, 100 * sizeof(char *))
    for word in command.words:
        word_bytes = word.encode("utf-8")
        parameters[i] = <char *>malloc(100 * sizeof(char))
        strcpy(parameters[i], word_bytes)
        i += 1

    result = _execute(parameters, input, output)

    for j in range(i):
        free(parameters[j])
    free(parameters)

    return result



cpdef int execute_connection(Connection command, int input, int output):
    cdef int status = -1
    cdef int fd[2]
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
        status = pipe(fd)
        if status == 0:
            execute_command(command.first, input, fd[1])
            status = execute_command(command.second, fd[0], output)
        close(fd[0])
        close(fd[1])
    return status

cpdef int cd(unicode dir = None):
    cdef int result
    if dir is None:
        dir = os.path.expanduser("~")
    directory = dir.encode("utf-8")
    result = chdir(directory)
    if result == -1:
        print("cd : %s: No such file or directory" % dir)
    return result
