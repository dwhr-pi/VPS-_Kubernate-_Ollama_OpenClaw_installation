# Profil: Smart_Home_AI_Assistant

## Zweck
Lokaler Smart-Home-Assistent mit MQTT, Node-RED, ESPHome und Zigbee2MQTT.

## Use Cases
- lokale Automationen
- Sensorik
- Sprachsteuerung
- Home-Assistant-nahe Flows

## Enthaltene Tools
- Node-RED
- Mosquitto
- Zigbee2MQTT
- ESPHome

## Installation
```bash
scripts/profiles/Smart_Home_AI_Assistant_install.sh
```

## Ports
- 1880
- 1883
- 8099

## Modelle
- optional lokale Sprachmodelle

## Abhängigkeiten
- Docker
- LAN-Zugriff

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: 8 GB+
- Storage: 10 GB+

## Sicherheitshinweise
- keine öffentlichen MQTT-Endpunkte
- Zigbee-/Home-Devices getrennt dokumentieren

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/Smart_Home_AI_Assistant_install.sh
```

## Deinstallation
```bash
scripts/profiles/Smart_Home_AI_Assistant_uninstall.sh
```
