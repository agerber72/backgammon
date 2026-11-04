# Builds the release bundle for Google Play and names it after the package
# and the version, for example build/release/de.p2g_it.backgammon_1.0.0-6.aab.
# Usage: ./tools/android/build_bundle.ps1
$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')

$gradle = Get-Content (Join-Path $root 'android\app\build.gradle.kts') -Raw
$package = [regex]::Match($gradle, 'applicationId\s*=\s*"([^"]+)"').Groups[1].Value
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
$version = [regex]::Match($pubspec, '(?m)^version:\s*(\S+)').Groups[1].Value
if (-not $package -or $version -notmatch '^(\d+\.\d+\.\d+)\+(\d+)$') {
    throw "Package name or version not found: '$package', '$version'"
}
$name = $Matches[1]
$code = $Matches[2]

Push-Location $root
try {
    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) {
        throw "flutter build appbundle failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

# The merged manifest shows what Google will see: version and permissions.
$manifest = Get-ChildItem (Join-Path $root 'build\app\intermediates') -Recurse `
    -Filter AndroidManifest.xml |
    Where-Object FullName -Match 'merged_manifest\\release' |
    Select-Object -First 1
$content = Get-Content $manifest.FullName -Raw
if ($content -notmatch "android:versionCode=`"$code`"") {
    throw "The bundle does not carry version code $code"
}
foreach ($permission in 'android.permission.INTERNET',
    'com.google.android.gms.permission.AD_ID',
    'com.android.vending.CHECK_LICENSE') {
    if ($content.Contains($permission)) {
        throw "The bundle asks for $permission"
    }
}

$target = Join-Path $root "build\release\${package}_$name-$code.aab"
New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
Copy-Item (Join-Path $root 'build\app\outputs\bundle\release\app-release.aab') $target -Force
Write-Output $target
