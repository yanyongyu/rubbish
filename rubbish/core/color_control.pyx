from colorama import Fore as _Fore, Back as _Back

from rubbish.core.config cimport global_config

cdef class ForeWrap:

    @property
    def BLACK(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.BLACK

    @property
    def RED(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.RED

    @property
    def GREEN(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.GREEN

    @property
    def YELLOW(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.YELLOW

    @property
    def BLUE(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.BLUE

    @property
    def MAGENTA(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.MAGENTA

    @property
    def CYAN(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.CYAN

    @property
    def WHITE(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.WHITE

    @property
    def RESET(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.RESET


    @property
    def LIGHTBLACK_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTBLACK_EX

    @property
    def LIGHTRED_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTRED_EX

    @property
    def LIGHTGREEN_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTGREEN_EX

    @property
    def LIGHTYELLOW_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTYELLOW_EX

    @property
    def LIGHTBLUE_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTBLUE_EX

    @property
    def LIGHTMAGENTA_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTMAGENTA_EX

    @property
    def LIGHTCYAN_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTCYAN_EX

    @property
    def LIGHTWHITE_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Fore.LIGHTWHITE_EX


cdef ForeWrap Fore = ForeWrap()


cdef class BackWrap:
    @property
    def BLACK(self):
        if not global_config.use_ansi:
            return ""
        return _Back.BLACK

    @property
    def RED(self):
        if not global_config.use_ansi:
            return ""
        return _Back.RED

    @property
    def GREEN(self):
        if not global_config.use_ansi:
            return ""
        return _Back.GREEN

    @property
    def YELLOW(self):
        if not global_config.use_ansi:
            return ""
        return _Back.YELLOW

    @property
    def BLUE(self):
        if not global_config.use_ansi:
            return ""
        return _Back.BLUE

    @property
    def MAGENTA(self):
        if not global_config.use_ansi:
            return ""
        return _Back.MAGENTA

    @property
    def CYAN(self):
        if not global_config.use_ansi:
            return ""
        return _Back.CYAN

    @property
    def WHITE(self):
        if not global_config.use_ansi:
            return ""
        return _Back.WHITE

    @property
    def RESET(self):
        if not global_config.use_ansi:
            return ""
        return _Back.RESET

    @property
    def LIGHTBLACK_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTBLACK_EX

    @property
    def LIGHTRED_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTRED_EX

    @property
    def LIGHTGREEN_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTGREEN_EX

    @property
    def LIGHTYELLOW_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTYELLOW_EX

    @property
    def LIGHTBLUE_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTBLUE_EX

    @property
    def LIGHTMAGENTA_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTMAGENTA_EX

    @property
    def LIGHTCYAN_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTCYAN_EX

    @property
    def LIGHTWHITE_EX(self):
        if not global_config.use_ansi:
            return ""
        return _Back.LIGHTWHITE_EX


cdef BackWrap Back = BackWrap()
