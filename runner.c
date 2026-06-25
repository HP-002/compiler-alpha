
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdarg.h>
#include "include/symbol_table.h"
#include "include/ir.h"
#include "include/cg.h"

int yylex(void);
int yyparse(void);

char line_buf[2048] = "";
char err_buf[10][256];
int err_count = 0;


FILE *FILE_tok = NULL;
FILE *FILE_asc = NULL;
FILE *FILE_cg = NULL;
bool compiler_debug = false;
bool cg = false;

void debug_log(const char *fmt, ...) {
    if (!compiler_debug) {
        return;
    }

    va_list args;
    va_start(args, fmt);
    fprintf(stderr, "DEBUG: ");
    vfprintf(stderr, fmt, args);
    fprintf(stderr, "\n");
    va_end(args);
}

typedef enum {
    TOKF,
    STF,
    ASCF,
    TCF,
    IRF,
    CGF,
    DEBUGF,
    HELPF,
    UNKNOWNF
} CLarg;

#define HELP_TEXT \
"HELP:\n"\
"How to run the alpha compiler:\n" \
"./alpha [options] program\n" \
"Valid options:\n" \
"-tok   output the token number, token, line number, and column number for each of the tokens to the .tok file\n" \
"-st    output the symbol table for the program to the .st file\n" \
"-asc   output the annotated source code for the program to the .asc file, including syntax errors\n" \
"-tc    run the type checker and report type errors to the .asc file\n" \
"-ir    run the intermediate representation generator, writing output to the .ir file\n" \
"-cg    run the (x86 assembly) code generator, writing output to the .s file\n" \
"-debug produce debugging messages to stderr\n" \
"-help  print this message and exit the alpha compiler\n"

CLarg parse_clarg(const char *arg); 
extern FILE *yyin;

extern SymbolTable *global_table;
SymbolTable *current_table = NULL;

/* Debug Mode */
bool debug_flag = false;
bool asc_flag = false;
bool tc_flag = false;
bool cg_flag = false;

/* Symbol table entries for primative types for type checking*/
SymbolEntry *t_integer = NULL;
SymbolEntry *t_address = NULL;
SymbolEntry *t_boolean = NULL;
SymbolEntry *t_character = NULL;
SymbolEntry *t_string = NULL;

int main(int argc, char *argv[]){
    const char *source_path = NULL;
    char *source_filename = NULL;

    bool tok_flag = false;
    bool st_flag = false;
    bool ir_flag = false;
    bool cg_flag = false;

    /* Parse command line: options start with '-', first non-option is the source path. */
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] == '-') {
            switch (parse_clarg(argv[i])) {
                case TOKF:
                    tok_flag = true;
                    break;
                case STF:
                    st_flag = true;
                    break;
                case ASCF:
                    asc_flag = true;
                    break;
                case TCF:
                    tc_flag = true;
                    break;
                case IRF:
                    ir_flag = true;
                    break;
                case CGF:
                    cg_flag = true;
                    break;
                case DEBUGF:
                    compiler_debug = true;
                    debug_log("debug mode enabled");
                    break;
                case HELPF:
                    printf(HELP_TEXT);
                    return 0;
                default:
                    fprintf(stderr, "Unknown option: %s\n", argv[i]);
                    return 1;
            }
        } else if (source_path == NULL) {
            source_path = argv[i];
        }
    }

    /* Choose input: provided file or stdin. */
    if (source_path != NULL) {
        debug_log("opening source file: %s", source_path);
        yyin = fopen(source_path, "r");
        if (yyin == NULL) {
            perror("Error opening input file");
            return 1;
        }

        /* source_filename is the same as source_path without the '.alpha' extension, added ability to work with other file extensions too */
        char *dot = strrchr(source_path, '.');
        size_t baselen = (dot && strcmp(dot, ".alpha") == 0) ? (size_t)(dot - source_path) : strlen(source_path);
        
        source_filename = malloc(baselen + 1);
        strncpy(source_filename, source_path, baselen);
        source_filename[baselen] = '\0';
    } else {
        yyin = stdin;
    }

    /* TOK Flag */
    if (tok_flag) {
        debug_log("token output enabled");
        char *tok_filename = malloc(strlen(source_filename) + strlen(".tok") + 1);
        sprintf(tok_filename, "%s.tok", source_filename);
        FILE_tok = fopen(tok_filename, "w+");
        if (FILE_tok == NULL) {
            perror("opening yyout.tok");
            return 1;
        }
        free(tok_filename);
    }

    /* ASC Flag */
    if (asc_flag) {
        debug_log("annotated source output enabled");
        char *asc_filename = malloc(strlen(source_filename) + strlen(".asc") + 1);
        sprintf(asc_filename, "%s.asc", source_filename);
        FILE_asc = fopen(asc_filename, "w+");
        if (FILE_asc == NULL) {
            perror("opening yyout.asc");
            return 1;
        }
        free(asc_filename);
    }

    /* Create the Symbol Table */
    global_table = symbol_table_init();
    current_table = global_table;

    /* Add the Primitive Types and String Type*/
    t_integer = insert_primitive_type(current_table, "integer");
    t_address = insert_primitive_type(current_table, "address");
    t_boolean = insert_primitive_type(current_table, "Boolean");
    t_character = insert_primitive_type(current_table, "character");
    t_string = insert_array_type(current_table, "string", 1, t_character);

    /* Added the parser logic, no longer looping manually but letting Bison handle it*/
    int parse_result = 0;
    if(yyin!= NULL){
        debug_log("starting parse");
        parse_result = yyparse();
        debug_log("parse completed with status: %d", parse_result);
    }

    // Assign Offsets for the variables in all the symbol table
    assign_offsets();

    /* ST Flag (moved above parsing)*/
    if(st_flag) {
        char *st_filename = malloc(strlen(source_filename) + strlen(".st") + 1);
        sprintf(st_filename, "%s.st", source_filename);
        print_symbol_table(global_table, st_filename);
        free(st_filename);
    }

    /*IR flag*/
    if (ir_flag) {
        debug_log("intermediate representation output enabled");
        char *ir_filename = malloc(strlen(source_filename) + strlen(".ir") + 1);
        sprintf(ir_filename, "%s.ir", source_filename);
        printIR(ir_filename);
        free(ir_filename);
    }

    /*CG flag*/
    if(cg_flag){
        if (!ir_flag) {
            fprintf(stderr, "Warning: -cg flag without -ir flag will not produce assembly output\n");
        } else {
            find_leaders();
            if (compiler_debug){
                print_leaders();
            }
            free(Leaders);
        
            cg = true;
            debug_log("code generation enabled");
            char *cg_filename = malloc(strlen(source_filename) + strlen(".s") + 1);
            sprintf(cg_filename, "%s.s", source_filename);
            CG(cg_filename);
            free(cg_filename);
        }
    }
  
    if(FILE_tok){
        fclose(FILE_tok);
    }

    if(FILE_asc){
        fclose(FILE_asc);
    }




    if (source_path != NULL && yyin != NULL && yyin != stdin) {
        fclose(yyin);

        free(source_filename);
        source_filename = NULL;
    }
    
    return parse_result;
}

CLarg parse_clarg(const char *arg) {
    if (strcmp(arg, "-tok") == 0)   return TOKF;
    if (strcmp(arg, "-st") == 0)    return STF;
    if (strcmp(arg, "-asc") == 0)   return ASCF;
    if (strcmp(arg, "-tc") == 0)    return TCF;
    if (strcmp(arg, "-ir") == 0)    return IRF;
    if (strcmp(arg, "-cg") == 0)    return CGF;
    if (strcmp(arg, "-debug") == 0) return DEBUGF;
    if (strcmp(arg, "-help") == 0)  return HELPF;
    return UNKNOWNF;
}
