#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_NAME="Puppeteer"
TOOL_KEY="Puppeteer"
TOOL_SLUG="puppeteer"
PUPPETEER_VERSION="${PUPPETEER_VERSION:-25.13.0}"
if ! [[ "$PUPPETEER_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo 'Ungueltige PUPPETEER_VERSION.' >&2; exit 2; fi
TOOL_NPM_PACKAGES="puppeteer@${PUPPETEER_VERSION}"
TOOL_NODE_MIN_VERSION="22.12.0"
TOOL_APT_PACKAGES="unzip ca-certificates"
TOOL_DESCRIPTION="Node-basierte Browserautomatisierung für Tests, Screenshots und Web-Workflows."
TOOL_OPENCLAW_NOTE="Ergänzt Playwright im Programmiererprofil und kann lokale OpenClaw-Webtests übernehmen."
TOOL_PROMPT_EXAMPLE='```txt
Öffne eine lokale Weboberfläche, führe einen Smoke-Test aus und dokumentiere eventuelle UI-Fehler.
```'
source "$SCRIPT_DIR/helpers/node_tool_common.sh"

puppeteer_smoke_test() {
    node -e 'const p = require("puppeteer"); const fs = require("node:fs"); const path = process.env.PUPPETEER_EXECUTABLE_PATH || p.executablePath(); fs.accessSync(path, fs.constants.X_OK); console.log("Puppeteer und Browserdatei vorhanden: " + path);'
}
TOOL_POST_INSTALL_FUNCTION=puppeteer_smoke_test

prepare_puppeteer_runtime() {
    ensure_node_tool_runtime
}

puppeteer_main() {
    case "${1:-install}" in
        --check)
            check_node_tool_runtime || return 1
            echo "Puppeteer ${PUPPETEER_VERSION}: unzip vor Chrome-Download; Paket-/Browserdatei-Smoke-Test nach Installation."
            ;;
        --dry-run)
            if ! check_node_tool_runtime >/dev/null 2>&1; then
                echo 'Plan: vorhandenes nvm laden oder nvm v0.40.8 aus GitHub bereitstellen; Node 22 mit npm im Benutzerkonto aktivieren.'
            fi
            echo "Plan: Puppeteer ${PUPPETEER_VERSION}, unzip und Browserdatei-Test. Kein Download, sudo oder nvm-Wechsel im Dry-Run."
            ;;
        install)
            prepare_puppeteer_runtime || return 1
            install_node_tool ;;
        *) echo 'Optionen: --check, --dry-run oder ohne Option installieren.' >&2; return 2 ;;
    esac
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    puppeteer_main "$@"
fi
