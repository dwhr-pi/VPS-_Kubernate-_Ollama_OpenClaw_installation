[CmdletBinding()]
param(
    [ValidateSet('marp', 'listmonk', 'mautic')]
    [string]$Tool = 'marp',
    [ValidateSet('plan', 'install', 'update', 'repair', 'uninstall', 'status', 'check', 'doctor')]
    [string]$Action = 'plan',
    [string]$PythonBin
)
$ErrorActionPreference = 'Stop'

try {
    $root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $helper = Join-Path $root 'scripts\tools\helpers\webinar_releases.py'
    if (-not (Test-Path -LiteralPath $helper -PathType Leaf)) {
        throw 'GitHub-Releaseinstaller fehlt im ausgewaehlten Setup.'
    }
    # The Windows home is deliberately independent of the WSL user-data path.
    if ($Action -eq 'plan') {
        [ordered]@{
            tool = $Tool
            target = 'native-windows'
            action = 'plan'
            userData = (Join-Path $env:USERPROFILE '.openclaw_ultimate_user_data')
            helper = $helper
            network = $false
            executed = $false
            note = 'Python >=3.10 erforderlich. Kein WSL, Docker, Dienst oder DB-Setup.'
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
            if (-not $command) { throw 'Windows-Python >=3.10 fehlt. PythonBin angeben; kein automatischer Download.' }
            $PythonBin = $command.Source
        }
    }
    & $PythonBin @prefix -c 'import sys; raise SystemExit(0 if sys.platform == chr(119)+chr(105)+chr(110)+chr(51)+chr(50) and sys.version_info >= (3,10) else 1)'
    if ($LASTEXITCODE -ne 0) { throw 'Ein natives Windows-Python >=3.10 ist erforderlich.' }
    $previousData = $env:OPENCLAW_USER_DATA_DIR
    try {
        $env:OPENCLAW_USER_DATA_DIR = Join-Path $env:USERPROFILE '.openclaw_ultimate_user_data'
        & $PythonBin @prefix -X utf8 -B $helper $Tool $Action
        $result = $LASTEXITCODE
    } finally {
        $env:OPENCLAW_USER_DATA_DIR = $previousData
    }
    exit $result
} catch {
    [Console]::Error.WriteLine('Windows-Webinar-Setup: ' + $_.Exception.Message)
    exit 1
}
