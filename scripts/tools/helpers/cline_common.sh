#!/usr/bin/env bash
set -euo pipefail
CLINE_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
CLINE_VERSION=4.1.25
CLINE_SHA256=aac83af0513f5168372905c02a72eee3835d32a53b9d635d3b055ed4a7bd71fc
CLINE_URL=https://github.com/cline/cline/releases/download/v4.1.25/cline-4.1.25.vsix

cline_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$CLINE_ROOT/"*)
    echo 'Cline-Workspace muss ausserhalb des Repos liegen.' >&2
    return 1
    ;;
  esac
  CLINE_BASE="$root/tools/cline"
  CLINE_PACKAGE="$CLINE_BASE/cline-$CLINE_VERSION.vsix"
  CLINE_MARKER="$CLINE_BASE/release-ready"
  CLINE_LOGS="$root/install_logs"
  for path in "$root" "$CLINE_BASE" "$CLINE_PACKAGE" "$CLINE_MARKER" "$CLINE_LOGS" "$CLINE_BASE/operation.lock"; do
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
      echo 'Cline: Symlink oder nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
  done
}

cline_verify() {
  local package="${1:-$CLINE_PACKAGE}" actual
  [[ -f "$package" && ! -L "$package" ]] || return 1
  actual="$(sha256sum -- "$package")" || return 1
  [[ "${actual%% *}" == "$CLINE_SHA256" ]] || {
    echo 'Cline: SHA-256 stimmt nicht.' >&2
    return 1
  }
  python3 -I -B - "$package" <<'PY'
import json
import sys
import zipfile
with zipfile.ZipFile(sys.argv[1]) as archive:
    info = archive.getinfo('extension/package.json')
    assert info.file_size < 2 * 1024 * 1024
    package = json.loads(archive.read(info))
    assert package['name'] == 'claude-dev'
    assert package['publisher'] == 'saoudrizwan'
    assert package['version'] == '4.1.25'
    assert 'extension/dist/extension.js' in archive.namelist()
print('VSIX-Hash, Identitaet und Version geprueft; kein Extension-Code ausgefuehrt.')
PY
}

cline_ready() {
  [[ -f "$CLINE_MARKER" && "$(<"$CLINE_MARKER")" == "$CLINE_SHA256" ]] && cline_verify
}

cline_fetch() {
  local temp
  if [[ -e "$CLINE_PACKAGE" ]]; then
    cline_verify || {
      echo 'Vorhandenes Paket abweichend; manuell sichern, kein automatisches Ueberschreiben.' >&2
      return 1
    }
  else
    temp="$(mktemp "$CLINE_BASE/.download.XXXXXX")" || return 1
    # Only the pinned GitHub asset; HTTPS also enforced after redirects.
    if ! curl --fail --location --proto '=https' --proto-redir '=https' \
      --connect-timeout 15 --max-time 300 --max-filesize 33554432 \
      "$CLINE_URL" --output "$temp" || ! cline_verify "$temp"; then
      rm -f -- "$temp"
      echo 'Cline: Download/Validierung fehlgeschlagen; kein neuer Erfolgsmarker.' >&2
      return 1
    fi
    mv -- "$temp" "$CLINE_PACKAGE" || return 1
  fi
  printf '%s\n' "$CLINE_SHA256" >"$CLINE_MARKER"
  echo "GitHub-VSIX bereitgestellt: $CLINE_PACKAGE"
  echo 'Noch NICHT im Editor installiert. VS Code: Extensions > ... > Install from VSIX.'
  echo 'Kein Docker, Marketplace-Download, Login, Agentenstart oder Modellabruf.'
}

cline_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" program mount log
  cline_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      printf 'Cline GitHub-Release v%s, ohne Docker: %s\nSHA-256: %s\n' "$CLINE_VERSION" "$CLINE_URL" "$CLINE_SHA256"
      echo 'Nur VSIX-Bereitstellung; Editor-Installation separat. Kein Download im Dry-Run.'
      return 0
      ;;
    status | --status)
      if cline_ready >/dev/null 2>&1; then
        echo '{"package_ready":true,"editor_installation":"not_checked","scope":"github-vsix"}'
      else
        echo '{"package_ready":false,"editor_installation":"not_checked","scope":"github-vsix"}'
      fi
      return 0
      ;;
    doctor | check | --check)
      cline_ready || {
        echo 'Cline: geprueftes GitHub-Paket fehlt/ist inkonsistent; explizit installieren.' >&2
        return 1
      }
      echo 'Doctor prueft nur das VSIX-Paket, keine Editor-/Providerfunktion.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Cline: nur GitHub-Paketverwaltung; keine Agenten-/Editorstart-Aktion.' >&2
      return 2
      ;;
  esac
  [[ "$EUID" != 0 ]] || {
    echo 'Cline als normaler Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in python3 sha256sum flock; do
    command -v "$program" >/dev/null || {
      echo "Cline: Basiswerkzeug $program fehlt; separat einrichten." >&2
      return 1
    }
  done
  python3 -I -B -c 'import sys; assert sys.version_info >= (3, 10)' || return 1
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v curl >/dev/null || {
      echo 'Cline: curl fehlt; separat einrichten.' >&2
      return 1
    }
    mount="$CLINE_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$CLINE_ROOT/scripts/lib/resource_check.sh"
    REQUIRE_WINDOWS_HOST_FREE_MB=1024 require_disk_mb 256 "$mount"
  elif [[ ! -d "$CLINE_BASE" ]]; then
    echo 'Kein Cline-Paket bereitgestellt; nichts entfernt.'
    return 0
  fi
  mkdir -p "$CLINE_BASE" "$CLINE_LOGS"
  exec 9>"$CLINE_BASE/operation.lock"
  flock -n 9 || {
    echo 'Cline: andere Paketoperation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$CLINE_LOGS/cline_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Cline-Installer: 2026-10-16-github-vsix; Aktion: $mode"
  echo "GitHub: $CLINE_URL"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "Cline: Fehler ($rc). Log: $log; nach Behebung erneut starten."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    if [[ -e "$CLINE_PACKAGE" ]]; then
      cline_verify || {
        echo 'Abweichendes Paket wird nicht geloescht.' >&2
        return 1
      }
      rm -f -- "$CLINE_PACKAGE"
    fi
    rm -f -- "$CLINE_MARKER"
    echo 'Verwaltetes Paket entfernt. Vorhandene Editor-Extension, Einstellungen, Keys und Projekte bleiben unberuehrt.'
    return 0
  fi
  cline_fetch
)
