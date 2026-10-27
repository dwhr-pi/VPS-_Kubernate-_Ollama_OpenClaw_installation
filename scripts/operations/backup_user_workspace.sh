#!/usr/bin/env bash
# Datei-Backup ohne Shell-Auswertung von Konfiguration und ohne automatische Repository-Anlage.
set -euo pipefail
set +x
umask 077
die() { printf 'Workspace-Backup abgebrochen: %s\n' "$*" >&2; exit 1; }
source_dir=${BACKUP_SOURCE:?Absolutes Quellverzeichnis setzen}
secret_dir=${BACKUP_SECRET_DIR:?Privates Secret-Verzeichnis setzen}
host_id=${BACKUP_HOST_ID:?Stabile eindeutige Host-ID setzen}
repository=${RESTIC_REPOSITORY:?Separates Repository setzen}
restic_bin=${RESTIC_BIN:-restic}
[[ "$source_dir" == /* && -d "$source_dir" && ! -L "$source_dir" && "$source_dir" != / ]] || die 'Keine regulaere absolute Quelle.'
[[ "$secret_dir" == /* && -d "$secret_dir" && ! -L "$secret_dir" ]] || die 'Privates Secret-Verzeichnis fehlt.'
source_dir=$(realpath -e -- "$source_dir")
secret_dir=$(realpath -e -- "$secret_dir")
[[ "$secret_dir/" != "$source_dir/"* && "$source_dir/" != "$secret_dir/"* ]] || die 'Recovery-Secrets muessen ausserhalb des Backup-Quellbaums liegen.'
[[ "$host_id" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]{0,62}$ ]] || die 'Host-ID ungueltig.'
[[ "$repository" == s3:https://* && "$repository" != *[[:space:]]* && "$repository" != *'@'* && "$repository" != *'?'* ]] || die 'Nur S3/HTTPS ohne Zugangsdaten in der URL.'
[[ ${BACKUP_TARGET_IS_EXTERNAL:-0} == 1 ]] || die 'Separates Backup-Ziel bewusst mit BACKUP_TARGET_IS_EXTERNAL=1 bestaetigen.'
[[ ! -e "$source_dir/install_transactions/.runner-lock" ]] || die 'Installation/Sperre aktiv; kein inkonsistentes Installationsinventar sichern.'
command -v "$restic_bin" >/dev/null || die 'Vorhandenes geprueftes Restic erforderlich; kein Download durch den Backupjob.'
for name in password access-key-id secret-access-key; do
  path="$secret_dir/$name"
  [[ -f "$path" && ! -L "$path" && -s "$path" ]] || die 'Erforderliche Secret-Datei fehlt.'
  [[ $(stat -c %a -- "$path") == 600 ]] || die 'Secret-Dateien brauchen Modus 0600.'
  [[ $(stat -c %u -- "$path") == "$EUID" ]] || die 'Secret-Dateien muessen dem Backup-Prozess gehoeren.'
done
# Keine geerbten Restic-Kommandos, Passwort-Hooks oder alternativen AWS-Profile.
unset RESTIC_PASSWORD RESTIC_PASSWORD_COMMAND RESTIC_REPOSITORY_FILE RESTIC_REST_USERNAME RESTIC_REST_PASSWORD
unset AWS_PROFILE AWS_SHARED_CREDENTIALS_FILE AWS_CONFIG_FILE AWS_SESSION_TOKEN
unset AWS_WEB_IDENTITY_TOKEN_FILE AWS_ROLE_ARN AWS_ROLE_SESSION_NAME AWS_CONTAINER_CREDENTIALS_RELATIVE_URI AWS_CONTAINER_CREDENTIALS_FULL_URI AWS_CONTAINER_AUTHORIZATION_TOKEN
export RESTIC_REPOSITORY="$repository"
export RESTIC_PASSWORD_FILE="$secret_dir/password"
AWS_ACCESS_KEY_ID=$(cat -- "$secret_dir/access-key-id")
AWS_SECRET_ACCESS_KEY=$(cat -- "$secret_dir/secret-access-key")
[[ -n "$AWS_ACCESS_KEY_ID" && -n "$AWS_SECRET_ACCESS_KEY" ]] || die 'Leere S3-Zugangsdaten.'
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
export AWS_EC2_METADATA_DISABLED=true
export RESTIC_CACHE_DIR=${RESTIC_CACHE_DIR:-/tmp/restic-cache}
[[ "$RESTIC_CACHE_DIR" == /* ]] || die 'Absoluter Cachepfad erforderlich.'
cache=$(realpath -m -- "$RESTIC_CACHE_DIR")
[[ "$cache/" != "$source_dir/"* ]] || die 'Restic-Cache darf nicht im Quellbaum liegen.'
tag=openclaw-workspace-v1
# Kein init und kein unlock: ein fehlendes/gesperrtes Repository ist ein echter Fehler.
"$restic_bin" cat config >/dev/null
"$restic_bin" backup --host "$host_id" --tag "$tag" -- "$source_dir"
# Exitcode 3 (unlesbare/geaenderte Dateien) beendet den Job vor jeder Retention.
if [[ ${BACKUP_ALLOW_PRUNE:-0} == 1 ]]; then
  [[ ${BACKUP_DEDICATED_REPOSITORY:-0} == 1 ]] || die 'Prune nur im ausdruecklich bestaetigten dedizierten Repository.'
  "$restic_bin" forget --host "$host_id" --tag "$tag" --group-by host,paths,tags \
    --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
  "$restic_bin" check
else
  printf 'Backup erfolgreich; Prune nicht freigegeben.\n'
fi
