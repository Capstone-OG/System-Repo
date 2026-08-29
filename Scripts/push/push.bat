@echo off
setlocal enabledelayedexpansion

echo =====================================================================
echo                V-Eval - Push and Discord Notification Tool
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

REM --- BƯỚC 1: Thu thập lời nhắn Commit ---
set "COMMIT_MSG=%~1"
if "%~2" neq "" (
    set "COMMIT_MSG=%*"
)

if "!COMMIT_MSG!"=="" (
    set /p COMMIT_MSG="Nhap loi nhan commit / thong bao Discord: " <con
)

if "!COMMIT_MSG!"=="" (
    set "COMMIT_MSG=Auto update code: %date% %time%"
)

REM Escaping double quotes trong message de tranh loi JSON
set "ESCAPED_MSG=!COMMIT_MSG:"='!"

REM --- BƯỚC 2: Kiểm tra lịch sử đồng bộ Git (Fetch & State Check) ---
echo === [1/3] Kiem tra dong bo lich su tren tat ca cac Repository ===
set "CAN_PUSH=1"
set "ALL_SERVICES_DIR=%ROOT_DIR%\All Services"
set "CONFIG_FILE=%ROOT_DIR%\git_config.txt"

REM Kiem tra System-Repo
pushd "%ROOT_DIR%"
for /f "tokens=*" %%b in ('git rev-parse --abbrev-ref HEAD') do set "R_BRANCH=%%b"
call :CHECK_REPO_SYNC "System-Repo" "!R_BRANCH!"
popd

REM Kiem tra cac service con
if not exist "%CONFIG_FILE%" goto :SKIP_CHECK_SERVICES
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        for /f "tokens=1,2 delims=|" %%I in ("!CONFIG_VAL!") do (
            set "REPO_URL=%%I"
            set "BRANCH=%%J"
        )
        
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        if exist "!TARGET_PATH!\.git" (
            pushd "!TARGET_PATH!"
            call :CHECK_REPO_SYNC "!SERVICE_NAME!" "!BRANCH!"
            popd
        )
    )
)
:SKIP_CHECK_SERVICES

if "!CAN_PUSH!"=="0" (
    echo.
    echo [ERROR] Phat hien xung dot hoac lich su bi tre - behind/diverged - tren mot so repo!
    echo Vui long chay Scripts/pull/pull.bat de dong bo code truoc khi tiep tuc.
    echo.
    pause
    exit /b 1
)

echo [SUCCESS] Kiem tra dong bo an toan. Tat ca cac repo san sang day code.
echo.

REM --- BƯỚC 3: Chọn chiến lược đẩy code ---
echo === [2/3] Lua chon Chien luoc Day Code (Push Strategy) ===
echo   [1] Commit va Push len mot NHÁNH MỚI [Dang: Ten_Dev/Nhiem_Vu]
echo   [2] Commit va Push truc tiep len NHÁNH HIỆN TẠI
echo   [3] Huy bo tien trinh (Cancel)
echo.

set "PUSH_OPTION=3"
set /p PUSH_OPTION="Nhap lua chon cua ban [1, 2, 3]: " <con

if "!PUSH_OPTION!"=="3" (
    echo [INFO] Huy bo tien trinh.
    pause
    exit /b 0
)

set "TARGET_BRANCH="
if "!PUSH_OPTION!"=="1" (
    set /p DEV_NAME="Nhap ten cua ban [vd: hoang, dung]: " <con
    set /p TASK_NAME="Nhap ten nhiem vu [vd: auth-api, gateway-fix]: " <con
    
    REM Loai bo cac ky tu dac biet
    set "DEV_NAME=!DEV_NAME: =!"
    set "TASK_NAME=!TASK_NAME: =!"
    
    set "TARGET_BRANCH=!DEV_NAME!/!TASK_NAME!"
    if "!TARGET_BRANCH!"=="/" (
        echo [ERROR] Ten nhanh khong duoc de trong!
        pause
        exit /b 1
    )
    echo [INFO] Chon chien luoc push len nhanh moi: !TARGET_BRANCH!
) else (
    echo [INFO] Chon chien luoc push truc tiep len nhanh hien tai cua tung repo.
)

REM --- BƯỚC 4: Thực hiện Commit & Push ---
echo.
echo === [3/3] Dang thuc hien Commit va Push... ===

REM Viet update message vao UPDATE.md
echo - !COMMIT_MSG! > "%ROOT_DIR%\UPDATE.md"

REM Push System-Repo
pushd "%ROOT_DIR%"
set "REPO_NAME=System-Repo"
for /f "tokens=*" %%b in ('git rev-parse --abbrev-ref HEAD') do set "CUR_BRANCH=%%b"
call :EXECUTE_PUSH
popd

REM Push cac service con
if not exist "%CONFIG_FILE%" goto :SKIP_PUSH_SERVICES
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    set "SERVICE_NAME=%%A"
    set "CONFIG_VAL=%%B"
    
    if not "!CONFIG_VAL!"=="" (
        for /f "tokens=1,2 delims=|" %%I in ("!CONFIG_VAL!") do (
            set "BRANCH=%%J"
        )
        
        set "TARGET_PATH=%ALL_SERVICES_DIR%\!SERVICE_NAME!"
        
        if exist "!TARGET_PATH!\.git" (
            pushd "!TARGET_PATH!"
            set "REPO_NAME=!SERVICE_NAME!"
            set "CUR_BRANCH=!BRANCH!"
            call :EXECUTE_PUSH
            popd
        )
    )
)
:SKIP_PUSH_SERVICES

REM --- BƯỚC 5: Bắn thông báo Discord Webhook ---
echo.
echo Gửi thong bao cap nhat ve Discord...
set "DISCORD_WEBHOOK=https://discord.com/api/webhooks/1526538394904035359/MmLUwCC2sOMjXHw-kh_f_-SjVABCyTtalAXfg6pgFsdQrsg_ISk25Nx7bfFKAWLHPCq6"
for /f "tokens=*" %%u in ('git config user.name') do set "GIT_USER=%%u"
if "!GIT_USER!"=="" set "GIT_USER=Developer"

set "PUSHED_BRANCH_INFO=!TARGET_BRANCH!"
if "!PUSHED_BRANCH_INFO!"=="" (
    set "PUSHED_BRANCH_INFO=Nhanh mac dinh cua tung Service"
)

REM Tao json payload file
(
echo {
echo   "embeds": [
echo     {
echo       "title": "🚀 V-Eval Code Update Push",
echo       "description": "He thong vua duoc cap nhat va push code.",
echo       "color": 3447003,
echo       "fields": [
echo         {
echo           "name": "💬 Loi nhan",
echo           "value": "!ESCAPED_MSG!"
echo         },
echo         {
echo           "name": "🌿 Nhanh day code",
echo           "value": "!PUSHED_BRANCH_INFO!"
echo         },
echo         {
echo           "name": "💻 Tac gia",
echo           "value": "!GIT_USER!"
echo         }
echo       ],
echo       "footer": {
echo         "text": "Scripts/push/push.bat"
echo       }
echo     }
echo   ]
echo }
) > "%TEMP%\discord_payload.json"

curl -H "Content-Type: application/json" -d @"%TEMP%\discord_payload.json" "%DISCORD_WEBHOOK%" >nul 2>&1
del "%TEMP%\discord_payload.json" >nul 2>&1

echo [SUCCESS] Discord Webhook notified.
echo.
echo =====================================================================
echo                Hoan thanh day code toan bo he thong!
echo =====================================================================
echo.
pause
exit /b 0

REM =====================================================================
REM SUBROUTINE: CHECK_REPO_SYNC
REM Yêu cầu: pushd vào đúng thư mục repo trước khi gọi.
REM Tham số: %1: Tên Repo, %2: Nhánh tracking
REM =====================================================================
:CHECK_REPO_SYNC
set "NM=%~1"
set "BR=%~2"

REM Lay thong tin remote moi nhat
git fetch origin >nul 2>&1

REM Kiem tra conflict truoc
set "CONFLICT_FILES="
for /f "tokens=*" %%c in ('git diff --name-only --diff-filter=U') do set "CONFLICT_FILES=%%c"
if not "!CONFLICT_FILES!"=="" (
    echo [ERROR] Repo !NM! dang co conflict chua duoc giai quyet!
    set "CAN_PUSH=0"
    exit /b 0
)

REM Lay hash commits
for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "L_SHA=%%a"
set "R_SHA="
for /f "tokens=*" %%a in ('git rev-parse --verify --quiet origin/!BR! 2^>nul') do set "R_SHA=%%a"

if not "!R_SHA!"=="" (
    for /f "tokens=*" %%a in ('git merge-base HEAD origin/!BR! 2^>nul') do set "B_SHA=%%a"
    
    if "!L_SHA!"=="!R_SHA!" (
        set "SYNC_STATUS=up-to-date"
    ) else if "!L_SHA!"=="!B_SHA!" (
        echo [ERROR] Repo !NM! dang bi cham hon remote - behind. Vui long pull!
        set "CAN_PUSH=0"
    ) else if "!R_SHA!"=="!B_SHA!" (
        set "SYNC_STATUS=ahead"
    ) else (
        echo [ERROR] Repo !NM! bi lech lich su voi remote - diverged. Vui long pull de merge!
        set "CAN_PUSH=0"
    )
)
exit /b 0

REM =====================================================================
REM SUBROUTINE: EXECUTE_PUSH
REM Yêu cầu: pushd vào đúng thư mục repo trước khi gọi.
REM Biến cần có: REPO_NAME, CUR_BRANCH, TARGET_BRANCH, COMMIT_MSG
REM =====================================================================
:EXECUTE_PUSH
REM Kiem tra xem co code chua commit khong
set HAS_CHANGES=0
for /f "tokens=*" %%i in ('git status --porcelain') do set HAS_CHANGES=1

if "!HAS_CHANGES!"=="1" (
    echo --- Thuc hien push cho: !REPO_NAME! ---
    if not "!TARGET_BRANCH!"=="" (
        echo Dang tao va checkout sang nhanh moi: !TARGET_BRANCH!...
        git checkout -b !TARGET_BRANCH! >nul 2>&1
        REM Neu da ton tai nhanh moi, checkout luon
        if !ERRORLEVEL! neq 0 git checkout !TARGET_BRANCH! >nul 2>&1
        
        git add -A
        git commit -m "!COMMIT_MSG!"
        echo Dang push len nhanh moi !TARGET_BRANCH!...
        git push origin !TARGET_BRANCH!
    ) else (
        git add -A
        git commit -m "!COMMIT_MSG!"
        echo Dang push len nhanh hien tai !CUR_BRANCH!...
        git push origin !CUR_BRANCH!
    )
) else (
    REM Neu khong co thay doi cục bộ nhưng dang co commit ahead chua push thi van can push
    if "!TARGET_BRANCH!"=="" (
        REM Kiem tra ahead
        set IS_AHEAD=0
        for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "L_SHA=%%a"
        for /f "tokens=*" %%a in ('git rev-parse --verify --quiet origin/!CUR_BRANCH! 2^>nul') do set "R_SHA=%%a"
        if not "!R_SHA!"=="" (
            for /f "tokens=*" %%a in ('git merge-base HEAD origin/!CUR_BRANCH! 2^>nul') do set "B_SHA=%%a"
            if "!R_SHA!"=="!B_SHA!" if not "!L_SHA!"=="!R_SHA!" set IS_AHEAD=1
        )
        if "!IS_AHEAD!"=="1" (
            echo --- Thuc hien push code ahead cho: !REPO_NAME! ---
            git push origin !CUR_BRANCH!
        ) else (
            echo [INFO] Repo !REPO_NAME! sach se va da push het.
        )
    ) else (
        echo [INFO] Repo !REPO_NAME! sach se.
    )
)
exit /b 0
