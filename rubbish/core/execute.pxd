from io import StringIO

from rubbish.core.command cimport Command, SimpleCommand, Connection


cpdef int execute_command(Command command, int input, int output, bint async = *) except? -1
cpdef int execute_simplecommand(SimpleCommand command, int input, int output) except? -1
cpdef int execute_connection(Connection command, int input, int output) except? -1
cpdef int cd(unicode dir = *) except? -1
cpdef int exit() except? -1
cpdef int alias(int output, unicode name = *, tuple words = *) except? -1
cpdef int unalias(unicode name)
cpdef int export(int output, unicode name = *, unicode value = *) except? -1
