# Tested Status Matrix

| Status | Bedeutung |
|---|---|
| planned | Dokumentiert, noch nicht automatisch voll installierbar. |
| documented | Profil/Tool ist beschrieben, Installer fehlt oder ist Stub. |
| ungeprueft | Fuer den genannten Pruefumfang liegt keine Installationsabnahme vor. |
| installable | Installer vorhanden, aber noch nicht breit getestet. |
| tested | Lokal in mindestens einem Zielpfad getestet. |
| stable | Wiederholt getestet, Healthcheck vorhanden, sichere Defaults. |

## Aktuelle Einordnung

| Bereich | Status | Hinweis |
|---|---|---|
| Base Setup, Logs, Speichertracking | installable | WSL2/Windows-Speicherhinweise vorhanden. |
| Docker Compose Helper | installable | GitHub-Compose-Plugin und sudo-Fallback vorhanden. |
| Office/RAG/Memory | documented/installable | Je nach Tool; neue Profile sind planned. |
| Activepieces/Airbyte/n8n | experimental | Grosse Monorepos, Node/Bun/pnpm empfindlich. |
| GPU/Video/3D/Kubernetes | documented/experimental | Nicht Default. |
| Security/Trading/Robotik | documented | Human-Approval-Gates erforderlich. |
| Tools aus Codeberg | ungeprueft | Installation derzeit nicht getestet; gilt auch fuer das vorhandene Forgejo-Buildrezept. |
| Tools aus GitLab | ungeprueft | Installation derzeit nicht getestet; recherchierte Projekte sind keine abgenommenen Installer. |

## Quellenplattformen: Installationsstatus

[Gemini-Desktop-Projekte](tools/gemini-desktop-clients.md): manuelle Releases und
Studienquellen. Windows-Installation/Builds und CLI-/OpenClaw-Adapter ungeprueft;
Dortanes archiviert, Bwendell-Pflege pausiert. Kein automatischer Login/GUI-Start.

[OpenAPI Servers](tools/openapi-servers.md): private Zeitserver-Umgebung plus
separate Loopback-/Bearer-Einrichtung. Installation, Serverstart und
Open-WebUI-End-to-End-Test vom 28.10.2026 noch ungeprueft.

[Godot, XR Tools, O3DE und Lively](tools/ai-game-engines-xr-wallpaper.md):
neue optionale Quell-/Buildwege vom 28.10.2026; Installation, Export und
VR-/AR-/Wallpaper-Betrieb ungeprueft. Offline-Tests sind keine Hardwareabnahme.

Nutzerhinweis vom 27.10.2026: **Codeberg- und GitLab-Tools sind derzeit in der
Installation ungetestet.** Eine dokumentierte Quelle, ein vorhandenes Buildrezept
oder bestandene Offline-/Mocktests ersetzen keinen Installationsnachweis.

[GitLab, OpenForge, GENIE.AI und MLflow](tools/gitlab-openforge-mlflow.md)
dokumentiert die konkreten Nutzerquellen und den optionalen CI-/Review-Einstieg,
ohne diesen Installationsstatus anzuheben.

Das beschreibt die fehlende Abnahme, nicht einen nachgewiesenen Fehler dieser
Tools. Erst nach einem protokollierten Test des konkreten Pins auf der genannten
Zielplattform darf eine Installationsfreigabe beziehungsweise ein `tested`-Status
ausgewiesen werden. Bestehende Quellen-/Build-Modi bleiben davon getrennt.
