#!/usr/bin/env bash
# Menu guidance only; the existing base installer retains its own safeguards.
gguf_check_base() {
    bash "$INSTALL_DIR/scripts/tools/comfyui_gguf_install.sh" --check-base
}

gguf_read_dependency_choice() {
    [[ -t 0 ]] || return 1
    read -r -p 'Auswahl [1/2/N; Standard N = abbrechen]: ' GGUF_DEPENDENCY_CHOICE
}

gguf_prepare_dependency() {
    local rc=0 GGUF_DEPENDENCY_CHOICE=""
    [[ "${COMFYUI_GGUF_MODE:-integrate}" == source ]] && return 0
    gguf_check_base || rc=$?
    ((rc == 0)) && return 0
    # Broken venv, conflicting targets and unsafe paths are not missing-source cases.
    ((rc == 3)) || return "$rc"
    echo 'ComfyUI-Basis fehlt. Keine automatische Installation.'
    echo '1: Separaten ComfyUI-Installer bewusst aufrufen (PyTorch, viele GB; eigene Warnung und Ressourcenpruefung).'
    echo '2: Nur GGUF-GitHub-Quellen vorbereiten, ohne ComfyUI-Integration oder Paketinstallation.'
    echo 'N/Enter: Abbrechen; nichts installieren.'
    gguf_read_dependency_choice || return 3
    case "$GGUF_DEPENDENCY_CHOICE" in
        2)
            export COMFYUI_GGUF_MODE=source
            echo 'Source-only gewaehlt; das ist keine aktive ComfyUI-Erweiterung.'
            return 0 ;;
        1)
            if [[ -n "${COMFYUI_ROOT:-}" && "$COMFYUI_ROOT" != /opt/comfyui ]]; then
                echo 'Basisinstaller verwendet /opt/comfyui, nicht den expliziten COMFYUI_ROOT. Keine Installation am falschen Ziel.' >&2
                return 3
            fi
            # Uses the normal menu path, including opt-in, resource guards and logs.
            install_tool ComfyUI || return 1
            if [[ "${TOOL_BATCH_ABORT_REQUESTED:-0}" == 1 ]]; then
                echo 'Abbruch nach Basisinstallation respektiert; GGUF wird nicht fortgesetzt.'
                return 3
            fi
            echo 'Pruefe die ComfyUI-Basis erneut; ein Installer-Erfolg allein genuegt nicht.'
            gguf_check_base || return 1
            return 0 ;;
        *) echo 'GGUF-Installation abgebrochen; keine Basisinstallation gestartet.'; return 3 ;;
    esac
}
