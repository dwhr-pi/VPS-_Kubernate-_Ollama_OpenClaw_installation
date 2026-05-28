# Installation Risk Levels

| Level | Bedeutung | Beispiele | Setup-Verhalten |
|---|---|---|---|
| leicht | wenig Speicher, kein Dienst oder nur CLI | Gitleaks, ShellCheck, shfmt, Restic | normale Auswahl |
| mittel | Dienst oder mehrere Pakete | Open WebUI, Qdrant, Uptime Kuma, Paperless | Speicher-/Portpruefung |
| schwer | Docker/Monorepo/grosse Downloads | Airbyte, AutoGPT, Activepieces, Nextcloud | Warnung, kein Auto-Install |
| GPU | VRAM/Modelle/grosse Artefakte | ComfyUI, Forge, vLLM, Blender-Render | nur bei GPU und Freigabe |
| experimental | instabiler Upstream oder komplexe Integration | Kubernetes, Multi-Agent-Router, Voice Clone | Doku-first, manuell |

## Regeln

- Kein schweres Tool automatisch installieren.
- Vor schweren Tools: RAM, Swap, Linux-Speicher, Windows-C:-Speicher unter WSL2 pruefen.
- Nach Fehlern: Log, Diagnose, Wiederholen, Ueberspringen, Zurueck anbieten.
- Ports default auf `127.0.0.1` oder Tailnet/Tunnel, nicht blind oeffentlich.
