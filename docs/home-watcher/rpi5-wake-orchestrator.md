# Raspberry Pi 5 / Mini-PC als Wake-Orchestrator

Der Heimnetz-Waechter ist ein kleines System, das immer eingeschaltet bleibt.
Er verbindet das Heimnetz per WireGuard mit dem Oracle VPS und kann den
RTX-/KI-Server per Wake-on-LAN starten.

## Aufgaben

- WireGuard Peer zum Oracle VPS
- Wake-on-LAN Magic Packets
- Statuspruefung lokaler Nodes
- Home Assistant Integration
- Healthchecks an VPS melden
- optional K3s Edge Node
- optional Frigate/Coral/Hailo-Integration

## Wake-on-LAN testen

Dry-Run:

```bash
bash scripts/home-watcher/wake-gpu-server.sh --dry-run
```

Anwenden:

```bash
GPU_SERVER_MAC=GPU_SERVER_MAC bash scripts/home-watcher/wake-gpu-server.sh --apply
```

## Serverstatus pruefen

```bash
GPU_SERVER_IP=GPU_SERVER_IP bash scripts/home-watcher/check-gpu-server.sh
```

## Idle Shutdown

Der RTX-Server kann optional herunterfahren, wenn er laenger nichts tut.

```bash
GPU_SERVER_IP=GPU_SERVER_IP bash scripts/home-watcher/shutdown-idle-gpu-server.sh --dry-run
```

Warnung:

Automatisches Herunterfahren erst aktivieren, wenn Jobs, Downloads und Modelle
nicht versehentlich unterbrochen werden.
