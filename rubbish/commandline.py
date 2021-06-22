from rubbish.core import Config, set_config, get_prompt


def main(config: Config = None):
    if config:
        set_config(config)
    while True:
        try:
            input(get_prompt())
        except KeyboardInterrupt:
            break
        except EOFError:
            break
