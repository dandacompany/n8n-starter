# Stop script on first error
$ErrorActionPreference = "Stop"

Write-Host "⚠️ 경고: 이 스크립트는 fly.io 앱과 관련된 모든 리소스(머신, 볼륨, IP 등)를 영구적으로 삭제합니다." -ForegroundColor Yellow
Write-Host "이 작업은 되돌릴 수 없습니다. 계속 진행하기 전에 신중하게 결정해주세요." -ForegroundColor Yellow
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

Write-Host "삭제할 앱의 이름: $appName" -ForegroundColor Cyan
Write-Host ""

# Get user confirmation
$confirmation = Read-Host "정말로 '$appName' 앱을 삭제하시겠습니까? 확인을 위해 'yes'를 입력하세요"

if ($confirmation -ne "yes") {
    Write-Host "삭제 작업이 취소되었습니다."
    exit 0
}

Write-Host ""
Write-Host "🗑️ '$appName' 앱과 모든 관련 리소스를 삭제합니다..." -ForegroundColor Magenta

# Run fly.io destroy command
flyctl apps destroy $appName --yes

Write-Host "✅ '$appName' 앱이 성공적으로 삭제되었습니다." -ForegroundColor Green

# Return to the original directory
Pop-Location 