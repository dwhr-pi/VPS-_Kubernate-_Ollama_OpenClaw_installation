# AI Model Router Gateway

## Status

- Status: `planned` / `documentation-first`
- Ressourcenklasse: `medium`
- Zielgeraete: WSL2 / MiniPC / Oracle VPS / GPU Server
- Auto-Installation: nein

## Zweck

Routing zwischen lokalen und optionalen Cloud-Modellen mit Fallbacks, Kostenlimits und Local-first-Policy.

## Typische Aufgaben

- Anforderungen und Zielhost pruefen.
- Tools erst nach Resource-/Security-Check installieren.
- Ergebnisse in `~/.openclaw_ultimate_user_data/` statt im Repo speichern.
- Bei schweren Jobs die Queue nutzen.

## Empfohlene Tools

`litellm`, `ollama`, `localai`, `vllm`, `llama_cpp`

## Minimalpfad

1. `bash scripts/doctor.sh` ausfuehren.
2. `bash scripts/check_resource_budget.sh` ausfuehren.
3. Doku und Port-/Secret-Hinweise pruefen.
4. Einzeltools bewusst installieren, keine Batch-Autoinstallation.

## Full-Pfad

Der Full-Pfad bleibt manuell, bis Installer, Uninstaller, Doctor-Check, Portdoku und Rollback vorhanden sind.

## Sicherheitsgrenzen

- Keine Secrets ins Repo schreiben.
- Keine Admin-Panels oeffentlich freigeben.
- Dienste standardmaessig an `127.0.0.1` binden.
- Externer Zugriff nur ueber WireGuard, Headscale, Tailscale oder Reverse Proxy mit Auth.
- KI-Agenten duerfen ohne Freigabe keine produktiven Aenderungen ausfuehren.

## Hinweise fuer Plattformen

| Plattform | Empfehlung |
| --- | --- |
| WSL2 | Nur leichte Tests, Windows-C:-Speicher beachten. |
| MiniPC | Maximal 1 schwerer Job, Queue verwenden. |
| Oracle VPS | Gut fuer Control Plane, Monitoring und Reverse Proxy. |
| Raspberry Pi | Nur leichte Dienste und Watcher-Aufgaben. |
| RTX/GPU | Geeignet fuer schwere Medien-/LLM-Aufgaben. |
| Kubernetes/K3s | Erst nach stabiler Einzelinstallation. |

## Beispiel-Prompt

```text
Plane dieses Profil fuer meinen Zielhost. Pruefe zuerst Ressourcen, Ports, Secrets und Rollback. Installiere nichts Schweres ohne explizite Freigabe.
```
