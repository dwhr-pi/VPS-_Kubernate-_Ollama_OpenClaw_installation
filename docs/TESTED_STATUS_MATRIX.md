# Tested Status Matrix

| Status | Bedeutung |
|---|---|
| planned | Dokumentiert, noch nicht automatisch voll installierbar. |
| documented | Profil/Tool ist beschrieben, Installer fehlt oder ist Stub. |
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
