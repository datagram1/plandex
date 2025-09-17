#!/bin/bash

# Example script demonstrating Plandex Agent Mode
# This script shows how to use the new agent mode with different options

echo "🤖 Plandex Agent Mode Examples"
echo "=============================="
echo

# Example 1: Basic agent mode with JSON output
echo "Example 1: Basic agent mode (JSON only)"
echo "Command: plandex agent 'Fix the bug in the login function'"
echo "Output: JSON responses only"
echo

# Example 2: Agent mode with human-readable output
echo "Example 2: Agent mode with human-readable progress"
echo "Command: plandex agent 'Add a new API endpoint' --human-readable"
echo "Output: Human-readable progress + JSON responses"
echo

# Example 3: Verbose agent mode
echo "Example 3: Verbose agent mode"
echo "Command: plandex agent 'Refactor the database layer' --verbose --human-readable"
echo "Output: Detailed human-readable output + JSON responses"
echo

# Example 4: Agent mode with file output
echo "Example 4: Agent mode with file output"
echo "Command: plandex agent 'Implement user authentication' --output results.json --human-readable"
echo "Output: Human-readable progress + JSON saved to results.json"
echo

# Example 5: No-plan mode
echo "Example 5: Agent mode without plan context"
echo "Command: plandex agent 'Analyze the codebase structure' --no-plan --human-readable"
echo "Output: Works without local plan context"
echo

echo "JSON Response Types:"
echo "- job_started: Initial job creation"
echo "- job_status: Progress updates with percentage"
echo "- agent_reply: AI model responses"
echo "- build_info: File building progress"
echo "- job_completed: Successful completion"
echo "- job_error: Error messages"
echo

echo "Human-readable Output Features:"
echo "- Timestamped messages"
echo "- Color-coded status indicators"
echo "- Progress percentages"
echo "- Emoji indicators for different message types"
echo "- Truncated text for readability"
echo

echo "To run these examples, make sure you have:"
echo "1. Plandex CLI installed and configured"
echo "2. Valid authentication set up"
echo "3. A project directory with code"
echo

echo "Example usage:"
echo "cd /path/to/your/project"
echo "plandex agent 'Your prompt here' --human-readable"
