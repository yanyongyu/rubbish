from rubbish.core import Config, get_prompt


def main(config: Config):
    while True:
        try:
            input(get_prompt())
        except KeyboardInterrupt:
            break
        except EOFError:
            break
