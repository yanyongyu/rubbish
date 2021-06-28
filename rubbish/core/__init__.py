from pathlib import Path

from colorama import Fore

from .parse import parse, parse_file, MoreInputNeeded
from .config import Config, get_config, set_config
from .prompt import get_username, get_hostname, get_cwd, get_prompt
from .execute import execute_command, execute_simplecommand, execute_connection, cd
from .command import (
    CommandType,
    RedirectInstruction,
    TokenType,
    Redirect,
    Command,
    Connection,
    SimpleCommand,
)


def init():
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
