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
    $secret = Read-Host "Gemini API key (tidak ditampilkan)" -AsSecureString

    $apiKey = [System.Net.NetworkCredential]::new(
        "",
        $secret
    ).Password

    $apiKey = $apiKey.Trim()
    $apiKey = [regex]::Replace(
        $apiKey,
        '[\x00-\x1F\x7F]',
        ''
    )

    if ([string]::IsNullOrWhiteSpace($apiKey) -or $apiKey.Length -lt 10) {
        throw "API key tampaknya tidak masuk dengan benar. Jalankan script lagi."
    }

    $env:GEMINI_API_KEY = $apiKey

    Write-Host ""
    Write-Host "Starting RacikAI backend..."
    Write-Host "Model  : $GeminiModel"
    Write-Host "Port   : $Port"
    Write-Host "CORS   : localhost:5000"
    Write-Host ""

    & "$PSScriptRoot\start.ps1" `
        -ModelDir $ModelDir `
        -Port $Port `
        -GeminiModel $GeminiModel
}
finally {
    Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue

    $apiKey = $null
    $secret = $null

    Write-Host ""
    Write-Host "Gemini API key sudah dibersihkan dari environment."
}