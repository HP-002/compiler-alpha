#include "include/cg.h"
#include "include/ir.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "include/symbol_table.h"

#define RAX_INDEX 0
#define RDX_INDEX 3

bool cgFlag = true;

int as_index = 0;
As_inst assembly[CG_SIZE];
Register register_file[12];
extern SymbolTable *global_table;

// Next register to be freed
int victim = 4;

// Parameter count for current function called
int param_count = 0;

// Initializes the register file by naming the registers
void initialize_register_file() {
    register_file[RAX_INDEX].name = RAX;
    register_file[1].name = RBX;
    register_file[2].name = RCX;
    register_file[RDX_INDEX].name = RDX;
    register_file[4].name = R8;
    register_file[5].name = R9;
    register_file[6].name = R10;
    register_file[7].name = R11;
    register_file[8].name = R12;
    register_file[9].name = R13;
    register_file[10].name = R14;
    register_file[11].name = R15;

    for (int i = 0; i < REGISTER_FILE_SIZE; i++) {
        register_file[i].variable = NULL;
    }
}

// Returns the Size (BYTE, QUAD, LONG) based on the variable's size
Size getRegSizeType(SymbolEntry *type) {
    switch (get_entry_size(type)) {
        case 1:
            return BYTE;
        case 4:
            return LONG;
        case 8:
            return QUAD;
        default:
            return LONG;
    }
}

// Returns a register that is free to be used. The register is not guaranteed to have the value of the variable.
Register getReg(SymbolEntry *variable) {
    Register reg;

    if(variable->entry.var_entry.reg_index != NOT_IN_REGISTER) {
        reg.name = register_file[variable->entry.var_entry.reg_index].name;
        reg.variable = variable;
        reg.size = register_file[variable->entry.var_entry.reg_index].size;
        return reg;
    }

    Size s = getRegSizeType(variable->entry.var_entry.type);

    for (int i = 0; i < REGISTER_FILE_SIZE; i++) {
        if (i != RAX_INDEX && i != RDX_INDEX && register_file[i].variable == NULL) {
            register_file[i].variable = variable;
            register_file[i].size = s;

            reg.name = register_file[i].name;
            reg.variable = variable;
            reg.size = s;

            variable->entry.var_entry.reg_index = i;
            return reg;
        }
    }

    freeReg(victim);
    register_file[victim].variable = variable;
    register_file[victim].size = s;

    reg.name = register_file[victim].name;
    reg.variable = variable;
    reg.size = s;

    variable->entry.var_entry.reg_index = victim;

    victim += 1;
    victim %= REGISTER_FILE_SIZE;

    if (victim == RAX_INDEX || victim == RDX_INDEX) {
        victim += 1;
    }

    return reg;
}

// Returns a register that holds the value of the variable
Register loadReg(SymbolEntry *variable) {
    Register reg;

    if(variable->entry.var_entry.reg_index != NOT_IN_REGISTER) {
        reg.name = register_file[variable->entry.var_entry.reg_index].name;
        reg.variable = variable;
        reg.size = register_file[variable->entry.var_entry.reg_index].size;
        return reg;
    }

    reg = getReg(variable);

    Inst_arg rbp, dst;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    int off = variable->entry.var_entry.offset;
    dst.reg = reg;

    emitAs(_MOV, IN_DISP, rbp, REG, dst, off, NULL);
    return reg;
}

// Saves the value from the register to the stack
void saveRegVariable(Register reg) {
    Inst_arg rbp, src;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    src.reg = reg;
    emitAs(_MOV, REG, src, IN_DISP, rbp, reg.variable->entry.var_entry.offset, NULL);
}

// Sets the variable of the register in register_file to the given variable
void setRegisterVariable(reg_num reg, SymbolEntry *var) {
    for (int i = 0; i < REGISTER_FILE_SIZE; i++) {
        if (register_file[i].name == reg) {
            register_file[i].variable = var;
            if (var != NULL) {
                var->entry.var_entry.reg_index = i;
            }
            return;
        }
    }
}

// Free the register at reg_index by moving the value from register to the stack
void freeReg(int reg_index) {
    if(register_file[reg_index].variable == NULL) {
        return;
    }

    if (register_file[reg_index].variable->entry.var_entry.var_class == CONSTANT) {
        register_file[reg_index].variable->entry.var_entry.reg_index = NOT_IN_REGISTER;
        register_file[reg_index].variable = NULL;
        return;
    }

    Register reg;
    reg.name = register_file[reg_index].name;
    reg.size = register_file[reg_index].size;

    As_type type = _MOV;

    // Source is register
    Addr_mode o1 = REG;
    Inst_arg r1;
    r1.reg = reg;
    
    // Destination is memory (stack)
    Addr_mode o2 = IN_DISP;
    Inst_arg r2;
    r2.reg.name = RBP;
    r2.reg.size = QUAD;

    
    int off = register_file[reg_index].variable->entry.var_entry.offset;

    emitAs(type, o1, r1, o2, r2,off, NULL);

    register_file[reg_index].variable->entry.var_entry.reg_index = NOT_IN_REGISTER;
    register_file[reg_index].variable = NULL;
}

// Frees all registers (including rax) by storing values on the stack.
void freeAllRegs() {
    for (int i = 0; i < REGISTER_FILE_SIZE; i++) {
        if (register_file[i].variable != NULL) {
            freeReg(i);
        }
    }
    victim = 4;
}

// Frees all registers (excluding rax). Does not store the values on the stack.
// Only used when function returns/exits.
void nukeRegisters() {
    for (int i = 0; i < REGISTER_FILE_SIZE; i++) {
        if (i != RAX_INDEX && register_file[i].variable != NULL) {
            register_file[i].variable->entry.var_entry.reg_index = NOT_IN_REGISTER;
            register_file[i].variable = NULL;
        }
    }
    victim = 4;
}

// Generates the assembly code for all the functions in the global symbol table
void generateAssembly(SymbolTable *global_table) {
    if (!cgFlag) {
        return;
    }

    SymbolEntry *f = global_table->entry_head;

    while (f != NULL) {
        if (f->type == FUNC_ENTRY && cgFlag && f->entry.func_entry.call_index != -1) {
            generateAsForFunc(f);
        }
        f = f->next;
    }
}

// Generates the assembly code for a single function. Emits the function label.
void generateAsForFunc(SymbolEntry *func) {
    // Emit function label
    emitLabel(strdup(func->name));

    int start_index = func->entry.func_entry.call_index;
    int end_index = func->entry.func_entry.end_index;
    int stack_size = -1 * func->entry.func_entry.stack_size; // Make stack size positive

    Inst_arg rbp, rsp;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    rsp.reg.name = RSP;
    rsp.reg.size = QUAD;

    // Push old base pointer
    emitAs(_PUSH, REG, rbp, -1, rbp, 0, NULL);

    // Move base pointer to stack pointer
    emitAs(_MOV, REG, rsp, REG, rbp, 0, NULL);

    // Move stack pointer to allocate stack space for variables
    if (stack_size > 0) {
        Inst_arg s;
        s.addr_imm = stack_size;
        emitAs(_SUB, IMM, s, REG, rsp, 0, NULL);
    }

    for (int i = start_index; i <= end_index; i++) {
        ir2as(i);
    }

    // For functions without a return statement
    if (IR[end_index].type != RETURN_IR) {
        emitAs(_MOV, REG, rbp, REG, rsp, 0, NULL); //changed because rbp should be moved into rsp at the end 
        emitAs(_POP, REG, rbp, -1, rbp, 0, NULL);
        emitAs(_RET, SINGLE, rbp, -1, rbp, 0, NULL);
    }
}

// Calls the appropriate handler function to generate assembly code
void ir2as(int ir_index){
    if (IR[ir_index].isLeader) {
        freeAllRegs();
        // Emit the leader label
        char leader[50];
        sprintf(leader, ".L_%d", ir_index);
        emitLabel(strdup(leader));
    }

    switch(IR[ir_index].type){
        case ADD_IR:
            handleBinaryOp(ir_index); break;
        case SUB_IR:
            handleBinaryOp(ir_index); break;
        case MUL_IR:
            handleBinaryOp(ir_index); break;
        case DIV_IR:
            handleBinaryOp(ir_index); break;
        case REM_IR:
            handleBinaryOp(ir_index); break;
        case MINUS_IR:
            handleUnaryOp(ir_index); break;
        case ASSIGN_IR:
            handleAssign(ir_index); break;
        case IFTRUE_IR:
            handleIfTrue(ir_index); break;
        case IFRELOP_IR:
            handleIfRelop(ir_index); break;
        case GOTO_IR:
            handleGoto(ir_index); break;
        case PARAM_IR:
            handleParam(ir_index); break;
        case CALL_IR:
            handleCall(ir_index); break;
        case RETURN_IR:
            handleReturn(ir_index); break;
        case ARR_READ_IR:
            handleMemRead(ir_index); break;
        case ARR_WRITE_IR:
            handleMemWrite(ir_index); break;
        default:
            return; // Should never happen
    }
}

// Handler functions
// Generates assembly for x = y
void handleAssign(int ir_index) {
    SymbolEntry *x = IR[ir_index].result;
    SymbolEntry *y = IR[ir_index].o1;

    Inst_arg rbp, rsp;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    rsp.reg.name = RSP;
    rsp.reg.size = QUAD;

    if (y->entry.var_entry.var_class == CONSTANT) {
        Inst_arg y_imm, xreg;
        xreg.reg = getReg(x);
        
        switch (y->entry.var_entry.primitive_type) {
            case INTEGER:
                y_imm.addr_imm = y->entry.var_entry.value.int_v;
                break;
            case CHARACTER:
                y_imm.addr_imm = y->entry.var_entry.value.char_v;
                break;
            case BOOLEAN:
                y_imm.addr_imm = y->entry.var_entry.value.bool_v;
                break;
            case ADDRESS:
                y_imm.addr_imm = (long)y->entry.var_entry.value.addr_v;
                break;
            case STRING:
                // Strings in alpha are 1-D arrays of characters
                // Store the string in the heap and return the address
                freeAllRegs();
                int length = strlen(y->entry.var_entry.value.str_v) - 2; // -2 to remove quotes
                Inst_arg param_arg, imm, rax;
                rax.reg.name = RAX;
                rax.reg.size = QUAD;
                param_arg.addr_imm = length + 4; // 4 bytes for the header of the array
                emitAs(_PUSH, IMM, param_arg, -1, param_arg, 0, NULL);
                // The Address of the string will be in rax
                emitAs(_CALL, SINGLE, rbp, -1, rbp, 0, strdup("reserve"));
                // Clean rsp
                param_arg.addr_imm = 8;
                emitAs(_ADD, IMM, param_arg, REG, rsp, 0, NULL);
                // Now put string length at rdx
                rax.reg.size = LONG; // DO NOT CHANGE THIS. for printing movl
                imm.addr_imm = length;
                int offset = 0;
                emitAs(_MOV, IMM, imm, IN_DISP, rax, offset, NULL);
                offset += 4; // skip the header
                rax.reg.size = BYTE; // DO NOT CHANGE THIS. to print movb
                // Insert the characters of the string in memory
                for (int i = 1; i <= length; i++) {
                    if (y->entry.var_entry.value.str_v[i] == '\\') {
                        i++;
                        switch (y->entry.var_entry.value.str_v[i]) {
                            case 'n':
                                imm.addr_imm = (long)10;
                                break;
                            case 't':
                                imm.addr_imm = (long)13;
                                break;
                            case '\\':
                                imm.addr_imm = (long)92;
                                break;
                            case '\'':
                                imm.addr_imm = (long)39;
                                break;
                            case '\"':
                                imm.addr_imm = (long)34;
                                break;
                            default:
                                imm.addr_imm = (long)0;
                                break;
                        }
                    } else {
                        imm.addr_imm = (long)y->entry.var_entry.value.str_v[i];
                    }
                    emitAs(_MOV, IMM, imm, IN_DISP, rax, offset, NULL);
                    offset += 1;
                }
                rax.reg.size = QUAD;
                emitAs(_MOV, REG, rax, REG, xreg, 0, NULL);
                setRegisterVariable(xreg.reg.name, x);
                return;
        }

        emitAs(_MOV, IMM, y_imm, REG, xreg, 0, NULL);
    } else {
        // Load y into a register
        Register reg = loadReg(y);

        // Set x to be the value in the register
        setRegisterVariable(reg.name, x);

        // Set y to not be in the register
        y->entry.var_entry.reg_index = NOT_IN_REGISTER;

    }
}

// Generates assembly for x = y op z
void handleBinaryOp(int ir_index) {
    SymbolEntry *x = IR[ir_index].result;
    SymbolEntry *y = IR[ir_index].o1;
    SymbolEntry *z = IR[ir_index].o2;

    Register yreg, zreg;
    Inst_arg yarg, zarg;

    if (y->entry.var_entry.var_class == CONSTANT && z->entry.var_entry.var_class == CONSTANT) {
        // Both y & z are constants
        int result;
        switch (IR[ir_index].type) {
            case ADD_IR:
                result = y->entry.var_entry.value.int_v + z->entry.var_entry.value.int_v;
                break;
            case SUB_IR:
                result = y->entry.var_entry.value.int_v - z->entry.var_entry.value.int_v;
                break;
            case MUL_IR:
                result = y->entry.var_entry.value.int_v * z->entry.var_entry.value.int_v;
                break;
            case DIV_IR:
                result = y->entry.var_entry.value.int_v / z->entry.var_entry.value.int_v;
                break;
            case REM_IR:
                result = y->entry.var_entry.value.int_v % z->entry.var_entry.value.int_v;
                break;
            default:
                // Should never happen
                result = 0;
        }

        yarg.addr_imm = result;
        zarg.reg = getReg(x);
        emitAs(_MOV, IMM, yarg, REG, zarg, 0, NULL);

    } else if (y->entry.var_entry.var_class == CONSTANT) {
        // y is a constant
        zreg = loadReg(z);

        yarg.addr_imm = y->entry.var_entry.value.int_v;
        zarg.reg = zreg;

        switch(IR[ir_index].type) {
            case ADD_IR:
                saveRegVariable(zreg);
                emitAs(_ADD, IMM, yarg, REG, zarg, 0, NULL);
                setRegisterVariable(zreg.name, x);
                z->entry.var_entry.reg_index = NOT_IN_REGISTER;
                break;
            case SUB_IR:
                yreg = getReg(y);
                Inst_arg yarg2;
                yarg2.reg = yreg;
                emitAs(_MOV, IMM, yarg, REG, yarg2, 0, NULL);
                saveRegVariable(yarg2.reg);
                emitAs(_SUB, REG, zarg, REG, yarg2, 0, NULL);
                setRegisterVariable(yreg.name, x);
                y->entry.var_entry.reg_index = NOT_IN_REGISTER;
                break;
            case MUL_IR:
                saveRegVariable(zreg);
                emitAs(_IMUL, IMM, yarg, REG, zarg, 0, NULL);
                setRegisterVariable(zreg.name, x);
                z->entry.var_entry.reg_index = NOT_IN_REGISTER;
                break;
            case DIV_IR:
                handleDivision(ir_index);
                return;
            case REM_IR:
                handleRem(ir_index);
                return;
            default:
                // Should never happen
                break;
        }
    } else if (z->entry.var_entry.var_class == CONSTANT) {
        // z is a constant
        yreg = loadReg(y);

        yarg.reg = yreg;
        zarg.addr_imm = z->entry.var_entry.value.int_v;
        
        switch(IR[ir_index].type) {
            case ADD_IR:
                saveRegVariable(yreg);
                emitAs(_ADD, IMM, zarg, REG, yarg, 0, NULL);
                break;
            case SUB_IR:
                // z comes first
                saveRegVariable(yreg);
                emitAs(_SUB, IMM, zarg, REG, yarg, 0, NULL);
                break;
            case MUL_IR:
                saveRegVariable(yreg);
                emitAs(_IMUL, IMM, zarg, REG, yarg, 0, NULL);
                break;
            case DIV_IR:
                handleDivision(ir_index);
                return;
            case REM_IR:
                handleRem(ir_index);
                return;
            default:
                // Should never happen
                break;
        }
        
        setRegisterVariable(yreg.name, x);
        y->entry.var_entry.reg_index = NOT_IN_REGISTER;
    } else {
        yreg = loadReg(y);
        zreg = loadReg(z);

        yarg.reg = yreg;
        zarg.reg = zreg;

        switch(IR[ir_index].type) {
            case ADD_IR:
                saveRegVariable(yreg);
                emitAs(_ADD, REG, zarg, REG, yarg, 0, NULL);
                break;
            case SUB_IR:
                // z comes first
                saveRegVariable(yreg);
                emitAs(_SUB, REG, zarg, REG, yarg, 0, NULL);
                break;
            case MUL_IR:
                saveRegVariable(yreg);
                emitAs(_IMUL, REG, zarg, REG, yarg, 0, NULL);
                break;
            case DIV_IR:
                handleDivision(ir_index);
                return;
            case REM_IR:
                handleRem(ir_index);
                return;
            default:
                // Should never happen
                break;
        }

        setRegisterVariable(yreg.name, x);
        y->entry.var_entry.reg_index = NOT_IN_REGISTER;
    }
}

void handleDivision(int ir_index) {
    SymbolEntry *x = IR[ir_index].result;
    SymbolEntry *y = IR[ir_index].o1;
    SymbolEntry *z = IR[ir_index].o2;

    Register yreg, zreg;
    Inst_arg yarg, zarg, t;

    freeReg(RAX_INDEX);
    freeReg(RDX_INDEX);
    Inst_arg rax, rbp;
    rax.reg.name = RAX;
    rax.reg.size = LONG;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;

    if (y->entry.var_entry.var_class == CONSTANT) {
        Inst_arg y_imm;
        y_imm.addr_imm = y->entry.var_entry.value.int_v;
        emitAs(_MOV, IMM, y_imm, REG, rax, 0, NULL);
    } else {
        yreg = loadReg(y);
        yarg.reg = yreg;
        emitAs(_MOV, REG, yarg, REG, rax, 0, NULL);
    }

    if (z->entry.var_entry.var_class == CONSTANT) {
        zreg = getReg(z); 
        zreg.size = LONG;
        Inst_arg z_imm;
        z_imm.addr_imm = z->entry.var_entry.value.int_v;
        zarg.reg = zreg;
        emitAs(_MOV, IMM, z_imm, REG, zarg, 0, NULL);
        setRegisterVariable(zreg.name, z);
    } else {
        zreg = loadReg(z);
        zreg.size = LONG;
        zarg.reg = zreg;
    }

    emitAs(_CLTD, SINGLE, t, SINGLE, t, 0, NULL);
    emitAs(_IDIV, REG, zarg, SINGLE, t, 0, NULL);
    emitAs(_MOV, REG, rax, IN_DISP, rbp, x->entry.var_entry.offset, NULL);
    freeReg(RAX_INDEX);
    freeReg(RDX_INDEX);
    y->entry.var_entry.reg_index = NOT_IN_REGISTER;
    x->entry.var_entry.reg_index = NOT_IN_REGISTER;
}

// Generates assembly for x = y % z
void handleRem(int ir_index){
    SymbolEntry *x = IR[ir_index].result;
    SymbolEntry *y = IR[ir_index].o1;
    SymbolEntry *z = IR[ir_index].o2;

    Register yreg, zreg;
    Inst_arg yarg, zarg, t;

    freeReg(RAX_INDEX);
    freeReg(RDX_INDEX);
    Inst_arg rax, rdx, rbp;
    rax.reg.name = RAX;
    rax.reg.size = LONG;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    rdx.reg.name = RDX;
    rdx.reg.size = LONG;

    if (y->entry.var_entry.var_class == CONSTANT) {
        Inst_arg y_imm;
        y_imm.addr_imm = y->entry.var_entry.value.int_v;
        emitAs(_MOV, IMM, y_imm, REG, rax, 0, NULL);
    } else {
        yreg = loadReg(y);
        yarg.reg = yreg;
        emitAs(_MOV, REG, yarg, REG, rax, 0, NULL);
    }

    if (z->entry.var_entry.var_class == CONSTANT) {
        zreg = getReg(z); 
        zreg.size = LONG;
        Inst_arg z_imm;
        z_imm.addr_imm = z->entry.var_entry.value.int_v;
        zarg.reg = zreg;
        emitAs(_MOV, IMM, z_imm, REG, zarg, 0, NULL);
        setRegisterVariable(zreg.name, z);
    } else {
        zreg = loadReg(z);
        zreg.size = LONG;
        zarg.reg = zreg;
    }

    emitAs(_CLTD, SINGLE, t, SINGLE, t, 0, NULL);
    emitAs(_IDIV, REG, zarg, SINGLE, t, 0, NULL);
    emitAs(_MOV, REG, rdx, IN_DISP, rbp, x->entry.var_entry.offset, NULL);
    freeReg(RAX_INDEX);
    freeReg(RDX_INDEX);
    y->entry.var_entry.reg_index = NOT_IN_REGISTER;
    x->entry.var_entry.reg_index = NOT_IN_REGISTER;
}


// Generates assembly for x = op y
void handleUnaryOp(int ir_index) {
    SymbolEntry *x = IR[ir_index].result;
    SymbolEntry *y = IR[ir_index].o1;

    if (y->entry.var_entry.var_class == CONSTANT) {
        Inst_arg y_imm, xarg;
        y_imm.addr_imm = y->entry.var_entry.value.int_v;
        xarg.reg = getReg(x);
        emitAs(_MOV, IMM, y_imm, REG, xarg, 0, NULL);
        emitAs(_NEG, REG, xarg, REG, xarg, 0, NULL);
    } else {
        Register yreg = loadReg(y);
        Inst_arg yarg;
        yarg.reg = yreg;
        saveRegVariable(yreg);
        emitAs(_NEG, REG, yarg, REG, yarg, 0, NULL);
        setRegisterVariable(yreg.name, x);
        y->entry.var_entry.reg_index = NOT_IN_REGISTER;
    }
}

// Generates assembly for goto L
void handleGoto(int ir_index) {
    freeAllRegs();
    Inst_arg j,k;
    char target[50];
    sprintf(target, ".L_%d",IR[ir_index].jumpTarget);
    emitAs(_JMP,SINGLE,j,SINGLE,k,-1,strdup(target));
    // Damn, this is to handle double increment for param for booleans.
    // Should work for more than one booleans too. At least in my head it does.
    param_count -= 1;
}

// Generates assembly for if x goto L
void handleIfTrue(int ir_index) {
    Inst_arg x, y, j1, j2;
    SymbolEntry *X = IR[ir_index].o1;
    freeAllRegs();
    if(X->entry.var_entry.var_class == CONSTANT){
        Inst_arg x_imm;
        x.reg = getReg(X);
        setRegisterVariable(x.reg.name,X);
        x_imm.addr_imm = (long)X->entry.var_entry.value.bool_v;
        emitAs(_MOV, IMM, x_imm, REG, x, -1, NULL);
    }
    else{
        x.reg = loadReg(X);
    }
    y.addr_imm = 1;
    char target[50];
    sprintf(target, ".L_%d",IR[ir_index].jumpTarget);
    emitAs(_CMP,IMM,y,REG,x,-1,NULL);
    emitAs(_JE,SINGLE,j1,SINGLE,j2,-1,strdup(target));
}

// Generates assembly for If x relop y goto L
void handleIfRelop(int ir_index) {
    Inst_arg x, y, j1, j2;
    SymbolEntry *X = IR[ir_index].o1;
    SymbolEntry *Y = IR[ir_index].o2;
    freeAllRegs();
    if(X->entry.var_entry.var_class == CONSTANT){
        x.reg = getReg(X);
        setRegisterVariable(x.reg.name,X);
        Inst_arg x_imm;
        switch (X->entry.var_entry.primitive_type) {
            case INTEGER:
                x_imm.addr_imm = X->entry.var_entry.value.int_v;
                break;
            case BOOLEAN:
                x_imm.addr_imm = X->entry.var_entry.value.bool_v;
                break;
            default: cgFlag = false;
                    return;
        } 
        emitAs(_MOV, IMM, x_imm, REG, x, -1, NULL);
    }
    else{
        x.reg = loadReg(X);
    }

    if(Y->entry.var_entry.var_class == CONSTANT){
        y.reg = getReg(Y);
        setRegisterVariable(y.reg.name,Y);
        Inst_arg y_imm;
        switch (Y->entry.var_entry.primitive_type) {
            case INTEGER:
                y_imm.addr_imm = Y->entry.var_entry.value.int_v;
                break;
            case BOOLEAN:
                y_imm.addr_imm = Y->entry.var_entry.value.bool_v;
                break;
            default: cgFlag = false;
                     return;
        } 
        emitAs(_MOV, IMM, y_imm, REG, y, -1, NULL);
    }
    else{
        y.reg = loadReg(Y);
    }
    char target[50];
    sprintf(target, ".L_%d",IR[ir_index].jumpTarget);
    emitAs(_CMP,REG,y,REG,x,-1,NULL);
    if(IR[ir_index].comp==LT){
        emitAs(_JL,SINGLE,j1,SINGLE,j2,-1,strdup(target));
    }
    else if(IR[ir_index].comp==EQ){
        emitAs(_JE,SINGLE,j1,SINGLE,j2,-1,strdup(target));
    }
}

// Generates assembly for param x
void handleParam(int ir_index) {
    Addr_mode mode;
    Inst_arg p;
    SymbolEntry *param = IR[ir_index].o1;

    Inst_arg rbp, rsp;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    rsp.reg.name = RSP;
    rsp.reg.size = QUAD;

    if (param->entry.var_entry.var_class == CONSTANT) {
        mode = IMM;
        switch (param->entry.var_entry.primitive_type) {
            case INTEGER:
                p.addr_imm = param->entry.var_entry.value.int_v;
                break;
            case CHARACTER:
                p.addr_imm = param->entry.var_entry.value.char_v;
                break;
            case BOOLEAN:
                p.addr_imm = param->entry.var_entry.value.bool_v;
                break;
            case ADDRESS:
                p.addr_imm = (long)param->entry.var_entry.value.addr_v;
                break;
            case STRING:
                // Strings in alpha are 1-D arrays of characters
                // Store the string in the heap and return the address
                freeAllRegs();
                int length = strlen(param->entry.var_entry.value.str_v) - 2;
                Inst_arg param_arg, imm, rax;
                rax.reg.name = RAX;
                rax.reg.size = QUAD;
                param_arg.addr_imm = length + 4; // 4 bytes for the header of the array
                emitAs(_PUSH, IMM, param_arg, -1, param_arg, 0, NULL);
                // The Address of the string will be in rax
                emitAs(_CALL, SINGLE, rbp, -1, rbp, 0, strdup("reserve"));
                // Clean rsp
                param_arg.addr_imm = 8;
                emitAs(_ADD, IMM, param_arg, REG, rsp, 0, NULL);
                // Now put string length at rdx
                rax.reg.size = LONG; // DO NOT CHANGE THIS. for printing movl
                imm.addr_imm = length;
                int offset = 0;
                emitAs(_MOV, IMM, imm, IN_DISP, rax, offset, NULL);
                offset += 4; // skip the header
                rax.reg.size = BYTE; // DO NOT CHANGE THIS. to print movb
                // Insert the characters of the string in memory
                for (int i = 1; i <= length; i++) {
                    if (param->entry.var_entry.value.str_v[i] == '\\') {
                        i++;
                        switch (param->entry.var_entry.value.str_v[i]) {
                            case 'n':
                                imm.addr_imm = (long)10;
                                break;
                            case 't':
                                imm.addr_imm = (long)13;
                                break;
                            case '\\':
                                imm.addr_imm = (long)92;
                                break;
                            case '\'':
                                imm.addr_imm = (long)39;
                                break;
                            case '\"':
                                imm.addr_imm = (long)34;
                                break;
                            default:
                                imm.addr_imm = (long)0;
                                break;
                        }
                    } else {
                        imm.addr_imm = (long)param->entry.var_entry.value.str_v[i];
                    }
                    emitAs(_MOV, IMM, imm, IN_DISP, rax, offset, NULL);
                    offset += 1;
                }
                rax.reg.size = QUAD;
                emitAs(_PUSH, REG, rax, -1, rax, 0, NULL);
                param_count++;
                return;
        }
    } else {
        mode = REG;
        Register param_reg = loadReg(IR[ir_index].o1);
        p.reg = param_reg;
    }
    emitAs(_PUSH, mode, p, -1, p, 0, NULL);
    param_count++;
}

// Generates assembly for x = call f
void handleCall(int ir_index) {
    Inst_arg rbp, rsp;
    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;
    rsp.reg.name = RSP;
    rsp.reg.size = QUAD;

    // Save values in registers to stack as the rbp and rsp will change
    freeAllRegs();

    emitAs(_CALL, SINGLE, rbp, -1, rbp, 0, strdup(IR[ir_index].o1->name));

    if (param_count > 0) {
        Inst_arg t;
        t.addr_imm = param_count * 8;
        emitAs(_ADD, IMM, t, REG, rsp, 0, NULL);
        param_count = 0;
    }

    SymbolEntry *result = IR[ir_index].result;
    if (result != NULL) {
        Inst_arg rax;
        rax.reg.name = RAX;
        rax.reg.size = getRegSizeType(result->entry.var_entry.type);
        emitAs(_MOV, REG, rax, IN_DISP, rbp, result->entry.var_entry.offset, NULL);
    }
}

// Generates assembly for return x / return
void handleReturn(int ir_index) {
    Inst_arg rax, rbp, rsp;

    rbp.reg.name = RBP;
    rbp.reg.size = QUAD;

    rsp.reg.name = RSP;
    rsp.reg.size = QUAD;

    SymbolEntry *return_value = IR[ir_index].o1;
    if (return_value != NULL) {
        Inst_arg r1;

        rax.reg.name = RAX;
        rax.reg.size = getRegSizeType(return_value->entry.var_entry.type);
        
        if (return_value->entry.var_entry.reg_index == RAX_INDEX) {
            // Return value is in rax
        } else if (return_value->entry.var_entry.var_class == CONSTANT) {
            // Return value is a constant
            // Use immediate value to mov it to rax
            switch (return_value->entry.var_entry.primitive_type) {
                case INTEGER:
                    r1.addr_imm = return_value->entry.var_entry.value.int_v;
                    break;
                case CHARACTER:
                    // ASCII value of the character
                    r1.addr_imm = (long)return_value->entry.var_entry.value.char_v;
                    break;
                case BOOLEAN:
                    r1.addr_imm = (long)return_value->entry.var_entry.value.bool_v;
                    break;
                case ADDRESS:
                    r1.addr_imm = (long)return_value->entry.var_entry.value.addr_v;
                    break;
                case STRING:
                    // Strings in alpha are 1-D arrays of characters
                    // Store the string in the heap and return the address
                    freeAllRegs();
                    int length = strlen(return_value->entry.var_entry.value.str_v) - 2;
                    Inst_arg param_arg, imm;
                    param_arg.addr_imm = length + 4; // 4 bytes for the header of the array
                    emitAs(_PUSH, IMM, param_arg, -1, param_arg, 0, NULL);
                    // The Address of the string will be in rax
                    emitAs(_CALL, SINGLE, rbp, -1, rbp, 0, strdup("reserve"));
                    // Clean rsp
                    param_arg.addr_imm = 8;
                    emitAs(_ADD, IMM, param_arg, REG, rsp, 0, NULL);
                    // Now put string length at rdx
                    rax.reg.size = LONG; // DO NOT CHANGE THIS. for printing movl
                    imm.addr_imm = length;
                    int offset = 0;
                    emitAs(_MOV, IMM, imm, IN_DISP, rax, offset, NULL);
                    offset += 4; // skip the header
                    rax.reg.size = BYTE; // DO NOT CHANGE THIS. to print movb
                    // Insert the characters of the string in memory
                    for (int i = 1; i <= length; i++) {
                        if (return_value->entry.var_entry.value.str_v[i] == '\\') {
                            i++;
                            switch (return_value->entry.var_entry.value.str_v[i]) {
                                case 'n':
                                    imm.addr_imm = (long)10;
                                    break;
                                case 't':
                                    imm.addr_imm = (long)13;
                                    break;
                                case '\\':
                                    imm.addr_imm = (long)92;
                                    break;
                                case '\'':
                                    imm.addr_imm = (long)39;
                                    break;
                                case '\"':
                                    imm.addr_imm = (long)34;
                                    break;
                                default:
                                    imm.addr_imm = (long)0;
                                    break;
                            }
                        } else {
                            imm.addr_imm = (long)return_value->entry.var_entry.value.str_v[i];
                        }
                        emitAs(_MOV, IMM, imm, IN_DISP, rax, offset, NULL);
                        offset += 1;
                    }
                    rax.reg.size = QUAD;
                    return;
            }
            // Free rax to store the return value
            freeReg(RAX_INDEX);
            emitAs(_MOV, IMM, r1, REG, rax, 0, NULL);
        } else if (return_value->entry.var_entry.reg_index != NOT_IN_REGISTER){
            // Return value is in a register
            // Move from its current register to rax
            r1.reg.name = register_file[return_value->entry.var_entry.reg_index].name;
            r1.reg.size = register_file[return_value->entry.var_entry.reg_index].size;
            // Free rax to store the return value
            freeReg(RAX_INDEX);
            emitAs(_MOV, REG, r1, REG, rax, 0, NULL);
        } else {
            // Return value is in memory on the stack
            // Move from stack to rax
            // Free rax to store the return value
            freeReg(RAX_INDEX);
            emitAs(_MOV, IN_DISP, rbp, REG, rax, return_value->entry.var_entry.offset, NULL);
        }
    }

    nukeRegisters();

    emitAs(_MOV, REG, rbp, REG, rsp, 0, NULL);
    emitAs(_POP, REG, rbp, -1, rbp, 0, NULL);
    emitAs(_RET, SINGLE, rbp, -1, rbp, 0, NULL);
}

// Generates assembly for x = y[z]
void handleMemRead(int ir_index) {
    SymbolEntry *x = IR[ir_index].result;
    SymbolEntry *y = IR[ir_index].o1;
    SymbolEntry *z = IR[ir_index].o2;

    
    if (z->entry.var_entry.var_class == CONSTANT) {
        Inst_arg xarg, yarg;
        yarg.reg = loadReg(y);
        xarg.reg = getReg(x);
        emitAs(_MOV, IN_DISP, yarg, REG, xarg, z->entry.var_entry.value.int_v, NULL);
    } else {
        Register yreg = loadReg(y);
        Register zreg = loadReg(z);

        Inst_arg yarg, zarg;
        yarg.reg = yreg;
        zarg.reg = zreg;
        zarg.reg.size = QUAD;

        emitAs(_ADD, REG, yarg, REG, zarg, 0, NULL);
        z->entry.var_entry.reg_index = NOT_IN_REGISTER;

        Inst_arg xarg;
        xarg.reg = getReg(x);

        emitAs(_MOV, INDIRECT, zarg, REG, xarg, 0, NULL);
        setRegisterVariable(zarg.reg.name, NULL);
    }
}

// Generates assembly for y[z] = x
void handleMemWrite(int ir_index) {
    SymbolEntry *x = IR[ir_index].o2;
    SymbolEntry *y = IR[ir_index].result;
    SymbolEntry *z = IR[ir_index].o1;

    Inst_arg xarg, yarg, zarg;
    Addr_mode xmode;

    if (x->entry.var_entry.var_class == CONSTANT) {
        xarg.addr_imm = x->entry.var_entry.value.int_v;
        xmode = IMM;
    } else {
        xarg.reg = loadReg(x);
        xmode = REG;
    }

    Size s = getRegSizeType(x->entry.var_entry.type);
    if (z->entry.var_entry.var_class == CONSTANT) {
        yarg.reg = loadReg(y);
        yarg.reg.size = s;
        emitAs(_MOV, xmode, xarg, IN_DISP, yarg, z->entry.var_entry.value.int_v, NULL);
    } else {
        yarg.reg = loadReg(y);
        zarg.reg = loadReg(z);
        zarg.reg.size = QUAD;
        emitAs(_ADD, REG, yarg, REG, zarg, 0, NULL);
        z->entry.var_entry.reg_index = NOT_IN_REGISTER;
        zarg.reg.size = s;
        emitAs(_MOV, xmode, xarg, INDIRECT, zarg, 0, NULL);
        setRegisterVariable(zarg.reg.name, NULL);
    }
}


// Emits an assembly instruction and increments the assembly index;
void emitAs(As_type type, Addr_mode o1, Inst_arg r1, Addr_mode o2, Inst_arg r2, int offset, char *label) {
    assembly[as_index].type = type;
    assembly[as_index].o1 = o1;
    assembly[as_index].r1 = r1;
    assembly[as_index].o2 = o2;
    assembly[as_index].r2 = r2;
    assembly[as_index].offset = offset;
    assembly[as_index].label = label;
    as_index++;
}


// Emits a label and increments the assembly index.
void emitLabel(char *label) {
    assembly[as_index].type = _LABEL;
    assembly[as_index].label = label;
    as_index++;
}

void printCG(const char *filename){
    if (!cgFlag) {
        return;
    }
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        exit(EXIT_FAILURE);
    }

    fprintf(file, "\t.text\n");
    fprintf(file, "\t.globl\tentry\n\n");
    for (int k = 0; k < as_index; k++) {
        As_inst inst = assembly[k];
        print_instruction_as(inst, file);
    }

    crashFunction(file);

    fclose(file);
}

void CG(const char *filename){
    initialize_register_file();
    generateAssembly(global_table);
    printCG(filename);
}

void print_instruction_as(As_inst inst, FILE *file){
    As_type type = inst.type;
    Size size;

    if (inst.o1 == REG) {
        size = inst.r1.reg.size;
    } else {
        size = inst.r2.reg.size;
    }

    if (type == _LABEL) {
        fprintf(file, "\n%s:\n", inst.label);
        return;
    }
    //jumps
    if (type == _JMP || type == _JL || type == _JE || type == _CALL) {
        char *mnemonic = getopstr(type,size);
        fprintf(file, "\t%s %s\n", mnemonic, inst.label);
        return;
    }
    //return
    if (inst.type == _RET) {
        fprintf(file, "\tret\n");
        return;
    }

    // cltd
    if (type == _CLTD) {
        fprintf(file, "\tcltd\n");
        return;
    }

    const char *op_str = getopstr(type,size);
        
    fprintf(file, "\t%s ", op_str);

    if (type == _PUSH || type ==  _POP) {
        // Unary instructions only use the first operand (o1/r1)
        inst.r1.reg.size = QUAD;
        print_operand(file, inst.o1, inst.r1, inst.offset);
        fprintf(file, "\n");
    } else if (type == _NOT || type == _IDIV || type == _NEG) {
        // Unary instructions only use the first operand (o1/r1)
        print_operand(file, inst.o1, inst.r1, inst.offset);
        fprintf(file, "\n");
    } else {
        // Binary instructions: Source (o1/r1) followed by Destination (o2/r2)
        print_operand(file, inst.o1, inst.r1, inst.offset);
        fprintf(file, ", ");
        print_operand(file, inst.o2, inst.r2, inst.offset);
        fprintf(file, "\n");
    }
}

void setRegVar(reg_num r, SymbolEntry *var){
    for (int i = 0; i< REGISTER_FILE_SIZE; i++){
        if(register_file[i].name == r){
            register_file[i].variable = var;
        }
    }
}

char *getopstr(As_type type, Size size){
    switch(type) {
    case _ADD:
    case _ADDI:
        switch(size) {
            case BYTE: return "addb";
            case LONG: return "addl";
            case QUAD: return "addq";
            default: return "add-unknown";
        }
    case _SUB:
        switch(size) {
            case BYTE: return "subb";
            case LONG: return "subl";
            case QUAD: return "subq";
            default: return "sub-unknown";
        }
    case _IMUL:
        switch(size) {
            case BYTE: return "imulb";
            case LONG: return "imull";
            case QUAD: return "imulq";
            default: return "imul-unknown";
        }
    case _IDIV:
        switch(size) {
            case BYTE: return "idivb";
            case LONG: return "idivl";
            case QUAD: return "idivq";
            default: return "idiv-unknown";
        }
    case _MOV:
        switch(size) {
            case BYTE: return "movb";
            case LONG: return "movl";
            case QUAD: return "movq";
            default: return "mov-unknown";
        }
    case _CMP:
        switch(size) {
            case BYTE: return "cmpb";
            case LONG: return "cmpl";
            case QUAD: return "cmpq";
            default: return "cmp-unknown";
        }
    case _AND:
        switch(size) {
            case BYTE: return "andb";
            case LONG: return "andl";
            case QUAD: return "andq";
            default: return "and-unknown";
        }
    case _OR:
        switch(size) {
            case BYTE: return "orb";
            case LONG: return "orl";
            case QUAD: return "orq";
            default: return "or-unknown";
        }
    case _NEG:
        switch(size) {
            case BYTE: return "negb";
            case LONG: return "negl";
            case QUAD: return "negq";
            default: return "neg-unknown";
        }
    case _NOT:
        switch(size) {
            case BYTE: return "notb";
            case LONG: return "notl";
            case QUAD: return "notq";
            default: return "not-unknown";
        }
    case _PUSH:
        return "pushq";
        break;
    case _POP:
        return "popq";
            break;
    case _JMP:
        return "jmp";
            break;
    case _JL:
        return "jl";
            break;
    case _JE:
        return "je";
            break;
    case _CALL:
        return "call";
            break;
    case _RET:
        return "ret";
            break;
    case _CLTD:
        return "cltd";
            break;
    default:
        return "unknown";
}
}

void print_operand(FILE *file, Addr_mode mode, Inst_arg arg, int offset) {
    switch (mode) {
        case IMM:
            // Immediate values get a '$' prefix
            fprintf(file, "$%ld", arg.addr_imm);
            break;
        case REG:
            // Registers get a '%' prefix
            fprintf(file, "%%%s", getRegName(arg.reg.name, arg.reg.size));
            break;
        case IN_DISP:
            // Base + Displacement format: offset(%reg)
            fprintf(file, "%d(%%%s)", offset, getRegName(arg.reg.name, QUAD));
            break;
        case INDIRECT:
            // Just the register in parentheses: (%reg)
            fprintf(file, "(%%%s)", getRegName(arg.reg.name, QUAD));
            break;
        case DIRECT:
            // Typically an absolute memory address or global label
            fprintf(file, "%ld", arg.addr_imm); 
            break;
        case SINGLE:
            // Used as a placeholder for instructions that don't need this operand
            break;
    }
}

char *getRegName(reg_num reg, Size size) {
    switch (reg) {
        case RAX:
            switch (size) {
                case BYTE: return "al";
                case LONG: return "eax";
                case QUAD: return "rax";
                default: return "rax-unknown";
            }
        case RBX:
            switch (size) {
                case BYTE: return "bl";
                case LONG: return "ebx";
                case QUAD: return "rbx";
                default: return "rbx-unknown";
            }
        case RCX:
            switch (size) {
                case BYTE: return "cl";
                case LONG: return "ecx";
                case QUAD: return "rcx";
                default: return "rcx-unknown";
            }
        case RDX:
            switch (size) {
                case BYTE: return "dl";
                case LONG: return "edx";
                case QUAD: return "rdx";
                default: return "rdx-unknown";
            }
        case R8:
            switch (size) {
                case BYTE: return "r8b";
                case LONG: return "r8d";
                case QUAD: return "r8";
                default: return "r8-unknown";
            }
        case R9:
            switch (size) {
                case BYTE: return "r9b";
                case LONG: return "r9d";
                case QUAD: return "r9";
                default: return "r9-unknown";
            }
        case R10:
            switch (size) {
                case BYTE: return "r10b";
                case LONG: return "r10d";
                case QUAD: return "r10";
                default: return "r10-unknown";
            }
        case R11:
            switch (size) {
                case BYTE: return "r11b";
                case LONG: return "r11d";
                case QUAD: return "r11";
                default: return "r11-unknown";
            }
        case R12:
            switch (size) {
                case BYTE: return "r12b";
                case LONG: return "r12d";
                case QUAD: return "r12";
                default: return "r12-unknown";
            }
        case R13:
            switch (size) {
                case BYTE: return "r13b";
                case LONG: return "r13d";
                case QUAD: return "r13";
                default: return "r13-unknown";
            }
        case R14:
            switch (size) {
                case BYTE: return "r14b";
                case LONG: return "r14d";
                case QUAD: return "r14";
                default: return "r14-unknown";
            }
        case R15:
            switch (size) {
                case BYTE: return "r15b";
                case LONG: return "r15d";
                case QUAD: return "r15";
                default: return "r15-unknown";
            }
        case RBP: 
            switch (size) {
                case BYTE: return "bpl";
                case LONG: return "ebp";
                case QUAD: return "rbp";
                default: return "rbp-unknown";
            }
        case RSP:
            switch (size) {
                case BYTE: return "spl";
                case LONG: return "esp";
                case QUAD: return "rsp";
                default: return "rsp-unknown";
            }
        case RSI:
            switch (size) {
                case BYTE: return "sil";
                case LONG: return "esi";
                case QUAD: return "rsi";
                default: return "rsi-unknown";
            }
        case RDI:
            switch (size) {
                case BYTE: return "dil";
                case LONG: return "edi";
                case QUAD: return "rdi";
                default: return "rdi-unknown";
            }
        default:
            return "unknown";
    }
}

// Extra code for crashes, etc.
// Added at the end of the assembly file
void crashFunction(FILE *file) {
    char *crash = "\n\
.crash:\n\
    pushq %rbp\n\
	movq %rsp, %rbp\n\
	subq $168, %rsp\n\
	pushq $10\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $65\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $114\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $114\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $97\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $121\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $32\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $111\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $117\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $116\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $32\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $111\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $102\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $32\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $98\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $111\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $117\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $110\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $100\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $115\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	pushq $10\n\
	movl %ebx, -168(%rbp)\n\
	call printCharacter\n\
	addq $8, %rsp\n\
	movq %rbp, %rsp\n\
	popq %rbp\n\
	ret\n\
    ";
    fprintf(file, "%s", crash);
}

void report_error_cg() {
    cgFlag = false;
}