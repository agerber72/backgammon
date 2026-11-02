# Rebuilds test/fixtures/gnubg_move_equity.json with GNU Backgammon.
# The file is committed, so the strength tests run where gnubg is not installed.
param([int]$Every = 3)
$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$cli = Join-Path $PSScriptRoot 'app\gnubg-cli.exe'
if (-not (Test-Path $cli)) {
    throw 'GNU Backgammon is not installed. Run tools/gnubg/setup.ps1 first.'
}

$env:GNUBG_POSITIONS = Join-Path $root 'test\fixtures\gnubg_legal_plays.json'
$env:GNUBG_REFERENCE = Join-Path $root 'test\fixtures\gnubg_move_equity.json'
$env:GNUBG_EVERY = $Every
& $cli -q -r -p (Join-Path $PSScriptRoot 'move_equity.py') 2>&1 |
    ForEach-Object { "$_" } | Where-Object { $_ -like 'RESULT *' -or $_ -like '*Error*' -or $_ -like 'Traceback*' }
