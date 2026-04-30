#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
APP_VERSION="11.15"

# shellcheck source=./scripts/lib/common.sh
source "$REPO_ROOT/scripts/lib/common.sh"

main_menu() {
  while true; do
    clear
    echo "OpenClaw Ultimate Setup V7 Kompatibilitätsmenü - Plattformstand V${APP_VERSION}"
    echo
    echo "1  Profile anzeigen"
    echo "2  Tools anzeigen"
    echo "3  Aktuelles Ultimate-Setup starten"
    echo "4  Status anzeigen"
    echo "5  Ports prüfen"
    echo "6  Speicher prüfen"
    echo "7  Logs anzeigen"
    echo "8  Backup starten"
    echo "9  Restore testen"
    echo "10 Security Scan starten"
    echo "11 Update aller Tools"
    echo "12 Ollama Modelle verwalten"
    echo "13 Kubernetes Deployments anzeigen"
    echo "14 Beenden"
    echo
    read -r -p "Auswahl: " choice
    case "$choice" in
      1) ls "$REPO_ROOT/scripts/profiles";;
      2) ls "$REPO_ROOT/scripts/tools";;
      3) bash "$REPO_ROOT/setup_ultimate.sh";;
      4) bash "$REPO_ROOT/scripts/operations/status_report.sh";;
      5) bash "$REPO_ROOT/scripts/port_check.sh";;
      6) bash "$REPO_ROOT/scripts/lib/resource_check.sh" --summary;;
      7) ls -lah "${HOME}/.openclaw_ultimate_user_data/logs" 2>/dev/null || true;;
      8) bash "$REPO_ROOT/scripts/operations/backup_run.sh";;
      9) bash "$REPO_ROOT/scripts/operations/restore_test.sh";;
      10) bash "$REPO_ROOT/scripts/operations/security_scan.sh";;
      11) bash "$REPO_ROOT/scripts/operations/update_all_tools.sh";;
      12)
        if [ -f "$REPO_ROOT/scripts/ollama_model_catalog_manager.sh" ]; then
          bash "$REPO_ROOT/scripts/ollama_model_catalog_manager.sh"
        else
          bash "$REPO_ROOT/scripts/ollama_model_manager.sh"
        fi
        ;;
      13) bash "$REPO_ROOT/scripts/operations/show_k8s_deployments.sh";;
      14) exit 0;;
      *) echo "Ungültige Auswahl.";;
    esac
    echo
    read -r -p "Weiter mit Enter..."
  done
}

main_menu
