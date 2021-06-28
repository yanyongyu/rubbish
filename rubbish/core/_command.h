#ifndef _RUBBISH_CORE_COMMAND
#define _RUBBISH_CORE_COMMAND

enum CommandType { cm_simple, cm_connection };

enum RedirectInstruction {
  r_output_direction,
  r_input_direction,
  r_appending_to,
  r_duplicating_output,
  r_duplicating_output_word
};

typedef struct word_list {
  struct word_list *next;
  char *word;
} WORD_LIST;

typedef union redirector {
  int dest;
  char *filename;
} REDIRECTOR;

typedef struct redirect {
  struct redirect *next;
  REDIRECTOR redirector;
  enum RedirectInstruction instruction;
  REDIRECTOR redirectee;
} REDIRECT;

typedef struct element {
  char *word;
  REDIRECT *redirect;
} ELEMENT;

typedef union command_info {
  struct connection *Connection;
  struct simple_cm *Simple;
} COMMAND_INFO;

typedef struct command {
  enum CommandType type;
  COMMAND_INFO info;
} COMMAND;

typedef struct connection {
  COMMAND *first;
  COMMAND *second;
  int connector;
} CONNECTION;

typedef struct simple_cm {
  WORD_LIST *words;
  REDIRECT *redirects;
} SIMPLE_COMMAND;

#endif
