OPENDSS_DIR  ?= electricdss
KLUSOLVE     ?= KLUSolve
TARGET       ?= dummy

SETUP_TARGET = setup_$(TARGET)

CC            = fpc
MACROS_LINUX  = -MDelphi -Scghi -Ct -O2  -k-lc -k-lm -k-lgcc_s -k-lstdc++ -l -vewnhibq
MACROS_MACOS  = -MDelphi -Scghi -Ct -O2 -l -vewnhibq
CFLAGS        = -dBorland -dVer150 -dDelphi7 -dCompiler6_Up -dPUREPASCAL -dCPU64
TMP           = ./tmp
LIB           = ./lib

KLUSOLVE_LIB  = $(KLUSOLVE)/Lib
KLUSOLVE_TEST = $(KLUSOLVE)/Test
KLUSOLVE_OBJ  = $(KLUSOLVE)/KLUSolve/Obj

OUT = libopendssdirect

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
	echo "Specify a target as: TARGET=linux or TARGET=macOS"

setup_dummy:
	echo "Specify a target as: TARGET=linux or TARGET=macOS"

# Build for x86_64 on Linux

linux: $(TMP) $(LIB) update_klusolve update_dss
	$(CC) \
	-Px86_64 -Cg $(MACROS_LINUX) \
	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -FU$(TMP) -FE$(LIB) \
	-o$(OUT).v`svnversion $(OPENDSS_DIR)`.so \
	$(CFLAGS) \
	$(OPENDSS_DIR)/Source/LazDSS/DirectDLL/OpenDSSDirect.lpr

# Bild for x86_64 on linux and delete unnecessary files afterwards

light_linux: linux
	rm -fr $(TMP)

# Build for macOS

macOS: $(TMP) $(LIB) update_klusolve_mac update_dss
	$(CC) \
	-Px86_64 -Cg $(MACROS_MACOS) \
	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -FU$(TMP) -FE$(LIB) \
	-o$(OUT).v`svnversion $(OPENDSS_DIR)`.dylib \
	$(CFLAGS) \
	$(OPENDSS_DIR)/Source/LazDSS/DirectDLL/OpenDSSDirect.lpr

# Bild for x86_64 on Linux and delete unnecessary files afterwards

light_macOS: macOS
	rm -fr $(TMP)

# # Build for 64bit ARM
#
# arm: $(TMP) $(LIB) update_klusolve update_dss
# 	$(CC) \
# 	-Parm  $(MACROS_LINUX) \
# 	$(INPUT_DIRS) $(LIB_DIRS) $(USE_DIRS) -Fu$(TMP) -FE$(LIB) \
# 	-Fl/usr/lib/gcc/arm-linux-gnueabihf/4.9/ \
# 	-o$(OUT) \
# 	$(CFLAGS) \
# 	$(OPENDSS_DIR)/Source/LazDSS/DirectDLL/OpenDSSDirect.lpr
#
# # Bild for x86_64 on Linux and delete unnecessary files afterwards
#
# light_arm: arm
# 	rm -fr $(TMP)

# Clean

clean:
	rm -rf $(TMP)
	rm -rf $(LIB)

clean_all: clean
	sudo rm -rf $(KLUSOLVE)
	sudo rm -rf $(OPENDSS_DIR)

# SVN code management

update_klusolve: $(KLUSOLVE)
	svn update $(KLUSOLVE)
	mkdir -p $(KLUSOLVE_LIB)
	mkdir -p $(KLUSOLVE_TEST)
	make -C $(KLUSOLVE) all

update_klusolve_mac: $(KLUSOLVE)
	svn update $(KLUSOLVE)
	mkdir -p $(KLUSOLVE_LIB)
	mkdir -p $(KLUSOLVE_TEST)
	mkdir -p $(KLUSOLVE_OBJ)
	make -C $(KLUSOLVE) all || make -C $(KLUSOLVE) all

$(KLUSOLVE):
	mkdir -p $(KLUSOLVE)
	svn checkout https://svn.code.sf.net/p/klusolve/code/ $(KLUSOLVE)

update_dss: $(OPENDSS_DIR)
	svn update $(OPENDSS_DIR)

$(OPENDSS_DIR):
	mkdir -p $(OPENDSS_DIR)
	svn checkout https://svn.code.sf.net/p/electricdss/code/trunk $(OPENDSS_DIR)

# Directory management

$(TMP):
	mkdir -p $(TMP)

$(LIB):
	mkdir -p $(LIB)

# Setup functions

setup_linux:
	# sudo apt update
	# sudo apt upgrade
	# sudo apt install build-essential lazarus subversion
	sudo apt install build-essential subversion
	sudo ln -sfv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so
	sudo ln -sfv /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so
	# Install FPC 3.0.2
	wget https://sourceforge.net/projects/freepascal/files/Linux/3.0.2/fpc-3.0.2.x86_64-linux.tar
	tar -xvf fpc-3.0.2.x86_64-linux.tar
	cd fpc-3.0.2.x86_64-linux && sudo ./install.sh </dev/null

setup_macOS:
	brew install fpc subversion
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
