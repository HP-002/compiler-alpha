#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    
    insert_variable(global, "global_var", t_int, LOCAL);
    
    SymbolTable *child = add_scope(global, 5, 10);
    CHECK(strcmp(child->scope, "005010") == 0, "Scope ID formatted incorrectly");
    
    insert_variable(child, "local_var", t_int, LOCAL);
    
    insert_variable(child, "global_var", t_int, LOCAL);
    
    CHECK(lookup_symbol_type(child, "local_var") == t_int, "Child cannot see its own variable");
    CHECK(lookup_symbol_type(child, "integer") == t_int, "Child cannot see global type");
    
    CHECK(lookup_symbol_type(global, "local_var") == NULL, "Global scope leaked into child scope");
    
    const char *output_file = "tests/st_scopes.st";
    print_symbol_table(global, output_file);
    
    return 0;
}