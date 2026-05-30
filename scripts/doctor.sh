#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

section() {
    printf '\n== %s ==\n' "$1"
}

command_exists_fast() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

run_version_if_exists() {
    local cmd="$1"
    shift
    if command_exists_fast "$cmd"; then
        timeout 3 "$cmd" "$@" || echo "Hinweis: $cmd gefunden, aber Versionsabfrage fehlgeschlagen"
    else
        echo "Hinweis: $cmd nicht gefunden"
    fi
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
if command_exists_fast podman; then
    timeout 5 podman info >/dev/null 2>&1 && echo "OK podman nutzbar" || echo "Hinweis: podman gefunden, aber nicht nutzbar"
fi
if command_exists_fast k3s; then
    timeout 5 k3s --version | head -n 1 || true
else
    echo "Hinweis: k3s nicht gefunden"
fi
if command_exists_fast node; then
    run_version_if_exists node --version
    run_version_if_exists pnpm --version
    run_version_if_exists corepack --version
else
    echo "Hinweis: node nicht gefunden"
    echo "Hinweis: pnpm/corepack werden uebersprungen, weil Node fehlt oder nur Windows-Shims vorhanden sind"
fi
run_version_if_exists python3 --version
run_version_if_exists pipx --version
if command_exists_fast gh; then timeout 3 gh --version | sed -n '1p' || true; else echo "Hinweis: GitHub CLI nicht gefunden"; fi
run_version_if_exists go version
if command_exists_fast make; then timeout 3 make --version | sed -n '1p' || true; else echo "Hinweis: make nicht gefunden"; fi
run_version_if_exists helm version --short
if command_exists_fast kubectl; then timeout 3 kubectl version --client=true 2>/dev/null | sed -n '1p' || true; else echo "Hinweis: kubectl nicht gefunden"; fi
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
if command_exists_fast free; then
    free -h || true
fi
if [ -n "${free_mb:-}" ] && [ "$free_mb" -lt 20480 ] 2>/dev/null; then
    echo "WARNUNG: Weniger als 20 GB frei. Schwere Installationen vermeiden."
fi

section "Git und Installationsstatus"
if command_exists_fast git; then
    timeout 20 git status --short --untracked-files=no || echo "Hinweis: Git-Status nicht verfuegbar oder Timeout"
fi
if [ -f installed_profiles.txt ]; then
    echo "Installierte Profile:"
    sed -n '1,40p' installed_profiles.txt
else
    echo "Hinweis: installed_profiles.txt nicht gefunden"
fi
if [ -f installed_tools.txt ]; then
    echo "Installierte Tools:"
    sed -n '1,40p' installed_tools.txt
else
    echo "Hinweis: installed_tools.txt nicht gefunden"
fi

section "Gefaehrliche Rechte"
rights_tmp="$(mktemp)"
timeout 20 find . -path ./.git -prune -o -type f -perm -0002 -print > "$rights_tmp" 2>/dev/null || true
if [ -s "$rights_tmp" ]; then
    sed -n '1,20p' "$rights_tmp"
else
    echo "OK: Keine world-writable Dateien in schneller Stichprobe gefunden"
fi
rm -f "$rights_tmp"

section "Ports"
bash scripts/check_ports.sh || echo "WARNUNG: Portcheck meldet Probleme"

section "Markdown"
if command_exists_fast node && command_exists_fast npx; then
    timeout 30 npx --yes markdown-link-check readme.md >/tmp/openclaw_markdown_links.txt 2>&1 && echo "OK README Links" || echo "Hinweis: markdown-link-check fuer README meldet Hinweise oder ist nicht verfuegbar"
else
    echo "Hinweis: node/npx fehlt; Markdown-Linkcheck uebersprungen"
fi

section "Registry Sync"
if command_exists_fast git && git status --short >/tmp/openclaw_doctor_git_status.txt 2>&1; then
    timeout 20 bash scripts/check_profile_registry_sync.sh || echo "WARNUNG: Profile/Tools Registry-Sync meldet Hinweise, Fehler oder Timeout"
else
    if grep -qi "dubious ownership" /tmp/openclaw_doctor_git_status.txt 2>/dev/null; then
        echo "Hinweis: Git meldet dubious ownership auf diesem Windows/WSL-Pfad. Registry-Sync uebersprungen."
        echo "Optionaler manueller Fix: git config --global --add safe.directory $ROOT_DIR"
    else
        echo "Hinweis: Git-Status nicht verfuegbar; Registry-Sync uebersprungen."
    fi
fi

section "Secret-Hygiene"
if [ -x scripts/check_secrets.sh ]; then
    timeout 45 bash scripts/check_secrets.sh --dry-run || echo "WARNUNG: Secret-Check meldet Hinweise oder Timeout"
else
    echo "Hinweis: scripts/check_secrets.sh fehlt"
fi

section "Fertig"
echo "Doctor abgeschlossen."
