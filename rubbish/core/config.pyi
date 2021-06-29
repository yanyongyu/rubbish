from typing import Optional

class Config:
    def __init__(self, init_file: str = ..., use_ansi: bool = ...): ...
    @property
    def init_file(self) -> str: ...
    @init_file.setter
    def init_file(self, value: str) -> None: ...
    @property
    def history_file(self) -> str: ...
    @history_file.setter
    def history_file(self, value: str) -> None: ...
    @property
    def use_ansi(self) -> bool: ...
    @use_ansi.setter
    def use_ansi(self, value: bool) -> None: ...

def set_config(config: Config) -> None: ...
def get_config() -> Config: ...
