#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    SymbolEntry *t_fmap = insert_function_type(global, "int2int", t_int, t_int);
    
    SymbolEntry *f_square = insert_function(global, "square", t_fmap);
    CHECK(f_square != NULL, "Failed to insert function");
    CHECK(f_square->type == FUNC_ENTRY, "Incorrect entry type for function");
    CHECK(f_square->entry.func_entry.type == t_fmap, "Function mapping pointer mismatch");
    
    SymbolEntry *lookup_square = lookup_symbol_type(global, "square");
    CHECK(lookup_square == t_fmap, "Lookup for function did not return its FUNCTION_TYPE entry");

    const char *output_file = "tests/st_function.st";
    print_symbol_table(global, output_file);
    
    return 0;
}