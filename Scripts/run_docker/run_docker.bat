@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                V-Eval - Docker Compose Run Script
echo =====================================================================
echo.

pushd "%~dp0..\.."
set "ROOT_DIR=%CD%"
popd

echo [INFO] Project Root Directory: %ROOT_DIR%
echo.

REM Kiểm tra xem Docker Daemon đã chạy chưa
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Desktop chua duoc khoi chay! Vui long bat Docker Desktop truoc.
    pause
    exit /b 1
)

REM Tu dong kiem tra va bo sung cau hinh neu con thieu
if exist "%ROOT_DIR%\Scripts\sync_config\sync_config.bat" (
    call "%ROOT_DIR%\Scripts\sync_config\sync_config.bat" --install-missing
)

echo Dang khoi dong cac Docker Container (va build lai neu co thay doi)...
pushd "%ROOT_DIR%"
docker-compose up --build
popd

pause
