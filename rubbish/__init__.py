from importlib.metadata import version, PackageNotFoundError

import colorama

colorama.init()

try:
    __version__ = version("rubbish")
except PackageNotFoundError:
    __version__ = "unknown"
