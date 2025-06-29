# Stop script on first error
$ErrorActionPreference = "Stop"

Write-Host "🚀 n8n 앱을 최신 버전으로 업데이트합니다." -ForegroundColor Green
Write-Host "Dockerfile에 명시된 'n8nio/n8n:latest' 이미지를 사용하여 재배포를 시도합니다."
Write-Host ""

# Change to the script's directory to resolve path issues.
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Path)

# Check for fly.toml
if (-not (Test-Path -Path "fly.toml")) {
    Write-Host "오류: 'fly.toml' 파일을 현재 디렉토리에서 찾을 수 없습니다." -ForegroundColor Red
    exit 1
}

# Read app name from fly.toml
$appNameLine = Get-Content -Path "fly.toml" | Select-String -Pattern "^\s*app\s*="
$appName = ($appNameLine.Line -replace '^\s*app\s*=\s*''|''\s*$' -replace '"','').Trim()

if ([string]::IsNullOrWhiteSpace($appName)) {
    Write-Host "오류: 'fly.toml'에서 앱 이름(app)을 찾을 수 없습니다." -ForegroundColor Red
    exit 1
}

Write-Host "업데이트할 앱의 이름: $appName" -ForegroundColor Cyan
Write-Host ""

# Get user confirmation
$confirmation = Read-Host "정말로 '$appName' 앱을 최신 이미지로 업데이트하시겠습니까? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "업데이트 작업이 취소되었습니다."
    exit 0
}

Write-Host ""
Write-Host "📦 앱을 재배포하여 업데이트합니다. 이 과정은 몇 분 정도 소요될 수 있습니다..." -ForegroundColor Magenta

# Run fly.io deploy command to update the app
# This will build a new image based on the Dockerfile and deploy it to the existing machines.
flyctl deploy --app $appName --dockerfile Dockerfile

Write-Host ""
Write-Host "✅ 업데이트 배포가 완료되었습니다." -ForegroundColor Green
Write-Host "앱의 최종 상태를 확인합니다."
flyctl status --app $appName

# Return to the original directory
Pop-Location 