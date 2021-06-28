from enum import IntEnum
from typing import Tuple, Optional

class CommandType(IntEnum):
    cm_simple = 0
    cm_connection = 1

class RedirectInstruction(IntEnum):
    r_output_direction = 0
    r_input_direction = 1
    r_appending_to = 2
    r_duplicating_output = 3
    r_duplicating_output_word = 4

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
    def second(self) -> Optional[Command]: ...
    @property
    def connector(self) -> int: ...

class SimpleCommand(Command):
    @property
    def words(self) -> Tuple[str]: ...
    @property
    def redirects(self) -> Tuple[Redirect]: ...
