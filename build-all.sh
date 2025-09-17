#!/usr/bin/env bash

set -e

VERSION="${1:-2.2.3}"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CLI_DIR="$SCRIPT_DIR/app/cli"
BUILD_DIR="$SCRIPT_DIR/builds"
RELEASE_DIR="$SCRIPT_DIR/releases"

# Clean and create directories
rm -rf "$BUILD_DIR" "$RELEASE_DIR"
mkdir -p "$BUILD_DIR" "$RELEASE_DIR"

echo "🚀 Building Plandex v$VERSION for multiple platforms and architectures"
echo ""

# Define build targets (platform/architecture combinations)
declare -a TARGETS=(
    "darwin/amd64"    # macOS Intel
    "darwin/arm64"    # macOS Apple Silicon
    "linux/amd64"     # Linux x86_64
    "linux/arm64"     # Linux ARM64
    # "windows/amd64"   # Windows x86_64 - skipping due to syscall issues
    # "windows/arm64"   # Windows ARM64 - skipping due to syscall issues
)

# Function to get platform name from GOOS
get_platform_name() {
    case "$1" in
        "darwin") echo "darwin" ;;
        "linux") echo "linux" ;;
        "windows") echo "windows" ;;
        *) echo "$1" ;;
    esac
}

# Function to get architecture name from GOARCH
get_arch_name() {
    case "$1" in
        "amd64") echo "amd64" ;;
        "arm64") echo "arm64" ;;
        "386") echo "386" ;;
        *) echo "$1" ;;
    esac
}

# Build for each target
for target in "${TARGETS[@]}"; do
    IFS='/' read -r GOOS GOARCH <<< "$target"
    PLATFORM=$(get_platform_name "$GOOS")
    ARCH=$(get_arch_name "$GOARCH")
    
    echo "🔨 Building for $PLATFORM/$ARCH..."
    
    # Set output filename
    if [[ "$GOOS" == "windows" ]]; then
        OUTPUT_NAME="plandex.exe"
        TARBALL_NAME="plandex_${VERSION}_${PLATFORM}_${ARCH}.zip"
    else
        OUTPUT_NAME="plandex"
        TARBALL_NAME="plandex_${VERSION}_${PLATFORM}_${ARCH}.tar.gz"
    fi
    
    # Build the binary
    cd "$CLI_DIR"
    GOOS="$GOOS" GOARCH="$GOARCH" go build -ldflags="-s -w" -o "$BUILD_DIR/$OUTPUT_NAME" .
    
    # Create package
    cd "$BUILD_DIR"
    if [[ "$GOOS" == "windows" ]]; then
        zip -q "$RELEASE_DIR/$TARBALL_NAME" "$OUTPUT_NAME"
    else
        tar -czf "$RELEASE_DIR/$TARBALL_NAME" "$OUTPUT_NAME"
    fi
    
    echo "✅ Created $TARBALL_NAME"
done

echo ""
echo "📦 All builds completed successfully!"
echo ""
echo "📋 Created packages:"
ls -la "$RELEASE_DIR"

echo ""
echo "📋 Next steps:"
echo "1. Test the packages locally"
echo "2. Create GitHub release with all packages"
echo "3. Update installation script if needed"
echo ""
echo "🧪 Test installation script:"
echo "PLANDEX_VERSION=$VERSION bash $SCRIPT_DIR/install.sh"
