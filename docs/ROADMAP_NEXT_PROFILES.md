# Roadmap Next Profiles

## P0: Security und Konsistenz

- Doctor-Skripte regelmaessig im Setup-Menue sichtbar machen.
- Secret-Scan vor Commit als Standardempfehlung.
- Profile mit `status` und `tier` weiter vervollstaendigen.
- Tool-Quellen transparenter machen: jedes Tool soll in `config/tools.yml` und im Diagnosebericht eindeutig zeigen, ob es aus GitHub, apt, pip, npm/pnpm, Docker/Podman, curl/wget, Go-Build, Modell-Hub oder Cloud/API stammt.
- Installation nur dann als "GitHub-basiert" markieren, wenn der eigentliche Upstream-Code aus einem GitHub-Repository kommt. Paketmanager-Abhaengigkeiten bleiben separate Quellen.

## P0: Tool-Quellen und GitHub-Abgleich

Diese Liste ist ein Arbeitsstand aus den vorhandenen `scripts/tools/*_install.sh`. Sie ist bewusst als TODO gefuehrt, weil einige Tools zwar GitHub im Skript nutzen, aber zusaetzlich ueber apt, pip, npm/pnpm, Docker Images oder curl/wget weitere Quellen laden.

GitHub-Bezug in Installskripten erkannt:

- `actionlint`, `activepieces`, `aider`, `airbyte`, `apache_tika`, `appsmith`, `argocd_cli`, `autogpt`, `axolotl`, `budibase`, `cadvisor`, `clawbake`, `clawhub`, `clawhub_cli`, `cloudflared`, `comfyui`, `continue_dev`, `crowdsec`, `data_juicer`, `dbt`, `directus`, `distilabel`, `docling`, `esphome`, `faster_whisper`, `fingpt`, `finrag`, `finrobot`, `flowise`, `fooocus`, `forgejo`, `gfpgan`, `github_cli`, `gitleaks`, `grafana_alloy`, `guardrails_ai`, `hadolint`, `healthchecks`, `home_assistant`, `huginn`, `invokeai`, `jupyterlab`, `kimi2`, `kubectx_kubens`, `langflow`, `langfuse`, `lightrag`, `litellm`, `llama_cpp_toolchain`, `llama_factory`, `marker`, `mcpo`, `meilisearch`, `metabase`, `minio`, `mosquitto`, `n8n`, `nats`, `netdata`, `nextcloud`, `nocodb`, `node_exporter`, `node_red`, `open_webui`, `openclaw`, `openclaw_rl`, `opencode`, `openhands`, `openlit`, `openmanus`, `opentofu`, `openwakeword`, `paperless_ngx`, `pipedream`, `pre_commit_hooks`, `prefect`, `promptfoo`, `promtail`, `realesrgan`, `rembg`, `renovate`, `rhasspy`, `rife`, `semgrep`, `sqlite_vec`, `stable_diffusion_webui`, `stable_diffusion_webui_forge`, `stirling_pdf`, `supabase`, `tabby`, `trufflehog`, `unsloth`, `unstructured`, `uptime_kuma`, `velero`, `watchtower`, `web3_py`, `whisper_cpp`, `wyoming`, `zenbot_trader`, `zigbee2mqtt`.

Direkt-/Paketquellen ohne erkannten GitHub-Clone im Installskript:

- `authelia`, `authentik`, `changelog_generator`, `clamav`, `docker`, `docker_compose_plugin`, `ethers_js`, `ffmpeg`, `flux_cli`, `foundry`, `hardhat`, `joplin_cli`, `k3s`, `kubernetes`, `mail_utils_msmtp`, `markdownlint_cli`, `ollama`, `opa`, `opentelemetry`, `pdf_parser`, `penpot`, `pgvector`, `podman`, `release_please`, `tailscale`, `trivy`, `vs_code_server`, `yara`, `zotero`.

Naechste Umsetzung:

- `source_type` je Tool ergaenzen: `github`, `apt`, `pip`, `npm`, `pnpm`, `docker`, `curl_binary`, `go_build`, `model_hub`, `cloud_api`, `mixed`.
- `source_url` und `upstream_repo` getrennt erfassen, damit z. B. Docker Images, GitHub-Repos und Paketmanager sauber auseinanderfallen.
- Diagnosebericht pro Installation um "Quellen" erweitern, damit sofort sichtbar ist, was von wo geladen wurde.
- Fuer Tools mit Direktdownload Pruefsummen, Versionspins oder offizielle Release-URLs bevorzugen.
- Fuer GitHub-Tools pruefen, ob Repository, Branch/Tag und Commit im Log festgehalten werden.

## P1: Codex, Browser und Agenten

- Browser-Automation nur mit Allowlist.
- Self-Learning-Agent-Lab als Replay-/Eval-Umgebung ausbauen.
- Prompt-Generator-Studio mit Prompt-Registry verbinden.

## P2: Memory, RAG und Dokumente

- Memory Import/Export mit Redaction-Pipeline.
- Docling/Tika/Paperless/Qdrant besser zusammenfuehren.
- Profile `Document_AI` und `Document_Intelligence` konsolidieren.

## P3: Media, GPU und Android

- Render-Farm/GPU-Workstation nur nach Hardware-Check.
- Android-App-Builder erst nach SDK-/Gradle-Doctor.
- Legal-Safe-Creator fuer Creator-Workflows erweitern.
