# OpenDSSDirect.make [![Build Status](https://travis-ci.org/Muxelmann/OpenDSSDirect.make.svg?branch=master)](https://travis-ci.org/Muxelmann/OpenDSSDirect.make)

This repo contains the complete procedure to generate updated versions of OpenDSS libraries.
Updates are applied by downloading and compiling the original OpenDSS source code from [Subversion Repository](https://sourceforge.net/projects/electricdss/).
The result is an updated library (e.g. `libopendssdirect.so` for Ubuntu Linux).

**This package is available for Linux only. Mac and Windows are still to come.**

## Usage - Ubuntu

### Setup

Run the following or follow the steps below manually:

```
make setup_Ubuntu
```

<hr>

Start by installing all prerequisites, including the standard compiler and lazarus (with Free Pascal). Also two additional symbolic links need to be added for the compilation to function correctly.

```
sudo apt update
sudo apt upgrade
sudo apt install build-essential lazarus subversion
sudo ln -sfv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so
sudo ln -sfv /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so
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

