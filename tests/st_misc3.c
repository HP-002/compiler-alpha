#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    
    SymbolEntry *t_arr = insert_array_type(global, "EmptyArr", 0, t_int);
    CHECK(t_arr != NULL, "Failed to insert 0-dimension array");
    CHECK(t_arr->entry.type_entry.info.array.dimensions == 0, "0-dimension array corrupted");

    SymbolTable *empty_fields = add_scope(global, 3, 15);
    SymbolEntry *t_rec = insert_record_type(global, "EmptyRecord", empty_fields);
    
    CHECK(t_rec != NULL, "Failed to insert empty record");
    CHECK(t_rec->entry.type_entry.info.record.fields->entry_head == NULL, "Empty record has hallucinated fields");
    
    const char *output_file = "tests/st_misc3.st";
    print_symbol_table(global, output_file);
    
    return 0;
}