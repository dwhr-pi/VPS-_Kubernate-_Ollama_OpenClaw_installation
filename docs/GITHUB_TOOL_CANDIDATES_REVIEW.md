# GitHub Tool Candidates Review

Stand: 2026-05-28. Keine blinde Aufnahme als Auto-Installer; erst Review, Healthcheck und Rollback.

| Tool | GitHub-URL | Zweck | Profile | Risiko | Default | Healthcheck | Deinstallation | WSL2-Hinweis |
|---|---|---|---|---|---|---|---|---|
| promptfoo | https://github.com/promptfoo/promptfoo | Prompt-/LLM-Tests | AI_Testing_QA_Lab | low | installierbar | `promptfoo --version` | npm/pnpm global oder `/opt/promptfoo` entfernen | kleine Testdaten nutzen |
| Aider | https://github.com/Aider-AI/aider | Coding-Agent CLI | Programmierer | medium | installierbar | `aider --version` | venv/pipx entfernen | Git-Status sauber halten |
| LlamaIndex | https://github.com/run-llama/llama_index | RAG Framework | Personal_Memory_Knowledge_OS | medium | installierbar | `python3 -c 'import llama_index'` | venv entfernen | Dokumente lokal halten |
| Paperless-ngx | https://github.com/paperless-ngx/paperless-ngx | Dokumentenarchiv | Local_AI_Office_Suite | medium | installierbar | Port/Containerstatus | Compose/Container und Daten bewusst entfernen | Speicher fuer OCR einplanen |
| Stirling PDF | https://github.com/Stirling-Tools/Stirling-PDF | lokale PDF-Tools | Local_AI_Office_Suite | medium | installierbar | Port 8081 | Container/opt-Pfad entfernen | nicht offen betreiben |
| Syncthing | https://github.com/syncthing/syncthing | Dateisync | Privacy_First_Cloud_Sync | medium | installierbar | `syncthing --version` | Dienst/Pfad entfernen | GUI nicht oeffentlich |
| Rclone | https://github.com/rclone/rclone | Cloud-/Remote-Sync | Backup_Recovery | low | installierbar | `rclone version` | Binary/Config bewusst entfernen | Cloud-Keys schuetzen |
| Uptime Kuma | https://github.com/louislam/uptime-kuma | Uptime-Monitoring | Monitoring | medium | installierbar | Port 3004 | Container/Pfad entfernen | lokal/Tailnet |
| Netdata | https://github.com/netdata/netdata | Host-Monitoring | MiniPC_Optimizer | medium | installierbar | Port 19999 | Service entfernen | Hostdaten nicht offen |
| Gitleaks | https://github.com/gitleaks/gitleaks | Secret Scan | Security | low | installierbar | `gitleaks version` | Binary entfernen | vor Commit nutzen |
| Trivy | https://github.com/aquasecurity/trivy | FS/Container Scan | Security | low | installierbar | `trivy --version` | Binary/apt entfernen | DB-Cache kann wachsen |
| Grype | https://github.com/anchore/grype | CVE Scan | Security | low | installierbar | `grype version` | Binary entfernen | Cache beachten |
| Syft | https://github.com/anchore/syft | SBOM | Security | low | installierbar | `syft version` | Binary entfernen | SBOMs vertraulich |
| Semgrep | https://github.com/semgrep/semgrep | Codeanalyse | Security | medium | installierbar | `semgrep --version` | venv/pipx entfernen | grosse Repos langsam |
| ShellCheck | https://github.com/koalaman/shellcheck | Shell-Lint | AI_Testing_QA_Lab | low | installierbar | `shellcheck --version` | apt/Binary entfernen | CI geeignet |
| shfmt | https://github.com/mvdan/sh | Shell-Format | AI_Testing_QA_Lab | low | installierbar | `shfmt --version` | Binary entfernen | nur checken, nicht blind schreiben |
| Whisper.cpp | https://github.com/ggerganov/whisper.cpp | lokale STT | Voice | medium | installierbar | Binary/Modelltest | `/opt/whisper.cpp` entfernen | Modelle gross |
| faster-whisper | https://github.com/SYSTRAN/faster-whisper | STT Python | Voice | medium | installierbar | Python import | venv entfernen | GPU optional |
| Piper | https://github.com/rhasspy/piper | lokale TTS | Voice | low | installierbar | `piper --help` | Binary/Pfad entfernen | stabiler als Coqui |
| OpenHands | https://github.com/All-Hands-AI/OpenHands | Web-Coding-Agent | Programmierer | high | planned | Container/Web-Status | Container/Pfad entfernen | nur Sandbox |
| Continue.dev | https://github.com/continuedev/continue | IDE-KI | Programmierer | medium | planned | Repo/Extension | `/opt/continue_dev` entfernen | Desktop-nah |
| Haystack | https://github.com/deepset-ai/haystack | RAG Framework | RAG | medium | planned | Python import | venv entfernen | Daten lokal |
| Nextcloud | https://github.com/nextcloud/server | Cloud/Files | Privacy_First_Cloud_Sync | high | planned | Port/Webstatus | Compose/Daten bewusst | Backup/TLS Pflicht |
| Headscale | https://github.com/juanfont/headscale | Selfhosted Tailnet | Zero Trust | high | documentation-only | Service/CLI | Service/Daten entfernen | Admin-Aufwand |
| Browserless | https://github.com/browserless/browserless | Browser-Service | Data_Scraping | high | documentation-only | Port/API | Container entfernen | nie offen |
| MobSF | https://github.com/MobSF/Mobile-Security-Framework-MobSF | Mobile Security Lab | Android_AI_App_Lab | high | documentation-only | Webstatus | Container/Pfad entfernen | nur eigene APKs |
| scancode-toolkit | https://github.com/aboutcode-org/scancode-toolkit | Lizenzanalyse | Legal_Compliance | medium | planned | `scancode --version` | venv entfernen | grosse Scans langsam |
| OpenTelemetry Collector | https://github.com/open-telemetry/opentelemetry-collector | Observability | LLMOps_Control_Center | medium | documentation-only | `otelcol --version` | Binary/Service entfernen | Telemetrie minimieren |
