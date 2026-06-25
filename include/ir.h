#ifndef IR_H
#define IR_H

#include "symbol_table.h"

#define IR_ARRAY_SIZE 2048

typedef struct List {
    int index;
    struct List *next;
} List;

typedef enum Relop{
    LT,
    EQ
} relop;

typedef enum Inst_type{
    ADD_IR,
    SUB_IR,
    MUL_IR,
    DIV_IR,
    REM_IR,
    NOT_IR,
    MINUS_IR,
    ASSIGN_IR,
    IFTRUE_IR,
    IFFALSE_IR,
    IFRELOP_IR,
    GOTO_IR,
    PARAM_IR,
    CALL_IR,
    RETURN_IR,
    ARR_READ_IR,
    ARR_WRITE_IR,
    DEREF_IR,
    ADDR_IR,
    DEREF_ASS_IR
} inst_type;

/*struct for instructions*/
typedef struct Inst{
    SymbolEntry *o1;
    SymbolEntry *o2;
    SymbolEntry *result;
    relop comp;
    int jumpTarget;
    inst_type type;
    bool isLeader;
} inst;


int emit(inst_type Type, SymbolEntry *O1, SymbolEntry *O2, SymbolEntry *Result, int Target, relop Rel);
SymbolEntry *create_new_temp(SymbolTable *table, SymbolEntry *type);

List *makeList(int i);
List *mergeList(List *a, List *b);
List *insertToList(List *l, int index);
void backpatch(List *l, int target);

void report_error_ir();
void printIR(const char *filename);

void find_leaders();
void print_leaders();
int block_index_from_IR_line(int ir_line);
int block_start(int block_index);
int block_end(int block_index);


extern inst IR[IR_ARRAY_SIZE];
extern int nextinstr;
extern bool error_reported;

extern int* Leaders; // terminated with -1
extern int numberOfLeaders;


#endif
