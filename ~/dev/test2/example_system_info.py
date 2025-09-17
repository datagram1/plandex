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
