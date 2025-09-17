#!/usr/bin/env bash

set -e

if [[ -z "$1" ]]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.0.0"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CLI_DIR="$SCRIPT_DIR/app/cli"
RELEASE_DIR="$SCRIPT_DIR/releases"

# Detect current platform
PLATFORM=
ARCH=

case "$(uname -s)" in
 Darwin)
   PLATFORM='darwin'
   ;;
 Linux)
   PLATFORM='linux'
   ;;
 *)
   echo "Unsupported platform: $(uname -s)"
   exit 1
   ;;
esac

case "$(uname -m)" in
 x86_64)
   ARCH="amd64"
   ;;
 arm64|aarch64)
   ARCH="arm64"
   ;;
 *)
   echo "Unsupported architecture: $(uname -m)"
   exit 1
   ;;
esac

echo "🚀 Creating release for Plandex v$VERSION"
echo "Platform: $PLATFORM"
echo "Architecture: $ARCH"
echo ""

# Check if CLI directory exists
if [[ ! -d "$CLI_DIR" ]]; then
  echo "❌ CLI directory not found: $CLI_DIR"
  exit 1
fi

# Build the binary if it doesn't exist or is outdated
BINARY_PATH="$CLI_DIR/plandex"
if [[ ! -f "$BINARY_PATH" ]] || [[ "$CLI_DIR/main.go" -nt "$BINARY_PATH" ]]; then
  echo "🔨 Building plandex binary..."
  cd "$CLI_DIR"
  go build -o plandex main.go
  cd "$SCRIPT_DIR"
else
  echo "✅ Binary already exists and is up to date"
fi

# Create releases directory
mkdir -p "$RELEASE_DIR"

# Create tarball
TARBALL_NAME="plandex_${VERSION}_${PLATFORM}_${ARCH}.tar.gz"
TARBALL_PATH="$RELEASE_DIR/$TARBALL_NAME"

echo "📦 Creating tarball: $TARBALL_NAME"
cd "$CLI_DIR"
tar -czf "$TARBALL_PATH" plandex
cd "$SCRIPT_DIR"

echo "✅ Tarball created: $TARBALL_PATH"
echo ""

# Display next steps
echo "📋 Next steps:"
echo ""
echo "1. Go to: https://github.com/datagram1/plandex/releases"
echo "2. Click 'Create a new release'"
echo "3. Create tag: cli/v$VERSION"
echo "4. Upload file: $TARBALL_PATH"
echo "5. Add release notes"
echo "6. Publish the release"
echo ""
echo "After publishing, users can install with:"
echo "curl -sL https://raw.githubusercontent.com/datagram1/plandex/main/install.sh | bash"
echo ""
echo "Or test locally:"
echo "PLANDEX_VERSION=$VERSION bash $SCRIPT_DIR/install.sh"
