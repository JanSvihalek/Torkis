#Requires -Version 5.1
# Pripravi base64 hodnoty pro GitHub Secrets pro iOS TestFlight build.
# Pouziti:
#   .\scripts\prepare-ios-secrets.ps1 -ProfilePath "C:\Users\JanSv\Downloads\Torkis_App_Store.mobileprovision" -P8Path "C:\Users\JanSv\Downloads\AuthKey_XXXXXXXXXX.p8"

param(
    [Parameter(Mandatory = $true)]
    [string]$ProfilePath,

    [Parameter(Mandatory = $true)]
    [string]$P8Path,

    [string]$P12Path = "$env:USERPROFILE\.ios-signing\distribution.p12"
)

$OutDir = "$env:USERPROFILE\.ios-signing\github-secrets"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function ToBase64($path) {
    if (-not (Test-Path $path)) {
        Write-Host "CHYBA: Soubor neexistuje: $path" -ForegroundColor Red
        exit 1
    }
    [Convert]::ToBase64String([IO.File]::ReadAllBytes($path))
}

function Save-Secret($name, $value) {
    $file = Join-Path $OutDir "$name.txt"
    [IO.File]::WriteAllText($file, $value)
    Write-Host "  $name  ->  $file" -ForegroundColor Green
}

Write-Host "Generuji hodnoty pro GitHub Secrets..." -ForegroundColor Cyan
Write-Host ""

Save-Secret "IOS_CERT_BASE64"    (ToBase64 $P12Path)
Save-Secret "IOS_PROFILE_BASE64" (ToBase64 $ProfilePath)
Save-Secret "ASC_KEY_BASE64"     (ToBase64 $P8Path)

$keyId = [IO.Path]::GetFileNameWithoutExtension($P8Path) -replace '^AuthKey_', ''
Save-Secret "ASC_KEY_ID" $keyId

# IOS_PROFILE_NAME ze samotneho mobileprovision (text uvnitr binarniho plistu)
$profileBytes = [IO.File]::ReadAllBytes($ProfilePath)
$profileText = [Text.Encoding]::UTF8.GetString($profileBytes)
if ($profileText -match '<key>Name</key>\s*<string>([^<]+)</string>') {
    Save-Secret "IOS_PROFILE_NAME" $matches[1]
}

# APPLE_TEAM_ID lze take precist z provisioning profilu (application-identifier)
if ($profileText -match '<key>application-identifier</key>\s*<string>([A-Z0-9]+)\.') {
    Save-Secret "APPLE_TEAM_ID" $matches[1]
}

Write-Host ""
Write-Host "Vsechny base64 hodnoty ulozeny do: $OutDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Otevri slozku v Pruzkumniku:" -ForegroundColor Yellow
Write-Host "  explorer `"$OutDir`""
Write-Host ""
Write-Host "Pro kazdy secret: otevri soubor, Ctrl+A, Ctrl+C, vlozit do GitHub Secrets." -ForegroundColor Yellow
Write-Host ""
Write-Host "RUCNE musis jeste pridat tyto 3 secrets:" -ForegroundColor Magenta
Write-Host "  IOS_CERT_PASSWORD  -> heslo k distribution.p12"
Write-Host "  KEYCHAIN_PASSWORD  -> libovolne, napr. 'gh-actions-keychain'"
Write-Host "  ASC_ISSUER_ID      -> z https://appstoreconnect.apple.com/access/integrations/api"

# Otevri slozku automaticky
Start-Process explorer.exe $OutDir
