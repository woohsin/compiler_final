%{
#include <stdio.h>
#include <stdlib.h>

// 函數與變數的聲明
void yyerror(const char *s);
int yylex();
%}

/* Token 定義 */
%token NUMBER TRUE FALSE IDENTIFIER
%token PLUS MINUS MULTIPLY DIVIDE MOD GREATER SMALLER EQUAL
%token AND OR NOT DEFINE FUN IF PRINT_NUM PRINT_BOOL
%token LPAREN RPAREN

/* 啟始規則 */
%start program

/* 優先順序與結合性 (可選) */
// %left PLUS MINUS
// %left MULTIPLY DIVIDE MOD

%%

program:
    statement_list
;

statement_list:
    statement
    | statement_list statement
;

statement:
    expression
    | definition_statement
    | print_statement
;

print_statement:
    LPAREN PRINT_NUM expression RPAREN
        { /* 在這裡實現打印數值的邏輯 */ }
    | LPAREN PRINT_BOOL expression RPAREN
        { /* 在這裡實現打印布林值的邏輯 */ }
;

expression:
    bool_val
        { /* 在這裡處理布林值的邏輯 */ }
    | number
        { /* 在這裡處理數值的邏輯 */ }
    | VARIABLE
        { /* 在這裡處理變數邏輯 */ }
    | numerical_operation
    | logical_operation
    | function_expression
    | function_call
    | if_expression
;

bool_val:
    TRUE
    | FALSE
;

number:
    NUMBER
;

numerical_operation:
    LPAREN PLUS expression_list RPAREN
    | LPAREN MINUS expression expression RPAREN
    | LPAREN MULTIPLY expression_list RPAREN
    | LPAREN DIVIDE expression expression RPAREN
    | LPAREN MOD expression expression RPAREN
    | LPAREN GREATER expression expression RPAREN
    | LPAREN SMALLER expression expression RPAREN
    | LPAREN EQUAL expression_list RPAREN
;

logical_operation:
    LPAREN AND expression_list RPAREN
    | LPAREN OR expression_list RPAREN
    | LPAREN NOT expression RPAREN
;

definition_statement:
    LPAREN DEFINE IDENTIFIER expression RPAREN
        { /* 在這裡實現變數定義邏輯 */ }
;

function_expression:
    LPAREN FUN LPAREN identifier_list RPAREN expression RPAREN
        { /* 在這裡實現函數定義邏輯 */ }
;

function_call:
    LPAREN IDENTIFIER expression_list RPAREN
        { /* 在這裡實現函數呼叫邏輯 */ }
;

if_expression:
    LPAREN IF expression expression expression RPAREN
        { /* 在這裡實現條件判斷邏輯 */ }
;

expression_list:
    expression
        { /* 初始化表達式列表 */ }
    | expression_list expression
        { /* 向表達式列表添加表達式 */ }
;

identifier_list:
    IDENTIFIER
        { /* 初始化變數列表 */ }
    | identifier_list IDENTIFIER
        { /* 向變數列表添加變數 */ }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Mini-LISP Parser\n");
    return yyparse();
}
