param(
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

$ModelDir = "D:\RacikAI\file ai\recovered-kaggle"
$GeminiModel = "gemini-3.5-flash-lite"

$env:CORS_ORIGINS = "http://localhost:5000,http://127.0.0.1:5000"
$env:GEMINI_MODEL = $GeminiModel

try {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "        RacikAI Backend Development"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "1. Buka Google AI Studio."
    Write-Host "2. Klik COPY pada Gemini API key."
    Write-Host "3. Kembali ke terminal ini."
    Write-Host "4. Tekan ENTER saja."
    Write-Host ""
    Write-Host "JANGAN paste API key ke terminal."
    Write-Host ""

    Read-Host "Jika API key sudah dicopy, tekan ENTER"

    $clipboardValue = Get-Clipboard

    if ([string]::IsNullOrWhiteSpace($clipboardValue)) {
        throw "Clipboard kosong. Copy API key terlebih dahulu."
    }

    $apiKey = $clipboardValue.Trim()

    $apiKey = [regex]::Replace(
        $apiKey,
        '[\x00-\x1F\x7F]',
        ''
    )

    Set-Clipboard -Value " "

    if (
        [string]::IsNullOrWhiteSpace($apiKey) -or
        $apiKey.Length -lt 20
    ) {
        throw "API key tampaknya tidak valid atau tidak tercopy dengan benar."
    }

    $env:GEMINI_API_KEY = $apiKey

    Write-Host ""
    Write-Host "Memeriksa koneksi Gemini API..."

    $testBody = @{
        model = $GeminiModel
        input = "Reply only OK."
        generation_config = @{
            thinking_level = "minimal"
        }
    } | ConvertTo-Json -Depth 10

    try {
        $testResponse = Invoke-RestMethod `
            -Uri "https://generativelanguage.googleapis.com/v1beta/interactions" `
            -Method Post `
            -Headers @{
                "x-goog-api-key" = $env:GEMINI_API_KEY
            } `
            -ContentType "application/json" `
            -Body $testBody

        $testText = (
            $testResponse.steps |
            Where-Object {
                $_.type -eq "model_output"
            } |
            ForEach-Object {
                $_.content.text
            }
        )

        if (-not $testText) {
            throw "Gemini tidak mengembalikan response."
        }

        Write-Host "Gemini API: OK"
    }
    catch {
        throw "Gemini API key/model gagal divalidasi. Backend tidak dijalankan."
    }

    Write-Host ""
    Write-Host "Starting RacikAI backend..."
    Write-Host "Model : $GeminiModel"
    Write-Host "Port  : $Port"
    Write-Host "CORS  : localhost:5000"
    Write-Host ""

    & "$PSScriptRoot\start.ps1" `
        -ModelDir $ModelDir `
        -Port $Port `
        -GeminiModel $GeminiModel
}
finally {
    Remove-Item Env:GEMINI_API_KEY `
        -ErrorAction SilentlyContinue

    $apiKey = $null
    $clipboardValue = $null
    $testBody = $null
    $testResponse = $null
    $testText = $null

    Set-Clipboard -Value " "

    Write-Host ""
    Write-Host "Gemini API key sudah dibersihkan dari environment dan clipboard."
}