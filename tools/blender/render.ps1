# Renders the board assets into assets/board, and larger copies for
# high-resolution displays into assets/board/hd.
# Usage: ./tools/blender/render.ps1              both tiers
#        ./tools/blender/render.ps1 -Tier normal only assets/board
#        ./tools/blender/render.ps1 -Tier hd     only assets/board/hd
#        ./tools/blender/render.ps1 -Preview     quick previews in tools/blender/preview
param(
    [switch]$Preview,
    [ValidateSet('all', 'normal', 'hd')][string]$Tier = 'all'
)
$ErrorActionPreference = 'Stop'

$blender = Join-Path $PSScriptRoot 'app\blender.exe'
if (-not (Test-Path $blender)) {
    throw 'Blender is not installed. Run tools/blender/setup.ps1 first.'
}

function Invoke-Render([string[]]$options) {
    $arguments = @(
        '-b', '--factory-startup', '--python-exit-code', '1',
        '--python', (Join-Path $PSScriptRoot 'render_board.py'), '--'
    ) + $options
    & $blender @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Blender failed with exit code $LASTEXITCODE"
    }
}

if ($Preview) {
    Invoke-Render @('preview')
    return
}
if ($Tier -in 'all', 'normal') {
    Invoke-Render @()
}
if ($Tier -in 'all', 'hd') {
    Invoke-Render @('hd')
}
