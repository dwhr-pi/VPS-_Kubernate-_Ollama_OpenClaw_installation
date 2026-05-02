#!/usr/bin/env bash
set -euo pipefail

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
nc='\033[0m'

ok() { echo -e "${green}[OK]${nc} $1"; }
warn() { echo -e "${yellow}[WARN]${nc} $1"; }
fail() { echo -e "${red}[FAIL]${nc} $1"; }

check_port() {
  local port="$1"
  local label="$2"
  if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$port )" | tail -n +2 | grep -q .; then
    ok "$label auf Port $port erreichbar oder gebunden."
  else
    warn "$label auf Port $port aktuell nicht gefunden. Reparatur: Dienst starten oder Portkonflikte prüfen."
  fi
}

echo "Healthcheck All"
echo "==============="

if command -v docker >/dev/null 2>&1; then ok "Docker ist installiert."; else fail "Docker fehlt. Reparatur: Tool/Profil mit Docker-Grundlage installieren."; fi
if command -v k3s >/dev/null 2>&1 || systemctl is-active --quiet k3s 2>/dev/null; then ok "K3s ist vorhanden/aktiv."; else warn "K3s nicht aktiv. Reparatur: K3s- oder DevOps-Profil prüfen."; fi
if command -v ollama >/dev/null 2>&1; then ok "Ollama CLI vorhanden."; else fail "Ollama fehlt."; fi

check_port 11434 "Ollama"
check_port 3000 "Open WebUI"
check_port 4000 "LiteLLM"
check_port 6333 "Qdrant"
check_port 3003 "Langfuse"
check_port 3001 "Grafana"
check_port 9090 "Prometheus"
check_port 1880 "Node-RED"
check_port 1883 "Mosquitto"

free_kb="$(df -Pk / | awk 'NR==2 {print $4}')"
if [ "${free_kb:-0}" -gt 10485760 ]; then
  ok "Freier Speicher > 10 GB."
else
  warn "Wenig freier Speicher. Reparatur: Modelle/Container/Volumes bereinigen."
fi

ram_mb="$(awk '/MemTotal/ {printf \"%d\", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
if [ "${ram_mb:-0}" -gt 8000 ]; then
  ok "RAM-Basis ausreichend (${ram_mb} MB)."
else
  warn "RAM eher knapp (${ram_mb} MB). Schwere Medien-/RAG-Profile vorsichtig wählen."
fi

if command -v nvidia-smi >/dev/null 2>&1; then
  ok "NVIDIA-GPU erkannt."
  nvidia-smi --query-gpu=name,memory.total --format=csv,noheader || true
elif command -v rocminfo >/dev/null 2>&1; then
  ok "ROCm-/AMD-GPU-Hinweis erkannt."
else
  warn "Keine GPU-Erkennung verfügbar. Bild-/Video-Profile könnten nur eingeschränkt laufen."
fi

if command -v ollama >/dev/null 2>&1; then
  echo
  echo "Verfügbare Ollama-Modelle:"
  ollama list || warn "Ollama antwortet nicht sauber. Reparatur: ollama serve prüfen."
fi
