from typing import Tuple
from enum import IntEnum

class CommandType(IntEnum):
    cm_simple = 0
    cm_connection = 1

class RedirectInstruction(IntEnum):
    r_output_direction = 0
    r_input_direction = 1

class Redirect:
    @property
    def redirector(self) -> str: ...
    @property
    def instruction(self) -> RedirectInstruction: ...
    @property
    def redirectee(self) -> str: ...

class Command:
    @property
    def type(self) -> CommandType: ...

class Connection(Command):
    @property
    def first(self) -> Command: ...
    @property
    def second(self) -> Command: ...
    @property
    def connector(self) -> str: ...

class SimpleCommand(Command):
    @property
    def words(self) -> Tuple[str]: ...
    @property
    def redirects(self) -> Tuple[Redirect]: ...
