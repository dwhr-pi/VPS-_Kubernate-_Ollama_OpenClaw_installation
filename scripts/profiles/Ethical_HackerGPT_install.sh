#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

PROFILE_KEY="Ethical_HackerGPT"
PROFILE_WORKSPACE_DIR="${USER_WORKSPACE_DIR}/ethical_hackergpt"
PROFILE_ENV_FILE="${PROFILE_WORKSPACE_DIR}/ethical_hackergpt.env"

ensure_user_workspace
mkdir -p "$PROFILE_WORKSPACE_DIR"

if [ -f "$PROFILE_ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$PROFILE_ENV_FILE"
fi

ETHICAL_HACKER_ENABLED="${ETHICAL_HACKER_ENABLED:-false}"
ETHICAL_HACKER_MODE="${ETHICAL_HACKER_MODE:-audit}"
ETHICAL_HACKER_ALLOWLIST="${ETHICAL_HACKER_ALLOWLIST:-127.0.0.1,localhost}"
ETHICAL_HACKER_RATE_LIMIT="${ETHICAL_HACKER_RATE_LIMIT:-low}"
ETHICAL_HACKER_INSTALL_LABS="${ETHICAL_HACKER_INSTALL_LABS:-false}"
ETHICAL_HACKER_INSTALL_OPTIONAL_TOOLS="${ETHICAL_HACKER_INSTALL_OPTIONAL_TOOLS:-false}"
ETHICAL_HACKER_OUTPUT_DIR="${ETHICAL_HACKER_OUTPUT_DIR:-./reports/security}"
ETHICAL_HACKER_NO_PUBLIC_TARGETS="${ETHICAL_HACKER_NO_PUBLIC_TARGETS:-true}"
ETHICAL_HACKER_ENABLE_ACTIVE_TESTS="${ETHICAL_HACKER_ENABLE_ACTIVE_TESTS:-false}"

resolve_output_dir() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    ./*) printf '%s\n' "$ROOT_DIR/${1#./}" ;;
    *) printf '%s\n' "$ROOT_DIR/$1" ;;
  esac
}

is_private_or_local_target() {
  local target="$1"

  case "$target" in
    localhost|127.0.0.1|::1) return 0 ;;
    *.local|*.lan|*.internal|*.home) return 0 ;;
    10.*|192.168.*) return 0 ;;
    172.16.*|172.17.*|172.18.*|172.19.*|172.2?.*|172.30.*|172.31.*) return 0 ;;
  esac

  return 1
}

sanitize_allowlist() {
  local raw="$1"
  local tmp=""
  local item=""
  local cleaned=()

  IFS=',' read -r -a entries <<< "$raw"
  for item in "${entries[@]}"; do
    item="${item//\"/}"
    item="$(printf '%s' "$item" | xargs)"
    [ -n "$item" ] || continue

    if [ "$ETHICAL_HACKER_NO_PUBLIC_TARGETS" = "true" ] && ! is_private_or_local_target "$item"; then
      log_warn "Ueberspringe nicht-lokales oder nicht-privates Ziel aus der Allowlist: $item"
      continue
    fi

    cleaned+=("$item")
  done

  if [ "${#cleaned[@]}" -eq 0 ]; then
    cleaned=("127.0.0.1" "localhost")
  fi

  printf '%s\n' "${cleaned[@]}" | awk '!seen[$0]++'
}

run_tool_script_if_present() {
  local script_name="$1"
  if [ -f "$ROOT_DIR/scripts/tools/$script_name" ]; then
    log_info "Installiere $script_name ..."
    bash "$ROOT_DIR/scripts/tools/$script_name"
  else
    log_warn "$script_name nicht gefunden. Ueberspringe diesen Baustein."
  fi
}

install_python_user_package_if_missing() {
  local module_name="$1"
  local package_name="$2"
  if python3 -c "import ${module_name}" >/dev/null 2>&1; then
    log_info "$package_name ist bereits verfuegbar."
  else
    log_info "Installiere Python-Paket $package_name fuer den aktuellen Benutzer ..."
    python3 -m pip install --user "$package_name"
  fi
}

OUTPUT_DIR="$(resolve_output_dir "$ETHICAL_HACKER_OUTPUT_DIR")"
mkdir -p "$OUTPUT_DIR"

if [ "$ETHICAL_HACKER_MODE" != "audit" ] && [ "$ETHICAL_HACKER_ENABLE_ACTIVE_TESTS" != "true" ]; then
  log_warn "Nur Audit-Modus ist ohne expliziten Schalter erlaubt. Setze Modus auf audit zurueck."
  ETHICAL_HACKER_MODE="audit"
fi

mapfile -t SANITIZED_ALLOWLIST < <(sanitize_allowlist "$ETHICAL_HACKER_ALLOWLIST")

log_info "Installiere Ethical_HackerGPT im defensiven Modus."
log_info "Allowlist:"
printf ' - %s\n' "${SANITIZED_ALLOWLIST[@]}"

sudo apt-get update
sudo apt-get install -y curl jq git whois dnsutils iproute2 net-tools openssl ufw fail2ban lynis

run_tool_script_if_present "nmap_install.sh"
run_tool_script_if_present "gitleaks_install.sh"
run_tool_script_if_present "semgrep_install.sh"
run_tool_script_if_present "trivy_install.sh"
run_tool_script_if_present "syft_install.sh"
run_tool_script_if_present "grype_install.sh"

install_python_user_package_if_missing "bandit" "bandit"
install_python_user_package_if_missing "pip_audit" "pip-audit"

if [ "$ETHICAL_HACKER_INSTALL_OPTIONAL_TOOLS" = "true" ]; then
  run_tool_script_if_present "trufflehog_install.sh"
  run_tool_script_if_present "fail2ban_analyzer_install.sh"
  run_tool_script_if_present "ufw_install.sh"
  run_tool_script_if_present "tailscale_install.sh"
  run_tool_script_if_present "cloudflared_install.sh"
  log_warn "Optionale Tools wie kube-bench, kubescape, testssl.sh, nuclei oder ZAP sind in diesem Repo noch nicht als Standard-Installer verdrahtet und werden deshalb nicht automatisch installiert."
fi

if [ "$ETHICAL_HACKER_INSTALL_LABS" = "true" ]; then
  mkdir -p "$PROFILE_WORKSPACE_DIR/labs"
  cat > "$PROFILE_WORKSPACE_DIR/labs/juice-shop.compose.yml" <<'EOF'
services:
  juice-shop:
    image: bkimminich/juice-shop
    ports:
      - "127.0.0.1:3008:3000"
EOF
  cat > "$PROFILE_WORKSPACE_DIR/labs/dvwa.compose.yml" <<'EOF'
services:
  dvwa:
    image: vulnerables/web-dvwa
    ports:
      - "127.0.0.1:8085:80"
EOF
  log_warn "Lokale Lab-Compose-Dateien wurden vorbereitet, aber nicht gestartet."
fi

printf '%s\n' "${SANITIZED_ALLOWLIST[@]}" > "$OUTPUT_DIR/ethical_hackergpt_allowlist.txt"

cat > "$OUTPUT_DIR/ethical_hackergpt_example_report.md" <<EOF
# Ethical HackerGPT Beispielreport

- Zeitpunkt: $(date -Iseconds)
- Modus: $ETHICAL_HACKER_MODE
- Rate-Limit: $ETHICAL_HACKER_RATE_LIMIT
- Public Targets gesperrt: $ETHICAL_HACKER_NO_PUBLIC_TARGETS

## Scope

$(printf -- '- %s\n' "${SANITIZED_ALLOWLIST[@]}")

## Findings

- Beispiel: Offene Ports, alte Pakete oder fehlende Security-Header muessen manuell geprueft werden.

## Risiko

- Mittel, bis konkrete technische Findings nachgezogen wurden.

## Beweis / Beobachtung

- Dieses Profil wurde im defensiven Audit-Modus vorbereitet.

## Empfehlung

- Zuerst lokale Host-, Repo- und Container-Scans gegen erlaubte Ziele ausfuehren.

## Fix-Kommandos

\`\`\`bash
sudo ufw status verbose
gitleaks detect --source . --no-git
trivy fs .
\`\`\`

## Prioritaet

- P1

## Nachtest

- Nach jedem Fix denselben Check erneut ausfuehren und Report aktualisieren.
EOF

cat > "$PROFILE_ENV_FILE" <<EOF
ETHICAL_HACKER_ENABLED=$ETHICAL_HACKER_ENABLED
ETHICAL_HACKER_MODE=$ETHICAL_HACKER_MODE
ETHICAL_HACKER_ALLOWLIST=$(IFS=,; printf '%s' "${SANITIZED_ALLOWLIST[*]}")
ETHICAL_HACKER_RATE_LIMIT=$ETHICAL_HACKER_RATE_LIMIT
ETHICAL_HACKER_INSTALL_LABS=$ETHICAL_HACKER_INSTALL_LABS
ETHICAL_HACKER_INSTALL_OPTIONAL_TOOLS=$ETHICAL_HACKER_INSTALL_OPTIONAL_TOOLS
ETHICAL_HACKER_OUTPUT_DIR=$ETHICAL_HACKER_OUTPUT_DIR
ETHICAL_HACKER_NO_PUBLIC_TARGETS=$ETHICAL_HACKER_NO_PUBLIC_TARGETS
ETHICAL_HACKER_ENABLE_ACTIVE_TESTS=$ETHICAL_HACKER_ENABLE_ACTIVE_TESTS
EOF

mark_profile_installed "$PROFILE_KEY"
log_success "Ethical_HackerGPT wurde defensiv vorbereitet. Reports liegen unter $OUTPUT_DIR"
