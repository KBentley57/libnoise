SHELL:=/bin/bash

CXXFLAGS:= -std=c++17 -fpic -g
CC:= gcc
CXX:= g++

CP = cp
DOXYGEN = doxygen
INSTALL = install
MKDIR = mkdir
MV = mv

PREFIX:= $(HOME)
BINDIR:= $(PREFIX)/bin
INCLUDEDIR:= $(PREFIX)/include
LIBDIR:= $(PREFIX)/lib
SHARE:= $(PREFIX)/share
DOCS:= $(SHARE)/doc
MANDIR := $(SHARE)/man

MODULE_HEADERS:=$(wildcard $(PWD)/src/module/*.h)
MODEL_HEADERS:=$(wildcard $(PWD)/src/model/*.h)
UTIL_HEADERS:=$(wildcard $(PWD)/src/*.h)

MODULE_SOURCES:=$(wildcard $(PWD)/src/module/*.cpp)
MODEL_SOURCES:=$(wildcard $(PWD)/src/model/*.cpp)
UTIL_SOURCES:=$(wildcard $(PWD)/src/*.cpp)

MODULE_OBJECTS:=$(patsubst %.cpp,%.o,$(MODULE_SOURCES))
MODEL_OBJECTS:=$(patsubst %.cpp,%.o,$(MODEL_SOURCES))
UTIL_OBJECTS:=$(patsubst %.cpp,%.o,$(UTIL_SOURCES))

.PHONY: default
default: all

.PHONY: all
all: includes libnoise.so.1.0.0 docs 

.PHONY:install
install: all
	$(INSTALL) -D -m 0644 lib/libnoise.so.1.0.0 -t $(LIBDIR)
	ln -sf $(LIBDIR)/libnoise.so.1.0.0 $(LIBDIR)/libnoise.so	
	for i in ${UTIL_HEADERS}; do \
		$(INSTALL) -D -m 0644 $${i} -t $(INCLUDEDIR)/noise; done 
	for i in ${MODEL_HEADERS}; \
		do $(INSTALL) -D -m 0644 $${i} -t $(INCLUDEDIR)/noise/model; done 
	for i in ${MODULE_HEADERS}; \
		do $(INSTALL) -D -m 0644 $${i} -t $(INCLUDEDIR)/noise/module; done 
	ln -sfr $(INCLUDEDIR)/noise/noiseutils.h $(INCLUDEDIR)
	$(INSTALL) -D -m 0644 doc/html/* -t $(DOCS)/libnoise
	$(INSTALL) -D -m 0644 doc/man/man3/* -t $(MANDIR)/man3


.PHONY: example
example: texturegranite

.PHONY: texturegranite
texturegranite: $(PWD)/examples/texturegranite.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -L./lib -o bin/$@ $^ -lnoise


.PHONY: uninstall
uninstall:
	$(RM) $(LIBDIR)/libnoise.so*
	$(RM) -rf $(MANDIR)/man3/*
	$(RM) -rf $(DOCS)/libnoise
	$(RM) -rf $(INCLUDEDIR)/noise
	$(RM) -rf $(INCLUDEDIR)/noiseutils.h
 	
libnoise.so.1.0.0: $(MODULE_OBJECTS) $(MODEL_OBJECTS) $(UTIL_OBJECTS)
	$(MKDIR) -p $(PWD)/lib
	$(CXX) $(CXXFLAGS) -shared -o $(PWD)/lib/$@ -Wl,--start-group $^ -Wl,--end-group
	ln -sfr $(PWD)/lib/libnoise.so.1.0.0 $(PWD)/lib/libnoise.so	

.PHONY: includes
includes: moduleincludes modelincludes

.PHONY: moduleincludes
moduleincludes: utilincludes
	$(MKDIR) -p $(PWD)/include/noise/module
	$(CP) -a ${MODULE_HEADERS} include/noise/module

.PHONY: modelincludes
modelincludes: utilincludes
	$(MKDIR) -p $(PWD)/include/noise/model
	$(CP) -a ${MODEL_HEADERS} include/noise/model

.PHONY: utilincludes
utilincludes:
	$(MKDIR) -p $(PWD)/include/noise
	$(CP) -a ${UTIL_HEADERS} include/noise
	cd $(PWD)/include && ln -sf noise/noiseutils.h noiseutils.h

# The docs section requires a fairly extensive set of tex packages
# If tex is available on the system, edit the Doxyfile to turn 
# Tex documentation on/off.
.PHONY: docs
docs: $(MODULE_SOURCES) $(MODEL_SOURCES) $(MODEL_HEADERS) $(MODULE_HEADERS) \
$(UTIL_SOURCES) $(UTIL_HEADERS)
	cd $(PWD)/doc && $(DOXYGEN) Doxyfile
	
.PHONY: clean
clean:
	$(RM) $(MODULE_OBJECTS) $(MODEL_OBJECTS) $(UTIL_OBJECTS)

.PHONY: clobber
clobber: clean
	$(RM) -rf lib doc/man doc/html include

%.o : %.cpp
	$(CXX) $(CXXFLAGS) -I$(PWD)/include -c -o $@ $^