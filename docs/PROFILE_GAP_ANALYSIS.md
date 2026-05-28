# Profile Gap Analysis

Diese Analyse ordnet vorgeschlagene Profile nach Mehrwert und Installationsreife. Neue Profile sollen zuerst `planned` oder `documentation-first` sein, bis Installer, Checkscript, Ports und Ressourcenwerte vorhanden sind.

## Direkt sinnvoll

| Profil | Status | Begruendung |
|---|---|---|
| Backup_Disaster_Recovery | planned | Zentrales Restore-/Snapshot-Profil fehlt als klarer Einstieg. |
| Secrets_Key_Management | planned | Secrets, `.env`, age/gocryptfs/Vault/SOPS brauchen eigene Leitplanken. |
| Update_Patch_Manager | planned | Setup-, Tool- und OS-Updates brauchen Dry-Run, Rollback und Logik. |
| Service_Status_Control_Center | planned | Bietet eine Bedienoberflaeche fuer Doctor, Status und Logs. |
| MCP_Server_Hub | planned | MCP-Server werden zentraler Baustein fuer OpenClaw/Codex-Agenten. |
| Agent_Router_Orchestrator | planned | Ergaenzt Model Router um Agentenpfade und Tool-Gates. |
| Local_Model_Benchmark_Lab | planned | Modellwahl braucht reproduzierbare lokale Benchmarks. |
| Prompt_Evaluation_Lab | planned | promptfoo/deepeval/Regressionstests als Qualitaetsprofil. |
| Nextcloud_Knowledge_Hub | planned | Baut auf myNextCloud AI und RAG auf. |
| Workflow_Automation_Hub | planned | Klammer fuer n8n, Activepieces, Huginn, Node-RED, Windmill. |
| Blue_Team_Defense_Lab | planned | Defensive Security-Pipeline mit Human Approval. |
| Container_Security_Scanner | planned | Trivy/Grype/Syft fuer Images und SBOM. |
| Dependency_Vulnerability_Scanner | planned | OSV, npm audit, pip-audit, cargo audit, Trivy fs. |
| Tailscale_Private_Network | planned | Sicherer Admin-Zugriff ohne offene Ports. |
| Cloudflare_Access_Tunnel | planned | Oeffentlicher Zugriff mit Access/WAF/Rate-Limits. |

## Bereits abgedeckt oder ueberlappend

| Vorschlag | Bestehende Naehe | Empfehlung |
|---|---|---|
| Local_Search_Engine | existiert als documentation-first Profil | nicht doppelt aktivieren |
| ComfyUI_Workflow_Studio | existiert | pflegen, nicht duplizieren |
| Synthetic_Data_Generator | existiert wahrscheinlich als Profil/Tool | Registry-Sync pruefen |
| Document_Intelligence_OCR | Document_Intelligence/PDF_OCR_Document_Pipeline | als Alias oder Spezialprofil |
| Personal_Knowledge_Vault | Personal_Memory_Knowledge_OS/Knowledge_Librarian | Alias auf Hauptprofil |
| N8N_Agent_Automation | N8N_AI_Automation_Engineer/Workflow Hub | Spezialprofil optional |
| Voice_Assistant_Local_First | Voice_Command_Center/Voice_Assistant | Alias oder Nachfolger |

## Nur mit klaren Sicherheitsgrenzen

| Profil | Grenze |
|---|---|
| Android_App_Clone_Lab | nur eigene Apps oder explizit erlaubte Open-Source-Apps analysieren |
| OSINT_Research_Lab | nur legale Recherche, keine Umgehung, kein Doxxing |
| Network_Traffic_Analyzer | nur eigene Netze/Geraete, keine fremden Targets |
| PiHole_Adware_Malware_Check | defensive DNS-/Listenanalyse |
| Smart_Home_Security_Audit | keine automatischen Schaltaktionen ohne Freigabe |

## Profile-Mindeststandard

Jede neue Profil-Doku braucht:

- Zweck
- Zielgruppe
- Ressourcenbedarf
- empfohlene Tools
- optionale Tools
- Ports
- Sicherheitsnotizen
- Installationsbefehl
- Testbefehl
- Deinstallationshinweis
- bekannte Fehler
- Reparaturhinweise
