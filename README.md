# OpenDSSDirect.make

[![Build Status](https://travis-ci.org/Muxelmann/OpenDSSDirect.make.svg?branch=master)](https://travis-ci.org/Muxelmann/OpenDSSDirect.make)

This repo contains the complete procedure to generate updated versions of OpenDSS libraries.
Updates are applied by downloading and compiling the original OpenDSS source code from [Subversion Repository](https://sourceforge.net/projects/electricdss/).
The result is an updated library (e.g. `libopendssdirect.so` for Linux).

**This package is available for Linux (64 bit) only. Mac and Windows are still to come.**

## Usage - Linux

### Setup

Run the following or follow the steps below manually:

```
make setup_linux
```

<hr>

Start by installing all prerequisites, including the `build-essential` package, Subversion and the Free Pascal Compiler (`fpc`).
Also, two additional symbolic links are need to be added for the compilation to complete correctly.

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

### Compile

Fully compile the library using:

```
make
```

This will save the final `libopendssdirect.so` in the `lib` directory, and a full copy of the OpenDSS source is stored in `electricdss`. If you want the OpenDSS source saved somewhere else, you can build like so:

```
make OPENDSS_DIR=some_other_dir
```

Also, making the project will download and compile a standalone KLUSolve, to assure it is compiled for the correct CPU architecture.


## Thanks

Thanks to @kdheepak and Davis for their input.
