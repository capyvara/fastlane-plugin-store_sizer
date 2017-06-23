HELLO_SRC    = hello.c

ARCH_FLAGS   =
%armv7           : ARCH_FLAGS = -arch armv7
%arm64           : ARCH_FLAGS = -arch arm64
%fat-armv7-arm64 : ARCH_FLAGS = -arch armv7 -arch arm64
%i386            : ARCH_FLAGS = -arch i386
%x86_64          : ARCH_FLAGS = -arch x86_64
%fat-i386-x86_64 : ARCH_FLAGS = -arch i386 -arch x86_64

SDK_FLAGS   =
%armv7           : SDK_FLAGS = -sdk iphoneos
%arm64           : SDK_FLAGS = -sdk iphoneos
%fat-armv7-arm64 : SDK_FLAGS = -sdk iphoneos
%i386            : SDK_FLAGS = -sdk iphonesimulator
%x86_64          : SDK_FLAGS = -sdk iphonesimulator
%fat-i386-x86_64 : SDK_FLAGS = -sdk iphonesimulator

# Make sure we're on OS X.
UNAME_S := $(shell uname -s)
ifneq ($(UNAME_S),Darwin)
  $(error This makefile can only be run on OS X, but detected $(UNAME_S))
endif

BIN_DIR := ../bin
ALL_ARCHS := armv7 arm64 fat-armv7-arm64 i386 x86_64 fat-i386-x86_64
ALL_TARGETS := $(addprefix $(BIN_DIR)/,$(ALL_ARCHS))

.PHONY: all clean

all: $(ALL_TARGETS)

$(BIN_DIR) : 
	mkdir -p $(BIN_DIR)

$(BIN_DIR)/%: $(HELLO_SRC) $(BIN_DIR)
	xcrun $(SDK_FLAGS) cc $(ARCH_FLAGS) -o $@ $<

clean:
	rm -rf $(BIN_DIR)