#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

section() {
    printf '\n== %s ==\n' "$1"
}

command_exists_fast() {
    local cmd="$1"
    [ -x "/usr/bin/$cmd" ] || [ -x "/usr/local/bin/$cmd" ] || timeout 2 bash -lc "command -v '$cmd' >/dev/null 2>&1"
}

section "Registry"
bash scripts/validate_config.sh
bash scripts/check_profiles.sh
bash scripts/check_ports.sh

section "Umgebung"
command_exists_fast docker && echo "OK docker gefunden" || echo "Hinweis: docker nicht gefunden"
command_exists_fast podman && echo "OK podman gefunden" || echo "Hinweis: podman nicht gefunden"
command_exists_fast node && timeout 3 node --version || echo "Hinweis: node nicht gefunden"
command_exists_fast pnpm && timeout 3 pnpm --version || echo "Hinweis: pnpm nicht gefunden"

if command -v systemctl >/dev/null 2>&1; then
    timeout 5 systemctl is-system-running || true
else
    echo "Hinweis: systemctl nicht verfuegbar."
fi

section "Lokale Dienste"
if command_exists_fast curl; then
    curl --max-time 3 -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && echo "OK Ollama erreichbar" || echo "Hinweis: Ollama auf 127.0.0.1:11434 nicht erreichbar"
    curl --max-time 3 -fsSI http://127.0.0.1:3000 >/dev/null 2>&1 && echo "OK Open WebUI/OpenClaw-Port 3000 antwortet" || echo "Hinweis: Port 3000 antwortet nicht"
fi

section "Secret-Hygiene"
if command_exists_fast git; then
    secret_scan_status=0
    timeout 20 git grep -nE '(sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|password *= *[^<\"'\"' ]{8,})' -- ':!*.png' ':!*.jpg' ':!*.svg' >/tmp/openclaw_secret_scan.txt 2>/dev/null || secret_scan_status=$?
    if [ "$secret_scan_status" -eq 0 ]; then
        echo "WARNUNG: Moegliche Secrets gefunden. Details:"
        cat /tmp/openclaw_secret_scan.txt
        exit 1
    elif [ "$secret_scan_status" -eq 124 ]; then
        echo "Hinweis: Secret-Scan wurde nach 20 Sekunden abgebrochen. Fuer tiefe Pruefung bitte gitleaks nutzen."
    else
        echo "OK: Keine offensichtlichen Secrets im Git-Textbestand gefunden."
    fi
fi

section "Fertig"
echo "Doctor abgeschlossen."
