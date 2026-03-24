# Waya Wolf Coin Docker Build Guide

This guide explains how to build Waya Wolf Coin (WW) binaries using Docker.
The code requires OpenSSL 1.0.x APIs, which are available in Ubuntu 16.04.

## Prerequisites

- Docker installed on your system
- At least 10GB disk space for builds

## Quick Start

```bash
# Build static Qt version (recommended)
docker build -f Dockerfile.qt-static -t ww-qt-static .

# Extract binaries
docker run --rm ww-qt-static cat /build/src/wayawolfcoind > wayawolfcoind
docker run --rm ww-qt-static cat /build/Wayawolfcoin-qt > Wayawolfcoin-qt
chmod +x wayawolfcoind Wayawolfcoin-qt
```

---

## Build Options

### Option 1: Dynamic Daemon Only (Dockerfile.normal)

Builds only the headless daemon with dynamic library linking.

```bash
docker build -f Dockerfile.normal -t ww-daemon .
docker run --rm ww-daemon cat /build/src/wayawolfcoind > wayawolfcoind
chmod +x wayawolfcoind
```

**Runtime dependencies (host needs):**
- libssl1.0
- libcrypto1.0
- libdb_cxx
- libboost_system, libboost_filesystem, libboost_program_options, libboost_thread
- libminiupnpc

---

### Option 2: Qt GUI - Dynamic (Dockerfile.qt)

Builds both daemon and Qt GUI with dynamic library linking.

```bash
docker build -f Dockerfile.qt -t ww-qt .
docker run --rm ww-qt cat /build/src/wayawolfcoind > wayawolfcoind
docker run --rm ww-qt cat /build/Wayawolfcoin-qt > Wayawolfcoin-qt
chmod +x wayawolfcoind Wayawolfcoin-qt
```

**Runtime dependencies (host needs):**
- Same as Option 1, plus:
- Qt5 libraries (libQt5Widgets, libQt5Gui, libQt5Network, libQt5Core)
- X11 libraries

---

### Option 3: Qt GUI - Static (Dockerfile.qt-static) **Recommended**

Builds both daemon and Qt GUI with static library linking.
Reduces runtime dependencies - no need to install old OpenSSL/Boost/BDB libraries.

```bash
docker build -f Dockerfile.qt-static -t ww-qt-static .
docker run --rm ww-qt-static cat /build/src/wayawolfcoind > wayawolfcoind
docker run --rm ww-qt-static cat /build/Wayawolfcoin-qt > Wayawolfcoin-qt
chmod +x wayawolfcoind Wayawolfcoin-qt
```

**Runtime dependencies (host needs):**
- glibc (libc, libpthread, libdl, libstdc++, libm, libgcc)
- Qt5 libraries
- X11/OpenGL libraries

**The following are NO LONGER needed on the host:**
- libssl / libcrypto (OpenSSL)
- libboost (Boost libraries)
- libdb_cxx (Berkeley DB)
- libminiupnpc

---

## Running the Binaries

### Daemon Only
```bash
./wayawolfcoind -daemon -datadir=/path/to/data
```

### Qt GUI
```bash
./Wayawolfcoin-qt
```

Note: The Qt GUI requires a display (X11 server or Wayland).

---

## Build Information

| Property | Value |
|----------|-------|
| **Base Image** | Ubuntu 16.04 (required for OpenSSL 1.0) |
| **Algo** | HMQ1725 |
| **Block Time** | 3 minutes |
| **RPC Port** | 9953 |
| **P2P Port** | 9952 |
| **Default Directory** | WayaWolfV3 |

---

## Troubleshooting

### "cannot find -lgcc_s" during static build
The STATIC=all option requires additional libraries. Use `STATIC=1` instead:
```bash
RUN cd src && make -f makefile.unix USE_UPNP=1 STATIC=1
```

### Qt build fails with "//WIN: No such file"
This is caused by Windows paths in the .pro file. The Dockerfiles include a fix via sed.

### Out of memory during build
Limit parallel builds:
```bash
RUN cd src && make -f makefile.unix USE_UPNP=1 STATIC=1 -j2
```