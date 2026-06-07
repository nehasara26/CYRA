# setup_flutter.ps1
# This script downloads and installs the Flutter SDK on Windows.

$installDir = "C:\src"
$flutterDir = "$installDir\flutter"

# 1. Create target directory
if (-not (Test-Path $installDir)) {
    Write-Host "Creating installation directory: $installDir"
    New-Item -ItemType Directory -Force -Path $installDir
}

if (Test-Path $flutterDir) {
    Write-Host "Flutter seems to already exist at $flutterDir. Please remove it first if you want to reinstall."
    exit
}

# 2. Clone Flutter stable channel using Git (much faster and more reliable than downloading the zip)
Write-Host "Cloning Flutter SDK from Github (stable channel)..."
git clone https://github.com/flutter/flutter.git -b stable $flutterDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Git clone failed. Please check your internet connection." -ForegroundColor Red
    exit
}

# 3. Add to user Path environment variable
Write-Host "Adding Flutter to user environment variables..."
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$flutterDir\bin*") {
    $newUserPath = "$userPath;$flutterDir\bin"
    [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    Write-Host "Successfully added Flutter bin to User PATH." -ForegroundColor Green
} else {
    Write-Host "Flutter bin is already in User PATH." -ForegroundColor Yellow
}

Write-Host "--------------------------------------------------------" -ForegroundColor Green
Write-Host "Flutter SDK has been successfully installed at $flutterDir!" -ForegroundColor Green
Write-Host "Please restart your terminal/IDE for the PATH changes to take effect." -ForegroundColor Green
Write-Host "Then run: flutter doctor" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor Green
