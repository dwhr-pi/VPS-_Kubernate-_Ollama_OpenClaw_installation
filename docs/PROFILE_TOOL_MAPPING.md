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
| Voice_Transcription_Callcenter | recommended | planned | Whisper.cpp, faster-whisper, Piper, Coqui XTTS, FFmpeg |
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
