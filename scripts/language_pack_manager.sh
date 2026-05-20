#!/bin/bash
# ==============================================================================
# LANGUAGE_PACK_MANAGER.SH - Verwaltet nachinstallierbare Sprachpakete
# ==============================================================================

set -euo pipefail

dialog() {
    local arg
    local has_cancel_label=0

    for arg in "$@"; do
        if [ "$arg" = "--cancel-label" ]; then
            has_cancel_label=1
            break
        fi
    done

    if [ "$has_cancel_label" -eq 1 ]; then
        command dialog "$@"
    else
        command dialog --cancel-label "Zurueck" "$@"
    fi
}

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
LANGUAGE_PACKS_DIR="$USER_WORKSPACE_DIR/language_packs"
REPO_PACKS_DIR="$INSTALL_DIR/language_packs"
CHOICE_FILE="/tmp/language_pack_choice"
INPUT_FILE="/tmp/language_pack_input"

cleanup_temp_files() {
    rm -f "$CHOICE_FILE" "$INPUT_FILE"
}

ensure_dirs() {
    mkdir -p "$LANGUAGE_PACKS_DIR"
}

pause_screen() {
    read -r -p "Druecken Sie Enter..."
}

list_manifest_paths() {
    local base_dir="$1"
    if [ -f "$base_dir/manifest.conf" ]; then
        printf '%s\n' "$base_dir/manifest.conf"
        return 0
    fi

    if [ -d "$base_dir/language_packs" ]; then
        find "$base_dir/language_packs" -mindepth 2 -maxdepth 2 -name manifest.conf -print 2>/dev/null | sort
        return 0
    fi

    find "$base_dir" -mindepth 2 -maxdepth 2 -name manifest.conf -print 2>/dev/null | sort
}

read_manifest_value() {
    local manifest_file="$1"
    local key="$2"
    awk -F= -v target="$key" '
        $1 == target {
            value = $2
            gsub(/^[[:space:]]*"/, "", value)
            gsub(/"[[:space:]]*$/, "", value)
            print value
            exit
        }
    ' "$manifest_file"
}

install_pack_from_manifest() {
    local manifest_file="$1"
    local source_dir pack_id pack_name pack_lang target_dir
    source_dir="$(cd "$(dirname "$manifest_file")" && pwd)"
    pack_id="$(read_manifest_value "$manifest_file" "PACK_ID")"
    pack_name="$(read_manifest_value "$manifest_file" "PACK_NAME")"
    pack_lang="$(read_manifest_value "$manifest_file" "PACK_LANGUAGE")"

    if [ -z "$pack_id" ] || [ -z "$pack_lang" ]; then
        echo -e "${RED}Fehler: Ungueltiges Sprachpaket-Manifest in $manifest_file${NC}"
        return 1
    fi

    target_dir="$LANGUAGE_PACKS_DIR/$pack_id"
    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    cp -R "$source_dir/." "$target_dir/"

    echo -e "${GREEN}Sprachpaket installiert:${NC} ${pack_name:-$pack_id} (${pack_lang})"
    echo "  Ziel: $target_dir"
}

install_packs_from_dir() {
    local source_dir="$1"
    local found=0 manifest_file
    ensure_dirs

    while IFS= read -r manifest_file; do
        [ -n "$manifest_file" ] || continue
        found=1
        install_pack_from_manifest "$manifest_file"
    done < <(list_manifest_paths "$source_dir")

    if [ "$found" -eq 0 ]; then
        echo -e "${RED}Fehler: Unter $source_dir wurde kein Sprachpaket-Manifest gefunden.${NC}"
        return 1
    fi
}

install_packs_from_git_repo() {
    local repo_url="$1"
    local tmp_dir
    tmp_dir="$(mktemp -d)"

    echo -e "${BLUE}Klonen von Sprachpaket-Quelle...${NC}"
    git clone --depth 1 "$repo_url" "$tmp_dir/repo"
    install_packs_from_dir "$tmp_dir/repo"
    rm -rf "$tmp_dir"
}

list_installed_packs() {
    local manifest_file pack_id pack_name pack_lang pack_version pack_enabled
    ensure_dirs

    if ! find "$LANGUAGE_PACKS_DIR" -mindepth 2 -maxdepth 2 -name manifest.conf -print -quit 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}Aktuell sind keine externen Sprachpakete im Benutzer-Workspace installiert.${NC}"
        return 0
    fi

    echo -e "${GREEN}Installierte Sprachpakete:${NC}"
    while IFS= read -r manifest_file; do
        pack_id="$(read_manifest_value "$manifest_file" "PACK_ID")"
        pack_name="$(read_manifest_value "$manifest_file" "PACK_NAME")"
        pack_lang="$(read_manifest_value "$manifest_file" "PACK_LANGUAGE")"
        pack_version="$(read_manifest_value "$manifest_file" "PACK_VERSION")"
        pack_enabled="$(read_manifest_value "$manifest_file" "PACK_ENABLED")"
        [ -n "$pack_enabled" ] || pack_enabled="true"
        echo " - ${pack_name:-$pack_id} | ID: ${pack_id} | Sprache: ${pack_lang} | Version: ${pack_version:-unbekannt} | Aktiv: ${pack_enabled}"
    done < <(find "$LANGUAGE_PACKS_DIR" -mindepth 2 -maxdepth 2 -name manifest.conf -print | sort)
}

choose_installed_pack() {
    local title="$1"
    local prompt="$2"
    local manifest_file pack_id pack_name pack_lang pack_enabled
    local args=()
    ensure_dirs

    while IFS= read -r manifest_file; do
        pack_id="$(read_manifest_value "$manifest_file" "PACK_ID")"
        pack_name="$(read_manifest_value "$manifest_file" "PACK_NAME")"
        pack_lang="$(read_manifest_value "$manifest_file" "PACK_LANGUAGE")"
        pack_enabled="$(read_manifest_value "$manifest_file" "PACK_ENABLED")"
        [ -n "$pack_enabled" ] || pack_enabled="true"
        args+=("$pack_id" "${pack_name:-$pack_id} | ${pack_lang} | aktiv=${pack_enabled}")
    done < <(find "$LANGUAGE_PACKS_DIR" -mindepth 2 -maxdepth 2 -name manifest.conf -print | sort)

    if [ "${#args[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Es sind keine installierten Sprachpakete vorhanden.${NC}"
        return 1
    fi

    dialog --clear --backtitle "OpenClaw Ultimate Setup" \
        --title "$title" --menu "$prompt" 20 100 10 \
        "${args[@]}" 2> "$CHOICE_FILE" || return 1

    SELECTED_PACK_ID="$(cat "$CHOICE_FILE" 2>/dev/null || true)"
    [ -n "$SELECTED_PACK_ID" ] || return 1
    return 0
}

set_pack_enabled_state() {
    local pack_id="$1"
    local new_state="$2"
    local manifest_file="$LANGUAGE_PACKS_DIR/$pack_id/manifest.conf"
    local tmp_file

    [ -f "$manifest_file" ] || {
        echo -e "${RED}Fehler: Manifest nicht gefunden fuer $pack_id${NC}"
        return 1
    }

    tmp_file="$(mktemp)"
    awk -v state="$new_state" '
        BEGIN { updated = 0 }
        /^PACK_ENABLED=/ {
            print "PACK_ENABLED=\"" state "\""
            updated = 1
            next
        }
        { print }
        END {
            if (updated == 0) {
                print "PACK_ENABLED=\"" state "\""
            }
        }
    ' "$manifest_file" > "$tmp_file"
    mv "$tmp_file" "$manifest_file"

    echo -e "${GREEN}Sprachpaket $pack_id wurde auf aktiv=${new_state} gesetzt.${NC}"
}

remove_pack() {
    local pack_id="$1"
    local pack_dir="$LANGUAGE_PACKS_DIR/$pack_id"
    if [ ! -d "$pack_dir" ]; then
        echo -e "${RED}Fehler: Sprachpaket $pack_id wurde nicht gefunden.${NC}"
        return 1
    fi
    rm -rf "$pack_dir"
    echo -e "${GREEN}Sprachpaket $pack_id wurde entfernt.${NC}"
}

open_language_pack_guide() {
    local guide_file="$INSTALL_DIR/docs/LANGUAGE_PACKS_GUIDE.md"
    if [ -f "$guide_file" ]; then
        dialog --clear --backtitle "OpenClaw Ultimate Setup" \
            --title "SPRACHPAKETE" --textbox "$guide_file" 28 100
    else
        echo -e "${RED}Fehler: Sprachpaket-Doku nicht gefunden.${NC}"
        pause_screen
    fi
}

main_menu() {
    local choice source_path repo_url pack_id manifest_file current_state
    ensure_dirs

    while true; do
        dialog --clear --backtitle "OpenClaw Ultimate Setup" \
            --title "SPRACHPAKETE" --menu \
            "Verwalte nachinstallierbare Sprachpakete fuer Setup, Tool-Hinweise und spaetere UI-Erweiterungen." \
            22 100 10 \
            "1" "Deutsches Starter-Paket aus diesem Repo installieren" \
            "2" "Sprachpaket aus lokalem Ordner installieren" \
            "3" "Sprachpaket aus Git-Repo installieren" \
            "4" "Installierte Sprachpakete anzeigen" \
            "5" "Sprachpaket aktivieren oder deaktivieren" \
            "6" "Sprachpaket entfernen" \
            "7" "Sprachpaket-Doku oeffnen" \
            "8" "Zurueck" 2> "$CHOICE_FILE" || return 0

        choice="$(cat "$CHOICE_FILE" 2>/dev/null || true)"
        clear

        case "$choice" in
            1)
                install_packs_from_dir "$REPO_PACKS_DIR/de_core_ui"
                pause_screen
                ;;
            2)
                dialog --clear --backtitle "OpenClaw Ultimate Setup" \
                    --title "LOKALER SPRACHPAKET-ORDNER" \
                    --inputbox "Gib den Pfad zu einem Ordner mit manifest.conf oder zu einem Repo mit language_packs/ an:" \
                    12 100 "$REPO_PACKS_DIR/de_core_ui" 2> "$INPUT_FILE" || continue
                source_path="$(cat "$INPUT_FILE" 2>/dev/null || true)"
                clear
                if [ -z "$source_path" ] || [ ! -d "$source_path" ]; then
                    echo -e "${RED}Fehler: Der angegebene Ordner wurde nicht gefunden.${NC}"
                else
                    install_packs_from_dir "$source_path"
                fi
                pause_screen
                ;;
            3)
                dialog --clear --backtitle "OpenClaw Ultimate Setup" \
                    --title "SPRACHPAKET AUS GIT-REPO" \
                    --inputbox "Gib die Git-URL zu einem Repo mit Sprachpaketen an:" \
                    12 100 "https://github.com/beispiel/sprachpakete.git" 2> "$INPUT_FILE" || continue
                repo_url="$(cat "$INPUT_FILE" 2>/dev/null || true)"
                clear
                if [ -z "$repo_url" ]; then
                    echo -e "${RED}Fehler: Die Git-URL darf nicht leer sein.${NC}"
                else
                    install_packs_from_git_repo "$repo_url"
                fi
                pause_screen
                ;;
            4)
                list_installed_packs
                pause_screen
                ;;
            5)
                if choose_installed_pack "SPRACHPAKET SCHALTEN" "Waehle das Sprachpaket, das aktiviert oder deaktiviert werden soll:"; then
                    manifest_file="$LANGUAGE_PACKS_DIR/$SELECTED_PACK_ID/manifest.conf"
                    current_state="$(read_manifest_value "$manifest_file" "PACK_ENABLED")"
                    [ -n "$current_state" ] || current_state="true"
                    if [ "$current_state" = "true" ]; then
                        set_pack_enabled_state "$SELECTED_PACK_ID" "false"
                    else
                        set_pack_enabled_state "$SELECTED_PACK_ID" "true"
                    fi
                fi
                pause_screen
                ;;
            6)
                if choose_installed_pack "SPRACHPAKET ENTFERNEN" "Waehle das Sprachpaket, das entfernt werden soll:"; then
                    remove_pack "$SELECTED_PACK_ID"
                fi
                pause_screen
                ;;
            7)
                open_language_pack_guide
                ;;
            8)
                return 0
                ;;
        esac
    done
}

cleanup_temp_files
trap cleanup_temp_files EXIT

main_menu "$@"
