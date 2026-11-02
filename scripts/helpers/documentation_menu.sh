#!/usr/bin/env bash
# Read-only documentation navigation. Sourcing this file has no side effects.

documentation_document_path() {
  case "$1:$2" in
    start:minutes) printf '%s\n' 'docs/FIRST_60_MINUTES.md' ;;
    start:status) printf '%s\n' 'docs/CURRENT_STATUS.md' ;;
    start:index) printf '%s\n' 'docs/readme.md' ;;
    architecture:baseline) printf '%s\n' 'docs/PRODUCTION_BASELINE.md' ;;
    architecture:gitops) printf '%s\n' 'docs/GITOPS_SMALL_VPS.md' ;;
    architecture:gpu) printf '%s\n' 'docs/LLMOPS_GPU_AND_OPERATIONS.md' ;;
    operations:backup) printf '%s\n' 'docs/INSTALLATION_STATUS_BACKUP.md' ;;
    operations:credentials) printf '%s\n' 'docs/CREDENTIALS_BACKUP.md' ;;
    operations:reset) printf '%s\n' 'docs/INSTALLATION_RESET.md' ;;
    security:releases) printf '%s\n' 'docs/SIGNED_RELEASES.md' ;;
    security:core) printf '%s\n' 'docs/SECURE_CORE_REFACTOR.md' ;;
    security:sources) printf '%s\n' 'docs/P0_B_CORE_SOURCES.md' ;;
    tools:tools) printf '%s\n' 'docs/generated/TOOL_MATRIX.md' ;;
    tools:profiles) printf '%s\n' 'docs/generated/PROFILE_MATRIX.md' ;;
    tools:keys) printf '%s\n' 'docs/_API-Keys/API_KEY_GUIDE.md' ;;
    history:legacy) printf '%s\n' 'docs/legacy/README_FULL_2026_11_01.md' ;;
    history:implementation) printf '%s\n' 'docs/P1_P3_IMPLEMENTATION.md' ;;
    history:review) printf '%s\n' 'docs/SETUP_REVIEW_2026_CODEX.md' ;;
    *) return 2 ;;
  esac
}

show_documentation_menu() {
  local topic document relative result
  local -a entries
  while :; do
    if topic="$(dialog --stdout --clear --backtitle "$APP_TITLE" \
      --title 'Dokumentation: sechs Themen' --ok-label 'Oeffnen' --cancel-label 'Zurueck' \
      --menu 'Nur lokale Texte. Enter oeffnet die Auswahl; Zurueck/Esc beendet die Ansicht.' 18 78 6 \
      start 'Einstieg und aktueller Status' architecture 'Architektur und Kubernetes' \
      operations 'Betrieb, Backup und Wiederherstellung' security 'Sicherheit und Releases' \
      tools 'Tools, Profile und API-Keys' history 'Historie und Abnahmegrenzen')"; then
      case "$topic" in
        start) entries=(minutes 'Erste 60 Minuten' status 'Aktueller Status' index 'Dokumentations-Wegweiser') ;;
        architecture) entries=(baseline 'Kubernetes-Baseline' gitops 'GitOps fuer kleine VPS' gpu 'GPU und Betrieb') ;;
        operations) entries=(backup 'Installationsstatus sichern' credentials 'ENV und Keys verschluesselt sichern' reset 'Installations-Reset') ;;
        security) entries=(releases 'Signierte Releases' core 'Sicherer Kernpfad' sources 'Core-Quellenschutz') ;;
        tools) entries=(tools 'Tool-Matrix' profiles 'Profil-Matrix' keys 'API-Key Guide') ;;
        history) entries=(legacy 'Historische Langfassung (keine Installationsfreigabe)' implementation 'P1-P3: Abnahmegrenzen' review 'Audit und historische Befunde') ;;
        *) return 2 ;;
      esac
    else
      result=$?
      case "$result" in 1 | 255) return 0 ;; *) return "$result" ;; esac
    fi
    while :; do
      if document="$(dialog --stdout --clear --backtitle "$APP_TITLE" \
        --title 'Dokument auswaehlen' --ok-label 'Oeffnen' --cancel-label 'Zurueck' \
        --menu 'Enter oeffnet den Text; Zurueck/Esc fuehrt zu den sechs Themen.' 16 78 3 "${entries[@]}")"; then
        relative="$(documentation_document_path "$topic" "$document")" || return $?
        if [[ ! -f "$INSTALL_DIR/$relative" ]]; then
          printf 'Dokument fehlt: %s\n' "$relative" >&2
          return 1
        fi
        if dialog --clear --backtitle "$APP_TITLE" --title "$relative" --exit-label 'Zurueck' \
          --textbox "$INSTALL_DIR/$relative" 25 80; then
          :
        else
          result=$?
          case "$result" in 1 | 255) ;; *) return "$result" ;; esac
        fi
      else
        result=$?
        case "$result" in 1 | 255) break ;; *) return "$result" ;; esac
      fi
    done
  done
}
