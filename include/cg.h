#ifndef CG_H   
#define CG_H

#include "symbol_table.h"
#include "ir.h"
#include <stdio.h>

#define CG_SIZE 4096
#define REGISTER_FILE_SIZE 12
#define NOT_IN_REGISTER -1

/*enum for each kind of assembly instruction we'll use*/
typedef enum as_type{
    /*3 VAR INST: INST_TYPE, VAL1, VAL2 */
    _ADD,    
    _ADDI,
    _MOV,
    _SUB,
    _IMUL,
    _IDIV,
    _NEG,
    _AND,
    _OR,
    _CMP,
    /*2 VAR INST: INST_TYPE, VAL1*/
    _JMP, 
    _JL,
    _JE,
    _PUSH,
    _POP,
    _CALL,
    _RET,
    _NOT,
    /*add more as necessary*/
    _LABEL,
    _CLTD
}As_type;

/*addressing mode enum*/
typedef enum addr_mode{
    IMM,
    REG,
    DIRECT,
    INDIRECT,
    IN_DISP,
    SINGLE
} Addr_mode;

typedef enum reg_num{ /*16 registers, make it easier to track this way*/
    RAX,
    RBX,
    RCX,
    RDX,
    RBP,
    RSP,
    RSI,
    RDI,
    R8,
    R9,
    R10,
    R11,
    R12,
    R13,
    R14,
    R15
} reg_num;

/*three possible size modes for registers*/
typedef enum thick{
    BYTE,
    QUAD,
    LONG
}Size;

/*unified regsiter struct*/
typedef struct reg{
    reg_num name;
    SymbolEntry *variable;
    Size size;
}Register;


/*union of possible arguments of assembly instruction, based on addressing mode*/
typedef union inst_arg{
    Register reg;
    long addr_imm;
}Inst_arg;

/*struct for assembly instructions*/
typedef struct as_inst{
    As_type type;   // Type of the instruction (_MOV, _ADD, _CALL, etc.)
    Addr_mode o1;   // Addressing mode 
    Inst_arg r1;    // First operand
    Addr_mode o2;   // Addressing mode for second operand
    Inst_arg r2;    // Second operand
    int offset;     // Only used for IN_DISP addressing mode by only one of the two operands
    char *label;    // Label for jump
} As_inst;

// Maps reg_num enum directly to register strings
extern const char *reg_names[]; 

extern As_inst assembly[CG_SIZE];
extern int as_index;
extern Register register_file[12];
extern bool cgFlag;

// Initializes the register file by naming the registers
void initialize_register_file();
// Returns the Size (BYTE, QUAD, LONG) based on the variable's size
Size getRegSizeType(SymbolEntry *variable);
// Returns a register that is free to be used
Register getReg(SymbolEntry *variable);
// Returns a register that holds the value of the variable
Register loadReg(SymbolEntry *variable);
// Saves the value from the register to the stack
void saveRegVariable(Register reg);
// Sets the variable of the register in register_file to the given variable
void setRegisterVariable(reg_num reg, SymbolEntry *var);
// Free the register at reg_index by moving the value from register to the stack
void freeReg(int reg_index);
// Frees all registers (including rax) by storing values on the stack.
void freeAllRegs();
// Frees all registers (excluding rax). Does not store the values on the stack.
// Only used when the function returns/exits.
void nukeRegisters(); 

// Generates the assembly code for all the functions in the global symbol table
void generateAssembly(SymbolTable *global_table);
// Generates the assembly code for a single function. Emits the function label.
void generateAsForFunc(SymbolEntry *func);

// Calls the appropriate handler function to generate assembly code
void ir2as(int ir_index);

// Handler functions
void handleAssign(int ir_index);    // x = y
void handleBinaryOp(int ir_index);  // x = y op z
void handleDivision(int ir_index);  // Helper function for x = y / z
void handleUnaryOp(int ir_index);   // x = op y
void handleGoto(int ir_index);      // goto L
void handleIfTrue(int ir_index);    // if x goto L
void handleIfRelop(int ir_index);   // If x relop y goto L
void handleParam(int ir_index);     // param x
void handleCall(int ir_index);      // call f
void handleReturn(int ir_index);    // return x / return
void handleMemRead(int ir_index);   // x = y[z]
void handleMemWrite(int ir_index);  // y[z] = x
void handleRem(int ir_index);       // helper for x = y % z
// Emits an assembly instruction and increments the assembly index;
void emitAs(As_type type, Addr_mode o1, Inst_arg r1, Addr_mode o2, Inst_arg r2, int offset, char *label);
// Emits a label and increments the assembly index.
void emitLabel(char *label);
void print_operand(FILE *file, Addr_mode mode, Inst_arg arg, int offset);
char *getRegName(reg_num reg, Size size);
void print_instruction_as(As_inst inst, FILE *file);
void printCG(const char *filename);
char *getopstr(As_type type, Size size);
void CG(const char *filename);
// Extra code for crashes, etc.
// Added at the end of the assembly file
void crashFunction(FILE *file);

void report_error_cg();
#endif