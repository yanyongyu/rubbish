from libc.stdlib cimport free

from rubbish.core.command cimport CommandType, WORD_LIST, REDIRECT, COMMAND

cdef class Redirect:

    def __cinit__(self):
        self.ptr_set = False

    def __dealloc__(self):
        # De-allocate if not null and flag is set
        if self._redirect is not NULL and self.ptr_set is True:
            free(self._redirect.redirector)
            free(self._redirect.redirectee)
            free(self._redirect)
            self._redirect = NULL

    @property
    def redirector(self):
        return self._redirect.redirector.decode("utf-8")

    @property
    def instruction(self):
        return self._redirect.instruction

    @property
    def redirectee(self):
        return self._redirect.redirectee.decode("utf-8")

    @staticmethod
    cdef Redirect from_ptr(REDIRECT *ptr, bint auto_dealloc = False):
        cdef Redirect wrapper = Redirect.__new__(Redirect)
        wrapper._redirect = ptr
        wrapper.ptr_set = auto_dealloc
        return wrapper


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
        return self._command.type

    @staticmethod
    cdef Command from_ptr(COMMAND *ptr, bint auto_dealloc = False):
        cdef Command wrapper
        cdef CommandType type = ptr.type
        if type == CommandType.cm_simple:
            wrapper = SimpleCommand.__new__(SimpleCommand)
        elif type == CommandType.cm_connection:
            wrapper = Connection.__new__(Connection)
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
        return Command.from_ptr(self._command.info.Connection.second)

    @property
    def connector(self):
        return self._command.info.Connection.connector.decode("utf-8")


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
                words.append(word.word.decode("utf-8"))
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
                redirects.append(Redirect.from_ptr(redirect))
                redirect = redirect.next
            self._redirects = tuple(redirects)
        return self._redirects
