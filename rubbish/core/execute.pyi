from typing import TextIO

from .command import Command, SimpleCommand

def execute_command(command: Command, input: TextIO, output: TextIO): ...
def execute_simplecommand(command: SimpleCommand, input: TextIO, output: TextIO): ...
