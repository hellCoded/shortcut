@echo off
title StockSetu - Starting...
setlocal enabledelayedexpansion

REM ============================================================
REM  StockSetu Universal Launcher
REM  Works from ANY folder - auto-finds the project
REM ============================================================

set "PROJECT_DIR="

REM 1. Check same folder as this .bat file
if exist "%~dp0run.py" (
    set "PROJECT_DIR=%~dp0"
    goto :launch
)

REM 2. Check current working directory
if exist "%cd%\run.py" (
    set "PROJECT_DIR=%cd%\"
    goto :launch
)

REM 3. Search common code directories
for %%d in (
    "D:\codes\CRUDV2"
    "D:\codes\StockSetu"
    "D:\codes\stocksetu"
    "D:\projects\CRUDV2"
    "D:\projects\StockSetu"
    "C:\codes\CRUDV2"
    "C:\projects\CRUDV2"
    "%USERPROFILE%\codes\CRUDV2"
    "%USERPROFILE%\Desktop\CRUDV2"
    "%USERPROFILE%\Desktop\demo"
) do (
    if exist "%%~d\run.py" (
        set "PROJECT_DIR=%%~d\"
        goto :launch
    )
)

REM 4. Search entire drives (quick scan of top-level folders)
for %%drive in (D: C:) do (
    if exist "%%drive\" (
        for /d %%f in ("%%drive\*") do (
            if exist "%%f\run.py" (
                set "PROJECT_DIR=%%f\"
                goto :launch
            )
            REM Check one level deep
            for /d %%g in ("%%f\*") do (
                if exist "%%g\run.py" (
                    set "PROJECT_DIR=%%g\"
                    goto :launch
                )
            )
        )
    )
)

REM 5. Last resort: ask the user
echo.
echo  [!] Could not find StockSetu (run.py) automatically.
echo.
echo  Enter the full path to the StockSetu folder
echo  (the folder containing run.py):
echo.
set /p "PROJECT_DIR=  Path: "

if not exist "%PROJECT_DIR%\run.py" (
    echo.
    echo  [!] ERROR: run.py not found in "%PROJECT_DIR%"
    echo.
    pause
    exit /b 1
)

:launch
cd /d "%PROJECT_DIR%"
echo.
echo  ╔══════════════════════════════════════╗
echo  ║        StockSetu - Inventory         ║
echo  ║       Global / LAN Access Mode       ║
echo  ╚══════════════════════════════════════╝
echo.
echo  [*] Project found: %PROJECT_DIR%
echo.

REM Activate virtual environment if present
if exist "venv\Scripts\activate.bat" (
    echo  [*] Activating virtual environment...
    call venv\Scripts\activate.bat
) else if exist ".venv\Scripts\activate.bat" (
    echo  [*] Activating virtual environment...
    call .venv\Scripts\activate.bat
)

REM Check Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo  [!] Python not found. Please install Python 3.10+ and try again.
    pause
    exit /b 1
)

REM Add firewall rule for port 5000 (silently fails if not admin)
netsh advfirewall firewall show rule name="StockSetu LAN" >nul 2>&1
if errorlevel 1 (
    echo  [*] Adding firewall rule for port 5000...
    netsh advfirewall firewall add rule name="StockSetu LAN" dir=in action=allow protocol=TCP localport=5000 >nul 2>&1
    if errorlevel 1 (
        echo  [!] Could not add firewall rule.
        echo      Right-click this file and "Run as administrator" for LAN access.
    ) else (
        echo  [OK] Firewall rule added for port 5000.
    )
)

REM Show access URLs
echo.
echo  ============================================
echo   ACCESS URLS
echo  ============================================
echo   Local:   http://localhost:5000
echo.
REM Show clean IP addresses only (no hostnames)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0.1"') do (
    set "_raw=%%a"
    set "_raw=!_raw: =!"
    if not "!_raw!"=="" echo   http://!_raw!:5000
)
echo  ============================================
echo.

echo  [*] Starting StockSetu (accessible on LAN)...
echo  [*] Other devices: open http://YOUR-IP:5000
echo  [*] Press Ctrl+C to stop
echo.
python run.py
pause
