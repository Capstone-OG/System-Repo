@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                Capstone-OG - Docker Compose Run Script
echo =====================================================================
echo.

REM Kiểm tra xem Docker Daemon đã chạy chưa
docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Desktop chua duoc khoi chay! Vui long bat Docker Desktop truoc.
    pause
    exit /b 1
)

echo Dang khoi dong cac Docker Container (va build lai neu co thay doi)...
docker-compose up --build
