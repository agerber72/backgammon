# Renders the board assets into assets/board.
# Usage: ./tools/blender/render.ps1            all assets
#        ./tools/blender/render.ps1 -Preview   quick previews in tools/blender/preview
param([switch]$Preview)
$ErrorActionPreference = 'Stop'

$blender = Join-Path $PSScriptRoot 'app\blender.exe'
if (-not (Test-Path $blender)) {
    throw 'Blender is not installed. Run tools/blender/setup.ps1 first.'
}

$arguments = @(
    '-b', '--factory-startup', '--python-exit-code', '1',
    '--python', (Join-Path $PSScriptRoot 'render_board.py')
)
if ($Preview) {
    $arguments += '--', 'preview'
}
& $blender @arguments
if ($LASTEXITCODE -ne 0) {
    throw "Blender failed with exit code $LASTEXITCODE"
}
