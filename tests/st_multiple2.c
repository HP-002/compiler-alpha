#include <stdio.h>
#include <stdlib.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    SymbolEntry *t_bool = insert_primitive_type(global, "boolean");
    
    SymbolEntry *t_func = insert_function_type(global, "logic_func", t_int, t_bool);
    insert_function(global, "process", t_func);
    
    SymbolTable *l1 = add_scope(global, 2, 0);
    insert_variable(l1, "x", t_int, LOCAL);
    
    SymbolTable *l2 = add_scope(l1, 3, 0);
    insert_variable(l2, "y", t_bool, LOCAL);
    insert_variable(l2, "x", t_bool, LOCAL);
    
    SymbolTable *l3 = add_scope(l2, 4, 0);
    insert_variable(l3, "z", t_int, LOCAL);
    
    CHECK(lookup_symbol_type(l3, "z") == t_int, "Failed to find self");
    CHECK(lookup_symbol_type(l3, "y") == t_bool, "Failed to find parent");
    CHECK(lookup_symbol_type(l3, "x") == t_bool, "Shadowing failed, found wrong type");
    CHECK(lookup_symbol_type(l3, "process") == t_func, "Failed to find global");
    
    const char *output_file = "tests/st_multiple2.st";
    print_symbol_table(global, output_file);
    
    return 0;
}