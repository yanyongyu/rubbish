%{
#include <stdio.h>
#include <string.h>

#include "_global.h"
#include "grammar.tab.h"
%}

%option noinput
%option nounput
%option noyywrap

%%

"\\" { return BACKSLASH; }
"\n" { return NEWLINE; }
"&" { return AND; }
"&&" { return AND_AND; }
";" { return SEMI; }
"|" { return OR; }
"||" { return OR_OR; }
">" { return GREATER; }
">>" { return GREATER_GREATER; }
"<" { return LESS; }
<<EOF>> { return YACCEOF; }

\\/[:blank:]*\n { return NEWLINE; }
[^ \n\r\t\\&|<>;]+ {
  yylval.word = strdup(yytext);
  return WORD;
}
\"[^\r\t]+\" {
  yylval.word = strdup(yytext);
  return WORD;
}

[ \t\r]   /* ignore whitespace */ ;

%%