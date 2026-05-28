# Setup Scorecard

Stand: 2026-05-28

| Bereich | Bewertung | Begruendung | Naechster Schritt |
|---|---:|---|---|
| Modularitaet | 8/10 | Profile, Tools, Ports, Security und Docs sind getrennt. | Registry-Generierung weiter automatisieren. |
| WSL2-Tauglichkeit | 7/10 | Speicherwache, Cleanup und WSL-Hinweise vorhanden. | Systemprofil-Detector vor schweren Tools anzeigen. |
| Installierbarkeit | 6/10 | Viele Installer vorhanden, aber schwere Upstreams wechseln schnell. | Tool-Statusmatrix konsequent pflegen. |
| Security Defaults | 8/10 | Localhost-first, Secret-Hinweise, Remote-Tunnel-Doku. | Human-Approval-Gates weiter in Menues sichtbar machen. |
| Rollback/Cleanup | 7/10 | Cleanup und Messwerte vorhanden. | Pro Tool klare Restore-/Uninstall-Hinweise ergaenzen. |
| Monitoring | 7/10 | Prometheus/Grafana/Uptime Kuma dokumentiert. | Minimal-Monitoring als empfohlenen Pfad testen. |
| Dokumentation | 8/10 | Viele Detaildocs vorhanden. | README kurz halten, Detaildocs verlinken. |

## Wichtigste Risiken

- Airbyte, AutoGPT, ComfyUI und Activepieces sind schwergewichtige Upstream-Projekte und fuer knappe WSL2-/MiniPC-Systeme riskant.
- Docker/kind/Kubernetes-Stacks koennen viel Speicher binden, auch wenn eine Installation fehlschlaegt.
- Multi-Agent-, Smart-Home-, Trading- und Security-Profile brauchen weiterhin manuelle Freigabe.

## Stabile Pfade

- Minimal: Ollama, OpenClaw, Open WebUI, Qdrant/ChromaDB, Uptime Kuma, Gitleaks/Trivy.
- WSL2 sicher: kleine Modelle, lokale Docs, Cleanup, keine parallelen schweren Docker-Stacks.
- VPS sicher: Tailscale/cloudflared, UFW/Fail2Ban, Uptime Kuma, kleine Web-UIs nur mit Auth.
