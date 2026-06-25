#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    
    SymbolEntry *t_arr = insert_array_type(global, "IntArray", 1, t_int);
    CHECK(t_arr != NULL, "Failed to insert array type");
    CHECK(t_arr->entry.type_entry.type_class == ARRAY_TYPE, "Not flagged as ARRAY_TYPE");
    CHECK(t_arr->entry.type_entry.info.array.dimensions == 1, "Dimension mismatch");
    CHECK(t_arr->entry.type_entry.info.array.type == t_int, "Element type pointer mismatch");
    
    SymbolEntry *lookup = lookup_symbol_type(global, "IntArray");
    CHECK(lookup == t_arr, "Lookup returned wrong pointer for 'IntArray'");

    const char *output_file = "tests/st_arraytype.st";
    print_symbol_table(global, output_file);

    return 0;
}