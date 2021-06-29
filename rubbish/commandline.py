import sys
import traceback

from colorama import Fore
from prompt_toolkit import PromptSession, ANSI
from prompt_toolkit.auto_suggest import AutoSuggestFromHistory

from rubbish.core import (
    init,
    get_history,
    get_completer,
    Config,
    set_config,
    get_config,
    get_prompt,
    parse,
    parse_file,
    MoreInputNeeded,
    execute_command,
)


def run_file(filename: str, config: Config = None):
    config = config or get_config()
    set_config(config)
    init()

    result = parse_file(filename)
    if result:
        for command in result:
            print(repr(command))
            return_code = execute_command(
                command, sys.stdin.fileno(), sys.stdout.fileno()
            )


def run_console(config: Config = None):
    config = config or get_config()
    set_config(config)
    init()

    session = PromptSession(
        history=get_history(),
        completer=get_completer(),
        auto_suggest=AutoSuggestFromHistory(),
    )
    input_stuck = []
    more = False
    while True:
        try:
            if more:
                prompt = ANSI(f"· {Fore.YELLOW}····{Fore.RESET}")
            else:
                prompt = ANSI(get_prompt())
            input = session.prompt(prompt)
            input_stuck.append(input)
            result = parse("\n".join(input_stuck))
            more = False
            input_stuck = []
            if result:
                for command in result:
                    print(repr(command))
                    return_code = execute_command(
                        command, sys.stdin.fileno(), sys.stdout.fileno()
                    )
        except MoreInputNeeded:
            more = True
        except SyntaxError:
            traceback.print_exc()
            more = False
            input_stuck = []
        except KeyboardInterrupt:
            more = False
            input_stuck = []
        except EOFError:
            break
