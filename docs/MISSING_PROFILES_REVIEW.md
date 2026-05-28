# Missing Profiles Review

Stand: 2026-05-28

## Ergaenzte Dokumentationsprofile

Die neu ergaenzten Profile sind bewusst documentation-first und werden nicht automatisch als schwere Installationsprofile aktiviert.

| Gruppe | Profile |
|---|---|
| LLMOps | `LLMOps_Control_Center`, `Local_Model_Lifecycle_Manager`, `Model_Downloader_Quantizer`, `Prompt_Testing_Benchmark_Lab`, `Agent_Safety_Policy_Manager`, `Multi_Agent_Router` |
| Automatisierung | `N8N_AI_Automation_Engineer`, `Home_Assistant_Agent_Builder`, `Webhook_API_Integrator`, `Personal_Command_Center`, `Notification_Router` |
| Wissen/RAG | `PDF_OCR_Document_Pipeline`, `Local_Search_Engine`, `Knowledge_Graph_Researcher`, `Personal_Wiki_Agent`, `Long_Term_Memory_Curator` |
| Medien | `AI_Video_Pipeline_Manager`, `ComfyUI_Workflow_Studio`, `Music_Prompt_Producer`, `Voice_Clone_TTS_Lab`, `Asset_Library_Manager` |
| Security/Netzwerk | `Android_Network_Monitor`, `PiHole_Domain_Intelligence`, `Firewall_Rule_Assistant`, `Vulnerability_Report_Writer`, `Backup_Disaster_Recovery_Auditor` |
| Hardware/Homelab | `MiniPC_Optimizer`, `WSL2_Recovery_Doctor`, `GPU_Render_Node`, `Kubernetes_Node_Planner`, `Storage_Cleanup_Manager` |
| Alltag/Recht | `Legal_Document_Checker`, `Contract_Risk_Reviewer`, `Household_Admin_Assistant`, `Finance_Budget_Tracker`, `Email_Response_Agent` |

## Ueberlappungen

- `Voice_Clone_TTS_Lab` ergaenzt `Voice_Clone_TTS_Studio`, fokussiert aber staerker Rechte, Einwilligung und Tests.
- `ComfyUI_Workflow_Studio` ergaenzt `Image_Generation_Studio` und `Video_Generation_ComfyUI_Wan`, ohne neue Modelle automatisch zu installieren.
- `Storage_Cleanup_Manager` ergaenzt die Installationsueberwachung und ist ein Sicherheitsprofil fuer Bereinigung.

## Nicht als eigene Installation aktivieren

Viele neue Profile sind Dachprofile. Sie sollen erst dann im Setup-Menue als installierbar erscheinen, wenn Installer, Checks, Speicherwerte und Sicherheitsgates vorhanden sind.
