@echo off
REM Plandex Installation Script for Windows (Batch wrapper)
REM This script downloads and runs the PowerShell installation script

echo.
echo ================================================================================
echo.
echo 🚀 Plandex • Quick Install (datagram1/plandex) for Windows
echo.
echo ================================================================================
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PowerShell is not available on this system.
    echo Please install PowerShell or use the manual installation method.
    echo.
    echo Manual installation:
    echo 1. Go to: https://github.com/datagram1/plandex/releases/latest
    echo 2. Download the appropriate Windows binary
    echo 3. Extract and add to your PATH
    echo.
    pause
    exit /b 1
)

echo 📥 Downloading and running PowerShell installation script...
echo.

REM Download and execute the PowerShell script
powershell -ExecutionPolicy Bypass -Command "& {Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/datagram1/plandex/main/install.ps1' -OutFile 'install_temp.ps1'; & '.\install_temp.ps1'; Remove-Item 'install_temp.ps1' -Force}"

if %errorlevel% neq 0 (
    echo.
    echo ❌ Installation failed. Please try the manual installation method:
    echo.
    echo 1. Go to: https://github.com/datagram1/plandex/releases/latest
    echo 2. Download the appropriate Windows binary
    echo 3. Extract and add to your PATH
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Installation completed successfully!
echo.
pause
