# Installations-Benchmarks und editierbare Schätzwerte

Das Setup enthält jetzt eine editierbare Datei für Installations-Schätzwerte und Platzbedarf:

- `~/.openclaw_ultimate_user_data/setup_metrics.conf`

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

## Speicherort

Die Datei liegt bewusst außerhalb des Repositories, damit sie bei Updates erhalten bleibt und nicht versehentlich ins Git-Repository geschrieben wird:

```text
~/.openclaw_ultimate_user_data/setup_metrics.conf
```

## Wichtiger Hinweis

Alle Werte sind absichtlich nur editierbare Schätzwerte. Je nach:

- Internetgeschwindigkeit
- SSD-/NVMe-Leistung
- CPU
- RAM
- gewähltem Profil
- zusätzlicher Tool-Auswahl

kann die echte Installationsdauer oder der Platzbedarf deutlich abweichen.
