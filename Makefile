default: build/mujs

CFLAGS = -std=c99 -pedantic -Wall -Wextra -Wno-unused-parameter
CXXFLAGS = -std=c++11 -pedantic -Wall -Wextra -Wno-unused-parameter -fsanitize=fuzzer
OPTIM = -O3 -s
CFLAGS += $(OPTIM)
CXXFLAGS += $(OPTIM)
CC=afl-clang-lto
CXX=afl-clang-lto++

HDRS = mujs.h jsi.h regexp.h utf.h astnames.h opnames.h
READLINE_CFLAGS = -DHAVE_READLINE
READLINE_LIBS = -lreadline

SRCS = \
 jsarray.c \
 jsboolean.c \
 jsbuiltin.c \
 jscompile.c \
 jsdate.c \
 jsdtoa.c \
 jserror.c \
 jsfunction.c \
 jsgc.c \
 jsintern.c \
 jslex.c \
 jsmath.c \
 jsnumber.c \
 jsobject.c \
 json.c \
 jsparse.c \
 jsproperty.c \
 jsregexp.c \
 jsrepr.c \
 jsrun.c \
 jsstate.c \
 jsstring.c \
 jsvalue.c \
 regexp.c \
 utf.c

OBJS = $(patsubst %.c,build/%.o,$(SRCS))

astnames.h: jsi.h
	grep -E '\<(AST|EXP|STM)_' jsi.h | sed 's/^[^A-Z]*\(AST_\)*/"/;s/,.*/",/' | tr A-Z a-z > $@

opnames.h: jsi.h
	grep -E '\<OP_' jsi.h | sed 's/^[^A-Z]*OP_/"/;s/,.*/",/' | tr A-Z a-z > $@

UnicodeData.txt:
	curl -s -o $@ https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt

utfdata.h: genucd.py UnicodeData.txt
	python3 genucd.py UnicodeData.txt >$@

build/mujs: build/main.o $(OBJS) $(HDRS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -o $@ $< $(OBJS) -lm $(READLINE_CFLAGS) $(READLINE_LIBS)

build/main.o: main.cpp $(HDRS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

build/%.o: %.c $(HDRS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf build

nuke: clean
	rm -f astnames.h opnames.h UnicodeData.txt utfdata.h