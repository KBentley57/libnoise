SHELL:=/bin/bash

CXXFLAGS:= -std=c++17 -fpic -g -O3 -march=native -msse2
CC:= gcc
CXX:= g++

CP = cp
DOXYGEN = doxygen
INSTALL = install
MKDIR = mkdir
MV = mv

# Default prefix is always /usr/local.  override with make PREFIX=PATH.
PREFIX:= /usr/local
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
	$(INSTALL) -D -m 0644 lib/libnoise.so.1.0.0 $(LIBDIR)/libnoise.so.1.0.0
	cd $(LIBDIR) && ln -sf libnoise.so.1.0.0 libnoise.so	
	$(MKDIR) -m 0755 -p $(INCLUDEDIR)/noise/model $(INCLUDEDIR)/noise/module
	$(CP) -a include/* $(INCLUDEDIR)
	cd $(INCLUDEDIR) && ln -sf noise/noiseutils.h noiseutils.h
	$(MKDIR) -m 0755 -p $(DOCS)/libnoise
	$(CP) -a doc/html/* $(DOCS)/libnoise
	$(MKDIR) -m 0755 -p $(MANDIR)/man3
	$(CP) -a doc/man/man3/* $(MANDIR)/man3

EXAMPLE_BIN:= complexplanet granite sky wood jade slime worms

complexplanet: examples/complexplanet.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -I/usr/include -L./lib -o bin/$@ $^ -lnoise 

granite: examples/texturegranite.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -L./lib -o bin/$@ $^ -lnoise 

sky: examples/texturesky.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -L./lib -o bin/$@ $^ -lnoise 

wood: examples/texturewood.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -L./lib -o bin/$@ $^ -lnoise 

jade: examples/texturejade.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -L./lib -o bin/$@ $^ -lnoise 

slime: examples/textureslime.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -L./lib -o bin/$@ $^ -lnoise 

worms: examples/worms.cpp
	$(MKDIR) -p bin
	$(CXX) $(CXXFLAGS) -I./include -I/usr/include -L./lib -o bin/$@ $^ -lnoise -lGL -lGLU -lglut

.PHONY: example
example: all $(EXAMPLE_BIN)

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
	cd lib && ln -sf libnoise.so.1.0.0 libnoise.so	

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
	$(RM) -rf lib bin include doc/man doc/html

%.o : %.cpp
	$(CXX) $(CXXFLAGS) -I$(PWD)/include -c -o $@ $^
