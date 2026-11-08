@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title V-Eval Testing Suite Runner

:: ============================================================================
:: V-Eval Capstone System - Test Runner CLI
:: Độc lập, thủ công, tương thích chuẩn .NET 9 Host SDK
:: ============================================================================

set "REPO_ROOT=%~dp0..\.."
cd /d "%REPO_ROOT%"

:: Kiểm tra bộ thực thi dotnet 9 trên máy Host
if exist "%USERPROFILE%\.dotnet\dotnet.exe" (
    set "DOTNET_CMD=%USERPROFILE%\.dotnet\dotnet.exe"
) else (
    set "DOTNET_CMD=dotnet"
)

:MENU
cls
echo ============================================================================
echo                     V-EVAL CAPSTONE SYSTEM - TEST RUNNER
echo ============================================================================
echo  Dotnet SDK: %DOTNET_CMD%
echo  Thu muc goc: %CD%
echo ============================================================================
echo.
echo  Chon dich vu can kiem thu:
echo.
echo    [1] Chay Test toan bo ca 5 Microservices (All Services)
echo    [2] V-Eval-Identity_Service
echo    [3] V-Eval-Content_Service
echo    [4] V-Eval-Practice_Service
echo    [5] V-Eval-Ai_Engine
echo    [6] V-Eval-Gateway
echo    [7] Thoat
echo.
set /p "CHOICE=Nhap lua chon cua ban [1-7]: "

if "%CHOICE%"=="1" goto TEST_ALL
if "%CHOICE%"=="2" goto TEST_IDENTITY
if "%CHOICE%"=="3" goto TEST_CONTENT
if "%CHOICE%"=="4" goto TEST_PRACTICE
if "%CHOICE%"=="5" goto TEST_AI_ENGINE
if "%CHOICE%"=="6" goto TEST_GATEWAY
if "%CHOICE%"=="7" goto EXIT_SCRIPT

echo.
echo [!] Lua chon khong hop le, vui long chon lai...
timeout /t 2 >nul
goto MENU

:TEST_ALL
cls
echo ============================================================================
echo           DANG CHAY TEST CHO TOAN BO 5 MICROSERVICES (V-EVAL)
echo ============================================================================
echo.

set "FAIL_COUNT=0"
set "PASS_COUNT=0"

call :RUN_SERVICE_TEST "Identity_Service" "All Services\V-Eval-Identity_Service\V-Eval-Identity_Service.Tests\V-Eval-Identity_Service.Tests.csproj"
call :RUN_SERVICE_TEST "Content_Service"  "All Services\V-Eval-Content_Service\V-Eval-Content_Service.Tests\V-Eval-Content_Service.Tests.csproj"
call :RUN_SERVICE_TEST "Practice_Service" "All Services\V-Eval-Practice_Service\V-Eval-Practice_Service.Tests\V-Eval-Practice_Service.Tests.csproj"
call :RUN_SERVICE_TEST "Ai_Engine"        "All Services\V-Eval-Ai_Engine\V-Eval-Ai_Engine.Tests\V-Eval-Ai_Engine.Tests.csproj"
call :RUN_SERVICE_TEST "Gateway"          "All Services\V-Eval-Gateway\V-Eval-Gateway.Tests\V-Eval-Gateway.Tests.csproj"

goto REPORT_SUMMARY

:TEST_IDENTITY
cls
set "FAIL_COUNT=0"
set "PASS_COUNT=0"
call :RUN_SERVICE_TEST "Identity_Service" "All Services\V-Eval-Identity_Service\V-Eval-Identity_Service.Tests\V-Eval-Identity_Service.Tests.csproj"
goto REPORT_SUMMARY

:TEST_CONTENT
cls
set "FAIL_COUNT=0"
set "PASS_COUNT=0"
call :RUN_SERVICE_TEST "Content_Service" "All Services\V-Eval-Content_Service\V-Eval-Content_Service.Tests\V-Eval-Content_Service.Tests.csproj"
goto REPORT_SUMMARY

:TEST_PRACTICE
cls
set "FAIL_COUNT=0"
set "PASS_COUNT=0"
call :RUN_SERVICE_TEST "Practice_Service" "All Services\V-Eval-Practice_Service\V-Eval-Practice_Service.Tests\V-Eval-Practice_Service.Tests.csproj"
goto REPORT_SUMMARY

:TEST_AI_ENGINE
cls
set "FAIL_COUNT=0"
set "PASS_COUNT=0"
call :RUN_SERVICE_TEST "Ai_Engine" "All Services\V-Eval-Ai_Engine\V-Eval-Ai_Engine.Tests\V-Eval-Ai_Engine.Tests.csproj"
goto REPORT_SUMMARY

:TEST_GATEWAY
cls
set "FAIL_COUNT=0"
set "PASS_COUNT=0"
call :RUN_SERVICE_TEST "Gateway" "All Services\V-Eval-Gateway\V-Eval-Gateway.Tests\V-Eval-Gateway.Tests.csproj"
goto REPORT_SUMMARY

:RUN_SERVICE_TEST
set "SERVICE_NAME=%~1"
set "PROJECT_PATH=%~2"
echo ----------------------------------------------------------------------------
echo  Dang thuc thi Test: %SERVICE_NAME%
echo  Du an: %PROJECT_PATH%
echo ----------------------------------------------------------------------------
"%DOTNET_CMD%" test "%PROJECT_PATH%" --configuration Release --logger "console;verbosity=normal" --collect:"XPlat Code Coverage" --results-directory "TestResults\%SERVICE_NAME%"
if errorlevel 1 (
    echo.
    echo  [-] KET QUA: THAT BAI [FAIL] tai %SERVICE_NAME%
    set /a "FAIL_COUNT+=1"
) else (
    echo.
    echo  [+] KET QUA: THANH CONG [PASS] tai %SERVICE_NAME%
    set /a "PASS_COUNT+=1"
)
echo.
goto :eof

:REPORT_SUMMARY
echo ============================================================================
echo                             TONG KET KIEM THU
echo ============================================================================
echo  Tong dich vu PASS: %PASS_COUNT%
echo  Tong dich vu FAIL: %FAIL_COUNT%
echo ============================================================================

:: Thu thap bao cao do bao phu (ReportGenerator)
echo.
echo [i] Dang kiem tra va tong hop bao cao Code Coverage HTML...
"%DOTNET_CMD%" tool run reportgenerator -reports:TestResults/**/coverage.cobertura.xml -targetdir:TestResults/CoverageReport -reporttypes:HtmlInline_AzurePipelines;Badges >nul 2>&1
if exist "TestResults\CoverageReport\index.html" (
    echo [+] Da xuat bao cao Coverage tai: %CD%\TestResults\CoverageReport\index.html
) else (
    echo [i] Khong tim thay file coverage XML hoac ReportGenerator chua khoi tao.
)

echo.
echo [i] Qua trinh kiem thu da hoan tat.
pause
goto MENU

:EXIT_SCRIPT
echo Tam biet!
exit /b 0