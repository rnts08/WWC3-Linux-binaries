# Release Process

This document describes how to create releases for WWC3 (Waya Wolf Coin) binaries.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Push access to the repository
- Docker (for local testing)

## Supported Platforms

- **Linux** (x86_64) - Built using Docker with Ubuntu 16.04 base
- **Windows** (x86_64) - Built using Docker cross-compilation with MXE
  - Daemon: `Dockerfile.windows-mxe` (wayawolfcoind.exe)
  - Qt GUI: `Dockerfile.windows-mxe-qt` (Wayawolfcoin-qt.exe)
- **macOS** - Not yet implemented

## Creating a Release

### Step 1: Ensure Workflow is Updated

The build workflows are defined in `.github/workflows/`:
- `build-release.yml` - Builds Linux binaries
- `build-windows.yml` - Builds Windows binaries

Both workflows automatically:
- Clone source from `https://github.com/Waya-Wolf/WWC3.git`
- Apply compatibility patches from `patches/`
- Build binaries using Docker
- Package and attach to the release

### Step 2: Create the Release

Run the following command:

```bash
gh release create <tag> --title "<title>" --notes "<notes>"
```

Examples:

```bash
# Create a release
gh release create v1.1 --title "WWC3 v1.1" --notes "Stable release with Linux and Windows builds"

# Create a prerelease
gh release create v1.2-rc1 --title "v1.2 RC1" --notes "Release candidate" --prerelease
```

### Step 3: Monitor the Build

Check the workflow status:

```bash
gh run list
```

The builds take ~10-15 minutes each (Docker compilation).

### Step 4: Verify Release

```bash
gh release view <tag>
```

## Build Output

Releases include:
- `WWC3-linux-x64.tar.gz` - Linux binaries (wayawolfcoind + Wayawolfcoin-qt)
- `WWC3-windows-x64.zip` - Windows binaries (wayawolfcoind.exe + Wayawolfcoin-qt.exe)

## Local Build

### Linux

```bash
git clone --depth 1 https://github.com/Waya-Wolf/WWC3.git wwc3-source
cp Dockerfile.qt-static wwc3-source/
docker build -f wwc3-source/Dockerfile.qt-static -t ww-qt-static wwc3-source/
docker run --rm ww-qt-static cat /build/src/wayawolfcoind > wayawolfcoind
docker run --rm ww-qt-static cat /build/Wayawolfcoin-qt > Wayawolfcoin-qt
```

### Windows - Daemon Only

```bash
git clone --depth 1 https://github.com/Waya-Wolf/WWC3.git wwc3-source
cp Dockerfile.windows-mxe wwc3-source/
cp patches/boost-compat.patch wwc3-source/
docker build -f wwc3-source/Dockerfile.windows-mxe -t ww-windows-mxe wwc3-source/
docker run --rm ww-windows-mxe cat /output/wayawolfcoind.exe > wayawolfcoind.exe
```

### Windows - Qt GUI (Recommended)

```bash
git clone --depth 1 https://github.com/Waya-Wolf/WWC3.git wwc3-source
cp Dockerfile.windows-mxe-qt wwc3-source/
docker build -f wwc3-source/Dockerfile.windows-mxe-qt -t ww-windows-qt wwc3-source/
docker run --rm ww-windows-qt cat /output/wayawolfcoind.exe > wayawolfcoind.exe
docker run --rm ww-windows-qt cat /output/Wayawolfcoin-qt.exe > Wayawolfcoin-qt.exe
```

## Compatibility Patches

The WWC3 codebase uses deprecated Boost/ASIO APIs. Patches are stored in `patches/`:

- `boost-compat.patch` - Base compatibility fixes for Boost/OpenSSL
- `qt-boost-compat.patch` - Additional fixes for Qt GUI build (Boost placeholders, ASIO changes)

### Changes in boost-compat.patch

1. **Boost.Asio io_service → io_context**:
   - `get_io_service()` → `get_executor()` for Boost 1.66+
   - Added template overloads for AcceptedConnectionImpl

2. **OpenSSL API updates**:
   - `ssl::context` constructor change (removed io_service parameter)
   - `ssl::context::impl()` → `ssl::context::native_handle()`

3. **Boost version checks**:
   - Uses `#if BOOST_VERSION >= 106600` to conditionally compile

### Additional Qt Build Changes (qt-boost-compat.patch)

1. **Boost placeholders**:
   - Added `#include <boost/bind.hpp>` and `using namespace boost::placeholders;` to:
     - `src/main.cpp`
     - `src/qt/clientmodel.cpp`
     - `src/qt/walletmodel.cpp`
   - Added `BOOST_BIND_GLOBAL_PLACEHOLDERS` define

2. **SSL context**:
   - Modified `SSLIOStreamDevice` to accept `io_service&` as first parameter
   - Updated all call sites in `rpcclient.cpp` and `rpcserver.cpp`

3. **Windows-specific**:
   - Changed `localtime_r` to `localtime_s` in `src/rpcwallet.cpp`
   - Added `BOOST_ERROR_CODE_HEADER_ONLY` to avoid multiple definition errors

## Workflow Details

### Linux Build
- Uses `Dockerfile.qt-static` (Ubuntu 16.04)
- Builds both daemon (wayawolfcoind) and Qt GUI (Wayawolfcoin-qt)
- Static linking for OpenSSL, Boost, BDB, miniupnpc

### Windows Build - Daemon
- Uses `Dockerfile.windows-mxe` (MXE with Boost 1.58)
- Builds daemon only (wayawolfcoind.exe)
- Applies `patches/boost-compat.patch` for compatibility

### Windows Build - Qt GUI
- Uses `Dockerfile.windows-mxe-qt` (MXE with Qt5)
- Builds both daemon (wayawolfcoind.exe) and Qt GUI (Wayawolfcoin-qt.exe)
- Applies source code patches for Boost compatibility
- Requires ~30 minutes to build (Qt compilation)

## Troubleshooting

### Workflow doesn't run
- Ensure the workflow file is on the default branch (main)
- Check that the release is published (not draft)

### Build fails
- Check logs: `gh run view <run_id> --log`
- Common issues: Docker build timeouts, missing dependencies

### Upload fails
- Ensure `permissions: contents: write` is set in workflow
- Verify the release tag exists

### Windows Qt Build - Multiple Definition Error
If you see `multiple definition of boost::system::error_code::location() const::loc`:
- Ensure `BOOST_ERROR_CODE_HEADER_ONLY` is defined
- Add `-Wl,--allow-multiple-definition` to LDFLAGS

### Windows Qt Build - Placeholder Errors
If you see `_1 was not declared in this scope`:
- Ensure `BOOST_BIND_GLOBAL_PLACEHOLDERS` is defined
- Add `#include <boost/bind.hpp>` and `using namespace boost::placeholders;` to affected files

## Future Enhancements

- Add macOS build support
- Add binary verification checksums
- Add automated version detection from source
