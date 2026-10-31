#!/usr/bin/env bash
set -euo pipefail
WM_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
WM_URL=https://github.com/windmill-labs/windmill.git
WM_COMMIT=1fe3858a6d51949327046117d9ce4c10467a3000
WM_RELEASE=v1.837.0
WM_SHA256=5879cd22b178d8871031cc072e5de5052ab46c4bd134e3358ff8a96d25d229aa
WM_ASSET_URL="https://github.com/windmill-labs/windmill/releases/download/$WM_RELEASE/windmill-amd64"

wm_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
  local -a paths=() resolved=()
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$WM_ROOT/"*)
    echo 'Windmill-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  WM_BASE="$root/tools/windmill"
  WM_SOURCE="$WM_BASE/source"
  WM_BINARY="$WM_BASE/bin/windmill"
  WM_BINARY_MARKER="$WM_BASE/binary-ready"
  WM_MARKER="$WM_BASE/source-ready"
  WM_LOGS="$root/install_logs"
  paths=("$root" "$WM_BASE" "$WM_SOURCE" "$WM_SOURCE/.git" "$WM_MARKER" "$WM_BINARY_MARKER" "$WM_BASE/bin" "$WM_BINARY" "$WM_LOGS" "$WM_BASE/operation.lock")
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Windmill: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

wm_source_ok() {
  [[ -d "$WM_SOURCE/.git" && ! -e "$WM_SOURCE/.env" && ! -L "$WM_SOURCE/.env" ]] &&
    [[ "$(git -C "$WM_SOURCE" rev-parse --show-toplevel)" == "$WM_SOURCE" ]] &&
    [[ "$(git -C "$WM_SOURCE" remote get-url origin)" == "$WM_URL" ]] &&
    [[ "$(git -C "$WM_SOURCE" rev-parse HEAD)" == "$WM_COMMIT" ]] &&
    [[ "$(git -C "$WM_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
    [[ "$(git -C "$WM_SOURCE" sparse-checkout list)" == "$(wm_sparse_patterns)" ]] &&
    [[ -z "$(git -C "$WM_SOURCE" status --porcelain --untracked-files=all)" ]]
}

wm_inspect() {
  wm_source_ok || return 1
  python3 -I -B - "$WM_SOURCE" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('backend/Cargo.toml', 'backend/Cargo.lock', 'backend/src/main.rs', 'frontend/package.json', 'LICENSE', 'LICENSE-AGPL', 'LICENSE-APACHE'):
    assert (root / name).is_file(), name
import json
assert json.loads((root / 'frontend/package.json').read_text())['version'] == '1.837.0'
assert not (root / '.env').exists()
print('Windmill-Pin und Paketlayout geprueft; kein Build, Import oder Serverstart.')
PY
}

wm_sparse_patterns() {
  # Exclude upstream env defaults, hooks and agent configs from the working tree.
  cat <<'PATTERNS'
/README.md
/LICENSE
/LICENSE-AGPL
/LICENSE-APACHE
/NOTICE
/version.txt
/CONTRIBUTING.md
/backend/
/frontend/
/typescript-client/
/python-client/
/go-client/
/rust-client/
/windmill-yaml-validator/
/openflow.openapi.yaml
!.env
!.env.*
!.envrc
!*.pem
!*.key
PATTERNS
}

wm_sparse_checkout() {
  wm_sparse_patterns | git -C "$WM_SOURCE" sparse-checkout set --no-cone --stdin
}

wm_fetch() {
  if [[ -e "$WM_SOURCE" ]]; then
    wm_source_ok || {
      echo 'Windmill-Quelle fremd/unvollstaendig/veraendert oder voller Checkout; manuell sichern. Kein Reset/Loeschen.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$WM_SOURCE"
    git -C "$WM_SOURCE" remote add origin "$WM_URL"
    wm_sparse_checkout
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$WM_SOURCE" fetch --filter=blob:none --depth 1 origin "$WM_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$WM_SOURCE" checkout --detach FETCH_HEAD
  fi
  wm_inspect || return 1
  printf '%s\n' "$WM_COMMIT" >"$WM_MARKER"
  echo 'Windmill-GitHub-Quellen vorbereitet; kein betriebsbereiter Workflow-Dienst. PostgreSQL/Worker/Runtimes separat einrichten.'
}

wm_deactivate() {
  rm -f -- "$WM_MARKER" "$WM_BINARY_MARKER"
  source "$WM_ROOT/scripts/helpers/native_tool_status.sh"
  native_tool_sync_status Windmill "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" || return 1
  echo 'Windmill-Quellregistrierung deaktiviert; Quelle, Binary, eigene Daten und Logs bleiben erhalten.'
}

wm_binary_preflight() {
  [[ "${WINDMILL_INSTALL_BINARY:-0}" == 0 || "${WINDMILL_INSTALL_BINARY:-0}" == 1 ]] || return 2
  [[ "${WINDMILL_ACCEPT_RELEASE_TERMS:-0}" == 1 ]] || {
    echo 'GitHub-Release-Binary hat eigene Community-Edition-Bedingungen. Erst docs/tools/windmill.md lesen, dann WINDMILL_ACCEPT_RELEASE_TERMS=1.' >&2
    return 2
  }
  [[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || {
    echo 'Dieser Pin bietet nur Linux-amd64 als nicht-EE-Binary. ARM/Windows/macOS: Quellpfad, kein falsches Asset verwenden.' >&2
    return 1
  }
  { command -v curl >/dev/null && command -v sha256sum >/dev/null; } || {
    echo 'curl/sha256sum fehlen; separat einrichten.' >&2
    return 1
  }
}

wm_binary_executable() { [[ -x "$WM_BINARY" ]]; }

wm_binary_ok() {
  local hash
  [[ -f "$WM_BINARY" && ! -L "$WM_BINARY" ]] && wm_binary_executable || return 1
  hash="$(sha256sum "$WM_BINARY")"
  [[ "${hash%% *}" == "$WM_SHA256" ]]
}

wm_install_binary() (
  set -euo pipefail
  local tmp
  if [[ -e "$WM_BINARY" ]]; then
    wm_binary_ok || {
      echo 'Windmill-Binary abweichend; bleibt erhalten. Manuell sichern/pruefen, kein Ueberschreiben.' >&2
      return 1
    }
  else
    mkdir -p "$WM_BASE/bin"
    tmp="$(mktemp "$WM_BASE/bin/.download_XXXXXX")"
    trap 'rm -f -- "$tmp"' EXIT
    curl --fail --location --proto '=https' --proto-redir '=https' --tlsv1.2 \
      --retry 2 --connect-timeout 15 --max-time 900 \
      --output "$tmp" "$WM_ASSET_URL"
    printf '%s  %s\n' "$WM_SHA256" "$tmp" | sha256sum --check --status
    python3 -I -B - "$tmp" <<'PY'
from pathlib import Path
import sys
with Path(sys.argv[1]).open('rb') as handle:
    header = handle.read(20)
assert header[:6] == bytes([127, 69, 76, 70, 2, 1]) and header[18:20] == bytes([62, 0]), 'Kein Linux x86_64 ELF'
PY
    chmod 700 "$tmp"
    mv -- "$tmp" "$WM_BINARY"
  fi
  wm_binary_ok
  printf '%s %s\n' "$WM_COMMIT" "$WM_SHA256" >"$WM_BINARY_MARKER"
  echo 'Nativer GitHub-Release installiert und SHA256 geprueft; Binary NICHT ausgefuehrt, kein Server/Worker gestartet.'
)

windmill_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" program mount log binary=false
  wm_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Windmill GitHub: $WM_URL; Pin $WM_COMMIT; ohne Docker."
      echo 'Standard: gepinnte GitHub-Quellen ohne .env und Hooks. Optional WINDMILL_INSTALL_BINARY=1 + WINDMILL_ACCEPT_RELEASE_TERMS=1 fuer Linux-amd64-Release. Kein Build/Dienst/DB/Workerstart.'
      echo 'Reserve Quellen 2 GiB Disk/Windows-C:, mit Binary 4 GiB; Dry-Run ohne Download oder Import.'
      return 0
      ;;
    status | --status)
      if [[ -f "$WM_MARKER" && "$(<"$WM_MARKER")" == "$WM_COMMIT" ]] && wm_source_ok >/dev/null 2>&1; then
        if [[ -f "$WM_BINARY_MARKER" && "$(<"$WM_BINARY_MARKER")" == "$WM_COMMIT $WM_SHA256" ]] && wm_binary_ok >/dev/null 2>&1; then binary=true; fi
        printf '{"source_ready":true,"binary_installed":%s,"runtime_ready":false}\n' "$binary"
      else echo '{"source_ready":false,"binary_installed":false,"runtime_ready":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$WM_MARKER" && "$(<"$WM_MARKER")" == "$WM_COMMIT" ]] && wm_inspect || return 1
      if [[ -e "$WM_BINARY_MARKER" ]]; then
        [[ "$(<"$WM_BINARY_MARKER")" == "$WM_COMMIT $WM_SHA256" ]] && wm_binary_ok || return 1
      fi
      echo 'Quellen/ggf. Binary-Hash geprueft; keine PostgreSQL-/Server-/Workerbereitschaft bestaetigt.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Windmill: nur Quellverwaltung, kein App-/Workflow-/Serverstart.' >&2
      return 2
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git python3 flock; do command -v "$program" >/dev/null || {
    echo "Windmill: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    [[ "${WINDMILL_INSTALL_BINARY:-0}" == 0 || "${WINDMILL_INSTALL_BINARY:-0}" == 1 ]] || {
      echo 'WINDMILL_INSTALL_BINARY muss 0 oder 1 sein.' >&2
      return 2
    }
    if [[ "${WINDMILL_INSTALL_BINARY:-0}" == 1 ]]; then wm_binary_preflight || return $?; fi
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$WM_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$WM_ROOT/scripts/lib/resource_check.sh"
    if [[ "${WINDMILL_INSTALL_BINARY:-0}" == 1 ]]; then
      REQUIRE_WINDOWS_HOST_FREE_MB=4096 require_disk_mb 4096 "$mount"
    else REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"; fi
  elif [[ ! -d "$WM_BASE" ]]; then
    wm_deactivate
    return $?
  fi
  mkdir -p "$WM_BASE" "$WM_LOGS"
  exec 9>"$WM_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Windmill-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$WM_LOGS/windmill_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Windmill-Installer: 2026-10-16-github-source-native-release; Aktion: $mode; Pin: $WM_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "Windmill-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    wm_deactivate
    return 0
  fi
  df -Pk "$WM_BASE"
  wm_fetch
  if [[ "${WINDMILL_INSTALL_BINARY:-0}" == 1 ]]; then wm_install_binary; fi
  df -Pk "$WM_BASE"
)
