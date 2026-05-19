#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
INSTALL_LOG_DIR="${INSTALL_LOG_DIR:-$USER_WORKSPACE_DIR/install_logs}"
REPORT_DIR="${REPORT_DIR:-$USER_WORKSPACE_DIR/diagnostic_reports}"
DEFAULT_EMAIL_TO="${DEFAULT_EMAIL_TO:-ai-chat-to-markdown@web.de}"
LIMIT="${LIMIT:-40}"
EMAIL_MODE="never"
EMAIL_TO="$DEFAULT_EMAIL_TO"

usage() {
  cat <<'EOF'
Installationslauf-Diagnose

Nutzung:
  bash scripts/install_run_diagnostics.sh
  bash scripts/install_run_diagnostics.sh --limit 80
  bash scripts/install_run_diagnostics.sh --email

Erstellt einen Bericht ueber die letzten Installationslogs, Fehler, Speicherorte,
installierte Tool-Statusdateien und grobe Abhaengigkeits-/Cache-Spuren.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --limit)
      LIMIT="${2:-40}"
      shift 2
      ;;
    --email|--send-email)
      EMAIL_MODE="always"
      EMAIL_TO="${2:-$DEFAULT_EMAIL_TO}"
      if [ "${2:-}" != "" ] && [[ "${2:-}" != --* ]]; then
        shift 2
      else
        shift
      fi
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unbekannte Option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/$(date '+%Y%m%d_%H%M%S')_install_run_diagnostics.md"
PATTERN='Hinweis:|Warnung:|Fehler:|ERROR:|Error:|error|failed|fatal|Traceback|Exception|Permission denied|No space left|ENOSPC|ECONNRESET|EAI_AGAIN|ERR_SOCKET_TIMEOUT|ELIFECYCLE|rake aborted!|LoadError|ConnectionError|not found|No such file'
MAIL_SETTINGS_FILE="${MAIL_SETTINGS_FILE:-$USER_WORKSPACE_DIR/mail/mail_settings.env}"

redact() {
  sed -E \
    -e 's/([?&](token|key|secret|password|passwd|api_key)=)[^&[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/((token|secret|password|passwd|api_key)[=:][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(set-cookie:[[:space:]]*)[^[:space:];]+/\1[REDACTED_COOKIE]/Ig'
}

human_du() {
  local path="$1"
  [ -e "$path" ] || return 0
  if command -v timeout >/dev/null 2>&1; then
    timeout 4s du -sh "$path" 2>/dev/null || echo "timeout/kein Zugriff: $path"
  else
    du -sh "$path" 2>/dev/null || true
  fi
}

infer_status() {
  local log_file="$1"
  local tail_success="false"
  if tail -n 160 "$log_file" | grep -qiE 'Status:[[:space:]]*success|erfolgreich installiert|erfolgreich deinstalliert|Installation abgeschlossen|wurde erfolgreich vorbereitet|Build ist vorhanden|Ruflo CLI-Build ist vorhanden|Bundle complete|success'; then
    tail_success="true"
  fi

  if grep -qiE 'Status:[[:space:]]*failed|Fehler bei der Installation|Fehler bei der Deinstallation|FEHLER:|fatal|Traceback|Exception|Permission denied|No space left|ENOSPC|Lifecycle script .* failed|Command failed' "$log_file"; then
    if [ "$tail_success" = "true" ]; then
      echo "success_with_old_warnings"
    else
      echo "failed_or_warning"
    fi
  elif grep -qiE 'failed|WARN|Warnung|warning' "$log_file"; then
    if [ "$tail_success" = "true" ]; then
      echo "success_with_warnings"
    else
      echo "warning"
    fi
  elif grep -qiE 'Status:[[:space:]]*success|erfolgreich installiert|erfolgreich deinstalliert|Installation abgeschlossen|wurde erfolgreich vorbereitet|Build ist vorhanden|success' "$log_file"; then
    echo "success"
  else
    echo "unknown"
  fi
}

extract_log_subject() {
  local name
  name="$(basename "$1" .log)"
  name="${name#????????_??????_}"
  name="${name#main_menu_}"
  name="${name#tool_install_}"
  name="${name#tool_uninstall_}"
  name="${name#profile_install_}"
  name="${name#profile_uninstall_}"
  printf '%s\n' "$name" | tr '[:upper:]' '[:lower:]'
}

status_rank() {
  case "$1" in
    success) echo 0 ;;
    success_with_warnings|success_with_old_warnings) echo 1 ;;
    warning) echo 2 ;;
    unknown) echo 3 ;;
    failed_or_warning) echo 4 ;;
    *) echo 5 ;;
  esac
}

status_note() {
  case "$1" in
    success) echo "letzter Lauf erfolgreich" ;;
    success_with_warnings) echo "letzter Lauf erfolgreich, aber mit Warnungen" ;;
    success_with_old_warnings) echo "letzter Lauf erfolgreich; alte Fehler/Warnungen im Log wurden ueberholt" ;;
    warning) echo "Warnung ohne klares Erfolgssignal" ;;
    failed_or_warning) echo "letzter Lauf fehlgeschlagen oder kritisch" ;;
    unknown) echo "kein klares Ergebnis erkannt" ;;
    *) echo "unbekannt" ;;
  esac
}

list_current_subject_status() {
  local tmp_file subject log_file status mtime metric
  tmp_file="$(mktemp)"
  list_recent_logs | while IFS= read -r log_file; do
    [ -n "$log_file" ] || continue
    subject="$(extract_log_subject "$log_file")"
    if ! grep -Fq "${subject}|" "$tmp_file" 2>/dev/null; then
      status="$(infer_status "$log_file")"
      mtime="$(date -r "$log_file" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo unbekannt)"
      metric="$(grep -E 'Messwert gespeichert:|Status:' "$log_file" | tail -n 1 | redact | sed 's/|/\\|/g' || true)"
      printf '%s|%s|%s|%s|%s\n' "$subject" "$status" "$mtime" "$log_file" "${metric:-kein Messwert gefunden}" >> "$tmp_file"
    fi
  done
  sort "$tmp_file"
  rm -f "$tmp_file"
}

list_superseded_failures() {
  local tmp_latest tmp_failed subject log_file status rank latest_status latest_rank latest_log
  tmp_latest="$(mktemp)"
  tmp_failed="$(mktemp)"

  list_current_subject_status > "$tmp_latest"
  list_recent_logs | while IFS= read -r log_file; do
    [ -n "$log_file" ] || continue
    subject="$(extract_log_subject "$log_file")"
    status="$(infer_status "$log_file")"
    [ "$status" = "failed_or_warning" ] || continue
    latest_status="$(awk -F'|' -v s="$subject" '$1 == s {print $2; exit}' "$tmp_latest")"
    latest_log="$(awk -F'|' -v s="$subject" '$1 == s {print $4; exit}' "$tmp_latest")"
    [ -n "$latest_status" ] || continue
    [ "$latest_log" != "$log_file" ] || continue
    rank="$(status_rank "$status")"
    latest_rank="$(status_rank "$latest_status")"
    if [ "$latest_rank" -lt "$rank" ]; then
      printf '%s|%s|%s|%s\n' "$subject" "$(basename "$log_file")" "$latest_status" "$(basename "$latest_log")" >> "$tmp_failed"
    fi
  done

  sort -u "$tmp_failed"
  rm -f "$tmp_latest" "$tmp_failed"
}

send_report_email() {
  local report_file="$1"
  local recipient="$2"
  local subject="[OpenClaw Setup] Installationslauf-Diagnose $(date '+%Y-%m-%d %H:%M')"

  if [ -f "$MAIL_SETTINGS_FILE" ]; then
    # shellcheck disable=SC1090
    source "$MAIL_SETTINGS_FILE"
  fi

  if command -v msmtp >/dev/null 2>&1 && [ -n "${MAIL_FROM:-}" ]; then
    {
      printf 'From: %s\n' "$MAIL_FROM"
      printf 'To: %s\n' "$recipient"
      printf 'Subject: %s\n' "$subject"
      printf 'Content-Type: text/plain; charset=UTF-8\n'
      printf '\n'
      cat "$report_file"
    } | msmtp -a "${MSMTP_ACCOUNT:-default}" -f "$MAIL_FROM" "$recipient"
    return $?
  fi

  if command -v mail >/dev/null 2>&1; then
    if [ -n "${MAIL_FROM:-}" ]; then
      mail -r "$MAIL_FROM" -s "$subject" "$recipient" < "$report_file"
    else
      mail -s "$subject" "$recipient" < "$report_file"
    fi
    return $?
  fi

  echo "E-Mail-Versand nicht moeglich: msmtp/mail fehlt oder MAIL_FROM ist nicht gesetzt." >&2
  return 1
}

list_recent_logs() {
  find "$INSTALL_LOG_DIR" -maxdepth 1 -type f -name '*.log' -printf '%T@ %p\n' 2>/dev/null |
    sort -nr |
    head -n "$LIMIT" |
    awk '{sub(/^[^ ]+ /, ""); print}'
}

{
  echo "# Installationslauf-Diagnose"
  echo
  echo "- Datum: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "- Repo: $ROOT_DIR"
  echo "- Installationslogs: $INSTALL_LOG_DIR"
  echo "- Limit: $LIMIT Logs"
  echo

  echo "## Kurzfazit"
  total=0
  failed=0
  success=0
  unknown=0
  while IFS= read -r log_file; do
    [ -n "$log_file" ] || continue
    total=$((total + 1))
    status="$(infer_status "$log_file")"
    case "$status" in
      failed_or_warning|warning) failed=$((failed + 1)) ;;
      success|success_with_warnings|success_with_old_warnings) success=$((success + 1)) ;;
      *) unknown=$((unknown + 1)) ;;
    esac
  done < <(list_recent_logs)
  echo
  echo "- Gepruefte Logs: $total"
  echo "- Erfolgreich wirkend: $success"
  echo "- Fehler/Warnung erkannt: $failed"
  echo "- Unklar: $unknown"
  echo

  echo "## Aktueller Status je Tool oder Aktion"
  echo
  echo "Diese Tabelle zeigt pro Tool/Aktion nur den neuesten Log. Aeltere Fehler desselben Tools sind darunter als Historie eingeordnet."
  echo
  echo "| Tool/Aktion | Aktueller Status | Bedeutung | Zeit | Neuester Log | Messwertzeile |"
  echo "|---|---|---|---|---|---|"
  while IFS='|' read -r subject status mtime log_file metric; do
    [ -n "$subject" ] || continue
    echo "| $subject | $status | $(status_note "$status") | $mtime | \`$log_file\` | ${metric:-kein Messwert gefunden} |"
  done < <(list_current_subject_status)
  echo

  superseded="$(list_superseded_failures)"
  if [ -n "$superseded" ]; then
    echo "## Alte Fehler, die durch spaetere Logs ueberholt sind"
    echo
    echo "| Tool/Aktion | Alter Fehlerlog | Neuerer Status | Neuerer Log |"
    echo "|---|---|---|---|"
    while IFS='|' read -r subject old_log latest_status latest_log; do
      [ -n "$subject" ] || continue
      echo "| $subject | \`$old_log\` | $latest_status | \`$latest_log\` |"
    done <<< "$superseded"
    echo
  fi

  echo "## Letzte Installationslogs"
  echo
  echo "| Zeit | Status | Datei | Messwertzeile |"
  echo "|---|---|---|---|"
  while IFS= read -r log_file; do
    [ -n "$log_file" ] || continue
    mtime="$(date -r "$log_file" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo unbekannt)"
    status="$(infer_status "$log_file")"
    metric="$(grep -E 'Messwert gespeichert:|Status:' "$log_file" | tail -n 1 | redact | sed 's/|/\\|/g' || true)"
    echo "| $mtime | $status | \`$log_file\` | ${metric:-kein Messwert gefunden} |"
  done < <(list_recent_logs)
  echo

  echo "## Fehlerauszuege je Log"
  while IFS= read -r log_file; do
    [ -n "$log_file" ] || continue
    echo
    echo "### $(basename "$log_file")"
    echo
    if grep -nE "$PATTERN" "$log_file" | tail -n 80 | redact; then
      true
    else
      echo "Keine Diagnose-Treffer. Letzte 20 Zeilen:"
      tail -n 20 "$log_file" | redact
    fi
  done < <(list_recent_logs)
  echo

  echo "## Statusdateien"
  echo
  for f in "$USER_WORKSPACE_DIR/status/installed_tools.txt" "$USER_WORKSPACE_DIR/status/installed_profiles.txt" "$ROOT_DIR/installed_tools.txt" "$ROOT_DIR/installed_profiles.txt"; do
    if [ -f "$f" ]; then
      echo "### $f"
      sed '/^[[:space:]]*$/d' "$f" | sort | sed 's/^/- /'
      echo
    fi
  done

  echo "## Speicheruebersicht"
  echo
  df -h "$HOME" "$ROOT_DIR" 2>/dev/null || df -h
  echo
  echo "### Grobe Verzeichnisgroessen"
  for p in \
    /opt \
    "$HOME/.cache" \
    "$HOME/.npm" \
    "$HOME/.pnpm-store" \
    "$HOME/.local/share/pnpm" \
    "$HOME/.cache/pip" \
    "$HOME/.cache/huggingface" \
    "$HOME/.cache/torch" \
    "$HOME/.ollama" \
    "$HOME/ai-stack" \
    "$USER_WORKSPACE_DIR"; do
    human_du "$p"
  done | sort -h
  echo

  echo "## /opt Einzeluebersicht"
  if [ -d /opt ]; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s sh -c 'du -sh /opt/* 2>/dev/null | sort -h | tail -n 80' || echo "Timeout bei /opt Einzeluebersicht."
    else
      du -sh /opt/* 2>/dev/null | sort -h | tail -n 80 || true
    fi
  fi
  echo

  echo "## Paket-/Abhaengigkeits-Snapshot"
  echo
  echo "### Apt manuell installiert, letzte 80"
  if command -v apt-mark >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s apt-mark showmanual 2>/dev/null | tail -n 80 || echo "Timeout bei apt-mark showmanual."
    else
      apt-mark showmanual 2>/dev/null | tail -n 80 || true
    fi
  else
    echo "apt-mark nicht verfuegbar."
  fi
  echo
  echo "### Python venvs unter /opt"
  if command -v timeout >/dev/null 2>&1; then
    timeout 5s find /opt -maxdepth 3 -type f -path '*/venv/bin/python' 2>/dev/null || true
  else
    find /opt -maxdepth 3 -type f -path '*/venv/bin/python' 2>/dev/null || true
  fi | sort | while read -r py; do
    venv_dir="$(dirname "$(dirname "$py")")"
    if command -v timeout >/dev/null 2>&1; then
      count="$(timeout 4s "$py" -m pip freeze 2>/dev/null | wc -l | tr -d ' ')"
    else
      count="$("$py" -m pip freeze 2>/dev/null | wc -l | tr -d ' ')"
    fi
    echo "- $venv_dir: $count pip-Pakete"
  done || true
  echo
  echo "### Node/npm/pnpm"
  command -v node >/dev/null 2>&1 && node --version || true
  command -v npm >/dev/null 2>&1 && npm --version || true
  command -v pnpm >/dev/null 2>&1 && pnpm --version || true
  if command -v npm >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s npm list -g --depth=0 2>/dev/null | tail -n 80 || echo "Timeout bei npm global list."
    else
      npm list -g --depth=0 2>/dev/null | tail -n 80 || true
    fi
  fi
  echo
  echo "### Container"
  if command -v docker >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 5s docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' 2>/dev/null || true
      timeout 5s docker system df 2>/dev/null || true
    else
      docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' 2>/dev/null || true
      docker system df 2>/dev/null || true
    fi
  elif command -v podman >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 5s podman images 2>/dev/null || true
      timeout 5s podman system df 2>/dev/null || true
    else
      podman images 2>/dev/null || true
      podman system df 2>/dev/null || true
    fi
  else
    echo "Docker/Podman nicht verfuegbar."
  fi
  echo

  echo "## Naechste sinnvolle Befehle"
  echo
  echo '```bash'
  echo 'bash scripts/last_install_log.sh --failed'
  echo 'bash scripts/install_run_diagnostics.sh --limit 80'
  echo 'bash scripts/dependency_snapshot.sh'
  echo 'du -sh /opt/* ~/.cache ~/.ollama ~/ai-stack ~/.openclaw_ultimate_user_data 2>/dev/null | sort -h'
  echo '```'
} > "$REPORT_FILE"

echo "Installationslauf-Diagnose erstellt: $REPORT_FILE"
sed -n '1,80p' "$REPORT_FILE"

if [ "$EMAIL_MODE" = "always" ]; then
  if send_report_email "$REPORT_FILE" "$EMAIL_TO"; then
    echo "Installationslauf-Diagnose wurde an $EMAIL_TO uebergeben."
  else
    echo "E-Mail-Versand fehlgeschlagen. Vollbericht bleibt lokal: $REPORT_FILE"
  fi
fi
