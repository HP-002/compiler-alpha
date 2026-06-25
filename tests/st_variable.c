#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    
    SymbolEntry *v_x = insert_variable(global, "x", t_int, LOCAL);
    CHECK(v_x != NULL, "Failed to insert variable");
    CHECK(v_x->type == VAR_ENTRY, "Incorrect entry type for variable");
    CHECK(v_x->entry.var_entry.var_class == LOCAL, "Variable class mismatch");
    CHECK(v_x->entry.var_entry.type == t_int, "Variable type pointer mismatch");
    
    SymbolEntry *t_dup = insert_variable(global, "x", t_int, LOCAL);
    CHECK(t_dup == NULL, "Failed to reject duplicate variable");
    
    SymbolEntry *lookup_x = lookup_symbol_type(global, "x");
    CHECK(lookup_x == t_int, "Lookup for variable did not return its TYPE entry");
    
    const char *output_file = "tests/st_variable.st";
    print_symbol_table(global, output_file);
    
    return 0;
}