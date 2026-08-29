@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                V-Eval - Global Pull and History Sync Tool
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
    echo [ERROR] Git chưa được cài đặt hoặc chưa thêm vào PATH!
    pause
    exit /b 1
)

set "ALL_SERVICES_DIR=%ROOT_DIR%\All Services"
set "CONFIG_FILE=%ROOT_DIR%\git_config.txt"

REM --- BƯỚC 1: Pull cho System-Repo gốc ---
echo =============================================================
echo Dang kiem tra va dong bo System-Repo (Root)
echo =============================================================
pushd "%ROOT_DIR%"
set "REPO_NAME=System-Repo"
for /f "tokens=*" %%b in ('git rev-parse --abbrev-ref HEAD') do set "CUR_BRANCH=%%b"
call :PROCESS_PULL
popd
echo.

REM --- BƯỚC 2: Duyệt qua các Service con để Pull ---
if not exist "%CONFIG_FILE%" (
    echo [WARNING] Khong tim thay file git_config.txt. Bo qua cac service con.
    goto END
)

for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        for /f "tokens=1,2 delims=|" %%I in ("!CONFIG_VAL!") do (
            set "REPO_URL=%%I"
            set "BRANCH=%%J"
        )
        
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        echo =============================================================
        echo Dang kiem tra va dong bo Service: !SERVICE_NAME! [!BRANCH!]
        echo =============================================================
        
        if exist "!TARGET_PATH!\.git" (
            pushd "!TARGET_PATH!"
            set "REPO_NAME=!SERVICE_NAME!"
            set "CUR_BRANCH=!BRANCH!"
            
            REM Dam bao checkout dung nhanh
            git checkout !CUR_BRANCH! >nul 2>&1
            
            call :PROCESS_PULL
            popd
        ) else (
            echo [WARNING] Thu muc "!TARGET_PATH!" chua duoc khoi tao Git.
            echo [INFO] Vui long chay Scripts/setup/setup.bat de khoi tao.
        )
        echo.
    )
)

:END
echo =====================================================================
echo                Dong bo hoàn tat!
echo =====================================================================
echo.
pause
exit /b 0

REM =====================================================================
REM SUBROUTINE: PROCESS_PULL
REM Yêu cầu: pushd vào đúng thư mục repo trước khi gọi.
REM Biến cần có: REPO_NAME, CUR_BRANCH
REM =====================================================================
:PROCESS_PULL
REM Lay thong tin remote moi nhat
git fetch origin >nul 2>&1

REM Kiem tra xem co thay doi chua commit o local khong
set HAS_LOCAL_CHANGES=0
for /f "tokens=*" %%i in ('git status --porcelain') do set HAS_LOCAL_CHANGES=1

if "!HAS_LOCAL_CHANGES!"=="1" (
    echo [CẢNH BÁO] Repo !REPO_NAME! co thay doi chua commit o local:
    git status -s
    echo.
    echo Vui long chon phuong an xu ly truoc khi pull:
    echo   [1] Stash thay doi - Cat tam thoi, pull roi phuc hoi [Khuyen nghi]
    echo   [2] Commit thay doi - Ghi nhan code local truoc roi pull
    echo   [3] Bo qua repo nay - Khong pull gi ca
    echo.
    
    set "USER_CHOICE=3"
    set /p USER_CHOICE="Nhap lua chon cua ban [1, 2, 3]: " <con
    
    if "!USER_CHOICE!"=="1" (
        echo Dang stash thay doi...
        git stash >nul 2>&1
        echo Dang pull tu remote...
        git pull origin !CUR_BRANCH!
        echo Dang restore thay doi tu stash...
        git stash pop >nul 2>&1
    ) else if "!USER_CHOICE!"=="2" (
        set "L_COMMIT_MSG=Auto commit before pull"
        set /p L_COMMIT_MSG="Nhap message commit (Enter de dung mac dinh): " <con
        git add -A
        git commit -m "!L_COMMIT_MSG!"
        echo Dang pull tu remote...
        git pull origin !CUR_BRANCH!
    ) else (
        echo [INFO] Da bo qua repo !REPO_NAME!.
    )
) else (
    REM Code local sach se, kiem tra dong bo lich su
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_SHA=%%a"
    set "REMOTE_SHA="
    for /f "tokens=*" %%a in ('git rev-parse --verify --quiet origin/!CUR_BRANCH! 2^>nul') do set "REMOTE_SHA=%%a"
    
    if "!REMOTE_SHA!"=="" (
        echo [INFO] Nhanh origin/!CUR_BRANCH! chua ton tai tren remote. Khong co gi de pull.
    ) else (
        for /f "tokens=*" %%a in ('git merge-base HEAD origin/!CUR_BRANCH! 2^>nul') do set "BASE_SHA=%%a"
        
        if "!LOCAL_SHA!"=="!REMOTE_SHA!" (
            echo [INFO] Repo !REPO_NAME! da moi nhat (up-to-date).
        ) else if "!LOCAL_SHA!"=="!BASE_SHA!" (
            echo [INFO] Code local dang bi cham (behind). Tien hanh pull...
            git pull origin !CUR_BRANCH!
        ) else if "!REMOTE_SHA!"=="!BASE_SHA!" (
            echo [INFO] Code local dang nhanh hon remote (ahead). Khong can pull.
        ) else (
            echo [WARNING] Lich su bi lech (diverged). Tien hanh pull va tu dong merge...
            git pull origin !CUR_BRANCH!
        )
    )
)
exit /b 0
