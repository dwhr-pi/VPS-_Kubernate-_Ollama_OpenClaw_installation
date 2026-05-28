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
if command_exists_fast docker; then
    timeout 5 docker info >/dev/null 2>&1 && echo "OK docker nutzbar" || echo "Hinweis: docker gefunden, aber fuer aktuellen User nicht direkt nutzbar"
fi
command_exists_fast podman && echo "OK podman gefunden" || echo "Hinweis: podman nicht gefunden"
command_exists_fast node && timeout 3 node --version || echo "Hinweis: node nicht gefunden"
command_exists_fast pnpm && timeout 3 pnpm --version || echo "Hinweis: pnpm nicht gefunden"
command_exists_fast corepack && timeout 3 corepack --version || echo "Hinweis: corepack nicht gefunden"
command_exists_fast python3 && timeout 3 python3 --version || echo "Hinweis: python3 nicht gefunden"
command_exists_fast pipx && timeout 3 pipx --version || echo "Hinweis: pipx nicht gefunden"
command_exists_fast gh && timeout 3 gh --version | head -n 1 || echo "Hinweis: GitHub CLI nicht gefunden"
python3 -m venv --help >/dev/null 2>&1 && echo "OK python venv verfuegbar" || echo "Hinweis: python3-venv fehlt oder ist defekt"

if grep -qiE "microsoft|wsl" /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
    echo "OK WSL2/WSL-Umgebung erkannt"
else
    echo "Hinweis: Keine WSL-Umgebung erkannt"
fi

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

section "OpenClaw"
if [ -d "$HOME/.openclaw_ultimate_user_data" ]; then
    echo "OK User-Workspace vorhanden: $HOME/.openclaw_ultimate_user_data"
else
    echo "Hinweis: User-Workspace fehlt noch."
fi
if [ -d /opt/openclaw ] || [ -f "$HOME/.openclaw_ultimate_user_data/openclaw/.env" ]; then
    echo "OK OpenClaw-Installation oder Konfiguration gefunden"
else
    echo "Hinweis: OpenClaw-Konfiguration nicht gefunden"
fi

section "Speicher"
free_mb="$(df -Pm / 2>/dev/null | awk 'NR==2 {print $4}')"
echo "Freier Linux-/WSL-Speicher: ${free_mb:-unbekannt} MB"
if [ -n "${free_mb:-}" ] && [ "$free_mb" -lt 20480 ] 2>/dev/null; then
    echo "WARNUNG: Weniger als 20 GB frei. Schwere Installationen vermeiden."
fi

section "Ports"
bash scripts/check_ports.sh || echo "WARNUNG: Portcheck meldet Probleme"

section "Markdown"
if command_exists_fast npx; then
    timeout 60 npx --yes markdown-link-check readme.md >/tmp/openclaw_markdown_links.txt 2>&1 && echo "OK README Links" || echo "Hinweis: markdown-link-check fuer README meldet Hinweise oder ist nicht verfuegbar"
else
    echo "Hinweis: npx fehlt; Markdown-Linkcheck uebersprungen"
fi

section "Registry Sync"
bash scripts/check_profile_registry_sync.sh || echo "WARNUNG: Profile/Tools Registry-Sync meldet Hinweise oder Fehler"

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
