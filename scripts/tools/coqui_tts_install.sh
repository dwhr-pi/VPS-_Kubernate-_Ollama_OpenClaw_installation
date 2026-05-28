#!/bin/bash
set -euo pipefail

TOOL_NAME="Coqui_TTS"
TOOL_KEY="Coqui_TTS"
TOOL_SLUG="coqui_tts"
TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
TOOL_PACKAGES="TTS==0.22.0"
TOOL_DESCRIPTION="Lokale Text-to-Speech Pipeline für Voiceover, Assistenzsysteme und Content-Automation."
TOOL_OPENCLAW_NOTE="Ergänzt Audio- und Content-Automation-Profile mit lokaler Sprachsynthese."
TOOL_PROMPT_EXAMPLE='```txt
Erzeuge ein deutschsprachiges Voiceover für ein Video-Skript und gib die empfohlenen Syntheseparameter aus.
```'
COQUI_MIN_LINUX_FREE_MB="${COQUI_MIN_LINUX_FREE_MB:-8192}"
COQUI_MIN_WINDOWS_FREE_MB="${COQUI_MIN_WINDOWS_FREE_MB:-20480}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/python_tool_common.sh
source "$SCRIPT_DIR/helpers/python_tool_common.sh"

free_mb_for_path() {
    df -Pm "${1:-/}" 2>/dev/null | awk 'NR==2 {print $4}'
}

python_is_coqui_compatible() {
    local python_bin="$1"
    "$python_bin" - <<'PY'
import sys
raise SystemExit(0 if (3, 9) <= sys.version_info[:2] < (3, 12) else 1)
PY
}

python_has_venv() {
    local python_bin="$1"
    "$python_bin" -m venv --help >/dev/null 2>&1
}

select_coqui_python() {
    local candidate

    if [ -n "${TOOL_PYTHON:-}" ]; then
        if command -v "$TOOL_PYTHON" >/dev/null 2>&1 && python_is_coqui_compatible "$TOOL_PYTHON" && python_has_venv "$TOOL_PYTHON"; then
            echo "$TOOL_PYTHON"
            return 0
        fi
        echo -e "${RED}Fehler: TOOL_PYTHON=${TOOL_PYTHON} ist fuer Coqui_TTS nicht geeignet oder hat kein venv-Modul.${NC}"
        return 1
    fi

    for candidate in python3.11 python3.10 python3.9; do
        if command -v "$candidate" >/dev/null 2>&1 && python_is_coqui_compatible "$candidate" && python_has_venv "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

preflight_coqui_tts() {
    local linux_free_mb
    local windows_free_mb
    local selected_python

    linux_free_mb="$(free_mb_for_path /)"
    echo -e "${BLUE}Coqui_TTS benoetigt Python >=3.9 und <3.12. Ubuntu 24.04 liefert standardmaessig Python 3.12, das fuer das PyPI-Paket TTS nicht passt.${NC}"
    echo -e "${BLUE}Freier Linux-/WSL-Speicher: ${linux_free_mb:-unbekannt} MB${NC}"

    if [ -n "$linux_free_mb" ] && [ "$linux_free_mb" -lt "$COQUI_MIN_LINUX_FREE_MB" ]; then
        echo -e "${RED}Fehler: Zu wenig Linux-/WSL-Speicher fuer Coqui_TTS. Benoetigt mindestens ${COQUI_MIN_LINUX_FREE_MB} MB.${NC}"
        return 1
    fi

    if [ -d /mnt/c ]; then
        windows_free_mb="$(free_mb_for_path /mnt/c || true)"
        echo -e "${BLUE}Freier Windows-Host-Speicher (C:): ${windows_free_mb:-unbekannt} MB${NC}"
        if [ -n "$windows_free_mb" ] && [ "$windows_free_mb" -lt "$COQUI_MIN_WINDOWS_FREE_MB" ]; then
            echo -e "${RED}Fehler: Zu wenig Windows-Host-Speicher fuer Coqui_TTS unter WSL.${NC}"
            echo -e "${YELLOW}Aktuell sind nur ${windows_free_mb} MB auf C: frei. Coqui/Torch-Abhaengigkeiten koennen mehrere GB ziehen und die WSL-VHDX weiter wachsen lassen.${NC}"
            echo -e "${YELLOW}Empfehlung: erst Speicher freigeben oder Piper als leichteren lokalen TTS-Pfad verwenden.${NC}"
            return 1
        fi
    fi

    if ! selected_python="$(select_coqui_python)"; then
        echo -e "${RED}Fehler: Kein kompatibles Python fuer Coqui_TTS gefunden.${NC}"
        echo -e "${YELLOW}Erforderlich: Python 3.9, 3.10 oder 3.11 mit venv-Modul. Gefundenes Standard-python3 ist vermutlich Python 3.12.${NC}"
        echo -e "${YELLOW}Coqui_TTS bleibt deshalb optional/experimental. Stabilerer lokaler TTS-Pfad: Piper.${NC}"
        return 1
    fi

    TOOL_PYTHON="$selected_python"
    echo -e "${GREEN}Nutze Python fuer Coqui_TTS: $("$TOOL_PYTHON" --version 2>&1)${NC}"

    if [ -x "${TOOL_DIR}/venv/bin/python" ] && ! python_is_coqui_compatible "${TOOL_DIR}/venv/bin/python"; then
        echo -e "${YELLOW}Vorhandene Coqui_TTS-venv nutzt inkompatibles Python. Erstelle die venv mit ${TOOL_PYTHON} neu.${NC}"
        rm -rf "${TOOL_DIR}/venv"
    fi
}

preflight_coqui_tts
install_python_tool
