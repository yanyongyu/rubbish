cdef extern from "_command.h":
    cpdef enum CommandType:
        cm_simple
        cm_connection

    cpdef enum RedirectInstruction:
        r_output_direction
        r_input_direction
        r_appending_to
        r_duplicating_output
        r_duplicating_output_word
        r_duplicating_input
        r_duplicating_input_word

    ctypedef struct WORD_LIST:
        WORD_LIST *next
        char *word

    ctypedef union REDIRECTOR:
        int dest
        char *filename

    ctypedef struct REDIRECT:
        REDIRECT *next
        REDIRECTOR redirector
        RedirectInstruction instruction
        REDIRECTOR redirectee

    ctypedef union COMMAND_INFO:
        CONNECTION *Connection
        SIMPLE_COMMAND *Simple

    ctypedef struct COMMAND:
        CommandType type
        COMMAND_INFO info

    ctypedef struct CONNECTION:
        COMMAND *first
        COMMAND *second
        int connector

    ctypedef struct SIMPLE_COMMAND:
        WORD_LIST *words
        REDIRECT *redirects

cdef extern from "grammar.tab.h":
    cpdef enum TokenType "yytokentype":
        WORD = 258
        NUMBER = 259
        NEWLINE = 260
        SEMI = 261
        YACCEOF = 262
        ERROR = 263
        AND = 264
        AND_AND = 265
        OR = 266
        OR_OR = 267
        GREATER = 268
        GREATER_GREATER = 269
        GREATER_AND = 270
        LESS = 271
        LESS_AND = 272


cdef class Redirector:
    cdef REDIRECTOR *_redirector
    cdef bint ptr_set

    @staticmethod
    cdef Redirector from_ptr(REDIRECTOR *ptr, bint auto_dealloc = *)


cdef class Redirect:
    cdef REDIRECT *_redirect
    cdef bint ptr_set

    @staticmethod
    cdef Redirect from_ptr(REDIRECT *ptr, bint auto_dealloc = *)


cdef class Command:
    cdef COMMAND *_command
    cdef bint ptr_set

    @staticmethod
    cdef Command from_ptr(COMMAND *ptr, bint auto_dealloc = *)


cdef class Connection(Command):
    pass


cdef class SimpleCommand(Command):

    cdef tuple _words
    cdef tuple _redirects
