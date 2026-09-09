@echo off
title Claude Code Universal Project Launcher

:: If a folder was dragged and dropped onto this script, use it directly
if not "%~1"=="" (
    set "TARGET_DIR=%~1"
    goto :LAUNCH
)

:: Otherwise, default to the folder this script itself lives in, so a plain
:: double-click just starts Claude here without any prompt.
set "TARGET_DIR=%~dp0"

:LAUNCH
:: Strip quotes and trailing backslash
set TARGET_DIR=%TARGET_DIR:"=%
if "%TARGET_DIR:~-1%"=="\" set "TARGET_DIR=%TARGET_DIR:~0,-1%"

if not exist "%TARGET_DIR%" (
    echo.
    echo [ERROR] Directory does not exist: %TARGET_DIR%
    echo.
    pause
    exit /b 1
)

:: Session name: the 3rd argument if given, otherwise the folder's own name.
:: No prompt, no persisted settings file - this must be able to run fully
:: unattended (e.g. a remote/automated fresh start with nobody at the
:: keyboard), and renaming a session after the fact works fine from Remote
:: Control / another Claude Code session, so there's nothing to gain from
:: blocking on human input here.
set "SESSION_NAME=%~3"
if "%SESSION_NAME%"=="" for %%F in ("%TARGET_DIR%") do set "SESSION_NAME=%%~nxF"

:: Reasoning effort - defaults to "medium" to reduce token/credit usage vs
:: Claude Code's own default of "high". Override by passing it as the 2nd
:: argument (e.g. ClaudeProjectLauncher.bat "C:\path\to\project" high).
set "EFFORT=%~2"
if "%EFFORT%"=="" set "EFFORT=medium"

echo.
echo ================================================================
echo  Project:  %TARGET_DIR%
echo  Session:  %SESSION_NAME%
echo  Effort:   %EFFORT%
echo  Flags:    -c --remote-control=%SESSION_NAME% --effort %EFFORT%
echo ================================================================
echo.

:: When this launcher is itself invoked by an agent's shell tool (rather than
:: typed by hand at a terminal), the spawned session inherits a
:: CLAUDE_CODE_CHILD_SESSION marker that disables transcript saving entirely
:: - so -c never finds anything to continue, even after real conversations.
:: Force persistence regardless of how this script was invoked.
set "CLAUDE_CODE_FORCE_SESSION_PERSISTENCE=1"

:: -c (continue) fails with "No conversation found to continue" on a
:: genuinely first-ever run in this folder - fall back to a fresh session
:: in that case instead of just exiting, so this script works unchanged
:: on both first and later runs.
set "CLAUDE_CMD=call claude -c --remote-control=%SESSION_NAME% --effort %EFFORT% || call claude --remote-control=%SESSION_NAME% --effort %EFFORT%"

:: NOTE: deliberately NOT using "wt.exe -d ... cmd /k ..." here even though Windows
:: Terminal is present - wt.exe re-parses its own command-line argument before handing
:: it to the inner cmd.exe, which was silently dropping the --remote-control value
:: (confirmed by testing: a bare "cmd /k" with this exact command works correctly,
:: the same command wrapped through wt.exe does not). Plain cmd window instead.
cd /d "%TARGET_DIR%"
start "Claude - %SESSION_NAME%" cmd /k "%CLAUDE_CMD%"
