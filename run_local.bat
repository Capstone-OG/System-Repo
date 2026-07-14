@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                Capstone-OG - Local Run Tool
echo =====================================================================
echo.

REM --- Step 1: Giải phóng các cổng Port phát triển phổ biến nếu đang bị chiếm dụng ---
REM (Bạn có thể sửa đổi danh sách Port này cho phù hợp với dự án của mình)
for %%P in (5173 5174 8080 5000 5001) do (
    echo Dang kiem tra Port %%P...
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%%P" ^| findstr "LISTENING"') do (
        echo Phat hien Tien trinh ID %%a dang chiem dung Port %%P. Tien hanh giai phong...
        taskkill /f /pid %%a
    )
)
echo.

REM --- Step 2: Quét git_config.txt để tự động chạy các Service con ---
if not exist "git_config.txt" (
    echo [ERROR] Khong tim thay file git_config.txt!
    pause
    exit /b 1
)

set "ALL_SERVICES_DIR=All Services"

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("git_config.txt") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        if exist "!TARGET_PATH!" (
            echo Dang khoi dong !SERVICE_NAME! o local...
            pushd "!TARGET_PATH!"
            
            REM Dự án Node.js (React, Vue, Next.js...)
            if exist "package.json" (
                start "!SERVICE_NAME!" cmd /k "cd /d "%CD%" && npm run dev"
            ) else (
                REM Dự án .NET Core / ASP.NET
                set "CSPROJ_PATH="
                for /r %%f in (*.csproj) do (
                    set "CSPROJ_PATH=%%f"
                )
                if not "!CSPROJ_PATH!"=="" (
                    start "!SERVICE_NAME!" dotnet run --project "!CSPROJ_PATH!"
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
