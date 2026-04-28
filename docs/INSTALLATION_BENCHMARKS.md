# Installations-Benchmarks und editierbare Schätzwerte

Das Setup enthält jetzt eine editierbare Datei für Installations-Schätzwerte und Platzbedarf:

- [config/setup_metrics.conf](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/config/setup_metrics.conf:1)

## Zweck

Darin kannst du für jede wichtige Sektion eigene Werte pflegen, zum Beispiel:

- benötigte freie GB
- geschätzte Downloadzeit
- geschätzte Installationszeit
- Zielsystem, z. B. Letsung MiniPC mit Windows 11 original
- Ziel-Linux, z. B. Ubuntu 24.04 LTS unter WSL2

## Bereits vorbelegt

Die Datei ist schon mit ersten Schätzwerten vorbelegt für:

- Windows 11 original auf Letsung MiniPC
- Ubuntu 24.04 LTS unter WSL2
- Basis-Setup
- Ubuntu-Updates
- OpenClaw Build
- Ollama
- Home Assistant
- Cloudflared
- alle großen Profile mit grobem GB-Bedarf

## Im Setup bearbeiten

Im Hauptmenü gibt es dafür jetzt einen eigenen Punkt:

- `Setup-Messwerte & Benchmarks bearbeiten`

Dort wird die Datei direkt editierbar geöffnet.

## Wichtiger Hinweis

Alle Werte sind absichtlich nur editierbare Schätzwerte. Je nach:

- Internetgeschwindigkeit
- SSD-/NVMe-Leistung
- CPU
- RAM
- gewähltem Profil
- zusätzlicher Tool-Auswahl

kann die echte Installationsdauer oder der Platzbedarf deutlich abweichen.
