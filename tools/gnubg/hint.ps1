# Prints GNU Backgammon's ranked moves for a position and a dice roll.
# Usage: ./tools/gnubg/hint.ps1 -PositionId 4HPwATDgc/ABMA -Die1 3 -Die2 1 -Plies 2
param(
    [Parameter(Mandatory)][string]$PositionId,
    [Parameter(Mandatory)][ValidateRange(1, 6)][int]$Die1,
    [Parameter(Mandatory)][ValidateRange(1, 6)][int]$Die2,
    [ValidateRange(0, 3)][int]$Plies = 2,
    [ValidateRange(1, 50)][int]$MaxMoves = 10
)
$ErrorActionPreference = 'Stop'

$cli = Join-Path $PSScriptRoot 'app\gnubg-cli.exe'
if (-not (Test-Path $cli)) {
    throw 'GNU Backgammon is not installed. Run tools/gnubg/setup.ps1 first.'
}

$env:GNUBG_POSITION_ID = $PositionId
$env:GNUBG_DIE_1 = $Die1
$env:GNUBG_DIE_2 = $Die2
$env:GNUBG_PLIES = $Plies
$env:GNUBG_MAX_MOVES = $MaxMoves

$output = & $cli -q -r -p (Join-Path $PSScriptRoot 'hint.py') 2>&1 | ForEach-Object { "$_" }
$results = $output | Where-Object { $_ -like 'RESULT *' }
if (-not $results) {
    $output | Write-Host
    throw 'GNU Backgammon returned no result.'
}
$results | ForEach-Object { $_.Substring('RESULT '.Length) }
