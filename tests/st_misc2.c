#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/symbol_table.h"

#define CHECK(cond, msg) if (!(cond)) { fprintf(stderr, "FAIL: %s\n", msg); exit(1); }

int main() {
    SymbolTable *global = symbol_table_init();
    
    SymbolTable *deep_scope = add_scope(global, 1234, 56);
    
    CHECK(deep_scope != NULL, "add_scope failed on large numbers");
    CHECK(strlen(deep_scope->scope) == 6, "Buffer overflow! Scope string is not null-terminated correctly");
    CHECK(strcmp(deep_scope->scope, "123405") == 0, "snprintf did not truncate the large scope ID safely");
    
    const char *output_file = "tests/st_misc2.st";
    print_symbol_table(global, output_file);
    
    return 0;
}