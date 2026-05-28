# Tool Integration Matrix

| Toolgruppe | Installationsart | Risiko | Doctor-Idee |
|---|---|---|---|
| Ollama/OpenClaw | binary/source | mittel | Port, Version, Token, Modellliste |
| n8n/Huginn/Node-RED | npm/docker/source | mittel | Port, DB, Workflow-Status |
| Qdrant/Chroma/Postgres | docker/venv/apt | mittel | Port, Collection, Speicher |
| LangGraph/CrewAI/AutoGen | venv | mittel | Importtest, Version |
| Aider/OpenCode/GitHub CLI | pipx/npm/binary | niedrig-mittel | Version, Git-Kontext |
| Authentik/Authelia/OIDC | docker/binary | hoch | Port, TLS, Adminschutz |
| Podman/K3s/Helm | apt/binary | hoch | Runtime/Clusterstatus |
| ComfyUI/Video/Blender | source/venv/binary | hoch | Speicher/GPU/Version |

## Status

Diese Matrix ist ein Einstieg. Maschinenlesbare Werte sollen schrittweise in `config/tools.yml` gepflegt werden.
