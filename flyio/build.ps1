# To run this script, you may need to set your PowerShell execution policy.
# Open PowerShell as an administrator and run:
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#
# Then, from this directory, you can run the script:
# ./flyio/build.ps1

# Stop script on first error
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting n8n deployment script for fly.io on Windows."

# Change to the script's directory to resolve path issues.
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Path)

# --- 1. Check and install flyctl ---
if (-not (Get-Command flyctl -ErrorAction SilentlyContinue)) {
    Write-Host "flyctl is not installed. Installing now using the official PowerShell installer."
    iwr https://fly.io/install.ps1 -useb | iex
} else {
    Write-Host "✅ flyctl is already installed."
}

# --- 2. Check fly.io login status ---
# We redirect stderr to null to avoid printing error messages on failure
if (-not (flyctl auth whoami 2>$null)) {
    Write-Host "⚠️ You are not logged into fly.io."
    Write-Host "A browser window will open to log you in."
    flyctl auth login
} else {
    Write-Host "✅ You are already logged into fly.io."
}

# --- 3. Get app name and region from fly.toml ---
if (-not (Test-Path -Path "fly.toml")) {
    Write-Host "Error: 'fly.toml' file not found in the current directory."
    exit 1
}

$appNameLine = Get-Content -Path "fly.toml" | Select-String -Pattern "^\s*app\s*="
$appName = ($appNameLine.Line -replace '^\s*app\s*=\s*''|''\s*$' -replace '"','').Trim()

$regionLine = Get-Content -Path "fly.toml" | Select-String -Pattern "^\s*primary_region\s*="
$region = ($regionLine.Line -replace '^\s*primary_region\s*=\s*''|''\s*$' -replace '"','').Trim()

if ([string]::IsNullOrWhiteSpace($appName) -or [string]::IsNullOrWhiteSpace($region)) {
    Write-Host "Error: Could not find app name or primary_region in 'fly.toml'."
    exit 1
}

Write-Host "-------------------------------------"
Write-Host "App Name: $appName"
Write-Host "Region: $region"
Write-Host "-------------------------------------"


# --- 4. Create or confirm Fly.io app ---
$appExists = $true
try {
    flyctl status --app $appName --machine-status | Out-Null
} catch {
    $appExists = $false
}

if (-not $appExists) {
    Write-Host "🛬 App '$appName' does not exist. Creating it now."
    flyctl launch --name $appName --region $region --ha=false --no-deploy --copy-config
    Write-Host "✅ App '$appName' has been created."
} else {
    Write-Host "✅ App '$appName' already exists."
}

# --- 5. Set N8N_ENCRYPTION_KEY secret ---
$secrets = flyctl secrets list --app $appName
if ($secrets -notmatch "N8N_ENCRYPTION_KEY") {
    Write-Host "🔑 N8N_ENCRYPTION_KEY secret is not set. Generating and setting a new one."
    
    # Generate a secure 32-byte random key and convert to hex
    $bytes = New-Object Byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $encryptionKey = -join ($bytes | ForEach-Object { $_.ToString('x2') })
    
    flyctl secrets set "N8N_ENCRYPTION_KEY=$encryptionKey" --app $appName
    Write-Host "✅ New N8N_ENCRYPTION_KEY secret has been created and set."
} else {
    Write-Host "✅ N8N_ENCRYPTION_KEY secret is already set."
}

# --- 6. Deploy the app ---
Write-Host "📦 Deploying the app. This may take a few minutes..."
flyctl deploy --app $appName --dockerfile Dockerfile
Write-Host "✅ Deployment complete."

# --- 7. Scale the app ---
Write-Host "⚖️ Scaling app instances to 1."
flyctl scale count 1 --app $appName
Write-Host "✅ Scaling complete."

# --- 8. Display app info ---
Write-Host ""
Write-Host "🎉 Deployment process is complete! Check your app status below."
flyctl status --app $appName

Write-Host "🔗 App URL: https://$appName.fly.dev"

# Return to the original directory
Pop-Location 