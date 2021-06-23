%{
#define YYSTYPE char*
#include "grammar.tab.h"
%}

%%

"\\" { return '\\'; }
"\n" { return '\n'; }
"&&" { return AND_AND; }
"&" { return '&'; }
";" { return ';'; }
"||" { return OR_OR; }
"|" { return '|'; }
">>" { return GREATER_GREATER; }
">" { return '>'; }
"<" { return '<'; }
<<EOF>> { return YACCEOF; }

[^ \n\r\t&|<>;]+ {
  yylval = strdup(yytext);
  return WORD;
}

[ \t\r]   /* ignore whitespace */ ;

%%
