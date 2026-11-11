# Builds the Windows release as a ZIP for GitHub Releases, for example
# build/release/backgammon_windows_1.1.0-8.zip, and checks that the unpacked
# app starts.
# The ZIP carries the Visual C++ runtime next to backgammon.exe, so the app
# also starts on PCs without the Visual C++ Redistributable, and the license.
# Usage: ./tools/windows/build_release.ps1 [-SkipStartTest]
param([switch]$SkipStartTest)
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')

$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
$version = [regex]::Match($pubspec, '(?m)^version:\s*(\S+)').Groups[1].Value
if ($version -notmatch '^(\d+\.\d+\.\d+)\+(\d+)$') {
    throw "Version not found: '$version'"
}
$name = $Matches[1]
$code = $Matches[2]

Push-Location $root
try {
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        throw "flutter build windows failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

$built = Join-Path $root 'build\windows\x64\runner\Release'
$exe = Join-Path $built 'backgammon.exe'
$info = (Get-Item $exe).VersionInfo
if ($info.ProductVersion -ne $version -and $info.ProductVersion -ne $name) {
    throw "backgammon.exe carries version '$($info.ProductVersion)', expected $version"
}

# Prefer the redistributable runtime from Visual Studio, fall back to System32.
$runtime = 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll'
$redist = $null
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vs = & $vswhere -latest -products * -property installationPath
    if ($vs) {
        $redist = Get-ChildItem (Join-Path $vs 'VC\Redist\MSVC') -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName 'x64\Microsoft.VC143.CRT' } |
            Where-Object { Test-Path (Join-Path $_ 'vcruntime140.dll') } |
            Sort-Object -Descending | Select-Object -First 1
    }
}
if (-not $redist) { $redist = Join-Path $env:SystemRoot 'System32' }

$folderName = "backgammon_windows_$name-$code"
$release = Join-Path $root 'build\release'
$stage = Join-Path $release $folderName
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null
Copy-Item (Join-Path $built '*') $stage -Recurse
foreach ($dll in $runtime) {
    Copy-Item (Join-Path $redist $dll) $stage
}
Copy-Item (Join-Path $root 'LICENSE') (Join-Path $stage 'LICENSE.txt')

foreach ($required in 'backgammon.exe', 'flutter_windows.dll', 'data\app.so',
    'data\icudtl.dat', 'data\flutter_assets\AssetManifest.bin') {
    if (-not (Test-Path (Join-Path $stage $required))) {
        throw "The release lacks $required"
    }
}

$zip = Join-Path $release "$folderName.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $stage -DestinationPath $zip -CompressionLevel Optimal

if (-not $SkipStartTest) {
    # Unpack the ZIP like a user would and check that the app keeps running.
    $check = Join-Path ([IO.Path]::GetTempPath()) "backgammon_start_test_$code"
    if (Test-Path $check) { Remove-Item $check -Recurse -Force }
    Expand-Archive $zip $check
    $process = Start-Process (Join-Path $check "$folderName\backgammon.exe") -PassThru
    try {
        Start-Sleep -Seconds 8
        if ($process.HasExited) {
            throw "The unpacked app exited with code $($process.ExitCode)"
        }
        $process.Refresh()
        if ($process.MainWindowHandle -eq 0) {
            throw 'The unpacked app shows no window'
        }
    } finally {
        if (-not $process.HasExited) { Stop-Process $process -Force }
        $process.WaitForExit()
        Remove-Item $check -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Output $zip
