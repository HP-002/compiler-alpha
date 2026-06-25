#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    SymbolEntry *t_bool = insert_primitive_type(global, "boolean");
    
    SymbolEntry *t_func = insert_function_type(global, "int2bool", t_int, t_bool);
    CHECK(t_func != NULL, "Failed to insert function type");
    CHECK(t_func->entry.type_entry.type_class == FUNCTION_TYPE, "Not flagged as FUNCTION_TYPE");
    CHECK(t_func->entry.type_entry.info.function.parameter_type == t_int, "Parameter mismatch");
    CHECK(t_func->entry.type_entry.info.function.return_type == t_bool, "Return mismatch");
    
    const char *output_file = "tests/st_functiontype.st";
    print_symbol_table(global, output_file);
    
    return 0;
}