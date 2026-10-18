#!/usr/bin/env bash
set -euo pipefail
DF_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
DF_URL=https://github.com/Rikorose/DeepFilterNet.git
DF_COMMIT=978576aa8400552a4ce9730838c635aa30db5e61

df_paths() {
    local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
    [[ "$root" == /* && "$root" != / ]] || return 1
    case "$root/" in "$DF_ROOT/"*) echo 'DeepFilterNet-Daten nicht im Setup-Repo ablegen.' >&2; return 1 ;; esac
    DF_BASE="$root/tools/deepfilternet"
    DF_SOURCE="$DF_BASE/source"
    DF_TARGET="$DF_BASE/build"
    DF_BINARY="$DF_TARGET/release/deep-filter"
    DF_MARKER="$DF_BASE/source-built"
    DF_LOGS="$root/install_logs"
    for path in "$root" "$DF_BASE" "$DF_SOURCE" "$DF_SOURCE/.git" "$DF_TARGET" "$DF_TARGET/release" "$DF_BINARY" "$DF_MARKER" "$DF_LOGS" "$DF_BASE/operation.lock"; do
        [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
            echo 'DeepFilterNet: Symlink/nicht normalisierter Pfad; Abbruch.' >&2; return 1;
        }
    done
}

df_source_ok() {
    [[ -d "$DF_SOURCE/.git" ]] &&
        [[ "$(git -C "$DF_SOURCE" rev-parse --show-toplevel)" == "$DF_SOURCE" ]] &&
        [[ "$(git -C "$DF_SOURCE" remote get-url origin)" == "$DF_URL" ]] &&
        [[ "$(git -C "$DF_SOURCE" rev-parse HEAD)" == "$DF_COMMIT" ]] &&
        [[ -z "$(git -C "$DF_SOURCE" status --porcelain --untracked-files=all)" ]]
}

df_probe() {
    local digest
    [[ -f "$DF_MARKER" && -x "$DF_BINARY" ]] || return 1
    df_source_ok || return 1
    digest="$(sha256sum "$DF_BINARY")"
    [[ "$(<"$DF_MARKER")" == "$DF_COMMIT ${digest%% *}" ]]
}

df_resources() {
    local mount="$DF_BASE" available
    while [[ ! -d "$mount" ]]; do mount="${mount%/*}"; [[ -n "$mount" ]] || mount=/; done
    # shellcheck source=../../lib/resource_check.sh
    source "$DF_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 6144
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 4096 ]] || {
        echo 'DeepFilterNet-Build braucht mindestens 4096 MiB aktuell verfuegbaren RAM; andere schwere Jobs beenden.' >&2; return 1;
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=8192 require_disk_mb 8192 "$mount"
}

df_fetch() {
    if [[ -e "$DF_SOURCE" ]]; then
        df_source_ok || { echo 'DeepFilterNet-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2; return 1; }
    else
        git -c init.defaultBranch=main init "$DF_SOURCE"
        git -C "$DF_SOURCE" remote add origin "$DF_URL"
        GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$DF_SOURCE" fetch --depth 1 origin "$DF_COMMIT"
        git -c core.hooksPath=/dev/null -C "$DF_SOURCE" checkout --detach FETCH_HEAD
    fi
    df_source_ok || return 1
    [[ -f "$DF_SOURCE/Cargo.lock" && -f "$DF_SOURCE/libDF/Cargo.toml" &&
       -f "$DF_SOURCE/models/DeepFilterNet3_onnx.tar.gz" ]] || {
        echo 'Erwartetes GitHub-Layout/mitgeliefertes Modell fehlt; kein Build.' >&2; return 1;
    }
}

df_build() (
    cd "$DF_SOURCE"
    export CARGO_TARGET_DIR="$DF_TARGET" CARGO_BUILD_JOBS=1
    cargo build --locked --release --jobs 1 -p deep_filter --bin deep-filter \
        --no-default-features --features bin,tract,wav-utils,transforms,default-model
)

df_finish() {
    local digest
    [[ -x "$DF_BINARY" ]] || { echo 'DeepFilterNet-Binary fehlt; kein Erfolgsmarker.' >&2; return 1; }
    # Clap exits before model loading/audio processing for --version.
    timeout 15 "$DF_BINARY" --version | grep -Fx 'deep_filter 0.5.6'
    digest="$(sha256sum "$DF_BINARY")"
    printf '%s %s\n' "$DF_COMMIT" "${digest%% *}" > "$DF_MARKER"
    echo "DeepFilterNet-CPU-CLI aus GitHub gebaut: $DF_BINARY"
    echo 'Modell aus GitHub eingebettet. Keine Audios, Mikrofone, Dienste oder Ports gestartet.'
}

df_install_base_packages() {
    source "$DF_ROOT/scripts/lib/apt_lock_wait.sh"
    run_apt_with_lock_wait update || return $?
    run_apt_with_lock_wait install -y "$@"
}

df_prepare_build_tools() {
    local program package answer="" consent="${DEEPFILTERNET_INSTALL_BUILD_DEPS:-ask}"
    local -a missing=()
    # rustup commonly installs here without changing the current menu's PATH.
    if [[ -x "$HOME/.cargo/bin/cargo" && -x "$HOME/.cargo/bin/rustc" ]]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    for program in git cargo rustc cc timeout sha256sum flock; do
        command -v "$program" >/dev/null && continue
        case "$program" in
            cargo|rustc|git) package="$program" ;;
            cc) package=build-essential ;;
            timeout|sha256sum) package=coreutils ;;
            flock) package=util-linux ;;
        esac
        [[ " ${missing[*]} " == *" $package "* ]] || missing+=("$package")
    done
    ((${#missing[@]})) || return 0
    echo "Fehlende DeepFilterNet-Build-Werkzeuge: ${missing[*]}"
    echo 'Nur Basiswerkzeuge via apt; DeepFilterNet selbst bleibt ein gepinnter GitHub-Build ohne Docker.'
    command -v apt-get >/dev/null || { echo 'Keine apt-Paketverwaltung; Build-Werkzeuge separat einrichten.' >&2; return 1; }
    case "$consent" in
        1) ;;
        ask)
            if [[ -t 0 ]]; then
                read -r -p 'Fehlende Basiswerkzeuge jetzt installieren (sudo)? [(j)a/(N)ein]: ' answer || return 1
            fi
            [[ "$answer" == j || "$answer" == J ]] || {
                echo 'Nicht installiert. Fuer bewusste Freigabe DEEPFILTERNET_INSTALL_BUILD_DEPS=1 setzen.' >&2; return 1;
            } ;;
        0) echo 'Automatische Basisinstallation deaktiviert.' >&2; return 1 ;;
        *) echo 'DEEPFILTERNET_INSTALL_BUILD_DEPS: ask, 0 oder 1 erwartet.' >&2; return 2 ;;
    esac
    df_install_base_packages "${missing[@]}" || return $?
    hash -r
    for program in git cargo rustc cc timeout sha256sum flock; do
        command -v "$program" >/dev/null || { echo "Nach Basisinstallation fehlt weiterhin: $program" >&2; return 1; }
    done
}

deepfilternet_main() (
    set -euo pipefail
    umask 077
    local mode="${1:-install}" log
    df_paths || return 1
    case "$mode" in
        --dry-run|--plan|plan|--help)
            echo "DeepFilterNet v0.5.6: $DF_URL; Commit $DF_COMMIT; nativer Rust-CPU-Build ohne Docker/Python."
            echo 'Reserve: 6144 MiB Gesamt-RAM, 4096 MiB verfuegbar, 8 GiB Disk/Windows-C:. Ein Buildjob.'
            echo 'Bei Installation: Cargo-Abhaengigkeiten und GitHub-Modell; kein Audio-/Dienststart. Dry-Run ohne Download.'; return 0 ;;
        status|--status)
            if df_probe >/dev/null 2>&1; then echo '{"installed":true,"scope":"rust-cpu-cli","audio_tested":false}'
            else echo '{"installed":false,"scope":"rust-cpu-cli","audio_tested":false}'; fi
            return 0 ;;
        doctor|check|--check)
            df_probe || { echo 'DeepFilterNet-Build fehlt/deaktiviert oder Quelle/Binary inkonsistent.' >&2; return 1; }
            echo 'Commit/Binary-Hash geprueft. Keine Binary-Ausfuehrung, Audios oder Echtheitsbewertung.'; return 0 ;;
        install|update|--repair|uninstall|--uninstall) ;;
        *) echo 'DeepFilterNet: nur Build/Status/Doctor/Deaktivierung; kein Audio-/Serverstart.' >&2; return 2 ;;
    esac
    [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || { echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2; return 1; }
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
        [[ -d "$DF_BASE" ]] || { echo 'Nicht eingerichtet; nichts deaktiviert.'; return 0; }
    else
        if [[ "$mode" == install ]] && df_probe >/dev/null 2>&1; then echo 'Verifizierter Build bereits vorhanden; nichts installiert.'; return 0; fi
        df_resources || return 1
        df_prepare_build_tools || return $?
    fi
    mkdir -p "$DF_BASE" "$DF_LOGS"
    exec 9>"$DF_BASE/operation.lock"
    flock -n 9 || { echo 'Andere DeepFilterNet-Operation aktiv.' >&2; return 1; }
    log="$(mktemp "$DF_LOGS/deepfilternet_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
    exec > >(tee -a "$log") 2>&1
    echo "DeepFilterNet-Installer: 2026-10-16-github-rust-cpu; Aktion: $mode; Pin: $DF_COMMIT"
    trap 'rc=$?; if ((rc != 0)); then echo "DeepFilterNet-Fehler ($rc); Daten erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
    if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
        rm -f -- "$DF_MARKER"
        echo 'Setup-Marker deaktiviert; Quelle, Binary, Modelle, Audio und Logs bleiben erhalten.'; return 0
    fi
    df_fetch
    rm -f -- "$DF_MARKER"
    df -Pk "$DF_BASE"
    df_build
    df_finish
    df -Pk "$DF_BASE"
)
