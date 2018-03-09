#ifndef LEXER_STRUCTS_H
#define LEXER_STRUCTS_H

#include <stdlib.h>
#include <inttypes.h>
#include <errno.h>
#include <sys/fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <zconf.h>
#include "syntax.h"

#define USE 1
#define UNUSED  0

#define SIZE_TABLE 128

enum ID {
    LEX_ERROR = 256,
    ID,
    DLM,
    OP,
    EQ,
    COMM,
    NUM
};

typedef size_t (*hash_func)(char*);

struct element {
    int8_t used;
    enum ID id;
    char *tok;
    struct element *next;
};

struct id_table {
    int8_t err;
    struct element *table;
    size_t size;
    size_t used;
    hash_func hash;
};

typedef struct id_table idt_t;

#define PRINT(TOK) printf(#TOK "(%d) \"%s\"(%d) in [%d, %d]\n", TOK, yytext, yyleng, yylineno, ++col)
#define ADD_T(TOK) if (add_token(table, yytext, TOK)) { fprintf(stderr, "cannot add tok %s\n", yytext); } /* return TOK */


#endif //LEXER_STRUCTS_H
