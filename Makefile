SHELL:=/bin/bash

CXXFLAGS:= -std=c++17 -fpic -O3 -march=native -mtune=native 
CC:= gcc
CXX:= g++

DOXYGEN = doxygen
INSTALL = install
MKDIR = mkdir
MV = mv

PREFIX:= $(HOME)
BINDIR:= $(PREFIX)/bin
INCLUDE:= $(PREFIX)/include
LIBDIR:= $(PREFIX)/lib
SHARE:= $(PREFIX)/share
DOCS:= $(SHARE)/doc
MANDIR := $(SHARE)/man

MODULE_HEADERS:=$(wildcard $(PWD)/src/module*.h)
MODEL_HEADERS:=$(wildcard $(PWD)/src/model*.h)

MODULE_SOURCES:=$(wildcard $(PWD)/src/module/*.cpp)
MODEL_SOURCES:=$(wildcard $(PWD)/src/model/*.cpp)

MODULE_OBJECTS:=$(patsubst %.cpp,%.o,$(MODULE_SOURCES))
MODEL_OBJECTS:=$(patsubst %.cpp,%.o,$(MODEL_SOURCES))

.PHONY: all
all: libnoise.so.1.0.0 docs 

.PHONY:install
install: all
	$(INSTALL) -D -m 0644 lib/libnoise.so.1.0.0 -t $(LIBDIR)
	cd $(LIBDIR) && ln -s libnoise.so.1.0.0 libnoise.so	
	$(INSTALL) -D -m 0644 src/*.h -t $(INCLUDE)/noise
	$(INSTALL) -D -m 0644 src/model/*.h -t $(INCLUDE)/noise/model
	$(INSTALL) -D -m 0644 src/module/*.h -t $(INCLUDE)/noise/module
	$(MAKE) -C $(PWD)/doc/latex
	$(INSTALL) -D -m 0644 $(PWD)/doc/latex/refman.pdf -T $(DOCS)/libnoise1.pdf
	$(INSTALL) -D -m 0644 doc/man/man3/* -t $(MANDIR)/man3

.PHONY: uninstall
uninstall:
	$(RM) $(LIBDIR)/libnoise.so*
	$(RM) -rf $(DOCS)/libnoise1.pdf
	$(RM) -rf $(MANDIR)/man3/*
	$(RM) -rf $(INCLUDE)/model
	$(RM) -rf $(INCLUDE)/module
	
libnoise.so.1.0.0: $(MODULE_OBJECTS) $(MODEL_OBJECTS) 
	$(MKDIR) -p $(PWD)/lib
	$(CXX) $(CXXFLAGS) -shared -o $(PWD)/lib/$@ $^

# The docs section requires a fairly extensive set of tex packages
# If tex is not available on the system, edit the Doxyfile to turn 
# Tex documentation off.
.PHONY: docs
docs: $(MODULE_SOURCES) $(MODEL_SOURCES) $(MODEL_HEADERS) $(MODULE_HEADERS)
	cd $(PWD)/doc && $(DOXYGEN) Doxyfile
	
.PHONY: clean
clean:
	$(RM) $(MODULE_OBJECTS) $(MODEL_OBJECTS)
	$(MAKE) -C $(PWD)/doc/latex clean

.PHONY: clobber
clobber: clean
	$(RM) -rf $(PWD)/lib $(PWD)/doc/latex $(PWD)/doc/man

%.o : %.cpp
	$(CXX) $(CXXFLAGS) -I./src -I./src/module -I./src/model -c -o $@ $^