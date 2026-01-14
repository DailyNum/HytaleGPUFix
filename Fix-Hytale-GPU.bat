@echo off
:: ============================================
::  Hytale GPU Fix - One-Click Launcher
::  No admin rights or special permissions needed
:: ============================================

title Hytale GPU Fix
color 0B

echo.
echo   ========================================
echo        HYTALE GPU FIX - LAUNCHER
echo   ========================================
echo.
echo   This tool helps fix invisible models and
echo   rendering issues in Hytale by setting the
echo   correct GPU preference.
echo.
echo   No admin rights required.
echo   No system changes - only user preferences.
echo.
echo   ----------------------------------------
echo.

:: Check if PowerShell script exists in same folder
set "SCRIPT_PATH=%~dp0Hytale-GPU-Selector.ps1"

if not exist "%SCRIPT_PATH%" (
    echo   [ERROR] Hytale-GPU-Selector.ps1 not found!
    echo   Please ensure both files are in the same folder.
    echo.
    pause
    exit /b 1
)

echo   Starting GPU Selector...
echo.

:: Run PowerShell with bypass execution policy (no admin needed)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

:: Keep window open if there was an error
if %ERRORLEVEL% neq 0 (
    echo.
    echo   [!] Script exited with an error.
    pause
)

exit /b 0
