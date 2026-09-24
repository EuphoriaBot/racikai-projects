param([string]$ModelDir = "", [int]$Port = 8000, [string]$GeminiModel = "")
$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot
if ($ModelDir) { $env:AI_MODEL_DIR = $ModelDir }
if ($GeminiModel) {
    $env:GEMINI_MODEL = $GeminiModel
    if (-not $env:GEMINI_API_KEY) {
        $geminiSecret = Read-Host "Gemini API key (tidak ditampilkan)" -AsSecureString
        $env:GEMINI_API_KEY = [System.Net.NetworkCredential]::new("", $geminiSecret).Password
    }
}
& "$PSScriptRoot\.venv\Scripts\python.exe" -m uvicorn app:app --host 0.0.0.0 --port $Port
