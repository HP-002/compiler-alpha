#include "include/ir.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

inst IR[IR_ARRAY_SIZE];
int nextinstr = 0;
int temp_varaible_count = 0;
bool error_reported = false;

int* Leaders;
int numberOfLeaders = 0;

char buffer[128];

void init_ir() {
  nextinstr = 0;
  temp_varaible_count = 0;
  error_reported = false;
}

int emit(inst_type Type, SymbolEntry *O1, SymbolEntry *O2, SymbolEntry *Result, int Target, relop Rel) {
  
  if (error_reported) {
    return -1;
  }

  if (nextinstr >= IR_ARRAY_SIZE) {
    fprintf(stderr, "ERROR: IR array overflow.\n");
    exit(1);
  }

  IR[nextinstr].type = Type;
  IR[nextinstr].o1 = O1;
  IR[nextinstr].o2 = O2;
  IR[nextinstr].result = Result;
  IR[nextinstr].jumpTarget = Target;
  IR[nextinstr].comp = Rel;
  IR[nextinstr].isLeader = false;

  return nextinstr++;
}

/* Creates a new list containing only index i  */
List *makeList(int i) {
  List *n = (List *)malloc(sizeof(List));
  if (!n) {
    fprintf(stderr, "Error: Memory allocation failed for makelist.\n");
    exit(1);
  }
  n->index = i;
  n->next = NULL;
  return n;
}

List *mergeList(List *a, List *b) {
  if (a == NULL)
    return b;
  if (b == NULL)
    return a;

  List *tail = a;
  while (tail->next != NULL) {
    tail = tail->next;
  }
  tail->next = b;

  return a;
}

List *insertToList(List *l, int index) {
  List *n = (List *)malloc(sizeof(List));
  if (!n) {
    fprintf(stderr, "Error: Memory allocation failed for insertToList.\n");
    exit(1);
  }
  n->index = index;
  n->next = l;
  return n;
}

void backpatch(List *l, int target) {
  if (error_reported) {
    return;
  }

  while (l != NULL) {
    IR[l->index].jumpTarget = target;
    l = l->next;
  }
}

SymbolEntry *create_new_temp(SymbolTable *table, SymbolEntry *type) {
  char temp_variable_name[32];
  sprintf(temp_variable_name, "$temp%d", temp_varaible_count++);

  SymbolEntry *temp_variable_entry = insert_variable(table, temp_variable_name, type, TEMPORARY);
  return temp_variable_entry;
}

char *resolve_variable(SymbolEntry *e) {
  if (e == NULL) {
    char *name = (char *)malloc(8);
    if (name) sprintf(name, "UNKNOWN");
    return name;
  }
  int cap = 256;
  if (e->name != NULL) {
    int nl = strlen(e->name) + 1;
    if (nl > cap) cap = nl;
  }
  char *name = (char *)malloc(cap);
  if (name == NULL) {
    return NULL;
  }

  if (e->type == VAR_ENTRY && e->entry.var_entry.var_class == CONSTANT) {
    switch (e->entry.var_entry.primitive_type) {
      case INTEGER:
        sprintf(name, "%d", e->entry.var_entry.value.int_v);  
        break;
      case CHARACTER:
        sprintf(name, "%c", e->entry.var_entry.value.char_v);  
        break;
      case BOOLEAN:
        if (e->entry.var_entry.value.bool_v) {
          sprintf(name, "true");
        } else {
          sprintf(name, "false");
        }
        break;
      case ADDRESS:
        if (e->entry.var_entry.value.addr_v == NULL) {
          sprintf(name, "null");
        } else {
          sprintf(name, "%p", e->entry.var_entry.value.addr_v);  
        }
        break;
      default:
        sprintf(name, "%s", e->name);  
        break;
    }
  } else {
    sprintf(name, "%s", e->name);
  }

  return name;
}

void print_instruction(inst *i, FILE *file) {
  if (i == NULL || file == NULL)
    return;

  char *o1 = resolve_variable(i->o1);
  char *o2 = resolve_variable(i->o2);
  char *result = resolve_variable(i->result);

  switch (i->type) {
  case ADD_IR:
    sprintf(buffer, "%s = %s + %s", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;

  case SUB_IR:
    sprintf(buffer, "%s = %s - %s", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;
  
  case MUL_IR:
    sprintf(buffer, "%s = %s * %s", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;
  case DIV_IR:
    sprintf(buffer, "%s = %s / %s", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;
  case REM_IR:
    sprintf(buffer, "%s = %s %% %s", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;
  case NOT_IR:
    sprintf(buffer, "%s = ! %s", result, o1);
    fprintf(file, "%s", buffer);
    break;
  case MINUS_IR:
    sprintf(buffer, "%s = - %s", result, o1);
    fprintf(file, "%s", buffer);
    break;
  case ASSIGN_IR:
    sprintf(buffer, "%s = %s", result, o1);
    fprintf(file, "%s", buffer);
    break;
    case IFTRUE_IR:
    sprintf(buffer, "if %s goto %d", o1, i->jumpTarget);
    fprintf(file, "%s", buffer);
    break;
  case IFFALSE_IR:
    sprintf(buffer, "if False %s goto %d", o1, i->jumpTarget);
    fprintf(file, "%s", buffer);
    break;
  case IFRELOP_IR:
    sprintf(buffer, "if %s %s %s goto %d", o1, (i->comp == LT) ? "<" : "=", o2, i->jumpTarget);
    fprintf(file, "%s", buffer);
    break;
  case GOTO_IR:
    fprintf(file, "goto %d", i->jumpTarget);
    break;
  case PARAM_IR:
    if(o1[0] =='\n'){
      sprintf(buffer, "param '\\n'");
      fprintf(file, "%s", buffer);
      break;
    }
    else{
      sprintf(buffer, "param %s", o1);
      fprintf(file, "%s", buffer);
      break;
    }
  case CALL_IR:
    if (i->result != NULL) {
        sprintf(buffer, "%s = call %s", result, o1);
    } else {
        sprintf(buffer, "call %s", o1);
    }
    fprintf(file, "%s", buffer);
    break;
  case RETURN_IR:
    if (i->o1 != NULL) {
        sprintf(buffer, "return %s", o1);
    } else {
        sprintf(buffer, "return");
    }
    fprintf(file, "%s", buffer);
    break;
  case ARR_READ_IR:
    sprintf(buffer, "%s = %s[%s]", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;
  case ARR_WRITE_IR:
    sprintf(buffer, "%s[%s] = %s", result, o1, o2);
    fprintf(file, "%s", buffer);
    break;
  case ADDR_IR:
    sprintf(buffer, "%s = &%s", result, o1);
    fprintf(file, "%s", buffer);
    break;
  case DEREF_IR:
    sprintf(buffer, "%s = *%s", result, o1);
    fprintf(file, "%s", buffer);
    break;
  case DEREF_ASS_IR:
    sprintf(buffer, "*%s = %s", result, o1);
    fprintf(file, "%s", buffer);
    break;
  }
}

void report_error_ir() {
  error_reported = true;
}

void printIR(const char *filename) {
  if (error_reported) {
    return;
  }

  FILE *file = fopen(filename, "w");
  if (file == NULL) {
    DEBUG_PRINT("Fatal Error: Could not open file '%s' for writing.\n", filename);
    exit(EXIT_FAILURE);
  }

  for (int k = 0; k < nextinstr; k++) {
    fprintf(file, "%d: ", k);
    print_instruction(&IR[k], file);
    fprintf(file, "\n");
  }

  fclose(file);
}



void find_leaders(){
    free(Leaders);
    Leaders = NULL;
    numberOfLeaders = 0;

    if (nextinstr <= 0) {
        return;
    }

    int *longList = calloc(nextinstr, sizeof *longList);
    if (longList == NULL) {
        return;
    }

    for (int i = 0; i < nextinstr; i++){
		if (IR[i].type == IFTRUE_IR || IR[i].type == IFFALSE_IR || IR[i].type == IFRELOP_IR || IR[i].type == GOTO_IR || IR[i].type == CALL_IR || IR[i].type == RETURN_IR) {
			int t = IR[i].jumpTarget;
			if (longList[t] != 1 && t >= 0 && t < nextinstr) {
				longList[t] = 1;
				numberOfLeaders++;
			}
			t = i + 1;
			if (longList[t] != 1 && t >= 0 && t < nextinstr) {
				longList[t] = 1;
				numberOfLeaders++;
			}
		}
    }

	if (longList[0] != 1) {
		longList[0] = 1;
		numberOfLeaders++;
	}
    
    Leaders = (int*)calloc(numberOfLeaders, sizeof(int));
	if (Leaders == NULL) {
        free(longList);
        return;
    }

    int j = 0;
    for (int i = 0; i < nextinstr; i++){
        if( longList[i] == 1){
            Leaders[j] = i;
            j++;
            IR[i].isLeader = true;
        }
    }
    free(longList);
    return;
}



void print_leaders(){
    fprintf(stderr,"=== Leader Debug Info: ======\n");
    fprintf(stderr,"Leaders: %d \n", numberOfLeaders);

    fprintf(stderr,"Leader indices:\n");
    fprintf(stderr,"[ ");
    for (int i = 0; i < numberOfLeaders; i++){
        fprintf(stderr,"%d ",Leaders[i]);
    }
    fprintf(stderr,"]\n");
    fprintf(stderr, "=============================\n");

}

int block_index_from_IR_line(int ir_line){
  if ((ir_line < 0) | (ir_line >= nextinstr)){
    DEBUG_PRINT("Fatal Error: ir Line '%d' does not exist.\n", ir_line);
    exit(EXIT_FAILURE);
  }
  int r_value = -1;
  for (int i = 0; i < numberOfLeaders; i++){
    if (ir_line >= Leaders[1]){
      r_value = i;
    }
    if (ir_line < Leaders[i]){
      break;
    }
  }
  return r_value;
}


int block_start(int block_index){
  if ((block_index < 0) | (block_index >= numberOfLeaders)){
    DEBUG_PRINT("Fatal Error: Could not find block with index '%d'.\n", block_index);
    exit(EXIT_FAILURE);
  }
  return Leaders[block_index];
}

int block_end(int block_index){
  if ((block_index < 0) || (block_index >= numberOfLeaders)){
    DEBUG_PRINT("Fatal Error: Could not find block with index '%d'.\n", block_index);
    exit(EXIT_FAILURE);
  }
  return Leaders[block_index+1] - 1;
}