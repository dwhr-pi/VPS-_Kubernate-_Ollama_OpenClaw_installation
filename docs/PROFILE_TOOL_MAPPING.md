# Profile Tool Mapping

## Next-Level Mapping

| Profil | Zweck | Tools | Risiko | Ressourcen | Status | Zielhost |
| --- | --- | --- | --- | --- | --- | --- |
| Job_Queue_Orchestrator | Jobs seriell/limitiert ausfuehren | job_queue, Redis/RQ optional | medium | low | planned | WSL2/MiniPC/VPS |
| Resource_Governor | RAM/CPU/Disk/GPU schuetzen | check_resource_budget | low | low | planned | alle |
| Secrets_Audit | Secrets finden ohne Werte auszugeben | gitleaks, trufflehog | medium | low | planned | alle |
| DDoS_Protection_HE_Oracle | HE/Oracle/Firewall absichern | CrowdSec, Fail2ban, UFW | high | medium | planned | Oracle VPS |
| K3s_HomeCluster_Manager | K3s Homecluster planen | k3s, helm, kubectl | high | heavy | planned | Home Server/K8s |
| Voice_Studio_Whisper_TTS | lokale STT/TTS | Piper, Whisper, Coqui optional | medium | medium | planned | MiniPC/GPU |

Hinweis: Diese Datei ist eine kompakte Uebersicht. Die maschinenlesbare Quelle bleibt `config/profiles.yml`.
