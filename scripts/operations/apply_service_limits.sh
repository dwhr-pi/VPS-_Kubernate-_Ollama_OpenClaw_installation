#!/usr/bin/env bash
# Persistente Limits vorbereiten; laufende Dienste nur mit separater Freigabe neustarten.
set -euo pipefail
umask 077
unit=ollama.service memory=8G cpu=200 mode=plan restart=0
die() { printf 'Ressourcen-Limits abgebrochen: %s\n' "$*" >&2; exit 1; }
while (($#)); do
  case "$1" in
    --unit|--memory-max|--cpu-quota)
      (($# >= 2)) || die 'Optionswert fehlt.'
      case "$1" in --unit) unit=$2 ;; --memory-max) memory=$2 ;; --cpu-quota) cpu=$2 ;; esac
      shift 2 ;;
    --apply) mode=apply; shift ;;
    --restart) restart=1; shift ;;
    *) die '--unit NAME --memory-max 8G --cpu-quota 200 [--apply --restart]' ;;
  esac
done
case "$unit" in ollama.service|comfyui.service|openclaw-core-ollama.service|openclaw-core-openclaw.service) ;; *) die 'Nur explizite KI-Dienstnamen zugelassen.' ;; esac
[[ "$memory" =~ ^([1-9][0-9]{0,5})([KMG])$ && "$cpu" =~ ^[1-9][0-9]{0,3}$ ]] || die 'Ungueltige Ressourcenwerte.'
# Nach separater Regexpruefung keine ungeprueften arithmetischen Ausdruecke verwenden.
amount=${memory%[KMG]}
case "$memory" in *K) bytes=$((amount*1024)) ;; *M) bytes=$((amount*1024*1024)) ;; *G) bytes=$((amount*1024*1024*1024)) ;; esac
content=$(printf '# Verwaltet: openclaw-service-limits-v1\n[Service]\nMemoryHigh=%s\nMemoryMax=%s\nCPUQuota=%s%%\n' "$((bytes*9/10))" "$memory" "$cpu")
printf '%s\n' "$content"
[[ "$mode" == apply ]] || { printf 'Nur Plan; kein systemd-Zugriff.\n'; exit 0; }
[[ "$EUID" == 0 && $(uname -s) == Linux ]] || die 'Apply nur als root unter Linux.'
total_kib=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
total=$((total_kib*1024))
# 8G auf einem 8G-Host waere keine Schutzreserve; mindestens 1 GiB frei lassen.
((bytes <= total-1073741824)) || die 'MemoryMax ist fuer diesen Host zu gross; mindestens 1 GiB Hostreserve erforderlich.'
[[ $(systemctl show "$unit" -p LoadState --value) == loaded ]] || die 'Dienst nicht geladen; keine fremde Unit erstellen.'
target="/etc/systemd/system/$unit.d"
[[ ! -L "$target" && ! -L "$target/limits.conf" ]] || die 'Symlink im Drop-in-Pfad.'
install -d -m 755 "$target"
if [[ -e "$target/limits.conf" ]]; then
  [[ -f "$target/limits.conf" ]] || die 'Ziel ist keine regulaere Datei.'
  [[ $(cat -- "$target/limits.conf") == "$content" ]] || die 'Vorhandenes abweichendes Drop-in bleibt erhalten; Anpassung separat pruefen.'
else
  printf '%s\n' "$content" > "$target/limits.conf"
  chmod 644 "$target/limits.conf"
fi
if ((restart)); then
  systemctl daemon-reload
  systemctl restart "$unit"
else
  printf 'Drop-in vorbereitet, noch kein daemon-reload. Aktivierung nur im Wartungsfenster mit --restart.\n'
fi
