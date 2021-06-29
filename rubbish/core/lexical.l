%{
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#include "_global.h"
#include "grammar.tab.h"

char temp;
char *temp_str;
long number_value;
enum yytokentype last_token;

int legal_number(const char *string, long *result);
void filter_string(const char *string, char *output);
%}

%option noyywrap

%%

"\n" { last_token = NEWLINE; return NEWLINE; }
"&" { last_token = AND; return AND; }
"&&" { last_token = AND_AND; return AND_AND; }
";" { last_token = SEMI; return SEMI; }
"|" { last_token = OR; return OR; }
"||" { last_token = OR_OR; return OR_OR; }
">" { last_token = GREATER; return GREATER; }
">>" { last_token = GREATER_GREATER; return GREATER_GREATER; }
">&" { last_token = GREATER_AND; return GREATER_AND; }
"<" { last_token = LESS; return LESS; }
"<&" { last_token = LESS_AND; return LESS_AND; }
<<EOF>> { last_token = YACCEOF; return YACCEOF; }

[^ "\n\r\t&|<>;]+ {
  // meet escaped special character, more input needed
  if (yytext[yyleng - 1] == '\\') {
    temp = input();
    yytext[yyleng] = temp;
    yymore();
  } else {
    // yylval.word = strdup(yytext);
    temp_str = strdup(yytext);

    // lookahead one character
    temp = input();
    if (temp) {
      unput(temp);
    }

    // only convert to int if last_token is '>&' '<&' or next token is '>' '<'
    if (last_token == GREATER_AND || last_token == LESS_AND || temp == '>' || temp == '<') {
      if (legal_number(temp_str, &number_value) && (int)number_value == number_value) {
        yylval.number = number_value;
        free(temp_str);
        last_token = NUMBER;
        return NUMBER;
      }
    }

    yylval.word = (char *)malloc(strlen(temp_str) * sizeof(char));
    filter_string(temp_str, yylval.word);
    free(temp_str);
    last_token = WORD;
    return WORD;
  }

}
\"[^"]* {
  // meet escaped quote character, more input needed
  if (yytext[yyleng - 1] == '\\') {
    yymore();
  } else {
    temp = input();
    if (temp == '"') {
      // yylval.word = strdup(yytext);
      yylval.word = (char *)malloc(strlen(yytext) * sizeof(char));
      filter_string(yytext + 1, yylval.word);
      last_token = WORD;
      return WORD;
    }

    // input not complete
    if (temp) {
      unput(temp);
    }
    if (is_interactive) {
      command_end = 0;
    }
    return ERROR;
  }
}

[ \t\r] /* ignore whitespace */ ;
\\[[:blank:]]*\n /* ignore escaped newline */ ;

%%

int legal_number(const char *string, long *result) {
  long value;
  char *ep;
  if (result) *result = 0;
  if (string == 0) return 0;

  errno = 0;
  value = strtoimax(string, &ep, 10);
  if (errno || ep == string) return 0;
  if (*string && *ep == '\0') {
    if (result) *result = value;
    return 1;
  }
  return 0;
}

void filter_string(const char *string, char * output) {
  const char *p_read = string;
  char *p_write = output;
  while (*p_read) {
    *p_write = *p_read;
    p_read++;
    p_write += (*p_write != '\\' || *p_read == '\\');
  }
  *p_write = '\0';
}
