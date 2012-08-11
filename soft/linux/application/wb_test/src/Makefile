#
#change this makefile for your target...
#

PHONY = clean
TARGET_NAME = wb_test

all: $(TARGET_NAME)

ROOT_DIR = $(shell pwd)

CC = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)g++

CFLAGS := -D__LINUX__ -g -Wall -I./board -I./pex -I./work -I./utils
LFLAGS := -Wl -ldl -lrt -lpthread
SRCDIR := board pex work utils
#SRCFILE := $(wildcard *.cpp) $(wildcard $(SRCDIR)/*.cpp)
SRCFILE := $(wildcard *.cpp)
SRCFILE += $(wildcard pex/*.cpp) $(wildcard board/*.cpp) $(wildcard work/*.cpp) $(wildcard utils/*.cpp)
OBJFILE := $(patsubst %.cpp,%.o, $(SRCFILE))

$(TARGET_NAME): $(OBJFILE)
	$(LD) -o $(TARGET_NAME) $(notdir $^) $(LFLAGS)

#	rm -f *.o *.d *~ core
	mv $(TARGET_NAME) ../bin
	@echo DONE...

%.o: %.cpp
	$(CC) $(CFLAGS) -c -MD $<
	
include $(wildcard *.d)


clean:
	rm -f *.o *~ core
	rm -f *.d *~ core
	rm -f $(TARGET_NAME)
	
distclean:
	rm -f *.o *~ core
	rm -f *.d *~ core
	rm -f $(TARGET_NAME)

src:
	@echo $(SRCFILE)
	@echo $(OBJFILE)
