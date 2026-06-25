#ifndef PARSER_H
#define PARSER_H 

#include "ir.h"
#include "symbol_table.h"


/* Constant Enums */
typedef enum {
    CINT,
    CCHAR,
    CBOOL,
    CADDR,
    CSTR
} ConstantType;

/* Constant Data */
typedef struct constantInfo {
    char *name;
    SymbolEntry *entry;

    ConstantType type;
    union {
        int int_v;
        char char_v;
        bool bool_v;
        void *addr_v;
        char *str_v;
    } value;

    int line;
    int column;
} ConstantInfo;

/* Type Data */
typedef struct typeInfo {
    char *name;
    SymbolEntry *entry;
      
    int line;
    int column;
} TypeInfo;

/* Variable Data */
typedef struct variableInfo {
    char *name;
    SymbolEntry *type;
    
    int line;
    int column;

    bool as_packed;
    struct variableInfo *next;
} VariableInfo;

typedef struct expressionInfo {
    SymbolEntry *actual_type;
    SymbolEntry *expected_type;

    // For variable, Base Array
    SymbolEntry *entry;

    // For boolean logic
    List *true_list;
    List *false_list;

    // For Array
    bool arr_access;
    SymbolEntry *arr_index;

    // For reserve ambiguity
    bool is_reserve_array;
    SymbolEntry *reserve_param;

    int line;
    int column;

    struct expressionInfo *next;
} ExpressionInfo;

#endif
