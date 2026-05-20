# Elektronik Entwickler Guide

Dieser Guide beschreibt das optionale Elektronik-Entwicklerprofil fuer PCB, Embedded, FPGA und Home-Assistant-Hardware.

## Projektstruktur

```text
Ultimate_KI_Setup/electronics/
  projects/
  kicad/
  freecad/
  firmware/
  fpga/
  datasheets/
  bom/
  gerber/
  simulations/
  dashboards/
  logs/
  exports/
```

## Lokale Installation

```bash
bash scripts/tools/electronics_dev_install.sh
```

Der Installer nutzt bevorzugt apt, pipx/pip und npm/pnpm. Er installiert keine proprietaeren Cloud-Abhaengigkeiten und erzwingt kein Docker.

## Empfohlene Arbeitsweise

1. Datenblatt in `datasheets/` ablegen.
2. OpenClaw/Codex erstellt Design-Briefing und Pinout-Matrix.
3. KiCad-Projekt erzeugen oder importieren.
4. ERC/DRC/Gerber/BOM pruefen.
5. Firmware mit PlatformIO, ESP-IDF, Arduino CLI oder Zephyr bauen.
6. Optional FPGA mit Verilator/Yosys/GTKWave simulieren.
7. n8n oder GitHub Actions erzeugen Review-Report.

## KiCad AI

Moegliche Integrationen:

- Seeed-Studio `kicad-mcp-server` fuer KiCad Analyse/Automation.
- `kicad-happy` als Agent-Skill-Sammlung fuer KiCad Reviews, EMC, SPICE und Fertigungsvorbereitung.
- Circuit-Synth fuer Python-definierte Schaltungen und KiCad-Integration.
- tscircuit fuer TypeScript/React-basierte Elektronik-Prototypen.

## WSL2 / Windows 11

- GUI-Tools wie KiCad/FreeCAD koennen direkt unter Windows oder per WSLg laufen.
- USB/JTAG/Serial Debugging unter WSL2 benoetigt oft `usbipd-win`.
- Fuer OpenOCD und Board-Flashing ist Windows-nativ manchmal stabiler.
- Projektdateien moeglichst im Linux-Dateisystem halten, wenn viele kleine Build-Dateien entstehen.

## GPU

GPU ist fuer EDA nicht Pflicht. Sie ist eher fuer lokale LLMs, RAG, Bild-/Board-Analyse und spaetere Dashboard-/Vision-Workflows relevant.

- NVIDIA/RTX: Ollama/LLM-Beschleunigung, CUDA optional.
- AMD/Intel: je nach Ollama/Runtime; EDA-Tools selbst meist CPU-lastig.
- FPGA/EDA-Synthese profitiert meistens mehr von CPU/RAM als GPU.

## Troubleshooting

- KiCad startet nicht unter WSL2: Windows-native KiCad-Version verwenden oder WSLg pruefen.
- OpenOCD findet Board nicht: USB-Passthrough mit `usbipd` pruefen.
- PlatformIO nutzt falsche Python-Version: venv oder pipx isoliert verwenden.
- ESP-IDF ist schwer: erst PlatformIO/Arduino CLI testen, ESP-IDF nur bei Bedarf aktivieren.
- OpenLane/OpenROAD sind gross: nur auf Workstations oder separaten Build-Nodes installieren.

