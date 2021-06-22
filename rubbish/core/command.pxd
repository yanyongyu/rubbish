cpdef public enum CommandType "command_type":
    cm_simple
    cm_connection

cpdef public enum RedirectInstruction "redirect_instruction":
    r_output_direction
    r_input_direction

cdef public struct word_list:
    word_list *next
    char *word

ctypedef public word_list WORD_LIST

cdef public struct redirect:
    redirect *next
    char *redirector
    RedirectInstruction instruction
    char *redirectee

ctypedef public redirect REDIRECT

cdef public union command_info:
    connection *Connection
    simple_cm *Simple

ctypedef public command_info COMMAND_INFO

cdef public struct command:
    CommandType type
    command_info info

ctypedef public command COMMAND

cdef public struct connection:
    COMMAND *first
    COMMAND *second
    char connector

ctypedef public connection CONNECTION

cdef public struct simple_cm:
    WORD_LIST *words
    REDIRECT *redirects

ctypedef public simple_cm SIMPLE_COMMAND

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
