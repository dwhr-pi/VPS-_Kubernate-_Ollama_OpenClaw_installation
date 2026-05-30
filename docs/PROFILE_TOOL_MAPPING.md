# Profile Tool Mapping

Quelle: `config/profiles.yml`.

| Profil | Tier | Status | Kern-Tools |
|---|---|---|---|
| Prompt_Generator_Studio | recommended | beta | Ollama, LiteLLM, Open WebUI, Promptfoo, Langfuse |
| Memory_Import_Export | recommended | beta | Qdrant, ChromaDB, DuckDB, Docling, Apache Tika |
| Self_Learning_Agent_Lab | advanced | experimental | OpenClaw, LiteLLM, Langfuse, Promptfoo, OpenLIT |
| Home_Network_Security | recommended | beta | Tailscale, cloudflared, UFW, CrowdSec |
| Android_App_Builder | advanced | planned | Java/Gradle/Android SDK als geplanter Baustein |
| AI_Dashboard_Builder | recommended | beta | Grafana, Prometheus, Loki, Netdata, Appsmith |
| Render_Farm_GPU_Workstation | advanced | experimental | ComfyUI, Forge, Blender, RealESRGAN |
| Legal_Safe_Creator | recommended | beta | Docling, Apache Tika, Paperless-ngx, Qdrant |
| Cyber_Security_AI | advanced | beta | Gitleaks, Semgrep, Trivy, Syft, Grype |
| Anti_Virus | recommended | beta | ClamAV, YARA, Gitleaks |

Profile installieren nie automatisch Web3-, Trading-, offensive Security- oder GPU-Stacks als Default.

## Planned Profile ab 11.17

| Profil | Tier | Status | Kern-Tools |
|---|---|---|---|
| Local_AI_Office_Suite | recommended | planned | Pandoc, Tesseract OCR, Stirling PDF, Paperless-ngx, Docling |
| Android_AI_App_Lab | advanced | planned | Android SDK CLI, Gradle, adb, apktool, jadx, gbox |
| Privacy_First_Cloud_Sync | recommended | planned | Rclone, Syncthing, Nextcloud, Restic, BorgBackup |
| Personal_Memory_Knowledge_OS | recommended | planned | Qdrant, ChromaDB, Open WebUI Memory, LlamaIndex, DuckDB |
| AI_Testing_QA_Lab | recommended | planned | pytest, bats-core, shellcheck, shfmt, Playwright, promptfoo |
| Model_Router_Cost_Control | recommended | planned | LiteLLM, Ollama, Open WebUI, Langfuse, OpenLIT |
| Voice_Transcription_Callcenter | recommended | planned | Whisper.cpp, faster-whisper, Piper, Coqui XTTS optional, FFmpeg |
| Network_HomeLab_ZeroTrust | recommended | planned | Tailscale, Headscale optional, cloudflared, Uptime Kuma, Netdata |
| Data_Scraping_Browser_Agents | advanced | planned | Playwright, Firecrawl, Browserless optional, trafilatura |
| Legal_Compliance_Safety_Review | recommended | planned | reuse, licensee, scancode-toolkit, gitleaks, detect-secrets |
| Prompt_Generator_Allround | recommended | planned | Ollama, OpenClaw, LiteLLM, promptfoo, Langfuse/OpenLIT optional |
| Local_AI_App_Builder | recommended | planned | Node.js LTS, pnpm/Corepack, Vite, React, Playwright, Tauri/Electron optional |

Stub-Installer markieren diese Profile als ausgewaehlt, starten aber keine schweren Toolchains oder oeffentlichen Dienste.

## Alias-Gruppen

| Alias / Spezialname | Hauptprofil |
|---|---|
| Android_Device_Manager, Android_App_Security, Android_Firewall_Monitor, Mobile_Remote_Control, MyExplorer_File_Manager_Dev, myBOX_Android_Container | Android_AI_App_Lab |
| PiHole_DNS_Security, FRITZBox_Mesh_Optimizer, Home_Network_Diagnostics, Adblock_Malware_URL_Checker | Network_HomeLab_ZeroTrust |
| AI_Memory_Hub, Chat_Import_Export, Personal_Context_Vault | Personal_Memory_Knowledge_OS |
| Cloud_Service_Connector, WebDAV_Sync_Hub, Rclone_Cloud_Manager | Privacy_First_Cloud_Sync |
| Desktop_App_Builder, Electron_Tauri_App_Builder, React_Dashboard_Builder | Local_AI_App_Builder |
| Suno_Music_Prompt_Studio, Image_Video_Prompt_Studio | Prompt_Generator_Allround |

## Documentation-first Profile ab 11.18

| Profil | Status | Kern-Tools / Bausteine |
|---|---|---|
| LLMOps_Control_Center | planned | Ollama, LiteLLM, Open WebUI, Langfuse, OpenLIT, Grafana |
| Local_Model_Lifecycle_Manager | planned | Ollama, llama.cpp, Open WebUI, resource_estimator |
| Model_Downloader_Quantizer | experimental | llama.cpp, Ollama, Checksums, Modellquellen |
| Prompt_Testing_Benchmark_Lab | planned | promptfoo, deepeval, pytest, LiteLLM, Langfuse |
| Agent_Safety_Policy_Manager | planned | OpenClaw, LiteLLM, LangGraph, OPA optional |
| Multi_Agent_Router | experimental | LangGraph, AutoGen, CrewAI, OpenClaw |
| N8N_AI_Automation_Engineer | optional | n8n, LiteLLM, Webhooks, Uptime Kuma |
| Home_Assistant_Agent_Builder | optional | Home Assistant, Node-RED, Mosquitto, Piper, Whisper.cpp |
| Webhook_API_Integrator | planned | n8n, Huginn, Node-RED, FastAPI, Uptime Kuma |
| Personal_Command_Center | planned | Open WebUI, OpenClaw, n8n, Qdrant |
| Notification_Router | planned | Uptime Kuma, Healthchecks, n8n, msmtp |
| PDF_OCR_Document_Pipeline | optional | OCRmyPDF, Tesseract, Apache Tika, Docling, Stirling PDF |
| Local_Search_Engine | planned | Meilisearch, SearXNG, DuckDB, Apache Tika, Qdrant |
| Knowledge_Graph_Researcher | experimental | Neo4j optional, Qdrant, LlamaIndex, Docling |
| Personal_Wiki_Agent | planned | Markdown, Qdrant, ChromaDB, DuckDB, Open WebUI |

## myNextCloud AI Mapping

| Profil | Tier | Status | Kern-Tools |
|---|---|---|---|
| mynextcloud_ai | recommended | planned | myNextCloud Server, Ollama, OpenClaw, n8n, Whisper.cpp/faster-whisper |
| mynextcloud_admin | recommended | planned | check_upstream.sh, backup_mynextcloud.sh, setup_env.sh, Home Assistant optional |
| mynextcloud_android | advanced | planned | myNextCloud Mobile, Android Studio, Gradle, upstream sync, Branding-Check |
| mynextcloud_security | recommended | planned | Gitleaks, Trivy, ClamAV/YARA optional, lokale Hash-Pruefung |
| mynextcloud_automation | recommended | planned | n8n, OpenClaw Agents, Ollama, Webhooks, Rate-Limits |
| mynextcloud_homeassistant | recommended | planned | Home Assistant, Tailscale, Cloudflare Access, n8n notifications |

Hinweis: Diese Profile sind bewusst nicht als schwere Auto-Installer freigeschaltet. Server-, Android- und Workflow-Schritte bleiben manuell bestaetigt und dokumentiert.
| Long_Term_Memory_Curator | planned | Qdrant, ChromaDB, DuckDB, Open WebUI Memory |
| AI_Video_Pipeline_Manager | experimental | ComfyUI, FFmpeg, Whisper.cpp, RealESRGAN, RIFE optional |
| ComfyUI_Workflow_Studio | experimental | ComfyUI, ComfyUI Manager optional, FFmpeg, Forge optional |
| Music_Prompt_Producer | planned | FFmpeg, Demucs, MusicGen optional, Piper |
| Voice_Clone_TTS_Lab | experimental | Piper, Whisper.cpp, faster-whisper, Coqui TTS optional nur mit Python 3.9-3.11 |
| Asset_Library_Manager | planned | Meilisearch, DuckDB, rclone, restic, FFmpeg |
| Android_Network_Monitor | planned | ADB, mitmproxy optional, jadx, apktool, Tailscale |
| PiHole_Domain_Intelligence | optional | Pi-hole, AdGuard Home, dnsmasq, unbound, Uptime Kuma |
| Firewall_Rule_Assistant | optional | UFW, Fail2Ban, CrowdSec optional, port_check |
| Vulnerability_Report_Writer | planned | Trivy, Grype, Syft, Semgrep, Gitleaks, OSV optional |
| Backup_Disaster_Recovery_Auditor | optional | Restic, BorgBackup, rclone, Kopia optional, MinIO |
| MiniPC_Optimizer | stable-doc | resource_estimator, cleanup_installation_residues, Netdata |
| WSL2_Recovery_Doctor | stable-doc | doctor.sh, check_setup_updates.sh, cleanup, docker system df |
| GPU_Render_Node | experimental | ComfyUI, Blender, FFmpeg, Prometheus, Grafana |
| Kubernetes_Node_Planner | experimental | K3s, kubectl, Helm, Prometheus, Velero |
| Storage_Cleanup_Manager | stable-doc | cleanup_installation_residues, docker system df, du |
| Legal_Document_Checker | planned | Docling, Apache Tika, Stirling PDF, Qdrant |
| Contract_Risk_Reviewer | planned | Docling, Apache Tika, Paperless-ngx, Qdrant |
| Household_Admin_Assistant | planned | Paperless-ngx, Stirling PDF, Open WebUI, Qdrant |
| Finance_Budget_Tracker | planned | DuckDB, LibreOffice CLI, Pandoc, local LLM |
| Email_Response_Agent | planned | Open WebUI, msmtp optional, n8n optional, Paperless-ngx |


## Planned Profile Erweiterung 2026

| Profil | Status | Ressourcen | Zielgeraet | Tools |
|---|---|---|---|---|
| [Queue_Job_Manager](Profile/Queue_Job_Manager.md) | planned | medium | WSL2, Oracle VPS, Home Server | queue_manager, redis, n8n |
| [LLMOps_Control_Plane](Profile/LLMOps_Control_Plane.md) | planned | medium | Oracle VPS, Kubernetes | litellm, langfuse, openlit, prometheus |
| [Kubernetes_Hybrid_Master](Profile/Kubernetes_Hybrid_Master.md) | planned | heavy | Oracle VPS, Kubernetes, Home Server | k3s, helm, grafana |
| [Wake_On_LAN_Orchestrator](Profile/Wake_On_LAN_Orchestrator.md) | planned | light | Raspberry Pi, Home Server | wireguard, home_assistant |
| [Resource_Scheduler](Profile/Resource_Scheduler.md) | planned | medium | WSL2, GPU Workstation, Home Server | queue_manager, prometheus, node_exporter |
| [Cost_Control_Budget_Guard](Profile/Cost_Control_Budget_Guard.md) | planned | light | WSL2, Oracle VPS | litellm, openlit |
| [Supply_Chain_Security](Profile/Supply_Chain_Security.md) | planned | medium | WSL2, Oracle VPS | gitleaks, trivy, syft, grype, cosign, sops, age |
| [Disaster_Recovery_Backup](Profile/Disaster_Recovery_Backup.md) | planned | medium | Oracle VPS, Home Server | restic, borgbackup, kopia, rclone |
| [Update_Rollback_Manager](Profile/Update_Rollback_Manager.md) | planned | medium | WSL2, Oracle VPS | github_cli, gitleaks |
| [Codex_Local_Worker](Profile/Codex_Local_Worker.md) | planned | medium | WSL2, Home Server | openclaw, aider, opencode |
| [OpenClaw_Task_Queue](Profile/OpenClaw_Task_Queue.md) | planned | medium | Oracle VPS, Home Server | openclaw, queue_manager, n8n |
| [Agent_Evaluation_Lab](Profile/Agent_Evaluation_Lab.md) | planned | medium | WSL2, Home Server | promptfoo, deepeval, langfuse |
| [Prompt_Testing_Evals](Profile/Prompt_Testing_Evals.md) | planned | light | WSL2, Oracle VPS | promptfoo |
| [MCP_Server_Hub](Profile/MCP_Server_Hub.md) | planned | medium | WSL2, Oracle VPS | mcpo, openclaw |
| [Tool_Registry_Manager](Profile/Tool_Registry_Manager.md) | planned | light | WSL2 | github_cli |
| [Memory_Governance](Profile/Memory_Governance.md) | planned | medium | WSL2, Home Server | qdrant, chromadb, lightrag |
| [Persona_Governance](Profile/Persona_Governance.md) | planned | light | WSL2 | openclaw |
| [RAG_Document_Factory](Profile/RAG_Document_Factory.md) | planned | medium | WSL2, Home Server | docling, apache_tika, qdrant, llamaindex |
| [DDoS_Hardening_HE_DNS](Profile/DDoS_Hardening_HE_DNS.md) | planned | medium | Oracle VPS | crowdsec, fail2ban, ddclient_he, caddy |
| [Firewall_IDS_IPS](Profile/Firewall_IDS_IPS.md) | planned | medium | Oracle VPS, Home Server | ufw, crowdsec, suricata, wazuh |
| [Secrets_Vault](Profile/Secrets_Vault.md) | planned | medium | WSL2, Oracle VPS | sops, age, vaultwarden |
| [Zero_Trust_Admin_Access](Profile/Zero_Trust_Admin_Access.md) | planned | medium | Oracle VPS, Home Server | wireguard, tailscale, headscale |
| [Mail_Security_Gateway](Profile/Mail_Security_Gateway.md) | planned | medium | Oracle VPS | stalwart_mail, rspamd, opendkim, opendmarc |
| [Android_Security_Lab](Profile/Android_Security_Lab.md) | planned | medium | WSL2, Android | gitleaks, trivy |
| [Home_Network_Defense](Profile/Home_Network_Defense.md) | planned | medium | Raspberry Pi, Home Server | pihole, adguard_home, crowdsec |
| [AI_Content_Multiplier](Profile/AI_Content_Multiplier.md) | planned | light | WSL2, Home Server | ai_content_multiplier |
| [Suno_Prompt_Studio](Profile/Suno_Prompt_Studio.md) | planned | light | WSL2 | ffmpeg |
| [Video_Render_Queue](Profile/Video_Render_Queue.md) | planned | gpu-heavy | GPU Workstation | queue_manager, comfyui, ffmpeg, blender |
| [ComfyUI_Workflow_Manager](Profile/ComfyUI_Workflow_Manager.md) | planned | gpu-heavy | GPU Workstation | comfyui, queue_manager |
| [Asset_Library_Manager](Profile/Asset_Library_Manager.md) | planned | medium | Home Server | nextcloud, syncthing |
| [Voice_TTS_STT_Studio](Profile/Voice_TTS_STT_Studio.md) | planned | heavy | GPU Workstation, Home Server | whisper_cpp, faster_whisper, piper, coqui_tts |
| [Music_Mastering_AI](Profile/Music_Mastering_AI.md) | planned | heavy | GPU Workstation | ffmpeg, demucs |
| [Jarvis_Home_Command_Center](Profile/Jarvis_Home_Command_Center.md) | planned | medium | Home Server, Raspberry Pi | home_assistant, mosquitto, openclaw |
| [FritzBox_Mesh_Diagnostics](Profile/FritzBox_Mesh_Diagnostics.md) | planned | light | WSL2, Raspberry Pi | nmap |
| [Home_Assistant_Agent](Profile/Home_Assistant_Agent.md) | planned | medium | Home Server | home_assistant, openclaw |
| [Local_Voice_Assistant](Profile/Local_Voice_Assistant.md) | planned | medium | Raspberry Pi, Home Server | whisper_cpp, piper, home_assistant |
| [Email_Assistant](Profile/Email_Assistant.md) | planned | medium | Oracle VPS, WSL2 | stalwart_mail, openclaw |
| [Calendar_Task_Assistant](Profile/Calendar_Task_Assistant.md) | planned | light | WSL2, Home Server | radicale |
| [Repo_Auditor](Profile/Repo_Auditor.md) | planned | light | WSL2 | gitleaks, trivy, semgrep |
| [Issue_Triage_Agent](Profile/Issue_Triage_Agent.md) | planned | light | WSL2, Oracle VPS | github_cli, openclaw |
| [CI_CD_Builder](Profile/CI_CD_Builder.md) | planned | medium | WSL2, Oracle VPS | github_cli, act, shellcheck, shfmt |
| [WebApp_Builder](Profile/WebApp_Builder.md) | planned | medium | WSL2 | node_red, appsmith, budibase |
| [Docs_Automation_Agent](Profile/Docs_Automation_Agent.md) | planned | light | WSL2 | github_cli |
