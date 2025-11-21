@echo off
:: Run as Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this batch file as Administrator!
    pause
    exit /b
)

:: Launch GUI Help + Options
powershell.exe -ExecutionPolicy Bypass -File "%~dp0UltimateCleanerGUI.ps1"

:: Pause at the end
pause
