# Installations-Benchmarks und editierbare Schätzwerte

Das Setup enthält jetzt eine editierbare Datei für Installations-Schätzwerte und Platzbedarf:

- `~/.openclaw_ultimate_user_data/setup_metrics.conf`

Zusätzlich schreibt das Setup jetzt echte Messwerte in:

- `~/.openclaw_ultimate_user_data/metrics_logs/operation_history.tsv`

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

Die automatisch aufgezeichneten echten Messwerte landen hier:

```text
~/.openclaw_ultimate_user_data/metrics_logs/operation_history.tsv
```

## Automatische Erfahrungswerte

Das Setup misst bei wichtigen Vorgängen jetzt automatisch:

- Startzeit
- Endzeit
- Gesamtdauer
- freien Speicher vor dem Start
- freien Speicher nach dem Ende
- daraus die grobe Speicheränderung

Das gilt insbesondere für:

- große Hauptmenü-Installationen
- Profil-Installationen und Profil-Deinstallationen
- Tool-Installationen und Tool-Deinstallationen

Damit bekommst du mit der Zeit echte Erfahrungswerte deines eigenen Systems statt nur allgemeiner Schätzungen.

Diese Werte kannst du später nutzen, um die Standard-Schätzwerte in `setup_metrics.conf` besser an deine reale Umgebung anzupassen.

## Wichtiger Hinweis

Alle Werte sind absichtlich nur editierbare Schätzwerte. Je nach:

- Internetgeschwindigkeit
- SSD-/NVMe-Leistung
- CPU
- RAM
- gewähltem Profil
- zusätzlicher Tool-Auswahl

kann die echte Installationsdauer oder der Platzbedarf deutlich abweichen.
