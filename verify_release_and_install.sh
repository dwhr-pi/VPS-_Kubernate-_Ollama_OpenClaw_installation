#!/usr/bin/env bash
# Einstieg aus einer bereits geprueften Bootstrap-Kopie; Vertrauen nie aus dem Download ableiten.
set -Eeuo pipefail
umask 077
ROOT="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
tag= key= artifacts= download=0 execute=0 destination="$HOME/openclaw_ultimate_setup" stage=
die() { printf 'Release-Einstieg abgebrochen: %s\n' "$*" >&2; exit 1; }
while (($#)); do
  case "$1" in
    --tag|--public-key|--artifacts|--destination)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in --tag) tag=$2 ;; --public-key) key=$2 ;; --artifacts) artifacts=$2 ;; --destination) destination=$2 ;; esac
      shift 2 ;;
    --download) download=1; shift ;;
    --install) execute=1; shift ;;
    --verify-only) shift ;;
    *) die '--tag vX.Y.Z --public-key ABS [--artifacts ABS | --download] [--install --destination ABS]' ;;
  esac
done
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ && "$key" == /* && -f "$key" && ! -L "$key" ]] || die 'Release-Tag und unabhaengige regulaere Public-Key-Datei erforderlich.'
command -v minisign >/dev/null || die 'Minisign separat aus gepruefter Quelle bereitstellen.'
command -v python3 >/dev/null || die 'Python 3 erforderlich.'
if ((execute)); then
  [[ $(uname -s) == Linux && "$EUID" != 0 ]] || die 'Installation nur als normaler Linux-/WSL-Benutzer.'
fi
cleanup() {
  local rc=$?
  if [[ -n "$stage" && "$stage" == /tmp/openclaw-release.* && -d "$stage" && ! -L "$stage" ]]; then
    rm -rf --one-file-system -- "$stage"
  fi
  return "$rc"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
stage=$(mktemp -d /tmp/openclaw-release.XXXXXXXX)
if ((download)); then
  [[ -z "$artifacts" ]] || die 'Lokale Artefakte und Download sind alternative Wege.'
  command -v curl >/dev/null || die 'curl fehlt.'
  artifacts="$stage/artifacts"
  mkdir -m 700 "$artifacts"
  for file in SHA256SUMS SHA256SUMS.minisig release.json install.sh; do
    curl -q --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
      --connect-timeout 15 --max-time 120 --max-filesize 1048576 \
      "https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/releases/download/$tag/$file" \
      --output "$artifacts/$file"
  done
fi
[[ "$artifacts" == /* && -d "$artifacts" && ! -L "$artifacts" ]] || die 'Absolutes Artefaktverzeichnis oder --download erforderlich.'
python3 -I -B "$ROOT/scripts/security/release_manifest.py" --artifacts "$artifacts" --tag "$tag" --public-key "$key" > "$stage/verified.json"
commit=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["commit"])' "$stage/verified.json")
if ((!execute)); then
  printf 'Signatur, SHA256, Tag und Commit geprueft. Kein Clone/Installer gestartet.\n'
  exit 0
fi
mkdir -m 700 "$stage/home"
git_safe() {
  env -i PATH="$PATH" HOME="$stage/home" LANG=C GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    GIT_TERMINAL_PROMPT=0 GIT_NOREPLACE_OBJECTS=1 GIT_LFS_SKIP_SMUDGE=1 \
    git -c core.hooksPath=/dev/null -c core.fsmonitor=false -c credential.helper= \
      -c http.sslVerify=true -c protocol.file.allow=never -c protocol.ext.allow=never "$@"
}
git_safe clone --no-checkout --depth=1 --single-branch --branch "$tag" --no-recurse-submodules \
  https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git "$stage/source"
[[ $(git_safe -C "$stage/source" rev-parse 'HEAD^{commit}') == "$commit" ]] || die 'Git-Tag zeigt nicht auf den signierten Commit.'
git_safe -C "$stage/source" checkout --detach "$commit"
[[ -f "$stage/source/install.sh" && ! -L "$stage/source/install.sh" ]] || die 'Installer darf kein Symlink sein.'
cmp -- "$artifacts/install.sh" "$stage/source/install.sh" || die 'Git-Installer weicht vom signierten Release ab.'
bash "$stage/source/install.sh" --verified-source "$commit" "$destination"
