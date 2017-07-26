OPENDSS_DIR  ?= electricdss
KLUSOLVE_DIR ?= KLUSolve
TARGET       ?= dummy
UNAME        := $(shell uname)

CC            = fpc
MACROS_LINUX  = -MDelphi -Scghi -Ct -O2  -k-lc -k-lm -k-lgcc_s -k-lstdc++ -l -vewnhibq
MACROS_MACOS  = -MDelphi -Scghi -Ct -O2 -l -vewnhibq
CFLAGS        = -dBorland -dVer150 -dDelphi7 -dCompiler6_Up -dPUREPASCAL -dCPU64

KLUSOLVE_URL  = https://svn.code.sf.net/p/klusolve/code/
KLUSOLVE_LIB  = $(KLUSOLVE_DIR)/Lib
KLUSOLVE_TEST = $(KLUSOLVE_DIR)/Test
KLUSOLVE_OBJ  = $(KLUSOLVE_DIR)/KLUSolve/Obj

OPENDSS_URL   = https://svn.code.sf.net/p/electricdss/code/trunk/Source/
OPENDSS_TMP   = $(OPENDSS_DIR)/Tmp
OPENDSS_LIB   = $(OPENDSS_DIR)/Lib

OUT           = libopendssdirect
ARCH_S       ?= .dummy
LIB_S        ?= .dummy

INPUT_DIRS = \
-Fi$(OPENDSS_DIR)/LazDSS/Forms \
-Fi$(OPENDSS_DIR)/LazDSS/Shared \
-Fi$(OPENDSS_DIR)/LazDSS/Common \
-Fi$(OPENDSS_DIR)/LazDSS/PDElements \
-Fi$(OPENDSS_DIR)/LazDSS/Controls \
-Fi$(OPENDSS_DIR)/LazDSS/General \
-Fi$(OPENDSS_DIR)/LazDSS/Plot \
-Fi$(OPENDSS_DIR)/LazDSS/Meters \
-Fi$(OPENDSS_DIR)/LazDSS/PCElements \
-Fi$(OPENDSS_DIR)/LazDSS/Executive \
-Fi$(OPENDSS_DIR)/LazDSS/Parser \
-Fi$(OPENDSS_DIR)/LazDSS/units/x86_64-linux

# LIB_DIRS = -Fl$(OPENDSS_DIR)/LazDSS/lib
LIB_DIRS = -Fl$(KLUSOLVE_LIB)

USE_DIRS = \
-Fu$(OPENDSS_DIR)/LazDSS/Shared \
-Fu$(OPENDSS_DIR)/LazDSS/Common \
-Fu$(OPENDSS_DIR)/LazDSS/PDElements \
-Fu$(OPENDSS_DIR)/LazDSS/Controls \
-Fu$(OPENDSS_DIR)/LazDSS/General \
-Fu$(OPENDSS_DIR)/LazDSS/Meters \
-Fu$(OPENDSS_DIR)/LazDSS/PCElements \
-Fu$(OPENDSS_DIR)/LazDSS/Executive \
-Fu$(OPENDSS_DIR)/LazDSS/Parser \
-Fu$(OPENDSS_DIR)/LazDSS/DirectDLL \

all:
	@ if [ $(UNAME) = "Linux" ] ; then \
		make all_$(KLUSOLVE_DIR) all_$(OPENDSS_DIR) TARGET=linux ARCH_S=.a LIB_S=.so ; \
	elif [ $(UNAME) = "Darwin" ] ; then \
		make all_$(KLUSOLVE_DIR) all_$(OPENDSS_DIR) TARGET=macOS ARCH_S=.dylib LIB_S=.dylib ; \
	else  \
		echo "System not supported for making: \"$(UNAME)\"" ; \
	fi

# # Build for x86_64 on Linux
#
# all_linux: all_$(KLUSOLVE_DIR) all_$(OPENDSS_DIR) $(OPENDSS_TMP) $(OPENDSS_LIB)
#
# # Build for macOS
#
# all_macOS: all_$(KLUSOLVE_DIR) update_dss $(OPENDSS_TMP) $(OPENDSS_LIB)

# # Build for 64bit ARM
#
# arm: $(OPENDSS_TMP) $(OPENDSS_LIB) update_klusolve update_dss
# 	$(CC) \
# 	-Parm  $(MACROS_LINUX) \
# 	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -Fu$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
# 	-Fl/usr/lib/gcc/arm-linux-gnueabihf/4.9/ \
# 	-o$(OUT) \
# 	$(CFLAGS) \
# 	$(OPENDSS_DIR)/LazDSS/DirectDLL/OpenDSSDirect.lpr
#
# # Bild for x86_64 on Linux and delete unnecessary files afterwards
#
# light_arm: arm
# 	rm -fr $(OPENDSS_TMP)

# KLUSolve repo management

all_$(KLUSOLVE_DIR): $(KLUSOLVE_DIR)
	svn update $(KLUSOLVE_DIR)
	mkdir -p $(KLUSOLVE_LIB)
	mkdir -p $(KLUSOLVE_TEST)
	@ if [ $(TARGET) = 'macOS' ] ; then \
		mkdir -p $(KLUSOLVE_OBJ) ; \
	fi
	@ if [ -h $(KLUSOLVE_LIB)/libklusolve$(ARCH_S) ] ; then \
		rm $(KLUSOLVE_LIB)/libklusolve$(ARCH_S) ; \
	fi
	make -C $(KLUSOLVE_DIR) all || make -C $(KLUSOLVE_DIR) all
	make link_$(KLUSOLVE_DIR) ARCH_S=$(ARCH_S)

$(KLUSOLVE_DIR):
	mkdir -p $(KLUSOLVE_DIR)
	svn checkout $(KLUSOLVE_URL) $(KLUSOLVE_DIR)

# OpenDSS repo management

all_$(OPENDSS_DIR): $(OPENDSS_DIR)
	svn update $(OPENDSS_DIR)
	@ if [ $(TARGET) = "linux" ] ; then \
		$(CC) \
		-Px86_64 -Cg $(MACROS_LINUX) \
		$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -FU$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
		-o$(OUT)$(LIB_S) \
		$(CFLAGS) \
		$(OPENDSS_DIR)/LazDSS/DirectDLL/OpenDSSDirect.lpr && \
		make link_$(OPENDSS_DIR) LIB_S=$(LIB_S) ; \
	elif [ $(TARGET) = "macOS" ] ; then \
		$(CC) \
		-Px86_64 -Cg $(MACROS_MACOS) \
		$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -FU$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
		-o$(OUT)$(LIB_S) \
		$(CFLAGS) \
		$(OPENDSS_DIR)/LazDSS/DirectDLL/OpenDSSDirect.lpr && \
		make link_$(OPENDSS_DIR) LIB_S=$(LIB_S) ; \
	else \
		echo "Not supported: \"$(TARGET)\"" ; \
	fi

$(OPENDSS_DIR):
	mkdir -p $(OPENDSS_DIR)
	svn checkout $(OPENDSS_URL) $(OPENDSS_DIR)
	mkdir -p $(OPENDSS_TMP)
	mkdir -p $(OPENDSS_LIB)

# Linking

link_$(OPENDSS_DIR): $(OPENDSS_DIR)
	@ if [ -h $(OPENDSS_LIB)/$(OUT)$(LIB_S) ] ; then \
		rm $(OPENDSS_LIB)/$(OUT)$(LIB_S) ; \
	fi
	@ if [ -e $(OPENDSS_LIB)/$(OUT)$(LIB_S) ] ; then \
		mv $(OPENDSS_LIB)/$(OUT)$(LIB_S) $(OPENDSS_LIB)/$(OUT).r`svnversion $(OPENDSS_DIR)`$(LIB_S) && \
		ln -s `pwd`/$(OPENDSS_LIB)/$(OUT).r`svnversion $(OPENDSS_DIR)`$(LIB_S) `pwd`/$(OPENDSS_LIB)/$(OUT)$(LIB_S) ; \
	fi

link_$(KLUSOLVE_DIR): $(KLUSOLVE_DIR)
	@ if [ -e $(KLUSOLVE_LIB)/libklusolve$(ARCH_S) ] ; then \
		mv $(KLUSOLVE_LIB)/libklusolve$(ARCH_S) $(KLUSOLVE_LIB)/libklusolve.r`svnversion $(KLUSOLVE_DIR)`$(ARCH_S) && \
		ln -s `pwd`/$(KLUSOLVE_LIB)/libklusolve.r`svnversion $(KLUSOLVE_DIR)`$(ARCH_S) `pwd`/$(KLUSOLVE_LIB)/libklusolve$(ARCH_S) ; \
	fi

# Cleaning

clean:
	rm -rf $(OPENDSS_TMP)/*
	rm -rf $(OPENDSS_LIB)/*
	rm -rf $(KLUSOLVE_LIB)/*

clean_all:
	sudo rm -rf $(KLUSOLVE_DIR)
	sudo rm -rf $(OPENDSS_DIR)

# Setup functions

setup:
	@ if [ $(UNAME) = "Linux" ] ; then \
		sudo apt install build-essential subversion ; \
		sudo ln -sfv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so ; \
		sudo ln -sfv /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so ; \
		wget https://sourceforge.net/projects/freepascal/files/Linux/3.0.2/fpc-3.0.2.x86_64-linux.tar  && \
		tar -xvf fpc-3.0.2.x86_64-linux.tar && \
		cd fpc-3.0.2.x86_64-linux && sudo ./install.sh </dev/null && cd .. && rm -rf fpc* ; \
	elif [ $(UNAME) = "Darwin" ] ; then \
		command -v fpc >/dev/null 2>&1 && brew upgrade fpc || brew install fpc ; \
		command -v svn >/dev/null 2>&1 && brew upgrade subversion || brew install subversion ; \
	else \
		echo "System not supported for setup: \"$(UNAME)\"" ; \
	fi

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
