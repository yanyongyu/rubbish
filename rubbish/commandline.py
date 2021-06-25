from prompt_toolkit import PromptSession, ANSI

from rubbish.core import Config, set_config, get_config, get_prompt, parse


def main(config: Config = None):
    config = config or get_config()
    config.interactive = True
    set_config(config)

    session = PromptSession()
    input_stuck = []
    more = False
    while True:
        try:
            if more:
                prompt = "... "
            else:
                prompt = ANSI(get_prompt())
            input = session.prompt(prompt)
            input_stuck.append(input)
            result = parse("\n".join(input_stuck) + "\n")
            if not result:
                more = True
                continue
            more = False
            input_stuck = []
            print(result)
        except SyntaxError:
            print("Syntax error")
            more = False
            input_stuck = []
        except KeyboardInterrupt:
            more = False
            input_stuck = []
        except EOFError:
            break
