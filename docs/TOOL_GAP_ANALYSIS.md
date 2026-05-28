# Tool Gap Analysis

Neue Tools werden nicht blind installiert. Sie werden zuerst als optionale Kandidaten mit Quelle, Risiko, Healthcheck und Deinstallationshinweis dokumentiert.

## Empfohlen / niedriger bis mittlerer Einstieg

| Tool | GitHub | Zweck | Default |
|---|---|---|---|
| modelcontextprotocol/servers | https://github.com/modelcontextprotocol/servers | MCP-Beispiele und Server-Hub | documentation-first |
| lobehub/lobe-chat | https://github.com/lobehub/lobe-chat | Chat-UI fuer lokale/remote Modelle | optional |
| windmill-labs/windmill | https://github.com/windmill-labs/windmill | Workflow-Automation | optional |
| trufflesecurity/trufflehog | https://github.com/trufflesecurity/trufflehog | Secret-Scan | optional |
| filebrowser/filebrowser | https://github.com/filebrowser/filebrowser | leichte Datei-Web-UI | optional |
| AUTOMATIC1111/stable-diffusion-webui | https://github.com/AUTOMATIC1111/stable-diffusion-webui | Bildgenerierung | optional/gpu |
| invoke-ai/InvokeAI | https://github.com/invoke-ai/InvokeAI | Bildgenerierung UI/API | optional/gpu |

## Schwer / experimentell

| Tool | GitHub | Risiko | Default |
|---|---|---|---|
| milvus-io/milvus | https://github.com/milvus-io/milvus | hoher Ressourcenbedarf | documentation-only |
| infiniflow/ragflow | https://github.com/infiniflow/ragflow | grosser Stack | documentation-only |
| wazuh/wazuh | https://github.com/wazuh/wazuh | schwerer Security-Stack | documentation-only |
| kubernetes/kubernetes | https://github.com/kubernetes/kubernetes | Cluster-Komplexitaet | documentation-only |
| k3s-io/k3s | https://github.com/k3s-io/k3s | Cluster-Komplexitaet | optional/vps |
| containers/podman | https://github.com/containers/podman | Runtime-Aenderung | optional |
| coqui-ai/TTS | https://github.com/coqui-ai/TTS | Python-Versionen, grosse Modelle | optional/experimental |

## Schon vorhanden oder naheliegend vorhanden

Autogen, CrewAI, LangGraph, Open WebUI, Continue.dev, Aider, OpenHands, Chroma, Qdrant, Weaviate, Haystack, Firecrawl, SearXNG, n8n, Activepieces, Huginn, Node-RED, Grafana, Prometheus, Uptime Kuma, Trivy, Grype, Gitleaks, Pi-hole, Tailscale, cloudflared, Helm, Gitea/Forgejo, act, ComfyUI, Blender, Transformers, Diffusers, Nextcloud, Syncthing, Restic und Rclone sind im Projektkontext bereits bekannt oder sollten ueber Registry-Sync geprueft werden.

## Healthcheck-Muster

| Tooltyp | Healthcheck |
|---|---|
| CLI | `command -v <tool>` und `<tool> --version` |
| Docker App | Containerstatus, Port nur `127.0.0.1`, Health-Endpoint |
| Python Tool | venv vorhanden, `python -m pip check`, Importtest |
| Node Tool | `node --version`, `corepack --version`, `pnpm --version`, Lockfile vorhanden |
| Service | systemd/User-Service Status, Logpfad, Port-Matrix |
