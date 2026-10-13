#!/bin/bash
set -euo pipefail
TOOL_NAME="Promptfoo"
TOOL_KEY="Promptfoo"
TOOL_SLUG="promptfoo"
TOOL_DESCRIPTION="Prompt-, Agenten- und RAG-Testframework für Qualität, Regressionen und Red-Teaming."
TOOL_MODULE_TYPE="AI-Evaluation-Scaffold"
TOOL_GIT_REPO="https://github.com/promptfoo/promptfoo.git"
TOOL_NODE_MIN_VERSION="22.22.0"
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Promptfoo

```txt
Erzeuge eine Testsuite für Prompts, RAG-Antworten und Sicherheitsfälle und dokumentiere die wichtigsten Regressionen im Setup.
```'
TOOL_OPENCLAW_NOTE="Promptfoo dient hier als Test- und Eval-Schicht für Prompts, RAG-Pipelines und Guardrail-Regeln."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers/node_tool_common.sh"

check_promptfoo_runtime() {
    check_node_tool_runtime || return 1
    local version
    version="$(npm --version)" || return 1
    # Match the pinned npm used in upstream's build/acceptance CI.
    if [ "$version" != "11.11.0" ]; then
        echo "Fehler: Promptfoo-Source-Build nutzt npm 11.11.0; gefunden: $version." >&2
        echo 'Passende Node-Version aktivieren, dort npm install -g npm@11.11.0 ausfuehren und erneut pruefen. Kein automatischer System-Node-Wechsel.' >&2
        return 1
    fi
}

build_promptfoo_from_source() (
    cd "$TOOL_DIR" || return 1
    if [ ! -f package.json ] || [ ! -f package-lock.json ]; then
        echo 'Fehler: Promptfoo package.json oder package-lock.json fehlt.' >&2
        return 1
    fi
    if ! npm ci --engine-strict; then
        echo 'Fehler: Promptfoo npm ci fehlgeschlagen. Node/npm-Version und npm-Log pruefen; keine Overrides entfernen.' >&2
        return 1
    fi
    if ! npm run build; then
        echo 'Fehler: Promptfoo Build fehlgeschlagen. Build-Log, RAM/Swap und freien Speicher pruefen.' >&2
        return 1
    fi
    if ! node dist/src/entrypoint.js --version; then
        echo 'Fehler: Promptfoo CLI-Smoke-Test fehlgeschlagen.' >&2
        return 1
    fi
)

promptfoo_main() {
    local mode="${1:-install}"
    case "$mode" in install|--check|--dry-run) ;; *) echo 'Aufruf: promptfoo_install.sh [--check|--dry-run]' >&2; return 2 ;; esac
    echo 'Promptfoo: GitHub-Source-Build; Node >=22.22.0, npm 11.11.0. Kein Dienststart, keine Cloud-Abfragen.'
    check_promptfoo_runtime || return 1
    if [ "$mode" != install ]; then
        echo 'Runtime-Pruefung bestanden. Kein Clone, Paketdownload oder Build ausgefuehrt.'
        return 0
    fi
    TOOL_DIR="/opt/promptfoo"
    if [ -L "$TOOL_DIR" ] || { [ -e "$TOOL_DIR" ] && [ ! -d "$TOOL_DIR/.git" ]; }; then
        echo "Fehler: $TOOL_DIR ist kein sicherer Git-Checkout. Inhalte sichern und manuell pruefen; keine automatische Loeschung." >&2
        return 1
    fi
    AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking "$TOOL_KEY"
    if ! command -v git >/dev/null || ! command -v make >/dev/null ||
       ! command -v g++ >/dev/null || ! command -v python3 >/dev/null; then
        run_apt_with_lock_wait update || return 1
        run_apt_with_lock_wait install -y git build-essential python3 || return 1
    fi
    if [ -d "$TOOL_DIR/.git" ]; then
        local origin
        origin="$(git -C "$TOOL_DIR" remote get-url origin)" || return 1
        if [ "$origin" != "$TOOL_GIT_REPO" ]; then
            echo "Fehler: Unerwartete Promptfoo Git-Quelle: $origin" >&2; return 1
        fi
        GIT_TERMINAL_PROMPT=0 git -C "$TOOL_DIR" pull --ff-only || return 1
    else
        sudo mkdir -p "$TOOL_DIR" || return 1
        sudo chown "$(id -un):$(id -gn)" "$TOOL_DIR" || return 1
        GIT_TERMINAL_PROMPT=0 git clone "$TOOL_GIT_REPO" "$TOOL_DIR" || return 1
    fi
    build_promptfoo_from_source || return 1
    mark_current_tool_installed
    echo 'Promptfoo Build und CLI-Smoke-Test erfolgreich. CLI: node /opt/promptfoo/dist/src/entrypoint.js'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    promptfoo_main "$@"
fi
