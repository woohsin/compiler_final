%{
#include "final.tab.h"
#include <stdio.h>
%}

%%

"("                { return LPAREN; }
")"                { return RPAREN; }
"print-num"        { return PRINT_NUM; }
"print-bool"       { return PRINT_BOOL; }
"define"           { return DEFINE; }
"fun"              { return FUN; }
"if"               { return IF; }
"and"              { return AND; }
"or"               { return OR; }
"not"              { return NOT; }
"="                { return EQUAL; }
">"                { return GREATER; }
"<"                { return SMALLER; }
"mod"              { return MODULUS; }
"+"                { return PLUS; }
"-"                { return MINUS; }
"*"                { return MULTIPLY; }
"/"                { return DIVIDE; }
"#t"               { yylval.unit.type = BOOL; yylval.unit.val = 1; return BOOL;}
"#f"               { yylval.unit.type = BOOL; yylval.unit.val = 0; return BOOL;}
0|\-?[0-9]+        { yylval.unit.type = NUM; yylval.unit.val = atoi(yytext); return NUM;}
[ \t\n\r]+         {  }
[a-z][0-9a-z\-]*   { strcpy(yylval.unit.name, yytext); return ID; }
.                  {  }

%%

int yywrap() {
    return 1;
}
