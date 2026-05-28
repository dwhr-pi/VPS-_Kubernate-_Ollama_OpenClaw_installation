# Setup Audit

Stand: 2026-05-28.

## Was ist bereits gut?

- Das Repository ist bereits modular aufgebaut: Profile, Tools, Scripts, Docs, Security-Checks und Installationslogs sind getrennt.
- Lokale Userdaten werden zunehmend nach `~/.openclaw_ultimate_user_data` ausgelagert.
- Schwere Tools werden als experimentell/heavy erkannt und brauchen zunehmend Opt-in.
- WSL2-, VPS-, GPU- und Kubernetes-Pfade sind dokumentiert oder als planned gekennzeichnet.
- Doctor-, Check- und Dry-Run-Skripte existieren und werden schrittweise robuster.

## Was fehlt?

- Vollstaendige Lifecycle-Abdeckung pro Tool: `check`, `install`, `update`, `uninstall`, `doctor`, `status`.
- Maschinenlesbare Ressourcenwerte fuer alle Tools/Profile.
- Einheitliche Profilstruktur in allen alten und neuen Profilen.
- Port-/Secret-Hinweise in allen Tool-Eintraegen.
- Schnelle Menue-Preview fuer Minimal-/Vollsetup ohne lange Live-Berechnung.

## Was ist riskant?

- Schwere Source-/Docker-/Kubernetes-Installationen unter WSL2 mit wenig Windows-C:-Speicher.
- `0.0.0.0` in historischen Templates, Reports oder Beispiel-Dateien.
- Cloud-/API-Key-Pfade ohne klare Kostenwarnung.
- Docker Socket, Kubernetes, Browser-Agenten, Smart Home und Security-Profile ohne Human Approval.

## Was ist unklar?

- Welche Tools in der lokalen Umgebung wirklich installiert sind, wenn Installationen abgebrochen wurden.
- Welche Profile produktiv genutzt werden und welche nur Dokumentation/Backlog sind.
- Ob alle Upstream-Forks sauber ableitbar und aktuell sind.

## Tools/Profile ergaenzen

- Profile: Bild/Video, DevOps/Kubernetes, Security/Privacy, Home Assistant, n8n, Local Memory, Android, Business Office, Legal Checker, System Doctor.
- Tools: LocalAI, AnythingLLM, RAGFlow, Haystack, SOPS/age, OpenTelemetry Collector, Tempo, Backstage, MkDocs, Filebrowser, Windmill.

## Prioritaeten

- P0: Secrets, Ports, Backup, WSL2-Speicher, schwere Tools blockieren.
- P1: Tool-Lifecycle, Profile-Standard, Registry-Sync, Doctor/Preflight.
- P2: Developer Portal, Kubernetes-Vorlagen, optionale Tool-Installer, UI-Verbesserungen.
