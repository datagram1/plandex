# Complete Plandex Guide: Building a Python System Information Tool

This guide will walk you through using Plandex to create a Python script that displays system information (processor, memory, disk space, etc.) and runs it from the command line.

## Prerequisites

### 1. Install Plandex

First, install Plandex using the official installer:

```bash
curl -sL https://plandex.ai/install.sh | bash
```

Or manually download from the [releases page](https://github.com/plandex-ai/plandex/releases).

### 2. Set Up API Access

You have three options for using Plandex:

#### Option A: Plandex Cloud (Easiest - Recommended for beginners)
- Go to [app.plandex.ai/start](https://app.plandex.ai/start?modelsMode=integrated)
- Sign up and start a trial
- No API keys needed - everything is handled for you

#### Option B: Plandex Cloud with Your Own API Key
- Sign up at [OpenRouter.ai](https://openrouter.ai/signup)
- Generate an API key at [OpenRouter.ai/keys](https://openrouter.ai/keys)
- Set the environment variable:
```bash
export OPENROUTER_API_KEY=your_api_key_here
```
- Go to [app.plandex.ai/start](https://app.plandex.ai/start?modelsMode=byo)

#### Option C: Self-Hosted/Local Mode
- Follow the [local-mode quickstart guide](https://docs.plandex.ai/docs/hosting/self-hosting/local-mode-quickstart.md)
- Requires Docker and PostgreSQL setup

## Step-by-Step Project Creation

### Step 1: Navigate to Your Project Directory

```bash
cd ~/dev/test2
```

### Step 2: Start Plandex REPL

```bash
plandex
```

This will start the Plandex REPL (Read-Eval-Print Loop) in chat mode. You'll see a prompt like:

```
Plandex REPL - Chat Mode
Type \help for help, \quit to quit
>
```

### Step 3: Create Your First Plan

In the REPL, type:

```
Create a Python script that displays system information including:
- CPU/processor information
- Memory (RAM) details
- Hard disk space
- Operating system information
- Network information

The script should be well-formatted and easy to read when run from the command line.
```

### Step 4: Switch to Tell Mode

After Plandex responds with a plan, it will suggest switching to "tell mode" for implementation. Type:

```
\tell
```

This switches you to implementation mode where Plandex will actually create and modify files.

### Step 5: Let Plandex Build Your Project

Plandex will:
1. Create a Python file (likely `system_info.py`)
2. Implement the system information gathering functionality
3. Add proper formatting and error handling
4. Make the script executable

### Step 6: Review and Test

Plandex will show you the changes it made. You can:

- Review the generated code
- Test the script by running it
- Ask for modifications if needed

### Step 7: Run Your Script

Once satisfied, run your Python script:

```bash
python system_info.py
```

## Understanding Plandex Commands

### REPL Commands

- `\help` or `\h` - Show help
- `\quit` or `\q` - Exit the REPL
- `\tell` or `\t` - Switch to tell mode (implementation)
- `\chat` or `\ch` - Switch to chat mode (conversation)
- `\current` - Show current plan information
- `\new` - Start a new plan
- `\plans` - List all plans
- `@filename` - Load a file into context
- `\run filename` - Use a file as a prompt

### Autonomy Levels

You can start Plandex with different autonomy levels:

```bash
# Manual mode - step by step, no automation
plandex --no-auto

# Basic automation - auto-continue plans
plandex --basic

# Plus automation - auto-update context, smart context, auto-commit
plandex --plus

# Semi-automatic - auto-load context
plandex --semi

# Full automation - auto-apply, auto-exec, auto-debug
plandex --full
```

### Model Packs

Choose different model packs for different needs:

```bash
# Daily driver (balanced capability, cost, speed) - DEFAULT
plandex --daily

# Reasoning models for complex planning
plandex --reasoning

# Strong models for complex tasks
plandex --strong

# Cheap models for simple tasks
plandex --cheap

# Open source models
plandex --oss
```

## Expected Project Structure

After following this guide, you should have:

```
~/dev/test2/
├── .plandex/           # Plandex configuration
│   └── plans/         # Your plan files
├── system_info.py     # Your Python script
├── requirements.txt   # Python dependencies
└── PLANDEX_GUIDE.md   # This guide
```

## Sample Python Script

Here's an example of what your `system_info.py` might look like (also included as `example_system_info.py`):

```python
#!/usr/bin/env python3
"""
System Information Tool
Displays comprehensive system information including CPU, memory, disk, and OS details.
"""

import platform
import psutil
import socket
import sys
from datetime import datetime

def get_cpu_info():
    """Get CPU information."""
    cpu_info = {
        'processor': platform.processor(),
        'architecture': platform.machine(),
        'physical_cores': psutil.cpu_count(logical=False),
        'logical_cores': psutil.cpu_count(logical=True),
        'cpu_percent': psutil.cpu_percent(interval=1)
    }
    return cpu_info

def get_memory_info():
    """Get memory information."""
    memory = psutil.virtual_memory()
    memory_info = {
        'total': memory.total,
        'available': memory.available,
        'used': memory.used,
        'percent': memory.percent
    }
    return memory_info

def get_disk_info():
    """Get disk information."""
    disk = psutil.disk_usage('/')
    disk_info = {
        'total': disk.total,
        'used': disk.used,
        'free': disk.free,
        'percent': (disk.used / disk.total) * 100
    }
    return disk_info

def get_os_info():
    """Get operating system information."""
    os_info = {
        'system': platform.system(),
        'release': platform.release(),
        'version': platform.version(),
        'machine': platform.machine(),
        'processor': platform.processor(),
        'python_version': sys.version.split()[0]
    }
    return os_info

def get_network_info():
    """Get network information."""
    try:
        hostname = socket.gethostname()
        ip_address = socket.gethostbyname(hostname)
    except:
        hostname = "Unknown"
        ip_address = "Unknown"
    
    network_info = {
        'hostname': hostname,
        'ip_address': ip_address
    }
    return network_info

def format_bytes(bytes_value):
    """Convert bytes to human readable format."""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_value < 1024.0:
            return f"{bytes_value:.1f} {unit}"
        bytes_value /= 1024.0
    return f"{bytes_value:.1f} PB"

def main():
    """Main function to display system information."""
    print("=" * 50)
    print("           SYSTEM INFORMATION")
    print("=" * 50)
    print(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # CPU Information
    print("🖥️  CPU Information:")
    cpu = get_cpu_info()
    print(f"   • Processor: {cpu['processor']}")
    print(f"   • Architecture: {cpu['architecture']}")
    print(f"   • Physical Cores: {cpu['physical_cores']}")
    print(f"   • Logical Cores: {cpu['logical_cores']}")
    print(f"   • CPU Usage: {cpu['cpu_percent']:.1f}%")
    print()
    
    # Memory Information
    print("💾 Memory Information:")
    memory = get_memory_info()
    print(f"   • Total RAM: {format_bytes(memory['total'])}")
    print(f"   • Available RAM: {format_bytes(memory['available'])}")
    print(f"   • Used RAM: {format_bytes(memory['used'])}")
    print(f"   • Memory Usage: {memory['percent']:.1f}%")
    print()
    
    # Disk Information
    print("💿 Disk Information:")
    disk = get_disk_info()
    print(f"   • Total Space: {format_bytes(disk['total'])}")
    print(f"   • Used Space: {format_bytes(disk['used'])}")
    print(f"   • Free Space: {format_bytes(disk['free'])}")
    print(f"   • Disk Usage: {disk['percent']:.1f}%")
    print()
    
    # Operating System Information
    print("🖥️  Operating System:")
    os_info = get_os_info()
    print(f"   • OS: {os_info['system']} {os_info['release']}")
    print(f"   • Version: {os_info['version']}")
    print(f"   • Machine: {os_info['machine']}")
    print(f"   • Python Version: {os_info['python_version']}")
    print()
    
    # Network Information
    print("🌐 Network Information:")
    network = get_network_info()
    print(f"   • Hostname: {network['hostname']}")
    print(f"   • IP Address: {network['ip_address']}")
    print()
    
    print("=" * 50)

if __name__ == "__main__":
    try:
        main()
    except ImportError as e:
        print(f"Error: Missing required package. Please install psutil:")
        print("pip install psutil")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
```

## Dependencies

Your script will likely need the `psutil` library for system information. Create a `requirements.txt` file:

```
psutil>=5.9.0
```

Install dependencies with:
```bash
pip install -r requirements.txt
```

## Sample Python Script Output

Your script should display something like:

```
=== System Information ===

CPU Information:
- Processor: Intel Core i7-9750H
- Architecture: x86_64
- Cores: 6 physical, 12 logical

Memory Information:
- Total RAM: 16.0 GB
- Available RAM: 8.2 GB
- Used RAM: 7.8 GB

Disk Information:
- Total Space: 500.0 GB
- Used Space: 200.0 GB
- Available Space: 300.0 GB

Operating System:
- OS: macOS 14.6.0
- Kernel: Darwin 23.6.0
- Python Version: 3.11.5

Network Information:
- Hostname: my-computer.local
- IP Address: 192.168.1.100
```

## Tips for Success

1. **Start Simple**: Begin with basic system info and expand from there
2. **Be Specific**: The more detailed your prompt, the better the results
3. **Iterate**: Don't expect perfection on the first try - refine your requirements
4. **Use Context**: Load relevant files with `@filename` if you have specific requirements
5. **Test Early**: Run your script frequently to catch issues early

## Troubleshooting

### Common Issues

1. **"Command not found: plandex"**
   - Make sure Plandex is installed and in your PATH
   - Try running the install script again

2. **API Key Issues**
   - Verify your API key is set correctly: `echo $OPENROUTER_API_KEY`
   - Check that your OpenRouter account has credits

3. **Permission Errors**
   - Make sure you're in the right directory
   - Check file permissions if you can't run the Python script

4. **Python Not Found**
   - Install Python if not already installed
   - Use `python3` instead of `python` if needed

### Getting Help

- Use `\help` in the REPL
- Check the [official documentation](https://docs.plandex.ai/)
- Visit the [GitHub repository](https://github.com/plandex-ai/plandex) for issues

## Next Steps

Once you've successfully created your system information tool:

1. **Enhance the Script**: Add more system details, better formatting, or export options
2. **Create a Package**: Turn it into a proper Python package with setup.py
3. **Add CLI Arguments**: Make it configurable with command-line options
4. **Create Tests**: Add unit tests for your functions
5. **Documentation**: Add docstrings and create a README

## Advanced Plandex Features to Explore

- **Context Management**: Learn how to load and manage project context
- **Version Control**: Use Plandex's built-in version control for your plans
- **Branches**: Create branches for different features
- **Multi-file Projects**: Build more complex applications
- **Integration**: Use Plandex with existing projects

This guide should get you started with Plandex and help you create your first Python project successfully!
