from rubbish.core import Config, set_config, get_config, get_prompt, parse


def main(config: Config = None):
    config = config or get_config()
    config.interactive = True
    set_config(config)
    while True:
        try:
            print(parse(input(get_prompt())))
        except KeyboardInterrupt:
            break
        except EOFError:
            break
