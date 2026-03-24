# Release Process

This document describes how to create releases for WWC3 (Waya Wolf Coin) binaries.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Push access to the repository
- Docker (for local testing)

## Supported Platforms

- **Linux** (x86_64) - Built using Docker with Ubuntu 16.04 base
- **Windows** (x86_64) - Built using Docker cross-compilation with MXE (Boost 1.58)
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
- `WWC3-windows-x64.zip` - Windows binaries (wayawolfcoind.exe)

## Local Build

### Linux

```bash
git clone --depth 1 https://github.com/Waya-Wolf/WWC3.git wwc3-source
cp Dockerfile.qt-static wwc3-source/
docker build -f wwc3-source/Dockerfile.qt-static -t ww-qt-static wwc3-source/
docker run --rm ww-qt-static cat /build/src/wayawolfcoind > wayawolfcoind
docker run --rm ww-qt-static cat /build/Wayawolfcoin-qt > Wayawolfcoin-qt
```

### Windows

```bash
git clone --depth 1 https://github.com/Waya-Wolf/WWC3.git wwc3-source
cp Dockerfile.windows-mxe wwc3-source/
cp patches/boost-compat.patch wwc3-source/
docker build -f wwc3-source/Dockerfile.windows-mxe -t ww-windows-mxe wwc3-source/
docker run --rm ww-windows-mxe cat /output/wayawolfcoind.exe > wayawolfcoind.exe
```

## Compatibility Patches

The WWC3 codebase uses deprecated Boost/ASIO APIs. Patches are stored in `patches/`:

- `boost-compat.patch` - Fixes compatibility with newer Boost (1.66+) and OpenSSL (1.1+)

### Changes in boost-compat.patch

1. **Boost.Asio io_service → io_context**:
   - `get_io_service()` → `get_executor()` for Boost 1.66+
   - Added template overloads for AcceptedConnectionImpl

2. **OpenSSL API updates**:
   - `ssl::context` constructor change (removed io_service parameter)
   - `ssl::context::impl()` → `ssl::context::native_handle()`

3. **Boost version checks**:
   - Uses `#if BOOST_VERSION >= 106600` to conditionally compile

## Workflow Details

### Linux Build
- Uses `Dockerfile.qt-static` (Ubuntu 16.04)
- Builds both daemon (wayawolfcoind) and Qt GUI (Wayawolfcoin-qt)
- Static linking for OpenSSL, Boost, BDB, miniupnpc

### Windows Build  
- Uses `Dockerfile.windows-mxe` (MXE with Boost 1.58)
- Builds daemon only (wayawolfcoind.exe)
- Applies `patches/boost-compat.patch` for compatibility

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

## Future Enhancements

- Add macOS build support
- Add binary verification checksums
- Add automated version detection from source
