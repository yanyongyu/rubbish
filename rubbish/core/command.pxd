cpdef public enum CommandType "command_type":
    cm_simple
    cm_connection

cpdef public enum RedirectInstruction "redirect_instruction":
    r_output_direction
    r_input_direction
    r_appending_to

cdef public struct word_list:
    word_list *next
    char *word

ctypedef public word_list WORD_LIST

cdef public union redirector:
    int dest
    char *filename

ctypedef public redirector REDIRECTOR

cdef struct redirect:
    redirect *next
    REDIRECTOR redirector
    RedirectInstruction instruction
    REDIRECTOR redirectee

ctypedef public redirect REDIRECT

cdef struct element:
  char *word
  REDIRECT *redirect
ctypedef public element ELEMENT

cdef union command_info:
    connection *Connection
    simple_cm *Simple

ctypedef public command_info COMMAND_INFO

cdef struct command:
    CommandType type
    command_info info

ctypedef public command COMMAND

cdef struct connection:
    COMMAND *first
    COMMAND *second
    int connector

ctypedef public connection CONNECTION

cdef struct simple_cm:
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
