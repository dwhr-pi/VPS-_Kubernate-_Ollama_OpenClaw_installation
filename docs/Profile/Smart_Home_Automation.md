# Profil: Smart_Home_Automation

## Zweck
Smart-Home-Automation mit Home Assistant, Node-RED, MQTT und optional Zigbee2MQTT.

## Use Cases
- Home Assistant Automationen
- MQTT-Broker
- Node-RED-Flows
- Cloudflare- und Alexa-nahe Integrationen

## Enthaltene Tools
- Home Assistant
- Node-RED
- Mosquitto
- Zigbee2MQTT optional

## Installation
```bash
scripts/profiles/Smart_Home_Automation_install.sh
```

## Ports
- 1880 Node-RED
- 1883 MQTT
- 8123 Home Assistant

## Modelle
- optional lokale Sprachmodelle für Steuerung

## Abhängigkeiten
- Docker
- Netzwerkzugriff im LAN

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: ab 10 GB

## Sicherheitshinweise
- MQTT und Home Assistant nie offen ohne Auth
- Tunnel und Alexa bewusst absichern

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/Smart_Home_Automation_install.sh
```

## Deinstallation
```bash
scripts/profiles/Smart_Home_Automation_uninstall.sh
```
