TARGET := smc

BUILD_DIR := build

C_MAIN  := src/smc.o
C_SRCS  := $(wildcard src/*.c)
C_OBJS  := $(C_SRCS:.c=.o)

FRAMEWORKS   := IOKit
INCLUDE_DIRS := /usr/local/include
DIRS         := /usr/local/lib

OPTIMIZATION := -O3
include config.mk

STD  := -std=c99 -pedantic
WARN := -Wall -W -Wextra

CFLAGS += -arch x86_64 -mmacosx-version-min=10.14

CFLAGS += $(foreach includedir,$(INCLUDE_DIRS),-I$(includedir))
CFLAGS += $(foreach framework,$(FRAMEWORKS),-framework $(framework))
CFLAGS += -DVERSION=\"${VERSION}\" $(OPTIMIZATION) $(STD) $(WARN)

LDFLAGS += $(foreach libdir,$(DIRS),-L$(libdir))
# LDFLAGS += $(foreach lib,$(LIBRARIES),-l$(lib))

.PHONY: all check clean distclean $(TARGET)


all: builddir $(TARGET)

$(C_OBJS): $(C_SRCS)
	@echo "Compiling C objects"
	$(CC) $(CFLAGS) $(LDFLAGS) -c $(C_SRCS) -o src/$(TARGET).o $(LDFLAGS)
	@echo

$(TARGET): $(C_OBJS)
	@echo "Compiling code"
	# $(CC) $(C_OBJS) -o $(BUILD_DIR)/$(TARGET) $(LDFLAGS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(BUILD_DIR)/$(TARGET) $(C_OBJS)
	@echo

install: all
	@echo "Creating required directories"
	@mkdir -p $(PREFIX)/bin $(MANPREFIX)/man1

	@echo "Installing binary to $(PREFIX)/bin"
	@cp -f $(BUILD_DIR)/$(TARGET) $(PREFIX)/bin

	@echo "Installing manpage to $(MANPREFIX)/man1"
	@sed "s/VERSION/$(VERSION)/g" < $(TARGET).1 > $(MANPREFIX)/man1/$(TARGET).1

	@echo "Fixing permissions"
	@chmod 644 $(MANPREFIX)/man1/$(TARGET).1
	@chmod 755 $(PREFIX)/bin/$(TARGET)
	@echo

uninstall:
	@echo "Removing binary from $(PREFIX)/bin"
	@rm -f $(PREFIX)/bin/$(TARGET)


## Misc ##

builddir:
	@echo "Creating build directory"
	@mkdir -p build
	@echo

clean:
	@- echo "Removing build directory"
	@- $(RM) -rf build
	@- echo "Removing build files"
	@- find . -iname "*.o" -o -iname "*.swm" -o -iname "*.swn" -o -iname "*.swo" -o -iname "*.swp" -o -iname ".DS_Store" -o -iname "._*" -o -iname "build" -o -iname "build-rpm" -o -iname "vgcore*" -exec rm -f {} \;
	@- echo "Removing C objects '$(C_OBJS)'"
	@- $(RM) -f $(C_OBJS)
	@- echo

distclean: clean

remove_optimization:
	@echo "Removing optimization"
	$(eval CFLAGS := $(filter-out $(OPTIMIZATION), $(CFLAGS)))
	@echo


define OBJECT_DEPENDS_ON_CORRESPONDING_HEADER
	$(1) : ${1:.o=.h}
endef
