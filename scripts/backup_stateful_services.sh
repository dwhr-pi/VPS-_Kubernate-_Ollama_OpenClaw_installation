#!/usr/bin/env bash
# Offline Compose volume backup. Explicit maintenance approval is mandatory.
set -euo pipefail
umask 077

die() {
  printf 'Backup abgebrochen: %s\n' "$*" >&2
  exit 1
}
usage() { printf 'Nutzung: bash %s /absolut/backup.env [--dry-run|--run]\n' "$0"; }
[[ $# -ge 1 && $# -le 2 ]] || {
  usage
  exit 2
}
env_file=$1
mode=${2:---dry-run}
[[ "$mode" == --run || "$mode" == --dry-run ]] || {
  usage
  exit 2
}
[[ "$env_file" == /* && -f "$env_file" && ! -L "$env_file" ]] || die 'Absolute regulaere env-Datei erforderlich.'

secure_file() {
  local file=$1 owner permissions
  [[ -f "$file" && ! -L "$file" ]] || die 'Secret-Datei fehlt oder ist ein Symlink.'
  owner=$(stat -c %u -- "$file")
  permissions=$(stat -c %a -- "$file")
  [[ "$owner" == "$EUID" && "$permissions" == 600 ]] || die 'Secret-Dateien muessen dem ausfuehrenden Benutzer gehoeren und Modus 0600 haben.'
}
secure_file "$env_file"
unset RESTIC_REPOSITORY RESTIC_PASSWORD_FILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION
unset COMPOSE_FILE QDRANT_DATA_DIR POSTGRES_DATA_DIR MINIO_DATA_DIR BACKUP_LOCK_DIR BACKUP_ALLOW_DOWNTIME BACKUP_TARGET_IS_EXTERNAL

# Parse literal KEY=VALUE entries. No source, eval, substitutions or shell expansion.
while IFS= read -r line || [[ -n "$line" ]]; do
  line=${line%$'\r'}
  [[ -z "$line" || "$line" == \#* ]] && continue
  [[ "$line" == *=* ]] || die 'Ungueltige env-Zeile.'
  key=${line%%=*}
  value=${line#*=}
  case "$key" in
    RESTIC_REPOSITORY | RESTIC_PASSWORD_FILE | AWS_ACCESS_KEY_ID | AWS_SECRET_ACCESS_KEY | AWS_SESSION_TOKEN | AWS_DEFAULT_REGION | COMPOSE_FILE | QDRANT_DATA_DIR | POSTGRES_DATA_DIR | MINIO_DATA_DIR | BACKUP_LOCK_DIR | BACKUP_ALLOW_DOWNTIME | BACKUP_TARGET_IS_EXTERNAL) ;;
    *) die 'Nicht erlaubter Variablenname in env-Datei.' ;;
  esac
  if [[ "$value" == \"*\" || "$value" == \'*\' ]]; then
    value=${value:1:${#value}-2}
  fi
  printf -v "$key" '%s' "$value"
  export "${key?}"
done <"$env_file"

for key in RESTIC_REPOSITORY RESTIC_PASSWORD_FILE COMPOSE_FILE QDRANT_DATA_DIR POSTGRES_DATA_DIR MINIO_DATA_DIR BACKUP_LOCK_DIR; do
  [[ -n ${!key:-} ]] || die "Pflichtvariable fehlt: $key"
done
[[ "$RESTIC_REPOSITORY" == s3:https://* ]] || die 'Externes S3-Ziel mit HTTPS erforderlich.'
[[ ! "$RESTIC_REPOSITORY" =~ ^s3:https://(localhost|127\.[0-9.]+|\[::1\]|minio)(:|/) ]] || die 'Primaeres/lokales MinIO ist kein separates Backup-Ziel.'
[[ ${BACKUP_TARGET_IS_EXTERNAL:-0} == 1 ]] || die 'Separates Backup-Ziel muss bestaetigt werden; nicht das zu stoppende MinIO verwenden.'
[[ "$RESTIC_PASSWORD_FILE" == /* ]] || die 'Absoluter Passwortdateipfad erforderlich.'
secure_file "$RESTIC_PASSWORD_FILE"
[[ "$COMPOSE_FILE" == /* && -f "$COMPOSE_FILE" && ! -L "$COMPOSE_FILE" ]] || die 'Absolute Compose-Datei erforderlich.'
for key in QDRANT_DATA_DIR POSTGRES_DATA_DIR MINIO_DATA_DIR; do
  value=${!key}
  [[ "$value" == /* && "$value" != / && -d "$value" && ! -L "$value" ]] || die "Ungueltiges Datenverzeichnis: $key"
  printf -v "$key" '%s' "$(realpath -e -- "$value")"
done
[[ "$QDRANT_DATA_DIR" != "$POSTGRES_DATA_DIR" && "$QDRANT_DATA_DIR" != "$MINIO_DATA_DIR" && "$POSTGRES_DATA_DIR" != "$MINIO_DATA_DIR" ]] || die 'Datenpfade muessen verschieden sein.'
[[ ! -L "$POSTGRES_DATA_DIR/pg_wal" ]] || die 'Externes PostgreSQL-WAL erfordert einen erweiterten Backup-Plan.'
if [[ -d "$POSTGRES_DATA_DIR/pg_tblspc" ]]; then
  [[ -z $(find "$POSTGRES_DATA_DIR/pg_tblspc" -mindepth 1 -maxdepth 1 -print -quit) ]] || die 'Externe PostgreSQL-Tablespaces werden nicht implizit gesichert.'
fi
[[ "$BACKUP_LOCK_DIR" == /* && -d "$BACKUP_LOCK_DIR" && ! -L "$BACKUP_LOCK_DIR" ]] || die 'Eigenes vorab angelegtes Lock-Verzeichnis erforderlich.'
[[ $(stat -c %u -- "$BACKUP_LOCK_DIR") == "$EUID" && $(stat -c %a -- "$BACKUP_LOCK_DIR") == 700 ]] || die 'Lock-Verzeichnis muss eigen und 0700 sein.'

if [[ "$mode" == --dry-run ]]; then
  printf 'Konfiguration lokal geprueft. Keine Docker-/S3-Abfrage, kein Stop, kein Backup ausgefuehrt.\n'
  exit 0
fi
[[ ${BACKUP_ALLOW_DOWNTIME:-0} == 1 ]] || die 'Wartungsfenster mit BACKUP_ALLOW_DOWNTIME=1 freigeben.'
for tool in docker restic flock python3; do command -v "$tool" >/dev/null || die "Werkzeug fehlt: $tool"; done
# Disallow inherited Restic command hooks and alternate credentials/repositories.
unset RESTIC_PASSWORD RESTIC_PASSWORD_COMMAND RESTIC_REPOSITORY_FILE RESTIC_REST_USERNAME RESTIC_REST_PASSWORD
exec 9>"$BACKUP_LOCK_DIR/backup.lock"
flock -n 9 || die 'Ein Backup laeuft bereits.'
compose=(docker compose --file "$COMPOSE_FILE")
services=(postgres minio qdrant)
paths=("$POSTGRES_DATA_DIR" "$MINIO_DATA_DIR" "$QDRANT_DATA_DIR")
destinations=(/var/lib/postgresql/data /data /qdrant/storage)
ids=()
restart_services=()

restore_services() {
  local rc=$?
  trap - EXIT INT TERM
  if ((${#restart_services[@]})); then
    printf 'Stelle zuvor laufende Dienste wieder her.\n'
    if ! "${compose[@]}" start "${restart_services[@]}"; then
      printf 'KRITISCH: Dienststart fehlgeschlagen. Operator muss Dienste pruefen.\n' >&2
      rc=1
    fi
  fi
  exit "$rc"
}
trap restore_services EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Validate actual mounts before stopping anything; never back up arbitrary paths.
for i in "${!services[@]}"; do
  id=$("${compose[@]}" ps --all --quiet "${services[$i]}")
  [[ "$id" =~ ^[a-f0-9]{12,64}$ ]] || die 'Genau ein vorhandener Container je Dienst erforderlich.'
  ids+=("$id")
  mounts=$(docker inspect --format '{{json .Mounts}}' "$id")
  python3 -I -c '
import json, os, sys
mounts = json.loads(sys.argv[1])
matches = [m for m in mounts if m["Destination"] == sys.argv[3]]
if len(matches) != 1 or os.path.realpath(matches[0]["Source"]) != sys.argv[2]:
    raise SystemExit("Backup-Pfad stimmt nicht mit dem Container-Mount ueberein.")
if any(m.get("RW", True) and m.get("Type") in ("bind", "volume")
       and m["Destination"] != sys.argv[3] for m in mounts):
    raise SystemExit("Weitere beschreibbare Mounts erfordern einen erweiterten Backup-Plan.")
' "$mounts" "${paths[$i]}" "${destinations[$i]}"
done

# Check repository access before entering the maintenance window. No automatic init.
restic cat config >/dev/null
for i in "${!services[@]}"; do
  running=$(docker inspect --format '{{.State.Running}}' "${ids[$i]}")
  if [[ "$running" == true ]]; then
    # Register before stop, so an interrupted stop is also recovered by the trap.
    restart_services+=("${services[$i]}")
    "${compose[@]}" stop --timeout 120 "${services[$i]}"
  fi
done
for id in "${ids[@]}"; do
  state=$(docker inspect --format '{{.State.Running}} {{.State.ExitCode}}' "$id")
  [[ "$state" == 'false 0' || "$state" == 'false 143' ]] || die 'Container nicht sauber gestoppt; kein Backup inkonsistenter Dateien.'
done
printf 'Alle drei Datendienste gestoppt; starte verschluesseltes Restic-Backup.\n'
# Exit codes including incomplete reads (3) and storage failures remain failures.
restic backup --tag llmops-offline -- "${paths[@]}"
printf 'Backup erfolgreich. Restore-Probe und restic check separat durchfuehren.\n'
