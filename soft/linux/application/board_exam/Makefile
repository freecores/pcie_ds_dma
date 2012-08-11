#
#change this makefile for your target...
#

PHONY = clean
TARGET_NAME = pex_board_test

all: $(TARGET_NAME)

ROOT_DIR = $(shell pwd)

CC = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)g++

CFLAGS := -D__LINUX__ -g -Wall -I../../driver/pexdrv -I../../common/board -I../../common/pex -I../adm_test/src/utils
LFLAGS := -Wl
SRCDIR := ../../common/board ../../common/pex
#SRCFILE := $(wildcard *.cpp) $(wildcard $(SRCDIR)/*.cpp)
SRCFILE := $(wildcard *.cpp) $(wildcard ../../common/board/*.cpp)
SRCFILE += $(wildcard *.cpp) $(wildcard ../../common/pex/*.cpp)
OBJFILE := $(patsubst %.cpp,%.o, $(SRCFILE))

$(TARGET_NAME): $(OBJFILE)
	$(LD) $(LFLAGS) $(notdir $^) -o $(TARGET_NAME)
	rm -f *.o *~ core

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
