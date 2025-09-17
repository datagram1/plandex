#!/usr/bin/env bash

set -e

VERSION="${1:-2.3.0}"
RELEASE_DIR="releases"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 2.3.0"
  exit 1
fi

echo "🚀 Creating GitHub release for v$VERSION"
echo ""

# Check if all release files exist
declare -a FILES=(
  "plandex_${VERSION}_darwin_amd64.tar.gz"
  "plandex_${VERSION}_darwin_arm64.tar.gz"
  "plandex_${VERSION}_linux_amd64.tar.gz"
  "plandex_${VERSION}_linux_arm64.tar.gz"
  "plandex_${VERSION}_windows_amd64.zip"
  "plandex_${VERSION}_windows_arm64.zip"
)

echo "🔍 Checking release files..."
for file in "${FILES[@]}"; do
  if [[ ! -f "$RELEASE_DIR/$file" ]]; then
    echo "❌ Release file not found: $RELEASE_DIR/$file"
    echo "Please run ./build-all.sh $VERSION first"
    exit 1
  fi
done
echo "✅ All release files found"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed."
  echo "Please install it first: https://cli.github.com/"
  echo ""
  echo "Or manually create the release:"
  echo "1. Go to: https://github.com/plandex-ai/plandex/releases"
  echo "2. Click 'Create a new release'"
  echo "3. Create tag: v$VERSION"
  echo "4. Upload all files from $RELEASE_DIR/"
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
echo "📦 Creating release v$VERSION..."
gh release create "v$VERSION" \
  --title "Plandex v$VERSION - Standalone Agent Mode" \
  --notes "## 🚀 Plandex v$VERSION - Major Agent Mode Update

### ✨ New Features

#### 🤖 Standalone Agent Mode
- **Zero Setup Required**: Works immediately after installation with just a \`custom-models.json\` file
- **No Server/Database**: Agent mode now runs completely standalone
- **Auto-Detection**: Automatically detects full mode capabilities and uses them when available
- **Perfect for CI/CD**: Ideal for automated workflows and distributed systems

#### 🔧 Enhanced Agent Capabilities
- **Local Mode by Default**: \`plandex agent\` now works standalone out of the box
- **Automatic Mode Detection**: Seamlessly switches between local and full mode
- **New Command Flags**: 
  - \`--local-mode\`: Force standalone operation
  - \`--full-mode\`: Force server + database operation
- **Improved JSON Output**: Better structured responses for automation

### 🏠 Standalone Installation

\`\`\`bash
# Download and install
curl -sL https://plandex.ai/install.sh | bash

# Set API key
export OPENAI_API_KEY=\"your-key\"

# Start using immediately!
plandex agent \"Fix the bug in the login function\"
\`\`\`

### 📦 Supported Platforms
- macOS (Intel & Apple Silicon)
- Linux (x86_64 & ARM64)
- Windows (x86_64 & ARM64)

### 🔗 Installation
\`\`\`bash
curl -sL https://plandex.ai/install.sh | bash
\`\`\`

### 📚 Documentation
- [Agent Mode Guide](https://docs.plandex.ai/agent-mode)
- [Local Mode Quickstart](https://docs.plandex.ai/hosting/self-hosting/local-mode-quickstart)
- [Model Configuration](https://docs.plandex.ai/models/model-providers)" \
  "${FILES[@]/#/$RELEASE_DIR/}"

echo ""
echo "✅ Release created successfully!"
echo ""
echo "🎉 Users can now install with:"
echo "curl -sL https://plandex.ai/install.sh | bash"
echo ""
echo "🧪 Test the installation:"
echo "curl -sL https://plandex.ai/install.sh | bash"
