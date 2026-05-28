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
