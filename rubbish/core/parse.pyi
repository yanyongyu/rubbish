from typing import List, Optional

from .command import Command

def parse(input: Optional[str] = ...) -> List[Command]: ...

class MoreInputNeeded(Exception): ...
