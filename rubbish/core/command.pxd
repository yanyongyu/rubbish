cdef extern from "_command.h":
    cpdef enum CommandType:
        cm_simple
        cm_connection

    cpdef enum RedirectInstruction:
        r_output_direction
        r_input_direction
        r_appending_to

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
        WORD
        NEWLINE
        AND
        AND_AND
        SEMI
        OR
        OR_OR
        GREATER
        GREATER_GREATER
        LESS
        YACCEOF

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
