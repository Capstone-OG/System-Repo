@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                Capstone-OG - Project Setup Script
echo =====================================================================
echo.

REM Kiểm tra xem Git đã được cài đặt chưa
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git chưa được cài đặt hoặc chưa thêm vào PATH! Vui lòng cài đặt Git trước.
    pause
    exit /b 1
)

REM --- Tự động khởi tạo Git cho thư mục gốc nếu chưa có ---
echo === [1/4] Khoi tao va dong bo Git cho thu muc goc ===
if not exist ".git" (
    echo [INFO] Dang khoi tao Git repository...
    git init
    git remote add origin https://github.com/Capstone-OG/System-Repo.git
) else (
    echo [INFO] Git da duoc khoi tao tu truoc. Cap nhat remote origin...
    git remote remove origin >nul 2>&1
    git remote add origin https://github.com/Capstone-OG/System-Repo.git
)

REM Kiểm tra xem đã có commit nào chưa, nếu chưa thì commit để làm baseline
git rev-parse --verify HEAD >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [INFO] Chua co commit nao. Dang tao commit lam moc khoi dau...
    git add -A
    git commit -m "Initial commit from setup" >nul 2>&1
)

echo Dang lay thong tin tu repository goc - git fetch origin...
git fetch origin

REM Kiểm tra nhánh mặc định trên remote (develop hoặc main)
set "DEFAULT_BRANCH=develop"
git rev-parse --verify origin/develop >nul 2>&1
if %ERRORLEVEL% neq 0 (
    set "DEFAULT_BRANCH=main"
)

echo Dang thiet lap nhanh !DEFAULT_BRANCH!...
git branch -M !DEFAULT_BRANCH!
git branch --set-upstream-to=origin/!DEFAULT_BRANCH! !DEFAULT_BRANCH!

echo Dang dong bo va gop code tu repository goc...
git pull origin !DEFAULT_BRANCH! --allow-unrelated-histories -X ours --no-edit
echo - Viết nội dung cập nhật tại đây... > UPDATE.md
echo Dong bo code goc hoan tat.
echo.

if not exist "git_config.txt" (
    echo [ERROR] Không tìm thấy file git_config.txt! Vui lòng tạo file này trước.
    pause
    exit /b 1
)

set "ALL_SERVICES_DIR=All Services"
if not exist "%ALL_SERVICES_DIR%" (
    echo Creating directory "%ALL_SERVICES_DIR%"...
    mkdir "%ALL_SERVICES_DIR%"
)

echo === [2/4] Configuring Service Repositories ===
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("git_config.txt") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        REM Tách REPO_URL và BRANCH bằng ký tự |
        for /f "tokens=1,2 delims=|" %%I in ("!CONFIG_VAL!") do (
            set "REPO_URL=%%I"
            set "BRANCH=%%J"
        )
        
        echo.
        echo =============================================================
        echo Configuring Service: !SERVICE_NAME!
        echo Branch:             !BRANCH!
        echo URL:                !REPO_URL!
        echo =============================================================
        
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        if exist "!TARGET_PATH!\.git" (
            echo Folder "!TARGET_PATH!" exists. Fetching and pulling...
            pushd "!TARGET_PATH!"
            git fetch origin
            git checkout !BRANCH!
            git pull origin !BRANCH!
            popd
        ) else (
            echo Folder "!TARGET_PATH!" does not exist. Cloning repository...
            git clone -b !BRANCH! !REPO_URL! "!TARGET_PATH!"
        )
        
        REM Tự động phục hồi và Build dự án tùy theo loại project (.NET hoặc Node.js)
        if exist "!TARGET_PATH!" (
            echo.
            pushd "!TARGET_PATH!"
            if exist "package.json" (
                echo Cài đặt Node dependencies cho !SERVICE_NAME!...
                call npm install
                if !ERRORLEVEL! neq 0 (
                    echo [WARNING] npm install failed for !SERVICE_NAME!
                ) else (
                    echo Building !SERVICE_NAME!...
                    call npm run build
                    if !ERRORLEVEL! neq 0 (
                        echo [WARNING] npm run build failed for !SERVICE_NAME!
                    ) else (
                        echo Build succeeded for !SERVICE_NAME!!
                    )
                )
            ) else (
                set "IS_DOTNET=0"
                if exist "*.sln" set "IS_DOTNET=1"
                for /r %%f in (*.csproj) do (
                    set "IS_DOTNET=1"
                )
                
                if "!IS_DOTNET!"=="1" (
                    echo Restoring NuGet packages for !SERVICE_NAME!...
                    dotnet restore
                    if !ERRORLEVEL! neq 0 (
                        echo [WARNING] dotnet restore failed for !SERVICE_NAME!
                    ) else (
                        echo Building !SERVICE_NAME!...
                        dotnet build
                        if !ERRORLEVEL! neq 0 (
                            echo [WARNING] dotnet build failed for !SERVICE_NAME!
                        ) else (
                            echo Build succeeded for !SERVICE_NAME!!
                        )
                    )
                ) else (
                    echo [INFO] Khong phai du an Node.js hoac .NET, bo qua tu dong build.
                )
            )
            popd
        )
    )
)

echo.
echo =====================================================================
echo                Setup and Build completed!
echo =====================================================================
echo.
pause
