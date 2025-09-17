# Plandex Installation Script for Windows
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1

param(
    [string]$Version = ""
)

# Set error handling
$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success { param([string]$Message) Write-ColorOutput $Message "Green" }
function Write-Info { param([string]$Message) Write-ColorOutput $Message "Cyan" }
function Write-Warning { param([string]$Message) Write-ColorOutput $Message "Yellow" }
function Write-Error { param([string]$Message) Write-ColorOutput $Message "Red" }

# Detect platform and architecture
function Get-PlatformInfo {
    $os = [System.Environment]::OSVersion.Platform
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    
    if ($os -eq "Win32NT") {
        $platform = "windows"
    } else {
        throw "Unsupported platform: $os"
    }
    
    if ($arch -eq "AMD64") {
        $architecture = "amd64"
    } elseif ($arch -eq "ARM64") {
        $architecture = "arm64"
    } else {
        $architecture = "amd64"  # Default fallback
    }
    
    return @{
        Platform = $platform
        Architecture = $architecture
    }
}

# Get latest version from GitHub API
function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/datagram1/plandex/releases/latest" -Method Get
        $tagName = $response.tag_name
        $version = $tagName -replace "^cli/v", ""
        return $version
    }
    catch {
        Write-Error "Failed to get latest version: $($_.Exception.Message)"
        throw
    }
}

# Download and install Plandex
function Install-Plandex {
    param(
        [string]$Version,
        [string]$Platform,
        [string]$Architecture
    )
    
    $downloadUrl = "https://github.com/datagram1/plandex/releases/download/cli/v$Version/plandex_${Version}_${Platform}_${Architecture}.zip"
    $tempDir = [System.IO.Path]::GetTempPath()
    $zipFile = Join-Path $tempDir "plandex.zip"
    $extractDir = Join-Path $tempDir "plandex_extract"
    
    Write-Info "📥 Downloading Plandex v$Version for $Platform/$Architecture"
    Write-Info "👉 $downloadUrl"
    
    try {
        # Download the file
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
        
        # Extract the zip file
        Write-Info "📦 Extracting archive..."
        if (Test-Path $extractDir) {
            Remove-Item $extractDir -Recurse -Force
        }
        Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
        
        # Find the plandex.exe file
        $plandexExe = Get-ChildItem -Path $extractDir -Name "plandex.exe" -Recurse | Select-Object -First 1
        if (-not $plandexExe) {
            throw "plandex.exe not found in downloaded archive"
        }
        
        $sourceFile = Join-Path $extractDir $plandexExe
        
        # Determine installation directory
        $installDir = $env:ProgramFiles
        if (-not (Test-Path $installDir)) {
            $installDir = $env:LOCALAPPDATA + "\Programs"
            if (-not (Test-Path $installDir)) {
                $installDir = $env:USERPROFILE + "\bin"
            }
        }
        
        $targetFile = Join-Path $installDir "plandex.exe"
        
        Write-Info "📁 Installing to: $targetFile"
        
        # Copy the executable
        if (Test-Path $targetFile) {
            Write-Warning "Plandex already exists at $targetFile. Overwriting..."
        }
        
        Copy-Item -Path $sourceFile -Destination $targetFile -Force
        
        # Add to PATH if not already there
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$installDir*") {
            Write-Info "🔧 Adding $installDir to PATH..."
            $newPath = if ($currentPath) { "$currentPath;$installDir" } else { $installDir }
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            Write-Success "✅ Added $installDir to PATH"
        }
        
        # Clean up
        Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
        Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Success "✅ Plandex v$Version installed successfully!"
        Write-Info ""
        Write-Info "🎉 Installation complete!"
        Write-Info ""
        Write-Info "⚡️ Run 'plandex' in any directory to start building!"
        Write-Info ""
        Write-Info "📚 Need help? 👉 https://docs.plandex.ai"
        Write-Info ""
        Write-Info "👋 Join a community of AI builders 👉 https://discord.gg/plandex-ai"
        Write-Info ""
        Write-Warning "Note: You may need to restart your terminal or PowerShell session for PATH changes to take effect."
        
    }
    catch {
        Write-Error "Installation failed: $($_.Exception.Message)"
        throw
    }
}

# Main installation logic
function Main {
    Write-ColorOutput ""
    Write-ColorOutput "=" * 80
    Write-ColorOutput ""
    Write-ColorOutput "🚀 Plandex • Quick Install (datagram1/plandex) for Windows"
    Write-ColorOutput ""
    Write-ColorOutput "=" * 80
    Write-ColorOutput ""
    
    # Get platform info
    $platformInfo = Get-PlatformInfo
    Write-Info "Platform: $($platformInfo.Platform)"
    Write-Info "Architecture: $($platformInfo.Architecture)"
    Write-Info ""
    
    # Get version
    if ($Version) {
        Write-Info "Using custom version: $Version"
    } else {
        Write-Info "Getting latest version..."
        $Version = Get-LatestVersion
        Write-Info "Latest version: $Version"
    }
    Write-Info ""
    
    # Install Plandex
    Install-Plandex -Version $Version -Platform $platformInfo.Platform -Architecture $platformInfo.Architecture
}

# Run the installation
try {
    Main
}
catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}
