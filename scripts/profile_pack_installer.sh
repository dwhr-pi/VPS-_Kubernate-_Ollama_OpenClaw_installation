#!/usr/bin/env bash
set -euo pipefail

PROFILE_KEY="${1:?Profil-ID fehlt}"
PROFILE_LABEL="${2:?Profilname fehlt}"
TOOL_LIST="${3:-}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=helpers/status_tracking.sh
source "$ROOT_DIR/scripts/helpers/status_tracking.sh"

init_profile_tracking "$PROFILE_KEY"

echo "Starte Profil-Installation: ${PROFILE_LABEL}"
echo "Tools: ${TOOL_LIST:-keine}"

for tool_slug in $TOOL_LIST; do
    tool_script="$ROOT_DIR/scripts/tools/${tool_slug}_install.sh"
    if [ ! -f "$tool_script" ]; then
        echo "Hinweis: Installer fehlt fuer Tool '${tool_slug}': ${tool_script}"
        continue
    fi

    echo "Installiere Profil-Baustein: ${tool_slug}"
    if [ "$tool_slug" = "coqui_tts" ]; then
        bash "$tool_script" || {
            echo "Hinweis: Coqui_TTS ist optional/experimental und wurde uebersprungen. Piper bleibt der stabile lokale TTS-Pfad."
            continue
        }
    else
        bash "$tool_script"
    fi
done

mark_current_profile_installed
echo "Profil '${PROFILE_LABEL}' wurde abgeschlossen."
