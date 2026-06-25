/* includes and function defs from bison and flex */
%code requires {
    #include "include/parser.h"
    #include "include/ir.h"
}

/* Use DEBUG_PRINT() macro from symbol_table.h to print debug messages */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include "include/symbol_table.h"
    #include "include/parser.h"
    #include "include/ir.h"
    #include "include/cg.h"

    extern char line_buf[2048];
    extern char err_buf[20][256];
    extern int err_count;
    extern int yylineno;
    extern int yyleng;
    extern int columnNumber;

    extern bool tc_flag;
    extern bool asc_flag;

    extern SymbolEntry *t_integer;
    extern SymbolEntry *t_address;
    extern SymbolEntry *t_boolean;
    extern SymbolEntry *t_character;
    extern SymbolEntry *t_string;

    extern SymbolTable *global_table;
    extern SymbolTable *current_table;
    void debug_log(const char *fmt, ...);

    extern int nextinstr;
    
    int yylex(void);
    void yyerror(const char *s);

    SymbolEntry *current_return_type = NULL;

    /* Built-in IR symbols for reserve/release */
    static SymbolEntry ir_reserve_entry = { .name = "reserve", .type = VAR_ENTRY };
    static SymbolEntry ir_release_entry = { .name = "release", .type = VAR_ENTRY };

    /* Returns the byte size of a type */
    static int type_byte_size(SymbolEntry *type_entry) {
        if (type_entry == NULL) return 8;
        if (type_entry == t_integer) return 4;
        if (type_entry == t_character) return 1;
        if (type_entry == t_boolean) return 1;
        if (type_entry == t_address) return 8;
        if (type_entry->type == TYPE_ENTRY) {
            /* Record, array, function types are pointers */
            return 8;
        }
        return 8;
    }

    /* Returns the total byte size of a record type */
    static int record_byte_size(SymbolEntry *record_type) {
        SymbolTable *fields = record_type->entry.type_entry.info.record.fields;
        SymbolEntry *field = fields->entry_head;
        int total = 0;
        while (field != NULL) {
            total += 8; // type_byte_size(field->entry.var_entry.type);
            field = field->next;
        }
        return total;
    }

    /* Returns the byte offset of a field within a record */
    static int field_byte_offset(SymbolEntry *record_type, const char *field_name) {
        SymbolTable *fields = record_type->entry.type_entry.info.record.fields;
        SymbolEntry *field = fields->entry_head;

        /* Collect fields (linked list is in reverse declaration order) */
        SymbolEntry *field_arr[64];
        int count = 0;
        while (field != NULL) {
            field_arr[count++] = field;
            field = field->next;
        }

        /* Iterate in declaration order (reverse of list) */
        int offset = 0;
        for (int i = count - 1; i >= 0; i--) {
            if (strcmp(field_arr[i]->name, field_name) == 0) {
                return offset;
            }
            offset += 8; // type_byte_size(field_arr[i]->entry.var_entry.type);
        }
        return -1;
    }

    /* Helper Functions */
    /* Create a new VariableInfo */
    VariableInfo *create_variable_info(const char *name, int line, int column) {
        VariableInfo *new_var = (VariableInfo *)malloc(sizeof(VariableInfo));
        new_var->name = strdup(name);
        new_var->line = line;
        new_var->column = column;
        new_var->next = NULL;
        return new_var;
    }

    /* Create a new ExpressionInfo */
    ExpressionInfo *create_expression_info(SymbolEntry *actual_type, int line, int column) {
        ExpressionInfo *new_expr = (ExpressionInfo *)malloc(sizeof(ExpressionInfo));
        new_expr->actual_type = actual_type;
        new_expr->expected_type = NULL;
        new_expr->entry = NULL;
        new_expr->true_list = NULL;
        new_expr->false_list = NULL;
        new_expr->arr_access = false;
        new_expr->arr_index = NULL;
        new_expr->is_reserve_array = false;
        new_expr->reserve_param = NULL;
        new_expr->line = line;
        new_expr->column = column;
        new_expr->next = NULL;
        return new_expr;
    }

    /* Report a type error to stderr and err_buf (only if tc_flag is set) */
    static void report_type_error(int line, int col, const char *fmt, ...) {
        report_error_ir();
        report_error_cg();
        if (!tc_flag) return;
        va_list args;
        char msg[220];
        va_start(args, fmt);
        vsnprintf(msg, sizeof(msg), fmt, args);
        va_end(args);
        fprintf(stderr, "LINE %03d:%03d** ERROR: %s\n", line, col, msg);
        if (err_count < 20) {
            snprintf(err_buf[err_count], 256, "LINE %03d:%03d** ERROR: %s", line, col, msg);
            err_count++;
        }
    }
%}


%union {
    ConstantInfo *constinfo;
    TypeInfo *tinfo;
    VariableInfo *varinfo;
    ExpressionInfo *exprinfo;
    int instr_idx;
    List *jlist;
};

/*==========Token definitions=============*/

/* identifier */
%token <tinfo> ID 101

/* type names */
%token <tinfo> T_INTEGER 201
%token <tinfo> T_ADDRESS 202
%token <tinfo> T_BOOLEAN 203
%token <tinfo> T_CHARACTER 204
%token <tinfo> T_STRING 205

/* constants (literals) */
%token <constinfo> C_INTEGER 301
%token <constinfo> C_NULL 302
%token <constinfo> C_CHARACTER 303
%token <constinfo> C_STRING 304
%token <constinfo> C_TRUE 305
%token <constinfo> C_FALSE 306

/* other keywords */
%token WHILE 401
%token IF 402
%token THEN 403
%token ELSE 404
%token TYPE 405
%token FUNCTION 406
%token RETURN 407
%token EXTERNAL 408
%token AS 409

/* punctuation - grouping */
%token L_PAREN 501
%token R_PAREN 502
%token L_BRACKET 503
%token R_BRACKET 504
%token L_BRACE 505
%token R_BRACE 506

/* punctuation - other */ 
%token SEMI_COLON 507
%token COLON 508
%token COMMA 509
%token ARROW 510

/* operators */ 
%token ADD 601
%token SUB_OR_NEG 602
%token MUL 603
%token DIV 604
%token REM 605
%token LESS_THAN 606
%token EQUAL_TO 607
%token ASSIGN 608
%token NOT 609
%token AND 610
%token OR 611
%token DOT 612
%token RESERVE 613
%token RELEASE 614

/*special*/
%token COMMENT 700
%token UNKNOWN 999

/*==========verbose error messages==========*/
%define parse.error verbose

/*=========Operator Precedence===========*/
%left OR                 
%left AND                
%left EQUAL_TO           
%left LESS_THAN          
%left ADD SUB_OR_NEG     
%left MUL DIV REM        

%precedence NOT MINUS   /*added a minus to distinguish from binary minus*/

/* Non-terminals */
%type <tinfo> type_id
%type <varinfo> parameter
%type <varinfo> idlist

%type <exprinfo> expression
%type <exprinfo> assignable
%type <exprinfo> constant
%type <exprinfo> ablock
%type <exprinfo> argument_list
%type <exprinfo> reserve_assignable

%type <instr_idx> M
%type <jlist> N

%%

/*==========GRAMMAR RULES==========*/

program:
    prototype_or_definition_list
    ;

prototype_or_definition_list:
    prototype prototype_or_definition_list
    | definition prototype_or_definition_list
    | prototype
    | definition
    | error                                                 
    ;

prototype:
    EXTERNAL FUNCTION RESERVE COLON type_id
    | EXTERNAL FUNCTION RELEASE COLON type_id
    | EXTERNAL FUNCTION ID COLON type_id
        {
            if ($5->entry == NULL) {
                // Error: Return type not found
                sprintf(err_buf[err_count], "LINE %03d:%d ** ERROR: Return type '%s' is undefined.",  $5->line, $5->column, $5->name);
                err_count++;
            } else {
                SymbolEntry *func = insert_function(current_table, $3->name, $5->entry);
                if (func == NULL) {
                    // Error: Function already defined
                    sprintf(err_buf[err_count], "LINE %03d:%d ** ERROR: Function '%s' already defined.", $3->line, $3->column, $3->name);
                    err_count++;
                } else {
                    func->entry.func_entry.call_index = -1;
                    func->entry.func_entry.end_index = -1;
                }
            }
        }
    | FUNCTION ID COLON type_id
        {
            if ($4->entry == NULL) {
                // Error: Return type not found
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Return type '%s' is undefined.", $4->line, $4->column, $4->name);
                err_count++;
            } else {
                SymbolEntry *func = insert_function(current_table, $2->name, $4->entry);
                if (func == NULL) {
                    // Error: Function already defined
                    sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Function '%s' already defined.", $2->line, $2->column, $2->name);
                    err_count++;
                } else {
                    func->entry.func_entry.call_index = -1;
                    func->entry.func_entry.end_index = -1;
                }
            }
        }
    ;

definition:
    TYPE ID COLON 
        {
            DEBUG_PRINT("Adding scope for type %s\n", $2->name);
            current_table = add_scope(current_table, yylineno, columnNumber);
        }
    dblock
        {
            SymbolTable *fields = current_table;
            current_table = current_table->parent;

            int num_elems = 0;
            SymbolEntry *curr = fields->entry_head;
            while (curr != NULL) {
                num_elems++;
                curr = curr->next;
            }
            
            // Assign offset to fields in reverse as the list is in reverse order
            // 8-byte align all elements
            curr = fields->entry_head;
            int curr_offset = (num_elems - 1) * 8;
            while (curr != NULL) {
                curr->entry.var_entry.offset = curr_offset;
                curr->entry.var_entry.var_class = RECORD_MEMBER;
                curr_offset -= 8;
                curr = curr->next;
            }

            DEBUG_PRINT("Inserting record type %s\n", $2->name);
            SymbolEntry *new_record = insert_record_type(current_table, $2->name, fields); 
            if (new_record == NULL) {
                // Error: Type already defined
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Type '%s' already defined.", $2->line, $2->column, $2->name);
                err_count++;
            } else {
                new_record->entry.type_entry.info.record.size = num_elems * 8;
            }
        }
    | TYPE ID COLON C_INTEGER ARROW type_id
        {
            if ($6->entry == NULL) {
                // Error: Type not found
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Type '%s' is undefined.", $6->line, $6->column, $6->name);
                err_count++;
            } else {
                if (insert_array_type(current_table, $2->name, $4->value.int_v, $6->entry) == NULL) {
                    // Error: Type already defined
                    sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Type '%s' already defined.", $2->line, $2->column, $2->name);
                    err_count++;
                }
            }
        }
    | TYPE ID COLON type_id ARROW type_id 
        {
            if ($4->entry == NULL) {
                // Error: Domain type not found
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Domain type '%s' is undefined.", $4->line, $4->column, $4->name);
                err_count++;
            }
            if ($6->entry == NULL) {
                // Error: Range type not found
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Range type '%s' is undefined.", $6->line, $6->column, $6->name);
                err_count++;
            }
            if ($4->entry != NULL && $6->entry != NULL) {
                if (insert_function_type(current_table, $2->name, $4->entry, $6->entry) == NULL) {
                    // Error: Type already defined
                    sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Type '%s' already defined.", $2->line, $2->column, $2->name);
                    err_count++;
                }
            }
        }
    | ID parameter ASSIGN 
        {
            debug_log("Adding scope for function %s\n", $1->name);
            current_table = add_scope(current_table, yylineno, columnNumber);
            
            SymbolEntry *t_func = lookup_symbol_type(global_table, $1->name);
            SymbolEntry *func = lookup_symbol(global_table, $1->name);

            
            if (t_func == NULL || func == NULL) {
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Function '%s' prototype not found.", $1->line, $1->column, $1->name);
                err_count++;
            } else {
                /* Prototype syntax accepts any type_id; enforce function type here. */
                if (t_func->entry.type_entry.type_class != FUNCTION_TYPE) {
                    sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Function '%s' prototype is not a function type.", $1->line, $1->column, $1->name);
                    err_count++;
                } else {
                    SymbolEntry *t_domain = t_func->entry.type_entry.info.function.parameter_type;
                    current_return_type = t_func->entry.type_entry.info.function.return_type;

                    VariableInfo *parameter = $2;

                    if (parameter->as_packed) {
                        /* With AS, multiple parameters are permitted */
                        if  (t_domain->entry.type_entry.type_class != RECORD_TYPE) {
                            report_type_error($2->line, $2->column, "'as' only permitted for record types. Actual: %s.", t_domain->name);
                        } else {
                            SymbolEntry *field = t_domain->entry.type_entry.info.record.fields->entry_head;

                            int expected_parameters = 0;
                            SymbolEntry *fields[64];
                            
                            while (field != NULL) {
                                fields[expected_parameters] = field;
                                field = field->next;
                                expected_parameters++;
                            }

                            int actual_parameters = 0;
                            VariableInfo *param = parameter;
                            while (param != NULL) {
                                actual_parameters++;
                                param = param->next;
                            }
                            if (expected_parameters != actual_parameters) {
                                report_type_error($2->line, $2->column, "Expected %d parameters. Actual: %d.", expected_parameters, actual_parameters);
                            }
                            expected_parameters--;
                            while (expected_parameters >= 0 && actual_parameters > 0) {
                                SymbolEntry *field_type = fields[expected_parameters]->entry.var_entry.type;
                                if (insert_variable(current_table, parameter->name, field_type, PARAMETER) == NULL) {
                                    report_type_error(parameter->line, parameter->column, "Parameter '%s' already defined.", parameter->name);
                                }
                                parameter = parameter->next;
                                expected_parameters--;
                                actual_parameters--;
                            }

                            SymbolEntry *func_entry = lookup_symbol(current_table, $1->name);
                            if (func_entry != NULL && func_entry->type == FUNC_ENTRY) {
                                func_entry->entry.func_entry.fdt = FUNC_AS;
                            }
                        }

                    } else {
                        /* Without AS, only one parameter is permitted */
                        if (insert_variable(current_table, parameter->name, t_domain, PARAMETER) == NULL) {
                            sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Parameter '%s' already defined.", parameter->line, parameter->column, parameter->name);
                            err_count++;
                        }
                    }
                }
                func->entry.func_entry.call_index = nextinstr;
                // Set functions scope
                func->entry.func_entry.scope = current_table;
            }
        }
    sblock
        {
            DEBUG_PRINT("Closing scope for function %s\n", $1->name);
            current_table = current_table->parent;
            current_return_type = NULL;
            SymbolEntry *func = lookup_symbol(global_table, $1->name);
            if (func != NULL) {
                func->entry.func_entry.end_index = nextinstr-1;
            }
        }
    ;

parameter:
    L_PAREN ID R_PAREN
        {
            $$ = create_variable_info($2->name, $2->line, $2->column);
            $$->as_packed = false;
        }
    | AS L_PAREN idlist R_PAREN
        {
            VariableInfo *id = $3;
            while (id != NULL) {
                id->as_packed = true;
                id = id->next;
            }
            $$ = $3;
        }
    ;

idlist:
    idlist COMMA ID
        {
            VariableInfo *new_id = create_variable_info($3->name, $3->line, $3->column);
            
            /* Append at end to preserve order */
            VariableInfo *tail = $1;
            while (tail->next != NULL) {
                tail = tail->next;
            }
            tail->next = new_id;
            $$ = $1;
        }
    | ID
        {
            $$ = create_variable_info($1->name, $1->line, $1->column);
        }
    ;

sblock:
    L_BRACE dblock statement_list R_BRACE
    | L_BRACE statement_list R_BRACE
    ;

dblock:
    L_BRACKET declaration_list R_BRACKET
    ;

declaration_list:
    declaration SEMI_COLON declaration_list
    | declaration
    | error SEMI_COLON declaration_list                    { yyerrok; }
    ;

type_id:
    T_INTEGER           { $$ = $1; $$->entry = lookup_symbol_type(current_table, $1->name); }
    | T_ADDRESS         { $$ = $1; $$->entry = lookup_symbol_type(current_table, $1->name); }
    | T_BOOLEAN         { $$ = $1; $$->entry = lookup_symbol_type(current_table, $1->name); }
    | T_CHARACTER       { $$ = $1; $$->entry = lookup_symbol_type(current_table, $1->name); }
    | T_STRING          { $$ = $1; $$->entry = lookup_symbol_type(current_table, $1->name); }
    | ID                { $$ = $1; $$->entry = lookup_symbol_type(current_table, $1->name); }
    ;

declaration:
    type_id COLON ID
        {
            if ($1->entry != NULL) {
                if (insert_variable(current_table, $3->name, $1->entry, LOCAL) == NULL) {
                    // Error: Variable already defined
                    sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Variable '%s' already defined.", $3->line, $3->column, $3->name);
                    err_count++;
                }
            } else {
                // Error: Type not found
                sprintf(err_buf[err_count], "LINE %03d:%03d** ERROR: Type '%s' is undefined.", $1->line, $1->column, $1->name);
                err_count++;
            }
        }
    ;

statement_list:
    compound_statement statement_list
    | compound_statement
    | simple_statement SEMI_COLON statement_list
    | simple_statement SEMI_COLON
    | error SEMI_COLON statement_list                      { yyerrok; }
    ;

compound_statement:
    WHILE M L_PAREN expression R_PAREN M
        {
            if ($4->actual_type != NULL && $4->actual_type != t_boolean) {
                report_type_error($4->line, $4->column, "Boolean expected. Actual type: %s", $4->actual_type->name);
            }

            backpatch($4->true_list, $6);

            DEBUG_PRINT("Adding scope for while loop\n");
            current_table = add_scope(current_table, yylineno, columnNumber);
        }
    sblock
        {
            DEBUG_PRINT("Closing scope for while loop\n");
            current_table = current_table->parent;
            
            DEBUG_PRINT("Emitting GOTO_IR\n");
            emit(GOTO_IR, NULL, NULL, NULL, $2, 0);
            backpatch($4->false_list, nextinstr);
        }
    | IF L_PAREN expression R_PAREN M THEN
        {
            if ($3->actual_type != NULL && $3->actual_type != t_boolean) {
                report_type_error($3->line, $3->column, "Boolean expected. Actual type: %s", $3->actual_type->name);
            }
            backpatch($3->true_list, $5);
            DEBUG_PRINT("Adding scope for if statement\n");
            current_table = add_scope(current_table, yylineno, columnNumber);
        }
    sblock 
        {
            DEBUG_PRINT("Closing scope for if statement\n");
            current_table = current_table->parent;
        }
    N ELSE M 
        {
            DEBUG_PRINT("Adding scope for else statement\n");
            current_table = add_scope(current_table, yylineno, columnNumber);
            backpatch($3->false_list, $12);
        }
    sblock
        {
            DEBUG_PRINT("Closing scope for else statement\n");
            current_table = current_table->parent;
            backpatch($10, nextinstr);
        }
    | 
        {
            DEBUG_PRINT("Adding scope for sblock (compund statement)\n");
            current_table = add_scope(current_table, yylineno, columnNumber);
        }
    sblock
        {
            DEBUG_PRINT("Closing scope for sblock (compund statement)\n");
            current_table = current_table->parent;
        }
    ;

simple_statement:
    assignable ASSIGN expression
        {
            // Left side decides the expected type of right side
            if ($1->actual_type != NULL && $3->actual_type != NULL && $1->actual_type != $3->actual_type) {
                TypeClass expected_type = $1->actual_type->entry.type_entry.type_class;
                // NULL can be assigned to Array or Record or Function
                if (!($3->actual_type == t_address && (expected_type == RECORD_TYPE || expected_type == ARRAY_TYPE || expected_type == FUNCTION_TYPE))) {
                    report_type_error($1->line, $1->column, "Expected %s, Actual %s.", $1->actual_type->name, $3->actual_type->name);
                }
            }
            if ($3->is_reserve_array) {
                if ($1->actual_type != NULL && $1->actual_type->entry.type_entry.type_class == RECORD_TYPE) {
                    $3->reserve_param->entry.var_entry.var_class = CONSTANT;
                    $3->reserve_param->entry.var_entry.primitive_type = INTEGER;
                    $3->reserve_param->entry.var_entry.value.int_v = 8;
                }
            }

            if ($3->actual_type != NULL && $3->actual_type == t_boolean) {
                SymbolEntry *temp_true = create_new_temp(current_table, t_boolean);
                temp_true->entry.var_entry.var_class = CONSTANT;
                temp_true->entry.var_entry.primitive_type = BOOLEAN;
                temp_true->entry.var_entry.value.bool_v = true;

                SymbolEntry *temp_false = create_new_temp(current_table, t_boolean);
                temp_false->entry.var_entry.var_class = CONSTANT;
                temp_false->entry.var_entry.primitive_type = BOOLEAN;
                temp_false->entry.var_entry.value.bool_v = false;

                backpatch($3->true_list, nextinstr);
                if ($1->arr_access) {
                    // Array Write is result[o1] = o2
                    emit(ARR_WRITE_IR, $1->arr_index, temp_true, $1->entry, -1, 0);
                } else {    
                    emit(ASSIGN_IR, temp_true, NULL, $1->entry, -1, 0);
                }
                DEBUG_PRINT("Emitting ASSIGN_IR\n");

                List *l = makeList(nextinstr);
                emit(GOTO_IR, NULL, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting GOTO_IR\n");

                backpatch($3->false_list, nextinstr);
                 if ($1->arr_access) {
                    // Array Write is result[o1] = o2
                    emit(ARR_WRITE_IR, $1->arr_index, temp_false, $1->entry, -1, 0);
                } else {    
                    emit(ASSIGN_IR, temp_false, NULL, $1->entry, -1, 0);
                }
                DEBUG_PRINT("Emitting ASSIGN_IR\n");

                backpatch(l, nextinstr);
            } else {
                if ($1->arr_access) {
                    // Array Write is result[o1] = o2
                    emit(ARR_WRITE_IR, $1->arr_index, $3->entry, $1->entry, -1, 0);
                } else {    
                    emit(ASSIGN_IR, $3->entry, NULL, $1->entry, -1, 0);
                }
                DEBUG_PRINT("Emitting ASSIGN_IR\n");
            }
        }
    | RETURN expression
        {
            if (current_return_type == NULL) {
                report_type_error($2->line, $2->column, "Return statement outside a function.");
            } else if (current_return_type != $2->actual_type) {
                if ($2->actual_type != NULL) {
                    TypeClass expected_type = current_return_type->entry.type_entry.type_class;
                    // NULL can be assigned to Array or Record or Function
                    if (!($2->actual_type == t_address && (expected_type == RECORD_TYPE || expected_type == ARRAY_TYPE || expected_type == FUNCTION_TYPE))) {
                        report_type_error($2->line, $2->column, "Expected %s, Actual %s.", current_return_type->name, $2->actual_type->name);
                    }
                }
            }

            if ($2->actual_type != NULL && $2->actual_type == t_boolean) {
                SymbolEntry *temp_true = create_new_temp(current_table, t_boolean);
                temp_true->entry.var_entry.var_class = CONSTANT;
                temp_true->entry.var_entry.primitive_type = BOOLEAN;
                temp_true->entry.var_entry.value.bool_v = true;

                SymbolEntry *temp_false = create_new_temp(current_table, t_boolean);
                temp_false->entry.var_entry.var_class = CONSTANT;
                temp_false->entry.var_entry.primitive_type = BOOLEAN;
                temp_false->entry.var_entry.value.bool_v = false;

                backpatch($2->true_list, nextinstr);
                emit(RETURN_IR, temp_true, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting RETURN_IR\n");

                backpatch($2->false_list, nextinstr);
                emit(RETURN_IR, temp_false, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting RETURN_IR\n");
            } else {
                emit(RETURN_IR, $2->entry, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting RETURN_IR\n");
            }
        }
    ;

assignable:
    ID
        {
            SymbolEntry *sym = lookup_symbol(current_table, $1->name);

            SymbolEntry *return_type = NULL;

            if (sym == NULL) {
                report_type_error($1->line, $1->column, "Variable '%s' is undefined.", $1->name);
            } else if (sym->type == VAR_ENTRY) {
                return_type = sym->entry.var_entry.type;
            } else if (sym->type == FUNC_ENTRY) {
                return_type = sym->entry.func_entry.type;
            } else {
                TypeClass return_tc = sym->entry.type_entry.type_class;

                if (return_tc == ARRAY_TYPE) {
                    return_type = sym->entry.type_entry.info.array.type;
                } else if (return_tc == RECORD_TYPE) {
                    // TODO: Record
                } else {
                    DEBUG_PRINT("Should not happen");
                }
                //fprintf(stderr, "LINE %03d:%03d** ERROR: Symbol '%s' is not a variable or function.\n", $1->line, $1->column, $1->name);
            }

            $$ = create_expression_info(return_type, $1->line, $1->column);

            $$->entry = sym;
        }
    | assignable ablock
        {
            SymbolEntry *t = $1->actual_type;

            SymbolEntry * return_type = NULL;
            SymbolEntry *ret_entry = NULL;

            if (t == NULL || t->type != TYPE_ENTRY) {
                report_type_error($1->line, $1->column, "Array Index or Function Call expected.");
                $$ = create_expression_info(return_type, $1->line, $1->column);
            } else if (t->entry.type_entry.type_class == ARRAY_TYPE) {
                /* Array Indexing */

                int actual_dimensions = 0;
                ExpressionInfo *arg = $2;
                while (arg != NULL) {
                    actual_dimensions++;
                    if (arg->actual_type != t_integer) {
                        report_type_error(arg->line, arg->column, "Integer expected. Actual type: %s", arg->actual_type->name);
                    }
                    arg = arg->next;
                }

                if (actual_dimensions != t->entry.type_entry.info.array.dimensions) {
                    report_type_error($1->line, $1->column, "Expected %d dimensions. Actual: %d.", t->entry.type_entry.info.array.dimensions, actual_dimensions);
                } else {    

                    return_type = t->entry.type_entry.info.array.type;
                    $$ = create_expression_info(return_type, $1->line, $1->column);

                    $$->arr_access = true;
                    $$->entry = $1->entry;

                    arg = $2;
                    int dimensions = t->entry.type_entry.info.array.dimensions;

                    SymbolEntry *zero = create_new_temp(current_table, t_integer);
                    zero->entry.var_entry.var_class = CONSTANT;
                    zero->entry.var_entry.primitive_type = INTEGER;
                    zero->entry.var_entry.value.int_v = 0;

                    SymbolEntry *crashfn = lookup_symbol(global_table, ".crash");
                    if (crashfn == NULL) {
                        crashfn = create_new_temp(global_table, t_address);
                        crashfn->name = strdup(".crash");
                    }
                    
                    SymbolEntry *size_1 = create_new_temp(current_table, t_integer);
                    emit(ARR_READ_IR, $1->entry, zero, size_1, -1, 0);

                    List *crash_list = makeList(nextinstr);
                    // if arg < 0, goto _(crash)_
                    emit(IFRELOP_IR, arg->entry, zero, NULL, -1, LT);

                    List *safe_list = makeList(nextinstr);
                    // if arg < size_1, got _(safe)_
                    emit(IFRELOP_IR, arg->entry, size_1, NULL, -1, LT);

                    // goto _(crash)_
                    crash_list = insertToList(crash_list, nextinstr);
                    emit(GOTO_IR, NULL, NULL, NULL, -1, 0);

                    backpatch(safe_list, nextinstr);

                    SymbolEntry *curr_index = arg->entry;
                    arg = arg->next;

                    for (int k = 2; k <= dimensions; k++) {
                        // dimension k is at index k-1
                        SymbolEntry *offset = create_new_temp(current_table, t_integer);
                        offset->entry.var_entry.var_class = CONSTANT;
                        offset->entry.var_entry.primitive_type = INTEGER;
                        offset->entry.var_entry.value.int_v = (k - 1) * 4; // integers are 4 bytes

                        // size_k = entry[offset]
                        SymbolEntry *size_k = create_new_temp(current_table, t_integer);
                        emit(ARR_READ_IR, $1->entry, offset, size_k, -1, 0);

                        // Bounds Checking
                        crash_list = insertToList(crash_list, nextinstr);
                        // if arg < size_k, goto _(crash)_
                        emit(IFRELOP_IR, arg->entry, zero, NULL, -1, LT);

                        safe_list = makeList(nextinstr);
                        // if arg < size_k, goto _(safe)_
                        emit(IFRELOP_IR, arg->entry, size_k, NULL, -1, LT);

                        crash_list = insertToList(crash_list, nextinstr);
                        emit(GOTO_IR, NULL, NULL, NULL, -1, 0);

                        backpatch(safe_list, nextinstr);

                        // t1 = curr_index * size_k
                        SymbolEntry *t1 = create_new_temp(current_table, t_integer);
                        emit(MUL_IR, curr_index, size_k, t1, -1, 0);

                        // t2 = t1 + arg
                        SymbolEntry *t2 = create_new_temp(current_table, t_integer);
                        emit(ADD_IR, t1, arg->entry, t2, -1, 0);

                        curr_index = t2;
                        arg = arg->next;
                    }

                    SymbolEntry *elem_size = create_new_temp(current_table, t_integer);
                    elem_size->entry.var_entry.var_class = CONSTANT;
                    elem_size->entry.var_entry.primitive_type = INTEGER;
                    elem_size->entry.var_entry.value.int_v = type_byte_size(return_type);

                    SymbolEntry *actual_offset = create_new_temp(current_table, t_integer);
                    emit(MUL_IR, curr_index, elem_size, actual_offset, -1, 0);

                    // Add number of dimensions
                    SymbolEntry *sizes_header = create_new_temp(current_table, t_integer);
                    sizes_header->entry.var_entry.var_class = CONSTANT;
                    sizes_header->entry.var_entry.primitive_type = INTEGER;
                    sizes_header->entry.var_entry.value.int_v = dimensions * 4; // integers are 4 bytes
                    if (dimensions % 2 == 1 && elem_size->entry.var_entry.value.int_v > 4) {
                        sizes_header->entry.var_entry.value.int_v += 4;
                    }

                    SymbolEntry *actual_index = create_new_temp(current_table, t_integer);
                    emit(ADD_IR, actual_offset, sizes_header, actual_index, -1, 0);

                    $$->arr_index = actual_index;

                    safe_list = makeList(nextinstr);
                    emit(GOTO_IR, NULL, NULL, NULL, -1, 0);

                    backpatch(crash_list, nextinstr);
                    emit(CALL_IR, crashfn, NULL, NULL, -1, 0);

                    backpatch(safe_list, nextinstr); 
                }
            } else if (t->entry.type_entry.type_class == FUNCTION_TYPE) {
                /* Function Call */
                SymbolEntry *func_entry = $1->entry;

                SymbolEntry *parameter_type = t->entry.type_entry.info.function.parameter_type;
                return_type = t->entry.type_entry.info.function.return_type;

                $$ = create_expression_info(return_type, $1->line, $1->column);

                ExpressionInfo *arg = $2;

                if (func_entry != NULL && func_entry->entry.func_entry.fdt == FUNC_AS && parameter_type->entry.type_entry.type_class == RECORD_TYPE) {
                    bool passed_whole_record = arg != NULL && arg->next == NULL && (arg->actual_type == parameter_type || arg->actual_type == t_address);

                    if (!passed_whole_record) {
                        SymbolEntry *field = parameter_type->entry.type_entry.info.record.fields->entry_head;

                        int expected_parameters = 0;
                        SymbolEntry *fields[64];
                        
                        while (field != NULL) {
                            fields[expected_parameters] = field;
                            field = field->next;
                            expected_parameters++;
                        }

                        int actual_parameters = 0;
                        ExpressionInfo *a = arg; 
                        while (a != NULL) {
                            actual_parameters++;
                            a = a->next;
                        }

                        if (expected_parameters != actual_parameters) {
                            report_type_error($1->line, $1->column, "Expected %d parameters. Actual: %d.", expected_parameters, actual_parameters);
                        } else {
                            int i = expected_parameters - 1;
                            while (i >= 0 && arg != NULL) {
                                SymbolEntry *expected_type = fields[i]->entry.var_entry.type;
                                if (expected_type != arg->actual_type) {
                                    bool null_case = (arg->actual_type == t_address) && 
                                                    (expected_type == t_address || 
                                                    (expected_type->type == TYPE_ENTRY && 
                                                    (expected_type->entry.type_entry.type_class == RECORD_TYPE || 
                                                    expected_type->entry.type_entry.type_class == ARRAY_TYPE ||
                                                    expected_type->entry.type_entry.type_class == FUNCTION_TYPE)));
                                    if (!null_case) {
                                        report_type_error(arg->line, arg->column, "Expected %s, Actual %s.", expected_type->name, arg->actual_type->name);
                                    }
                                }
                                emit(PARAM_IR, arg->entry, NULL, NULL, -1, 0);
                                arg = arg->next;
                                i--;
                            }
                        }
                    } else {
                        // Take parts of record as individual parameters
                        SymbolEntry *field = parameter_type->entry.type_entry.info.record.fields->entry_head;

                        int expected_parameters = 0;
                        SymbolEntry *fields[64];
                        
                        while (field != NULL) {
                            fields[expected_parameters] = field;
                            field = field->next;
                            expected_parameters++;
                        }

                        int i = expected_parameters - 1;
                        while (i >= 0) {
                            SymbolEntry *f = fields[i];
                            
                            // Offset of the field
                            SymbolEntry *offset_const = create_new_temp(current_table, t_integer);
                            offset_const->entry.var_entry.var_class = CONSTANT;
                            offset_const->entry.var_entry.primitive_type = INTEGER;
                            offset_const->entry.var_entry.value.int_v = f->entry.var_entry.offset;
                            
                            // Field value
                            SymbolEntry *field_val = create_new_temp(current_table, f->entry.var_entry.type);
                            emit(ARR_READ_IR, arg->entry, offset_const, field_val, -1, 0);
                            // Pass it as a parameter
                            emit(PARAM_IR, field_val, NULL, NULL, -1, 0);
                            
                            i--;
                        }
                    }
                } else {
                    /* Single argument expected */
                    int actual_parameters = 0;

                    while (arg != NULL) {
                        actual_parameters++;

                        if (actual_parameters == 1) {
                            if (parameter_type != arg->actual_type) {
                                bool null_case = (arg->actual_type == t_address) && 
                                                (parameter_type == t_address || 
                                                (parameter_type->type == TYPE_ENTRY && 
                                                (parameter_type->entry.type_entry.type_class == RECORD_TYPE || 
                                                parameter_type->entry.type_entry.type_class == ARRAY_TYPE ||
                                                parameter_type->entry.type_entry.type_class == FUNCTION_TYPE)));
                                if (!null_case) {
                                    report_type_error(arg->line, arg->column, "Expected %s, Actual %s.", parameter_type->name, arg->actual_type->name);
                                }
                            }
                        }

                        if (arg->actual_type != NULL && $2->actual_type == t_boolean) {
                            SymbolEntry *temp_true = create_new_temp(current_table, t_boolean);
                            temp_true->entry.var_entry.var_class = CONSTANT;
                            temp_true->entry.var_entry.primitive_type = BOOLEAN;
                            temp_true->entry.var_entry.value.bool_v = true;

                            SymbolEntry *temp_false = create_new_temp(current_table, t_boolean);
                            temp_false->entry.var_entry.var_class = CONSTANT;
                            temp_false->entry.var_entry.primitive_type = BOOLEAN;
                            temp_false->entry.var_entry.value.bool_v = false;

                            backpatch($2->true_list, nextinstr);
                            emit(PARAM_IR, temp_true, NULL, NULL, -1, 0);

                            List *l = makeList(nextinstr);
                            emit(GOTO_IR, NULL, NULL, NULL, -1, 0);

                            backpatch($2->false_list, nextinstr);
                            emit(PARAM_IR, temp_false, NULL, NULL, -1, 0);

                            backpatch(l, nextinstr);
                        } else {
                            emit(PARAM_IR, arg->entry, NULL, NULL, -1, 0);
                        }
                        arg = arg->next;
                    }
                    
                    if (actual_parameters != 1) {
                        report_type_error($1->line, $1->column, "Expected %d parameters. Actual: %d.", 1, actual_parameters);
                    }
                }
                ret_entry = create_new_temp(current_table, return_type);
                emit(CALL_IR, $1->entry, NULL, ret_entry, -1, 0);
                $$->entry = ret_entry;
            } else {
                report_type_error($1->line, $1->column, "Array Index or Function Call expected.");
                $$ = create_expression_info(return_type, $1->line, $1->column);
            }

        }
    | assignable DOT ID
        {
            SymbolEntry *t = $1->actual_type;
            SymbolEntry *return_type = NULL;

            if (t == NULL || t->type != TYPE_ENTRY) {
                report_type_error($1->line, $1->column, "Array dimension lookup or Record Access expected.");
            } else if (t->entry.type_entry.type_class == ARRAY_TYPE) {
                // Array Dimension Lookup
                int dimensions = t->entry.type_entry.info.array.dimensions;

                char *arg = $3->name;
                if (arg[0] == '_') {
                    char *start = arg + 1;
                    char *end;
                    int d = strtol(start, &end, 10);

                    if (start == end || *end != '\0') {
                        report_type_error($3->line, $3->column, "Invalid dimension index. Expected integer. Actual: %s.", $3->name);
                    } else if (d < 0 || d > dimensions) {
                        report_type_error($3->line, $3->column, "Array dimension out of bounds. Expected 0-%d. Actual: %d.", dimensions, d);
                    } else if (d == 0) {
                        // Return the number of dimensions
                        return_type = t_integer;
                        $$ = create_expression_info(return_type, $3->line, $3->column);
                        SymbolEntry *dim = create_new_temp(current_table, t_integer);
                        dim->entry.var_entry.var_class = CONSTANT;
                        dim->entry.var_entry.primitive_type = INTEGER;
                        dim->entry.var_entry.value.int_v = dimensions;
                        $$->entry = dim;
                    } else {
                        // Return the size of the d-th dimension
                        return_type = t_integer;
                        $$ = create_expression_info(return_type, $3->line, $3->column);
                        SymbolEntry *offset = create_new_temp(current_table, t_integer);
                        offset->entry.var_entry.var_class = CONSTANT;
                        offset->entry.var_entry.primitive_type = INTEGER;
                        offset->entry.var_entry.value.int_v = (d - 1) * 4;

                        SymbolEntry *size_d = create_new_temp(current_table, t_integer);
                        emit(ARR_READ_IR, $1->entry, offset, size_d, -1, 0);

                        $$->entry = size_d;
                    }
                } else {
                    report_type_error($3->line, $3->column, "Array dimension lookup expected.");
                    $$ = create_expression_info(return_type, $3->line, $3->column);
                }
            } else if (t->entry.type_entry.type_class == RECORD_TYPE) {
                // Record Access
                SymbolTable *fields = t->entry.type_entry.info.record.fields;
                SymbolEntry *field_entry = lookup_symbol_current_scope(fields, $3->name);

                if (field_entry == NULL) {
                    report_type_error($3->line, $3->column, "Field '%s' not found in record '%s'.", $3->name, t->name);
                    $$ = create_expression_info(return_type, $3->line, $3->column);
                } else {
                    return_type = field_entry->entry.var_entry.type;
                    $$ = create_expression_info(return_type, $3->line, $3->column);

                    int offset = field_byte_offset(t, $3->name);
                    SymbolEntry *offset_const = create_new_temp(current_table, t_integer);
                    offset_const->entry.var_entry.var_class = CONSTANT;
                    offset_const->entry.var_entry.primitive_type = INTEGER;
                    offset_const->entry.var_entry.value.int_v = offset;

                    $$->arr_access = true;
                    $$->arr_index = offset_const;
                    $$->entry = $1->entry;
                }
            } else {
                report_type_error($1->line, $1->column, "Array dimension lookup or Record Access expected.");
                $$ = create_expression_info(return_type, $3->line, $3->column);
            }

        }
    ;

constant:
    C_INTEGER
        {
            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            temp->entry.var_entry.var_class = CONSTANT;
            temp->entry.var_entry.primitive_type = INTEGER;
            temp->entry.var_entry.value.int_v = $1->value.int_v;
            $$ = create_expression_info(t_integer, $1->line, $1->column);
            $$->entry = temp;
        }
    | C_NULL
        {
            SymbolEntry *temp = create_new_temp(current_table, t_address);
            temp->entry.var_entry.var_class = CONSTANT;
            temp->entry.var_entry.primitive_type = ADDRESS;
            temp->entry.var_entry.value.addr_v = NULL;
            $$ = create_expression_info(t_address, $1->line, $1->column);
            $$->entry = temp;
        }
    | C_CHARACTER
        {
            SymbolEntry *temp = create_new_temp(current_table, t_character);
            temp->entry.var_entry.var_class = CONSTANT;
            temp->entry.var_entry.primitive_type = CHARACTER;
            temp->entry.var_entry.value.char_v = $1->value.char_v;
            $$ = create_expression_info(t_character, $1->line, $1->column);
            $$->entry = temp;
        }
    | C_STRING
        {
            SymbolEntry *temp = create_new_temp(current_table, t_string);
            temp->entry.var_entry.var_class = CONSTANT;
            temp->entry.var_entry.primitive_type = STRING;
            temp->entry.var_entry.value.str_v = $1->value.str_v;
            $$ = create_expression_info(t_string, $1->line, $1->column);
            $$->entry = temp;
        }
    | C_TRUE
        {
            SymbolEntry *temp = create_new_temp(current_table, t_boolean);
            temp->entry.var_entry.var_class = CONSTANT;
            temp->entry.var_entry.primitive_type = BOOLEAN;
            temp->entry.var_entry.value.bool_v = true;
            $$ = create_expression_info(t_boolean, $1->line, $1->column);
            $$->entry = temp;
        }
    | C_FALSE
        {
            SymbolEntry *temp = create_new_temp(current_table, t_boolean);
            temp->entry.var_entry.var_class = CONSTANT;
            temp->entry.var_entry.primitive_type = BOOLEAN;
            temp->entry.var_entry.value.bool_v = false;
            $$ = create_expression_info(t_boolean, $1->line, $1->column);
            $$->entry = temp;
        }
    ;

expression:
    constant
        {
            $$ = $1;

            if ($$->actual_type != NULL && $$->actual_type == t_boolean) {
                $$->true_list = makeList(nextinstr);
                emit(IFTRUE_IR, $$->entry, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting IFTRUE_IR\n");

                $$->false_list = makeList(nextinstr);
                emit(GOTO_IR, NULL, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting GOTO_IR\n");
            } else {
                $$->true_list = NULL;
                $$->false_list = NULL;
            }
        }
    | assignable
        {
            $$ = $1;

            if ($$->arr_access) {
                SymbolEntry *temp = create_new_temp(current_table, $$->actual_type);

                emit(ARR_READ_IR, $$->entry, $$->arr_index, temp, -1, 0);

                $$->entry = temp;
                $$->arr_access = false;
            }

            if ($$->actual_type != NULL && $$->actual_type == t_boolean) {
                $$->true_list = makeList(nextinstr);
                emit(IFTRUE_IR, $$->entry, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting IFTRUE_IR\n");

                $$->false_list = makeList(nextinstr);
                emit(GOTO_IR, NULL, NULL, NULL, -1, 0);
                DEBUG_PRINT("Emitting GOTO_IR\n");
            } else {
                $$->true_list = NULL;
                $$->false_list = NULL;
            }
        }
    | expression OR M expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_boolean) {
                report_type_error($1->line, $1->column, "Boolean expected. Actual type: %s", $1->actual_type->name);
            }
            if ($4->actual_type != NULL && $4->actual_type != t_boolean) {
                report_type_error($4->line, $4->column, "Boolean expected. Actual type: %s", $4->actual_type->name);
            }
            $$ = create_expression_info(t_boolean, $1->line, $1->column);

            // If left side is false, evaluate right side
            backpatch($1->false_list, $3);
            // If right side is also false, whole expression is false
            $$->false_list = $4->false_list;
            // If any side is true, whole expression is true
            $$->true_list = mergeList($1->true_list, $4->true_list);
        }
    | expression AND M expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_boolean) {
                report_type_error($1->line, $1->column, "Boolean expected. Actual type: %s", $1->actual_type->name);
            }
            if ($4->actual_type != NULL && $4->actual_type != t_boolean) {
                report_type_error($4->line, $4->column, "Boolean expected. Actual type: %s", $4->actual_type->name);
            }
            $$ = create_expression_info(t_boolean, $1->line, $1->column);

            // If left side is true, evaluate right side
            backpatch($1->true_list, $3);
            // If right side is true, whole expression is true
            $$->true_list = $4->true_list;
            // If any side is false, whole expression is false
            $$->false_list = mergeList($1->false_list, $4->false_list);

        }
    | expression EQUAL_TO expression
        {
            if ($1->actual_type != NULL && $3->actual_type != NULL) {
                if ($1->actual_type != $3->actual_type) {
                    if ($1->actual_type == t_address) {
                        TypeClass expected = $3->actual_type->entry.type_entry.type_class;
                        if (expected != RECORD_TYPE && expected != ARRAY_TYPE && expected != FUNCTION_TYPE) {
                            report_type_error($3->line, $3->column, "Record or Array expected. Actual: %s", $3->actual_type->name);
                        }
                    } else if ($3->actual_type == t_address) {
                        TypeClass expected = $1->actual_type->entry.type_entry.type_class;
                        if (expected != RECORD_TYPE && expected != ARRAY_TYPE && expected != FUNCTION_TYPE) {
                            report_type_error($1->line, $1->column, "Record or Array expected. Actual: %s", $1->actual_type->name);
                        }
                    } else {
                        report_type_error($1->line, $1->column, "Comparison of different types: %s and %s", $1->actual_type->name, $3->actual_type->name);
                    }
                }
            }

            $$ = create_expression_info(t_boolean, $1->line, $1->column);

            $$->true_list = makeList(nextinstr);
            emit(IFRELOP_IR, $1->entry, $3->entry, NULL, -1, EQ);
            DEBUG_PRINT("Emitting IFRELOP_IR\n");

            $$->false_list = makeList(nextinstr);
            emit(GOTO_IR, NULL, NULL, NULL, -1, 0);
            DEBUG_PRINT("Emitting GOTO_IR\n");
        }
    | expression LESS_THAN expression
        {
            if ($1->actual_type != NULL && $3->actual_type != NULL && $1->actual_type != $3->actual_type) {
                report_type_error($3->line, $3->column, "Expected %s, Actual %s.", $1->actual_type->name, $3->actual_type->name);
            } else if ($1->actual_type != NULL && $1->actual_type != t_integer && $1->actual_type != t_boolean && $1->actual_type != t_character) {
                report_type_error($1->line, $1->column, "Expected Integer, Boolean, or Character. Actual type: %s", $1->actual_type->name);
            }

            $$ = create_expression_info(t_boolean, $1->line, $1->column);

            $$->true_list = makeList(nextinstr);
            emit(IFRELOP_IR, $1->entry, $3->entry, NULL, -1, LT);
            DEBUG_PRINT("Emitting IFRELOP_IR\n");

            $$->false_list = makeList(nextinstr);
            emit(GOTO_IR, NULL, NULL, NULL, -1, 0);
            DEBUG_PRINT("Emitting GOTO_IR\n");
        }
    | expression SUB_OR_NEG expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_integer) {
                report_type_error($1->line, $1->column, "Integer expected. Actual type: %s", $1->actual_type->name);
            }
            if ($3->actual_type != NULL && $3->actual_type != t_integer) {
                report_type_error($3->line, $3->column, "Integer expected. Actual type: %s", $3->actual_type->name);
            }

            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            emit(SUB_IR, $1->entry, $3->entry, temp, -1, 0);
            DEBUG_PRINT("Emitting SUB_IR\n");

            $$ = create_expression_info(t_integer, $1->line, $1->column);
            $$->entry = temp;
        }
    | expression ADD expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_integer) {
                report_type_error($1->line, $1->column, "Integer expected. Actual type: %s", $1->actual_type->name);
            }
            if ($3->actual_type != NULL && $3->actual_type != t_integer) {
                report_type_error($3->line, $3->column, "Integer expected. Actual type: %s", $3->actual_type->name);
            }

            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            emit(ADD_IR, $1->entry, $3->entry, temp, -1, 0);
            DEBUG_PRINT("Emitting ADD_IR\n");

            $$ = create_expression_info(t_integer, $1->line, $1->column);
            $$->entry = temp;
        }
    | expression REM expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_integer) {
                report_type_error($1->line, $1->column, "Integer expected. Actual type: %s", $1->actual_type->name);
            }
            if ($3->actual_type != NULL && $3->actual_type != t_integer) {
                report_type_error($3->line, $3->column, "Integer expected. Actual type: %s", $3->actual_type->name);
            }

            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            emit(REM_IR, $1->entry, $3->entry, temp, -1, 0);
            DEBUG_PRINT("Emitting REM_IR\n");

            $$ = create_expression_info(t_integer, $1->line, $1->column);
            $$->entry = temp;
        }
    | expression DIV expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_integer) {
                report_type_error($1->line, $1->column, "Integer expected. Actual type: %s", $1->actual_type->name);
            }
            if ($3->actual_type != NULL && $3->actual_type != t_integer) {
                report_type_error($3->line, $3->column, "Integer expected. Actual type: %s", $3->actual_type->name);
            }

            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            emit(DIV_IR, $1->entry, $3->entry, temp, -1, 0);
            DEBUG_PRINT("Emitting DIV_IR\n");

            $$ = create_expression_info(t_integer, $1->line, $1->column);
            $$->entry = temp;
        }
    | expression MUL expression
        {
            if ($1->actual_type != NULL && $1->actual_type != t_integer) {
                report_type_error($1->line, $1->column, "Integer expected. Actual type: %s", $1->actual_type->name);
            }
            if ($3->actual_type != NULL && $3->actual_type != t_integer) {
                report_type_error($3->line, $3->column, "Integer expected. Actual type: %s", $3->actual_type->name);
            }

            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            emit(MUL_IR, $1->entry, $3->entry, temp, -1, 0);
            DEBUG_PRINT("Emitting MUL_IR\n");

            $$ = create_expression_info(t_integer, $1->line, $1->column);
            $$->entry = temp;
        }
    | NOT expression
        {
            if ($2->actual_type != NULL && $2->actual_type != t_boolean) {
                report_type_error($2->line, $2->column, "Boolean expected. Actual type: %s", $2->actual_type->name);
            }
            
            $$ = create_expression_info(t_boolean, $2->line, $2->column);
            
            $$->true_list = $2->false_list;
            $$->false_list = $2->true_list;
        }
    | SUB_OR_NEG expression %prec MINUS
        {
            if ($2->actual_type != NULL && $2->actual_type != t_integer) {
                report_type_error($2->line, $2->column, "Integer expected. Actual type: %s", $2->actual_type->name);
            }

            SymbolEntry *temp = create_new_temp(current_table, t_integer);
            emit(MINUS_IR, $2->entry, NULL, temp, -1, 0);
            DEBUG_PRINT("Emitting MINUS_IR\n");

            $$ = create_expression_info(t_integer, $2->line, $2->column);
            $$->entry = temp;
        }
    | RELEASE assignable
        {
            if ($2->actual_type != NULL && ($2->actual_type == t_integer || $2->actual_type == t_boolean || $2->actual_type == t_character)) {
                report_type_error($2->line, $2->column, "Address expected. Actual type: %s", $2->actual_type->name);
            }
            $$ = create_expression_info(t_address, $2->line, $2->column);

            // emit IR for param var
            emit(PARAM_IR, $2->entry, NULL, NULL, -1, 0);
            // emit IR for call $release
            emit(CALL_IR, &ir_release_entry, NULL, NULL, -1, 0);

            SymbolEntry *null_const = create_new_temp(current_table, t_address);
            null_const->entry.var_entry.var_class = CONSTANT;
            null_const->entry.var_entry.primitive_type = ADDRESS;
            null_const->entry.var_entry.value.addr_v = NULL;
            $$->entry = null_const;
        }
    | RESERVE reserve_assignable
        {
            /* Record */

            if ($2->actual_type == NULL || $2->actual_type->type != TYPE_ENTRY || $2->actual_type->entry.type_entry.type_class != RECORD_TYPE) {
                report_type_error($2->line, $2->column, "Record expected for reserve.");
            }

            $$ = create_expression_info(t_address, $2->line, $2->column);

            if ($2->actual_type != NULL && $2->actual_type->type == TYPE_ENTRY && 
                $2->actual_type->entry.type_entry.type_class == RECORD_TYPE) {

                int size = record_byte_size($2->actual_type);
                SymbolEntry *size_const = create_new_temp(current_table, t_integer);
                size_const->entry.var_entry.var_class = CONSTANT;
                size_const->entry.var_entry.primitive_type = INTEGER;
                size_const->entry.var_entry.value.int_v = size;

                emit(PARAM_IR, size_const, NULL, NULL, -1, 0);

                SymbolEntry *result = create_new_temp(current_table, t_address);
                debug_log("Emitting CALL_IR for reserve\n");
                emit(CALL_IR, &ir_reserve_entry, NULL, result, -1, 0);

                $$->entry = result;
            }
        }
    | RESERVE reserve_assignable ablock
        {
            /* Array */
            bool valid = false;

            if ($2->actual_type == NULL || $2->actual_type->type != TYPE_ENTRY || $2->actual_type->entry.type_entry.type_class != ARRAY_TYPE) {
                report_type_error($2->line, $2->column, "Expected array type for reserve.");
            } else {
                int actual_dimensions = 0;
                ExpressionInfo *arg = $3;
                while (arg != NULL) {
                    actual_dimensions++;
                    if (arg->actual_type != t_integer) {
                        report_type_error(arg->line, arg->column, "Integer expected. Actual type: %s", arg->actual_type->name);
                    }
                    arg = arg->next;
                }

                if (actual_dimensions != $2->actual_type->entry.type_entry.info.array.dimensions) {
                    report_type_error($3->line, $3->column, "Expected %d dimensions. Actual: %d.", $2->actual_type->entry.type_entry.info.array.dimensions, actual_dimensions);} else {
                    valid = true;
                }
            }

            $$ = create_expression_info(t_address, $2->line, $2->column);

            if (valid) {
                int dimensions = $2->actual_type->entry.type_entry.info.array.dimensions;
                SymbolEntry *elem_type = $2->actual_type->entry.type_entry.info.array.type;
                int elem_size = type_byte_size(elem_type);
                int header_size = dimensions * 4;
                if (dimensions % 2 == 1 && elem_size > 4) {
                    header_size += 4;
                }

                ExpressionInfo *arg = $3;
                SymbolEntry *total_count = arg->entry;
                arg = arg->next;
                while (arg != NULL) {
                    SymbolEntry *mul_result = create_new_temp(current_table, t_integer);
                    emit(MUL_IR, total_count, arg->entry, mul_result, -1, 0);
                    total_count = mul_result;
                    arg = arg->next;
                }

                // total_bytes = total_count * elem_size
                SymbolEntry *elem_size_const = create_new_temp(current_table, t_integer);
                elem_size_const->entry.var_entry.var_class = CONSTANT;
                elem_size_const->entry.var_entry.primitive_type = INTEGER;
                elem_size_const->entry.var_entry.value.int_v = elem_size;

                SymbolEntry *total_elem_bytes = create_new_temp(current_table, t_integer);
                emit(MUL_IR, total_count, elem_size_const, total_elem_bytes, -1, 0);

                // total = total_elem_bytes + header_size
                SymbolEntry *header_const = create_new_temp(current_table, t_integer);
                header_const->entry.var_entry.var_class = CONSTANT;
                header_const->entry.var_entry.primitive_type = INTEGER;
                header_const->entry.var_entry.value.int_v = header_size;

                SymbolEntry *total_bytes = create_new_temp(current_table, t_integer);
                emit(ADD_IR, total_elem_bytes, header_const, total_bytes, -1, 0);

                $$->is_reserve_array = true;
                $$->reserve_param = total_bytes;
                emit(PARAM_IR, total_bytes, NULL, NULL, -1, 0);

                SymbolEntry *result = create_new_temp(current_table, t_address);
                debug_log("Emitting CALL_IR for reserve\n");
                emit(CALL_IR, &ir_reserve_entry, NULL, result, -1, 0);

                // Store dimension sizes in memory
                arg = $3;
                for (int d = 0; d < dimensions; d++) {
                    SymbolEntry *dim_offset = create_new_temp(current_table, t_integer);
                    dim_offset->entry.var_entry.var_class = CONSTANT;
                    dim_offset->entry.var_entry.primitive_type = INTEGER;
                    dim_offset->entry.var_entry.value.int_v = d * 4;

                    emit(ARR_WRITE_IR, dim_offset, arg->entry, result, -1, 0);
                    arg = arg->next;
                }

                $$->entry = result;
            }
        }
    | L_PAREN expression R_PAREN
        {
            $$ = $2;
        }
    ;

reserve_assignable:
    ID
        {
            SymbolEntry *sym = lookup_symbol(current_table, $1->name);
            if (sym == NULL) {
                report_type_error($1->line, $1->column, "Variable '%s' is undefined.", $1->name);
                $$ = create_expression_info(NULL, $1->line, $1->column);
            } else if (sym->type != VAR_ENTRY) {
                report_type_error($1->line, $1->column, "Variable expected.");
                $$ = create_expression_info(NULL, $1->line, $1->column);
            } else {
                $$ = create_expression_info(sym->entry.var_entry.type, $1->line, $1->column);
                $$->entry = sym; 
            }
        }
    | reserve_assignable DOT ID
        {
            SymbolEntry *t = $1->actual_type;
            if (t != NULL && t->type == TYPE_ENTRY && t->entry.type_entry.type_class == RECORD_TYPE) {
                SymbolTable *fields = t->entry.type_entry.info.record.fields;
                SymbolEntry *field_entry = lookup_symbol_current_scope(fields, $3->name);
                
                if (field_entry == NULL) {
                    report_type_error($3->line, $3->column, "Field '%s' not found.", $3->name);
                    $$ = create_expression_info(NULL, $3->line, $3->column);
                } else {
                    $$ = create_expression_info(field_entry->entry.var_entry.type, $3->line, $3->column);
                }
            } else {
                report_type_error($1->line, $1->column, "Record Access expected.");
                $$ = create_expression_info(NULL, $1->line, $1->column);
            }
        }
    ;

ablock:
    L_PAREN argument_list R_PAREN
        {
            $$ = $2;
        }
    ;

argument_list:
    argument_list COMMA expression
        {
            /* Append at end to preserve order */
            ExpressionInfo *tail = $1;
            while (tail->next != NULL) {
                tail = tail->next;
            }
            tail->next = $3;
            $$ = $1;
        }
    | expression
        {
            $$ = $1;
        }
    ;

M: %empty
    {
        $$ = nextinstr;
    }
    ;

N: %empty
    {
        $$ = makeList(nextinstr);
        emit(GOTO_IR, NULL, NULL, NULL, -1, 0);
        DEBUG_PRINT("Emitting GOTO_IR\n");
    }
    
%%

void yyerror(const char *s){
    report_error_ir();
    report_error_cg();
    if (err_count < 10) {
        /* save the error message to buffer*/
        sprintf(err_buf[err_count], "LINE %03d:%d ** ERROR: %s", 
                yylineno, columnNumber-yyleng, s);
        err_count++;
        debug_log("parse error at line %d, column %d: %s", yylineno, columnNumber-yyleng, s);
    }
}
