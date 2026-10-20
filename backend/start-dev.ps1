param(
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot


# Membaca konfigurasi dari backend/.env
$envFile = Join-Path $PSScriptRoot ".env"

if (-not (Test-Path -LiteralPath $envFile)) {
    throw "File backend/.env tidak ditemukan."
}

$allowedKeys = @(
    "GEMINI_API_KEY",
    "GEMINI_MODEL",
    "RECIPE_DATA_SOURCE",
    "AI_MODEL_DIR",
    "RECIPE_IMAGE_DIR"
)

foreach ($line in Get-Content -LiteralPath $envFile) {
    $line = $line.Trim()

    if (-not $line -or $line.StartsWith("#")) {
        continue
    }

    $parts = $line.Split('=', 2)

    if ($parts.Count -ne 2) {
        continue
    }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    if ($allowedKeys -notcontains $key) {
        continue
    }

    # Menghapus tanda petik pembungkus jika ada
    if (
        $value.Length -ge 2 -and
        (
            ($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))
        )
    ) {
        $value = $value.Substring(1, $value.Length - 2)
    }

    Set-Item -Path "Env:$key" -Value $value
}

$ModelDir = $env:AI_MODEL_DIR
$GeminiModel = $env:GEMINI_MODEL

if ([string]::IsNullOrWhiteSpace($ModelDir)) {
    throw "AI_MODEL_DIR belum diisi dalam .env."
}

if ([string]::IsNullOrWhiteSpace($GeminiModel)) {
    throw "GEMINI_MODEL belum diisi dalam .env."
}

$env:CORS_ORIGINS = "http://localhost:5000,http://127.0.0.1:5000"

try {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "        RacikAI Backend Development"
    Write-Host "========================================"
    Write-Host ""
    if (
        [string]::IsNullOrWhiteSpace($env:GEMINI_API_KEY) -or
        $env:GEMINI_API_KEY.Length -lt 20
    ) {
        throw "GEMINI_API_KEY belum diisi atau tidak valid di backend/.env."
    }

    Write-Host "Konfigurasi Gemini berhasil dibaca dari .env."
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