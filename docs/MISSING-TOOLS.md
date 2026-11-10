# Offene Betriebsfaehigkeiten statt neuer Pflicht-Tools

| Bereich | Befund | Naechster Schritt / Aufwand | Risiko ohne Nachweis |
| --- | --- | --- | --- |
| Inferenz | LiteLLM/Ollama vorhanden, Failover und Modell-Evals unvollstaendig | Kleine lokale Prompt-Regression nach Updates / M | Fehler erst im Agentenworkflow sichtbar |
| Memory | Qdrant vorhanden, Restore nicht abgenommen | Ingestion und Reindex am separaten Ziel testen / M | Verlorener oder inkonsistenter Index |
| Agenten/MCP | Adapter vorhanden, Least-Privilege je Einsatz offen | Rechte, Auth, Timeout und externe Aufrufe dokumentieren / M | Ungewollter Datenabfluss oder Side Effects |
| Secrets und Backup | SOPS, Gitleaks, Trivy und Restore-Fixtures vorhanden | Schluesselrotation und isolierte Restore-Abnahme / M | Nicht wiederherstellbarer Zustand |
| Observability | Monitoring-lite und Langfuse-Einstiege vorhanden | Latenz, Disk, GPU und Alarmzustellung je Ziel pruefen / M | Ausfaelle oder Kosten bleiben unbemerkt |
| Edge | WireGuard und WoL vorhanden; Host-Tuning nicht als Default noetig | Pi-Hardware und Bedarf an ZRAM/cgroups zuerst messen / S | Unnoetige oder nicht reproduzierbare Host-Eingriffe |
| Runtime-CI | Lint und Offline-Fixtures vorhanden | Getrennte VPS-/Pi-/RTX-/WSL-Abnahme / L | Scheinsicherheit aus statischen Checks |

Keine zusaetzlichen Pflichtdienste, kein Docker-/Compose-Installationsweg
und kein automatischer Host-Tuning- oder Cluster-Sync-Schritt.
