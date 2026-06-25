# Alpha ($\alpha$) Compiler

The compiler by Team Dijkstra's Delegates for the Alpha ($\alpha$) Language. This project was made as part of CSE 443 with Carl Alphonce and Meyer Simon. Our compiler supports all the $\alpha$ primitives, strings, arrays, and records.

## Compiler Flags

- `-tok` : output the token number, token, line number, and column number for each of the tokens to the .tok file
- `-st` : output the symbol table for the program to the .st file
- `-asc` : output the annotated source code for the program to the .asc file, including syntax errors
- `-tc` : run the type checker and report type errors to the .asc file
- `-ir` : run the intermediate representation generator, writing output to the .ir file
- `-cg` : run the (x86 assembly) code generator, writing output to the .s file
- `-debug` : produce debugging messages to stderr
- `-help` : print this message and exit the alpha compiler

### How to invoke the compiler

`./alpha [options] program` where program is a alpha code file.

## Project Structure

```
.
├── runner.c
├── compiler.lex
├── grammar.y
├── symboltable.c
├── ir.c
├── cg.c
├── Makefile
├── include
│   ├── cg.h
│   ├── ir.h
│   ├── parser.h
│   └── symbol_table.h
├── lib
│   ├── alpha_driver.s
│   ├── alpha_lib_st.s
│   ├── library.alpha
│   ├── printBoolean_st.s
│   ├── printInt_st.s
│   └── reserve_release_st.s
├── proj
│   └── gameoflife.alpha
└── tests
    ├── expected
    │   └── Expected output files
    └── Test Files
```

- `runner.c` : The main function which invokes different parts of the compiler.
- `compiler.lex` : Lexer used by our compiler to convert input strings to the compiler to tokens. Uses Flex 2.6.
- `grammar.y` : Contains the grammar for $\alpha$-language. Uses Bison 3.8.
- `symboltable.c`: Contains the API function implementations for the Symbol Table.
- `ir.c` : Contains the API functions for Intermediate Code Generation.
- `cg.c` : Contains the API functions for the x86-64 Assembly Code Generation.
- `Makefile` : Contains make recipes. See [Makefile](#makefile) for the recipes.
- `include/` : Contains all the header files.
- `lib/` : Contains `library.alpha` & the x86-64 Assembly files for the alpha library functions.
- `proj/` : Contains few example alpha files such as Conway's Game of Life, Merge Sort.
- `tests/` : Contains various test files and expected outputs used during production.

## Makefile

The `Makefile` provides recipes to build the `alpha` compiler, compile `.alpha` source files into x86-64 executables, and clean up generated artifacts.

### Build Rules

- `make` or `make compiler` : Builds the `alpha` compiler binary by compiling `runner.c`, the Flex-generated lexer, the Bison-generated parser, and other required files.
- `make clean` : Removes all generated build artifacts, including object files, the lexer/parser sources, the `alpha` binary, and intermediate compilation outputs (`.tok`, `.st`, `.asc`, `.ir`, `.s`, `.cpp.alpha`). Alpha library files under `lib/` are not deleted by the clean rule.

### Intermediate Rules

- `%.cpp.alpha` : Runs the C preprocessor (`cpp -P -x c`) on a `.alpha` source file to add library alpha code from `#include` (e.g., `library.alpha`) and produces a preprocessed `.cpp.alpha` file of pure alpha code.
- `%.s` : Invokes the `alpha` compiler with `-tok -st -asc -tc -ir -cg` on the preprocessed source to emit token, symbol table, type-checking, IR code, and x86-64 assembly outputs.

### Running an Alpha Program

- `make <name>` : Requires `<name>` to be the name of a `<name>.alpha` file. It preprocesses `<name>.alpha`, compiles it to assembly via the `alpha` compiler with all the flags & then links the resulting `.s` file with the alpha standard library (`lib/alpha_lib_st.s`) and the alpha driver (`lib/alpha_driver.s`) using `gcc` to produce an executable named `<name>`.

#### Example
To build the alpha compiler
```bash
make compiler        # build the alpha compiler
```

To compile an alpha file
```bash
make proj/gameoflife # compile and link proj/gameoflife.alpha into an executable
./proj/gameoflife    # run the program
make clean           # remove all generated artifacts
```

## Credits

Special thanks to Carl Alphonce and Meyer Simon.

## Contributors

- Pranav Acharya
- Het Patel
- Indigo Hawk
- Greg Fiegel