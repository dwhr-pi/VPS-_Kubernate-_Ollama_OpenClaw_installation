#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"

ensure_user_workspace

edit_config_file() {
  local target_file="$1"
  local editor="${EDITOR:-nano}"
  if ! command -v "$editor" >/dev/null 2>&1; then
    editor="vi"
  fi
  "$editor" "$target_file"
}

persist_config_value() {
  local target_file="$1"
  local key="$2"
  local value="$3"
  local tmp_file

  tmp_file="$(mktemp)"
  awk -v config_key="$key" -v config_value="$value" '
    BEGIN { updated = 0 }
    $0 ~ ("^" config_key "=") {
      print config_key "=\"" config_value "\""
      updated = 1
      next
    }
    { print }
    END {
      if (updated == 0) {
        print config_key "=\"" config_value "\""
      }
    }
  ' "$target_file" > "$tmp_file"
  mv "$tmp_file" "$target_file"
}

current_huginn_profile() {
  get_custom_repo_profile "HUGINN" "stable-release"
}

current_huginn_repo_url() {
  get_custom_repo_url "HUGINN" "https://github.com/huginn/huginn.git"
}

current_huginn_repo_ref() {
  get_custom_repo_ref "HUGINN" "v2022.08.18"
}

huginn_profile_label() {
  case "$1" in
    stable-release) echo "Stable Release (empfohlen): v2022.08.18" ;;
    master-ai) echo "Master Branch: fuer moderne AI-/LLM-Tests" ;;
    main-ai) echo "Main Branch: nur falls der Upstream main nutzt" ;;
    pinned-commit) echo "Pinned Commit: exakt reproduzierbarer Snapshot" ;;
    custom-fork) echo "Eigener Fork oder eigener Branch" ;;
    *) echo "$1" ;;
  esac
}

configure_huginn_source() {
  local profile repo_url repo_ref custom_value

  ensure_user_workspace
  profile="$(current_huginn_profile)"
  repo_url="$(current_huginn_repo_url)"
  repo_ref="$(current_huginn_repo_ref)"

  echo
  echo "Huginn Branch-orientiertes Setup konfigurieren"
  echo "Aktuelles Profil: $(huginn_profile_label "$profile")"
  echo "Aktuelle Quelle: $repo_url"
  echo "Aktueller Ref:   $repo_ref"
  echo
  echo "1) Stable Release (empfohlen, v2022.08.18)"
  echo "2) Master Branch (moderne AI-/LLM-Tests)"
  echo "3) Main Branch (nur falls der Upstream main nutzt)"
  echo "4) Commit SHA pinnen"
  echo "5) Eigener Fork / eigener Branch"
  echo "6) Nur aktuellen Wert anzeigen"
  echo "7) Zurück"
  echo
  read -r -p "Auswahl: " custom_value

  case "$custom_value" in
    1)
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_PROFILE" "stable-release"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_URL" "https://github.com/huginn/huginn.git"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_REF" "v2022.08.18"
      log_success "Huginn wurde auf das empfohlene Stable-Release-Profil gesetzt."
      ;;
    2)
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_PROFILE" "master-ai"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_URL" "https://github.com/huginn/huginn.git"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_REF" "master"
      log_success "Huginn wurde auf den master-Branch gesetzt."
      ;;
    3)
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_PROFILE" "main-ai"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_URL" "https://github.com/huginn/huginn.git"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_REF" "main"
      log_success "Huginn wurde auf den main-Branch gesetzt."
      ;;
    4)
      read -r -p "Commit SHA oder Tag eingeben: " repo_ref
      if [ -z "$repo_ref" ]; then
        log_warn "Kein Commit/Tag angegeben."
        return 1
      fi
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_PROFILE" "pinned-commit"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_URL" "https://github.com/huginn/huginn.git"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_REF" "$repo_ref"
      log_success "Huginn wurde auf den festen Ref $repo_ref gesetzt."
      ;;
    5)
      read -r -p "Fork-URL [.git]: " repo_url
      read -r -p "Branch/Tag/Commit des Forks: " repo_ref
      if [ -z "$repo_url" ] || [ -z "$repo_ref" ]; then
        log_warn "Fork-URL und Ref sind erforderlich."
        return 1
      fi
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_PROFILE" "custom-fork"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_URL" "$repo_url"
      persist_config_value "$CUSTOM_SOURCES_FILE" "CUSTOM_REPO_HUGINN_REF" "$repo_ref"
      log_success "Huginn wurde auf Fork/Branch $repo_ref gesetzt."
      ;;
    6)
      echo
      echo "Aktuelle Huginn-Konfiguration"
      echo "Profil: $(huginn_profile_label "$(current_huginn_profile)")"
      echo "URL:    $(current_huginn_repo_url)"
      echo "Ref:    $(current_huginn_repo_ref)"
      ;;
    7)
      return 0
      ;;
    *)
      log_warn "Unbekannte Auswahl."
      return 1
      ;;
  esac

  echo
  echo "Hinweis: Fuer jeden Huginn-Branch oder Ref sollte der Installer danach erneut laufen,"
  echo "damit Bundle-, Datenbank- und Fallback-Schritte sauber gegen genau diesen Stand ausgefuehrt werden."
}

clone_or_update_custom_source() {
  local source_key="" repo_url="" target_name="" target_dir=""

  echo
  echo "Custom GitHub-Quelle vorbereiten"
  echo "Beispiel Schlüssel: FINGPT, OPENCLAW, OPENMANUS, OPEN_WEBUI, LITELLM, COMFYUI"
  read -r -p "Schlüssel/Bezeichner: " source_key
  read -r -p "GitHub-URL (.git): " repo_url
  read -r -p "Lokaler Ordnername [${source_key,,}]: " target_name

  if [ -z "$source_key" ] || [ -z "$repo_url" ]; then
    log_warn "Schlüssel und URL sind erforderlich."
    return 1
  fi

  if [ -z "$target_name" ]; then
    target_name="$(printf '%s' "$source_key" | tr '[:upper:]' '[:lower:]')"
  fi

  target_dir="$CUSTOM_SOURCE_REPOS_DIR/$target_name"
  begin_measurement "custom_source_${target_name}" "Custom Source vorbereiten: ${target_name}"

  if [ -d "$target_dir/.git" ]; then
    git -C "$target_dir" fetch origin --prune
    git -C "$target_dir" pull --ff-only || true
  else
    git clone "$repo_url" "$target_dir"
  fi

  if ! grep -q "CUSTOM_REPO_${source_key}_URL" "$CUSTOM_SOURCES_FILE"; then
    {
      echo
      echo "# Benutzerdefinierter Eintrag für ${source_key}"
      printf 'CUSTOM_REPO_%s_URL="%s"\n' "$source_key" "$repo_url"
    } >> "$CUSTOM_SOURCES_FILE"
  fi

  end_measurement "success"
  log_success "Quelle vorbereitet unter: $target_dir"
}

prepare_custom_ollama_build() {
  local build_name="" repo_url="" source_dir="" base_model="" gguf_path="" modelfile_path=""

  echo
  echo "Custom Ollama-Build vorbereiten"
  echo "Hinweis: Für GitHub-Forks wie FinGPT brauchst du in der Regel zuerst Fine-Tuning/Export nach GGUF."
  read -r -p "Build-Name (Ollama Modellname): " build_name
  read -r -p "GitHub-Repo-URL des Forks/Projekts (optional): " repo_url
  read -r -p "Quellordner im Workspace (optional): " source_dir
  read -r -p "Basis-Modell [qwen3:30b]: " base_model
  read -r -p "Pfad zur exportierten GGUF-Datei (optional, für ollama create empfohlen): " gguf_path

  if [ -z "$build_name" ]; then
    log_warn "Ein Build-Name ist erforderlich."
    return 1
  fi

  if [ -z "$base_model" ]; then
    base_model="qwen3:30b"
  fi

  if [ -z "$source_dir" ]; then
    source_dir="$CUSTOM_SOURCE_REPOS_DIR/$build_name"
  fi

  modelfile_path="$USER_MODELFILE_DIR/${build_name}.Modelfile"

  if [ -n "$repo_url" ] && [ ! -d "$source_dir/.git" ]; then
    git clone "$repo_url" "$source_dir"
  fi

  if [ -n "$gguf_path" ]; then
    cat > "$modelfile_path" <<EOF
FROM $gguf_path

PARAMETER temperature 0.2
PARAMETER num_ctx 32768

SYSTEM You are a finance analysis model prepared for structured market, report and risk analysis. You must not claim to execute trades autonomously.
EOF
  else
    cat > "$modelfile_path" <<EOF
FROM $base_model

PARAMETER temperature 0.2
PARAMETER num_ctx 32768

SYSTEM Placeholder-Modelfile für einen späteren Custom-Build. Trage nach Fine-Tuning und GGUF-Export den echten GGUF-Pfad im FROM ein.
EOF
  fi

  {
    echo
    echo "# Custom Build: $build_name"
    printf 'BUILD_%s_REPO_URL="%s"\n' "$(printf '%s' "$build_name" | tr '[:lower:]-' '[:upper:]_')" "$repo_url"
    printf 'BUILD_%s_SOURCE_DIR="%s"\n' "$(printf '%s' "$build_name" | tr '[:lower:]-' '[:upper:]_')" "$source_dir"
    printf 'BUILD_%s_BASE_MODEL="%s"\n' "$(printf '%s' "$build_name" | tr '[:lower:]-' '[:upper:]_')" "$base_model"
    printf 'BUILD_%s_GGUF_PATH="%s"\n' "$(printf '%s' "$build_name" | tr '[:lower:]-' '[:upper:]_')" "$gguf_path"
    printf 'BUILD_%s_MODEFILE_PATH="%s"\n' "$(printf '%s' "$build_name" | tr '[:lower:]-' '[:upper:]_')" "$modelfile_path"
  } >> "$CUSTOM_OLLAMA_BUILDS_FILE"

  log_success "Modelfile vorbereitet: $modelfile_path"
  echo
  echo "Nächste typische Schritte:"
  echo "1. Fork/Repo lokal weiterentwickeln oder Fine-Tuning ausführen"
  echo "2. GGUF exportieren"
  echo "3. Modelfile prüfen"
  echo "4. Ollama registrieren:"
  echo "   ollama create $build_name -f \"$modelfile_path\""

  if [ -n "$gguf_path" ] && [ -f "$gguf_path" ] && command -v ollama >/dev/null 2>&1; then
    echo
    read -r -p "Soll der Build jetzt direkt in Ollama registriert werden? (j/N): " answer
    case "$answer" in
      j|J|y|Y|yes|YES)
        ollama create "$build_name" -f "$modelfile_path"
        ;;
    esac
  fi
}

show_current_files() {
  echo
  echo "Custom Quellen Konfiguration: $CUSTOM_SOURCES_FILE"
  echo "Custom Ollama-Builds:       $CUSTOM_OLLAMA_BUILDS_FILE"
  echo "Custom Quellen Ordner:      $CUSTOM_SOURCE_REPOS_DIR"
  echo "Custom Modelfiles Ordner:   $USER_MODELFILE_DIR"
  echo "Huginn Profil:              $(huginn_profile_label "$(current_huginn_profile)")"
  echo "Huginn Quelle:              $(current_huginn_repo_url)"
  echo "Huginn Ref:                 $(current_huginn_repo_ref)"
  echo
  ls -la "$CUSTOM_SOURCE_REPOS_DIR" 2>/dev/null || true
}

while true; do
  clear
  echo "Custom GitHub-Quellen & Ollama-Builds"
  echo "1) custom_sources.conf bearbeiten"
  echo "2) custom_ollama_builds.conf bearbeiten"
  echo "3) Custom-Quellen und Build-Dateien anzeigen"
  echo "4) Custom GitHub-Quelle klonen/aktualisieren"
  echo "5) Custom Ollama-Build vorbereiten / registrieren"
  echo "6) Huginn Branch/Ref konfigurieren"
  echo "7) Kurzhilfe anzeigen"
  echo "8) Zurück"
  echo
  read -r -p "Auswahl: " choice
  case "$choice" in
    1) edit_config_file "$CUSTOM_SOURCES_FILE" ;;
    2) edit_config_file "$CUSTOM_OLLAMA_BUILDS_FILE" ;;
    3) show_current_files; read -r -p "Enter..." _ ;;
    4) clone_or_update_custom_source; read -r -p "Enter..." _ ;;
    5) prepare_custom_ollama_build; read -r -p "Enter..." _ ;;
    6) configure_huginn_source; read -r -p "Enter..." _ ;;
    7)
      echo
      echo "Kurzlogik:"
      echo "- custom_sources.conf speichert GitHub-Overrides für Tools und Hauptprogramme."
      echo "- custom_ollama_builds.conf speichert lesbare Build-Blöcke für eigene Modelle/Forks."
      echo "- Huginn kann hier als branch-orientiertes Setup mit empfohlenem Stable-Ref, master/main, Commit oder eigenem Fork verwaltet werden."
      echo "- Für FinGPT/FinRobot/FinRAG oder eigene Forks gilt meist:"
      echo "  Fine-Tuning/Export -> GGUF -> Modelfile -> ollama create"
      echo
      read -r -p "Enter..." _ ;;
    8) exit 0 ;;
    *) ;;
  esac
done
