%{
#include "_command.h"

int command_end = 1;
int is_interactive = 0;
int eof_encountered = 0;
static REDIRECTOR source;
static REDIRECTOR destination;
COMMAND *global_command = (COMMAND *)NULL;

int yylex(void);
void yyerror(const char *s);

COMMAND * create_connection(COMMAND *first, COMMAND *second, int connector);
COMMAND * create_simple_command(void);
COMMAND * merge_simple_command(ELEMENT element, COMMAND *command);
REDIRECT * create_redirection(REDIRECTOR source, enum RedirectInstruction instruction, REDIRECTOR destination);
WORD_LIST * merge_word_list(char *word, WORD_LIST *list);
%}

%union {
  char *word;
  COMMAND *command;
  ELEMENT element;
  REDIRECT *redirect;
}

%token <word> WORD
%token NEWLINE AND AND_AND SEMI OR OR_OR GREATER GREATER_GREATER LESS YACCEOF

%type <redirect> redirection
%type <element> simple_command_element
%type <command> command simple_list simple_list_inner pipeline_command simple_command

%start input

%left AND SEMI NEWLINE YACCEOF
%left AND_AND OR_OR

%%

input:
    simple_list simple_list_terminator {
      global_command = $1;
      eof_encountered = 0;
      YYACCEPT;
    }
  | NEWLINE {
      global_command = (COMMAND *)NULL;
      eof_encountered = 0;
      YYACCEPT;
    }
  | error NEWLINE {
      global_command = (COMMAND *)NULL;
      eof_encountered = 0;
      YYABORT;
    }
  | YACCEOF {
      global_command = (COMMAND *)NULL;
      eof_encountered = 1;
      YYACCEPT;
    }
  | error YACCEOF {
      global_command = (COMMAND *)NULL;
      eof_encountered = 1;
      YYABORT;
    }
  ;

simple_list:
    simple_list_inner {
      $$ = $1;
    }
  | simple_list_inner AND {
      $$ = $1;
    }
  | simple_list_inner SEMI {
      $$ = $1;
    }
  ;

simple_list_inner:
    simple_list_inner AND_AND simple_list_inner {
      $$ = create_connection($1, $3, AND_AND);
    }
  | simple_list_inner AND_AND NEWLINE newline_list simple_list_inner {
      $$ = create_connection($1, $5, AND_AND);
    }
  | simple_list_inner AND_AND NEWLINE YACCEOF {
      if (is_interactive) {
        command_end = 0;
      }
      global_command = (COMMAND *)NULL;
      eof_encountered = 1;
      YYABORT;
    }
  | simple_list_inner OR_OR simple_list_inner {
      $$ = create_connection($1, $3, OR_OR);
    }
  | simple_list_inner OR_OR NEWLINE newline_list simple_list_inner {
      $$ = create_connection($1, $5, OR_OR);
    }
  | simple_list_inner OR_OR NEWLINE YACCEOF {
      if (is_interactive) {
        command_end = 0;
      }
      global_command = (COMMAND *)NULL;
      eof_encountered = 1;
      YYABORT;
    }
  | simple_list_inner AND simple_list_inner {
      $$ = create_connection($1, $3, AND);
    }
  | simple_list_inner SEMI simple_list_inner {
      $$ = create_connection($1, $3, SEMI);
    }
  | pipeline_command
  ;

simple_list_terminator:
    NEWLINE
  | YACCEOF
  ;

newline_list:
  | newline_list NEWLINE
  ;

pipeline_command:
    pipeline_command OR command {
      $$ = create_connection($1, $3, OR);
    }
  | pipeline_command OR NEWLINE newline_list command {
      $$ = create_connection($1, $5, OR);
    }
  | pipeline_command OR NEWLINE YACCEOF {
      if (is_interactive) {
        command_end = 0;
      }
      global_command = (COMMAND *)NULL;
      eof_encountered = 1;
      YYABORT;
    }
  | command {
      $$ = $1;
    }
  ;

command:
    simple_command {
      $$ = $1;
    }
  ;

simple_command:
    simple_command_element {
      $$ = merge_simple_command($1, (COMMAND *)NULL);
    }
  | simple_command simple_command_element {
      $$ = merge_simple_command($2, $1);
    }
  ;

simple_command_element:
    WORD {
      $$.word = $1;
      $$.redirect = 0;
    }
  | redirection {
      $$.redirect = $1;
      $$.word = 0;
    }
  ;

redirection:
    GREATER WORD {
      source.dest = 1;
      destination.filename = $2;
      $$ = create_redirection(source, r_output_direction, destination);
    }
  | LESS WORD {
      source.dest = 0;
      destination.filename = $2;
      $$ = create_redirection(source, r_input_direction, destination);
    }
  | GREATER_GREATER WORD {
      source.dest = 1;
      destination.filename = $2;
      $$ = create_redirection(source, r_appending_to, destination);
    }
  ;

%%

void yyerror(const char *s) {
  /* fprintf(yyout, "%s\n", s); */
}

COMMAND * create_connection(COMMAND *first, COMMAND *second, int connector) {
  COMMAND *command;
  CONNECTION *connect;
  command = (COMMAND *)malloc(sizeof(COMMAND));
  command->type = cm_connection;
  command->info.Connection = connect = (CONNECTION *)malloc(sizeof(CONNECTION));

  connect->first = first;
  connect->second = second;
  connect->connector = connector;

  return command;
}

COMMAND * create_simple_command(void) {
  COMMAND *command;
  SIMPLE_COMMAND *temp;
  command = (COMMAND *)malloc(sizeof(COMMAND));
  command->type = cm_simple;
  command->info.Simple = temp = (SIMPLE_COMMAND *)malloc(sizeof(SIMPLE_COMMAND));

  temp->words = (WORD_LIST *)NULL;
  temp->redirects = (REDIRECT *)NULL;

  return command;
}

COMMAND * merge_simple_command(ELEMENT element, COMMAND *command) {
  if (command == 0) {
    command = create_simple_command();
  }
  if (element.word) {
    command->info.Simple->words = merge_word_list(element.word, command->info.Simple->words);
  } else if (element.redirect) {
    REDIRECT *r = element.redirect;
    while (r->next) {
      r = r->next;
    }
    r->next = command->info.Simple->redirects;
    command->info.Simple->redirects = element.redirect;
  }
  return command;
}

REDIRECT * create_redirection(REDIRECTOR source, enum RedirectInstruction instruction, REDIRECTOR destination) {
  REDIRECT *temp;
  temp = (REDIRECT *)malloc(sizeof(REDIRECT));
  temp->redirector = source;
  temp->redirectee = destination;
  temp->instruction = instruction;
  temp->next = (REDIRECT *)NULL;
  return temp;
}

WORD_LIST * merge_word_list(char *word, WORD_LIST *list) {
  WORD_LIST *temp;
  temp = (WORD_LIST *)malloc(sizeof(WORD_LIST));
  temp->word = word;
  temp->next = list;
  return temp;
}
