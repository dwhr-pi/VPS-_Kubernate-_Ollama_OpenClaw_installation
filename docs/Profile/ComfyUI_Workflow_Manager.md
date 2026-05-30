# ComfyUI_Workflow_Manager

## Zweck

ComfyUI Workflows organisieren und ressourcenschonend starten.

## Status

- Installationsreife: planned
- Ressourcenklasse: gpu-heavy
- Empfohlene Geraete: GPU Workstation

## Empfohlene Tools

- comfyui
- queue_manager

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil ComfyUI_Workflow_Manager fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
