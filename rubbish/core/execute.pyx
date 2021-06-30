import os.path
from typing import Dict, Tuple

from libc.errno cimport errno
from libc.stdio cimport fopen, FILE
from libc.string cimport strcpy, memset
from libc.stdlib cimport malloc, free, getenv, exit as c_exit
from rubbish.core.command cimport Command, SimpleCommand, Connection, CommandType, TokenType, RedirectInstruction

cdef extern from "<unistd.h>":
    ctypedef int pid_t
    cdef pid_t fork ()
    cdef int close (int fd)
    cdef int pipe (int fd[2])
    cdef int chdir (char* path)
    cdef char **environ
    cdef int dup(int oldfd)
    cdef int dup2(int oldfd, int newfd)
    cdef int execvp(const char* path,char* const argv[])
    cdef int STDERR_FILENO

cdef extern from "<stdio.h>":
    cdef int fileno (FILE *stream)
    cdef int setenv(const char *name, const char *value, int overwrite)
    cdef int dprintf (int fd, const char *format, ...)

cdef extern from "<wait.h>":
    cdef int wait(int* statloc)

cdef extern from "<sys/types.h>":
    ctypedef unsigned int mode_t

cdef extern from "<fcntl.h>":
    cdef int open(const char *pathname, int flags, mode_t mode)
    cdef mode_t S_IRUSR, S_IWUSR
    cdef int O_CREAT, O_RDWR, O_TRUNC, O_APPEND

aliases: Dict[str, Tuple[str]] = {
    "ls": ("ls", "--color=auto"),
    "ll": ("ls", "-alF")
}


cpdef int execute_command(Command command, int input, int output, int error, bint async = False) except? -1:
    if command is None:
        return 0

    cdef int status = 0
    cdef pid_t pid
    cdef char * temp

    if async:
        desc = str(command).encode("utf-8")
        temp = desc
        pid = fork()
        if pid < 0 :
            return -1
        elif pid == 0:
            if command.type == CommandType.cm_simple:
                status = execute_simplecommand(<SimpleCommand>command, input, output, error)
            elif command.type == CommandType.cm_connection:
                status = execute_connection(<Connection>command, input, output, error)
            dprintf(output, "[!] Job %s ended with status %d\n", temp, status)
            c_exit(status)
        else:
            dprintf(output, "[+] PID %d: Job %s start running\n", pid, temp)
            return 0

    if command.type == CommandType.cm_simple:
        return execute_simplecommand(<SimpleCommand>command, input, output, error)
    elif command.type == CommandType.cm_connection:
        return execute_connection(<Connection>command, input, output, error)


cpdef int execute_simplecommand(SimpleCommand command, int input, int output, int error) except? -1:
    cdef int fd1
    cdef int fd2
    cdef int dest
    cdef pid_t pid
    cdef char ** parameters
    cdef int i = 0
    cdef int status = -1
    cdef int result = -1
    cdef int flag = 0

    words = list(command.words)

    if words[0] in aliases:
        words[:1] = list(aliases[words[0]])

    if words[0] == "cd":
        return cd(words[1] if len(words) == 2 else None)
    elif words[0] == "exit":
        return exit()
    elif words[0] == "alias":
        if len(words) == 1:
            return alias(output)
        return alias(output, words[1], tuple(words[2:]))
    elif words[0] == "unalias":
        return unalias(words[1])
    elif words[0] == "export":
        if len(words) == 1:
            return export(output)
        elif len(words) == 2:
            return export(output, words[1])
        return export(output, words[1], words[2])
    elif words[0] == "help":
        return help(output)

    parameters = <char **>malloc(100 * sizeof(char *))
    memset(parameters, 0, 100 * sizeof(char *))
    for word in words:
        word_bytes = word.encode("utf-8")
        parameters[i] = <char *>malloc(100 * sizeof(char))
        strcpy(parameters[i], word_bytes)
        i += 1

    pid = fork()
    if pid < 0:
        dprintf(error, "create fork failed\n")
    elif pid ==0:
        dup2(input, 0)
        dup2(output, 1)
        dup2(error, 2)

        for redirect in command.redirects:
            if redirect.instruction == RedirectInstruction.r_input_direction:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp,O_RDWR, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(error, "open error\n")
                    c_exit(fd)
                flag = 1
                fd2 = dup2(fd, dest)
                if fd2 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd2)
            elif redirect.instruction == RedirectInstruction.r_output_direction:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(error, "open error\n")
                    c_exit(fd)
                flag = 1
                fd2 = dup2(fd, dest)
                if fd2 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd2)
            elif redirect.instruction == RedirectInstruction.r_appending_to:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_APPEND, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(error, "open error\n")
                    c_exit(fd)
                flag = 1
                fd2 = dup2(fd, dest)
                if fd2 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd2)
            elif redirect.instruction == RedirectInstruction.r_duplicating_output:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.dest
                fd1 = dup2(temp, dest)
                if fd1 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd1)
                fd2 = dup2(temp, 2)
                if fd2 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd2)
            elif redirect.instruction == RedirectInstruction.r_duplicating_output_word:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(error, "open error\n")
                    c_exit(fd)
                flag = 1
                fd1 = dup2(fd, dest)
                if fd1 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd1)
                fd2 = dup2(fd, 2)
                if fd2 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd2)
            elif redirect.instruction == RedirectInstruction.r_duplicating_input:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.dest
                fd1 = dup2(temp, dest)
                if fd1 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd1)
            elif redirect.instruction == RedirectInstruction.r_duplicating_input_word:
                dest = redirect.redirector.dest
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(error, "open error\n")
                    c_exit(fd)
                flag = 1
                fd1 = dup2(fd, dest)
                if fd1 < 0:
                    dprintf(error, "dup2 error\n")
                    c_exit(fd1)

        result = execvp(parameters[0], parameters)

        if flag == 1:
            close(fd)

        if result < 0:
            dprintf(error, "%s: command not found\n", parameters[0])

        c_exit(errno)
    else:
        wait(&status)

    for j in range(i):
        free(parameters[j])
    free(parameters)

    return status



cpdef int execute_connection(Connection command, int input, int output, int error) except? -1:
    cdef int status = -1
    cdef int fd, fds[2]
    cdef FILE *fp
    if command.connector == TokenType.SEMI:
        execute_command(command.first, input, output, error)
        status = execute_command(command.second, input, output, error)
    elif command.connector == TokenType.AND_AND:
        status = execute_command(command.first, input, output, error)
        if status == 0:
            status = execute_command(command.second, input, output, error)
    elif command.connector == TokenType.OR_OR:
        status = execute_command(command.first, input, output, error)
        if status != 0:
            status = execute_command(command.second, input, output, error)
    elif command.connector == TokenType.OR:
        status = pipe(fds)
        if status == 0:
            status = execute_command(command.first, input, fds[1], error)
            close(fds[1])
            status = execute_command(command.second, fds[0], output, error)
            close(fds[0])
    elif command.connector == TokenType.AND:
        fp = fopen("/dev/null", "r")
        fd = fileno(fp)
        execute_command(command.first, fd, output, error, 1)
        close(fd)
        status = execute_command(command.second, input, output, error)
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
cpdef int help(int output):
    cdef char *temp_str
    text = (
		"                  ______\n"
		"                 /      \\\n"
		"       __________   __   ___________\n"
		"   ___/         \\__    __/          \\___\n"
		"  /                                      \\\n"
		" /____     Welcome to RubbiShell!     ____\\\n"
		"|     \\____                     ____/     |       -exit\n"
		" \\____                               ____/        -alias\n"
		" /   ________                 _________  \\         alias name command arg1 arg2\n"
		" \\          \\\\_______________//          /        -unalias\n"
		"  \\|                                   |/         -export\n"
		"   |  |   |     |    |    |     |   |  |           export name\n"
		"   |  \\   |     |    |    |     |   /  |           export name value\n"
		"   |   |  |     |    |    |     |  |   |          -cd\n"
		"   |   |  \\     |    |    |     /  |   |           cd ..\n"
		"   |   |   |    |    |    |    |   |   |\n"
		"   \\|  |   |    |    |    |    |   |  |/\n"
		"    |  |   |    |    |    |    |   |  |\n"
		"    |  \\|  |    |    |    |    |  |/  |\n"
		"    ||  |  |    |    |    |    |  |  ||\n"
		"    \\|  |  |    |    |    |    |  |  |/\n"
		"     |  |  |    |    |    |    |  |  |\n"
		"     \\  |  |    |    |    |    |  | /\n"
		"      \\____________________________/\n"
	).encode("utf-8")
    temp_str = text
    dprintf(output, "%s", temp_str)
    return 0
