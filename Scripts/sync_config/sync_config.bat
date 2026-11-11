@echo off
setlocal enabledelayedexpansion

REM Lay duong dan tuyet doi den thu muc goc cua du an
pushd "%~dp0..\.."
set "ROOT_DIR=%CD%"
popd

set "CONFIGS_DIR=%ROOT_DIR%\Configs"
set "ALL_SERVICES_DIR=%ROOT_DIR%\All Services"

set "ARG_MODE=%~1"

if "%ARG_MODE%"=="--install-missing" goto :DO_INSTALL_MISSING
if "%ARG_MODE%"=="--force" goto :DO_APPLY_ALL
if "%ARG_MODE%"=="--check" goto :DO_CHECK_STATUS

:MENU
cls
echo =====================================================================
echo           V-Eval - Centralized Configuration Sync Tool
echo =====================================================================
echo.
echo Thu muc goc: %ROOT_DIR%
echo.
echo Chon tac vu dong bo cau hinh:
echo   [1] Nap cau hinh chuan vao tat ca Service [Configs -> Services]
echo   [2] Gom cau hinh tu may local vao thu muc Configs [Services -> Configs]
echo   [3] Kiem tra trang thai cau hinh cua cac Service
echo   [4] Thoat
echo.
set "CHOICE=1"
set /p "CHOICE=Nhap lua chon cua ban [1, 2, 3, 4 - Mac dinh: 1]: "

if "%CHOICE%"=="1" goto :DO_APPLY_ALL
if "%CHOICE%"=="2" goto :DO_COLLECT_ALL
if "%CHOICE%"=="3" goto :DO_CHECK_STATUS
if "%CHOICE%"=="4" goto :EOF
goto :MENU

REM =====================================================================
REM TAC VU 1: NAP CAU HINH CHUAN VAO SERVICES (Configs -> Services)
REM =====================================================================
:DO_APPLY_ALL
echo.
echo =====================================================================
echo [SYNC DOWN] Dang nap cau hinh chuan vao cac Service...
echo =====================================================================
echo.

call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Gateway\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Gateway\V-Eval-Gateway.API\appsettings.json" "V-Eval-Gateway" "%ALL_SERVICES_DIR%\V-Eval-Gateway"
call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Identity_Service\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Identity_Service\V-Eval-Identity_Service.API\appsettings.json" "V-Eval-Identity_Service" "%ALL_SERVICES_DIR%\V-Eval-Identity_Service"
call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Content_Service\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Content_Service\V-Eval-Content_Service.API\appsettings.json" "V-Eval-Content_Service" "%ALL_SERVICES_DIR%\V-Eval-Content_Service"
call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Practice_Service\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Practice_Service\V-Eval-Practice_Service.API\appsettings.json" "V-Eval-Practice_Service" "%ALL_SERVICES_DIR%\V-Eval-Practice_Service"
call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Ai_Engine\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API\appsettings.json" "V-Eval-Ai_Engine API" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine"
call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Ai_Engine\rag-service\.env" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\rag-service\.env" "V-Eval-Ai_Engine Python RAG" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine"
call :SYNC_ONE_DOWN "%CONFIGS_DIR%\V-Eval-Web_Client\.env" "%ALL_SERVICES_DIR%\V-Eval-Web_Client\.env" "V-Eval-Web_Client" "%ALL_SERVICES_DIR%\V-Eval-Web_Client"

echo.
echo [HOAN TAT] Da dong bo toan bo cau hinh chuan vao cac Service!
if "%ARG_MODE%"=="" pause
goto :EOF

REM =====================================================================
REM TAC VU 2: GOM CAU HINH TU SERVICES VAO THU MUC CONFIGS (Services -> Configs)
REM =====================================================================
:DO_COLLECT_ALL
echo.
echo =====================================================================
echo [SYNC UP] Dang gom cau hinh tu cac Service vao System-Repo/Configs...
echo =====================================================================
echo.

call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Gateway\V-Eval-Gateway.API\appsettings.json" "%CONFIGS_DIR%\V-Eval-Gateway\appsettings.json" "V-Eval-Gateway"
call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Identity_Service\V-Eval-Identity_Service.API\appsettings.json" "%CONFIGS_DIR%\V-Eval-Identity_Service\appsettings.json" "V-Eval-Identity_Service"
call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Content_Service\V-Eval-Content_Service.API\appsettings.json" "%CONFIGS_DIR%\V-Eval-Content_Service\appsettings.json" "V-Eval-Content_Service"
call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Practice_Service\V-Eval-Practice_Service.API\appsettings.json" "%CONFIGS_DIR%\V-Eval-Practice_Service\appsettings.json" "V-Eval-Practice_Service"
call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API\appsettings.json" "%CONFIGS_DIR%\V-Eval-Ai_Engine\appsettings.json" "V-Eval-Ai_Engine API"
call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\rag-service\.env" "%CONFIGS_DIR%\V-Eval-Ai_Engine\rag-service\.env" "V-Eval-Ai_Engine Python RAG"
call :SYNC_ONE_UP "%ALL_SERVICES_DIR%\V-Eval-Web_Client\.env" "%CONFIGS_DIR%\V-Eval-Web_Client\.env" "V-Eval-Web_Client"

echo.
echo [HOAN TAT] Da gom cau hinh xong! Ban co the commit va push System-Repo de chia se cho ca team.
if "%ARG_MODE%"=="" pause
goto :EOF

REM =====================================================================
REM TAC VU 3: KIEM TRA TRANG THAI CAU HINH (Check Status)
REM =====================================================================
:DO_CHECK_STATUS
echo.
echo =====================================================================
echo [STATUS] Kiem tra trang thai file cau hinh tai tung Service...
echo =====================================================================
echo.

call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Gateway\V-Eval-Gateway.API\appsettings.json" "V-Eval-Gateway [appsettings.json]"
call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Identity_Service\V-Eval-Identity_Service.API\appsettings.json" "V-Eval-Identity_Service [appsettings.json]"
call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Content_Service\V-Eval-Content_Service.API\appsettings.json" "V-Eval-Content_Service [appsettings.json]"
call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Practice_Service\V-Eval-Practice_Service.API\appsettings.json" "V-Eval-Practice_Service [appsettings.json]"
call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API\appsettings.json" "V-Eval-Ai_Engine API [appsettings.json]"
call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\rag-service\.env" "V-Eval-Ai_Engine Python RAG [.env]"
call :CHECK_ONE "%ALL_SERVICES_DIR%\V-Eval-Web_Client\.env" "V-Eval-Web_Client [.env]"

echo.
if "%ARG_MODE%"=="" pause
goto :EOF

REM =====================================================================
REM TAC VU PHU: CHI NAP NHUNG FILE CON THIEU (Install Missing)
REM =====================================================================
:DO_INSTALL_MISSING
echo [INFO] Kiem tra va tu dong bo sung cau hinh neu con thieu...

call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Gateway\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Gateway\V-Eval-Gateway.API\appsettings.json" "V-Eval-Gateway" "%ALL_SERVICES_DIR%\V-Eval-Gateway"
call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Identity_Service\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Identity_Service\V-Eval-Identity_Service.API\appsettings.json" "V-Eval-Identity_Service" "%ALL_SERVICES_DIR%\V-Eval-Identity_Service"
call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Content_Service\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Content_Service\V-Eval-Content_Service.API\appsettings.json" "V-Eval-Content_Service" "%ALL_SERVICES_DIR%\V-Eval-Content_Service"
call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Practice_Service\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Practice_Service\V-Eval-Practice_Service.API\appsettings.json" "V-Eval-Practice_Service" "%ALL_SERVICES_DIR%\V-Eval-Practice_Service"
call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Ai_Engine\appsettings.json" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API\appsettings.json" "V-Eval-Ai_Engine API" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine"
call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Ai_Engine\rag-service\.env" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\rag-service\.env" "V-Eval-Ai_Engine Python RAG" "%ALL_SERVICES_DIR%\V-Eval-Ai_Engine"
call :INSTALL_IF_MISSING "%CONFIGS_DIR%\V-Eval-Web_Client\.env" "%ALL_SERVICES_DIR%\V-Eval-Web_Client\.env" "V-Eval-Web_Client" "%ALL_SERVICES_DIR%\V-Eval-Web_Client"

goto :EOF

REM =====================================================================
REM SUBROUTINES
REM =====================================================================
:SYNC_ONE_DOWN
set "SRC_FILE=%~1"
set "DST_FILE=%~2"
set "LABEL=%~3"
set "SVC_ROOT=%~4"

if not exist "%SRC_FILE%" (
    echo [BO QUA] Khong tim thay file nguon Configs cho %LABEL%
    exit /b 0
)

if not "!SVC_ROOT!"=="" if not exist "!SVC_ROOT!" (
    echo [BO QUA] Service %LABEL% chua duoc clone tai local.
    exit /b 0
)

REM Lay thu muc dich
for %%F in ("%DST_FILE%") do set "DST_DIR=%%~dpF"
if not exist "%DST_DIR%" mkdir "%DST_DIR%" >nul 2>&1

if exist "%DST_FILE%" (
    copy /y "%DST_FILE%" "%DST_FILE%.bak" >nul 2>&1
)

copy /y "%SRC_FILE%" "%DST_FILE%" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Da cap nhat cau hinh cho: %LABEL%
) else (
    echo [ERROR] Loi khi copy cau hinh cho: %LABEL%
)
exit /b 0

:SYNC_ONE_UP
set "SRC_FILE=%~1"
set "DST_FILE=%~2"
set "LABEL=%~3"

if not exist "%SRC_FILE%" (
    echo [BO QUA] Service %LABEL% chua co file cau hinh tai local de gom.
    exit /b 0
)

for %%F in ("%DST_FILE%") do set "DST_DIR=%%~dpF"
if not exist "%DST_DIR%" mkdir "%DST_DIR%" >nul 2>&1

copy /y "%SRC_FILE%" "%DST_FILE%" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Da gom cau hinh cho: %LABEL%
) else (
    echo [ERROR] Loi khi gom cau hinh cho: %LABEL%
)
exit /b 0

:CHECK_ONE
set "CHECK_PATH=%~1"
set "LABEL=%~2"

if exist "%CHECK_PATH%" (
    echo   [SAN SANG] %LABEL%
) else (
    echo   [CHUA CO ] %LABEL% - Can chay sync de bo sung
)
exit /b 0

:INSTALL_IF_MISSING
set "SRC_FILE=%~1"
set "DST_FILE=%~2"
set "LABEL=%~3"
set "SVC_ROOT=%~4"

if not exist "%SRC_FILE%" exit /b 0
if not "!SVC_ROOT!"=="" if not exist "!SVC_ROOT!" exit /b 0

if not exist "%DST_FILE%" (
    for %%F in ("%DST_FILE%") do set "DST_DIR=%%~dpF"
    if not exist "!DST_DIR!" mkdir "!DST_DIR!" >nul 2>&1
    copy /y "%SRC_FILE%" "%DST_FILE%" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo [BO SUNG] Da tu dong tao file cau hinh con thieu cho: %LABEL%
    )
)
exit /b 0
