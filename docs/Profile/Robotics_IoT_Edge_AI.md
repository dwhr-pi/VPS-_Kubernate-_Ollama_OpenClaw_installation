# Robotics_IoT_Edge_AI

## Zweck
ESP32-, Arduino-, MQTT- und Edge-AI-Workflows für Sensorik, Automatisierung und lokale Auswertung.

## Typische Aufgaben
- Firmware-Projekte
- Edge-Kamera- und Sensor-Pipelines
- MQTT-basierte Automatisierung
- lokale CV-Auswertung auf Edge-Systemen

## Empfohlene Tools
PlatformIO, OpenCV Python, ESPHome, Mosquitto, Zigbee2MQTT.

## Optionale Tools
Arduino CLI, Node-RED, Home Assistant.

## Benötigte Ports
`1883`, `8099`

## Ressourcenbedarf
4 GB RAM lokal; mehr bei Bild-/CV-Workflows.

## Sicherheitsrisiken
Greift auf physische Geräte und Heimnetz-Nähe zu. Keine ungetesteten Flows oder OTA-Änderungen auf produktive Geräte schieben.

## Ollama/OpenClaw-Fit
Gut für lokale Assistenz, Diagnose und Steuerlogik, aber nur mit klaren Freigabegrenzen.

## LiteLLM/Open WebUI-Fit
Optional für Bedienung und Assistenz, nicht Kern des Profils.

## Quickstart
`bash scripts/profiles/Robotics_IoT_Edge_AI_install.sh`

## Deinstallation
`bash scripts/profiles/Robotics_IoT_Edge_AI_uninstall.sh`

## Sinnvolle lokale Modelle
Kleine Generalisten und Vision-Helfer für Debugging und Dokumentation.

## Grenzen und Warnhinweise
Keine autonomen Eingriffe in reale Aktoren ohne manuelle Freigabe und Sicherheitslogik.
