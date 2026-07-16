# Generate Android upload keystore (run once on your PC)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path "$PSScriptRoot")) { $root = Get-Location }

Set-Location $PSScriptRoot
$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
if (-not (Test-Path $keytool)) {
  Write-Error "keytool not found at Android Studio JBR. Install Android Studio first."
}

$keystore = Join-Path $PSScriptRoot "asan-upload-keystore.jks"
if (Test-Path $keystore) {
  Write-Host "Keystore already exists: $keystore"
  exit 0
}

Write-Host "You will be prompted for passwords and certificate details."
& $keytool -genkey -v -keystore $keystore -keyalg RSA -keysize 2048 -validity 10000 -alias asan

@"
storePassword=PASTE_STORE_PASSWORD
keyPassword=PASTE_KEY_PASSWORD
keyAlias=asan
storeFile=asan-upload-keystore.jks
"@ | Set-Content -Path (Join-Path $PSScriptRoot "key.properties") -Encoding ASCII

Write-Host ""
Write-Host "Created $keystore"
Write-Host "Edit android/key.properties with the passwords you just entered."
Write-Host "KEEP A BACKUP of the .jks file in a safe place."
