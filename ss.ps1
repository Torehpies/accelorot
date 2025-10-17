# ss.ps1
param([string]$name = "")

$screenshotsPath = Join-Path $PWD "screenshots"
if (!(Test-Path $screenshotsPath)) {
    New-Item -ItemType Directory -Path $screenshotsPath | Out-Null
}

if ([string]::IsNullOrEmpty($name)) {
    $name = (Get-Date -Format "yyyyMMdd_HHmmss")
}

$outputPath = Join-Path $screenshotsPath "$name.png"

Write-Host "📸 Taking screenshot..."
flutter screenshot --out="$outputPath"
Write-Host "✅ Screenshot saved to: $outputPath"
