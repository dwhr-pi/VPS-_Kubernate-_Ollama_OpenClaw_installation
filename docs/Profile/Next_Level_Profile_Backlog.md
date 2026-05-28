# Next Level Profile Backlog

Dieser Backlog sammelt sinnvolle neue Profile, die noch nicht als stabile Installer aktiviert werden sollen. Status: `planned` oder `documentation-first`.

## Betrieb und Infrastruktur

| Profil | Ziel | Status |
|---|---|---|
| Backup_Disaster_Recovery | Restore, Snapshots, Backup-Berichte | planned |
| Secrets_Key_Management | `.env`, age/SOPS/Vault, Key-Policy | planned |
| Update_Patch_Manager | Setup-/Tool-/OS-Updates mit Rollback | planned |
| Service_Status_Control_Center | Doctor, Logs, Ports, Dienste | planned |
| Resource_Cost_Optimizer | Speicher, RAM, Kosten, Modellgroessen | planned |
| Multi_Node_Cluster_Manager | K3s/Kubernetes nur nach Baseline | experimental |
| Edge_Device_Manager | Raspberry Pi, Edge, Sensoren | planned |
| VPS_Hardening_Baseline | UFW, Fail2ban, SSH, Updates | planned |

## KI, Agenten und LLMOps

| Profil | Ziel | Status |
|---|---|---|
| MCP_Server_Hub | sichere MCP-Server zentral verwalten | planned |
| Agent_Router_Orchestrator | Agentenrouting mit Human Approval | planned |
| Local_Model_Benchmark_Lab | lokale Modellbenchmarks | planned |
| Prompt_Evaluation_Lab | Prompt-Regression und promptfoo/deepeval | planned |
| Synthetic_Data_Generator | synthetische Daten mit Datenschutzregeln | planned |
| Fine_Tuning_LoRA_Lab | LoRA/Fine-Tuning nur mit Lizenzcheck | experimental |
| Dataset_Curation_Studio | Daten kuratieren, deduplizieren, labeln | planned |
| Model_Context_Protocol_Tools | MCP-Tools fuer Agenten | planned |
| AI_Audit_Log_Inspector | Agentenlogs und Toolentscheidungen pruefen | planned |

## RAG, Wissen und Dokumente

| Profil | Ziel | Status |
|---|---|---|
| Document_Intelligence_OCR | OCR, Tika, Docling, Tabellen | planned |
| Personal_Knowledge_Vault | lokales Wissensarchiv | planned |
| Nextcloud_Knowledge_Hub | myNextCloud plus RAG/Tags/Summaries | planned |
| Local_Search_Engine | existiert/weiter pflegen | planned |
| PDF_Table_Extractor | PDF-Tabellen und strukturierte Exporte | planned |
| Research_Assistant_Deep_Search | Deep Research mit Quellenpflicht | planned |

## Automation

| Profil | Ziel | Status |
|---|---|---|
| Workflow_Automation_Hub | n8n, Activepieces, Huginn, Node-RED | planned |
| N8N_Agent_Automation | n8n mit Agenten-Gates | planned |
| Home_Assistant_Automation_Lab | Smart Home Automationen mit Freigabe | planned |
| Email_Notification_Center | Mail, Healthchecks, Alerts | planned |
| Webhook_API_Gateway | Signaturen, Rate-Limits, Webhook-Docs | planned |

## Security

Alle Security-Profile sind defensiv, legal und nur fuer eigene oder explizit autorisierte Systeme gedacht.

| Profil | Ziel | Status |
|---|---|---|
| Blue_Team_Defense_Lab | defensive Detection und Reports | planned |
| OSINT_Research_Lab | legale Recherche, keine Umgehung | planned |
| Network_Traffic_Analyzer | eigenes Netz analysieren | planned |
| PiHole_Adware_Malware_Check | DNS-/Blocklisten pruefen | planned |
| Container_Security_Scanner | Trivy/Grype/Syft | planned |
| Dependency_Vulnerability_Scanner | Abhaengigkeiten pruefen | planned |
| Log_Threat_Detection | Logs auswerten und priorisieren | planned |

## Medien, Android, Smart Home und Netzwerk

| Profil | Ziel | Status |
|---|---|---|
| Stable_Diffusion_Image_Lab | SD/Forge/InvokeAI mit GPU-Hinweis | experimental |
| AI_Video_Pipeline | Video-KI mit Speicherwarnung | experimental |
| Suno_Music_Prompt_Studio | Musikprompts und Rechtehinweise | planned |
| Blender_Automation_Studio | Blender lokal/GPU optional | planned |
| Unreal_Unity_AI_Bridge | Game-Engine Integration | planned |
| Asset_Generation_Factory | Assets, Metadaten, Lizenzen | planned |
| Android_Firewall_Builder | eigene Android-Tests | planned |
| Android_App_Clone_Lab | nur eigene/erlaubte OSS-Apps | planned |
| MicroG_Compatibility_Lab | Kompatibilitaet und Datenschutz | planned |
| MyBox_Container_App | Android Container-App Konzept | planned |
| Mobile_Remote_Control_Client | OpenClaw/Ollama Companion | planned |
| APK_Build_Signing_Release | Build, Signing, Release-Checklisten | planned |
| FritzBox_Mesh_Optimizer | Heimnetzdiagnose | planned |
| Tailscale_Private_Network | privater Adminzugriff | planned |
| Cloudflare_Access_Tunnel | oeffentlicher Zugriff mit Access | planned |
| Voice_Assistant_Local_First | lokale Sprache/STT/TTS | planned |
| Smart_Home_Security_Audit | Smart Home defensiv pruefen | planned |

## Aktivierungsregel

Ein Backlog-Profil wird erst Menuepunkt, wenn Doku, Registry-Eintrag, Toolmapping, Ressourcenwerte, Portdoku, Installer, Uninstaller, Doctor und Statuscheck vorhanden sind.
