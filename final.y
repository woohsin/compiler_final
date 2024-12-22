%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
int yylex();
void yyerror(const char *s);
void reduce(const char *s);
%}

%union {
int ival;
struct {
    int type;
    int val;
    char name[];
} unit;
}

%token <unit> NUM BOOL ID
%token PRINT_NUM PRINT_BOOL LPAREN RPAREN
%token DEFINE FUN IF
%token AND OR NOT
%token EQUAL GREATER SMALLER
%token MODULUS PLUS MINUS MULTIPLY DIVIDE

%type <unit> PROGRAM STMT_LIST STMT PRINT_STMT EXP 
%type <unit> NUM_OP LOGICAL_OP AND_OP OR_OP AND_OPS OR_OPS 
%type <unit> PLUS_OPS PLUS_OP MULTIPLY_OPS MULTIPLY_OP EQUAL_OPS EQUAL_OP
%type <unit> DEF_STMT FUN_EXP ID_LIST FUN_BODY FUN_CALL PARAM_LIST FUN_NAME 
%type <unit> IF_EXP TEST_EXP THAN_EXP ELSE_EXP

%%

PROGRAM  : STMT_LIST
         ;

STMT_LIST: STMT
         | STMT_LIST STMT
         ;

STMT     : EXP
         | DEF_STMT
         | PRINT_STMT
         ;

PRINT_STMT: LPAREN PRINT_NUM EXP RPAREN { if($3.type != NUM){ yyerror("type"); } else { printf("%d\n", $3.val); }}
          | LPAREN PRINT_BOOL EXP RPAREN { if($3.type != BOOL){ yyerror("type"); } else { printf("%s\n", ($3.val == 1 ? "#t" : "#f")); } }
          ;

EXP      : BOOL         { $$ = $1; }
         | NUM          { $$ = $1; }
         | ID           { $$ = $1; }
         | NUM_OP       { $$ = $1; }
         | LOGICAL_OP   { $$ = $1; }
         | FUN_EXP      { $$ = $1; }
         | FUN_CALL     { $$ = $1; }
         | IF_EXP       { $$ = $1; }
         ;

NUM_OP   : LPAREN PLUS_OPS RPAREN           { $$ = $2;}
         | LPAREN MINUS EXP EXP RPAREN      { $$.type = NUM; $$.val = $3.val - $4.val;}
         | LPAREN MULTIPLY_OPS RPAREN       { $$ = $2;}
         | LPAREN DIVIDE EXP EXP RPAREN     { $$.type = NUM; $$.val = $3.val / $4.val;}
         | LPAREN MODULUS EXP EXP RPAREN    { $$.type = NUM; $$.val = $3.val % $4.val;}
         | LPAREN GREATER EXP EXP RPAREN    { $$.type = BOOL; $$.val = $3.val > $4.val;}
         | LPAREN SMALLER EXP EXP RPAREN    { $$.type = BOOL; $$.val = $3.val < $4.val;}
         | LPAREN EQUAL_OPS RPAREN          { $$ = $2;}
         ;

PLUS_OPS    :PLUS_OPS EXP   { $$.type = NUM; $$.val = $1.val + $2.val;}
            |PLUS_OP        { $$ = $1;}
            ;

MULTIPLY_OPS:MULTIPLY_OPS EXP   { $$.type = NUM; $$.val = $1.val * $2.val;}
            |MULTIPLY_OP        { $$ = $1;}
            ;

EQUAL_OPS   :EQUAL_OPS EXP      { $$.type = BOOL; $$.val = $1.val == $2.val;}
            |EQUAL_OP           { $$ = $1;}
            ;

PLUS_OP     :PLUS EXP EXP { $$.type = NUM; $$.val = $2.val + $3.val;}
MULTIPLY_OP :MULTIPLY EXP EXP { $$.type = NUM; $$.val = $2.val * $3.val;}
EQUAL_OP    :EQUAL EXP EXP { $$.type = NUM; $$.val = $2.val == $3.val;}

LOGICAL_OP : LPAREN AND_OPS RPAREN      { $$ = $2;}
           | LPAREN OR_OPS RPAREN       { $$ = $2;}
           | LPAREN NOT EXP RPAREN      { $$.type = BOOL; $$.val = !$3.val; }
           ;

AND_OPS  : AND_OPS EXP  { $$.type = BOOL; $$.val = $1.val && $2.val; }
         | AND_OP       { $$ = $1;}
         ;

OR_OPS   : OR_OPS EXP   { $$.type = BOOL; $$.val = $1.val || $2.val; }
         | OR_OP        { $$ = $1;}
         ;

AND_OP   : AND EXP EXP  { $$.type = BOOL; $$.val = $2.val && $3.val; }
         ;

OR_OP    : OR EXP EXP   { $$.type = BOOL; $$.val = $2.val || $3.val; }
         ;


DEF_STMT : DEFINE ID EXP
         ;

FUN_EXP  : FUN ID_LIST FUN_BODY
         ;

ID_LIST  : ID
         | ID_LIST ID
         ;

FUN_BODY : EXP
         ;

FUN_CALL : FUN_NAME PARAM_LIST
         ;

PARAM_LIST : EXP
           | PARAM_LIST EXP
           ;

FUN_NAME : ID
         ;

IF_EXP   : IF TEST_EXP THAN_EXP ELSE_EXP
         ;

TEST_EXP : EXP
         ;

THAN_EXP : EXP
         ;

ELSE_EXP : EXP
         ;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    if(strcmp(s, "type") == 0) {
        printf("Type error!");
    }
    else {
        printf("syntax error");
    }
    exit(1);
    return;
}
