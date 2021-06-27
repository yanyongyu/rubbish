import os.path
from libc.stdio cimport fopen, FILE
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, memset

from rubbish.core.command cimport Command, SimpleCommand, Connection, CommandType, TokenType

cdef extern from "<unistd.h>":
    ctypedef int pid_t
    cdef pid_t fork ()
    cdef int close (int fd)
    cdef int pipe (int fd[2])
    cdef void exit (int status)
    cdef int chdir (char* path)

cdef extern from "<stdio.h>":
    cdef int fileno (FILE *stream)
    cdef int dprintf (int fd, const char *format, ...)

cdef extern from "_execute.c":
    cdef int _execute "execute" (char ** parameters, int input, int output)


cpdef int execute_command(Command command, int input, int output, int async):
    if command is None:
        return 0

    cdef int status = 0
    cdef pid_t pid
    cdef char * temp

    if async:
        desc = str(command).encode("utf-8")
        temp = desc
        pid = fork()
        if (pid < 0):
            return -1
        elif pid == 0:
            if command.type == CommandType.cm_simple:
                status = execute_simplecommand(<SimpleCommand>command, input, output)
            elif command.type == CommandType.cm_connection:
                status = execute_connection(<Connection>command, input, output)
            dprintf(output, "[!] Job %s ended with status %d\n", temp, status)
            exit(status)
        else:
            dprintf(output, "[+] PID %d: Job %s start running\n", pid, temp)
            return pid

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
    cdef int fd, fds[2]
    cdef FILE *fp
    if command.connector == TokenType.SEMI:
        execute_command(command.first, input, output, 0)
        status = execute_command(command.second, input, output, 0)
    elif command.connector == TokenType.AND_AND:
        status = execute_command(command.first, input, output, 0)
        if status == 0:
            status = execute_command(command.second, input, output, 0)
    elif command.connector == TokenType.OR_OR:
        status = execute_command(command.first, input, output, 0)
        if status != 0:
            status = execute_command(command.second, input, output, 0)
    elif command.connector == TokenType.OR:
        status = pipe(fds)
        if status == 0:
            status = execute_command(command.first, input, fds[1], 0)
            close(fds[1])
            status = execute_command(command.second, fds[0], output, 0)
            close(fds[0])
    elif command.connector == TokenType.AND:
        fp = fopen("/dev/null", "r")
        fd = fileno(fp)
        execute_command(command.first, fd, output, 1)
        close(fd)
        status = execute_command(command.second, input, output, 0)
    return status

cpdef int cd(unicode dir = None):
    cdef int result
    if dir is None:
        dir = os.path.expanduser("~")
    directory = dir.encode("utf-8")
    result = chdir(directory)
    if result == -1:
        print("cd: %s: No such file or directory" % dir)
    return result
