#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    
    SymbolTable *fields_table = add_scope(global, 2, 20); 
    insert_variable(fields_table, "x", t_int, LOCAL);
    insert_variable(fields_table, "y", t_int, LOCAL);
    
    SymbolEntry *t_rec = insert_record_type(global, "Point", fields_table);
    CHECK(t_rec != NULL, "Failed to insert record type");
    CHECK(t_rec->entry.type_entry.type_class == RECORD_TYPE, "Not flagged as RECORD_TYPE");
    CHECK(t_rec->entry.type_entry.info.record.fields == fields_table, "Fields table pointer mismatch");
    
    SymbolEntry *lookup_point = lookup_symbol_type(global, "Point");
    CHECK(lookup_point == t_rec, "Lookup returned wrong pointer for 'Point'");

    const char *output_file = "tests/st_recordtype.st";
    print_symbol_table(global, output_file);
    
    return 0;
}