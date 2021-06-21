from typing import Any, Union, Optional, Sequence
from argparse import ArgumentParser, Action, Namespace

import colorama

from . import __version__


class DisableAnsi(Action):
    def __call__(
        self,
        parser: ArgumentParser,
        namespace: Namespace,
        values: Union[str, Sequence[Any], None],
        option_string: Optional[str] = None,
    ):
        colorama.deinit()


parser = ArgumentParser("Rubbish", description="Rubbish -- Yet another Rubbi shell.")
parser.add_argument(
    "-v", "--version", action="version", version=f"%(prog)s {__version__}"
)
parser.add_argument("--no-ansi", action=DisableAnsi, help="disable ANSI output.")


if __name__ == "__main__":
    result = parser.parse_args()
