#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    
    SymbolEntry *t_int = insert_primitive_type(global, "integer");
    CHECK(t_int != NULL, "Failed to insert 'integer'");
    CHECK(strcmp(t_int->name, "integer") == 0, "Name mismatch");
    CHECK(t_int->type == TYPE_ENTRY, "Incorrect entry type");
    
    SymbolEntry *t_bool = insert_primitive_type(global, "boolean");
    CHECK(t_bool != NULL, "Failed to insert 'boolean'");
    
    SymbolEntry *t_dup = insert_primitive_type(global, "integer");
    CHECK(t_dup == NULL, "Failed to reject duplicate primitive type");
    
    SymbolEntry *lookup_t_int = lookup_symbol_type(global, "integer");
    CHECK(lookup_t_int == t_int, "Lookup returned wrong pointer for 'integer'");
    
    const char *output_file = "tests/st_primitivetype.st";
    print_symbol_table(global, output_file);

    return 0;
}