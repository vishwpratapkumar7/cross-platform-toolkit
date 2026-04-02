@echo off
:: ============================================================
:: sysinfo.bat - Windows System Information Tool
:: Works on: Windows 10/11, Windows Terminal, CMD
:: ============================================================
setlocal EnableDelayedExpansion

title System Information - DevToolkit

echo.
echo  ===================================================
echo       SYSTEM INFORMATION REPORT - DevToolkit
echo  ===================================================
echo  Generated: %DATE% %TIME%
echo.

echo  --- SYSTEM ---
echo  Computer Name : %COMPUTERNAME%
echo  Username      : %USERNAME%
echo  User Domain   : %USERDOMAIN%
echo  OS Platform   : Windows
echo  Processor     : %PROCESSOR_IDENTIFIER%
echo  CPU Cores     : %NUMBER_OF_PROCESSORS%
echo  Architecture  : %PROCESSOR_ARCHITECTURE%

echo.
echo  --- OS DETAILS ---
for /f "tokens=*" %%i in ('ver') do echo  Version: %%i
wmic os get Caption,Version,BuildNumber /format:list 2>nul | findstr /v "^$"

echo.
echo  --- MEMORY ---
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /format:list 2>nul | findstr /v "^$"
wmic OS get TotalVirtualMemorySize,FreeVirtualMemory /format:list 2>nul | findstr /v "^$"

echo.
echo  --- DISK DRIVES ---
wmic logicaldisk get Caption,Size,FreeSpace,DriveType /format:list 2>nul | findstr /v "^$"

echo.
echo  --- NETWORK ---
ipconfig /all 2>nul | findstr /i "IPv4 IPv6 Default Gateway DNS"

echo.
echo  --- INSTALLED SOFTWARE (Top 20) ---
wmic product get Name,Version /format:list 2>nul | findstr "Name=" | head /n 20 2>nul || (
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2>nul | findstr "DisplayName" | head /n 20
)

echo.
echo  --- RUNNING PROCESSES ---
tasklist /fo table /nh 2>nul | head /n 20 2>nul || tasklist /fo table /nh 2>nul

echo.
echo  --- ENVIRONMENT VARIABLES ---
echo  PATH: %PATH%
echo  TEMP: %TEMP%
echo  HOME: %USERPROFILE%

echo.
echo  ===================================================
echo       Report Complete - DevToolkit v2.0.0
echo  ===================================================
echo.
pause
endlocal
