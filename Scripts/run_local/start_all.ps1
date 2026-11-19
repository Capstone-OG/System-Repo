# V-Eval - Full Local Services Daemon Runner
$ErrorActionPreference = "Continue"

$rootDir = (Get-Item $PSScriptRoot\..\..).FullName
Set-Location $rootDir
Write-Host "[INFO] Project Root: $rootDir" -ForegroundColor Cyan

# 1. Clear conflicting ports
$ports = @(5212, 5155, 5156, 5249, 5250, 5261, 5104, 8000, 5173)
Write-Host "[BƯỚC 1] Giai phong cac cong port..." -ForegroundColor Yellow
foreach ($port in $ports) {
    try {
        $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
        foreach ($c in $connections) {
            Write-Host "  -> Dang dong port $port (PID: $($c.OwningProcess))..."
            Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

# 2. Check and sync config
if (Test-Path "$rootDir\Scripts\sync_config\sync_config.bat") {
    Write-Host "[INFO] Dong bo cau hinh..." -ForegroundColor Yellow
    cmd /c "$rootDir\Scripts\sync_config\sync_config.bat --install-missing"
}

# 3. Locate dotnet 9
$dotnetCmd = "dotnet"
if (Test-Path "$env:USERPROFILE\.dotnet\dotnet.exe") {
    $dotnetCmd = "$env:USERPROFILE\.dotnet\dotnet.exe"
    $env:PATH = "$env:USERPROFILE\.dotnet;" + $env:PATH
}
Write-Host "[INFO] Su dung .NET binary: $dotnetCmd" -ForegroundColor Cyan

# 4. Locate python
$pythonCmd = "python"
if (Test-Path "C:\Users\USER\AppData\Local\Programs\Python\Python311\python.exe") {
    $pythonCmd = "C:\Users\USER\AppData\Local\Programs\Python\Python311\python.exe"
}

# 5. Launch all services as background processes
$services = @(
    @{
        Name = "Identity Service"
        Path = "$rootDir\All Services\V-Eval-Identity_Service\V-Eval-Identity_Service.API"
        Command = $dotnetCmd
        Args = @("run")
        Port = 5155
    },
    @{
        Name = "Content Service"
        Path = "$rootDir\All Services\V-Eval-Content_Service\V-Eval-Content_Service.API"
        Command = $dotnetCmd
        Args = @("run")
        Port = 5249
    },
    @{
        Name = "Practice Service"
        Path = "$rootDir\All Services\V-Eval-Practice_Service\V-Eval-Practice_Service.API"
        Command = $dotnetCmd
        Args = @("run")
        Port = 5261
    },
    @{
        Name = "AI Engine .NET"
        Path = "$rootDir\All Services\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API"
        Command = $dotnetCmd
        Args = @("run")
        Port = 5104
    },
    @{
        Name = "AI Python RAG"
        Path = "$rootDir\All Services\V-Eval-Ai_Engine\rag-service"
        Command = $pythonCmd
        Args = @("-m", "uvicorn", "main:app", "--port", "8000")
        Port = 8000
    },
    @{
        Name = "Gateway YARP"
        Path = "$rootDir\All Services\V-Eval-Gateway\V-Eval-Gateway.API"
        Command = $dotnetCmd
        Args = @("run")
        Port = 5212
    },
    @{
        Name = "Web Client"
        Path = "$rootDir\All Services\V-Eval-Web_Client"
        Command = "npm.cmd"
        Args = @("run", "dev")
        Port = 5173
    }
)

Write-Host "`n[BƯỚC 2] Dang khoi dong cac Service..." -ForegroundColor Green
$runningJobs = @()

foreach ($svc in $services) {
    Write-Host "  -> Khoi dong $($svc.Name) (Port: $($svc.Port))..." -ForegroundColor Cyan
    $p = Start-Process -FilePath $svc.Command -ArgumentList $svc.Args -WorkingDirectory $svc.Path -PassThru -NoNewWindow
    $runningJobs += @{ Service = $svc; Process = $p }
    Start-Sleep -Seconds 2
}

Write-Host "`n=====================================================================" -ForegroundColor Green
Write-Host "          DANH SACH CAC SERVICE VA PORT HOAT DONG" -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Green
Write-Host "  * Web Client React Vite : http://localhost:5173  [Frontend UI]"
Write-Host "  * API Gateway YARP      : http://localhost:5212  [Entry Point]"
Write-Host "  * Practice Service      : http://localhost:5261  [UI Runner: :5261/view-diagnostic.html]"
Write-Host "  * Identity Service      : http://localhost:5155  [gRPC: 5156]"
Write-Host "  * Content Service       : http://localhost:5249  [gRPC: 5250]"
Write-Host "  * AI Engine .NET API    : http://localhost:5104  [OCR, Ingestion]"
Write-Host "  * Python FastAPI RAG    : http://localhost:8000  [Swagger: :8000/docs]"
Write-Host "=====================================================================" -ForegroundColor Green
Write-Host "Tat ca cac service dang chay nen (Daemon Mode). Giu tien trinh luon hoat dong..." -ForegroundColor Yellow

# Monitor loop
while ($true) {
    Start-Sleep -Seconds 10
}
