import sys
from code import InteractiveConsole

from rubbish.core import Config, set_config, get_config, get_prompt, parse


def compile(source: str, filename: str = "<input>", symbol: str = "single"):
    return parse(source)


class Console(InteractiveConsole):
    def __init__(self) -> None:
        super(Console, self).__init__()
        self.compile = compile

    def runcode(self, code):
        print(code)

    def interact(self):
        more = 0
        while True:
            try:
                if more:
                    prompt = get_prompt()
                else:
                    prompt = get_prompt()
                try:
                    line = self.raw_input(prompt)
                except EOFError:
                    self.write("\n")
                    break
                else:
                    more = self.push(line)
            except KeyboardInterrupt:
                self.resetbuffer()
                more = 0


def main(config: Config = None):
    config = config or get_config()
    config.interactive = True
    set_config(config)

    console = Console()
    console.interact()
