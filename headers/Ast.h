#ifndef LEXER_AST_H
#define LEXER_AST_H

#include "hash_table.h"

typedef enum {
    typeRoot,
    typeList,
    typeCond,
    typeId,
    typeOpr,
    typeDef,
    typeArgs,
    typeFunc,
    typeTerm,
    typeBody,
    typeRet,
    typeIvar,
    typeCall,
    typeFargs,
    typeErr
} nodeEnum;

typedef struct Ast Ast_t;

/* main list of atoms
 * get node and it's pushed to back */
struct _atom {
    Ast_t *head;
    Ast_t *tail;
};

typedef struct _atom _atom_t;

struct _list {
    Ast_t *next;
    Ast_t *val;
};
/*node of condition
 * contains: statement, body for true, and if exist else, pointer to else */
struct _if {
    Ast_t *expr;
    Ast_t *body;
    Ast_t *_else;
};

/*node of body
 * contains list of other nodes same as if, defvar, for */
struct _body {
    Ast_t *val; // defvar, expr, if/else, return
    Ast_t *next;
};
typedef struct _body _body_t;

struct _func {
    Ast_t *name;
    Ast_t *args;
    Ast_t *body;
};
typedef struct _func _func_t;

/* node of term
 * contains type and identifier */
struct _term {
    int type;
    char *id;
};
typedef struct _term _term_t;

/* node of define variable
 * contains term thath describe variable
 * and maybe node of init expr */
struct _defvar {
    int type;
    char *key;
    Ast_t *expr;
};
typedef struct _defvar _defvar_t;

/* tree of some operation; other name is expr */
struct _operation {
    int oper;
    Ast_t *left;
    Ast_t *right;
};
typedef struct _operation _oper_t;
/* node of cycle
 * contains */
struct _for {

};

/* list of args */
struct _args {
    Ast_t *var;
    Ast_t *next;
};
typedef struct _args _args_t;

struct _call {
    char *id;
    Ast_t *args;
};
typedef struct _call _call_t;

struct _fargs {
    char *id;
    Ast_t *next;
};
typedef struct _fargs _fargs_t;

typedef union {
    struct _atom atom;
    struct  _list list;
    struct _if if_;
    struct _body body;
    struct _defvar defvar;
    struct _operation oper;
    struct _term term;
    struct _for for_;
    struct _args args;
    struct _func func;
    struct _call call;
    struct _fargs fargs;
} attr_t;


struct Ast {
    nodeEnum type;
    attr_t attr;
};


Ast_t *ast_init(nodeEnum type);

Ast_t *ast_node(attr_t attr, nodeEnum type);

void ast_dfs(struct Ast *root);

Ast_t *ast_push(Ast_t *parent, Ast_t *child);

void ast_free(Ast_t *node);

char *_get_type(int type);

#endif //LEXER_AST_H
