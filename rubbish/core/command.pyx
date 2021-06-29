from libc.stdlib cimport free

cdef class Redirector:

    def __cinit__(self):
        self.ptr_set = False

    def __dealloc__(self):
        if self._redirector is not NULL and self.ptr_set is True:
            self._redirector = NULL

    @property
    def dest(self):
        return self._redirector.dest

    @property
    def filename(self):
        return self._redirector.filename.decode("utf-8")

    @staticmethod
    cdef Redirector from_ptr(REDIRECTOR *ptr, bint auto_dealloc = False):
        cdef Redirector wrapper = Redirector.__new__(Redirector)
        wrapper._redirector = ptr
        wrapper.ptr_set = auto_dealloc
        return wrapper


cdef class Redirect:

    def __cinit__(self):
        self.ptr_set = False

    def __dealloc__(self):
        # De-allocate if not null and flag is set
        if self._redirect is not NULL and self.ptr_set is True:
            free(self._redirect)
            self._redirect = NULL

    @property
    def redirector(self):
        return Redirector.from_ptr(&self._redirect.redirector)

    @property
    def instruction(self):
        return RedirectInstruction(self._redirect.instruction)

    @property
    def redirectee(self):
        return Redirector.from_ptr(&self._redirect.redirectee)

    @staticmethod
    cdef Redirect from_ptr(REDIRECT *ptr, bint auto_dealloc = False):
        cdef Redirect wrapper = Redirect.__new__(Redirect)
        wrapper._redirect = ptr
        wrapper.ptr_set = auto_dealloc
        return wrapper

    def __str__(self):
        return f"({self.redirector} {self.instruction!s} {self.redirectee})"

    def __repr__(self):
        return f"Redirect({self.redirector} {self.instruction!s} {self.redirectee})"


cdef class Command:

    def __cinit__(self):
        self.ptr_set = False

    def __dealloc__(self):
        # De-allocate if not null and flag is set
        if self._command is not NULL and self.ptr_set is True:
            free(self._command)
            self._command = NULL

    @property
    def type(self):
        return CommandType(self._command.type)

    @staticmethod
    cdef Command from_ptr(COMMAND *ptr, bint auto_dealloc = False):
        cdef Command wrapper
        cdef CommandType type = ptr.type
        if type == CommandType.cm_simple:
            wrapper = SimpleCommand.__new__(SimpleCommand)
        elif type == CommandType.cm_connection:
            wrapper = Connection.__new__(Connection)
        else:
            raise ValueError("Unknown command type")
        wrapper._command = ptr
        wrapper.ptr_set = auto_dealloc
        return wrapper


cdef class Connection(Command):

    def __dealloc__(self):
        if self._command is not NULL and self.ptr_set is True:
            free(self._command.info.Connection.first)
            free(self._command.info.Connection.second)
            free(self._command.info.Connection)
            free(self._command)
            self._command = NULL

    @property
    def first(self):
        return Command.from_ptr(self._command.info.Connection.first)

    @property
    def second(self):
        if self._command.info.Connection.second is NULL:
            return None
        return Command.from_ptr(self._command.info.Connection.second)

    @property
    def connector(self):
        return TokenType(self._command.info.Connection.connector)

    def __str__(self):
        return f"({self.first}) {self.connector!s} ({self.second})"

    def __repr__(self):
        return f"Connection({self.first} {self.connector!s} {self.second})"


cdef class SimpleCommand(Command):

    def __dealloc__(self):
        cdef WORD_LIST *word
        cdef WORD_LIST *temp1
        cdef REDIRECT *redirect
        cdef REDIRECT *temp2
        if self._command is not NULL and self.ptr_set is True:
            word = self._command.info.Simple.words
            while word:
                temp1 = word
                word = word.next
                free(word)
            redirect = self._command.info.Simple.redirects
            while redirect:
                temp2 = redirect
                redirect = redirect.next
                free(redirect)
            free(self._command.info.Simple)
            free(self._command)
            self._command = NULL

    @property
    def words(self):
        cdef list words
        cdef WORD_LIST *word
        if not self._words:
            words = []
            word = self._command.info.Simple.words
            while word:
                words.insert(0, word.word.decode("utf-8"))
                word = word.next
            self._words = tuple(words)
        return self._words

    @property
    def redirects(self):
        cdef list redirects
        cdef REDIRECT *redirect
        if not self._redirects:
            redirects = []
            redirect = self._command.info.Simple.redirects
            while redirect:
                redirects.insert(0, Redirect.from_ptr(redirect))
                redirect = redirect.next
            self._redirects = tuple(redirects)
        return self._redirects

    def __str__(self):
        return f"{' '.join(self.words)} {' '.join(map(str, self.redirects))}".strip()

    def __repr__(self):
        return f"SimpleCommand({self.words}, {self.redirects})"
