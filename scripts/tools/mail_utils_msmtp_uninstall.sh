#!/bin/bash
# ==============================================================================
# MAIL_UTILS_MSMTP_UNINSTALL.SH - Entfernt lokale Mail-Tools optional
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Mail_Utils_MSMTP"

echo -e "${YELLOW}Entferne mailutils/msmtp/msmtp-mta. Lokale Benutzerkonfiguration bleibt erhalten.${NC}"
if [ "$(id -u)" -eq 0 ]; then
    apt-get remove -y mailutils msmtp msmtp-mta || true
    apt-get autoremove -y || true
elif sudo -n true 2>/dev/null; then
    sudo apt-get remove -y mailutils msmtp msmtp-mta || true
    sudo apt-get autoremove -y || true
else
    echo "Hinweis: sudo ist nicht ohne Passwort-Prompt verfuegbar. Pakete wurden nicht entfernt."
    echo "Manuell ausfuehren:"
    echo "  sudo apt-get remove -y mailutils msmtp msmtp-mta"
    echo "  sudo apt-get autoremove -y"
fi

mark_current_tool_removed
echo -e "${GREEN}Mail_Utils_MSMTP wurde aus dem Setup-Status entfernt.${NC}"
