#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

kubectl_arch() {
  case "$(uname -m)" in
    x86_64 | amd64) echo amd64 ;;
    aarch64 | arm64) echo arm64 ;;
    *)
      log_error "Kubectl: nicht unterstuetzte Architektur."
      return 1
      ;;
  esac
}

verify_kubectl_checksum() {
  local binary="$1" checksum_file="$2" checksum
  checksum="$(tr -d '\r\n' <"$checksum_file")"
  [[ "$checksum" =~ ^[a-fA-F0-9]{64}$ ]] || return 1
  printf '%s  %s\n' "$checksum" "$binary" | sha256sum --check --status
}

kubectl_main() {
  local mode="${1:-install}" arch version url tmp_dir
  case "$mode" in
    --check | --status)
      kubectl version --client
      return $?
      ;;
    install | --dry-run) ;;
    --help | -h)
      echo 'Kubectl: --check, --status, --dry-run; KUBECTL_VERSION=vX.Y.Z fuer eine feste Version.'
      return 0
      ;;
    *)
      log_error "Unbekannte Option: $mode"
      return 2
      ;;
  esac
  arch="$(kubectl_arch)" || return 1
  version="${KUBECTL_VERSION:-}"
  if [ -n "$version" ] && ! [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_error 'KUBECTL_VERSION muss vX.Y.Z entsprechen.'
    return 2
  fi
  if [ "$mode" = --dry-run ]; then
    echo "Kubectl linux-${arch}: Version ${version:-aus https://dl.k8s.io/release/stable.txt}; SHA256-Pruefung; Ziel /usr/local/bin/kubectl."
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_Kubectl 'Kubectl aus offiziellem Kubernetes-Release'
  ensure_base_apt_packages ca-certificates curl coreutils || {
    end_measurement failed
    return 1
  }
  if [ -z "$version" ]; then
    version="$(curl -fsSL --connect-timeout 15 --max-time 60 https://dl.k8s.io/release/stable.txt)" || {
      end_measurement failed
      return 1
    }
  fi
  if ! [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_error 'Ungueltige Kubernetes-Release-Version.'
    end_measurement failed
    return 1
  fi
  url="https://dl.k8s.io/release/${version}/bin/linux/${arch}/kubectl"
  log_info "GitHub-Projekt: https://github.com/kubernetes/kubernetes; Release: $url"
  if [ -x /usr/local/bin/kubectl ] && /usr/local/bin/kubectl version --client -o json 2>/dev/null | grep -Fq "\"gitVersion\": \"$version\""; then
    mark_tool_installed Kubectl
    end_measurement success
    return 0
  fi
  tmp_dir="$(mktemp -d)" || {
    end_measurement failed
    return 1
  }
  if ! curl -fsSL --connect-timeout 15 --max-time 300 "$url" -o "$tmp_dir/kubectl" ||
    ! curl -fsSL --connect-timeout 15 --max-time 60 "$url.sha256" -o "$tmp_dir/kubectl.sha256" ||
    ! verify_kubectl_checksum "$tmp_dir/kubectl" "$tmp_dir/kubectl.sha256" ||
    ! chmod 0755 "$tmp_dir/kubectl" ||
    ! "$tmp_dir/kubectl" version --client >/dev/null ||
    ! sudo install -m 0755 "$tmp_dir/kubectl" /usr/local/bin/kubectl; then
    log_error 'Kubectl: Download, SHA256-Pruefung, Client-Test oder Installation fehlgeschlagen.'
    rm -rf -- "$tmp_dir"
    end_measurement failed
    return 1
  fi
  rm -rf -- "$tmp_dir"
  mark_tool_installed Kubectl
  end_measurement success
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  kubectl_main "$@"
fi
