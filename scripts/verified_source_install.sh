#!/usr/bin/env bash
# Nur aus dem verifizierten temporaren Checkout aufrufen; kein Remote-Update.
set -euo pipefail
umask 077
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
commit=${1:-} destination=${2:-}
repo=https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git
die() { printf 'Verifizierter Quellenstart abgebrochen: %s\n' "$*" >&2; exit 1; }
[[ "$commit" =~ ^[a-f0-9]{40}$ && "$destination" == /* ]] || die 'Commit und absolutes Ziel erforderlich.'
[[ "$EUID" != 0 ]] || die 'Interaktives Setup als normaler Benutzer starten, nicht pauschal als root.'
home=$(realpath -e -- "$HOME")
target=$(realpath -m -- "$destination")
data=$(realpath -m -- "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}")
[[ "$target" == "$home/"* && "$target" != "$home" && "$target/" != "$data/"* && "$data/" != "$target/"* ]] || die 'Repo-Ziel muss im Home und getrennt vom User-Workspace liegen.'
[[ ! -L "$destination" && -d "${destination%/*}" ]] || die 'Ziel/Elternverzeichnis ungueltig.'
git_safe() {
  env -i PATH="$PATH" HOME="$HOME" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null "$@"
}
[[ $(git_safe -C "$ROOT" rev-parse HEAD) == "$commit" && -z $(git_safe -C "$ROOT" status --porcelain --untracked-files=all) ]] || die 'Quellstand nicht unveraendert.'
if [[ -e "$target" ]]; then
  die 'Vorhandenes Ziel nicht automatisch adoptieren oder lokal konfigurierte Git-Filter ausfuehren; separaten neuen Pfad waehlen.'
else
  # Nur lokale Kopie des bereits geprueften Git-Objektbaums, kein Netzabruf.
  git_safe -c protocol.file.allow=always clone --local --no-hardlinks --no-checkout "$ROOT" "$target"
  git_safe -C "$target" checkout --detach "$commit"
  git_safe -C "$target" remote set-url origin "$repo"
fi
[[ $(git_safe -C "$target" rev-parse HEAD) == "$commit" ]] || die 'Zielstand stimmt nicht.'
printf 'Starte den gepinnten interaktiven Setup-Stand. Tool-Aktionen bleiben bewusste Benutzerentscheidungen.\n'
cd "$target"
bash ./setup_ultimate.sh
