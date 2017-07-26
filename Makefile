OPENDSS_DIR  ?= electricdss
KLUSOLVE_DIR ?= KLUSolve
TARGET       ?= dummy
UNAME        := $(shell uname)

SETUP_TARGET  = setup_$(TARGET)

CC            = fpc
MACROS_LINUX  = -MDelphi -Scghi -Ct -O2  -k-lc -k-lm -k-lgcc_s -k-lstdc++ -l -vewnhibq
MACROS_MACOS  = -MDelphi -Scghi -Ct -O2 -l -vewnhibq
CFLAGS        = -dBorland -dVer150 -dDelphi7 -dCompiler6_Up -dPUREPASCAL -dCPU64

KLUSOLVE_URL  = https://svn.code.sf.net/p/klusolve/code/
KLUSOLVE_LIB  = $(KLUSOLVE_DIR)/Lib
KLUSOLVE_TEST = $(KLUSOLVE_DIR)/Test
KLUSOLVE_OBJ  = $(KLUSOLVE_DIR)/KLUSolve/Obj

OPENDSS_URL   = https://svn.code.sf.net/p/electricdss/code/trunk
OPENDSS_TMP   = $(OPENDSS_DIR)/Tmp
OPENDSS_LIB   = $(OPENDSS_DIR)/Lib

OUT           = libopendssdirect

INPUT_DIRS = \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Forms \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Shared \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Common \
-Fi$(OPENDSS_DIR)/Source/LazDSS/PDElements \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Controls \
-Fi$(OPENDSS_DIR)/Source/LazDSS/General \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Plot \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Meters \
-Fi$(OPENDSS_DIR)/Source/LazDSS/PCElements \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Executive \
-Fi$(OPENDSS_DIR)/Source/LazDSS/Parser \
-Fi$(OPENDSS_DIR)/Source/LazDSS/units/x86_64-linux

# LIB_DIRS = -Fl$(OPENDSS_DIR)/Source/LazDSS/lib
LIB_DIRS = -Fl$(KLUSOLVE_LIB)

USE_DIRS = \
-Fu$(OPENDSS_DIR)/Source/LazDSS/Shared \
-Fu$(OPENDSS_DIR)/Source/LazDSS/Common \
-Fu$(OPENDSS_DIR)/Source/LazDSS/PDElements \
-Fu$(OPENDSS_DIR)/Source/LazDSS/Controls \
-Fu$(OPENDSS_DIR)/Source/LazDSS/General \
-Fu$(OPENDSS_DIR)/Source/LazDSS/Meters \
-Fu$(OPENDSS_DIR)/Source/LazDSS/PCElements \
-Fu$(OPENDSS_DIR)/Source/LazDSS/Executive \
-Fu$(OPENDSS_DIR)/Source/LazDSS/Parser \
-Fu$(OPENDSS_DIR)/Source/LazDSS/DirectDLL \

all: $(TARGET)

setup: $(SETUP_TARGET)

# Define dummy dependencies

dummy:
	@ if [ $(UNAME) = "Linux" ] ; then \
		make TARGET=linux ; \
	elif [ $(UNAME) = "Darwin" ] ; then \
		make TARGET=macOS ; \
	else  \
		echo "System not supported for making: \"$(UNAME)\"" ; \
	fi

setup_dummy:
	@ if [ $(UNAME) = "Linux" ] ; then \
		make setup TARGET=linux ; \
	elif [ $(UNAME) = "Darwin" ] ; then \
		make setup TARGET=macOS ; \
	else \
		echo "System not supported for setup: \"$(UNAME)\"" ; \
	fi

# Build for x86_64 on Linux

linux: update_klusolve_linux update_dss $(OPENDSS_TMP) $(OPENDSS_LIB)
	$(CC) \
	-Px86_64 -Cg $(MACROS_LINUX) \
	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -FU$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
	-o$(OUT).r`svnversion $(OPENDSS_DIR) | rev | cut -c 2- | rev`.so \
	$(CFLAGS) \
	$(OPENDSS_DIR)/Source/LazDSS/DirectDLL/OpenDSSDirect.lpr
	@[ -f $(OPENDSS_LIB)/$(OUT).r`svnversion $(OPENDSS_DIR) | rev | cut -c 2- | rev`.so ] \
		&& ln -s $(OPENDSS_LIB)/$(OUT).r`svnversion $(OPENDSS_DIR) | rev | cut -c 2- | rev`.so $(OPENDSS_LIB)/$(OUT).so \
		|| echo "Release has not been built correctly"

# Bild for x86_64 on linux and delete unnecessary files afterwards

light_linux: linux
	rm -fr $(OPENDSS_TMP)

# Build for macOS

macOS: update_klusolve_macOS update_dss $(OPENDSS_TMP) $(OPENDSS_LIB)
	$(CC) \
	-Px86_64 -Cg $(MACROS_MACOS) \
	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -FU$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
	-o$(OUT).r`svnversion $(OPENDSS_DIR) | rev | cut -c 2- | rev`.dylib \
	$(CFLAGS) \
	$(OPENDSS_DIR)/Source/LazDSS/DirectDLL/OpenDSSDirect.lpr
	@[ -f $(OPENDSS_LIB)/$(OUT).r`svnversion $(OPENDSS_DIR) | rev | cut -c 2- | rev`.dylib ] \
		&& ln -s $(OPENDSS_LIB)/$(OUT).r`svnversion $(OPENDSS_DIR) | rev | cut -c 2- | rev`.dylib $(OPENDSS_LIB)/$(OUT).dylib \
		|| echo "Release has not been built correctly"

# Bild for x86_64 on Linux and delete unnecessary files afterwards

light_macOS: macOS
	rm -fr $(OPENDSS_TMP)

# # Build for 64bit ARM
#
# arm: $(OPENDSS_TMP) $(OPENDSS_LIB) update_klusolve update_dss
# 	$(CC) \
# 	-Parm  $(MACROS_LINUX) \
# 	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -Fu$(OPENDSS_TMP) -FE$(OPENDSS_LIB) \
# 	-Fl/usr/lib/gcc/arm-linux-gnueabihf/4.9/ \
# 	-o$(OUT) \
# 	$(CFLAGS) \
# 	$(OPENDSS_DIR)/Source/LazDSS/DirectDLL/OpenDSSDirect.lpr
#
# # Bild for x86_64 on Linux and delete unnecessary files afterwards
#
# light_arm: arm
# 	rm -fr $(OPENDSS_TMP)

# Clean

clean:
	rm -rf $(OPENDSS_TMP)
	rm -rf $(OPENDSS_LIB)

clean_all:
	sudo rm -rf $(KLUSOLVE_DIR)
	sudo rm -rf $(OPENDSS_DIR)

# SVN code management

update_klusolve_linux: $(KLUSOLVE_DIR)
	svn update $(KLUSOLVE_DIR)
	mkdir -p $(KLUSOLVE_LIB)
	mkdir -p $(KLUSOLVE_TEST)
	make -C $(KLUSOLVE_DIR) all
	@[ -f $(KLUSOLVE_LIB)/libklusolve.a ] \
		&& cp $(KLUSOLVE_LIB)/libklusolve.a $(KLUSOLVE_LIB)/libklusolve.v`svnversion $(KLUSOLVE_DIR)`.a

update_klusolve_macOS: $(KLUSOLVE_DIR)
	svn update $(KLUSOLVE_DIR)
	mkdir -p $(KLUSOLVE_LIB)
	mkdir -p $(KLUSOLVE_TEST)
	mkdir -p $(KLUSOLVE_OBJ)
	make -C $(KLUSOLVE_DIR) all || make -C $(KLUSOLVE_DIR) all
	@[ -f $(KLUSOLVE_LIB)/libklusolve.dylib ] \
		&& cp $(KLUSOLVE_LIB)/libklusolve.dylib $(KLUSOLVE_LIB)/libklusolve.v`svnversion $(KLUSOLVE_DIR)`.dylib

$(KLUSOLVE_DIR):
	mkdir -p $(KLUSOLVE_DIR)
	svn checkout $(KLUSOLVE_URL) $(KLUSOLVE_DIR)

update_dss: $(OPENDSS_DIR)
	svn update $(OPENDSS_DIR)

$(OPENDSS_DIR):
	mkdir -p $(OPENDSS_DIR)
	svn checkout $(OPENDSS_URL) $(OPENDSS_DIR) --depth immediates
	cd $(OPENDSS_DIR)/Source && svn update --set-depth infinity

# Directory management

$(OPENDSS_TMP):
	mkdir -p $(OPENDSS_TMP)

$(OPENDSS_LIB):
	mkdir -p $(OPENDSS_LIB)

# Setup functions

setup_linux:
	sudo apt install build-essential subversion
	sudo ln -sfv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so
	sudo ln -sfv /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so
	@ # Install FPC 3.0.2
	wget https://sourceforge.net/projects/freepascal/files/Linux/3.0.2/fpc-3.0.2.x86_64-linux.tar
	tar -xvf fpc-3.0.2.x86_64-linux.tar
	cd fpc-3.0.2.x86_64-linux && sudo ./install.sh </dev/null

setup_macOS:
	command -v fpc >/dev/null 2>&1 && brew upgrade fpc || brew install fpc
	command -v svn >/dev/null 2>&1 && brew upgrade subversion || brew install subversion
	# brew install wget
	# wget https://sourceforge.net/projects/freepascal/files/Mac\ OS\ X/3.0.2/fpc-3.0.2.intel-macosx.dmg
	# sudo hdiutil attach fpc-3.0.2.intel-macosx.dmg
	# sudo installer -package /Volumes/fpc-3.0.2.intel-macosx/fpc-3.0.2.intel-macosx.pkg -target /

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
