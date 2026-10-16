[CmdletBinding()]
param(
    [ValidateSet('Plan', 'CheckInstaller')]
    [string]$Action = 'Plan',
    [string]$InstallerPath,
    [string]$ExpectedSha256
)
$ErrorActionPreference = 'Stop'

if ($Action -eq 'Plan') {
    [ordered]@{
        tool = 'Qwen Code Desktop'
        mode = 'manual-windows'
        installed = $false
        executed = $false
        network = $false
        downloadPage = 'https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest'
        guide = 'docs/tools/qwen-desktop-windows.md'
    } | ConvertTo-Json
    exit 0
}

try {
    if ([string]::IsNullOrWhiteSpace($InstallerPath) -or $ExpectedSha256 -notmatch '^[a-fA-F0-9]{64}$') {
        throw 'InstallerPath und geprueften SHA-256-Wert aus demselben offiziellen Release angeben.'
    }
    $file = Get-Item -LiteralPath $InstallerPath -Force
    if ($file.PSIsContainer -or ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        $file.Name -notmatch '^Qwen-Code-Desktop_[0-9][A-Za-z0-9._-]*_x64-setup\.exe$') {
        throw 'Nur eine regulaere x64-Desktop-Installerdatei aus dem offiziellen Release pruefen.'
    }
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    if ($hash -ne $ExpectedSha256) {
        throw 'Hash stimmt nicht ueberein. Nicht installieren.'
    }
    $signature = Get-AuthenticodeSignature -LiteralPath $file.FullName
    if ($signature.Status -ne 'Valid') {
        throw 'Authenticode-Signatur ist nicht gueltig. Nicht installieren; Herkunft manuell klaeren.'
    }
    [ordered]@{
        sha256Matches = $true
        signatureStatus = 'Valid'
        signer = $signature.SignerCertificate.Subject
        publisherManuallyVerified = $false
        executed = $false
        note = 'Signaturinhaber gegen vertrauenswuerdige Herausgeberinformation pruefen; kein automatischer Start.'
    } | ConvertTo-Json
    exit 0
}
catch {
    [Console]::Error.WriteLine('Pruefung abgebrochen: ' + $_.Exception.Message)
    exit 1
}
