# n8n Workflows fuer Elektronikentwicklung

## PCB Review nach Pull Request

- GitHub PR erstellt.
- n8n holt geaenderte KiCad-Dateien.
- OpenClaw startet Schaltplan-/PCB-Review.
- Report wird als Markdown-Kommentar oder Artefakt abgelegt.

## BOM Preisvergleich

- BOM CSV aus KiCad exportieren.
- n8n prueft Lieferanten-/Preisquellen.
- Fehlende oder riskante Teile werden markiert.
- Alternative Footprints und Second Sources werden vorgeschlagen.

## Datenblatt Import

- PDF in `datasheets/` ablegen.
- Parser extrahiert Pins, Grenzwerte, Layout-Hinweise.
- RAG-Index fuer Ollama/OpenClaw aktualisieren.

## Firmware Build

- Commit triggert PlatformIO/Arduino/ESP-IDF Build.
- Buildlog wird gespeichert.
- Fehleranalyse-Agent fasst Ursachen zusammen.

## OTA und Home Assistant

- Erfolgreicher Firmware-Build erzeugt OTA-Kandidat.
- Home Assistant Discovery Payload wird generiert.
- MQTT-Test prueft Sensorwerte.

