# Release Process

This document describes how to create releases for WWC3 (Waya Wolf Coin) binaries.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Push access to the repository

## Supported Platforms

- **Linux** (x86_64) - Built using Docker with Ubuntu 16.04 base
- **Windows** (x86_64) - Built using Docker cross-compilation with Ubuntu 16.04 + MinGW
- **macOS** - Not yet implemented

## Creating a Release

### Step 1: Ensure Workflow is Updated

The build workflows are defined in `.github/workflows/`:
- `build-release.yml` - Builds Linux binaries
- `build-windows.yml` - Builds Windows binaries

Both workflows automatically:
- Clone source from `https://github.com/Waya-Wolf/WWC3.git`
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
- `WWC3-windows-x64.zip` - Windows binaries (wayawolfcoind)

## Workflow Details

### Linux Build
- Uses `Dockerfile.qt-static` (Ubuntu 16.04)
- Builds both daemon (wayawolfcoind) and Qt GUI (Wayawolfcoin-qt)
- Static linking for OpenSSL, Boost, BDB, miniupnpc

### Windows Build  
- Uses `Dockerfile.windows-cross` (Ubuntu 16.04 + MinGW cross-compilation)
- Builds daemon only (wayawolfcoind.exe)
- OpenSSL 1.0.2g compatible with WWC3 codebase

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
