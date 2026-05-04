# Profil: Robotics_IoT_Edge_AI

## Zweck

Lokale Edge-AI- und IoT-Plattform fuer Sensorik, MQTT, Home Assistant und spaetere ESP-/Robotik-Pfade.

## Installierbare Kern-Tools

- `home_assistant`
- `node_red`
- `mosquitto`
- `zigbee2mqtt`
- `esphome`

## Optionale / noch nicht sauber verdrahtete Tools

- spaeter sinnvoll: `PlatformIO`, `Arduino CLI`, `ROS2`, Kamera-/Audio-Edge-Pipelines

## Hardware / Plattform

- gut fuer `MiniPC`, Edge-Systeme, `VPS` als Begleitinstanz
- lokale Funk- und Netzwerkanbindung beachten

## Risiken und Grenzen

- Smart-Home- und Sensordaten sind privat
- externe Freigaben nur ueber abgesicherte Tunnel/Reverse Proxies

## Quickstart

```bash
bash scripts/profiles/Robotics_IoT_Edge_AI_install.sh
```
