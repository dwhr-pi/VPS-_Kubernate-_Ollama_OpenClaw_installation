#!/bin/bash
# ==============================================================================
# CLEANUP_SETUP_LOGS.SH - Sichere Rotation alter Setup- und Diagnose-Logs
# ==============================================================================

set -euo pipefail

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-${HOME}/.openclaw_ultimate_user_data}"
RETENTION_DAYS="${LOG_CLEANUP_RETENTION_DAYS:-14}"
KEEP_RECENT="${LOG_CLEANUP_KEEP_RECENT:-30}"
APPLY=false
FAILED_ONLY=false

usage() {
    cat <<'EOF'
Usage:
  cleanup_setup_logs.sh [--dry-run|--apply] [--days N] [--keep N] [--failed-only]

Bereinigt nur Dateien im Benutzer-Workspace:
  ~/.openclaw_ultimate_user_data/install_logs/*.log
  ~/.openclaw_ultimate_user_data/diagnostic_reports/*.md

Standard ist --dry-run. Es werden immer die neuesten N Dateien je Ordner behalten.
Mit --failed-only werden nur Installationslogs geloescht, die bekannte Fehler-
oder Warnmuster enthalten. Diagnoseberichte bleiben dabei unangetastet.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --apply)
            APPLY=true
            shift
            ;;
        --dry-run)
            APPLY=false
            shift
            ;;
        --days)
            RETENTION_DAYS="${2:-}"
            shift 2
            ;;
        --keep)
            KEEP_RECENT="${2:-}"
            shift 2
            ;;
        --failed-only)
            FAILED_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unbekannte Option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

case "$RETENTION_DAYS" in
    ''|*[!0-9]*)
        echo "Fehler: --days muss eine Zahl sein." >&2
        exit 2
        ;;
esac

case "$KEEP_RECENT" in
    ''|*[!0-9]*)
        echo "Fehler: --keep muss eine Zahl sein." >&2
        exit 2
        ;;
esac

workspace_real="$(realpath -m "$USER_WORKSPACE_DIR")"
deleted_count=0
candidate_count=0

cleanup_dir() {
    local target_dir="$1"
    local pattern="$2"
    local target_real
    local file
    local file_real
    local cutoff_epoch
    local file_epoch
    local recent_list

    [ -d "$target_dir" ] || return 0
    target_real="$(realpath -m "$target_dir")"

    case "$target_real" in
        "$workspace_real"/*) ;;
        *)
            echo "Sicherheitsabbruch: Ziel liegt nicht im Benutzer-Workspace: $target_real" >&2
            return 1
            ;;
    esac

    echo
    echo "Pruefe: $target_real"
    echo "Regel: aelter als ${RETENTION_DAYS} Tage, aber neueste ${KEEP_RECENT} Dateien behalten"

    cutoff_epoch="$(date -d "${RETENTION_DAYS} days ago" +%s)"
    recent_list="$(mktemp)"
    find "$target_real" -maxdepth 1 -type f -name "$pattern" -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr \
        | head -n "$KEEP_RECENT" \
        | cut -d' ' -f2- > "$recent_list"

    while IFS= read -r file; do
        [ -n "$file" ] || continue
        file_real="$(realpath -m "$file")"
        case "$file_real" in
            "$target_real"/*) ;;
            *)
                echo "Ueberspringe unsicheren Pfad: $file_real" >&2
                continue
                ;;
        esac

        if grep -Fxq "$file_real" "$recent_list"; then
            continue
        fi

        if [ "$FAILED_ONLY" = true ]; then
            case "$target_real" in
                */install_logs) ;;
                *) continue ;;
            esac
            if ! grep -qiE 'Status:[[:space:]]*failed|Fehler bei der Installation|Fehler bei der Deinstallation|FEHLER:|failed|fatal|Traceback|Exception|Permission denied|No space left|ENOSPC|rake aborted!|ELIFECYCLE|ECONNRESET|EAI_AGAIN|ERR_SOCKET_TIMEOUT' "$file_real"; then
                continue
            fi
        fi

        file_epoch="$(stat -c '%Y' "$file_real" 2>/dev/null || echo 0)"
        if [ "$file_epoch" -le "$cutoff_epoch" ]; then
            candidate_count=$((candidate_count + 1))
            if [ "$APPLY" = true ]; then
                rm -f -- "$file_real"
                deleted_count=$((deleted_count + 1))
                echo "Geloescht: $file_real"
            else
                echo "Wuerde loeschen: $file_real"
            fi
        fi
    done < <(find "$target_real" -maxdepth 1 -type f -name "$pattern" -printf '%p\n' 2>/dev/null)

    rm -f "$recent_list"
}

cleanup_dir "$USER_WORKSPACE_DIR/install_logs" "*.log"
if [ "$FAILED_ONLY" != true ]; then
    cleanup_dir "$USER_WORKSPACE_DIR/diagnostic_reports" "*.md"
fi

echo
if [ "$APPLY" = true ]; then
    echo "Log-Aufraeumung abgeschlossen. Kandidaten: $candidate_count, geloescht: $deleted_count"
else
    echo "Trockenlauf abgeschlossen. Loesch-Kandidaten: $candidate_count"
fi
