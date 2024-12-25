%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <map>
using namespace std;
map<string, int> id_map;
map<int, string> fun_id_map;
map<string, int> fun_val_map;
int fun_id = 0;
int fun_val = 0;
int in_fun = 0;
int out_fun = 0;
int yylex();
void yyerror(const char *s);
void reduce(const char *s);
%}

%union {
int ival;
char name[100];
struct {
    int type;
    int val;
    char name[100];
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
%type <unit> DEF_STMT ID_LIST FUN_CALL PARAM_LIST
%type <unit> IF_EXP FUN_BODY FUN_OP

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
          | LPAREN PRINT_BOOL EXP RPAREN { if($3.type != BOOL){ yyerror("type"); } else { printf("%s\n", ($3.val == 1 ? "#t" : "#f")); } }
          ;

EXP      : BOOL         { $$ = $1; }
         | NUM          { $$ = $1; }
         | ID           { /*printf("=============ID\n");*/
                            $$.type = NUM; 
                            if(in_fun == 0){ 
                                $$.val = id_map[$1.name]; 
                            } 
                            else if(in_fun == 1){ 
                                $$.val = fun_val_map[$1.name]; 
                                printf("ID->%s\n", fun_val_map[$1.name]);
                                out_fun++;
                                if(out_fun == fun_val){
                                    in_fun = 0;
                                    out_fun = 0;
                                    fun_val = 0;
                                    fun_id = 0;
                                }
                            } 
                        }
         | NUM_OP       { $$ = $1; }
         | LOGICAL_OP   { $$ = $1; }
         | FUN_CALL     { $$ = $1; }
         | IF_EXP       { $$ = $1; }
         ;

NUM_OP   : LPAREN PLUS_OPS RPAREN           { $$ = $2; /*printf("=============NUM_OP\n");*/ }
         | LPAREN MINUS EXP EXP RPAREN      { 
             if ($3.type == NUM && $4.type == NUM) {
                 $$.type = NUM;
                 $$.val = $3.val - $4.val;
             } else {
                 yyerror("Expect 'number' but got 'boolean'.");
             }
         }
         | LPAREN MULTIPLY_OPS RPAREN       { $$ = $2; }
         | LPAREN DIVIDE EXP EXP RPAREN     { 
             if ($3.type == NUM && $4.type == NUM) {
                 $$.type = NUM;
                 $$.val = $3.val / $4.val;
             } else {
                 yyerror("Expect 'number' but got 'boolean'.");
             }
         }
         | LPAREN MODULUS EXP EXP RPAREN    { 
             if ($3.type == NUM && $4.type == NUM) {
                 $$.type = NUM;
                 $$.val = $3.val % $4.val;
             } else {
                 yyerror("Expect 'number' but got 'boolean'.");
             }
         }
         | LPAREN GREATER EXP EXP RPAREN    { 
             if ($3.type == NUM && $4.type == NUM) {
                 $$.type = BOOL;
                 $$.val = $3.val > $4.val;
             } else {
                 yyerror("Expect 'number' but got 'boolean'.");
             }
         }
         | LPAREN SMALLER EXP EXP RPAREN    { 
             if ($3.type == NUM && $4.type == NUM) {
                 $$.type = BOOL;
                 $$.val = $3.val < $4.val;
             } else {
                 yyerror("Expect 'number' but got 'boolean'.");
             }
         }
         | LPAREN EQUAL_OPS RPAREN          { $$ = $2; }
         ;

PLUS_OPS    :PLUS_OPS EXP   { 
                    if($1.type == NUM && $2.type == NUM){
                        $$.type = NUM; 
                        $$.val = $1.val + $2.val;
                    }
                    else{
                        yyerror("Expect 'number' but got 'boolean'.");
                    }
            }
            |PLUS_OP        { $$ = $1;}
            ;

MULTIPLY_OPS:MULTIPLY_OPS EXP   { 
                    if($1.type == NUM && $2.type == NUM){
                        $$.type = NUM; 
                        $$.val = $1.val * $2.val;
                    }
                    else{
                        yyerror("Expect 'number' but got 'boolean'.");
                    }
                }
            |MULTIPLY_OP        { $$ = $1;}
            ;

EQUAL_OPS   :EQUAL_OPS EXP      { 
                    if($1.type == NUM && $2.type == NUM){
                        $$.type = BOOL; 
                        $$.val = $1.val == $2.val;
                    }
                    else{
                        yyerror("Expect 'number' but got 'boolean'.");
                    }
                }
            |EQUAL_OP           { $$ = $1;}
            ;

PLUS_OP     :PLUS EXP EXP { 
                if($2.type == NUM && $3.type == NUM){
                    $$.type = NUM;
                    $$.val = $2.val + $3.val;
                }else{
                    yyerror("Expect 'number' but got 'boolean'.");
                }
            }
MULTIPLY_OP :MULTIPLY EXP EXP { 
                if($2.type == NUM && $3.type == NUM){
                    $$.type = NUM;
                    $$.val = $2.val * $3.val;
                }else{
                    yyerror("Expect 'number' but got 'boolean'.");
                }
            }
EQUAL_OP    :EQUAL EXP EXP { 
                if($2.type == NUM && $3.type == NUM){
                    $$.type = BOOL;
                    $$.val = $2.val == $3.val;
                }else{
                    yyerror("Expect 'number' but got 'boolean'.");
                }
            }

LOGICAL_OP : LPAREN AND_OPS RPAREN      { $$ = $2; }
           | LPAREN OR_OPS RPAREN       { $$ = $2; }
           | LPAREN NOT EXP RPAREN      { 
               if ($3.type == BOOL) {
                   $$.type = BOOL;
                   $$.val = !$3.val;
               } else {
                   yyerror("Expect 'boolean' but got 'number'.");
               }
           }
           ;

AND_OPS  : AND_OPS EXP  { 
               if ($1.type == BOOL && $2.type == BOOL) {
                   $$.type = BOOL;
                   $$.val = $1.val && $2.val;
               } else {
                   yyerror("Expect 'boolean' but got 'number'.");
               }
           }
         | AND_OP       { $$ = $1; }
         ;

OR_OPS   : OR_OPS EXP   { 
               if ($1.type == BOOL && $2.type == BOOL) {
                   $$.type = BOOL;
                   $$.val = $1.val || $2.val;
               } else {
                   yyerror("Expect 'boolean' but got 'number'.");
               }
           }
         | OR_OP        { $$ = $1; }
         ;

AND_OP   : AND EXP EXP  { 
               if ($2.type == BOOL && $3.type == BOOL) {
                   $$.type = BOOL;
                   $$.val = $2.val && $3.val;
               } else {
                   yyerror("Expect 'boolean' but got 'number'.");
               }
           }
         ;

OR_OP    : OR EXP EXP   { 
               if ($2.type == BOOL && $3.type == BOOL) {
                   $$.type = BOOL;
                   $$.val = $2.val || $3.val;
               } else {
                   yyerror("Expect 'boolean' but got 'number'.");
               }
           }
         ;



DEF_STMT : LPAREN DEFINE ID EXP RPAREN    { 
            if($4.type != NUM){
                yyerror("type");
            }
            else if(id_map.count($3.name) != 0){
                printf("WARNING: Redefining is not allowed.\n");
            }
            else{
                id_map[$3.name] = $4.val;
            } 
         }
         ;

FUN_CALL : LPAREN FUN_OP PARAM_LIST RPAREN { $$ = $2;}
         ;

ID_LIST  : ID   { in_fun = 1; fun_id_map[fun_id++] = $1.name;}
         | ID_LIST ID   { fun_id_map[fun_id++] = $2.name;}
         ;
         
PARAM_LIST : EXP    { fun_val_map[fun_id_map[fun_val++]] = $1.val;}
           | PARAM_LIST EXP { fun_val_map[fun_id_map[fun_val++]] = $2.val;}
           ;

FUN_OP : LPAREN FUN LPAREN ID_LIST RPAREN FUN_BODY RPAREN { $$ = $6; }
        ;

FUN_BODY : NUM_OP   {$$ = $1;}
        ;


IF_EXP  : LPAREN IF EXP EXP EXP RPAREN  { 
             if ($3.type != BOOL) { 
                 yyerror("Expect 'boolean' but got 'number'.");
             } 
             else if ($4.type != NUM || $5.type != NUM) { 
                 yyerror("Expect 'number' but got 'boolean'.");
             } 
             else { 
                 $$ = $3.val ? $4 : $5; 
             } 
         }
         ;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    if (strcmp(s, "Expect 'number' but got 'boolean'.") == 0) {
        printf("Type Error: Expect 'number' but got 'boolean'.\n");
    }
    else if (strcmp(s, "Expect 'boolean' but got 'number'.") == 0) {
        printf("Type Error: Expect 'boolean' but got 'number'.\n");
    }
    else {
        printf("Syntax error.\n");
    }
    exit(1);
}