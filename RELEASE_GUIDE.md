# Release Guide for datagram1/plandex

This guide explains how to create releases for your plandex fork so users can install it using the custom installation script.

## Creating a Release

### 1. Build the Binary

First, make sure you have a built plandex binary in the `app/cli/` directory:

```bash
cd app/cli
go build -o plandex main.go
```

### 2. Create Release Assets

The installation script expects a tarball with the following naming convention:
`plandex_{VERSION}_{PLATFORM}_{ARCH}.tar.gz`

For example:
- `plandex_1.0.0_darwin_arm64.tar.gz` (macOS Apple Silicon)
- `plandex_1.0.0_darwin_amd64.tar.gz` (macOS Intel)
- `plandex_1.0.0_linux_amd64.tar.gz` (Linux x86_64)
- `plandex_1.0.0_linux_arm64.tar.gz` (Linux ARM64)

### 3. Package the Binary

Create a tarball containing just the `plandex` binary:

```bash
# For macOS ARM64
tar -czf plandex_1.0.0_darwin_arm64.tar.gz plandex

# For macOS Intel
tar -czf plandex_1.0.0_darwin_amd64.tar.gz plandex

# For Linux AMD64
tar -czf plandex_1.0.0_linux_amd64.tar.gz plandex

# For Linux ARM64
tar -czf plandex_1.0.0_linux_arm64.tar.gz plandex
```

### 4. Create GitHub Release

1. Go to your GitHub repository: https://github.com/datagram1/plandex
2. Click "Releases" → "Create a new release"
3. Create a new tag: `cli/v1.0.0` (note the `cli/` prefix)
4. Upload all the tarball files as release assets
5. Add release notes describing the changes
6. Publish the release

### 5. Test the Installation

Once the release is published, test the installation:

```bash
curl -sL https://raw.githubusercontent.com/datagram1/plandex/main/install.sh | bash
```

## Automated Release Script

You can use the provided `create-release.sh` script to automate this process:

```bash
./create-release.sh 1.0.0
```

This script will:
1. Build the binary for your current platform
2. Create the appropriate tarball
3. Provide instructions for creating the GitHub release

## Notes

- The installation script automatically detects the latest release from your repository
- Users can also specify a custom version: `PLANDEX_VERSION=1.0.0 curl -sL https://raw.githubusercontent.com/datagram1/plandex/main/install.sh | bash`
- Make sure to test the installation on different platforms before publishing
