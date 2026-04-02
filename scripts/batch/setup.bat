@echo off
:: ============================================================
:: CrossPlatform DevToolkit - Windows Setup Script
:: Version: 2.0.0
:: Supports: Windows 10/11, Windows Terminal, CMD, PowerShell
:: ============================================================
setlocal EnableDelayedExpansion

title CrossPlatform DevToolkit - Setup

:: Colors using ANSI (Windows 10+)
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "CYAN=[36m"
set "BOLD=[1m"
set "RESET=[0m"

set "VERSION=2.0.0"
set "INSTALL_DIR=%USERPROFILE%\.devtoolkit"
set "LOG_DIR=%INSTALL_DIR%\logs"
set "CONFIG_DIR=%INSTALL_DIR%\config"
set "BIN_DIR=%INSTALL_DIR%\bin"

:: ── Banner ───────────────────────────────────────────────────
echo.
echo  %CYAN%+==================================================+%RESET%
echo  %CYAN%^|    CrossPlatform DevToolkit v%VERSION%             ^|%RESET%
echo  %CYAN%^|    Windows Terminal Setup Script               ^|%RESET%
echo  %CYAN%+==================================================+%RESET%
echo.

:: ── Check Admin ──────────────────────────────────────────────
net session >nul 2>&1
if %errorLevel% == 0 (
    echo  %GREEN%[OK]%RESET%    Running with Administrator privileges
) else (
    echo  %YELLOW%[WARN]%RESET%  Not running as Administrator
    echo         Some features may be limited
)

:: ── Detect Windows Version ───────────────────────────────────
echo.
echo  %BLUE%--- System Detection ---%RESET%
for /f "tokens=4-5 delims=. " %%i in ('ver') do (
    set "WIN_VER=%%i.%%j"
)
echo  %CYAN%[INFO]%RESET%  Windows Version: %WIN_VER%
echo  %CYAN%[INFO]%RESET%  Install Dir: %INSTALL_DIR%
echo  %CYAN%[INFO]%RESET%  User: %USERNAME%
echo  %CYAN%[INFO]%RESET%  Computer: %COMPUTERNAME%

:: ── Create Directories ───────────────────────────────────────
echo.
echo  %BLUE%--- Creating Directories ---%RESET%

set "DIRS=%INSTALL_DIR% %LOG_DIR% %CONFIG_DIR% %BIN_DIR% %INSTALL_DIR%\cache %INSTALL_DIR%\plugins %INSTALL_DIR%\backups %INSTALL_DIR%\temp"

for %%D in (%DIRS%) do (
    if not exist "%%D" (
        mkdir "%%D" 2>nul
        echo  %GREEN%[OK]%RESET%    Created: %%D
    ) else (
        echo  %YELLOW%[SKIP]%RESET%  Exists: %%D
    )
)

:: ── Check Requirements ───────────────────────────────────────
echo.
echo  %BLUE%--- Checking Requirements ---%RESET%

:: Check Git
where git >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=*" %%v in ('git --version 2^>nul') do set "GIT_VER=%%v"
    echo  %GREEN%[OK]%RESET%    Git: !GIT_VER!
) else (
    echo  %RED%[MISS]%RESET%  Git not found. Download: https://git-scm.com
)

:: Check Python
where python >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=*" %%v in ('python --version 2^>nul') do set "PY_VER=%%v"
    echo  %GREEN%[OK]%RESET%    Python: !PY_VER!
) else (
    echo  %YELLOW%[WARN]%RESET%  Python not found. Download: https://python.org
)

:: Check Node.js
where node >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=*" %%v in ('node --version 2^>nul') do set "NODE_VER=%%v"
    echo  %GREEN%[OK]%RESET%    Node.js: !NODE_VER!
) else (
    echo  %YELLOW%[INFO]%RESET%  Node.js not found (optional)
)

:: Check curl
where curl >nul 2>&1
if %errorLevel% == 0 (
    echo  %GREEN%[OK]%RESET%    curl: available
) else (
    echo  %YELLOW%[WARN]%RESET%  curl not found
)

:: Check PowerShell
where powershell >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=*" %%v in ('powershell -command "$PSVersionTable.PSVersion.ToString()" 2^>nul') do set "PS_VER=%%v"
    echo  %GREEN%[OK]%RESET%    PowerShell: !PS_VER!
)

:: ── Create Config ────────────────────────────────────────────
echo.
echo  %BLUE%--- Creating Configuration ---%RESET%

set "CONFIG_FILE=%CONFIG_DIR%\toolkit.conf"
(
    echo # CrossPlatform DevToolkit Configuration
    echo # Generated: %DATE% %TIME%
    echo # Platform: Windows
    echo.
    echo [general]
    echo version = %VERSION%
    echo install_dir = %INSTALL_DIR%
    echo platform = windows
    echo log_level = INFO
    echo color_output = true
    echo.
    echo [paths]
    echo bin_dir = %BIN_DIR%
    echo log_dir = %LOG_DIR%
    echo cache_dir = %INSTALL_DIR%\cache
    echo backup_dir = %INSTALL_DIR%\backups
    echo.
    echo [tools]
    echo enable_sysinfo = true
    echo enable_netcheck = true
    echo enable_fileorg = true
    echo enable_cleaner = true
) > "%CONFIG_FILE%"
echo  %GREEN%[OK]%RESET%    Config: %CONFIG_FILE%

:: ── Add to PATH ──────────────────────────────────────────────
echo.
echo  %BLUE%--- Updating PATH ---%RESET%

echo %PATH% | find /i "%BIN_DIR%" >nul 2>&1
if %errorLevel% neq 0 (
    setx PATH "%BIN_DIR%;%PATH%" >nul 2>&1
    echo  %GREEN%[OK]%RESET%    Added to PATH: %BIN_DIR%
) else (
    echo  %YELLOW%[SKIP]%RESET%  Already in PATH
)

:: ── Summary ──────────────────────────────────────────────────
echo.
echo  %GREEN%+==================================================+%RESET%
echo  %GREEN%^|     ✅  Setup Complete!                         ^|%RESET%
echo  %GREEN%+==================================================+%RESET%
echo   Install Dir : %INSTALL_DIR%
echo   Config      : %CONFIG_FILE%
echo   Next Steps  : Restart terminal and run 'dtk --help'
echo.

pause
endlocal
