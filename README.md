# OpenDSSDirect.make

[![Build Status](https://travis-ci.org/Muxelmann/OpenDSSDirect.make.svg?branch=master)](https://travis-ci.org/Muxelmann/OpenDSSDirect.make)

This repo contains the complete procedure to generate updated versions of OpenDSS libraries.
Updates are applied by downloading and compiling the original OpenDSS source code from [Subversion Repository](https://sourceforge.net/projects/electricdss/).
The result is an updated library (e.g. `libopendssdirect.so` for Linux).

**This package is available for Linux and Mac (64 bit) only. Windows is still to come.**

## Usage for Linux and macOS

### Setup

To setup the compile environment, tun the following code. For macOS, make sure you have installed Xcode and its Command Line Tools. Alternatively, run follow the setup steps below; they are different **for Linux** and **for macOS**.

```
make setup
```

### Compile

Fully compile the library using:

```
make
```

This will save the final `libopendssdirect.rXXXX` file in the `Lib` directory in the OpenDSS repo folder. It is a `*.so` file for Linux and `*.dylib` for macOS. `rXXXX` indicates the Subversion release from which it was built.

### Manual setup

**For Linux**, start by installing all prerequisites, including the `build-essential` package, Subversion and the Free Pascal Compiler (`fpc`). Also, two additional symbolic links are need to be added for the compilation to complete correctly.

```
sudo apt install build-essential subversion
sudo ln -sfv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so
sudo ln -sfv /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so
wget https://sourceforge.net/projects/freepascal/files/Linux/3.0.2/fpc-3.0.2.x86_64-linux.tar
tar -xvf fpc-3.0.2.x86_64-linux.tar
cd fpc-3.0.2.x86_64-linux
sudo ./install.sh </dev/null
cd ..
```

**For macOS**, start by installing all prerequisites, including Subversion and the Free Pascal Compiler (`fpc`).

```
brew install fpc subversion
```

## Aside

A full copy of the OpenDSS source is stored in `electricdss`. The directory can be changed by adjusting the `OPENDSS_DIR` variable. E.g.:

```
make OPENDSS_DIR=<different path>
```

Also, making the project will download and compile a standalone `KLUSolve` into a directory of the same name. This is to assure that the code compiles with the most up to date solver. You can change this directory by adjusting the `KLUSOLVE_DIR` variable. E.g:
 
```
make KLUSOLVE_DIR=<different path>
```

## Thanks

Thanks to @kdheepak (repo [here](https://github.com/NREL/OpenDSSDirect.py)) and Davis for their input.
