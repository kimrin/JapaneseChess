SRCDIR := ./src
HDRDIR := ./src
BINDIR := ./bin
LIBDIR := ./lib

CPPFILES := Main
HFILES := Shogi
ADDCPPFILES := 
PROGNAME := MechaJyo
LIBNAME  := libMJ

PROGRAM := $(BINDIR)/$(PROGNAME)

LIBRARY_MAJOR := 1
LIBRARY_MINOR := 0
LIBLINKMAJOR := $(LIBNAME).so.$(LIBRARY_MAJOR)
LIBLINKMINOR := $(LIBNAME).so.$(LIBRARY_MAJOR).$(LIBRARY_MINOR)
LIBRARY := $(LIBDIR)/$(LIBLINKMINOR)

MWSRCS := $(addsuffix .cpp,$(addprefix $(SRCDIR)/,$(CPPFILES)))
MWHDRS := $(addsuffix .h,$(addprefix $(HDRDIR)/,$(HFILES)))

CXX := g++
LN  := ln
CD  := cd
LD  := ld
INCDIRS := -I. -I/usr/include -I$(HDRDIR)
PG  := -pg

#CFLAGS := -g -Wall -O1 -fPIC -fno-inline
CFLAGS := -g -Wall -O3 -fPIC
#CFLAGS := -g -Wall -O3
CONCATLIB := -lm #-ldb-4.8 -lpthread

all: executable # sharedlib

executable: $(PROGRAM)

$(PROGRAM): $(MWSRCS) $(ADDCPPFILES)
	$(CXX) $(CFLAGS) $(INCDIRS) $(MWSRCS) -o $@ $(CONCATLIB)

sharedlib: $(LIBRARY)

$(LIBRARY): $(MWSRCS) $(ADDCPPFILES)
	$(CXX) -shared $(CFLAGS) $(INCDIRS) $(MWSRCS) -o $@ $(CONCATLIB)
	$(LN) -s $(LIBLINKMINOR) $(LIBDIR)/$(LIBLINKMAJOR)

#$(MWOBJS): $(MWSRCS)
#	$(CXX) -c $(INCDIRS) $(CFLAGS) $<

.PHONY : clean
clean:
	rm -f $(LIBRARY) $(LIBDIR)/$(LIBLINKMAJOR) $(PROGRAM)
