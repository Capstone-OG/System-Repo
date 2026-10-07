@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo           V-Eval - Local Full Services Runner Tool
echo =====================================================================
echo.

pushd "%~dp0..\.."
set "ROOT_DIR=%CD%"
popd

echo [INFO] Project Root Directory: %ROOT_DIR%
echo.

REM --- Step 1: Chon che do khoi chay ---
echo Chon che do khoi dong:
echo   [1] Khoi dong FULL tat ca 7 Service [Gateway, Identity, Content, Practice, AI Engine, Python RAG, Web Client]
echo   [2] Khoi dong cac Microservices C# [.NET Core]
echo   [3] Khoi dong chi AI Subsystem [AI Engine .NET + Python FastAPI RAG]
echo   [4] Khoi dong chi Web Client [React 19 Vite - Port 5173]
echo   [5] Giai phong / Kill tat ca cac Port va Tien trinh dang chiem dung
echo   [6] Thoat
echo.
set "CHOICE=1"
set /p "CHOICE=Nhap lua chon cua ban [Mac dinh: 1]: "

if "%CHOICE%"=="6" (
    echo Tam biet!
    exit /b 0
)

REM --- Step 2: Giai phong cac cong Port phat trien ---
echo.
echo =====================================================================
echo [BƯỚC 1] Giai phong cac cong Port tranh xung dot...
echo =====================================================================
set "PORTS_TO_CLEAN=5212 5155 5156 5249 5250 5261 5104 8000 5000 5001 5002 5005 5006 5173 5174 8080 3000"

for %%P in (%PORTS_TO_CLEAN%) do (
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%%P" ^| findstr "LISTENING" 2^>nul') do (
        echo [KILL] Phat hien Tien trinh ID %%a chiem dung Port %%P. Dang giai phong...
        taskkill /f /pid %%a >nul 2>&1
    )
)
echo [DONE] Da giai phong hoan tat cac Port phat trien.
echo.

if "%CHOICE%"=="5" (
    echo [INFO] Da giai phong thanh cong tat ca cac cong.
    pause
    exit /b 0
)

if "%CHOICE%"=="4" goto start_web_only

set "ALL_SERVICES_DIR=%ROOT_DIR%\All Services"

REM --- Step 2.5: Kiem tra va tu dong bo sung cau hinh neu con thieu ---
if exist "%ROOT_DIR%\Scripts\sync_config\sync_config.bat" (
    call "%ROOT_DIR%\Scripts\sync_config\sync_config.bat" --install-missing
)

REM --- Step 3: Khoi dong cac Service theo lua chon ---
echo =====================================================================
echo [BƯỚC 2] Tien hanh khoi dong cac Service...
echo =====================================================================
echo.

REM 1. Identity Service
if "%CHOICE%"=="1" goto start_identity
if "%CHOICE%"=="2" goto start_identity
goto check_ai

:start_identity
set "ID_PATH=%ALL_SERVICES_DIR%\V-Eval-Identity_Service\V-Eval-Identity_Service.API\V-Eval-Identity_Service.API.csproj"
if exist "%ID_PATH%" (
    echo [START] Dang khoi dong Identity Service [Port 5155 / 5156]...
    start "V-Eval - Identity Service [HTTP:5155 | gRPC:5156]" cmd /k "dotnet run --project "%ID_PATH%""
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay Identity Service tai: %ID_PATH%
)

REM 2. Content Service
set "CONTENT_PATH=%ALL_SERVICES_DIR%\V-Eval-Content_Service\V-Eval-Content_Service.API\V-Eval-Content_Service.API.csproj"
if exist "%CONTENT_PATH%" (
    echo [START] Dang khoi dong Content Service [Port 5249 / 5250]...
    start "V-Eval - Content Service [HTTP:5249 | gRPC:5250]" cmd /k "dotnet run --project "%CONTENT_PATH%""
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay Content Service tai: %CONTENT_PATH%
)

REM 3. Practice Service
set "PRACTICE_PATH=%ALL_SERVICES_DIR%\V-Eval-Practice_Service\V-Eval-Practice_Service.API\V-Eval-Practice_Service.API.csproj"
if exist "%PRACTICE_PATH%" (
    echo [START] Dang khoi dong Practice Service [Port 5261]...
    start "V-Eval - Practice Service [HTTP:5261]" cmd /k "dotnet run --project "%PRACTICE_PATH%""
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay Practice Service tai: %PRACTICE_PATH%
)

:check_ai
REM 4. AI Engine .NET API
if "%CHOICE%"=="1" goto start_ai
if "%CHOICE%"=="2" goto start_ai_net
if "%CHOICE%"=="3" goto start_ai
goto check_gateway

:start_ai
:start_ai_net
set "AI_NET_PATH=%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API\V-Eval-Ai_Engine.API.csproj"
if exist "%AI_NET_PATH%" (
    echo [START] Dang khoi dong AI Engine .NET API [Port 5104]...
    start "V-Eval - AI Engine .NET API [HTTP:5104]" cmd /k "dotnet run --project "%AI_NET_PATH%""
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay AI Engine .NET tai: %AI_NET_PATH%
)

if "%CHOICE%"=="2" goto check_gateway

REM 5. AI Engine Python FastAPI RAG Service
set "AI_PY_DIR=%ALL_SERVICES_DIR%\V-Eval-Ai_Engine\rag-service"
if exist "%AI_PY_DIR%\main.py" (
    echo [START] Dang khoi dong AI Engine Python FastAPI RAG [Port 8000]...
    set "PY_CMD=python -m uvicorn main:app --port 8000 --reload"
    if exist "%AI_PY_DIR%\.venv\Scripts\python.exe" (
        set "PY_CMD="%AI_PY_DIR%\.venv\Scripts\python.exe" -m uvicorn main:app --port 8000 --reload"
    )
    start "V-Eval - AI Engine Python RAG [FastAPI:8000]" cmd /k "cd /d "%AI_PY_DIR%" && !PY_CMD!"
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay Python rag-service tai: %AI_PY_DIR%
)

:check_gateway
if "%CHOICE%"=="3" goto show_summary

REM 6. API Gateway YARP
set "GATEWAY_PATH=%ALL_SERVICES_DIR%\V-Eval-Gateway\V-Eval-Gateway.API\V-Eval-Gateway.API.csproj"
if exist "%GATEWAY_PATH%" (
    echo [START] Dang khoi dong API Gateway YARP [Port 5212]...
    start "V-Eval - API Gateway YARP [HTTP:5212]" cmd /k "dotnet run --project "%GATEWAY_PATH%""
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay API Gateway tai: %GATEWAY_PATH%
)

if "%CHOICE%"=="1" goto start_web
goto show_summary

:start_web
set "WEB_DIR=%ALL_SERVICES_DIR%\V-Eval-Web_Client"
if exist "%WEB_DIR%\package.json" (
    echo [START] Dang khoi dong V-Eval Web Client [Port 5173]...
    start "V-Eval - Web Client [React Vite:5173]" cmd /k "cd /d "%WEB_DIR%" && npm run dev"
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay Web Client tai: %WEB_DIR%
)
goto show_summary

:start_web_only
set "WEB_DIR=%ALL_SERVICES_DIR%\V-Eval-Web_Client"
if exist "%WEB_DIR%\package.json" (
    echo [START] Dang khoi dong V-Eval Web Client [Port 5173]...
    start "V-Eval - Web Client [React Vite:5173]" cmd /k "cd /d "%WEB_DIR%" && npm run dev"
    timeout /t 2 /nobreak >nul
) else (
    echo [WARNING] Khong tim thay Web Client tai: %WEB_DIR%
)
goto show_summary

:show_summary
echo.
echo =====================================================================
echo           DANH SACH CAC SERVICE VA PORT HOAT DONG
echo =====================================================================
echo  * API Gateway YARP      : http://localhost:5212  [Entry Point]
echo  * Identity Service      : http://localhost:5155  [gRPC: 5156]
echo  * Content Service       : http://localhost:5249  [gRPC: 5250]
echo  * Practice Service      : http://localhost:5261  [UI Runner: :5261/view-diagnostic.html]
echo  * AI Engine .NET API    : http://localhost:5104  [OCR, Ingestion]
echo  * Python FastAPI RAG    : http://localhost:8000  [Swagger: :8000/docs]
echo  * Web Client React Vite : http://localhost:5173  [Frontend UI]
echo =====================================================================
echo.
echo Tat ca cac service da duoc khoi chay trong cac cua so rieng biet!
echo Nhan phim bat ky de thoat cua so dieu khien nay...
pause >nul
