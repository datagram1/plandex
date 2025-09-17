#!/usr/bin/env bash

set -e

VERSION="1.0.0"
TARBALL_PATH="releases/plandex_${VERSION}_darwin_arm64.tar.gz"

if [[ ! -f "$TARBALL_PATH" ]]; then
  echo "❌ Tarball not found: $TARBALL_PATH"
  exit 1
fi

echo "🚀 Creating GitHub release for v$VERSION"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed."
  echo "Please install it first: https://cli.github.com/"
  echo ""
  echo "Or manually create the release:"
  echo "1. Go to: https://github.com/datagram1/plandex/releases"
  echo "2. Click 'Create a new release'"
  echo "3. Create tag: cli/v$VERSION"
  echo "4. Upload file: $TARBALL_PATH"
  echo "5. Add release notes"
  echo "6. Publish the release"
  exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
  echo "❌ Not authenticated with GitHub CLI"
  echo "Please run: gh auth login"
  exit 1
fi

# Create the release
echo "📦 Creating release cli/v$VERSION..."
gh release create "cli/v$VERSION" \
  --title "Plandex CLI v$VERSION" \
  --notes "Initial release of datagram1/plandex fork

## Features
- Autonomous AI coding capabilities
- Agent mode with JSON output
- Smart context management
- Full project support

## Installation
\`\`\`bash
curl -sL https://raw.githubusercontent.com/datagram1/plandex/main/install.sh | bash
\`\`\`" \
  "$TARBALL_PATH"

echo ""
echo "✅ Release created successfully!"
echo ""
echo "🎉 Users can now install with:"
echo "curl -sL https://raw.githubusercontent.com/datagram1/plandex/main/install.sh | bash"
echo ""
echo "🧪 Test the installation:"
echo "curl -sL https://raw.githubusercontent.com/datagram1/plandex/main/install.sh | bash"
