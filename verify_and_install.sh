#!/usr/bin/env bash
# Vertrauensanker muessen aus einem unabhaengig geprueften Release stammen.
set -euo pipefail
umask 077
commit= expected= destination="$HOME/openclaw_ultimate_setup" verify_only=0
repo=https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git
die() { printf 'Verifizierter Bootstrap abgebrochen: %s\n' "$*" >&2; exit 1; }
while (($#)); do
  case "$1" in
    --commit|--installer-sha256|--destination)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in --commit) commit=$2 ;; --installer-sha256) expected=$2 ;; --destination) destination=$2 ;; esac
      shift 2 ;;
    --verify-only) verify_only=1; shift ;;
    *) die '--commit VOLLER_SHA --installer-sha256 SHA256 [--destination ABS] [--verify-only]' ;;
  esac
done
[[ "$commit" =~ ^[a-f0-9]{40}$ && "$expected" =~ ^[a-f0-9]{64}$ && "$expected" != "$(printf '%064d' 0)" ]] || die 'Voller Commit und echter externer SHA256 erforderlich; kein main/latest.'
[[ $(uname -s) == Linux ]] || die 'Bootstrap fuer Linux/WSL; keine Windows-Installation.'
for tool in git sha256sum mktemp realpath stat; do command -v "$tool" >/dev/null || die "Werkzeug fehlt: $tool"; done
stage=$(mktemp -d /tmp/openclaw-verified.XXXXXXXX)
canonical=$(realpath -e -- "$stage")
[[ "$canonical" == /tmp/openclaw-verified.* && ! -L "$stage" && $(stat -c %u "$stage") == "$EUID" ]] || die 'Temp-Verzeichnis nicht sicher.'
cleanup() {
  # Nur diesen privaten Temp-Checkout entfernen, niemals Ziel oder Benutzerdaten.
  if [[ "$stage" == "$canonical" && "$stage" == /tmp/openclaw-verified.* && -d "$stage" && ! -L "$stage" ]]; then
    rm -rf --one-file-system -- "$stage"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -m 700 "$stage/home" "$stage/templates"
git_safe() {
  # Keine geerbten Credential-Helper, Traces, Filter, Hooks oder Fremdprotokolle.
  env -i PATH="$PATH" HOME="$stage/home" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    GIT_TEMPLATE_DIR="$stage/templates" GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=/bin/false \
    git -c credential.helper= -c core.hooksPath=/dev/null -c protocol.allow=never \
      -c protocol.https.allow=always -c http.sslVerify=true "$@"
}
# Noch kein Checkout und keine Ausfuehrung heruntergeladenen Codes.
git_safe clone --no-checkout --depth=1 --no-recurse-submodules "$repo" "$stage/source"
git_safe -C "$stage/source" fetch --depth=1 origin "$commit"
[[ $(git_safe -C "$stage/source" rev-parse FETCH_HEAD) == "$commit" ]] || die 'Commit stimmt nicht.'
git_safe -C "$stage/source" checkout --detach "$commit"
[[ -f "$stage/source/install.sh" && ! -L "$stage/source/install.sh" ]] || die 'Installer fehlt oder ist ein Symlink.'
printf '%s  %s\n' "$expected" "$stage/source/install.sh" | sha256sum --status -c - || die 'Installer-Hash falsch; nichts ausgefuehrt.'
[[ -z $(git_safe -C "$stage/source" status --porcelain --untracked-files=all) ]] || die 'Verifizierter Checkout wurde veraendert.'
printf 'Commit und Installer-Hash geprueft. Keine Versionsgarantie fuer spaetere Tool-Downloads.\n'
((verify_only == 0)) || exit 0
# Vertrag des neuen Installers: kein erneuter Netz-Clone von main.
grep -Fq -- '--verified-source' "$stage/source/install.sh" || die 'Dieser alte Installer unterstuetzt den sicheren Quellenvertrag nicht.'
bash "$stage/source/install.sh" --verified-source "$commit" "$destination"
