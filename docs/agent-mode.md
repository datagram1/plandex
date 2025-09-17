# Plandex Agent Mode

Plandex Agent Mode provides autonomous execution capabilities similar to Cursor's agent mode, with JSON-formatted responses perfect for programmatic integration and automation.

## Features

- **Autonomous Execution**: Automatically explores codebase and makes changes without user intervention
- **JSON Output**: Structured responses for easy programmatic parsing
- **Human-Readable Progress**: Optional real-time progress display with timestamps and colors
- **No Plan Dependency**: Can work independently of local plans
- **Real-time Feedback**: Provides job completion, errors, and progress updates

## Usage

### Basic Agent Mode

```bash
plandex agent "Fix the bug in the login function"
```

This runs the agent with JSON output only, perfect for automation scripts.

### Human-Readable Progress

```bash
plandex agent "Add a new API endpoint" --human-readable
```

Displays both human-readable progress and JSON output simultaneously.

### Verbose Mode

```bash
plandex agent "Refactor the database layer" --verbose --human-readable
```

Shows detailed progress information including AI model responses.

### File Output

```bash
plandex agent "Implement user authentication" --output results.json --human-readable
```

Saves JSON responses to a file while showing progress on screen.

### No-Plan Mode

```bash
plandex agent "Analyze the codebase structure" --no-plan --human-readable
```

Works without requiring a local plan context.

## Command Options

| Option | Description | Default |
|--------|-------------|---------|
| `--output`, `-o` | Output file for JSON responses | stdout |
| `--no-plan` | Work without local plan context | true |
| `--auto-exec` | Automatically execute commands | true |
| `--auto-apply` | Automatically apply changes | true |
| `--human-readable` | Display human-readable progress | false |
| `--verbose` | Enable verbose human-readable output | false |

## JSON Response Types

### Job Started
```json
{
  "type": "job_started",
  "job_id": "agent-12345",
  "data": {
    "job_id": "agent-12345",
    "status": "started",
    "message": "Agent job initialized"
  }
}
```

### Status Update
```json
{
  "type": "job_status",
  "job_id": "agent-12345",
  "data": {
    "job_id": "agent-12345",
    "status": "processing",
    "progress": 50,
    "message": "Executing agent task"
  }
}
```

### Agent Reply
```json
{
  "type": "agent_reply",
  "job_id": "agent-12345",
  "message": "I'll help you fix the login function...",
  "data": {
    "job_id": "agent-12345",
    "chunk": "I'll help you fix the login function..."
  }
}
```

### Build Info
```json
{
  "type": "build_info",
  "job_id": "agent-12345",
  "message": "Building src/auth/login.js",
  "data": {
    "job_id": "agent-12345",
    "path": "src/auth/login.js",
    "tokens": 150,
    "finished": true,
    "removed": false
  }
}
```

### Job Completed
```json
{
  "type": "job_completed",
  "job_id": "agent-12345",
  "data": {
    "job_id": "agent-12345",
    "status": "completed",
    "progress": 100,
    "message": "Agent task completed successfully",
    "result": "Task execution finished"
  }
}
```

### Job Error
```json
{
  "type": "job_error",
  "job_id": "agent-12345",
  "error": "Failed to create agent plan: insufficient credits",
  "data": {
    "job_id": "agent-12345",
    "status": "error",
    "error": "Failed to create agent plan: insufficient credits"
  }
}
```

## Human-Readable Output

When `--human-readable` is enabled, the agent displays colored, timestamped progress information:

- 🤖 **Agent Job Started**: Initial job creation
- 📊 **Status Update**: Progress updates with percentage
- 💬 **Agent Reply**: AI model responses (verbose mode only)
- 🔨 **Build Info**: File building progress
- ✅ **Job Completed**: Successful completion
- ❌ **Error**: Error messages

### Example Human-Readable Output

```
[14:30:15] 🤖 Agent Job Started (ID: agent-12345)
[14:30:16] 📊 Status Update [10%] Created temporary plan for agent session
[14:30:17] 📊 Status Update [20%] Analyzing project context
[14:30:18] 📊 Status Update [30%] Executing agent task
[14:30:20] 🔨 Build Info: src/auth/login.js ✅ (150 tokens)
[14:30:25] 📊 Status Update [90%] Stream finished
[14:30:26] ✅ Job Completed Successfully!
```

## Integration Examples

### Python Integration

```python
import subprocess
import json

def run_plandex_agent(prompt, human_readable=False):
    cmd = ["plandex", "agent", prompt]
    if human_readable:
        cmd.append("--human-readable")
    
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    responses = []
    for line in process.stdout:
        try:
            response = json.loads(line.decode().strip())
            responses.append(response)
            
            # Handle different response types
            if response["type"] == "job_completed":
                print("✅ Task completed successfully!")
                break
            elif response["type"] == "job_error":
                print(f"❌ Error: {response['error']}")
                break
                
        except json.JSONDecodeError:
            # Skip non-JSON lines (human-readable output)
            continue
    
    return responses
```

### Node.js Integration

```javascript
const { spawn } = require('child_process');

function runPlandexAgent(prompt, options = {}) {
    const args = ['agent', prompt];
    if (options.humanReadable) args.push('--human-readable');
    if (options.output) args.push('--output', options.output);
    
    const process = spawn('plandex', args);
    const responses = [];
    
    process.stdout.on('data', (data) => {
        const lines = data.toString().split('\n');
        lines.forEach(line => {
            try {
                const response = JSON.parse(line.trim());
                responses.push(response);
                
                // Handle response types
                switch (response.type) {
                    case 'job_completed':
                        console.log('✅ Task completed!');
                        break;
                    case 'job_error':
                        console.error('❌ Error:', response.error);
                        break;
                }
            } catch (e) {
                // Skip non-JSON lines
            }
        });
    });
    
    return new Promise((resolve, reject) => {
        process.on('close', (code) => {
            if (code === 0) {
                resolve(responses);
            } else {
                reject(new Error(`Process exited with code ${code}`));
            }
        });
    });
}
```

## Best Practices

1. **Use `--human-readable` for debugging**: Helps monitor agent progress in real-time
2. **Use `--verbose` for detailed output**: Shows AI model responses and detailed progress
3. **Use `--output` for automation**: Saves JSON responses for later processing
4. **Use `--no-plan` for analysis tasks**: When you don't need to modify the codebase
5. **Handle all response types**: Always check for `job_error` and `job_completed` types

## Troubleshooting

### Common Issues

1. **Import cycle errors**: Make sure you're not importing conflicting packages
2. **Authentication errors**: Ensure you're logged in with `plandex auth`
3. **Plan creation errors**: Check your project permissions and credits
4. **Stream connection errors**: Verify network connectivity and server status

### Debug Mode

Use `--verbose --human-readable` to see detailed progress information and identify where issues occur.

## Comparison with Cursor Agent

| Feature | Cursor Agent | Plandex Agent |
|---------|--------------|---------------|
| Autonomous execution | ✅ | ✅ |
| Multi-file edits | ✅ | ✅ |
| JSON output | ❌ | ✅ |
| Human-readable progress | ✅ | ✅ |
| Programmatic integration | Limited | ✅ |
| No plan dependency | ✅ | ✅ |
