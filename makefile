PARSER = src/parser
LEXER = src/lexer
EXEC = tpcas

CC = gcc
CFLAGS = -Wall 

TEST_GOOD = $(wildcard test/good/*.tpc)
TEST_SYN_ERR = $(wildcard test/syn-err/*.tpc)

all: $(EXEC)

$(EXEC): $(LEXER).yy.o $(PARSER).tab.o src/tree.c
	$(CC) $(CFLAGS) -o $@ $^
	@mv src/parser.tab.o obj
	@mv src/lexer.yy.o obj
	@mkdir -p bin
	@mv $(EXEC) bin

$(PARSER).tab.c $(PARSER).tab.h: $(PARSER).y
	bison -d $<
	@mv parser.tab.h src
	@mv parser.tab.c src

$(LEXER).yy.c: $(LEXER).lex $(PARSER).tab.h
	flex -o $@ $<

clean:
	@echo "Nettoyage fichiers"
	@rm -f $(PARSER).tab.o $(PARSER).tab.c $(PARSER).tab.h
	@rm -f $(LEXER).yy.o $(LEXER).yy.c bin/$(EXEC)
	@rm -f obj/lexer.yy.o obj/parser.tab.o

test: all
	@echo "Running tests..."; \
	sh -c ' \
	PASS_GOOD=0; FAIL_GOOD=0; PASS_ERR=0; FAIL_ERR=0; \
	for file in $(TEST_GOOD); do \
		if bin/./$(EXEC) < "$$file" > /dev/null 2>&1; then \
			PASS_GOOD=$$(($$PASS_GOOD + 1)); \
		else \
			FAIL_GOOD=$$(($$FAIL_GOOD + 1)); \
		fi; \
	done; \
	for file in $(TEST_SYN_ERR); do \
		if bin/./$(EXEC) < "$$file" > /dev/null 2>&1; then \
			PASS_ERR=$$(($$PASS_ERR + 1)); \
		else \
			FAIL_ERR=$$(($$FAIL_ERR + 1)); \
		fi; \
	done; \
	echo "Good files passed: $$PASS_GOOD, failed: $$FAIL_GOOD"; \
	echo "Syn-err files failed: $$FAIL_ERR, passed: $$PASS_ERR"; \
	echo "Total unexpected failures: $$((FAIL_GOOD + PASS_ERR))"; \
	'
