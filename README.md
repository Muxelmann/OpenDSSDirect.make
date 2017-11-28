# OpenDSSDirect.make

[![Build Status](https://travis-ci.org/Muxelmann/OpenDSSDirect.make.svg?branch=master)](https://travis-ci.org/Muxelmann/OpenDSSDirect.make)

This repo contains the complete procedure to generate updated versions of OpenDSS libraries.
Updates are applied by downloading and compiling the original OpenDSS source code from [Subversion Repository](https://sourceforge.net/projects/electricdss/).
The result is an updated library (e.g. `libOpenDSSDirect.so` for Linux).

**This package is available only for Linux (64bit) and Mac (64 bit). 32bit and Windows support is still to come.**

*This version is no longer based on the Lazarus project and uses the source code that is provided in the `electricdss/DDLL` directory instead.*

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

The results are saved as `libopendssdirect` in the `_source/lib` directory. They are stored according to system and SVN versioning of `electricdss` and `KLUSolve` at the time of building.

### Manual setup

**For Linux**, start by installing all prerequisites, including the `build-essential` package, Subversion and the Free Pascal Compiler (`fpc`). Also, two additional symbolic links are need to be added for the compilation to complete correctly.
Make sure you use the correct architecture (the example below is `x86_64`).

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
brew install fpc
brew install subversion
```

## Supported architectures

- [x] Intel x86 64bit - e.g. `x86_64`
- [x] Intel x86 32bit - e.g. `i386`, `i686`
- [ ] ARM 64bit - e.g. `ARMv7`

## Thanks

Thanks to @kdheepak (repo [here](https://github.com/NREL/OpenDSSDirect.py)) and Davis for their input.
