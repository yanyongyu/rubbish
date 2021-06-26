from typing import Optional

from .command import Command

def parse(input: str) -> Optional[Command]: ...

class MoreInputNeeded(Exception): ...
