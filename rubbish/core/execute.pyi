from typing import TextIO

from .command import Command

def execute_command(command: Command, input: TextIO, output: TextIO): ...
