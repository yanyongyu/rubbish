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
    r_duplicating_input = 5
    r_duplicating_input_word = 6

class TokenType(IntEnum):
    WORD = 258
    NUMBER = 259
    NEWLINE = 260
    SEMI = 261
    YACCEOF = 262
    ERROR = 263
    AND = 264
    AND_AND = 265
    OR = 266
    OR_OR = 267
    GREATER = 268
    GREATER_GREATER = 269
    GREATER_AND = 270
    LESS = 271
    LESS_AND = 272

class Redirector:
    @property
    def dest(self) -> int: ...
    @property
    def filename(self) -> str: ...

class Redirect:
    @property
    def redirector(self) -> int: ...
    @property
    def instruction(self) -> RedirectInstruction: ...
    @property
    def redirectee(self) -> int: ...

class Command:
    @property
    def type(self) -> CommandType: ...

class Connection(Command):
    @property
    def first(self) -> Command: ...
    @property
    def second(self) -> Optional[Command]: ...
    @property
    def connector(self) -> TokenType: ...

class SimpleCommand(Command):
    @property
    def words(self) -> Tuple[str]: ...
    @property
    def redirects(self) -> Tuple[Redirect]: ...
