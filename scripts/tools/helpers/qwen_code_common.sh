#!/usr/bin/env bash
set -euo pipefail
QWEN_CODE_REPO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
QWEN_CODE_SOURCE_URL=https://github.com/QwenLM/qwen-code.git
QWEN_CODE_SOURCE_COMMIT=c1a8218f38203e272e6e965778ed6a2795cfeed7
QWEN_CODE_RUNTIME_REVISION=2026-10-16-private-node-corepack-bootstrap-ram-budget
QWEN_CODE_PNPM_SPEC=pnpm@11.24.0+sha512.bd27e345e976dcb0be0b7a1228217b049a817e21b1f355c90dbe7dc46671895a8bc1e6d06c24554505ea93ea0b45f489a27ec1bfbc8de6a9659fca0f16fa0000

qwen_code_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$QWEN_CODE_REPO_ROOT/"*)
    echo 'User-Daten muessen ausserhalb des Setup-Repos liegen.' >&2
    return 1
    ;;
  esac
  QWEN_CODE_BASE="$root/tools/qwen_code"
  QWEN_CODE_SOURCE_DIR="$QWEN_CODE_BASE/source"
  QWEN_CODE_MARKER="$QWEN_CODE_BASE/source-built"
  QWEN_CODE_LOG_DIR="$root/install_logs"
  QWEN_CODE_NVM_DIR="$QWEN_CODE_BASE/runtime/nvm"
  QWEN_CODE_COREPACK_DIR="$QWEN_CODE_BASE/runtime/corepack"
  export COREPACK_HOME="$QWEN_CODE_BASE/runtime/corepack-cache"
  export COREPACK_ENV_FILE=0 COREPACK_ENABLE_AUTO_PIN=0 COREPACK_DEFAULT_TO_LATEST=0
  local -a paths=("$root" "$QWEN_CODE_BASE" "$QWEN_CODE_SOURCE_DIR" "$QWEN_CODE_MARKER" "$QWEN_CODE_LOG_DIR" "$QWEN_CODE_BASE/operation.lock" "$QWEN_CODE_BASE/build-home" "$QWEN_CODE_NVM_DIR" "$QWEN_CODE_NVM_DIR/nvm.sh" "$QWEN_CODE_COREPACK_DIR" "$QWEN_CODE_COREPACK_DIR/node_modules" "$QWEN_CODE_COREPACK_DIR/node_modules/.bin" "$QWEN_CODE_COREPACK_DIR/node_modules/corepack" "$COREPACK_HOME") resolved=()
  local index=0
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Qwen Code: nicht normalisierter Pfad/Symlink; nichts veraendert.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

qwen_code_require_base_tools() {
  local program
  for program in git flock; do
    command -v "$program" >/dev/null || {
      echo "Qwen Code: $program fehlt; separat einrichten." >&2
      return 1
    }
  done
}

qwen_code_node_compatible() {
  local version
  command -v node >/dev/null && command -v npm >/dev/null || return 1
  node -e 'const [a,b]=process.versions.node.split(".").map(Number);if(a!==22||b<22)process.exit(1)' || return 1
  version="$(npm --version)" || return 1
  [[ "$version" =~ ^([0-9]+)\. ]] && ((BASH_REMATCH[1] >= 10))
}

qwen_code_activate_private_node() {
  [[ -s "$QWEN_CODE_NVM_DIR/nvm.sh" && -d "$QWEN_CODE_NVM_DIR/.git" && ! -L "$QWEN_CODE_NVM_DIR/.git" ]] || return 1
  [[ "$(git -C "$QWEN_CODE_NVM_DIR" remote get-url origin)" == https://github.com/nvm-sh/nvm.git ]] || return 1
  git -C "$QWEN_CODE_NVM_DIR" diff --quiet HEAD -- nvm.sh || return 1
  export NVM_DIR="$QWEN_CODE_NVM_DIR"
  # shellcheck disable=SC1090
  source "$NVM_DIR/nvm.sh" --no-use || return 1
  nvm use 22 >/dev/null 2>&1
}

qwen_code_activate_private_tools() {
  local binary="$QWEN_CODE_COREPACK_DIR/node_modules/.bin/corepack"
  [[ -f "$binary" && "$(realpath -m -- "$binary")" == "$QWEN_CODE_COREPACK_DIR/node_modules/corepack/dist/corepack.js" ]] || return 1
  export PATH="$QWEN_CODE_COREPACK_DIR/node_modules/.bin:$PATH"
  hash -r
  [[ "$(COREPACK_ENABLE_NETWORK=0 corepack --version)" == 0.34.0 ]]
}

qwen_code_tools_compatible() {
  command -v pnpm >/dev/null && command -v corepack >/dev/null || return 1
  [[ "$(COREPACK_ENABLE_PROJECT_SPEC=0 COREPACK_ENABLE_NETWORK=0 pnpm --version)" == 11.24.0 &&
  "$(COREPACK_ENABLE_PROJECT_SPEC=0 COREPACK_ENABLE_NETWORK=0 corepack pnpm --version)" == 11.24.0 ]]
}

qwen_code_runtime_check() {
  qwen_code_require_base_tools || return 1
  if [[ -s "$QWEN_CODE_NVM_DIR/nvm.sh" ]] || ! qwen_code_node_compatible >/dev/null 2>&1; then
    qwen_code_activate_private_node || true
  fi
  qwen_code_node_compatible || {
    echo 'Qwen Code: Node 22.22+/npm >=10 fehlt; Installation/Repair nutzen. Kein Download bei diesem Check.' >&2
    return 1
  }
  qwen_code_activate_private_tools || true
  qwen_code_tools_compatible || {
    echo 'Qwen Code: pnpm 11.24.0/Corepack-Cache fehlt; Installation/Repair nutzen. Kein Download bei diesem Check.' >&2
    return 1
  }
}

qwen_code_load_node_helper() {
  # shellcheck disable=SC1091
  source "$QWEN_CODE_REPO_ROOT/scripts/tools/helpers/node_tool_common.sh"
  # Bound only inside qwen_code_main's installation subshell.
  check_node_tool_runtime() { qwen_code_node_compatible; }
}

qwen_code_install_private_tools() {
  mkdir -p "$QWEN_CODE_COREPACK_DIR" || return 1
  npm install --prefix "$QWEN_CODE_COREPACK_DIR" --global=false --ignore-scripts \
    --no-audit --no-fund --package-lock=false --engine-strict \
    --registry=https://registry.npmjs.org corepack@0.34.0 || return 1
  qwen_code_activate_private_tools
}

qwen_code_cache_package_manager() {
  # --global changes only this tool's private COREPACK_HOME/default, not system shims.
  COREPACK_ENABLE_PROJECT_SPEC=0 COREPACK_ENABLE_NETWORK=1 corepack install --global "$QWEN_CODE_PNPM_SPEC"
}

qwen_code_prepare_runtime() {
  if qwen_code_runtime_check >/dev/null 2>&1; then return 0; fi
  [[ "${QWEN_CODE_AUTO_RUNTIME:-1}" == 1 ]] || {
    echo 'Qwen Code: automatischer Runtime-Download durch QWEN_CODE_AUTO_RUNTIME=0 deaktiviert.' >&2
    return 1
  }
  qwen_code_require_base_tools || return 1
  if ! qwen_code_node_compatible >/dev/null 2>&1; then
    echo "Qwen Code: stelle Node 22/npm privat via GitHub-nvm bereit: $QWEN_CODE_NVM_DIR"
    qwen_code_load_node_helper || return 1
    export NVM_DIR="$QWEN_CODE_NVM_DIR"
    TOOL_NAME=Qwen_Code
    TOOL_NODE_MIN_VERSION=22.22.0
    if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then unset -f nvm 2>/dev/null || true; fi
    ensure_node_tool_runtime || return 1
    qwen_code_node_compatible || return 1
  fi
  if ! qwen_code_tools_compatible; then
    if ! qwen_code_activate_private_tools; then qwen_code_install_private_tools || return 1; fi
    echo 'Qwen Code: stelle pnpm 11.24.0 im privaten Corepack-Cache bereit.'
    qwen_code_cache_package_manager || return 1
  fi
  qwen_code_runtime_check
}

qwen_code_require_user() {
  [[ "$EUID" != 0 ]] || {
    echo 'Qwen Code als normaler Benutzer bauen, nicht sudo/root.' >&2
    return 1
  }
}

qwen_code_ram_budget() {
  local total="$1" available="$2"
  [[ "$total" =~ ^[0-9]+$ && "$available" =~ ^[0-9]+$ ]] || {
    echo 'Qwen Code: RAM-Messwerte fehlen/ungueltig; kein Build gestartet.' >&2
    return 1
  }
  echo "Qwen Code RAM (MiB): gesamt=$total, aktuell verfuegbar=$available; Reserve: gesamt >=7168, verfuegbar >=5120."
  if ((total < 7168 || available < 5120)); then
    echo 'Qwen Code: zu wenig RAM fuer den Source-Build. Andere schwere Jobs beenden oder auf groesserem Buildhost bauen. Kein automatischer Swap-/WSL-Umbau.' >&2
    return 1
  fi
  if ((total < 8192)); then
    echo 'Hinweis: 8-GB-Geraeteklasse unter 8192 MiB nutzbarem RAM; Grenzfall, kein garantierter Build-Erfolg.'
  fi
}

qwen_code_resources() {
  # shellcheck disable=SC1091
  source "$QWEN_CODE_REPO_ROOT/scripts/lib/resource_check.sh"
  local total available
  total="$(snapshot_ram_mb)"
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  qwen_code_ram_budget "$total" "$available" || return 1
  REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 10240 "$1"
}

qwen_code_lock() {
  mkdir -p "$QWEN_CODE_BASE" || return 1
  exec 9>"$QWEN_CODE_BASE/operation.lock"
  flock -n 9 || {
    echo 'Qwen Code: andere Build-/Deaktivierungsaktion laeuft.' >&2
    return 1
  }
}

qwen_code_verify_source() {
  local origin head changes
  [[ -d "$QWEN_CODE_SOURCE_DIR/.git" && ! -L "$QWEN_CODE_SOURCE_DIR/.git" ]] || {
    echo 'Qwen Code: unvollstaendiger Checkout; manuell sichern/pruefen, keine automatische Loeschung.' >&2
    return 1
  }
  origin="$(git -C "$QWEN_CODE_SOURCE_DIR" remote get-url origin)" || return 1
  head="$(git -C "$QWEN_CODE_SOURCE_DIR" rev-parse HEAD)" || return 1
  changes="$(git -C "$QWEN_CODE_SOURCE_DIR" status --porcelain --untracked-files=normal)" || return 1
  [[ "$origin" == "$QWEN_CODE_SOURCE_URL" && "$head" == "$QWEN_CODE_SOURCE_COMMIT" && -z "$changes" ]] || {
    echo 'Qwen Code: Quelle, Commit oder lokale Aenderungen abweichend. Kein Reset/Pull/Ueberschreiben.' >&2
    return 1
  }
}

qwen_code_is_built() {
  [[ -f "$QWEN_CODE_MARKER" && -f "$QWEN_CODE_SOURCE_DIR/dist/cli.js" &&
    -f "$QWEN_CODE_SOURCE_DIR/scripts/cli-entry.js" ]] &&
    grep -Fxq "$QWEN_CODE_SOURCE_COMMIT" "$QWEN_CODE_MARKER"
}

qwen_code_smoke() (
  cd "$QWEN_CODE_SOURCE_DIR" || exit 1
  [[ -f dist/cli.js && -f scripts/cli-entry.js ]] || exit 1
  node --check dist/cli.js && node --check scripts/cli-entry.js
)

qwen_code_build() (
  local mode="$1" mount="$QWEN_CODE_BASE" log before started
  qwen_code_require_base_tools || return 1
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  qwen_code_resources "$mount" || return 1
  qwen_code_lock || return 1
  if [[ -e "$QWEN_CODE_SOURCE_DIR" ]]; then qwen_code_verify_source || return 1; fi
  if [[ "$mode" == install ]] && qwen_code_is_built && qwen_code_runtime_check >/dev/null 2>&1; then
    qwen_code_smoke || return 1
    echo 'Qwen Code Source-Build bereits vorhanden; kein Agent gestartet.'
    return 0
  fi
  mkdir -p "$QWEN_CODE_LOG_DIR" || return 1
  log="$QWEN_CODE_LOG_DIR/$(date +%Y%m%d_%H%M%S)_qwen_code_source_$$.log"
  before="$(df -Pk "$mount" | awk 'NR==2 {print $4}')"
  started="$SECONDS"
  exec > >(tee -a "$log") 2>&1
  trap 'rc=$?; printf "Qwen Code Build Exit=%s Dauer=%ss Disk-vorher-KiB=%s\n" "$rc" "$((SECONDS-started))" "$before"; df -Pk "$mount"; exit "$rc"' EXIT
  echo "Qwen Code GitHub-Source $QWEN_CODE_SOURCE_COMMIT; kein Docker, Login- oder Agentenstart."
  qwen_code_prepare_runtime || {
    echo 'Qwen Code: Runtime-Bereitstellung fehlgeschlagen; kein neuer Erfolgsmarker.' >&2
    return 1
  }
  if [[ "$mode" == install ]] && qwen_code_is_built; then
    qwen_code_smoke || return 1
    echo 'Qwen Code: private Runtime wiederhergestellt, vorhandenen Build geprueft.'
    return 0
  fi
  if [[ ! -e "$QWEN_CODE_SOURCE_DIR" ]]; then
    git init "$QWEN_CODE_SOURCE_DIR" || return 1
    git -C "$QWEN_CODE_SOURCE_DIR" remote add origin "$QWEN_CODE_SOURCE_URL" || return 1
    GIT_TERMINAL_PROMPT=0 git -C "$QWEN_CODE_SOURCE_DIR" fetch --depth 1 origin "$QWEN_CODE_SOURCE_COMMIT" || return 1
    git -C "$QWEN_CODE_SOURCE_DIR" -c advice.detachedHead=false checkout --detach "$QWEN_CODE_SOURCE_COMMIT" || return 1
  fi
  qwen_code_verify_source || return 1
  rm -f -- "$QWEN_CODE_MARKER" || return 1
  (
    cd "$QWEN_CODE_SOURCE_DIR" || exit 1
    [[ -f pnpm-lock.yaml && -f pnpm-workspace.yaml && -f package.json ]] || exit 1
    # Pinned dependency lifecycle scripts may run; never invoke the agent entry point.
    export BUILD_SANDBOX=0 QWEN_SANDBOX=false QWEN_SKIP_PREPARE=1 HUSKY=0
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 PUPPETEER_SKIP_DOWNLOAD=1 COREPACK_ENABLE_NETWORK=0
    export COREPACK_ENABLE_PROJECT_SPEC=1 COREPACK_ENABLE_STRICT=1
    export QWEN_HOME="$QWEN_CODE_BASE/build-home"
    pnpm install --frozen-lockfile --child-concurrency=1 --network-concurrency=4 && pnpm run build --cli-only && pnpm run bundle
  ) || {
    echo 'Qwen Code Build fehlgeschlagen. Privates Log, Node/pnpm und native Build-Werkzeuge pruefen.' >&2
    return 1
  }
  qwen_code_smoke || {
    echo 'Qwen Code: Build/Syntax-Test fehlgeschlagen.' >&2
    return 1
  }
  printf '%s\n' "$QWEN_CODE_SOURCE_COMMIT" >"$QWEN_CODE_MARKER" || return 1
  echo 'Qwen Code aus GitHub gebaut. Kein globales CLI, kein Dienst, keine Authentifizierung oder Modellabfrage.'
)

qwen_code_main() (
  umask 077
  echo "Qwen-Code-Runtime: $QWEN_CODE_RUNTIME_REVISION"
  local mode="${1:---dry-run}"
  case "$mode" in
    --dry-run | --plan | plan) mode=plan ;; --check | check | --status | status) mode=status ;;
    --repair | repair) mode=update ;; --uninstall) mode=uninstall ;;
    install | update | uninstall | doctor) ;;
    *)
      echo 'Qwen Code: nur Source-Build/Status/Doctor/Deaktivierung. Agentenstart und Login bleiben gesperrt.' >&2
      return 2
      ;;
  esac
  qwen_code_paths || return 1
  if [[ "$mode" == plan ]]; then
    echo "Qwen Code: GitHub $QWEN_CODE_SOURCE_COMMIT, pnpm 11.24.0, Node 22.x; ohne Docker."
    echo 'Planungsreserve: RAM gesamt >=7168 MiB und aktuell verfuegbar >=5120 MiB; empfohlen >=8 GiB. Disk/WSL-Hostreserve je 10 GiB. Kein Download/Start im Dry-Run.'
    return 0
  fi
  if [[ "$mode" == status || "$mode" == doctor ]]; then
    qwen_code_is_built && qwen_code_verify_source || {
      echo 'Qwen Code: kein verifizierter Source-Build vorhanden.' >&2
      return 1
    }
    if [[ "$mode" == doctor ]]; then qwen_code_runtime_check && qwen_code_smoke || return 1; fi
    echo 'Qwen Code Source-Build vorhanden; Agent-/Login-Status wird nicht gelesen.'
    return 0
  fi
  qwen_code_require_user || return 1
  if [[ "$mode" == uninstall ]]; then
    command -v git >/dev/null && command -v flock >/dev/null || return 1
    qwen_code_lock || return 1
    if [[ -e "$QWEN_CODE_SOURCE_DIR" ]]; then
      qwen_code_verify_source || return 1
      local disabled="$QWEN_CODE_BASE/source.disabled.$(date +%Y%m%d_%H%M%S).$$"
      [[ ! -e "$disabled" ]] || return 1
      mv -- "$QWEN_CODE_SOURCE_DIR" "$disabled" || return 1
    fi
    rm -f -- "$QWEN_CODE_MARKER" || return 1
    echo 'Build deaktiviert, Quellcode gesichert. Keine Prozesse, Logins oder Runtime-Daten angefasst.'
    return 0
  fi
  qwen_code_build "$mode"
)
