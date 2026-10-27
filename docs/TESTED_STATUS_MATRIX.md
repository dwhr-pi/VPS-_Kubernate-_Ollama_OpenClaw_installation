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

Nutzerhinweis vom 27.10.2026: **Codeberg- und GitLab-Tools sind derzeit in der
Installation ungetestet.** Eine dokumentierte Quelle, ein vorhandenes Buildrezept
oder bestandene Offline-/Mocktests ersetzen keinen Installationsnachweis.

Das beschreibt die fehlende Abnahme, nicht einen nachgewiesenen Fehler dieser
Tools. Erst nach einem protokollierten Test des konkreten Pins auf der genannten
Zielplattform darf eine Installationsfreigabe beziehungsweise ein `tested`-Status
ausgewiesen werden. Bestehende Quellen-/Build-Modi bleiben davon getrennt.
