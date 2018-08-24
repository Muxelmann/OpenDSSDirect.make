# https://github.com/NREL/OpenDSSDirect.py
# https://github.com/tshort/OpenDSSDirect.jl

UNAME_S        := $(shell uname)
ARCH_S         := $(shell uname -m)

SOURCE          = _source/
LIB_DIR         = _lib/
OPENDSS_DIR     = $(SOURCE)electricdss/
KLUSOLVE_DIR    = $(SOURCE)KLUSolve/

# For Linux
ifeq ($(UNAME_S),Linux)
CC              = ppcx64
CFLAGS                                  = @linuxopts.cfg
GCCLIB         := $(shell gcc --print-file-name=)
LDFLAGS                                 = -k-L$(GCCLIB)
ARCH_SUFFIX     = .a
LIB_SUFFIX      = .so
ifeq ($(ARCH_S),x86_64)
CC              = ppcx64
UNIT_DIR        = x86_64-linux/
else ifeq ($(ARCH_S),i686)
$(error Architecture $(ARCH_S) on $(UNAME_S) not supported)
else ifneq ($(findstring arm,$(ARCH_S)),)
$(error Architecture $(ARCH_S) on $(UNAME_S) not supported)
else
$(error Architecture $(ARCH_S) on $(UNAME_S) not supported)
endif
endif

# For Darwin (e.g. macOS)
ifeq ($(UNAME_S),Darwin)
CFLAGS          = @fpcopts.cfg
ARCH_SUFFIX     = .dylib
LIB_SUFFIX      = .dylib
ifeq ($(ARCH_S),x86_64)
CC              = ppcx64
UNIT_DIR        = x86_64-darwin/
else
$(error Architecture $(ARCH_S) on $(UNAME_S) not supported)
endif
endif


KLUSOLVE_URL    = https://svn.code.sf.net/p/klusolve/code/
KLUSOLVE_OUT    = libklusolve
KLUSOLVE_LIB    = $(KLUSOLVE_DIR)Lib/
KLUSOLVE_TEST   = $(KLUSOLVE_DIR)Test/
KLUSOLVE_OBJ    = $(KLUSOLVE_DIR)KLUSolve/Obj/
KLUSOLVE_VER   := .r`svnversion $(abspath $(KLUSOLVE_DIR))`

OPENDSS_URL     = https://svn.code.sf.net/p/electricdss/code/trunk/Source/
OPENDSS_OUT     = libOpenDSSDirect
OPENDSS_PROJ	  = OpenDSSDirect.lpr
OPENDSS_TMP     = $(OPENDSS_DIR)Tmp/
OPENDSS_LIB     = $(OPENDSS_DIR)DDLL/
OPENDSS_VER    := .r`svnversion $(abspath $(OPENDSS_DIR))`

KLUSOLVE_DLL   += $(shell pwd)/$(LIB_DIR)$(UNIT_DIR)


.PHONY: all
all:
#ifneq ($(findstring arm,$(ARCH_S)),)
#	$(error ARM NOT YET IMPLEMENTED! Architecture $(ARCH_S) on $(UNAME_S) not supported for `make`)
#endif
	make KLUSolve
	make electricdss

# KLUSolve repo management

.PHONY: KLUSolve
KLUSolve: $(KLUSOLVE_DIR)
	svn update $<
	make -C $(KLUSOLVE_DIR) all || make -C $(KLUSOLVE_DIR) all
ifeq ($(UNAME_S),Darwin)
	install_name_tool -id @rpath/$(KLUSOLVE_OUT)$(ARCH_SUFFIX) $(KLUSOLVE_LIB)$(KLUSOLVE_OUT)$(ARCH_SUFFIX)
	otool -L $(KLUSOLVE_LIB)$(KLUSOLVE_OUT)$(ARCH_SUFFIX)
endif
	mkdir -p $(LIB_DIR)$(UNIT_DIR)
	cp $(KLUSOLVE_LIB)$(KLUSOLVE_OUT)$(ARCH_SUFFIX) $(LIB_DIR)$(UNIT_DIR)$(KLUSOLVE_OUT)$(KLUSOLVE_VER)$(ARCH_SUFFIX)
	cd $(KLUSOLVE_DLL) && \
	ln -sf $(KLUSOLVE_OUT)$(KLUSOLVE_VER)$(ARCH_SUFFIX) $(KLUSOLVE_OUT)$(ARCH_SUFFIX)

$(KLUSOLVE_DIR):
	mkdir -p $@
	svn checkout $(KLUSOLVE_URL) $@
	mkdir -p $(KLUSOLVE_LIB)
	mkdir -p $(KLUSOLVE_TEST)
ifeq ($(UNAME_S),Darwin)
	mkdir -p $(KLUSOLVE_OBJ)
endif

# OpenDSS repo management

.PHONY: electricdss
electricdss: $(OPENDSS_DIR)
	svn update $<
	cd $(OPENDSS_LIB) && mkdir -p units && $(CC) $(CFLAGS) $(LDFLAGS) -Fl$(KLUSOLVE_DLL) -B $(OPENDSS_PROJ)
ifeq ($(UNAME_S),Darwin)
	install_name_tool -id @rpath/$(OPENDSS_OUT)$(LIB_SUFFIX) $(OPENDSS_LIB)$(OPENDSS_OUT)$(LIB_SUFFIX)
	install_name_tool -change ../Lib/libklusolve.dylib @rpath/$(KLUSOLVE_OUT)$(ARCH_SUFFIX) $(OPENDSS_LIB)$(OPENDSS_OUT)$(LIB_SUFFIX)
	otool -L $(OPENDSS_LIB)$(OPENDSS_OUT)$(LIB_SUFFIX)
endif
	mkdir -p $(LIB_DIR)$(UNIT_DIR)
	cp $(OPENDSS_LIB)$(OPENDSS_OUT)$(LIB_SUFFIX) $(LIB_DIR)$(UNIT_DIR)$(OPENDSS_OUT)$(OPENDSS_VER)$(LIB_SUFFIX)
	cd $(LIB_DIR)$(UNIT_DIR) && \
	ln -sf $(OPENDSS_OUT)$(OPENDSS_VER)$(LIB_SUFFIX) $(OPENDSS_OUT)$(LIB_SUFFIX)

$(OPENDSS_DIR):
	mkdir -p $@
	svn checkout $(OPENDSS_URL) $@
	mkdir -p $(OPENDSS_TMP)
	mkdir -p $(OPENDSS_LIB)

# Cleaning

.PHONY: clean
clean:
	rm -rf $(OPENDSS_TMP)*.*
	rm -rf $(OPENDSS_LIB)units
	rm -rf $(OPENDSS_LIB)*.so
	make -C $(KLUSOLVE_DIR) clean

.PHONY: clean_all
clean_all:
	sudo rm -rf $(SOURCE)

reset: clean_all
	sudo rm -rf $(LIB_PY)
	sudo rm -rf $(LIB_JL)

# Setup functions

.PHONY: setup
setup:
ifeq ($(UNAME_S),Linux)
	sudo apt update
	sudo apt install build-essential subversion
ifneq ($(findstring 3.,$(shell apt policy fpc | grep 'Candidate:' | cut -f2- -d:)),)
# FPC is version 3.x -> use apt version
	sudo apt install fpc
else
# FPC not version 3.x -> use upstream version
	@ sudo ln -sfv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so
	@ sudo ln -sfv /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so
	@ wget https://sourceforge.net/projects/freepascal/files/Linux/3.0.2/fpc-3.0.2.x86_64-linux.tar  && \
	tar -xvf fpc-3.0.2.x86_64-linux.tar && \
	cd fpc-3.0.2.x86_64-linux && sudo ./install.sh </dev/null && cd .. && rm -rf fpc*
endif
else ifeq ($(UNAME_S).$(ARCH_S),Darwin.x86_64)
	brew update
	command -v fpc >/dev/null 2>&1 && brew upgrade fpc || brew install fpc
	command -v svn >/dev/null 2>&1 && brew upgrade subversion || brew install subversion
else
	$(error Architecture $(ARCH_S) on $(UNAME_S) not supported for `make setup`)
endif

.PHONY: setup_test
setup_test:
ifeq ($(UNAME_S).$(ARCH_S),Linux.x86_64)
	sudo apt install python3
else ifeq ($(UNAME_S).$(ARCH_S),Darwin.x86_64)
	command -v python3 >/dev/null 2>&1 || brew install python3
else ifneq ($(findstring arm,$(ARCH_S)),)
	sudo apt install python3
else
	$(error Architecture $(ARCH_S) on $(UNAME_S) not supported for `make setup_test`)
endif

# # Build for 64bit ARM
#
# arm: $(OPENDSS_TMP) $(OPENDSS_LIB) update_klusolve update_dss
# 	$(CC) \
# 	-Parm  $(MACROS_LINUX) \
# 	$(FPC_DIRS) $(LIB_DIRS) $(USE_DIRS) -Fu$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
# 	-Fl/usr/lib/gcc/arm-linux-gnueabihf/4.9/ \
# 	-o$(OPENDSS_OUT) \
# 	$(CFLAGS) \
# 	$(OPENDSS_DIR)/DDLL/OpenDSSDirect.lpr
#
# # Bild for x86_64 on Linux and delete unnecessary files afterwards
#
# light_arm: arm
# 	rm -fr $(OPENDSS_TMP)

# setup_RPi:
# 	# sudo apt-get update
# 	# sudo apt-get upgrade
# 	sudo apt-get install build-essential subversion
# 	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libstdc++.so.6 /usr/lib/arm-linux-gnueabihf/libstdc++.so
# 	sudo ln -sfv /lib/arm-linux-gnueabihf/libgcc_s.so.1 /lib/arm-linux-gnueabihf/libgcc_s.so
# 	# Install FPC 3.0.2
# 	# wget ftp://ftp.hu.freepascal.org/pub/fpc/dist/3.0.2/arm-linux/fpc-3.0.2.arm-linux-eabihf-raspberry.tar
# 	# tar -xvf fpc-3.0.2.arm-linux-eabihf-raspberry.tar
# 	# cd fpc-3.0.2.arm-linux && sudo ./install.sh
# 	# Install FPC 3.0.0
# 	wget ftp://ftp.hu.freepascal.org/pub/fpc/dist/3.0.0/arm-linux/fpc-3.0.0.arm-linux-raspberry1wq.tar
# 	tar -xvf fpc-3.0.0.arm-linux-raspberry1wq.tar
# 	cd fpc-3.0.0.arm-linux && sudo ./install.sh
