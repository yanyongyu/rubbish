import sys
from prompt_toolkit import PromptSession, ANSI

from rubbish.core import (
    Config,
    set_config,
    get_config,
    get_prompt,
    parse,
    MoreInputNeeded,
    execute_command,
)


def main(config: Config = None):
    config = config or get_config()
    set_config(config)

    if config.file:
        result = parse()
        if result:
            for command in result:
                print(repr(command))
                return_code = execute_command(
                    command, sys.stdin.fileno(), sys.stdout.fileno(), False
                )
        return

    session = PromptSession()
    input_stuck = []
    more = False
    while True:
        try:
            if more:
                prompt = ".     "
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
                        command, sys.stdin.fileno(), sys.stdout.fileno(), False
                    )
        except MoreInputNeeded:
            more = True
        except SyntaxError:
            print("Syntax error")
            more = False
            input_stuck = []
        except KeyboardInterrupt:
            more = False
            input_stuck = []
        except EOFError:
            break
