# Installs GNU Backgammon into tools/gnubg/app as a development-only test tool.
# The binaries are GPL-licensed and git-ignored; they are never shipped with the app.
$ErrorActionPreference = 'Stop'

$version = '1_08_003-20240428'
$installerName = "gnubg-$version-setup.exe"
$url = "https://ftp.gnu.org/gnu/gnubg/$installerName"
$expectedSha256 = '68cd01d92a99e6ec4bdb5f544c14ecbfcc7d9119afb0d2ac189698b309e62d06'

$appDir = Join-Path $PSScriptRoot 'app'
$downloadDir = Join-Path $PSScriptRoot '.download'
$installer = Join-Path $downloadDir $installerName

if (Test-Path (Join-Path $appDir 'gnubg-cli.exe')) {
    Write-Host "GNU Backgammon is already installed in $appDir"
    exit 0
}

New-Item -ItemType Directory -Force $downloadDir | Out-Null
if (-not (Test-Path $installer)) {
    Write-Host "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $installer
}

$actualSha256 = (Get-FileHash $installer -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $expectedSha256) {
    Remove-Item $installer
    throw "Checksum mismatch for $installerName"
}

$arguments = @(
    '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CURRENTUSER',
    '/NOICONS', '/TASKS=""', "/DIR=`"$appDir`""
)
$process = Start-Process -FilePath $installer -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    throw "Installer failed with exit code $($process.ExitCode)"
}

Write-Host "GNU Backgammon installed in $appDir"
