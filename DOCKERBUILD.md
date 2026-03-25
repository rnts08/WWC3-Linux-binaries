# Waya Wolf Coin Docker Build Guide

This guide explains how to build Waya Wolf Coin (WWC3) binaries using Docker.

## Prerequisites

- Docker installed on your system
- At least 20GB disk space for builds (Windows Qt builds require more)

## Quick Start

### Linux (Recommended)
```bash
# Build static Qt version
docker build -f Dockerfile.qt-static -t ww-qt-static .

# Extract binaries
docker run --rm ww-qt-static cat /build/src/wayawolfcoind > wayawolfcoind
docker run --rm ww-qt-static cat /build/Wayawolfcoin-qt > Wayawolfcoin-qt
chmod +x wayawolfcoind Wayawolfcoin-qt
```

### Windows
```bash
# Build Qt GUI (includes both daemon and Qt)
docker build -f Dockerfile.windows-mxe-qt -t ww-windows-qt .

# Extract binaries
docker run --rm ww-windows-qt cat /output/wayawolfcoind.exe > wayawolfcoind.exe
docker run --rm ww-windows-qt cat /output/Wayawolfcoin-qt.exe > Wayawolfcoin-qt.exe
```

---

## Build Options

### Linux Builds

#### Option 1: Dynamic Daemon Only (Dockerfile.normal)

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

#### Option 2: Qt GUI - Dynamic (Dockerfile.qt)

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

#### Option 3: Qt GUI - Static (Dockerfile.qt-static) **Recommended**

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

---

### Windows Builds

#### Option 1: Daemon Only (Dockerfile.windows-mxe)

Builds the headless daemon for Windows using MXE cross-compilation.

```bash
docker build -f Dockerfile.windows-mxe -t ww-windows-mxe .
docker run --rm ww-windows-mxe cat /output/wayawolfcoind.exe > wayawolfcoind.exe
```

**Output:** `wayawolfcoind.exe` (~8MB)

---

#### Option 2: Qt GUI (Dockerfile.windows-mxe-qt) **Recommended**

Builds both daemon and Qt GUI for Windows using MXE cross-compilation with Qt5.

```bash
docker build -f Dockerfile.windows-mxe-qt -t ww-windows-qt .
docker run --rm ww-windows-qt cat /output/wayawolfcoind.exe > wayawolfcoind.exe
docker run --rm ww-windows-qt cat /output/Wayawolfcoin-qt.exe > Wayawolfcoin-qt.exe
```

**Output:**
- `wayawolfcoind.exe` (~8MB)
- `Wayawolfcoin-qt.exe` (~27MB)

**Build time:** ~30 minutes (Qt compilation)

**Key patches applied:**
- Boost 1.65+ compatibility (placeholders, ASIO changes)
- OpenSSL 1.1+ compatibility (ssl::context changes)
- Windows-specific fixes (localtime_s, UPNP disabled)

---

## Running the Binaries

### Linux Daemon
```bash
./wayawolfcoind -daemon -datadir=/path/to/data
```

### Linux Qt GUI
```bash
./Wayawolfcoin-qt
```
Note: Requires a display (X11 server or Wayland).

### Windows
```bash
./wayawolfcoind.exe -daemon
./Wayawolfcoin-qt.exe
```

---

## Build Information

| Property | Value |
|----------|-------|
| **Base Image (Linux)** | Ubuntu 16.04 (required for OpenSSL 1.0) |
| **Base Image (Windows)** | MXE (sskender/altcoin-mxe:latest) |
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

### Windows Qt Build - Multiple Definition Error
```
multiple definition of `boost::system::error_code::location() const::loc'
```
Fix: Add `-Wl,--allow-multiple-definition` to LDFLAGS and `BOOST_ERROR_CODE_HEADER_ONLY` to DEFINES

### Windows Qt Build - Placeholder Errors
```
error: '_1' was not declared in this scope
```
Fix: Add `BOOST_BIND_GLOBAL_PLACEHOLDERS` define and include `<boost/bind.hpp>` with `using namespace boost::placeholders;`