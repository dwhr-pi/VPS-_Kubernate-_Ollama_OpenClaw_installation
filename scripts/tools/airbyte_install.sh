#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="Airbyte"
INSTALL_ROOT="/opt/airbyte"
AIRBYTE_SOURCE_DIR="$INSTALL_ROOT/source"
ABCTL_SOURCE_DIR="$INSTALL_ROOT/abctl"
ABCTL_BIN_DIR="$INSTALL_ROOT/bin"
ABCTL_BIN="$ABCTL_BIN_DIR/abctl"
LOCAL_GO_ROOT="$INSTALL_ROOT/go"
LOCAL_GO_BIN="$LOCAL_GO_ROOT/bin/go"
AIRBYTE_PORT="${AIRBYTE_PORT:-8003}"
AIRBYTE_HOST="${AIRBYTE_HOST:-localhost}"
AIRBYTE_GO_VERSION="${AIRBYTE_GO_VERSION:-1.24.4}"
AIRBYTE_ABCTL_REF="${AIRBYTE_ABCTL_REF:-v0.30.4}"
AIRBYTE_MIN_FREE_MB="${AIRBYTE_MIN_FREE_MB:-32768}"
AIRBYTE_RECOMMENDED_FREE_MB="${AIRBYTE_RECOMMENDED_FREE_MB:-65536}"
AIRBYTE_MIN_WINDOWS_FREE_MB="${AIRBYTE_MIN_WINDOWS_FREE_MB:-20480}"
AIRBYTE_MIN_MEMORY_MB="${AIRBYTE_MIN_MEMORY_MB:-8192}"
AIRBYTE_RECOMMENDED_MEMORY_MB="${AIRBYTE_RECOMMENDED_MEMORY_MB:-12288}"
AIRBYTE_ABCTL_TIMEOUT_MIN="${AIRBYTE_ABCTL_TIMEOUT_MIN:-120}"
AIRBYTE_K8S_NAMESPACE="${AIRBYTE_K8S_NAMESPACE:-airbyte-abctl}"
AIRBYTE_K8S_CONTEXT="${AIRBYTE_K8S_CONTEXT:-kind-airbyte-abctl}"

begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

get_free_mb_for_path() {
  local path="${1:-/}"
  df -Pm "$path" 2>/dev/null | awk 'NR==2 {print $4}'
}

get_windows_host_free_mb() {
  local win_path="/mnt/c"
  [ -d "$win_path" ] || return 0
  df -Pm "$win_path" 2>/dev/null | awk 'NR==2 {print $4}'
}

get_mem_available_mb() {
  awk '/^MemAvailable:/ {printf "%d\n", $2 / 1024}' /proc/meminfo 2>/dev/null
}

airbyte_confirm_heavy_install() {
  local linux_free_mb
  local windows_free_mb
  local mem_available_mb

  linux_free_mb="$(get_free_mb_for_path /)"
  windows_free_mb="$(get_windows_host_free_mb || true)"
  mem_available_mb="$(get_mem_available_mb || true)"

  log_warn "Airbyte ist sehr schwergewichtig: abctl startet lokal einen kind/Kubernetes-Cluster und zieht viele Container-Images."
  log_info "Freier Linux-/WSL-Speicher: ${linux_free_mb:-unbekannt} MB"
  if [ -n "$windows_free_mb" ]; then
    log_info "Freier Windows-Host-Speicher (C:): ${windows_free_mb} MB"
  fi
  if [ -n "$mem_available_mb" ]; then
    log_info "Verfuegbarer RAM laut Linux/WSL: ${mem_available_mb} MB"
  fi
  log_info "Mindestempfehlung fuer Airbyte: ${AIRBYTE_MIN_FREE_MB} MB Linux/WSL frei, besser ${AIRBYTE_RECOMMENDED_FREE_MB} MB oder mehr."
  log_info "Unter WSL sollte der Windows-Host zusaetzlich mindestens ${AIRBYTE_MIN_WINDOWS_FREE_MB} MB frei haben, weil Docker/WSL-VHDX waehrend Image-Pulls wachsen kann."
  log_info "RAM-Empfehlung fuer Airbyte/kind: mindestens ${AIRBYTE_MIN_MEMORY_MB} MB verfuegbar, besser ${AIRBYTE_RECOMMENDED_MEMORY_MB} MB oder mehr."

  if [ -n "$linux_free_mb" ] && [ "$linux_free_mb" -lt "$AIRBYTE_MIN_FREE_MB" ]; then
    log_error "Zu wenig freier Linux-/WSL-Speicher fuer Airbyte. Installation wird vor dem Image-Pull abgebrochen."
    return 1
  fi

  if [ -n "$windows_free_mb" ] && [ "$windows_free_mb" -lt "$AIRBYTE_MIN_WINDOWS_FREE_MB" ]; then
    log_error "Zu wenig freier Windows-Host-Speicher fuer Airbyte unter WSL. Installation wird vor dem Image-Pull abgebrochen."
    log_warn "Hinweis: Airbyte kann lange bei 'Pulling images' stehen und danach durch Speicher-/VHDX-Grenzen abbrechen."
    return 1
  fi

  if [ -n "$mem_available_mb" ] && [ "$mem_available_mb" -lt "$AIRBYTE_MIN_MEMORY_MB" ]; then
    log_error "Zu wenig verfuegbarer RAM fuer Airbyte/kind. Installation wird vor dem Helm-Deployment abgebrochen."
    log_warn "Airbyte startet viele Pods. Unter WSL fuehren knapper RAM oder aggressive Speicherbegrenzungen oft zu Readiness-/Liveness-Probe-Schleifen."
    return 1
  fi

  if [ -n "$linux_free_mb" ] && [ "$linux_free_mb" -lt "$AIRBYTE_RECOMMENDED_FREE_MB" ]; then
    log_warn "Der freie Linux-/WSL-Speicher liegt unter der Empfehlung. Airbyte kann trotzdem starten, aber Pulls und Builds koennen lange dauern oder abbrechen."
  fi

  if [ -n "$mem_available_mb" ] && [ "$mem_available_mb" -lt "$AIRBYTE_RECOMMENDED_MEMORY_MB" ]; then
    log_warn "Der verfuegbare RAM liegt unter der Empfehlung. Airbyte kann trotzdem starten, aber Helm/Pods koennen sehr lange haengen."
  fi
}

airbyte_docker_cmd() {
  if docker info >/dev/null 2>&1; then
    echo "docker"
    return 0
  fi
  if command -v sudo >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
    echo "sudo docker"
    return 0
  fi
  return 1
}

airbyte_print_deployment_hint() {
  log_warn "Airbyte/abctl startet einen lokalen kind/Kubernetes-Cluster und installiert Airbyte per Helm."
  log_warn "Readiness-/Liveness-Probe-Warnungen sind am Anfang moeglich, besonders unter WSL, bei wenig RAM oder langsamer Platte."
  log_warn "Wenn die gleiche Worker-Meldung lange wiederholt wird, ist meist ein Pod abgestuerzt, zu langsam gestartet oder durch Speicher-/Image-Pull-Probleme blockiert."
}

airbyte_diagnose_deployment() {
  local docker_cmd

  log_warn "Airbyte-Diagnose: sammle lokale Hinweise zum abctl/kind-Deployment."

  if docker_cmd="$(airbyte_docker_cmd)"; then
    log_info "Docker Speicheruebersicht:"
    # shellcheck disable=SC2086
    $docker_cmd system df || true
    log_info "Docker Container mit Airbyte/kind-Bezug:"
    # shellcheck disable=SC2086
    $docker_cmd ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}' | grep -Ei 'airbyte|kind|abctl|temporal' || true
  else
    log_warn "Docker ist fuer die Diagnose nicht nutzbar."
  fi

  if command -v kubectl >/dev/null 2>&1; then
    log_info "Kubernetes Pods im Airbyte-Namespace:"
    kubectl --context "$AIRBYTE_K8S_CONTEXT" -n "$AIRBYTE_K8S_NAMESPACE" get pods -o wide 2>/dev/null || kubectl get pods -A 2>/dev/null | grep -i airbyte || true
    log_info "Kubernetes Events mit Airbyte-Bezug:"
    kubectl --context "$AIRBYTE_K8S_CONTEXT" -n "$AIRBYTE_K8S_NAMESPACE" get events --sort-by=.lastTimestamp 2>/dev/null | tail -n 40 || true
    log_info "Kurze Worker-Pod-Logs, falls vorhanden:"
    kubectl --context "$AIRBYTE_K8S_CONTEXT" -n "$AIRBYTE_K8S_NAMESPACE" logs -l app.kubernetes.io/name=worker --tail=80 2>/dev/null || \
      kubectl --context "$AIRBYTE_K8S_CONTEXT" -n "$AIRBYTE_K8S_NAMESPACE" logs -l airbyte=worker --tail=80 2>/dev/null || true
  else
    log_warn "kubectl ist nicht installiert. Nutze bei Bedarf: $ABCTL_BIN local status oder Docker/kind-Diagnose."
  fi

  log_warn "Wenn Airbyte haengen bleibt: erst Speicher freigeben, dann alte Airbyte/kind-Reste pruefen."
  log_warn "Sicherer erster Schritt: bash scripts/cleanup_installation_residues.sh --dry-run --all"
  log_warn "Riskanter und nur nach Sichtpruefung: alte /opt-Airbyte-Reste ueber Optionen -> Installationsueberwachung -> /opt-Toolreste bereinigen."
}

airbyte_classify_abctl_failure() {
  local install_log="$1"

  [ -f "$install_log" ] || return 0

  if grep -qi "TLS handshake timeout" "$install_log"; then
    log_error "Erkannt: Kubernetes/API-Server TLS handshake timeout waehrend Helm-Installation."
    log_warn "Das passt zu einem ueberlasteten oder langsam reagierenden lokalen kind-Cluster, haeufig durch WSL-/Docker-I/O, wenig RAM, knappen Windows-Host-Speicher oder sehr lange Image-Pulls."
  fi

  if grep -qi "context deadline exceeded" "$install_log"; then
    log_error "Erkannt: Helm/Kubernetes context deadline exceeded."
    log_warn "Das bedeutet: abctl hat zu lange auf gesunde Airbyte-Pods gewartet. In WSL ist das meist RAM-/I/O-/Docker-Last oder ein bereits halb angelegter kind-Cluster."
  fi

  if grep -qiE "Readiness probe failed|Liveness probe failed|Reason: Unhealthy" "$install_log"; then
    log_error "Erkannt: wiederholte Readiness-/Liveness-Probe-Fehler in Airbyte-Pods."
    log_warn "Einige Probe-Warnungen beim Start sind normal. Viele Wiederholungen deuten aber auf Pods hin, die intern nicht stabil hochkommen."
  fi

  if grep -qi "workload-api-server" "$install_log"; then
    log_error "Erkannt: Airbyte workload-api-server wurde nicht gesund."
    log_warn "Typisches Muster: Probe auf /health/liveness an Port 8085 liefert 'connection refused'."
    log_warn "Das ist kein GitHub-/abctl-Buildfehler, sondern ein lokales Airbyte/kind-Runtime-Problem."
    log_warn "Empfohlen: Airbyte deinstallieren, Docker/kind-Reste pruefen, Speicher freigeben und erst dann neu versuchen."
  fi

  if grep -qi "A new release of abctl is available" "$install_log"; then
    log_error "Erkannt: abctl meldet, dass die verwendete Version veraltet ist."
    log_warn "Der Installer baut abctl deshalb standardmaessig vom GitHub-Release-Tag ${AIRBYTE_ABCTL_REF}. Bei Bedarf kann AIRBYTE_ABCTL_REF angepasst werden."
  fi
}

if ! ensure_user_workspace || ! require_disk_mb "$AIRBYTE_MIN_FREE_MB" / || ! airbyte_confirm_heavy_install; then
  end_measurement "failed"
  exit 1
fi

log_info "Starte Installation von Airbyte ueber abctl."
log_warn "Der alte Docker-Compose-Pfad mit airbyte/webapp:latest ist veraltet und wird nicht mehr verwendet."
log_info "Primaerquellen:"
log_info "  Airbyte: https://github.com/airbytehq/airbyte.git"
log_info "  abctl:   https://github.com/airbytehq/abctl.git"

ensure_base_apt_packages git docker.io ca-certificates curl build-essential make tar
ensure_docker_compose_available
sudo systemctl enable --now docker || true

if ! docker info >/dev/null 2>&1 && ! sudo docker info >/dev/null 2>&1; then
  log_error "Docker-Daemon ist nicht erreichbar. Airbyte/abctl benoetigt Docker, weil abctl lokal einen kind/Kubernetes-Cluster startet."
  end_measurement "failed"
  exit 1
fi

sudo mkdir -p "$INSTALL_ROOT" "$ABCTL_BIN_DIR"
sudo chown -R "$USER":"$USER" "$INSTALL_ROOT"

clone_or_update_github_source "https://github.com/airbytehq/airbyte.git" "$AIRBYTE_SOURCE_DIR"
clone_or_update_github_source "https://github.com/airbytehq/abctl.git" "$ABCTL_SOURCE_DIR"

log_info "Setze abctl-Quelle auf GitHub-Ref: ${AIRBYTE_ABCTL_REF}"
(cd "$ABCTL_SOURCE_DIR" && git fetch --tags --force && git checkout "$AIRBYTE_ABCTL_REF")

go_supports_tool_directive() {
  local go_bin="$1"
  [ -x "$go_bin" ] || command -v "$go_bin" >/dev/null 2>&1 || return 1
  "$go_bin" env GOVERSION 2>/dev/null | awk '
    /^go[0-9]+\.[0-9]+/ {
      sub(/^go/, "", $0)
      split($0, parts, ".")
      major = parts[1] + 0
      minor = parts[2] + 0
      if (major > 1 || (major == 1 && minor >= 24)) exit 0
    }
    { exit 1 }
  '
}

ensure_local_go_toolchain() {
  local arch
  local go_url
  local tarball

  if command -v go >/dev/null 2>&1 && go_supports_tool_directive "$(command -v go)"; then
    GO_BIN="$(command -v go)"
    log_info "Nutze vorhandenes Go: $($GO_BIN env GOVERSION)"
    return 0
  fi

  if [ -x "$LOCAL_GO_BIN" ] && go_supports_tool_directive "$LOCAL_GO_BIN"; then
    GO_BIN="$LOCAL_GO_BIN"
    log_info "Nutze lokale Go-Toolchain: $($GO_BIN env GOVERSION)"
    return 0
  fi

  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *)
      log_error "Keine Go-Toolchain-Download-Architektur fuer '$arch' hinterlegt."
      return 1
      ;;
  esac

  go_url="https://go.dev/dl/go${AIRBYTE_GO_VERSION}.linux-${arch}.tar.gz"
  tarball="$INSTALL_ROOT/go${AIRBYTE_GO_VERSION}.linux-${arch}.tar.gz"
  log_warn "System-Go ist fuer abctl zu alt. abctl benoetigt Go >= 1.24 wegen der go.mod 'tool'-Direktive."
  log_info "Lade lokale Go-Toolchain ohne System-Go zu ueberschreiben: ${go_url}"
  curl -fsSL "$go_url" -o "$tarball"
  rm -rf "$LOCAL_GO_ROOT"
  tar -C "$INSTALL_ROOT" -xzf "$tarball"
  rm -f "$tarball"

  GO_BIN="$LOCAL_GO_BIN"
  "$GO_BIN" version
}

GO_BIN=""
ensure_local_go_toolchain

log_info "Baue abctl aus GitHub-Quelle..."
if (cd "$ABCTL_SOURCE_DIR" && PATH="$(dirname "$GO_BIN"):$PATH" make build >/dev/null 2>&1); then
  if [ -x "$ABCTL_SOURCE_DIR/build/abctl" ]; then
    cp "$ABCTL_SOURCE_DIR/build/abctl" "$ABCTL_BIN"
  elif [ -x "$ABCTL_SOURCE_DIR/build/abctl_linux_amd64/abctl" ]; then
    cp "$ABCTL_SOURCE_DIR/build/abctl_linux_amd64/abctl" "$ABCTL_BIN"
  fi
fi

if [ ! -x "$ABCTL_BIN" ]; then
  log_warn "make build hat kein abctl-Binary erzeugt. Versuche go build direkt mit $($GO_BIN env GOVERSION)."
  (cd "$ABCTL_SOURCE_DIR" && "$GO_BIN" build -o "$ABCTL_BIN" .)
fi

chmod +x "$ABCTL_BIN"
"$ABCTL_BIN" version || true

log_info "Installiere/aktualisiere Airbyte lokal auf http://${AIRBYTE_HOST}:${AIRBYTE_PORT}"
airbyte_print_deployment_hint

ABCTL_CMD=("$ABCTL_BIN" local install --host "$AIRBYTE_HOST" --port "$AIRBYTE_PORT" --low-resource-mode --no-browser --insecure-cookies)
ABCTL_INSTALL_LOG="$(mktemp)"
log_info "abctl Installationsausgabe wird zusaetzlich analysiert: ${ABCTL_INSTALL_LOG}"
log_info "Maximale abctl-Laufzeit fuer diese Installation: ${AIRBYTE_ABCTL_TIMEOUT_MIN} Minuten."
log_info "Anpassbar bei Bedarf: AIRBYTE_ABCTL_TIMEOUT_MIN=180 bash scripts/tools/airbyte_install.sh"

install_exit=0
ABCTL_RUN_CMD=("${ABCTL_CMD[@]}")
if command -v timeout >/dev/null 2>&1; then
  ABCTL_RUN_CMD=(timeout "${AIRBYTE_ABCTL_TIMEOUT_MIN}m" "${ABCTL_CMD[@]}")
else
  log_warn "timeout ist nicht verfuegbar. abctl kann bei Probe-Schleifen laenger laufen als gewuenscht."
fi

if docker info >/dev/null 2>&1; then
  "${ABCTL_RUN_CMD[@]}" 2>&1 | tee "$ABCTL_INSTALL_LOG"
  install_exit=${PIPESTATUS[0]}
else
  log_warn "Docker-Daemon ist fuer den aktuellen User nicht direkt nutzbar. Verwende sudo fuer abctl."
  if command -v timeout >/dev/null 2>&1; then
    sudo timeout "${AIRBYTE_ABCTL_TIMEOUT_MIN}m" "${ABCTL_CMD[@]}" 2>&1 | tee "$ABCTL_INSTALL_LOG"
  else
    sudo "${ABCTL_CMD[@]}" 2>&1 | tee "$ABCTL_INSTALL_LOG"
  fi
  install_exit=${PIPESTATUS[0]}
fi

if [ "$install_exit" -ne 0 ]; then
  if [ "$install_exit" -eq 124 ]; then
    log_error "Airbyte/abctl wurde nach ${AIRBYTE_ABCTL_TIMEOUT_MIN} Minuten beendet, um eine stundenlange Probe-Schleife zu vermeiden."
  fi
  log_error "Airbyte/abctl Installation ist fehlgeschlagen oder wurde durch wiederholte Kubernetes-Probe-Fehler beendet."
  airbyte_classify_abctl_failure "$ABCTL_INSTALL_LOG"
  airbyte_diagnose_deployment
  end_measurement "failed"
  exit "$install_exit"
fi

log_info "Airbyte-Zugangsdaten koennen mit folgendem Befehl angezeigt werden:"
log_info "  $ABCTL_BIN local credentials"
log_warn "Die Zugangsdaten nicht ins Repository kopieren."

mark_tool_installed "$TOOL_NAME"
log_success "Airbyte wurde ueber abctl installiert oder aktualisiert."
end_measurement "success"
