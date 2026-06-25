#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    SymbolEntry *t_bool = insert_primitive_type(global, "boolean");
    
    SymbolEntry *v_lower = insert_variable(global, "myVar", t_int, LOCAL);
    SymbolEntry *v_upper = insert_variable(global, "MyVar", t_bool, LOCAL);
    
    CHECK(v_lower != NULL, "Failed to insert lowercase variable");
    CHECK(v_upper != NULL, "Failed to insert uppercase variable");
    
    CHECK(lookup_symbol_type(global, "myVar") == t_int, "Case sensitivity failure on lowercase lookup");
    CHECK(lookup_symbol_type(global, "MyVar") == t_bool, "Case sensitivity failure on uppercase lookup");

    const char *output_file = "tests/st_misc1.st";
    print_symbol_table(global, output_file);
    
    return 0;
}