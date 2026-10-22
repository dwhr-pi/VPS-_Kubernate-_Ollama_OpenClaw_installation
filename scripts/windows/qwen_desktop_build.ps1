param(
    [ValidateSet('install', 'update', 'repair', 'uninstall', 'status', 'check', 'doctor', 'plan')]
    [string]$Action = 'plan'
)
$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot '../tools/helpers/gap_tools.py'
# Native Python is intentional: never build the Windows desktop inside WSL.
& python -B $helper qwen_desktop_build $Action
exit $LASTEXITCODE
