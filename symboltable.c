#include "include/symbol_table.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Function declarations
void print_symbol_entry(SymbolEntry *entry, char *current_scope, char *parent_scope, FILE *file);

// Assigns offsets to the variables in all the Symbol Tables of the function. Returns the deepest offset.
int assign_offsets_to_table(SymbolTable *table, int start_offset);

/* Globals */
// Global ST (Scope: 001001)
SymbolTable *global_table = NULL;
// Tail of the all table list
SymbolTable *all_tables_tail = NULL;

/* Initializes the first global symbol table with scope 001001 and returns the pointer */
SymbolTable *symbol_table_init() {
    SymbolTable *global_table = (SymbolTable *)malloc(sizeof(SymbolTable));
    if (!global_table) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for global SymbolTable.\n");
        exit(EXIT_FAILURE);
    }

    global_table->parent = NULL;
    global_table->entry_head = NULL;
    global_table->all_tables = NULL;
    global_table->children = NULL;
    global_table->next_child = NULL;
    
    /* The global scope is strictly defined as "001001" */
    strncpy(global_table->scope, "001001", 7);

    // Set the current table same as the global at the start
    all_tables_tail = global_table;

    return global_table;
}

/* Adds a new table under the parent and returns a pointer to the new table */
SymbolTable *add_scope(SymbolTable *parent, int line_num, int col_num) {
    SymbolTable *new_table = (SymbolTable *)malloc(sizeof(SymbolTable));
    if (!new_table) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for local SymbolTable.\n");
        exit(EXIT_FAILURE);
    }

    // Set the parent
    new_table->parent = parent;
    new_table->entry_head = NULL;
    new_table->all_tables = NULL;
    // Set the scope
    snprintf(new_table->scope, 7, "%03d%03d", line_num, col_num);

    // Add the new table to the all table list
    all_tables_tail->all_tables = new_table;
    all_tables_tail = new_table;

    // Set the children and next child to NULL
    new_table->children = NULL;
    new_table->next_child = NULL;
    // Add to the children list of the parent
    if (parent != NULL) {
        if (parent->children == NULL) {
            parent->children = new_table;
        } else {
            SymbolTable *children_tail = parent->children;
            while (children_tail->next_child != NULL) {
                children_tail = children_tail->next_child;
            }
            children_tail->next_child = new_table;
        }
    }
    
    return new_table;
}

/* Inserts a primitive type into the symbol table */
SymbolEntry* insert_primitive_type(SymbolTable *table, const char *name) {
    // Check for duplicate entries in the same scope
    SymbolEntry *current = table->entry_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // fprintf(stderr, "Semantic Error: Symbol '%s' has already been declared in this scope.\n", name);
            return NULL; 
        }
        current = current->next;
    }

    // Create new entry
    SymbolEntry *new_entry = (SymbolEntry *)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for primitive type '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    // Set the name and entry
    new_entry->name = strdup(name); 
    new_entry->type = TYPE_ENTRY;

    // the info union is ignored for primitive types
    new_entry->entry.type_entry.type_class = PRIMITIVE_TYPE;
    
    // Insert the entry in the current scope ST
    new_entry->next = table->entry_head;
    table->entry_head = new_entry;

    return new_entry;
}

/* Inserts an array into the symbol table */
SymbolEntry* insert_array_type(SymbolTable *table, const char *name, int dimensions, SymbolEntry *array_type) {
    // Check for duplicate entries in the same scope
    SymbolEntry *current = table->entry_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // fprintf(stderr, "Semantic Error: Symbol '%s' has already been declared in this scope.\n", name);
            return NULL; 
        }
        current = current->next;
    }

    // Create new entry
    SymbolEntry *new_entry = (SymbolEntry *)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for array type '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    // Set the name and entry
    new_entry->name = strdup(name); 
    new_entry->type = TYPE_ENTRY;

    // Set the properties
    new_entry->entry.type_entry.type_class = ARRAY_TYPE;
    new_entry->entry.type_entry.info.array.dimensions = dimensions;
    new_entry->entry.type_entry.info.array.type = array_type;
    
    // Insert the entry in the current scope ST
    new_entry->next = table->entry_head;
    table->entry_head = new_entry;

    return new_entry;
}

/* Inserts a record into the symbol table */
SymbolEntry* insert_record_type(SymbolTable *table, const char *name, SymbolTable *fields) {
    // Check for duplicate entries in the same scope
    SymbolEntry *current = table->entry_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // fprintf(stderr, "Semantic Error: Symbol '%s' has already been declared in this scope.\n", name);
            return NULL; 
        }
        current = current->next;
    }

    // Create new entry
    SymbolEntry *new_entry = (SymbolEntry *)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for record type '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    // Set the name and entry
    new_entry->name = strdup(name); 
    new_entry->type = TYPE_ENTRY;

    // Set the properties
    new_entry->entry.type_entry.type_class = RECORD_TYPE;
    new_entry->entry.type_entry.info.record.fields = fields;
    
    // Insert the entry in the current scope ST
    new_entry->next = table->entry_head;
    table->entry_head = new_entry;

    return new_entry;
}

/* Inserts a function type into the symbol table */
SymbolEntry* insert_function_type(SymbolTable *table, const char *name, SymbolEntry *parameter_type, SymbolEntry *return_type) {
    // Check for duplicate entries in the same scope
    SymbolEntry *current = table->entry_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // fprintf(stderr, "Semantic Error: Symbol '%s' has already been declared in this scope.\n", name);
            return NULL; 
        }
        current = current->next;
    }

    // Create new entry
    SymbolEntry *new_entry = (SymbolEntry *)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for function type '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    // Set the name and entry
    new_entry->name = strdup(name); 
    new_entry->type = TYPE_ENTRY;

    // Set the properties
    new_entry->entry.type_entry.type_class = FUNCTION_TYPE;
    new_entry->entry.type_entry.info.function.parameter_type = parameter_type;
    new_entry->entry.type_entry.info.function.return_type = return_type;
    
    // Insert the entry in the current scope ST
    new_entry->next = table->entry_head;
    table->entry_head = new_entry;

    return new_entry;
}

/* Inserts a variable into the symbol table */
SymbolEntry* insert_variable(SymbolTable *table, const char *name, SymbolEntry *var_type, VariableClass v_class) {
    SymbolEntry *current = table->entry_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // fprintf(stderr, "Semantic Error: Variable '%s' has already been declared in this scope.\n", name);
            return NULL; 
        }
        current = current->next;
    }

    // Create new entry
    SymbolEntry *new_entry = (SymbolEntry *)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for variable '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    // Set the name
    new_entry->name = strdup(name); 
    
    // Set the entry type as VAR_ENTRY
    new_entry->type = VAR_ENTRY;

    // Set the properties
    new_entry->entry.var_entry.type = var_type;
    new_entry->entry.var_entry.var_class = v_class;
    
    // Offset initialized to 0, tbd
    new_entry->entry.var_entry.offset = 0;
    new_entry->entry.var_entry.reg_index = -1;
    
    // Insert the entry in the current scope ST
    new_entry->next = table->entry_head;
    table->entry_head = new_entry;

    return new_entry;
}

/* Inserts a function into the symbol table */
SymbolEntry* insert_function(SymbolTable *table, const char *name, SymbolEntry *type) {
    // Check for duplicate in current scope
    SymbolEntry *current = table->entry_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // fprintf(stderr, "Semantic Error: Function '%s' has already been declared in this scope.\n", name);
            return NULL; 
        }
        current = current->next;
    }

    // Create new entry
    SymbolEntry *new_entry = (SymbolEntry *)malloc(sizeof(SymbolEntry));
    if (new_entry == NULL) {
        DEBUG_PRINT("Fatal Error: Memory allocation failed for function '%s'.\n", name);
        exit(EXIT_FAILURE);
    }

    // Set the name and entry
    new_entry->name = strdup(name); 
    new_entry->type = FUNC_ENTRY;

    // Set the properties
    new_entry->entry.func_entry.type = type;
    new_entry->entry.func_entry.fdt = FUNC_NORMAL;
    new_entry->entry.func_entry.scope = NULL;
    new_entry->entry.func_entry.call_index = -1;
    new_entry->entry.func_entry.end_index = -1;
    new_entry->entry.func_entry.stack_size = 0;

    // Insert the entry in the current scope ST
    new_entry->next = table->entry_head;
    table->entry_head = new_entry;

    return new_entry;
}

/* Returns the entry of the symbol hierarchically up all scopes */
SymbolEntry* lookup_symbol(SymbolTable *table, const char *name) {
    SymbolTable *current_table = table;

    // Go up the scope hierarchy
    while (current_table != NULL) {
        SymbolEntry *current_entry = current_table->entry_head;

        // Search the linked list of the current scope
        while (current_entry != NULL) {
            if (strcmp(current_entry->name, name) == 0) {
                // Symbol found
                return current_entry;
            }
            current_entry = current_entry->next;
        }

        // symbol not found. Move up the parent
        current_table = current_table->parent;
    }

    // Symbol does not exist in any valid scope
    return NULL;
}

/* Returns the entry of the symbol in given scope only */
SymbolEntry* lookup_symbol_current_scope(SymbolTable *table, const char *name) {
    SymbolEntry *current_entry = table->entry_head;

    // Search the linked list of the given scope
    while (current_entry != NULL) {
        if (strcmp(current_entry->name, name) == 0) {
            // Symbol found
            return current_entry;
        }
        current_entry = current_entry->next;
    }

    // Symbol does not exist in the given scope
    return NULL;
}

/* Returns the type of the symbol */
SymbolEntry* lookup_symbol_type(SymbolTable *table, const char *name) {
    SymbolTable *current_table = table;

    // Go up the scope hierarchy
    while (current_table != NULL) {
        SymbolEntry *current_entry = current_table->entry_head;

        // Search the linked list of the current scope
        while (current_entry != NULL) {
            if (strcmp(current_entry->name, name) == 0) {
                
                // Symbol found. Return its TYPE pointer
                if (current_entry->type == VAR_ENTRY) {
                    return current_entry->entry.var_entry.type;
                    
                } else if (current_entry->type == FUNC_ENTRY) {
                    return current_entry->entry.func_entry.type;
                    
                } else if (current_entry->type == TYPE_ENTRY) {
                    // the symbol itself is a type
                    return current_entry; 
                }
            }
            current_entry = current_entry->next;
        }

        // symbol not found. Move up the parent
        current_table = current_table->parent;
    }

    // Symbol does not exist in any valid scope
    return NULL;
}

/* Prints the symbol table to the given filename */
void print_symbol_table(SymbolTable *global_table, const char *filename) {
    // Open the file
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        DEBUG_PRINT("Fatal Error: Could not open file '%s' for writing.\n", filename);
        exit(EXIT_FAILURE);
    }

    fprintf(file, "NAME             : SCOPE  : PARENT : TYPE                 : Extra annotation\n");
    fprintf(file, "-----------------:--------:--------:----------------------:-----------------------------\n");

    // Print the symbol table
    SymbolTable *current_table = global_table;

    while (current_table != NULL) {
        // Go through all the entries in the current table
        SymbolEntry *current_entry = current_table->entry_head;

        // Get parent scope
        char *parent_scope = (current_table->parent != NULL) ? current_table->parent->scope : NULL;

        while (current_entry != NULL) {
            // Print the entry
            print_symbol_entry(current_entry,current_table->scope, parent_scope, file);
            current_entry = current_entry->next;
        }
        fprintf(file, "-----------------:--------:--------:----------------------:-----------------------------\n");

        current_table = current_table->all_tables;
    }

    // Close the file
    fclose(file);
}

/* Prints the symbol entry */
void print_symbol_entry(SymbolEntry *entry, char *current_scope, char *parent_scope, FILE *file) {
    char type_str[50] = {0};
    char extra_str[100] = {0};

    if (entry->type == VAR_ENTRY) {
        // Variables - Name, Scope:Parent, Type, Extra
        if (entry->entry.var_entry.type != NULL) {
            snprintf(type_str, sizeof(type_str), "%s", entry->entry.var_entry.type->name);
        } else {
            snprintf(type_str, sizeof(type_str), "UNKNOWN");
        }
        
        switch (entry->entry.var_entry.var_class) {
            case LOCAL:
                snprintf(extra_str, sizeof(extra_str), "local, stack-offset: %d", entry->entry.var_entry.offset);
                break;
            case PARAMETER:
                snprintf(extra_str, sizeof(extra_str), "parameter, stack-offset: %d", entry->entry.var_entry.offset);
                break;
            case TEMPORARY:
                snprintf(extra_str, sizeof(extra_str), "temporary, stack-offset: %d", entry->entry.var_entry.offset);
                break;
            case RECORD_MEMBER:
                snprintf(extra_str, sizeof(extra_str), "record member, rec-offset: %d", entry->entry.var_entry.offset);
                break;
            case CONSTANT:
                switch (entry->entry.var_entry.primitive_type) {
                    case INTEGER:
                        snprintf(extra_str, sizeof(extra_str), "constant, val: %d", entry->entry.var_entry.value.int_v);
                        break;
                    case CHARACTER:
                        if(entry->entry.var_entry.value.char_v == '\n'){
                            snprintf(extra_str, sizeof(extra_str), "constant, val: '\\n'");
                            break;
                        }
                        snprintf(extra_str, sizeof(extra_str), "constant, val: '%c'", entry->entry.var_entry.value.char_v);
                        break;
                    case BOOLEAN:
                        snprintf(extra_str, sizeof(extra_str), "constant, val: %s", entry->entry.var_entry.value.bool_v ? "true" : "false");
                        break;
                    case STRING:
                        snprintf(extra_str, sizeof(extra_str), "constant, val: \"%s\"", 
                                entry->entry.var_entry.value.str_v ? entry->entry.var_entry.value.str_v : "");
                        break;
                    case ADDRESS:
                        if (entry->entry.var_entry.value.addr_v == NULL) {
                            snprintf(extra_str, sizeof(extra_str), "constant, val: NULL");
                        } else {
                            snprintf(extra_str, sizeof(extra_str), "constant, val: %p", entry->entry.var_entry.value.addr_v);
                        }
                        break;
                    default:
                        snprintf(extra_str, sizeof(extra_str), "constant");
                        break;
                }
                break;
        }

    } 
    else if (entry->type == FUNC_ENTRY) {
        if (entry->entry.func_entry.type != NULL) {
            snprintf(type_str, sizeof(type_str), "%s", entry->entry.func_entry.type->name);
        } else {
            snprintf(type_str, sizeof(type_str), "UNKNOWN");
        }
        snprintf(extra_str, sizeof(extra_str), "function, start: %d, end: %d, stack-size: %d", entry->entry.func_entry.call_index, entry->entry.func_entry.end_index, entry->entry.func_entry.stack_size);
    } 
    else if (entry->type == TYPE_ENTRY) {
        switch (entry->entry.type_entry.type_class) {
            case PRIMITIVE_TYPE:
                snprintf(type_str, sizeof(type_str), "primitive"); 
                break;
                
            case ARRAY_TYPE:
                snprintf(type_str, sizeof(type_str), "%d -> %s", 
                    entry->entry.type_entry.info.array.dimensions,
                    entry->entry.type_entry.info.array.type ? entry->entry.type_entry.info.array.type->name : "UNKNOWN");
                break;
                
            case RECORD_TYPE:
                snprintf(type_str, sizeof(type_str), "record");
                break;
                
            case FUNCTION_TYPE:
                snprintf(type_str, sizeof(type_str), "%s -> %s", 
                    entry->entry.type_entry.info.function.parameter_type ? entry->entry.type_entry.info.function.parameter_type->name : "UNKNOWN",
                    entry->entry.type_entry.info.function.return_type ? entry->entry.type_entry.info.function.return_type->name : "UNKNOWN");
                break;
        }
        if (entry->entry.type_entry.type_class == RECORD_TYPE) {
            snprintf(extra_str, sizeof(extra_str), "type declaration, size: %d", get_entry_size(entry));
        } else {
            snprintf(extra_str, sizeof(extra_str), "type declaration");
        }
    }

    fprintf(file, "%-17s: %-6s   : %-6s   : %-20s   : %s\n",
            entry->name,
            current_scope,
            parent_scope ? parent_scope : "", // Handle global scope parent being NULL
            type_str,
            extra_str);
}

// Returns the size of the Symbol
int get_entry_size(SymbolEntry *type_entry) {
    if (type_entry == NULL || type_entry->type != TYPE_ENTRY) {
        return 0;
    }
    
    switch (type_entry->entry.type_entry.type_class) {
        case PRIMITIVE_TYPE:
            if (strcmp(type_entry->name, "integer") == 0) {
                return 4;
            } else if (strcmp(type_entry->name, "character") == 0) {
                return 1;
            } else if (strcmp(type_entry->name, "Boolean") == 0) {
                return 1;
            } else if (strcmp(type_entry->name, "address") == 0) {
                return 8;
            } else {
                return 8; // Unknown
            }

        case RECORD_TYPE:
            return type_entry->entry.type_entry.info.record.size;

        case ARRAY_TYPE:
            return 8;

        default:
            return 8;
    }

}

// Assigns offsets to the variables in all the Symbol Tables
void assign_offsets() {
    SymbolEntry *f = global_table->entry_head;

    while (f != NULL) {
        if (f->type == FUNC_ENTRY && f->entry.func_entry.scope != NULL) {
            f->entry.func_entry.stack_size = assign_offsets_to_table(f->entry.func_entry.scope, -8) + 8;
        }
        f = f->next;
    }
}

// Assigns offsets to the variables in all the Symbol Tables of the function. Returns the deepest offset.
int assign_offsets_to_table(SymbolTable *table, int start_offset) {
    int curr_offset = start_offset;

    // Skip return address and old base pointer
    int parameter_offset = 16;
    // Parameters are at positive offsets
    SymbolEntry *param = table->entry_head;
    while (param != NULL) {
        if (param->entry.var_entry.var_class == PARAMETER) {
            param->entry.var_entry.offset = parameter_offset;
            parameter_offset += 8;
        }
        param = param->next;
    }

    // Set negative offsets for locals and temps
    SymbolEntry *variable = table->entry_head;
    while (variable != NULL) {
        if (variable->type == VAR_ENTRY && variable->entry.var_entry.var_class != PARAMETER
        && variable->entry.var_entry.var_class != CONSTANT) {
            variable->entry.var_entry.offset = curr_offset;
            curr_offset -= 8;
        }
        variable = variable->next;
    }

    int max_depth = curr_offset;
    for (SymbolTable *child = table->children; child != NULL; child = child->next_child) {
        int d = assign_offsets_to_table(child, curr_offset);
        max_depth = max_depth < d ? d : max_depth;
    }

    return max_depth;
}