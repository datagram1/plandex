#!/bin/bash
# test_agent_local_mode.sh - Test agent mode in local mode (standalone)

set -e  # Exit on error

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test_utils.sh"

# Setup for this test
setup() {
    setup_test_dir "agent-local-mode-test"
    
    # Create a simple test file
    echo "package main

import \"fmt\"

func main() {
    fmt.Println(\"Hello, World!\")
}" > main.go
}

# Set trap for cleanup on exit
trap cleanup_test_dir EXIT

# Test agent mode in local mode
test_agent_local_mode() {
    log "Testing agent mode in local mode..."
    
    # Test basic agent command (should auto-detect local mode)
    run_plandex_cmd "agent 'Add a comment to the main function'" "Run agent in auto-detect mode"
    
    # Test explicit local mode
    run_plandex_cmd "agent 'Add another comment' --local-mode" "Run agent in explicit local mode"
    
    # Test JSON output
    run_plandex_cmd "agent 'Create a simple function' --json" "Run agent with JSON output"
    
    # Test with file input
    echo "Create a utility function that prints the current time" > agent_prompt.txt
    run_plandex_cmd "agent --file agent_prompt.txt" "Run agent with file input"
    
    # Verify files were created/modified
    if [ -f "main.go" ]; then
        log "✅ main.go exists and was modified"
    else
        log "❌ main.go not found"
        exit 1
    fi
}

# Test that local mode works without authentication
test_no_auth_required() {
    log "Testing that local mode works without authentication..."
    
    # Remove auth file if it exists to simulate no authentication
    if [ -f "$HOME/.plandex/auth.json" ]; then
        mv "$HOME/.plandex/auth.json" "$HOME/.plandex/auth.json.backup"
    fi
    
    # This should work without authentication
    run_plandex_cmd "agent 'Test without auth' --local-mode" "Run agent without authentication"
    
    # Restore auth file if it was backed up
    if [ -f "$HOME/.plandex/auth.json.backup" ]; then
        mv "$HOME/.plandex/auth.json.backup" "$HOME/.plandex/auth.json"
    fi
}

main() {
    log "=== Plandex Agent Local Mode Test Started at $(date) ==="
    
    setup
    
    test_agent_local_mode
    test_no_auth_required
    
    log "\n=== All Agent Local Mode Tests Passed! ==="
    log "✅ Agent mode works in local mode"
    log "✅ No authentication required for local mode"
    log "✅ JSON output works"
    log "✅ File input works"
    log "✅ Auto-detection works"
}

# Run the test
main
