#!/usr/bin/env bash
set -euo pipefail

# Watches OpenClaw diagnostic reports and creates Codex-ready handoff files.
# Intended for manual use, cron, or Huginn ShellCommandAgent.

USER_DATA_DIR="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
REPORT_DIR="${OPENCLAW_DIAGNOSTIC_REPORT_DIR:-$USER_DATA_DIR/diagnostic_reports}"
STATE_DIR="${OPENCLAW_HUGINN_LOG_WORKTREE_DIR:-$USER_DATA_DIR/huginn_log_worktree}"
HANDOFF_DIR="${OPENCLAW_CODEX_HANDOFF_DIR:-$USER_DATA_DIR/codex_handoffs}"
PROCESSED_FILE="$STATE_DIR/processed_reports.tsv"
MAX_EXCERPT_LINES="${OPENCLAW_LOG_WORKTREE_EXCERPT_LINES:-160}"

mkdir -p "$REPORT_DIR" "$STATE_DIR" "$HANDOFF_DIR"
touch "$PROCESSED_FILE"
chmod 700 "$STATE_DIR" "$HANDOFF_DIR" 2>/dev/null || true
chmod 600 "$PROCESSED_FILE" 2>/dev/null || true

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])'
}

is_processed() {
  local file="$1"
  grep -Fq -- "$file"$'\t' "$PROCESSED_FILE"
}

mark_processed() {
  local file="$1"
  local handoff="$2"
  printf '%s\t%s\t%s\n' "$file" "$(date -Is)" "$handoff" >> "$PROCESSED_FILE"
}

redact_stream() {
  sed -E \
    -e 's/(password|passwd|secret|token|api[_-]?key|authorization|cookie)([[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1\2[REDACTED]/Ig' \
    -e 's/(set-cookie:[[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig' \
    -e 's/(Bearer )[A-Za-z0-9._~+\/=-]+/\1[REDACTED]/g'
}

make_excerpt() {
  local file="$1"
  {
    grep -nE 'Fehler:|Error:|ERROR:?|failed|rake aborted!|LoadError|ArgumentError|ConnectionError|Traceback|Exception|WARN|Hinweis:|systemd|service|curl|HTTP/|assets:precompile|bundle|npm|pnpm|yarn|docker|kubernetes|postgres|mysql|sqlite|grpc|esbuild|password|passwd|secret|token|api[_-]?key|authorization|cookie' "$file" 2>/dev/null \
      | tail -n "$MAX_EXCERPT_LINES" || true
  } | redact_stream
}

create_handoff() {
  local report="$1"
  local base ts handoff
  base="$(basename "$report" .md)"
  ts="$(date +%Y%m%d_%H%M%S)"
  handoff="$HANDOFF_DIR/${ts}_${base}_codex_handoff.md"

  {
    printf '# Codex-Handoff: %s\n\n' "$base"
    printf 'Erstellt: `%s`\n\n' "$(date -Is)"
    printf 'Quelle: `%s`\n\n' "$report"
    printf 'Status: neue Diagnose-/Logdatei wurde erkannt und fuer die Weiterarbeit vorbereitet.\n\n'
    printf '## Aufgabe fuer Codex\n\n'
    printf 'Analysiere diesen Diagnosebericht, fasse die wahrscheinliche Ursache zusammen, pruefe die relevanten Installer-/Setup-Dateien im Repository und schlage einen sicheren Fix vor. Bitte keine Secrets ausgeben und keine Nutzerdateien blind loeschen.\n\n'
    printf '## Wichtige lokale Pfade\n\n'
    printf '%s\n' "- Setup-Repository: \`${OPENCLAW_SETUP_REPO:-$HOME/openclaw_ultimate_setup}\`"
    printf '%s\n' "- Diagnosebericht: \`$report\`"
    printf '%s\n' "- Handoff-Datei: \`$handoff\`"
    printf '%s\n' "- Install-Logs: \`$USER_DATA_DIR/install_logs\`"
    printf '%s\n\n' "- Diagnoseberichte: \`$REPORT_DIR\`"
    printf '## Gefilterter Auszug\n\n'
    printf '```text\n'
    make_excerpt "$report"
    printf '\n```\n\n'
    printf '## Naechste sinnvolle Pruefkommandos\n\n'
    printf '```bash\n'
    printf 'cd "${OPENCLAW_SETUP_REPO:-$HOME/openclaw_ultimate_setup}"\n'
    printf 'bash scripts/tool_log_diagnostics.sh --tool Huginn --no-email\n'
    printf 'bash scripts/huginn_status.sh 2>/dev/null || true\n'
    printf 'git status --short\n'
    printf '```\n\n'
    printf '## Sicherheitsnotiz\n\n'
    printf 'Der Auszug wurde automatisch basis-redigiert. Bitte vor Weitergabe trotzdem pruefen, ob private Pfade, Tokens, Cookies oder Mailadressen enthalten sind.\n'
  } > "$handoff"

  chmod 600 "$handoff" 2>/dev/null || true
  printf '%s' "$handoff"
}

new_count=0
last_report=""
last_handoff=""

while IFS= read -r -d '' report; do
  if is_processed "$report"; then
    continue
  fi
  handoff="$(create_handoff "$report")"
  mark_processed "$report" "$handoff"
  new_count=$((new_count + 1))
  last_report="$report"
  last_handoff="$handoff"
done < <(find "$REPORT_DIR" -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

if [ "$new_count" -eq 0 ]; then
  printf '{"status":"no_new_reports","report_dir":"%s","handoff_dir":"%s"}\n' \
    "$(printf '%s' "$REPORT_DIR" | json_escape)" \
    "$(printf '%s' "$HANDOFF_DIR" | json_escape)"
else
  printf '{"status":"new_reports","count":%s,"latest_report":"%s","latest_handoff":"%s"}\n' \
    "$new_count" \
    "$(printf '%s' "$last_report" | json_escape)" \
    "$(printf '%s' "$last_handoff" | json_escape)"
fi
