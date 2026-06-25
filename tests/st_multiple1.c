#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    SymbolEntry *t_arr = insert_array_type(global, "IntArr", 2, t_int);
    
    SymbolTable *rec_fields = symbol_table_init();
    insert_variable(rec_fields, "id", t_int, LOCAL);
    insert_variable(rec_fields, "data", t_arr, LOCAL);
    SymbolEntry *t_rec = insert_record_type(global, "DataRecord", rec_fields);
    
    SymbolTable *func_scope = add_scope(global, 10, 5);
    SymbolEntry *v_rec = insert_variable(func_scope, "my_record", t_rec, PARAMETER);
    
    CHECK(v_rec != NULL, "Failed to insert complex variable");
    CHECK(lookup_symbol_type(func_scope, "my_record") == t_rec, "Lookup failed");
    
    const char *output_file = "tests/st_multiple1.st";
    print_symbol_table(global, output_file);
    
    return 0;
}