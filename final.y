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
%type <unit> NUM_OP LOGICAL_OP AND_OP OR_OP NOT_OP
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

PRINT_STMT: LPAREN PRINT_NUM EXP RPAREN { if($3.type != NUM){ yyerror("type"); } else { printf("%d\n", $3.val); } }
          | LPAREN PRINT_BOOL EXP RPAREN { if($3.type != BOOL){ yyerror("type"); } else { printf("#%c\n", ($3.val == 1 ? '#t' : '#f')); } }
          ;

EXP      : BOOL         { $$ = $1; }
         | NUM          { $$ = $1; }
         | ID           { $$ = $1; }
         | NUM_OP       
         | LOGICAL_OP   
         | FUN_EXP
         | FUN_CALL
         | IF_EXP
         ;

NUM_OP   : LPAREN PLUS EXP EXP RPAREN
         | LPAREN MINUS EXP EXP RPAREN
         | LPAREN MULTIPLY EXP EXP RPAREN
         | LPAREN DIVIDE EXP EXP RPAREN
         | LPAREN MODULUS EXP EXP RPAREN
         | LPAREN GREATER EXP EXP RPAREN
         | LPAREN SMALLER EXP EXP RPAREN
         | LPAREN EQUAL EXP EXP RPAREN
         ;

LOGICAL_OP : AND_OP EXP EXP
           | OR_OP EXP EXP
           | NOT_OP EXP
           ;

AND_OP   : AND EXP EXP
         ;

OR_OP    : OR EXP EXP
         ;

NOT_OP   : NOT EXP
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
