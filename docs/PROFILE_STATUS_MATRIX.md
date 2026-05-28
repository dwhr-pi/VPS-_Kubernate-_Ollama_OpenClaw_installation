# Profile Status Matrix

| Status | Bedeutung | Darf automatisch installiert werden? |
|---|---|---|
| stable | Wiederholt sinnvoll getestet oder sehr leichtgewichtig | Ja, wenn vom Nutzer gewaehlt |
| optional | Sinnvoll, aber nicht fuer jeden Zielpfad | Nur nach Auswahl |
| planned | Dokumentiert, Installer/Checks noch nicht voll belastbar | Nein |
| experimental | Hoher Ressourcenbedarf oder schnell wechselnder Upstream | Nein, nur mit Warnung |
| gpu-only | Lokale GPU/VRAM noetig | Nein, wenn keine GPU erkannt |
| vps-only | Serverpfad, Remote-/Firewall-Wissen noetig | Nein auf WSL2/MiniPC |

## Status der neuen Profile

| Profil | Status | Risiko |
|---|---|---|
| LLMOps_Control_Center | planned | Prompt-/Trace-Daten |
| Local_Model_Lifecycle_Manager | planned | Speicherverbrauch |
| Model_Downloader_Quantizer | experimental | Lizenz/Modellquellen |
| Prompt_Testing_Benchmark_Lab | planned | Eval-Daten |
| Agent_Safety_Policy_Manager | planned | Policy-Umgehung vermeiden |
| Multi_Agent_Router | experimental | Tool-Ketten |
| N8N_AI_Automation_Engineer | optional | Credentials/Webhooks |
| Home_Assistant_Agent_Builder | optional | reale Hausaktionen |
| PDF_OCR_Document_Pipeline | optional | private Dokumente |
| AI_Video_Pipeline_Manager | experimental/gpu-only | VRAM/Rechte |
| MiniPC_Optimizer | stable-doc | Cleanup nur mit Freigabe |
| WSL2_Recovery_Doctor | stable-doc | keine destruktive Reparatur |
| GPU_Render_Node | experimental/gpu-only | Strom/VRAM/Modelle |
| Kubernetes_Node_Planner | experimental | Cluster/Secrets |
| Storage_Cleanup_Manager | stable-doc | keine Volumes automatisch loeschen |
