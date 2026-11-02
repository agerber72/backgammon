# Rebuilds test/fixtures/gnubg_legal_plays.json with GNU Backgammon.
# The file is committed, so the tests also run where gnubg is not installed.
$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$cli = Join-Path $PSScriptRoot 'app\gnubg-cli.exe'
if (-not (Test-Path $cli)) {
    throw 'GNU Backgammon is not installed. Run tools/gnubg/setup.ps1 first.'
}

$positions = Join-Path ([IO.Path]::GetTempPath()) 'gnubg_positions.json'
$reference = Join-Path $root 'test\fixtures\gnubg_legal_plays.json'
New-Item -ItemType Directory -Force (Split-Path $reference) | Out-Null

Push-Location $root
try {
    dart run tools/gnubg/export_positions.dart $positions
} finally {
    Pop-Location
}

$env:GNUBG_POSITIONS = $positions
$env:GNUBG_REFERENCE = $reference
& $cli -q -r -p (Join-Path $PSScriptRoot 'legal_plays.py') 2>&1 |
    ForEach-Object { "$_" } | Where-Object { $_ -like 'RESULT *' -or $_ -like '*Error*' -or $_ -like 'Traceback*' }
