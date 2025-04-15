%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%
[0-9]+\.[0-9]*   { yylval.dval = atof(yytext); return NUMBER; }
[0-9]+           { yylval.dval = atof(yytext); return NUMBER; }
"f"              { return F; }
"i"              { return I; }
"p"              { return PRINT; }
[a-zA-Z][a-zA-Z0-9]* { yylval.sval = strdup(yytext); return NAME; }
[ \t\r\n]+       ;
"//".*           ;
.                { return yytext[0]; }
%%