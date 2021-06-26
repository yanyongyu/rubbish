from typing import Optional

from .command import Command

def parse(input: Optional[str] = ...) -> Optional[Command]: ...

class MoreInputNeeded(Exception): ...
