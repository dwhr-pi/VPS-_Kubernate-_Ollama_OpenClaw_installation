# Create a new disposable lab only. Never adopt, unregister or shut down other distributions.
[CmdletBinding()]
param(
    [ValidateSet('Plan', 'Run')][string]$Action = 'Plan',
    [string]$Python = 'python',
    [string]$Distribution = 'OpenClaw-InstallLab-Builds',
    [string]$LabDirectory,
    [string]$RootfsTar,
    [string]$RootfsSha256,
    [string]$ApprovalsFile,
    [ValidateRange(2048, 1048576)][int]$HostReserveMiB = 8192,
    [switch]$ConfirmNewDistribution,
    [switch]$ConfirmBuildAndUninstall
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$pythonCommand = Get-Command -Name $Python -CommandType Application -ErrorAction Stop
$Python = $pythonCommand.Source
if ($Python -match '[\\/]Microsoft[\\/]WindowsApps[\\/]' -or
    [IO.Path]::GetExtension($Python) -ine '.exe') { throw 'Existing native Python required; no Store alias or shell fallback.' }
if ($Distribution -cnotmatch '^OpenClaw-InstallLab-[A-Za-z0-9-]{1,48}$') {
    throw 'A dedicated OpenClaw-InstallLab-NAME is required.'
}
$planText = & $Python -I -B (Join-Path $PSScriptRoot 'install_lab.py') plan
if ($LASTEXITCODE -ne 0) { throw 'Offline plan failed; no WSL action.' }
$plan = ($planText -join "`n") | ConvertFrom-Json
if ($Action -eq 'Plan') {
    [pscustomobject]@{ distribution = $Distribution; executed = $false; tools = $plan.tools } |
        ConvertTo-Json -Depth 8
    return
}
if (-not $ConfirmNewDistribution -or -not $ConfirmBuildAndUninstall) {
    throw 'Run requires both explicit approvals; no WSL action.'
}
if ($RootfsSha256 -cnotmatch '^[a-f0-9]{64}$') { throw 'Independent rootfs SHA256 required.' }

function Assert-RegularPath([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    if ($full.StartsWith('\\')) { throw 'Local filesystem required.' }
    $current = $full
    while ($current) {
        if (Test-Path -LiteralPath $current) {
            $item = Get-Item -LiteralPath $current -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked path refused.' }
        }
        $next = Split-Path -Parent $current
        if ($next -eq $current) { break }
        $current = $next
    }
    return $full
}
$RootfsTar = Assert-RegularPath $RootfsTar
$ApprovalsFile = Assert-RegularPath $ApprovalsFile
if (-not (Test-Path -LiteralPath $RootfsTar -PathType Leaf) -or
    -not (Test-Path -LiteralPath $ApprovalsFile -PathType Leaf)) { throw 'Rootfs and approvals files required.' }
if ((Get-Item -LiteralPath $ApprovalsFile).Length -gt 1048576) { throw 'Approvals file too large.' }
if ((Get-FileHash -LiteralPath $RootfsTar -Algorithm SHA256).Hash.ToLowerInvariant() -ne $RootfsSha256) {
    throw 'Rootfs hash mismatch; no WSL action.'
}
$approvalsText = [IO.File]::ReadAllText($ApprovalsFile)
$approvals = $approvalsText | ConvertFrom-Json
function Test-Approval($Tool) {
    $entry = $approvals.PSObject.Properties[$Tool.tool]
    if (-not $entry -or -not $entry.Value) { return $false }
    $hash = $entry.Value.PSObject.Properties['recipe_sha256']
    $terms = $entry.Value.PSObject.Properties['source_and_dependency_terms_reviewed']
    return ($hash -and $terms -and $hash.Value -ceq $Tool.recipe_sha256 -and
            $terms.Value -is [bool] -and $terms.Value -eq $true)
}
if (-not @($plan.tools | Where-Object { $_.eligible -and (Test-Approval $_) }).Count) {
    throw 'No reviewed recipe/license approval. No distribution imported or packages downloaded.'
}
# Require reviewed sources in HEAD. A local untracked runner is not silently substituted.
$gitArguments = @('-c', 'core.hooksPath=/dev/null', '-c', 'core.fsmonitor=false', '-c', 'credential.helper=', '-C', $repo)
& git @gitArguments ls-files --error-unmatch scripts/benchmarks/install_lab.py `
    scripts/benchmarks/install_lab_reports.py scripts/benchmarks/wsl_install_lab.ps1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Review and commit the lab implementation before a real run.' }
& git @gitArguments diff --no-ext-diff --no-textconv --quiet HEAD -- scripts config
if ($LASTEXITCODE -ne 0) { throw 'Modified build code/configuration refused; commit a reviewed snapshot first.' }
if (-not $LabDirectory) { $LabDirectory = Join-Path $env:LOCALAPPDATA "OpenClawInstallLabs/$Distribution" }
$LabDirectory = Assert-RegularPath $LabDirectory
if (Test-Path -LiteralPath $LabDirectory) { throw 'Lab directory must be new; nothing overwritten.' }
if ($LabDirectory.Length -le ([IO.Path]::GetPathRoot($LabDirectory)).Length -or
    $LabDirectory.StartsWith($repo + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
    $LabDirectory -eq $repo) { throw 'A separate new lab directory is required.' }
$drive = [IO.DriveInfo]::new([IO.Path]::GetPathRoot($LabDirectory))
if ($drive.AvailableFreeSpace -lt (($HostReserveMiB + 4096) * 1MB + (Get-Item $RootfsTar).Length)) {
    throw 'Insufficient Windows host space before import; no distribution created.'
}
$wsl = Join-Path ([Environment]::GetFolderPath('System')) 'wsl.exe'
if (-not (Test-Path -LiteralPath $wsl -PathType Leaf)) { throw 'Existing WSL2 required; no automatic WSL installation.' }
$names = & $wsl --list --quiet
if ($LASTEXITCODE -ne 0) { throw 'Cannot verify distribution list.' }
foreach ($name in $names) {
    if ($name.Replace([string][char]0, '').Trim().Trim([char]0xFEFF) -ieq $Distribution) {
        throw 'Distribution already exists; existing distributions are never adopted.'
    }
}
[IO.Directory]::CreateDirectory($LabDirectory) | Out-Null
$archive = Join-Path $LabDirectory 'reviewed-source.tar'
& git @gitArguments archive --format=tar "--output=$archive" HEAD
if ($LASTEXITCODE -ne 0) { throw 'Source archive failed; no import.' }
$commit = (& git @gitArguments rev-parse --verify 'HEAD^{commit}').Trim()
if ($LASTEXITCODE -ne 0 -or $commit -cnotmatch '^[a-f0-9]{40}$') { throw 'A real source commit is required; no import.' }
$nonce = [Guid]::NewGuid().ToString('N')
$identity = @{ schema = 2; mode = 'wsl'; distribution = $Distribution; nonce = $nonce; uid = 20000;
               source_root = '/opt/openclaw-install-lab/repo'; source_commit = $commit } | ConvertTo-Json -Compress
[IO.File]::WriteAllText((Join-Path $LabDirectory 'lab-identity.json'), $identity)
& $wsl --import $Distribution (Join-Path $LabDirectory 'distro') $RootfsTar --version 2
if ($LASTEXITCODE -ne 0) { throw 'Import failed; files preserved, no automatic unregister.' }

function Invoke-Guest([string[]]$GuestArgs, [string]$Text, [string]$InputFile, [switch]$AllowCycleExitCodes) {
    # Guest arguments below are fixed paths, validated IDs or numbers, never shell programs.
    $all = @('--distribution', $Distribution) + $GuestArgs
    foreach ($arg in $all) {
        if ($arg -match '[\s"]') { throw 'Unexpected guest argument; no shell interpolation allowed.' }
    }
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $wsl
    $start.Arguments = $all -join ' '
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.EnvironmentVariables['WSLENV'] = ''
    $start.RedirectStandardInput = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = [Diagnostics.Process]::Start($start)
    $outTask = $process.StandardOutput.ReadToEndAsync()
    $errTask = $process.StandardError.ReadToEndAsync()
    $completed = $false
    try {
        if ($InputFile) {
            $stream = [IO.File]::OpenRead($InputFile)
            try { $stream.CopyTo($process.StandardInput.BaseStream) } finally { $stream.Dispose() }
        } elseif ($Text) {
            $bytes = [Text.Encoding]::UTF8.GetBytes($Text.Replace("`r`n", "`n"))
            $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
        }
        $process.StandardInput.Close()
        $timer = [Diagnostics.Stopwatch]::StartNew()
        while (-not $process.WaitForExit(1000)) {
            if ([IO.DriveInfo]::new($drive.Name).AvailableFreeSpace -lt ($HostReserveMiB * 1MB) -or
                $timer.Elapsed.TotalSeconds -gt 20000) {
                # This name was freshly imported by this invocation, never adopted.
                & $wsl --terminate $Distribution | Out-Null
                throw 'Host reserve/time limit reached; only the new lab stopped. Data and logs preserved.'
            }
        }
        $output = $outTask.GetAwaiter().GetResult()
        $errorText = $errTask.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0 -and -not ($AllowCycleExitCodes -and $process.ExitCode -in @(1, 2))) {
            throw "Lab command failed ($($process.ExitCode)); lab preserved. $errorText $output"
        }
        $completed = $true
        return $output
    } finally {
        if (-not $completed -or -not $process.HasExited) { & $wsl --terminate $Distribution | Out-Null }
        $process.Dispose()
    }
}
$identity64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($identity))
$approvals64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($approvalsText))
$bootstrap = @'
set -Eeuo pipefail
umask 022
. /etc/os-release
[[ "$ID" == ubuntu && "$VERSION_ID" == 24.04 ]] || exit 2
! command -v docker >/dev/null
! command -v podman >/dev/null
! id oc-install-lab >/dev/null 2>&1
! getent passwd 20000 >/dev/null
[[ ! -e /etc/openclaw-install-lab.json && ! -L /etc/openclaw-install-lab.json ]]
[[ ! -e /opt/openclaw-install-lab && ! -L /opt/openclaw-install-lab ]]
[[ ! -e /home/oc-install-lab && ! -L /home/oc-install-lab ]]
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends python3 python3-venv git ca-certificates curl build-essential pkg-config xz-utils unzip
useradd --create-home --uid 20000 --shell /bin/bash oc-install-lab
printf '[automount]\nenabled=false\nmountFsTab=false\n[interop]\nenabled=false\nappendWindowsPath=false\n[boot]\nsystemd=false\n[user]\ndefault=oc-install-lab\n' >/etc/wsl.conf
mkdir -p /opt/openclaw-install-lab/repo
python3 - <<'PY'
import base64, pathlib
pathlib.Path('/etc/openclaw-install-lab.json').write_bytes(base64.b64decode('IDENTITY64'))
pathlib.Path('/home/oc-install-lab/approvals.json').write_bytes(base64.b64decode('APPROVALS64'))
pathlib.Path('/opt/openclaw-install-lab/extract.py').write_text('''import pathlib, sys, tarfile
root = pathlib.Path('/opt/openclaw-install-lab/repo')
with tarfile.open(fileobj=sys.stdin.buffer, mode='r|*') as archive:
    for member in archive:
        name = pathlib.PurePosixPath(member.name)
        if name.is_absolute() or '..' in name.parts or not (member.isdir() or member.isfile()):
            raise ValueError('Unsafe archive entry')
        archive.extract(member, path=root, filter='data')
''')
PY
chmod 644 /etc/openclaw-install-lab.json
chown oc-install-lab:oc-install-lab /home/oc-install-lab/approvals.json
chmod 600 /home/oc-install-lab/approvals.json
'@
$bootstrap = $bootstrap.Replace('IDENTITY64', $identity64).Replace('APPROVALS64', $approvals64)
$bootstrapLog = Invoke-Guest @('--user', 'root', '--exec', '/usr/bin/env', '-i',
    'PATH=/usr/sbin:/usr/bin:/sbin:/bin', 'HOME=/root', 'LANG=C.UTF-8', '/bin/bash', '--noprofile', '--norc', '-s') $bootstrap ''
[IO.File]::WriteAllText((Join-Path $LabDirectory 'bootstrap.log'), $bootstrapLog)
Invoke-Guest @('--user', 'root', '--exec', '/usr/bin/python3', '/opt/openclaw-install-lab/extract.py') '' $archive | Out-Null
# Restart only the newly created distribution to apply its per-distro restrictions.
& $wsl --terminate $Distribution
if ($LASTEXITCODE -ne 0) { throw 'Cannot apply lab restrictions; no build started.' }
$reportPath = Join-Path $LabDirectory 'cycles.jsonl'
$incomplete = Join-Path $LabDirectory 'CYCLE_INCOMPLETE'
[IO.File]::WriteAllText($incomplete, 'Run not complete; never infer success from partial reports.')
$reportStream = [IO.StreamWriter]::new([IO.File]::Open($reportPath, [IO.FileMode]::CreateNew), [Text.UTF8Encoding]::new($false))
$blocked = $false
$failures = 0
try {
    foreach ($tool in $plan.tools) {
        $hostFree = [math]::Floor([IO.DriveInfo]::new($drive.Name).AvailableFreeSpace / 1MB)
        if ($blocked) { $status = 'not_attempted_cleanup_blocked' }
        elseif (-not $tool.eligible) { $status = 'skipped_unsupported_contract' }
        elseif (-not (Test-Approval $tool)) { $status = 'skipped_license_not_approved' }
        elseif ($hostFree -lt ($tool.build_reserve_mib + 2048 + $HostReserveMiB)) { $status = 'skipped_insufficient_space' }
        else { $status = '' }
        if ($status) {
            $report = @{ tool = $tool.tool; status = $status; executed = $false; installed_after_cycle = $false;
                         backend = 'wsl2'; source_commit = $commit }
        } else {
            $output = Invoke-Guest @('--user', 'oc-install-lab', '--exec', '/usr/bin/python3', '-I', '-B',
                '/opt/openclaw-install-lab/repo/scripts/benchmarks/install_lab.py', 'run-one',
                '--tool', $tool.tool, '--distribution', $Distribution, '--nonce', $nonce,
                '--approvals', '/home/oc-install-lab/approvals.json', '--host-free-mib', "$hostFree",
                '--host-reserve-mib', "$HostReserveMiB", '--confirm-build-and-uninstall') '' '' -AllowCycleExitCodes
            $report = $output | ConvertFrom-Json
            if (-not $report.PSObject.Properties['tool']) { $report | Add-Member -NotePropertyName tool -NotePropertyValue $tool.tool }
        }
        $reportStream.WriteLine(($report | ConvertTo-Json -Depth 12 -Compress))
        $reportStream.Flush()
        if ($report.status.StartsWith('failed_')) { $failures++ }
        if ($report.status -eq 'refused' -or ($report.executed -and -not $report.cleanup_ok)) {
            $blocked = $true
            & $wsl --terminate $Distribution | Out-Null
        }
    }
} finally { $reportStream.Dispose() }
$backupArguments = @('-I', '-B', (Join-Path $PSScriptRoot 'install_lab_reports.py'), 'backup', '--input', $reportPath,
    '--output', (Join-Path $LabDirectory 'measurements-backup.tar'), '--apply')
if (-not $blocked) { $backupArguments += '--complete-batch' }
& $Python @backupArguments
if ($LASTEXITCODE -ne 0) { throw 'Measurement backup failed; raw reports and lab preserved.' }
if ($blocked) { throw 'Cleanup/refusal blocked the batch; remaining entries recorded as not attempted. Lab preserved.' }
[IO.File]::Delete($incomplete)
if ($failures -gt 0) { throw "Measurements complete, but $failures lifecycle tests failed. Reports and backup preserved." }
Write-Output "Measurements: $reportPath; source commit: $commit. No normal installation status changed."
Write-Output 'Lab and logs preserved. No unregister, global shutdown, compact or personal distro access.'
