from argparse import ArgumentParser

from .core import Config
from . import __version__
from .commandline import main


parser = ArgumentParser("Rubbish", description="Rubbish -- Yet another Rubbi shell.")
parser.add_argument(
    "-v", "--version", action="version", version=f"%(prog)s {__version__}"
)
parser.add_argument(
    "--no-ansi",
    action="store_false",
    dest="use_ansi",
    help="disable ANSI output.",
)
parser.add_argument(
    "file", action="store", nargs="?", default=None, metavar="FILE", help="input file."
)


def start():
    config = parser.parse_args(namespace=Config())
    main(config)


if __name__ == "__main__":
    start()
