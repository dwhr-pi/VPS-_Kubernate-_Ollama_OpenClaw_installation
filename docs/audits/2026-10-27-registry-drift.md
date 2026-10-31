# Registry-/Menue-Abgleich vom 27.10.2026

Statischer Abgleich des lokalen Codes, kein Start des Setups und kein Installationsnachweis.
Grundlage: config/tools.yml, config/profiles.yml, config/ports.yml, setup_ultimate.sh und
scripts/helpers/native_github_menu.sh. Native Registrierungen am Hauptschleifenbeginn werden
beruecksichtigt. Tool-Zuordnung: normalisierte ID/Name oder identischer Installer-Pfad.
Profil-Zuordnung: normalisierte IDs; fachliche Aliasnamen bleiben manuell zu pruefen.

Registry-only ist nicht automatisch ein Fehler: einige Eintraege sind Projektbausteine, optionale
Quellen oder ueber andere Menues erreichbar. Menue-only bedeutet hier fehlende eindeutige
Registry-Zuordnung, nicht fehlender Installer. Weitere dynamische Shell-Logik wird nicht
ausgefuehrt. Portlisten beschreiben Deklarationen, keine geoeffneten Ports.

## Zahlen

| Messwert                                   | Anzahl |
| ------------------------------------------ | ------ |
| tools_registry                             | 389    |
| tools_menu_literal                         | 325    |
| tools_menu_including_native                | 344    |
| tools_registry_without_menu                | 142    |
| tools_menu_without_registry                | 97     |
| profiles_registry                          | 245    |
| profiles_menu                              | 57     |
| profiles_registry_without_literal_menu     | 206    |
| profiles_menu_without_equal_registry_id    | 19     |
| ports_registry                             | 44     |
| tool_port_references_outside_port_registry | 17     |

## Tools: Registry ohne Tools-Menue-Zuordnung

| Kennung                        |
| ------------------------------ |
| `lightrag`                     |
| `ufw`                          |
| `tailscale`                    |
| `cloudflared`                  |
| `esphome`                      |
| `borgbackup`                   |
| `clamav`                       |
| `yara`                         |
| `haystack`                     |
| `pytest`                       |
| `deepeval`                     |
| `pihole`                       |
| `adguard_home`                 |
| `trafilatura`                  |
| `reuse`                        |
| `scancode_toolkit`             |
| `gbox`                         |
| `stalwart_mail`                |
| `queue_manager`                |
| `tasktiger`                    |
| `rq`                           |
| `celery`                       |
| `dramatiq`                     |
| `bullmq`                       |
| `temporal`                     |
| `argo_workflows`               |
| `swe_agent`                    |
| `cosign`                       |
| `sops`                         |
| `age`                          |
| `vaultwarden`                  |
| `suricata`                     |
| `wazuh`                        |
| `headscale`                    |
| `headplane`                    |
| `wireguard`                    |
| `frp`                          |
| `nginx_proxy_manager`          |
| `ddclient_he`                  |
| `acme_sh`                      |
| `rspamd`                       |
| `roundcube`                    |
| `snappymail`                   |
| `mailpit`                      |
| `opendkim`                     |
| `opendmarc`                    |
| `kopia`                        |
| `supabase_self_hosted`         |
| `duplicati`                    |
| `automatic1111`                |
| `krita_ai_diffusion`           |
| `job_queue`                    |
| `modelcontextprotocol_servers` |
| `mcp_filesystem`               |
| `mcp_git`                      |
| `mcp_github`                   |
| `mcp_shell`                    |
| `mcp_browser`                  |
| `mcp_sqlite`                   |
| `mcp_postgres`                 |
| `mcp_fetch`                    |
| `mcp_memory`                   |
| `supervisord`                  |
| `systemd_user_units`           |
| `tmux`                         |
| `pm2`                          |
| `lynis`                        |
| `openscap`                     |
| `mcp_filesystem_server`        |
| `mcp_git_server`               |
| `mcp_github_server`            |
| `mcp_shell_server`             |
| `mcp_browser_server`           |
| `mcp_sqlite_server`            |
| `mcp_postgres_server`          |
| `mcp_fetch_server`             |
| `mcp_memory_server`            |
| `styletts2`                    |
| `openvoice`                    |
| `seed_vc`                      |
| `diffsinger`                   |
| `openutau`                     |
| `nnsvs`                        |
| `fish_speech`                  |
| `melotts`                      |
| `kokoro_tts`                   |
| `spark_tts`                    |
| `hallo2`                       |
| `emo_avatar`                   |
| `skyreels_a1`                  |
| `wav2lip`                      |
| `clearer_voice_studio`         |
| `subtitleedit`                 |
| `openbao`                      |
| `infisical`                    |
| `glances`                      |
| `blocky`                       |
| `localai`                      |
| `browsermcp`                   |
| `docker_mcp_registry`          |
| `pass`                         |
| `litestream`                   |
| `fastlane`                     |
| `apktool`                      |
| `mitmproxy`                    |
| `radicale`                     |
| `imap_importer`                |
| `git`                          |
| `doctor`                       |
| `wsl2`                         |
| `voice_studio`                 |
| `podcast_studio`               |
| `audiobook_studio`             |
| `dubbing_studio`               |
| `prompt_generator_studio`      |
| `video_ai_production`          |
| `character_library`            |
| `voice_clone`                  |
| `ai_choir`                     |
| `android_sdk`                  |
| `gradle`                       |
| `jadx`                         |
| `arq`                          |
| `apscheduler`                  |
| `renovate`                     |
| `check_resource_budget`        |
| `mkdocs`                       |
| `firejail`                     |
| `wakeonlan`                    |
| `nvidia_smi`                   |
| `ddclient`                     |
| `check_tools`                  |
| `check_profiles`               |
| `check_ports`                  |
| `paddleocr`                    |
| `livekit`                      |
| `asterisk`                     |
| `beszel`                       |
| `zeek`                         |
| `falco`                        |
| `stalwart`                     |
| `sieve`                        |

## Tools: Menue ohne Registry-Zuordnung

| Kennung                   |
| ------------------------- |
| `Actionlint`              |
| `Agent_Router`            |
| `Ahrefs`                  |
| `AI_Powered_Law_Firms`    |
| `Airtable`                |
| `AnimateDiff`             |
| `Axolotl`                 |
| `Backtest_Workflow`       |
| `BPM_Analyzer`            |
| `Browser_Tool`            |
| `Buffer_API`              |
| `Clawbake`                |
| `Clawhub`                 |
| `Clawhub_CLI`             |
| `Code_Sandbox`            |
| `ControlNet`              |
| `Data_Juicer`             |
| `Deadline_Checker`        |
| `Docker_Compose_Plugin`   |
| `Drafting_Agent`          |
| `ElevenLabs`              |
| `Emotion_Tagging`         |
| `EnviroLLM`               |
| `Ethers_JS`               |
| `EULLM`                   |
| `Exchange_APIs`           |
| `Fail2Ban_Analyzer`       |
| `File_System_Tool`        |
| `FinGPT`                  |
| `Fooocus`                 |
| `Foundry`                 |
| `GitHub_API_Tooling`      |
| `GitHub_Research`         |
| `Google_Analytics_API`    |
| `Hadolint`                |
| `Hardhat`                 |
| `Hook_Detection`          |
| `HubSpot`                 |
| `Huge_Facing`             |
| `Image_Upscaler_Pipeline` |
| `Joplin_CLI`              |
| `Kimi2`                   |
| `Kubectx_Kubens`          |
| `Kubernetes`              |
| `Lawfirm`                 |
| `LibreOffice_Headless`    |
| `librosa`                 |
| `Llama_CPP_Toolchain`     |
| `LLaMA_Factory`           |
| `Make`                    |
| `Memory_Policies`         |
| `Meta_Ads_API`            |
| `MLflow`                  |
| `Music2P_Pipeline`        |
| `NATS`                    |
| `Nikto`                   |
| `Notion`                  |
| `OPA`                     |
| `OpenClaw_RL`             |
| `OpenManus`               |
| `PDF_Parser`              |
| `Pgvector`                |
| `Pipedream`               |
| `pydub`                   |
| `Ray`                     |
| `Repo_Comparison`         |
| `Riffusion`               |
| `Risk_Agent`              |
| `Risk_Scoring`            |
| `Risk_Strategy_Analyzer`  |
| `Runway_API`              |
| `Security_Workflow`       |
| `SEMrush`                 |
| `SQLite`                  |
| `SQLite_Vec`              |
| `Stable_Diffusion_WebUI`  |
| `Suno_API`                |
| `SVD`                     |
| `Tax_Calculator`          |
| `Tax_Law_Agent`           |
| `Thumbnail_Pipeline`      |
| `TikTok_Ads_API`          |
| `TikTok_Score`            |
| `Trend_Monitor`           |
| `Udio_API`                |
| `Unsloth`                 |
| `Upload_Automation`       |
| `Voice_Assistant_Runtime` |
| `VS_Code_Server`          |
| `Web3_APIs`               |
| `Web3_Py`                 |
| `Weights_and_Biases`      |
| `Whisper`                 |
| `YT_DLP`                  |
| `Zapier`                  |
| `Zenbot_API`              |
| `Zenbot_trader`           |

## Profile: Registry ohne gleichnamigen Profile-Menueeintrag

| Kennung                             |
| ----------------------------------- |
| `Agentic_Coding_Local_First`        |
| `Personalakten_Local_First`         |
| `Embedded_Debug_HIL`                |
| `AI_Project_Manager`                |
| `Prompt_Engineering_Studio`         |
| `AI_Agent_Evaluation`               |
| `Model_Router_Gateway`              |
| `RAG_Wissensdatenbank`              |
| `OSINT_Research`                    |
| `Data_Analytics_BI`                 |
| `Synthetic_Data_Lab`                |
| `NoCode_LowCode_AI`                 |
| `Browser_Automation_Agent`          |
| `Local_AI_App_Builder`              |
| `Office_Productivity`               |
| `Email_Office_Automation`           |
| `Image_Generation_Studio`           |
| `Video_Generation_Studio`           |
| `Voice_Clone_TTS_Studio`            |
| `Music_AI_Studio`                   |
| `Smart_Home_AI_Assistant`           |
| `Robotics_IoT_Edge_AI`              |
| `Smart_Home_Automation`             |
| `Document_Intelligence`             |
| `Personal_Knowledge_Memory`         |
| `Game_Dev_AI`                       |
| `CAD_Konstrukteur`                  |
| `Robotertechnik_Anlagensteuerung`   |
| `Architektur_3D_BIM`                |
| `Education_Tutor`                   |
| `Developer_CI_CD`                   |
| `MCP_Agent_Tools`                   |
| `Monitoring_Observability`          |
| `Backup_Recovery`                   |
| `DevOps_SRE_Agent`                  |
| `Security_DevSecOps`                |
| `AI_Governance_Audit`               |
| `Cost_Energy_Optimizer`             |
| `Prompt_Generator_Studio`           |
| `Self_Learning_Agent_Lab`           |
| `Home_Network_Security`             |
| `Android_App_Builder`               |
| `AI_Dashboard_Builder`              |
| `Render_Farm_GPU_Workstation`       |
| `Legal_Safe_Creator`                |
| `Cyber_Security_AI`                 |
| `Anti_Virus`                        |
| `Boardroom`                         |
| `Web3_Crypto_Agent`                 |
| `Local_AI_Office_Suite`             |
| `Android_AI_App_Lab`                |
| `Privacy_First_Cloud_Sync`          |
| `Personal_Memory_Knowledge_OS`      |
| `AI_Testing_QA_Lab`                 |
| `Model_Router_Cost_Control`         |
| `Voice_Transcription_Callcenter`    |
| `Network_HomeLab_ZeroTrust`         |
| `Data_Scraping_Browser_Agents`      |
| `Legal_Compliance_Safety_Review`    |
| `Queue_Job_Manager`                 |
| `LLMOps_Control_Plane`              |
| `Kubernetes_Hybrid_Master`          |
| `Wake_On_LAN_Orchestrator`          |
| `Resource_Scheduler`                |
| `Cost_Control_Budget_Guard`         |
| `Supply_Chain_Security`             |
| `Disaster_Recovery_Backup`          |
| `Update_Rollback_Manager`           |
| `Codex_Local_Worker`                |
| `OpenClaw_Task_Queue`               |
| `Agent_Evaluation_Lab`              |
| `Prompt_Testing_Evals`              |
| `MCP_Server_Hub`                    |
| `Tool_Registry_Manager`             |
| `Memory_Governance`                 |
| `Persona_Governance`                |
| `RAG_Document_Factory`              |
| `DDoS_Hardening_HE_DNS`             |
| `Firewall_IDS_IPS`                  |
| `Secrets_Vault`                     |
| `Zero_Trust_Admin_Access`           |
| `Mail_Security_Gateway`             |
| `Android_Security_Lab`              |
| `Home_Network_Defense`              |
| `AI_Content_Multiplier`             |
| `Suno_Prompt_Studio`                |
| `Video_Render_Queue`                |
| `ComfyUI_Workflow_Manager`          |
| `Asset_Library_Manager`             |
| `Voice_TTS_STT_Studio`              |
| `Music_Mastering_AI`                |
| `Jarvis_Home_Command_Center`        |
| `FritzBox_Mesh_Diagnostics`         |
| `Home_Assistant_Agent`              |
| `Local_Voice_Assistant`             |
| `Email_Assistant`                   |
| `Calendar_Task_Assistant`           |
| `Repo_Auditor`                      |
| `Issue_Triage_Agent`                |
| `CI_CD_Builder`                     |
| `Docs_Automation_Agent`             |
| `Job_Queue_Manager`                 |
| `Agent_Supervisor`                  |
| `Self_Healing_Maintenance`          |
| `Cost_And_Quota_Manager`            |
| `Setup_Doctor`                      |
| `DNS_DDoS_Hardening`                |
| `Network_Security_Gateway`          |
| `Secrets_And_Supply_Chain_Security` |
| `Forensic_Log_Analyzer`             |
| `Privacy_Local_First`               |
| `Mailserver_AI_Assistant`           |
| `Email_Automation_Agent`            |
| `Calendar_Contact_Agent`            |
| `Codex_Queue_Worker`                |
| `Repo_Audit_Agent`                  |
| `Windows_WSL_Troubleshooter`        |
| `Kubernetes_Node_Manager`           |
| `Knowledge_Graph_RAG`               |
| `Personal_Data_Vault`               |
| `Image_Video_Render_Farm`           |
| `Music_Prompt_Producer`             |
| `Voice_Dubbing_Local`               |
| `Home_Assistant_Bridge`             |
| `IoT_Device_Manager`                |
| `Alexa_Local_Bridge`                |
| `Voice_Studio`                      |
| `AI_Singer`                         |
| `AI_Choir`                          |
| `Voice_Clone`                       |
| `Podcast_Studio`                    |
| `Audiobook_Studio`                  |
| `Dubbing_Studio`                    |
| `Voice_Laboratory`                  |
| `AI_Actor`                          |
| `AI_Actress`                        |
| `AI_News_Anchor`                    |
| `AI_Moderator`                      |
| `AI_Podcast_Host`                   |
| `AI_Radio_Host`                     |
| `AI_Documentary_Narrator`           |
| `AI_Audiobook_Narrator`             |
| `AI_Dubbing_Artist`                 |
| `AI_Comedian`                       |
| `AI_Sports_Commentator`             |
| `AI_Interviewer`                    |
| `AI_Influencer`                     |
| `AI_Virtual_Human`                  |
| `AI_Film_Director`                  |
| `AI_Casting_Director`               |
| `AI_Voice_Director`                 |
| `Queue_Worker_Orchestrator`         |
| `MCP_Server_Gateway`                |
| `Secrets_Vault_Local_First`         |
| `Observability_AI_Control_Tower`    |
| `RAG_Document_Intelligence`         |
| `Backup_Disaster_Recovery`          |
| `Network_DNS_DDoS_Hardening`        |
| `Mail_AI_Operations`                |
| `Android_AI_Lab`                    |
| `Job_Queue_Orchestrator`            |
| `Resource_Governor`                 |
| `Backup_Restore_Manager`            |
| `Disaster_Recovery`                 |
| `Offline_First_Documentation`       |
| `Update_And_Migration_Manager`      |
| `Config_Policy_Manager`             |
| `RAG_Quality_Auditor`               |
| `Prompt_Testing_Lab`                |
| `Multi_Agent_Scheduler`             |
| `Local_Memory_Governance`           |
| `Dataset_Curator`                   |
| `Secrets_Audit`                     |
| `Vulnerability_Scanner`             |
| `DDoS_Protection_HE_Oracle`         |
| `Safe_Agent_Sandbox`                |
| `K3s_HomeCluster_Manager`           |
| `Wake_On_LAN_Controller`            |
| `GPU_Workload_Scheduler`            |
| `Storage_Backup_NAS`                |
| `Reverse_Proxy_Gateway`             |
| `DNS_DDNS_Hurricane_Electric`       |
| `Monitoring_Alerting_NOC`           |
| `Music_Production_Studio`           |
| `Video_Pipeline_Manager`            |
| `Image_Model_Manager`               |
| `ComfyUI_Workflow_Library`          |
| `Voice_Studio_Whisper_TTS`          |
| `Android_Remote_Control`            |
| `APK_Build_Test_Lab`                |
| `Mobile_Device_Firewall`            |
| `myBOX_Android_Container`           |
| `MicroG_Compatibility_Lab`          |
| `Codex_Task_Queue`                  |
| `Project_Roadmap_Manager`           |
| `Decision_Log_Boardroom`            |
| `Install_Test_Matrix`               |
| `Beginner_Wizard_Profile`           |
| `AI_Model_Router_Gateway`           |
| `Voice_AI_Callcenter`               |
| `Email_AI_Office`                   |
| `Observability_Control_Tower`       |
| `Security_BlueTeam_SOC`             |
| `Network_DDNS_ZeroTrust`            |
| `Media_Music_Video_Studio`          |
| `Ultimate_JARVIS`                   |

## Profile: Menue ohne gleichnamige Registry-ID

| Kennung                      |
| ---------------------------- |
| `Repo_Maintainer`            |
| `Agent_Orchestrator`         |
| `Research_Agent`             |
| `KI_Forschung`               |
| `Document_AI`                |
| `Personal_Knowledge_OS`      |
| `Texter_Werbung_Marketing`   |
| `Rechtsberatung_Steuerrecht` |
| `DevOps_SRE`                 |
| `Security_Analyst`           |
| `Compliance_Privacy`         |
| `Audio`                      |
| `Media_Musik`                |
| `Content_Automation`         |
| `Image_Generation`           |
| `Video_Generation`           |
| `Visual_Creator`             |
| `Trading_AI`                 |
| `Web3_Crypto_Tools`          |

## Tool-Ports ohne Eintrag in ports.yml

Keine Aussage ueber Listener oder Erreichbarkeit.

| Tool-ID         | Deklarierter Port |
| --------------- | ----------------- |
| `searxng`       | 8888              |
| `node_exporter` | 9100              |
| `cadvisor`      | 8088              |
| `redis`         | 6379              |
| `syncthing`     | 8384              |
| `syncthing`     | 22000             |
| `syncthing`     | 21027             |
| `pihole`        | 53                |
| `pihole`        | 80                |
| `adguard_home`  | 53                |
| `stalwart_mail` | 25                |
| `stalwart_mail` | 465               |
| `stalwart_mail` | 587               |
| `stalwart_mail` | 993               |
| `stalwart_mail` | 995               |
| `stalwart_mail` | 443               |
| `stalwart_mail` | 4190              |
