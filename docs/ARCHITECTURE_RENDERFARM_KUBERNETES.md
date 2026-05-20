# Architektur Renderfarm und Kubernetes

Dieses Dokument beschreibt den optionalen verteilten Betrieb fuer Rendering, KI-Bildsysteme, IFC-Analyse und Storage.

## Rollen

- `planner`: Ollama/OpenClaw, Prompting, Job-Aufteilung.
- `render-gpu`: Blender/Cycles, RTX/OptiX, GPU-Renders.
- `comfy-gpu`: ComfyUI, Flux, SDXL, ControlNet, LoRAs.
- `bim-cpu`: IfcOpenShell, FreeCAD, QGIS, Reports.
- `storage`: MinIO/NFS/Longhorn fuer Projekte, Texturen und Cache.

## Multi-GPU

- Parallele Renderjobs sind meist stabiler als ein grosser verteilter Einzeljob.
- Ein Renderjob pro GPU ist einfach planbar.
- Texturen und Assets vorher auf Shared Storage synchronisieren.
- Rendercache mit TTL/Quota begrenzen.

## Remote Zugriff

- Cloudflare Tunnel oder Tailscale fuer WebUIs.
- Keine offenen Ports fuer Blender, ComfyUI oder Filebrowser.
- Authentik/Authelia optional als zentrale Auth-Schicht.

