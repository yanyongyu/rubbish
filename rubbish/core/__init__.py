import os
from pathlib import Path
from typing import Optional

from colorama import Fore

from .config import Config, get_config, set_config
from .parse import parse, parse_file, MoreInputNeeded
from .execute import execute_command, execute_simplecommand, execute_connection, cd
from .prompt import get_username, get_hostname, get_cwd, get_prompt, History, Completer
from .command import (
    CommandType,
    RedirectInstruction,
    TokenType,
    Redirect,
    Command,
    Connection,
    SimpleCommand,
)

_history: Optional[History] = None
_completer: Optional[Completer] = None


def init():
    global _history
    global _completer
    config: Config = get_config()

    # init rubbish rc file
    Path(config.init_file).touch()
    try:
        init_commands = parse_file(config.init_file)
    except SyntaxError:
        print(
            f"{Fore.RED}[!] Error when parsing init file: {config.init_file}{Fore.RESET}"
        )
    else:
        try:
            f = open("/dev/null", "r+")
            for command in init_commands:
                result_code = execute_command(command, f.fileno(), f.fileno())
                assert result_code == 0
        except Exception:
            print(
                f"{Fore.RED}[!] Error when running init file: {config.init_file}{Fore.RESET}"
            )

    # init rubbish history file
    Path(config.history_file).touch()
    _history = History(config.history_file)
    _completer = Completer(
        get_paths=lambda: ["."] + os.environ.get("PATH", "").split(os.pathsep)
    )


def get_history() -> History:
    if not _history:
        raise RuntimeError("Shell not init!")

    return _history


def get_completer() -> Completer:
    if not _completer:
        raise RuntimeError("Shell not init!")

    return _completer
