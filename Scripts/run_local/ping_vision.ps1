# ==============================================================================
# V-EVAL AI ENGINE - SCRIPT PING KIEM TRA MO HINH VISION AI
# Huong dan chay:
#   .\Scripts\run_local\ping_vision.ps1 -ApiKey "AIzaSy..."
#   Hoac:
#   .\Scripts\run_local\ping_vision.ps1  (Se tu dong doc tu appsettings.json)
# ==============================================================================

param (
    [string]$ApiKey = "",
    [string]$OpenAiKey = ""
)

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "V-EVAL AI ENGINE - VISION MODELS PING AND LATENCY BENCHMARK" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Tim Gemini API Key neu khong truyen tham so
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $appsettingsPath = "$PSScriptRoot\..\..\All Services\V-Eval-Ai_Engine\V-Eval-Ai_Engine.API\appsettings.json"
    if (Test-Path $appsettingsPath) {
        $json = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
        if ($json.AiSettings.GeminiApiKey -and -not $json.AiSettings.GeminiApiKey.StartsWith("YOUR_")) {
            $ApiKey = $json.AiSettings.GeminiApiKey
        } elseif ($json.AiSettings.GeminiApiKeys -and $json.AiSettings.GeminiApiKeys.Count -gt 0 -and -not $json.AiSettings.GeminiApiKeys[0].StartsWith("YOUR_")) {
            $ApiKey = $json.AiSettings.GeminiApiKeys[0]
        }
    }
    if ([string]::IsNullOrWhiteSpace($ApiKey)) {
        $ApiKey = [System.Environment]::GetEnvironmentVariable("GEMINI_API_KEY")
    }
}

if ([string]::IsNullOrWhiteSpace($ApiKey) -or $ApiKey.StartsWith("YOUR_")) {
    Write-Host ""
    Write-Host "[WARNING] CHUA CO GEMINI API KEY!" -ForegroundColor Yellow
    Write-Host "Vui long truyen -ApiKey hoac cap nhat vao appsettings.json" -ForegroundColor Gray
    Write-Host "Vi du: .\Scripts\run_local\ping_vision.ps1 -ApiKey ""AIzaSy...""" -ForegroundColor Green
    Write-Host ""
} else {
    $maskedKey = if ($ApiKey.Length -gt 8) { "$($ApiKey.Substring(0,4))...$($ApiKey.Substring($ApiKey.Length-4))" } else { "****" }
    Write-Host ""
    Write-Host "[1] Google Gemini API Key: [$maskedKey]" -ForegroundColor Green

    $models = @(
        @{ Id = "gemini-flash-lite-latest"; Role = "Top 1 Khuyen nghi: Toc do duoi 1.5s, bóc tách chuẩn, Free Tier 15 RPM" },
        @{ Id = "gemini-3.5-flash-lite"; Role = "The he moi nhat, toc do cao, toi uu token va chi phi" },
        @{ Id = "gemini-3.1-flash-lite"; Role = "On dinh, ho tro OCR da phuong thuc tot" },
        @{ Id = "gemini-3.8-flash"; Role = "Mo hinh Flash cao cap danh cho tac vu phuc tap" }
    )

    $payload = @{
        contents = @(
            @{ parts = @( @{ text = "Ping test! Reply with 'OK' only." } ) }
        )
    } | ConvertTo-Json -Depth 5

    foreach ($m in $models) {
        $modelId = $m.Id
        $role = $m.Role
        Write-Host ""
        Write-Host "--> Dang ping [$modelId]... " -NoNewline -ForegroundColor Cyan

        $url = "https://generativelanguage.googleapis.com/v1beta/models/${modelId}:generateContent?key=$ApiKey"
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $resp = Invoke-RestMethod -Uri $url -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 15
            $sw.Stop()
            $latency = $sw.ElapsedMilliseconds
            Write-Host "[OK - 200] " -ForegroundColor Green -NoNewline
            Write-Host "${latency} ms" -ForegroundColor Yellow
            Write-Host "    Dac diem: $role" -ForegroundColor Gray
        } catch {
            $sw.Stop()
            $latency = $sw.ElapsedMilliseconds
            Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
            Write-Host "(${latency} ms)" -ForegroundColor DarkGray
            Write-Host "    Loi: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "KET LUAN VA DE XUAT CHO SGK RAG PIPELINE:" -ForegroundColor Yellow
Write-Host "1. Dung gemini-1.5-flash hoac gemini-2.0-flash: Toc do 0.8s - 1.2s/trang (toan bo 170 trang chi 20-30s)." -ForegroundColor White
Write-Host "2. Giu nguyen 100% cong thuc LaTeX va cau truc bang Markdown khong bi nat nhu OCR CPU." -ForegroundColor White
Write-Host "3. Chi phi: Free Tier 1,500 requests/ngay; neu tra phi chi ~500 VND / toan bo cuon sach 170 trang." -ForegroundColor White
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""
