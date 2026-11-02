# Installs a portable Blender into tools/blender/app for rendering the board assets.
# The binaries are git-ignored; only the rendered images are shipped with the app.
$ErrorActionPreference = 'Stop'

$version = '4.5.15'
$archiveName = "blender-$version-windows-x64"
$url = "https://download.blender.org/release/Blender4.5/$archiveName.zip"
$expectedSha256 = '52dd02fd74877fa08e74b67d7854cf32468a232c02aaa19b6844c91285574f8d'

$appDir = Join-Path $PSScriptRoot 'app'
$downloadDir = Join-Path $PSScriptRoot '.download'
$archive = Join-Path $downloadDir "$archiveName.zip"

if (Test-Path (Join-Path $appDir 'blender.exe')) {
    Write-Host "Blender is already installed in $appDir"
    exit 0
}

New-Item -ItemType Directory -Force $downloadDir | Out-Null
if (-not (Test-Path $archive)) {
    Write-Host "Downloading $url"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $archive
}

$actualSha256 = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSha256 -ne $expectedSha256) {
    Remove-Item $archive
    throw "Checksum mismatch for $archiveName.zip"
}

Expand-Archive -Path $archive -DestinationPath $downloadDir -Force
Move-Item (Join-Path $downloadDir $archiveName) $appDir

Write-Host "Blender $version installed in $appDir"
