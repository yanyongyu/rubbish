import os.path
from typing import Dict, Tuple

from libc.stdio cimport fopen, FILE
from libc.string cimport strcpy, memset
from libc.stdlib cimport malloc, free, getenv

from rubbish.core.command cimport Command, SimpleCommand, Connection, CommandType, TokenType

cdef extern from "<unistd.h>":
    ctypedef int pid_t
    cdef pid_t fork ()
    cdef int close (int fd)
    cdef int pipe (int fd[2])
    cdef void c_exit "exit" (int status)
    cdef int chdir (char* path)
    cdef char **environ

cdef extern from "<stdio.h>":
    cdef int fileno (FILE *stream)
    cdef int setenv(const char *name, const char *value, int overwrite)
    cdef int dprintf (int fd, const char *format, ...)

cdef extern from "_execute.c":
    cdef int _execute "execute" (char ** parameters, int input, int output)


aliases: Dict[str, Tuple[str]] = {
    "ls": ("ls", "--color=auto"),
    "ll": ("ls", "-alF")
}


cpdef int execute_command(Command command, int input, int output, bint async = False) except? -1:
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
            c_exit(status)
        else:
            dprintf(output, "[+] PID %d: Job %s start running\n", pid, temp)
            return 0

    if command.type == CommandType.cm_simple:
        return execute_simplecommand(<SimpleCommand>command, input, output)
    elif command.type == CommandType.cm_connection:
        return execute_connection(<Connection>command, input, output)


cpdef int execute_simplecommand(SimpleCommand command, int input, int output) except? -1:
    cdef char ** parameters
    cdef int i = 0, result

    words = list(command.words)

    if words[0] in aliases:
        words[:1] = list(aliases[words[0]])

    if words[0] == "cd":
        return cd(command.words[1] if len(command.words) == 2 else None)
    elif words[0] == "exit":
        return exit()
    elif words[0] == "alias":
        if len(command.words) == 1:
            return alias(output)
        return alias(output, command.words[1], command.words[2:])
    elif words[0] == "unalias":
        return unalias(command.words[1])
    elif words[0] == "export":
        if len(command.words) == 1:
            return export(output)
        elif len(command.words) == 2:
            return export(output, command.words[1])
        return export(output, command.words[1], command.words[2])

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



cpdef int execute_connection(Connection command, int input, int output) except? -1:
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

cpdef int cd(unicode dir = None) except? -1:
    cdef int result
    if dir is None:
        dir = os.path.expanduser("~")
    directory = dir.encode("utf-8")
    result = chdir(directory)
    if result == -1:
        print("cd: %s: No such file or directory" % dir)
    return result

cpdef int exit() except? -1:
    raise EOFError("Shell exit")

cpdef int alias(int output, unicode name = None, tuple words = None) except? -1:
    cdef char *temp_str
    if not name:
        for key, value in aliases.items():
            formated = f"alias {key} '{' '.join(value)}'".encode("utf-8")
            temp_str = formated
            dprintf(output, "%s\n", temp_str)
    elif not words:
        return 1
    else:
        aliases[name] = words
    return 0

cpdef int unalias(unicode name):
    aliases.pop(name, None)
    return 0

cpdef int export(int output, unicode name = None, unicode value = None) except? -1:
    cdef int i = 0
    cdef char *temp_str
    cdef char *temp_name
    cdef char *temp_value
    if not name:
        while True:
            temp_str = environ[i]
            if temp_str == NULL:
                break
            dprintf(output, "%s\n", temp_str)
            i += 1
    elif not value:
        name_bytes = name.encode("utf-8")
        temp_name = name_bytes
        temp_value = getenv(temp_name)
        if temp_value is not NULL:
            dprintf(output, "%s\n", temp_value)
    else:
        name_bytes = name.encode("utf-8")
        value_bytes = value.encode("utf-8")
        temp_name = name_bytes
        temp_value = value_bytes
        return setenv(temp_name, temp_value, 1)
    return 0
