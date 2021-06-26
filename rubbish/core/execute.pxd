from io import StringIO

from rubbish.core.command cimport Command, SimpleCommand, Connection


cpdef int execute_command(Command command, int input, int output)
cpdef int execute_simplecommand(SimpleCommand command, int input, int output)
cpdef int execute_connection(Connection command, int input, int output)
