%{
#include "final.tab.h"
%}

%%

[0-9]+              { yylval = atoi(yytext); return NUMBER; }
"#t"                { return TRUE; }
"#f"                { return FALSE; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval = strdup(yytext); return IDENTIFIER; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MULTIPLY; }
"/"                 { return DIVIDE; }
"mod"               { return MOD; }
">"                 { return GREATER; }
"<"                 { return SMALLER; }
"="                 { return EQUAL; }
"and"               { return AND; }
"or"                { return OR; }
"not"               { return NOT; }
"define"            { return DEFINE; }
"fun"               { return FUN; }
"if"                { return IF; }
"print-num"         { return PRINT_NUM; }
"print-bool"        { return PRINT_BOOL; }
[ \t\n]+            ;  // 忽略空白字符
.                   { printf("Unknown character: %s\n", yytext); }

%%
int yywrap() {
    return 1;
}
