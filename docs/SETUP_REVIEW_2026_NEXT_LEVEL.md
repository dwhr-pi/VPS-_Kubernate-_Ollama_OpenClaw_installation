# Setup Review 2026 Next Level

Stand: 2026-05-28.

## Gesamtbewertung

Das Ultimate-KI-Setup ist bereits mehr als eine Tool-Sammlung: Es besitzt Profile, Tool-Registries, Doctor-Skripte, Security-Dokumentation, Update-Pfade, Logik fuer WSL2/VPS und viele vorbereitete Installer. Der naechste Reifegrad ist nicht "noch mehr Tools", sondern ein stabileres Betriebsmodell: klare Statusklassen, konsequente Dry-Runs, idempotente Tool-Lifecycle-Skripte und harte Safe-Defaults.

## Staerken

- Breite modulare Struktur fuer Base System, Runtime, Model Gateway, Agent Layer, Memory/RAG, Tool Layer, UI, Monitoring und Security.
- Viele Profile sind bereits dokumentiert und ueber Tool-Mappings erschlossen.
- Logs und Userdaten liegen weitgehend ausserhalb des Repos unter `~/.openclaw_ultimate_user_data`.
- Schwere Tools werden zunehmend markiert und vor Installation bestaetigt.
- WSL2-, VPS-, GPU- und Kubernetes-Pfade sind konzeptionell getrennt.
- Doctor-/Check-Skripte existieren bereits und koennen erweitert werden.

## Schwaechen

- Einige Profile sind konzeptionell ueberlappend und brauchen Alias-/Deprecated-Markierung statt Parallelpflege.
- Nicht jedes Tool hat bereits vollstaendig `check`, `install`, `update`, `uninstall`, `doctor` und `status`.
- Monorepo-/Kubernetes-/GPU-Tools koennen unter WSL2 sehr lange laufen und viel Speicher belegen.
- Manche Dokumentationsprofile sind sichtbar, aber bewusst noch nicht installierbar.
- GitHub-Quellen, Ports und Ressourcenwerte sind nicht fuer alle Tools maschinenlesbar vollstaendig.

## Sicherheitsrisiken

- Oeffentliche Admin-Ports waeren kritisch; Default muss `127.0.0.1` bleiben.
- `.env` und Tokens duerfen nie ins Repo.
- Docker Socket, Kubernetes Cluster, Airbyte, n8n, Activepieces, Nextcloud, Browser-Agenten und Smart-Home-Automationen brauchen Human Approval.
- Security-Profile muessen defensiv, autorisiert und lokal-first bleiben.
- Forks oder manipulierte Setup-Kopien duerfen nicht automatisch selbstheilend aktualisiert werden.

## Fehlende oder unvollstaendige Profilgruppen

Die vorgeschlagenen Next-Level-Profile sind groesstenteils sinnvoll, sollten aber zuerst als `planned`/`documentation-first` erscheinen:

- Betrieb: Backup/Restore, Secrets, Patch-Management, Status-Control, Resource/Cost, Cluster, Edge, VPS Hardening.
- LLMOps: MCP Hub, Agent Router, Model Benchmark, Prompt Evaluation, LoRA/Fine-Tuning, Dataset Curation, Audit Logs.
- Wissen: Nextcloud Knowledge Hub, PDF/Table Extraction, Deep Search.
- Automation: Workflow Hub, n8n Agent Automation, Webhook Gateway, Notification Center.
- Security: Blue Team, Traffic Analyzer, Container/Dependency Scanner, Log Threat Detection.
- Medien: ComfyUI/SD/Video/Music/Blender/Asset Factory.
- Android: Firewall, App Clone Lab, MicroG, Container-App, APK Build/Signing.
- Netzwerk: FritzBox, Tailscale, Cloudflare Access, Local Voice, Smart Home Audit.

## Fehlende oder zu pruefende GitHub-Tools

Prioritaet `recommended`: MCP servers, lobe-chat, ragflow, milvus, windmill, wazuh, trufflehog, filebrowser, AUTOMATIC1111, InvokeAI.

Prioritaet `optional/heavy`: Kubernetes, K3s, Podman, OpenHands, Nextcloud, ComfyUI, Blender, Coqui TTS, Milvus, Wazuh.

## Prioritaetenliste

1. Keine Secrets ins Repo und `.env` nur unter `~/.openclaw_ultimate_user_data`.
2. Ports standardmaessig nur auf `127.0.0.1`.
3. Schwere Installationen mit Speicher/RAM/Swap-Preflight und expliziter Bestaetigung.
4. Tool-Lifecycle vereinheitlichen: `check`, `install`, `update`, `uninstall`, `doctor`, `status`.
5. Registries synchron halten und fehlende Skripte melden.
6. Low-Resource-Modus fuer WSL2/MiniPC als eigener Installationspfad.
7. CI fuer Shellcheck, Markdown, Secrets, Registry-Sync und Dry-Run.

## Konkrete Umsetzungsschritte

- `docs/PROFILE_GAP_ANALYSIS.md` als Quelle fuer geplante Profile nutzen.
- `docs/TOOL_GAP_ANALYSIS.md` als Quelle fuer optionale Tool-Kandidaten nutzen.
- Profile erst dokumentieren, dann Installer/Checks bauen, erst danach im Menue aktivieren.
- Fuer jedes Tool eine kleine Lifecycle-Datei oder Funktionen in `scripts/tools/` nachziehen.
- `scripts/next_level_dry_run_check.sh` im CI laufen lassen.
- Schwere Tools in Menues als `[schwer]`, `[GPU]`, `[VPS]`, `[experimental]` markieren.
- `scripts/preflight.sh`, `scripts/secret_scan.sh`, `scripts/security_scan.sh`, `scripts/profile_matrix_check.sh` und `scripts/tool_registry_check.sh` als sichere Validation-Wrapper verwenden.
- Neue Tool-Kandidaten erst als `planned`/`optional` in `docs/TOOL_GAP_ANALYSIS.md` dokumentieren, bevor Installer entstehen.
