# smc version
VERSION = 0.0.1

# Paths
PREFIX    = /usr/local
MANPREFIX = $(PREFIX)/share/man
LIBPREFIX = $(PREFIX)/lib/smc-command

# Compiler and linker based on OS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	CC = gcc-8
endif
