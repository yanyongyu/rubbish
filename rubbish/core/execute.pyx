from rubbish.core.command cimport Command, SimpleCommand
from libc.stdlib cimport malloc

cdef extern from "_execute.c":
    int _execute "execute" (char **)


cpdef void execute_command(Command command, input, output):
    pass


cpdef int execute_simplecommand(SimpleCommand command, input, output):
    cdef char ** parameters=<char **>malloc(100*sizeof(char *))
    cdef int i=0,result
    for word in command.words:
        word_bytes = word.decode("utf-8")
        parameters[i] = <char *>malloc(sizeof(char) * 100);
        parameters[i] = word_bytes
        i += 1
    result = _execute(parameters)
    return result

