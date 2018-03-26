%{
#include "../headers/Ast.h"
extern idt_t *table;
extern FILE *yyin;
int yylex();
void yyerror(char *err);
Ast_t *root = NULL;
char ans[1024];

attr_t attr;

%}

%token INT CHAR DOUBLE
%token IF ELSE PRINT SCAN FOR LEX_ERROR RETURN
%token ID CONST_INT CONST_DOUBLE

%union {
    int type;
    char *str;
    struct Ast *tree;
}

%type <type> INT CHAR DOUBLE TYPE
%type <str> ID CONST_INT CONST_DOUBLE
%type <tree> IF ELSE PRINT SCAN FOR RETURN
%type <tree> START ATOM DEFVAR INITVAR FUNC ARGS BODY EVALUATE EXPR TERM
%type <tree> CONST_VAR FUNC_NAME

%%

START:  ATOM { ast_push(root, $1); printf("[PROGRAM]\n");}
        | START ATOM { ast_push(root, $2); puts("[ATOM]"); }

ATOM:   FUNC { $$ = $1;  printf("[FUNC]\n");}
        | DEFVAR { $$ = $1; puts("[DEFVAR]\n"); }


DEFVAR: TYPE ID ';' { attr.defvar = (_defvar_t) {$1, $2, NULL}; $$ = ast_node(attr, typeDef); }

FUNC_NAME: TYPE ID { attr.defvar = (_defvar_t) {$1, $2, NULL}; $$ = ast_node(attr, typeDef); }

INITVAR:    TYPE ID '=' EVALUATE ';' { attr.defvar = (_defvar_t) {$1, $2, $4}; $$ = ast_node(attr, typeDef); }
        | ID '=' EVALUATE ';' { attr.defvar = (_defvar_t) {-1, $1, $3}; $$ = ast_node(attr, typeIvar); }

FUNC:   FUNC_NAME '(' ARGS ')' '{' BODY '}' { attr.func = (_func_t) {$1, $3, $6}; $$ = ast_node(attr, typeFunc); }

ARGS:   FUNC_NAME { attr.args = (_args_t) {$1, NULL}; $$ = ast_node(attr, typeArgs); puts("[ARGS]"); }
        | FUNC_NAME ',' ARGS { attr.args = (_args_t) {$1, $3}; $$ = ast_node(attr, typeArgs); }

BODY:   DEFVAR BODY { attr.body = (_body_t) {$1, $2}; $$ = ast_node(attr, typeBody); }
        | INITVAR BODY { attr.body = (_body_t) {$1, $2}; $$ = ast_node(attr, typeBody); }
        | RETURN EVALUATE ';' { attr.body = (_body_t) {$2, NULL}; $$ = ast_node(attr, typeRet);}

EVALUATE:   EXPR { $$ = $1; printf("[EVAL]\n"); }

EXPR:   TERM { $$ = $1; printf("[EXPR]\n"); }
        | EXPR '+' TERM { attr.oper = (_oper_t) {'+', $1, $3}; $$ = ast_node(attr, typeOpr);  printf("[EXPR]\n"); }
        | EXPR '-' TERM { attr.oper = (_oper_t) {'-', $1, $3}; $$ = ast_node(attr, typeOpr); printf("[EXPR]\n"); }

TERM:   CONST_VAR { $$ = $1 ; printf("[TERM]\n"); }
        | TERM '*' CONST_VAR { attr.oper = (_oper_t) {'*', $1, $3}; $$ = ast_node(attr, typeOpr); printf("[TERM]\n"); }
        | TERM '/' CONST_VAR { attr.oper = (_oper_t) {'/', $1, $3}; $$ = ast_node(attr, typeOpr); printf("[TERM]\n"); }

CONST_VAR:    CONST_INT { attr.term = (_term_t) {INT, $1}; $$ = ast_node(attr, typeTerm); }
        | CONST_DOUBLE { attr.term = (_term_t) {DOUBLE, $1}; $$ = ast_node(attr, typeTerm); }
        | ID { attr.term = (_term_t) {ID, $1}; $$ = ast_node(attr, typeTerm); }

TYPE:   INT {$$ = $1;}
        | CHAR {$$ = $1;}
        | DOUBLE {$$ = $1;}

%%


void yyerror(char *err)
{
    fprintf(stderr, "Have err [%s]\n", err);
}

int main(int argc, char **argv)
{
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            perror("Open file");
            return 1;
        }
    }
    //yydebug = 1;
    if (init_table(&table, std_hash, SIZE_TABLE)) {
        perror("Init table");
        return EXIT_FAILURE;
    }
    root = ast_init(typeRoot);
    printf("Input file is [%s]\n", (argc > 1 ? argv[1] : "stdin"));
    yyparse();
    // statistic_table(table);
    ast_dfs(root);
    free_table(table);
    ast_free(root);
    return 0;
}