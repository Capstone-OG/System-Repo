@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                V-Eval - Project Setup Script
echo =====================================================================
echo.

REM Lay duong dan tuyet doi den thu muc goc cua du an
pushd "%~dp0..\..\"
set "ROOT_DIR=%CD%"
popd

echo [INFO] Project Root Directory: %ROOT_DIR%
echo.

REM Kiem tra xem Git da duoc cai dat chua
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git chua duoc cai dat hoac chua them vao PATH! Vui long cai dat Git truoc.
    pause
    exit /b 1
)

REM --- Dong bo Git cho System-Repo gốc ---
echo === [1/2] Dong bo Repository he thong (System-Repo) ===
pushd "%ROOT_DIR%"
if not exist ".git" (
    echo [INFO] Dang khoi tao Git cho System-Repo...
    git init
    git remote add origin https://github.com/Capstone-OG/System-Repo.git
) else (
    echo [INFO] Git da duoc khoi tao o System-Repo. Cap nhat origin...
    git remote remove origin >nul 2>&1
    git remote add origin https://github.com/Capstone-OG/System-Repo.git
)

REM Tao commit dau tien neu chua co bat ky commit nao
git rev-parse --verify HEAD >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [INFO] Chua co commit nao. Dang tao commit lam moc...
    git add -A
    git commit -m "Initial commit from setup" >nul 2>&1
)

echo Dang dong bo code goc tu remote...
git fetch origin >nul 2>&1
set "DEFAULT_BRANCH=main"
git rev-parse --verify origin/develop >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set "DEFAULT_BRANCH=develop"
)
git branch -M !DEFAULT_BRANCH! >nul 2>&1
git branch --set-upstream-to=origin/!DEFAULT_BRANCH! !DEFAULT_BRANCH! >nul 2>&1
git pull origin !DEFAULT_BRANCH! --allow-unrelated-histories -X ours --no-edit >nul 2>&1
popd
echo [SUCCESS] Dong bo he thong goc hoan tat.
echo.

REM --- Doc file git_config.txt va tao/clone các service con ---
echo === [2/2] Khoi tao va Clone cac Service con ===
set "CONFIG_FILE=%ROOT_DIR%\git_config.txt"
if not exist "%CONFIG_FILE%" (
    echo [ERROR] Khong tim thay file %CONFIG_FILE%! Vui long tao file nay truoc.
    pause
    exit /b 1
)

set "ALL_SERVICES_DIR=%ROOT_DIR%\All Services"
if not exist "%ALL_SERVICES_DIR%" (
    echo [INFO] Creating directory "%ALL_SERVICES_DIR%"...
    mkdir "%ALL_SERVICES_DIR%"
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        for /f "tokens=1,2 delims=|" %%I in ("!CONFIG_VAL!") do (
            set "REPO_URL=%%I"
            set "BRANCH=%%J"
        )
        
        echo.
        echo -------------------------------------------------------------
        echo Service: !SERVICE_NAME!
        echo Nhanh:   !BRANCH!
        echo Remote:  !REPO_URL!
        echo -------------------------------------------------------------
        
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        if exist "!TARGET_PATH!\.git" (
            echo Folder "!TARGET_PATH!" exists. Fetching and pulling...
            pushd "!TARGET_PATH!"
            git fetch origin >nul 2>&1
            git checkout !BRANCH! >nul 2>&1
            git pull origin !BRANCH! >nul 2>&1
            
            REM Kiem tra xem da co solution (.sln) chua, neu chua thi tu dong khoi tao
            set "SLN_EXISTS=0"
            if exist "*.sln" set "SLN_EXISTS=1"
            for /r %%f in (*.sln) do set "SLN_EXISTS=1"
            
            if "!SLN_EXISTS!"=="0" (
                echo [INFO] Thu muc ton tai nhung chua co Solution. Tien hanh khoi tao C# Clean Architecture...
                echo [INFO] Dang khoi tao Solution va cac Project C# Clean Architecture cho !SERVICE_NAME!...
                
                REM Tao Solution .NET
                dotnet new sln -n !SERVICE_NAME! >nul 2>&1
                
                REM Tao cac Project con cung cap voi Solution
                dotnet new classlib -n !SERVICE_NAME!.Domain -o "!SERVICE_NAME!.Domain" >nul 2>&1
                dotnet new classlib -n !SERVICE_NAME!.Application -o "!SERVICE_NAME!.Application" >nul 2>&1
                dotnet new classlib -n !SERVICE_NAME!.Infrastructure -o "!SERVICE_NAME!.Infrastructure" >nul 2>&1
                dotnet new webapi -n !SERVICE_NAME!.API -o "!SERVICE_NAME!.API" >nul 2>&1
                
                REM Add Projects vao Solution
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.Domain\!SERVICE_NAME!.Domain.csproj" >nul 2>&1
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" >nul 2>&1
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.Infrastructure\!SERVICE_NAME!.Infrastructure.csproj" >nul 2>&1
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.API\!SERVICE_NAME!.API.csproj" >nul 2>&1
                
                REM Thiet la tham chieu (References) giua cac projects theo Clean Architecture
                dotnet add "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" reference "!SERVICE_NAME!.Domain\!SERVICE_NAME!.Domain.csproj" >nul 2>&1
                dotnet add "!SERVICE_NAME!.Infrastructure\!SERVICE_NAME!.Infrastructure.csproj" reference "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" >nul 2>&1
                dotnet add "!SERVICE_NAME!.API\!SERVICE_NAME!.API.csproj" reference "!SERVICE_NAME!.Infrastructure\!SERVICE_NAME!.Infrastructure.csproj" >nul 2>&1
                dotnet add "!SERVICE_NAME!.API\!SERVICE_NAME!.API.csproj" reference "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" >nul 2>&1
                
                REM Tao README.md neu chua co
                if not exist "README.md" (
                    echo # !SERVICE_NAME! > README.md
                    echo. >> README.md
                    echo Giai phap C# Clean Architecture Web API cho !SERVICE_NAME! >> README.md
                )
                
                REM Tao .gitignore neu chua co
                if not exist ".gitignore" (
                    echo # Build results > .gitignore
                    echo [Db]in/ >> .gitignore
                    echo [Ob]j/ >> .gitignore
                    echo .vs/ >> .gitignore
                    echo .idea/ >> .gitignore
                    echo *.user >> .gitignore
                    echo *.suo >> .gitignore
                )
                
                git add -A
                git commit -m "Auto Clean Architecture setup for !SERVICE_NAME!" >nul 2>&1
            )
            popd
            echo [SUCCESS] Updated !SERVICE_NAME!.
        ) else (
            echo Folder "!TARGET_PATH!" does not exist. Cloning repository...
            git clone -b !BRANCH! !REPO_URL! "!TARGET_PATH!" 2>nul
            
            if !ERRORLEVEL! neq 0 (
                echo [WARNING] GitHub Repository !REPO_URL! not found.
                echo [INFO] Khoi tao Git local do Repo remote chua co tren GitHub...
                
                if not exist "!TARGET_PATH!" mkdir "!TARGET_PATH!"
                pushd "!TARGET_PATH!"
                git init >nul 2>&1
                git checkout -b !BRANCH! >nul 2>&1
                git branch -M !BRANCH! >nul 2>&1
                git remote add origin !REPO_URL! >nul 2>&1
                
                echo [INFO] Dang khoi tao Solution va cac Project C# Clean Architecture cho !SERVICE_NAME!...
                REM Tao Solution .NET
                dotnet new sln -n !SERVICE_NAME! >nul 2>&1
                
                REM Tao cac Project con cung cap voi Solution
                dotnet new classlib -n !SERVICE_NAME!.Domain -o "!SERVICE_NAME!.Domain" >nul 2>&1
                dotnet new classlib -n !SERVICE_NAME!.Application -o "!SERVICE_NAME!.Application" >nul 2>&1
                dotnet new classlib -n !SERVICE_NAME!.Infrastructure -o "!SERVICE_NAME!.Infrastructure" >nul 2>&1
                dotnet new webapi -n !SERVICE_NAME!.API -o "!SERVICE_NAME!.API" >nul 2>&1
                
                REM Add Projects vao Solution
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.Domain\!SERVICE_NAME!.Domain.csproj" >nul 2>&1
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" >nul 2>&1
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.Infrastructure\!SERVICE_NAME!.Infrastructure.csproj" >nul 2>&1
                dotnet sln !SERVICE_NAME!.sln add "!SERVICE_NAME!.API\!SERVICE_NAME!.API.csproj" >nul 2>&1
                
                REM Thiet la tham chieu (References) giua cac projects theo Clean Architecture
                dotnet add "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" reference "!SERVICE_NAME!.Domain\!SERVICE_NAME!.Domain.csproj" >nul 2>&1
                dotnet add "!SERVICE_NAME!.Infrastructure\!SERVICE_NAME!.Infrastructure.csproj" reference "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" >nul 2>&1
                dotnet add "!SERVICE_NAME!.API\!SERVICE_NAME!.API.csproj" reference "!SERVICE_NAME!.Infrastructure\!SERVICE_NAME!.Infrastructure.csproj" >nul 2>&1
                dotnet add "!SERVICE_NAME!.API\!SERVICE_NAME!.API.csproj" reference "!SERVICE_NAME!.Application\!SERVICE_NAME!.Application.csproj" >nul 2>&1
                
                REM Tao README.md
                echo # !SERVICE_NAME! > README.md
                echo. >> README.md
                echo Giai phap C# Clean Architecture Web API cho !SERVICE_NAME! >> README.md
                echo. >> README.md
                echo Nhanh theo doi: !BRANCH! >> README.md
                echo URL remote mac dinh: !REPO_URL! >> README.md
                
                REM Tao .gitignore
                echo # Build results > .gitignore
                echo [Db]in/ >> .gitignore
                echo [Ob]j/ >> .gitignore
                echo .vs/ >> .gitignore
                echo .idea/ >> .gitignore
                echo *.user >> .gitignore
                echo *.suo >> .gitignore
                
                git add -A
                git commit -m "Initial Clean Architecture setup for !SERVICE_NAME!" >nul 2>&1
                popd
                echo [SUCCESS] Khoi tao local Git va Solution C# Clean Architecture cho !SERVICE_NAME!.
            ) else (
                echo [SUCCESS] Cloned !SERVICE_NAME! from GitHub.
            )
        )
        
        REM Phuc hoi va Build tu dong cho tat ca cac service sau khi Setup/Pull
        if exist "!TARGET_PATH!" (
            pushd "!TARGET_PATH!"
            if exist "package.json" (
                echo Cai dat dependencies va build cho !SERVICE_NAME!...
                call npm install
                call npm run build
            ) else (
                set "IS_DOTNET=0"
                if exist "*.sln" set "IS_DOTNET=1"
                for /r %%f in (*.csproj) do set "IS_DOTNET=1"
                if "!IS_DOTNET!"=="1" (
                    echo Dang phuc hoi NuGet va build !SERVICE_NAME!...
                    dotnet restore
                    dotnet build
                )
            )
            popd
        )
    )
)

echo.
echo =====================================================================
echo                V-Eval Setup Completed!
echo =====================================================================
echo.
pause
