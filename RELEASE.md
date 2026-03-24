# Release Process

This document describes how to create releases for WWC3 binaries.

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Push access to the repository

## Creating a Release

### Step 1: Ensure Workflow is Updated

The build workflow is defined in `.github/workflows/build-release.yml`. It automatically:
- Clones the source from `https://github.com/Waya-Wolf/WWC3.git`
- Builds Linux binaries using Docker
- Packages them as `WWC3-linux-x64.tar.gz`
- Attaches to the release

### Step 2: Create the Release

Run the following command:

```bash
gh release create <tag> --title "<title>" --notes "<notes>"
```

Examples:

```bash
# Create a release with auto-generated notes
gh release create v1.0.0 --title "v1.0.0" --generate-notes

# Create a release with custom notes
gh release create v1.0.0 --title "Version 1.0.0" --notes "First official release"

# Create a prerelease
gh release create v1.0.0-rc1 --title "v1.0.0 RC1" --notes "Release candidate" --prerelease
```

### Step 3: Monitor the Build

Check the workflow status:

```bash
gh run list
```

The build takes ~10-15 minutes (Docker compilation).

### Step 4: Verify Release

```bash
gh release view <tag>
```

## Build Output

The release will include:
- `WWC3-linux-x64.tar.gz` - Linux binaries (wayawolfcoind + Wayawolfcoin-qt)

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

- Add Windows (.zip) and macOS (.tar.gz) builds
- Add binary verification checksums
- Add automated version detection from source
