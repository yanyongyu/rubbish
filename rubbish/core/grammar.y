%{
#include "_command.h"

static REDIRECTOR source;
static REDIRECTOR destination;
extern COMMAND *global_command;

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
  WORD_LIST *word_list;
  COMMAND *command;
  ELEMENT element;
  REDIRECT *redirect;
}

%token <word> WORD
%token AND_AND OR_OR GREATER_GREATER YACCEOF

%type <redirect> redirection
%type <element> simple_command_element
%type <command> command simple_list simple_list_inner pipeline_command simple_command

%start input

%left '&' ';' '\n' YACCEOF
%left AND_AND OR_OR

%%

input:
    simple_list simple_list_terminator {
      global_command = $1;
      YYACCEPT;
    }
  | '\n'
  | YACCEOF
  ;

simple_list:
    simple_list_inner {
      $$ = $1;
    }
  | simple_list_inner '&' {
      $$ = $1;
    }
  | simple_list_inner ';' {
      $$ = $1;
    }
  ;

simple_list_inner:
    simple_list_inner AND_AND newline_list simple_list_inner {
      $$ = create_connection($1, $4, AND_AND);
    }
  | simple_list_inner OR_OR newline_list simple_list_inner {
      $$ = create_connection($1, $4, OR_OR);
    }
  | simple_list_inner '&' simple_list_inner {
      $$ = create_connection($1, $3, '&');
    }
  | simple_list_inner ';' simple_list_inner {
      $$ = create_connection($1, $3, ';');
    }
  | pipeline_command
  ;

simple_list_terminator:
    '\n'
  | YACCEOF
  ;

newline_list:
  | newline_list '\n'
  ;

pipeline_command:
    pipeline_command '|' newline_list command {
      $$ = create_connection($1, $4, '|');
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
    '>' WORD {
      source.dest = 1;
      destination.filename = $2;
      $$ = create_redirection(source, r_output_direction, destination);
    }
  | '<' WORD {
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

COMMAND * create_connection(COMMAND *first, COMMAND *second, int connector) {
  COMMAND *command;
  CONNECTION *connect;
  command = (COMMAND *)malloc(sizeof(COMMAND));
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
