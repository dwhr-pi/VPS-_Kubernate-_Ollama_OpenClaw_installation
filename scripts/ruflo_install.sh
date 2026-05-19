#!/bin/bash
# ==============================================================================
# RUFLO_INSTALL.SH - Ruflo Installation & Management
# Installiert Ruflo von GitHub, stellt Node/pnpm sicher und verlinkt die CLI.
# ==============================================================================

set -euo pipefail

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

RUFLO_DIR="/opt/ruflo"
RUFLO_REPOS=(
    "${RUFLO_REPO_URL:-}"
    "https://github.com/ruvnet/ruflo.git"
    "https://github.com/dwhr-pi/ruflo.git"
)
RUFLO_PNPM_ALLOWED_BUILDS=(
    "@google/genai"
    "agentdb"
    "agentic-flow"
    "argon2"
    "better-sqlite3"
    "esbuild"
    "hnswlib-node"
    "onnxruntime-node"
    "protobufjs"
    "sharp"
    "tldjs"
)

run_sudo() {
    if [ "${EUID}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

ensure_base_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Skript unterstuetzt aktuell nur apt-basierte Systeme.${NC}"
        exit 1
    fi

    run_sudo apt-get update
    run_sudo apt-get install -y curl ca-certificates git
}

ensure_nodejs_22() {
    local current_major

    if command -v node >/dev/null 2>&1; then
        current_major="$(node -p 'process.versions.node.split(".")[0]')"
        if [ "${current_major}" -ge 22 ]; then
            return
        fi
        echo -e "${YELLOW}Gefundene Node.js Version $(node -v) ist zu alt. Aktualisiere auf Node.js 22.x...${NC}"
    else
        echo -e "${BLUE}Node.js ist nicht installiert. Installiere Node.js 22.x...${NC}"
    fi

    curl -fsSL https://deb.nodesource.com/setup_22.x | run_sudo bash -
    run_sudo apt-get install -y nodejs
}

ensure_pnpm() {
    if ! command -v corepack >/dev/null 2>&1; then
        echo -e "${RED}Fehler: corepack ist nicht verfuegbar, obwohl Node.js installiert sein sollte.${NC}"
        exit 1
    fi

    run_sudo env PATH="$PATH" corepack enable
    run_sudo env PATH="$PATH" corepack prepare pnpm@latest --activate
}

activate_pnpm_version() {
    local version="$1"
    run_sudo env PATH="$PATH" corepack prepare "pnpm@${version}" --activate
}

pnpm_v3() {
    npx -y pnpm@8.15.0 "$@"
}

ensure_pnpm_workspace_file() {
    if [ -f pnpm-workspace.yaml ]; then
        return
    fi

    cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "."
EOF
}

write_pnpm_allowed_builds_config() {
    local dep

    ensure_pnpm_workspace_file

    cp pnpm-workspace.yaml "pnpm-workspace.yaml.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true

    {
        echo "packages:"
        node <<'EOF'
const fs = require("fs");
let packages = ["."];
try {
  const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
  if (Array.isArray(pkg.workspaces)) {
    packages = pkg.workspaces;
  } else if (pkg.workspaces && Array.isArray(pkg.workspaces.packages)) {
    packages = pkg.workspaces.packages;
  }
} catch (_) {}
for (const entry of packages) {
  console.log(`  - ${JSON.stringify(entry)}`);
}
EOF
        echo
        echo "allowBuilds:"
        for dep in "${RUFLO_PNPM_ALLOWED_BUILDS[@]}"; do
            printf '  "%s": true\n' "$dep"
        done
    } > pnpm-workspace.yaml
}

repair_legacy_or_broken_pnpm_workspace() {
    if [ ! -f pnpm-workspace.yaml ]; then
        return 0
    fi

    if grep -qE 'onlyBuiltDependencies:|set this to true or false|Automatically ignored builds during installation|hint: allowBuilds:' pnpm-workspace.yaml; then
        echo -e "${YELLOW}Bereinige alte oder kaputte pnpm-workspace.yaml aus einem vorherigen Ruflo-Versuch...${NC}"
        write_pnpm_allowed_builds_config
        return 0
    fi

    if ! node -e 'const fs=require("fs"); const text=fs.readFileSync("pnpm-workspace.yaml","utf8"); if (!/^packages:/m.test(text)) process.exit(1);' >/dev/null 2>&1; then
        echo -e "${YELLOW}pnpm-workspace.yaml wirkt unvollstaendig. Erzeuge sichere Ruflo-Workspace-Konfiguration neu...${NC}"
        write_pnpm_allowed_builds_config
    fi
}

handle_pnpm_ignored_builds() {
    local answer

    if ! command -v pnpm >/dev/null 2>&1; then
        return 1
    fi

    if ! pnpm ignored-builds >/tmp/ruflo_pnpm_ignored_builds.txt 2>/dev/null; then
        return 1
    fi

    if ! grep -qE '^[[:space:]]*[[:alnum:]_@./-]+' /tmp/ruflo_pnpm_ignored_builds.txt; then
        return 1
    fi

    echo -e "${YELLOW}pnpm hat Build-Skripte blockiert. Das ist eine Sicherheitsfunktion von pnpm 10/11.${NC}"
    echo -e "${YELLOW}Blockierte Pakete laut pnpm:${NC}"
    sed 's/^/  - /' /tmp/ruflo_pnpm_ignored_builds.txt
    echo
    echo -e "${YELLOW}Ohne Freigabe koennen native Module wie esbuild, sharp, argon2 oder better-sqlite3 spaeter im Build fehlen.${NC}"
    echo -e "${YELLOW}Es werden nur bekannte Ruflo-Abhaengigkeiten in pnpm-workspace.yaml unter allowBuilds: true eingetragen.${NC}"

    if [ "${RUFLO_APPROVE_BUILDS:-}" = "1" ] || [ "${RUFLO_APPROVE_BUILDS:-}" = "true" ]; then
        answer="j"
    else
        read -r -p "Bekannte Ruflo-Build-Abhaengigkeiten gezielt erlauben und pnpm install wiederholen? [j/N] " answer
    fi

    case "${answer:-N}" in
        j|J|y|Y)
            write_pnpm_allowed_builds_config
            echo -e "${BLUE}pnpm install wird mit gezielter Build-Freigabe erneut ausgefuehrt...${NC}"
            pnpm install --no-frozen-lockfile
            echo -e "${BLUE}Fuehre pnpm rebuild fuer freigegebene native Pakete aus...${NC}"
            pnpm rebuild
            return $?
            ;;
        *)
            echo -e "${YELLOW}Keine Build-Skripte freigegeben. Wenn der Build fehlschlaegt, fuehre im Ruflo-Verzeichnis bewusst 'pnpm approve-builds' aus oder setze RUFLO_APPROVE_BUILDS=1.${NC}"
            return 1
            ;;
    esac
}

has_pnpm_ignored_builds() {
    command -v pnpm >/dev/null 2>&1 || return 1
    pnpm ignored-builds >/tmp/ruflo_pnpm_ignored_builds.txt 2>/dev/null || return 1
    grep -qE '^[[:space:]]*[[:alnum:]_@./-]+' /tmp/ruflo_pnpm_ignored_builds.txt
}

detect_ruflo_repo() {
    local repo
    for repo in "${RUFLO_REPOS[@]}"; do
        [ -z "$repo" ] && continue
        if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
            echo "$repo"
            return 0
        fi
    done
    return 1
}

backup_and_reset_ruflo_repo_changes() {
    local backup_dir

    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        return 0
    fi

    backup_dir="$HOME/.openclaw_ultimate_user_data/backups/ruflo_git_dirty_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    echo -e "${YELLOW}Lokale Aenderungen im Ruflo-Upstream-Checkout erkannt.${NC}"
    echo -e "${YELLOW}Sie stammen meist von vorherigen pnpm-install/build-Laeufen und wuerden das Update blockieren.${NC}"
    echo -e "${YELLOW}Sichere Diff/Status nach:${NC} $backup_dir"

    git status --short > "$backup_dir/git_status.txt" 2>/dev/null || true
    git diff > "$backup_dir/worktree.diff" 2>/dev/null || true
    git diff --cached > "$backup_dir/index.diff" 2>/dev/null || true
    git ls-files --others --exclude-standard > "$backup_dir/untracked_files.txt" 2>/dev/null || true

    echo -e "${BLUE}Setze /opt/ruflo auf den sauberen Upstream-Stand zurueck...${NC}"
    git reset --hard
    git clean -fd
}

clone_or_update_repo() {
    local repo_url="$1"

    if [ -d "$RUFLO_DIR/.git" ]; then
        echo -e "${YELLOW}Ruflo-Verzeichnis $RUFLO_DIR existiert bereits. Aktualisiere Repository...${NC}"
        cd "$RUFLO_DIR"
        backup_and_reset_ruflo_repo_changes
        git pull --ff-only
        return
    fi

    if [ -d "$RUFLO_DIR" ] && [ ! -d "$RUFLO_DIR/.git" ]; then
        echo -e "${RED}Fehler: $RUFLO_DIR existiert, ist aber kein Git-Repository.${NC}"
        echo -e "${YELLOW}Bitte sichern oder entfernen Sie das Verzeichnis und starten Sie das Skript erneut.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Klone Ruflo in $RUFLO_DIR...${NC}"
    run_sudo mkdir -p "$RUFLO_DIR"
    run_sudo chown -R "$USER:$USER" "$RUFLO_DIR"
    git clone "$repo_url" "$RUFLO_DIR"
    cd "$RUFLO_DIR"
}

prepare_ruflo_cli_workspace() {
    echo -e "${BLUE}Bereite Ruflo CLI-Workspace gezielt vor...${NC}"

    if [ -f "$RUFLO_DIR/v3/package.json" ]; then
        echo -e "${BLUE}Nutze pnpm 8.15.0 fuer den Ruflo-v3-Workspace...${NC}"
        echo -e "${BLUE}Installiere Ruflo-v3 Workspace-Abhaengigkeiten...${NC}"
        pnpm_v3 --dir "$RUFLO_DIR/v3" install --no-frozen-lockfile || true
    fi

    if [ -f "$RUFLO_DIR/v3/@claude-flow/memory/package.json" ]; then
        echo -e "${BLUE}Baue @claude-flow/memory vor, falls vorhanden...${NC}"
        pnpm_v3 --dir "$RUFLO_DIR/v3" --filter @claude-flow/memory run build || true
    fi

    if [ -f "$RUFLO_DIR/v3/@claude-flow/swarm/package.json" ]; then
        echo -e "${BLUE}Baue @claude-flow/swarm vor, falls vorhanden...${NC}"
        pnpm_v3 --dir "$RUFLO_DIR/v3" --filter @claude-flow/swarm run build || true
    fi

    if [ -f "$RUFLO_DIR/v3/@claude-flow/cli/package.json" ]; then
        echo -e "${BLUE}Installiere fehlende optionale CLI-Abhaengigkeiten lokal im CLI-Workspace...${NC}"
        pnpm_v3 --dir "$RUFLO_DIR/v3/@claude-flow/cli" add @ruvector/learning-wasm@^0.1.29 --save-optional || true
    fi
}

install_ruflo() {
    if [ ! -f package.json ]; then
        echo -e "${RED}Fehler: Im Ruflo-Repository wurde keine package.json gefunden.${NC}"
        exit 1
    fi

    repair_legacy_or_broken_pnpm_workspace

    echo -e "${BLUE}Installiere Ruflo-Abhaengigkeiten mit pnpm...${NC}"
    if ! pnpm install --no-frozen-lockfile; then
        echo -e "${YELLOW}pnpm install wurde nicht erfolgreich abgeschlossen. Pruefe auf blockierte Build-Skripte...${NC}"
        if grep -qE 'onlyBuiltDependencies:|set this to true or false|Automatically ignored builds during installation|hint: allowBuilds:' pnpm-workspace.yaml 2>/dev/null; then
            repair_legacy_or_broken_pnpm_workspace
            pnpm install --no-frozen-lockfile
        elif ! handle_pnpm_ignored_builds; then
            echo -e "${RED}Fehler: pnpm install fuer Ruflo fehlgeschlagen.${NC}"
            echo -e "${YELLOW}Wenn ERR_PNPM_IGNORED_BUILDS angezeigt wurde, muss die gezielte Build-Freigabe bestaetigt werden.${NC}"
            echo -e "${YELLOW}Nicht-interaktiv kann bewusst RUFLO_APPROVE_BUILDS=1 gesetzt werden.${NC}"
            exit 1
        fi
    else
        if has_pnpm_ignored_builds; then
            if ! handle_pnpm_ignored_builds; then
                echo -e "${RED}Fehler: Ruflo braucht die gezielte Freigabe bekannter pnpm-Build-Skripte.${NC}"
                echo -e "${YELLOW}Ohne diese Freigabe bleiben native Module unvollstaendig und der CLI-Build scheitert reproduzierbar.${NC}"
                echo -e "${YELLOW}Starte erneut und bestaetige mit 'j' oder setze bewusst RUFLO_APPROVE_BUILDS=1.${NC}"
                exit 1
            fi
        fi
    fi

    prepare_ruflo_cli_workspace

    echo -e "${BLUE}Baue Ruflo CLI mit pnpm...${NC}"
    echo -e "${YELLOW}Hinweis:${NC} Der Upstream-Root-Build kompiliert derzeit auch unfertige v3-/Plugin-Bereiche. Fuer die CLI wird gezielt der v3-CLI-Workspace gebaut."
    pnpm_v3 --dir "$RUFLO_DIR/v3" --filter @claude-flow/cli run build || true

    if [ ! -f "$RUFLO_DIR/v3/@claude-flow/cli/dist/src/index.js" ]; then
        echo -e "${RED}Fehler: Ruflo CLI-Build konnte die benoetigte Datei nicht erzeugen.${NC}"
        echo "Fehlende Datei: $RUFLO_DIR/v3/@claude-flow/cli/dist/src/index.js"
        echo -e "${YELLOW}Sichere Optionen:${NC}"
        echo "  cd $RUFLO_DIR"
        echo "  pnpm install --no-frozen-lockfile"
        echo "  npx -y pnpm@8.15.0 --dir v3 --filter @claude-flow/cli run build"
        echo "  node bin/cli.js --help"
        echo -e "${YELLOW}Der komplette Upstream-Befehl 'pnpm build' ist fuer diesen Ruflo-Stand aktuell nicht als Installationskriterium geeignet.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Ruflo CLI-Build ist vorhanden.${NC}"
}

link_ruflo_cli() {
    local cli_path="$RUFLO_DIR/bin/cli.js"

    if [ ! -f "$cli_path" ]; then
        echo -e "${YELLOW}Warnung: Ruflo CLI-Datei wurde nicht gefunden. Ueberspringe globale Verlinkung.${NC}"
        return
    fi

    chmod +x "$cli_path"
    run_sudo ln -sf "$cli_path" /usr/local/bin/ruflo
    run_sudo ln -sf "$cli_path" /usr/local/bin/claude-flow
}

print_summary() {
    echo -e "${GREEN}Ruflo wurde erfolgreich vorbereitet.${NC}"
    echo -e "${YELLOW}Hinweis:${NC} Das Upstream-Paket heisst derzeit intern 'claude-flow', obwohl das Projekt als Ruflo gebrandet ist."
    echo -e "${BLUE}Verfuegbare CLI-Befehle:${NC}"
    echo "  ruflo --help"
    echo "  claude-flow --help"
}

echo -e "${BLUE}Starte Ruflo Installation & Management...${NC}"

RUFLO_REPO_URL="$(detect_ruflo_repo || true)"
if [ -z "$RUFLO_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Ruflo Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprueft wurden ruvnet/ruflo und dwhr-pi/ruflo.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf RUFLO_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

echo -e "${GREEN}1/4: Installiere Grundabhaengigkeiten fuer Ruflo...${NC}"
ensure_base_packages
ensure_nodejs_22
ensure_pnpm

echo -e "${GREEN}2/4: Hole Ruflo aus GitHub...${NC}"
clone_or_update_repo "$RUFLO_REPO_URL"

echo -e "${GREEN}3/4: Installiere und baue Ruflo...${NC}"
install_ruflo

echo -e "${GREEN}4/4: Richte Ruflo CLI ein...${NC}"
link_ruflo_cli
print_summary
