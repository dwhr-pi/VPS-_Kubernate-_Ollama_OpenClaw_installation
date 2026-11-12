#!/usr/bin/env bash
# Ephemeral GitHub-hosted Noble runner only; never rewrite host APT sources.
set -euo pipefail

qa_sources() {
  printf '%s\n' \
    'deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://archive.ubuntu.com/ubuntu noble main universe' \
    'deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://archive.ubuntu.com/ubuntu noble-updates main universe' \
    'deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://archive.ubuntu.com/ubuntu noble-backports main universe' \
    'deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] https://security.ubuntu.com/ubuntu noble-security main universe'
}

qa_runner_guard() {
  if [[ ${GITHUB_ACTIONS:-} != true || ${RUNNER_OS:-} != Linux || ${RUNNER_ENVIRONMENT:-} != github-hosted ]]; then
    printf '%s\n' 'QA bootstrap refused: GitHub-hosted Linux runner required.' >&2
    return 2
  fi
  if ! grep -qx 'ID=ubuntu' /etc/os-release || ! grep -Eq '^VERSION_ID="?24\.04"?$' /etc/os-release || [[ $(dpkg --print-architecture) != amd64 ]]; then
    printf '%s\n' 'QA bootstrap supports Ubuntu 24.04 amd64 only.' >&2
    return 2
  fi
  if [[ ${RUNNER_TEMP:-} != /* || ${RUNNER_TEMP:-} == / || ! -d ${RUNNER_TEMP:-} || -L ${RUNNER_TEMP:-} || ! -r /usr/share/keyrings/ubuntu-archive-keyring.gpg ]]; then
    printf '%s\n' 'QA bootstrap refused: unsafe temporary directory or missing Ubuntu keyring.' >&2
    return 2
  fi
}

qa_install() (
  qa_runner_guard
  local tool work sources
  local -a missing=() apt_options=()
  for tool in shellcheck shfmt python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing+=("$tool")
    fi
  done
  if ((${#missing[@]})); then
    work=$(mktemp -d "${RUNNER_TEMP%/}/openclaw-qa-apt.XXXXXXXX")
    sources="$work/ubuntu.list"
    trap 'rm -f -- "$sources"; rmdir -- "$work"' EXIT
    qa_sources >"$sources"
    chmod 755 "$work"
    chmod 644 "$sources"
    apt_options=(-o "Dir::Etc::sourcelist=$sources" -o 'Dir::Etc::sourceparts=-'
      -o 'APT::Get::List-Cleanup=0' -o 'APT::Update::Error-Mode=any'
      -o 'Acquire::Retries=2' -o 'Acquire::http::Timeout=20' -o 'Acquire::https::Timeout=20')
    sudo apt-get "${apt_options[@]}" update
    sudo apt-get "${apt_options[@]}" install -y --no-install-recommends "${missing[@]}"
  fi
  shellcheck --version
  shfmt --version
  python3 --version
)

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  case ${1:-install} in
    --sources) qa_sources ;;
    install) qa_install ;;
    *)
      printf '%s\n' 'Unsupported QA bootstrap action.' >&2
      exit 2
      ;;
  esac
fi
