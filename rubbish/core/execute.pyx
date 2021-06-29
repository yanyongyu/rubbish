import os.path
from libc.errno cimport errno
from libc.stdio cimport fopen, FILE
from libc.stdlib cimport malloc, free, exit as c_exit
from libc.string cimport strcpy, memset
from rubbish.core.command cimport Command, SimpleCommand, Connection, CommandType, TokenType, RedirectInstruction

cdef extern from "<unistd.h>":
    ctypedef int pid_t
    cdef pid_t fork ()
    cdef int close (int fd)
    cdef int pipe (int fd[2])
    cdef int chdir (char* path)
    cdef dup(int oldfd)
    cdef int dup2(int oldfd, int newfd)
    cdef int execvp(const char* path,char* const argv[])
    cdef int STDERR_FILENO
cdef extern from "<stdio.h>":
    cdef int fileno (FILE *stream)
    cdef int dprintf (int fd, const char *format, ...)

cdef extern from "<wait.h>":
    cdef int wait(int* statloc)

cdef extern from "<sys/types.h>":
    ctypedef unsigned int mode_t

cdef extern from "<fcntl.h>":
    cdef int open(const char *pathname, int flags, mode_t mode)
    cdef mode_t S_IRUSR, S_IWUSR
    cdef int O_CREAT, O_RDWR, O_TRUNC, O_APPEND

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
        if pid < 0 :
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
    cdef int i = 0

    if command.words[0] == "cd":
        return cd(command.words[1] if len(command.words) == 2 else None)
    elif command.words[0] == "exit":
        return exit()
    elif command.words[0] == "help":
        return help()

    parameters = <char **>malloc(100 * sizeof(char *))
    memset(parameters, 0, 100 * sizeof(char *))
    for word in command.words:
        word_bytes = word.encode("utf-8")
        parameters[i] = <char *>malloc(100 * sizeof(char))
        strcpy(parameters[i], word_bytes)
        i += 1
    cdef int status = 0
    cdef pid_t pid
    cdef int result = 0
    cdef int fd
    cdef int fd2
    cdef int flag = 0
    pid = fork()
    if pid < 0 :
        dprintf(output, "create fork failed\n")
    elif pid ==0 :
        dup2(input, 0)
        dup2(output, 1)
        for redirect in command.redirects:
            if redirect.instruction == RedirectInstruction.r_output_direction:
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(output, " open error\n")
                    return result
                flag = 1
                fd2 = dup2(fd, output)
                if fd2 < 0:
                    dprintf(output, "dup2 error\n")
                    return result
            elif redirect.instruction == RedirectInstruction.r_appending_to:
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_APPEND, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(output, " open error\n")
                    return result
                flag = 1
                fd2 = dup2(fd, output)
                if fd2 < 0:
                    dprintf(output, "dup2 error\n")
                    return result
            elif redirect.instruction == RedirectInstruction.r_input_direction:
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp,O_RDWR, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(output, " open error\n")
                    return result
                flag = 1
                fd2 = dup2(fd, input)
                if fd2 < 0:
                    dprintf(output, "dup2 error\n")
                    return result
            elif redirect.instruction == RedirectInstruction.r_duplicating_output_word:
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(output, " open error\n")
                    return result
                flag = 1
                fd1 = dup2(fd, output)
                fd2 = dup2(fd, STDERR_FILENO)
                if fd2 < 0 or fd1 < 0:
                    dprintf(output, "dup2 error\n")
                    return result
            elif redirect.instruction == RedirectInstruction.r_duplicating_output:
                temp = redirect.redirectee.dest
                fd1 = dup2(temp, output)
                fd2 = dup2(temp, STDERR_FILENO)
                if fd2 < 0 or fd1 < 0:
                    dprintf(output, "dup2 error\n")
                    return result
            elif redirect.instruction == RedirectInstruction.r_duplicating_input_word:
                temp = redirect.redirectee.filename.encode("utf-8")
                fd = open(temp, O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR)
                if fd < 0:
                    dprintf(output, " open error\n")
                    return result
                flag = 1
                fd1 = dup2(fd, input)
                if fd1 < 0:
                    dprintf(output, "dup2 error\n")
                    return result
            elif redirect.instruction == RedirectInstruction.r_duplicating_input:
                temp = redirect.redirectee.dest
                fd1 = dup2(temp, output)
                if  fd1 < 0:
                    dprintf(output, "dup2 error\n")
                    return result

        result = execvp( parameters[0], parameters)
        if flag == 1:
            close(fd)
        if result<0 :
            dprintf(output, "%s: command not found\n", parameters[0])
            c_exit(errno)
        else:
            wait(&status)


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

cpdef int help():
    print(
		"                  ______\n"
		"                 /      \\\n"
		"       __________   __   ___________\n"
		"   ___/         \\__    __/          \\___\n"
		"  /                                      \\\n"
		" /____     Welcome to RubbiShell!     ____\\\n"
		"|     \\____                     ____/     |\n"
		" \\____                               ____/\n"
		" /   ________                 _________  \\\n"
		" \\          \\\\_______________//          /\n"
		"  \\|                                   |/\n"
		"   |  |   |     |    |    |     |   |  |\n"
		"   |  \\   |     |    |    |     |   /  |\n"
		"   |   |  |     |    |    |     |  |   |\n"
		"   |   |  \\     |    |    |     /  |   |\n"
		"   |   |   |    |    |    |    |   |   |\n"
		"   \\|  |   |    |    |    |    |   |  |/\n"
		"    |  |   |    |    |    |    |   |  |\n"
		"    |  \\|  |    |    |    |    |  |/  |\n"
		"    ||  |  |    |    |    |    |  |  ||\n"
		"    \\|  |  |    |    |    |    |  |  |/\n"
		"     |  |  |    |    |    |    |  |  |\n"
		"     \\  |  |    |    |    |    |  | /\n"
		"      \\____________________________/\n"
	)
    return 1
