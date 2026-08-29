@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                V-Eval - Local Run Tool (C# Services)
echo =====================================================================
echo.

pushd "%~dp0..\..\"
set "ROOT_DIR=%CD%"
popd

echo [INFO] Project Root Directory: %ROOT_DIR%
echo.

REM --- Step 1: Giai phong cac cong Port phat trien pho bien ---
for %%P in (5173 5174 8080 5000 5001 5005 5006) do (
    echo Dang kiem tra Port %%P...
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%%P" ^| findstr "LISTENING" 2^>nul') do (
        echo Phat hien Tien trinh ID %%a dang chiem dung Port %%P. Tien hanh giai phong...
        taskkill /f /pid %%a >nul 2>&1
    )
)
echo.

REM --- Step 2: Quet git_config.txt de tu dong chay cac Service con ---
set "CONFIG_FILE=%ROOT_DIR%\git_config.txt"
if not exist "%CONFIG_FILE%" (
    echo [ERROR] Khong tim thay file %CONFIG_FILE%!
    pause
    exit /b 1
)

set "ALL_SERVICES_DIR=%ROOT_DIR%\All Services"

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        if exist "!TARGET_PATH!" (
            echo Dang khoi dong !SERVICE_NAME! o local...
            pushd "!TARGET_PATH!"
            
            REM Neu co package.json (Frontend, Node.js Gateway, v.v...)
            if exist "package.json" (
                start "!SERVICE_NAME!" cmd /k "cd /d "%CD%" && npm run dev"
            ) else (
                REM Du an C# (.NET Core)
                set "CSPROJ_PATH="
                
                REM Quet cac file .csproj va tim API project
                for /r %%f in (*.csproj) do (
                    set "FILE_NAME=%%~nxf"
                    echo !FILE_NAME! | findstr /i "API" >nul
                    if !ERRORLEVEL! equ 0 (
                        set "CSPROJ_PATH=%%f"
                    )
                )
                
                REM Neu khong tim thay file API.csproj thi lay bat ky .csproj nao lam fallback
                if "!CSPROJ_PATH!"=="" (
                    for /r %%f in (*.csproj) do (
                        set "CSPROJ_PATH=%%f"
                    )
                )
                
                if not "!CSPROJ_PATH!"=="" (
                    echo Tim thay Project: !CSPROJ_PATH!
                    start "!SERVICE_NAME!" cmd /k "dotnet run --project "!CSPROJ_PATH!""
                ) else (
                    echo [WARNING] Khong tim thay file .csproj hoac package.json trong !SERVICE_NAME!. Bo qua.
                )
            )
            popd
        ) else (
            echo [WARNING] Thu muc "!TARGET_PATH!" khong ton tai. Vui long chay setup.bat truoc.
        )
    )
)

echo.
echo Tat ca cac service da duoc khoi chay trong cac cua so rieng biet.
echo.
pause
