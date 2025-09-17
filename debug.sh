#!/bin/bash

echo "🔍 Debugging Plandex Configuration"
echo "=================================="

# 1. Check if LM Studio is running
echo "1. Checking if LM Studio is accessible..."
curl -s http://127.0.0.1:1234/v1/models || echo "❌ LM Studio not accessible at http://127.0.0.1:1234"

# 2. Test the models endpoint
echo -e "\n2. Testing LM Studio models endpoint..."
curl -s http://127.0.0.1:1234/v1/models | jq '.' || echo "❌ Failed to get models from LM Studio"

# 3. Test a simple completion
echo -e "\n3. Testing basic completion..."
curl -s -X POST http://127.0.0.1:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-oss-20b",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }' | jq '.' || echo "❌ Failed basic completion test"

# 4. Check plandex configuration location
echo -e "\n4. Checking plandex configuration..."
echo "Config locations to check:"
echo "- ~/.plandex/config.json"
echo "- ./plandex-config.json"
echo "- Current directory: $(pwd)"

# 5. Validate JSON syntax
echo -e "\n5. Checking JSON syntax of your config..."
if [ -f "config.json" ]; then
    jq '.' config.json > /dev/null && echo "✅ JSON syntax is valid" || echo "❌ JSON syntax error"
else
    echo "ℹ️  No config.json found in current directory"
fi

echo -e "\n📋 Next Steps:"
echo "1. Ensure LM Studio is running with the model loaded"
echo "2. Verify the model name matches what's loaded in LM Studio"
echo "3. Place the corrected config in the right location"
echo "4. Restart plandex server"
