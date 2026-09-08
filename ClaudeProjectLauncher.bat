@echo off
title Claude Code Universal Project Launcher

:: If a folder was dragged and dropped onto this script, use it directly
if not "%~1"=="" (
    set "TARGET_DIR=%~1"
    goto :LAUNCH
)

:: Otherwise, ask user for the folder path
echo ====================================================================
echo                 Claude Code Universal Project Launcher
echo ====================================================================
echo.
echo Drag and drop any folder onto this file, or paste the path below:
echo.
set /p TARGET_DIR="Project path: "

:LAUNCH
:: Strip quotes
set TARGET_DIR=%TARGET_DIR:"=%

if not exist "%TARGET_DIR%" (
    echo.
    echo [ERROR] Directory does not exist: %TARGET_DIR%
    echo.
    pause
    exit /b 1
)

:: Derive session name from directory name
for %%F in ("%TARGET_DIR%") do set "SESSION_NAME=%%~nxF"

echo.
echo ================================================================
echo  Project:  %TARGET_DIR%
echo  Session:  %SESSION_NAME%
echo  Flags:    -c --remote-control "%SESSION_NAME%"
echo ================================================================
echo.

:: -c (continue) fails with "No conversation found to continue" on a
:: genuinely first-ever run in this folder - fall back to a fresh session
:: in that case instead of just exiting, so this script works unchanged
:: on both first and later runs.
set "CLAUDE_CMD=call claude -c --remote-control \"%SESSION_NAME%\" || call claude --remote-control \"%SESSION_NAME%\""

where wt.exe >nul 2>&1
if %errorLevel% equ 0 (
    start "" wt.exe -d "%TARGET_DIR%" --title "Claude - %SESSION_NAME%" cmd /k "%CLAUDE_CMD%"
) else (
    cd /d "%TARGET_DIR%"
    start "Claude - %SESSION_NAME%" cmd /k "%CLAUDE_CMD%"
)
