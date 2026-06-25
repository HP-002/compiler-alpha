CC = gcc
LEX = flex
YACC = bison -Wno-empty-rule
CFLAGS = -Wall -Wextra -g -Wno-unused-function
CPPFLAGS =
LFLAGS =
YFLAGS = -d -v -W
RM = rm -f
ALPHALIB = ./lib
CPP = cpp -P -x c -o
ALPHA = ./alpha
ALPHAFLAGS = -tok -st -asc -tc -ir -cg

ALPHA_LIB = ./lib/alpha_lib_st.s
ALPHA_DRIVER = ./lib/alpha_driver.s

objects = runner.o lex.yy.o grammar.tab.o symbol_table.o ir.o cg.o

.PHONY: compiler clean
compiler: $(objects)
	$(CC) $(CFLAGS) -o alpha $(objects) -lfl

grammar.tab.c grammar.tab.h: grammar.y
	$(YACC) $(YFLAGS) grammar.y

lex.yy.c: compiler.lex grammar.tab.h
	$(LEX) $(LFLAGS) -o $@ compiler.lex

runner.o: runner.c grammar.tab.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<

lex.yy.o: lex.yy.c grammar.tab.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<

grammar.tab.o: grammar.tab.c grammar.tab.h
	$(CC) $(CFLAGS) -c grammar.tab.c

symbol_table.o: symboltable.c include/symbol_table.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<

%.cpp.alpha: %.alpha
	cp $< $(ALPHALIB)/test.alpha
	$(CPP) $(CPPFLAGS) $(ALPHALIB)/test.cpp.alpha $(ALPHALIB)/test.alpha
	mv $(ALPHALIB)/test.cpp.alpha $@
	rm $(ALPHALIB)/test.alpha

%.s: compiler %.cpp.alpha
	$(ALPHA) $(ALPHAFLAGS) $*.cpp.alpha

%: %.s
	cp $*.cpp.s $(ALPHALIB)/test.s
	@gcc $(ALPHALIB)/test.s $(ALPHA_LIB) $(ALPHA_DRIVER) -no-pie -o $(ALPHALIB)/test
	rm $(ALPHALIB)/test.s
	mv $(ALPHALIB)/test $*

clean:
	$(RM) *.o lex.yy.c grammar.tab.c grammar.tab.h grammar.output alpha
	find . -type f -regextype posix-egrep -regex ".*\.(tok|o|st|asc|ir|s|cpp.alpha)$$" -not -path '$(ALPHALIB)/*.s' -delete
	find . -type f -not -name "*.*" -not -path '$(ALPHALIB)/*.s' -not -path './.git/*' -not -path './Makefile' -delete

