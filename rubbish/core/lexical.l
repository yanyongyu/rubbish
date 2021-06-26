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

([^ \n\r\t\\&|<>;]|"\\ ")+ {
  yylval.word = strdup(yytext);
  return WORD;
}
\"[^\r\t]+\" {
  yylval.word = strdup(yytext);
  return WORD;
}

[ \t\r] /* ignore whitespace */ ;
\\/[:blank:]*\n /* ignore escaped newline */ ;

%%
