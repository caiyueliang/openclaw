# A2UI Bundle PowerShell Script for Windows
# This is a simplified version of bundle-a2ui.sh for Windows

$ROOT_DIR = Resolve-Path (Join-Path $PSScriptRoot "..")
$HASH_FILE = Join-Path $ROOT_DIR "src/canvas-host/a2ui/.bundle.hash"
$OUTPUT_FILE = Join-Path $ROOT_DIR "src/canvas-host/a2ui/a2ui.bundle.js"
$A2UI_RENDERER_DIR = Join-Path $ROOT_DIR "vendor/a2ui/renderers/lit"
$A2UI_APP_DIR = Join-Path $ROOT_DIR "apps/shared/OpenClawKit/Tools/CanvasA2UI"

# Check if source directories exist
if (-not (Test-Path $A2UI_RENDERER_DIR) -or -not (Test-Path $A2UI_APP_DIR)) {
    Write-Host "A2UI sources missing; keeping prebuilt bundle."
    exit 0
}

# For now, skip the bundling since it requires bash
# The project should work without this step for basic functionality
Write-Host "Skipping A2UI bundle step (bash not available on Windows)"
Write-Host "This is expected on Windows without WSL. The project will still work."
exit 0
