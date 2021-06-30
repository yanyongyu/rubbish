from typing import Optional
from argparse import ArgumentParser
from dataclasses import dataclass, asdict

from . import __version__
from .core import Config
from .commandline import run_file, run_ui, run_console


@dataclass
class CommandlineConfig(object):
    ui: bool = False
    debug: bool = False
    use_ansi: bool = True
    file: Optional[str] = None
    init_file: str = ""
    history_file: str = ""


parser = ArgumentParser("Rubbish", description="Rubbish -- Yet another Rubbi shell.")
parser.add_argument(
    "-v", "--version", action="version", version=f"%(prog)s {__version__}"
)
parser.add_argument(
    "-d", "--debug", action="store_true", dest="debug", help="enable debugging."
)
parser.add_argument(
    "--no-ansi",
    action="store_false",
    dest="use_ansi",
    help="disable ANSI output.",
)
parser.add_argument(
    "--init-file", action="store", dest="init_file", help="rubbish init file."
)
parser.add_argument(
    "--history-file", action="store", dest="history_file", help="rubbish history file."
)
parser.add_argument("--ui", action="store_true", dest="ui", help="launch terminal ui.")
parser.add_argument(
    "file", action="store", nargs="?", default=None, metavar="FILE", help="input file."
)


def start():
    commandline_config = parser.parse_args(namespace=CommandlineConfig())
    config = Config(**asdict(commandline_config))
    if commandline_config.file:
        run_file(commandline_config.file, config, commandline_config.debug)
    elif commandline_config.ui:
        run_ui(config)
    else:
        run_console(config, commandline_config.debug)


if __name__ == "__main__":
    start()
