from io import StringIO

from rubbish.core.command cimport Command, SimpleCommand


cpdef int execute_command(Command command, input, output)
cpdef int execute_simplecommand(SimpleCommand command, input, output)
