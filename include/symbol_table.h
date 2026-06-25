#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H 

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

/* Expose the global flag to the rest of the compiler */
extern bool debug_flag;

/* Use DEBUG_PRINT to print error and debug messages */
#define DEBUG_PRINT(...) if (debug_flag) printf(__VA_ARGS__)

/* Declarations */
typedef struct function Function;
typedef struct array Array;
typedef struct record Record;
typedef struct typeEntry TypeEntry;
typedef struct varEntry VarEntry;
typedef struct funcEntry FuncEntry;
typedef struct symbolTable SymbolTable;
typedef struct symbolEntry SymbolEntry;

/* Enums */
typedef enum {
    TYPE_ENTRY,
    VAR_ENTRY,
    FUNC_ENTRY
} EntryType;

typedef enum {
    PRIMITIVE_TYPE,
    RECORD_TYPE,
    ARRAY_TYPE,
    FUNCTION_TYPE
} TypeClass;

typedef enum {
    LOCAL,
    PARAMETER,
    TEMPORARY,
    CONSTANT,
    RECORD_MEMBER
} VariableClass;

typedef enum {
    INTEGER,
    CHARACTER,
    BOOLEAN,
    ADDRESS,
    STRING
} PrimitiveType;

typedef enum {
    FUNC_AS,
    FUNC_NORMAL
} FunctionDeclarationType;

/* Array Structure */
struct array {
    // Dimensions of the array
    int dimensions;

    // Type of the array
    SymbolEntry *type;
};

/* Record Structure */
struct record {
    /* Pointer to the symbol table with all fields */
    SymbolTable *fields;

    // Size of the record
    int size;
};

/* Function Structure */
struct function {
    // Pointer to parameter and return type
    SymbolEntry *parameter_type;
    SymbolEntry *return_type;
};

/* Type Structure  */
struct typeEntry {
    TypeClass type_class;

    union {
        Array array;
        Record record;
        Function function;
    } info;
};

/* Variable Structure */
struct varEntry {
    /* Pointer to type of the variable */
    SymbolEntry *type;

    // Variable Class - LOCAL, PARAMETER, TEMPORARY, CONSTANT, RECORD_MEMBER
    VariableClass var_class;
    
    PrimitiveType primitive_type;
    union {
        int int_v;
        char char_v;
        bool bool_v;
        void *addr_v;
        char *str_v;
    } value;

    /* Offset */
    int offset;

    // Register index
    int reg_index;
};

/* Function Structure */
struct funcEntry {
    /* Pointer to type of the variable */
    SymbolEntry *type;
    
    /*declaration type*/
    FunctionDeclarationType fdt;

    /*indices of starting and ending ir instruction*/
    int call_index;
    int end_index;

    // Function Scope
    SymbolTable *scope;
    int stack_size;
};


/* Symbol Table Structure */
struct symbolTable {
    // Current scope number
    char scope[7];

    // Head of the list of entries in the symbol table
    SymbolEntry *entry_head;

    // Pointer to the parent symbol table
    SymbolTable *parent;

    // Pointer for the all table list
    SymbolTable *all_tables;

    // Children symbol tables
    SymbolTable *children;
    // Next child in the children of the parent
    SymbolTable *next_child;
};

/* Symbol Entry Structure */
struct symbolEntry {
    // Name/Literal of the symbol
    char *name;

    // Type of the symbol - TYPE_ENTRY, VAR_ENTRY, FUNC_ENTRY
    EntryType type;

    // Entry union
    union {
        TypeEntry type_entry;
        VarEntry var_entry;
        FuncEntry func_entry;
    } entry;

    // Next entry in the symbol table
    SymbolEntry *next;
};

/* Global Symbol Table */
// extern SymbolTable *global_table;

/* Function declarations */
SymbolTable *symbol_table_init();
SymbolTable *add_scope(SymbolTable *parent, int line_num, int col_num);

// Type Insert
SymbolEntry* insert_primitive_type(SymbolTable *table, const char *name);
SymbolEntry* insert_array_type(SymbolTable *table, const char *name, int dimensions, SymbolEntry *array_type);
SymbolEntry* insert_record_type(SymbolTable *table, const char *name, SymbolTable *fields);
SymbolEntry* insert_function_type(SymbolTable *table, const char *name, SymbolEntry *parameter_type, SymbolEntry *return_type);

// Variable Insert
SymbolEntry* insert_variable(SymbolTable *table, const char *name, SymbolEntry *type, VariableClass v_class);

// Fucntion Insert
SymbolEntry* insert_function(SymbolTable *table, const char *name, SymbolEntry *type);

// Returns the entry of the symbol hierarchically up all scopes
SymbolEntry* lookup_symbol(SymbolTable *table, const char *name);
// Returns the entry of the symbol in current scope only
SymbolEntry* lookup_symbol_current_scope(SymbolTable *table, const char *name);
// Returns the type 
SymbolEntry* lookup_symbol_type(SymbolTable *table, const char *name);
// Returns the size of the Symbol
int get_entry_size(SymbolEntry *type);

// Assigns offsets to the variables in all the Symbol Tables
void assign_offsets();

// Outputs the symbol table to the given filename
void print_symbol_table(SymbolTable *global_table, const char *filename);

#endif