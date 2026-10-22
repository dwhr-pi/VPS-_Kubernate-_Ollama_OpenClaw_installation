param(
    [ValidateSet('install', 'update', 'repair', 'uninstall', 'status', 'check', 'doctor', 'plan')]
    [string]$Action = 'plan',
    [string]$PythonBin
)
$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot '../tools/helpers/gap_tools.py'
try {
    if ($Action -eq 'plan') {
        $manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../tools/helpers/gap_tools.json') -Raw | ConvertFrom-Json
        [ordered]@{
            tool = 'qwen_desktop_build'
            target = 'native-windows'
            action = 'plan'
            source = ('https://github.com/' + $manifest.qwen_desktop_build.repo)
            pin = $manifest.qwen_desktop_build.pin
            reserveMiB = $manifest.qwen_desktop_build.reserve_mb
            userData = (Join-Path $env:USERPROFILE '.openclaw_ultimate_user_data')
            network = $false
            executed = $false
            note = 'Developer PowerShell: Python >=3.10, Git, Node 22/npm/Corepack, Rust MSVC, C++ Buildtools. Kein WSL/Docker/Agentenstart.'
        } | ConvertTo-Json
        exit 0
    }
    $prefix = @()
    if ([string]::IsNullOrWhiteSpace($PythonBin)) {
        $command = Get-Command py.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            $PythonBin = $command.Source
            $prefix = @('-3')
        } else {
            $command = Get-Command python.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $command) { throw 'Natives Windows-Python >=3.10 fehlt; PythonBin angeben.' }
            $PythonBin = $command.Source
        }
    }
    & $PythonBin @prefix -I -c 'import sys; assert sys.platform == chr(119)+chr(105)+chr(110)+chr(51)+chr(50) and sys.version_info >= (3,10)'
    if ($LASTEXITCODE -ne 0) { throw 'Natives Windows-Python >=3.10 erforderlich.' }
    # Do not forward a Linux OPENCLAW_USER_DATA_DIR into the Windows installation.
    $previousData = $env:OPENCLAW_USER_DATA_DIR
    try {
        $env:OPENCLAW_USER_DATA_DIR = Join-Path $env:USERPROFILE '.openclaw_ultimate_user_data'
        & $PythonBin @prefix -X utf8 -B $helper qwen_desktop_build $Action
        $result = $LASTEXITCODE
    } finally {
        $env:OPENCLAW_USER_DATA_DIR = $previousData
    }
    exit $result
} catch {
    [Console]::Error.WriteLine('Windows-Qwen-Desktop-Build: ' + $_.Exception.Message)
    exit 1
}
