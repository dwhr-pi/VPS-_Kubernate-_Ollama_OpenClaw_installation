# Setup Review und naechste Schritte

Stand: 2026-05-15

## Kurzbewertung

Das Repository ist inzwischen deutlich mehr als ein einzelnes Installationsskript. Stark sind vor allem das modulare Zielbild `Base System -> Runtime -> Model Gateway -> Agent Layer -> Memory/RAG -> Tool Layer -> UI -> Monitoring -> Security`, die getrennte Benutzerablage unter `~/.openclaw_ultimate_user_data`, die zentrale Tool-/Profil-/Port-Registry und die wachsende Trennung zwischen lokaler Nutzung, VPS, WSL2, K3s und GPU-Workstation.

Die groesste Baustelle ist nicht mehr "noch mehr Tools", sondern Ordnung: stabile Profile muessen klar von Beta-/Experimental-/High-Risk-Profilen getrennt werden, und jedes Profil braucht erkennbare Tool-Zuordnung, Ressourcenhinweise, Sicherheitsgrenzen und einen Doctor-/Statuspfad.

## Was bereits gut ist

- Zentrale Registries unter `config/tools.yml`, `config/profiles.yml` und `config/ports.yml`.
- Viele Profile sind bereits als Fachprofile unter `docs/Profil/` und als Setup-Profile unter `docs/Profile/` dokumentiert.
- Sensible Laufzeitdaten liegen ausserhalb des Repos in `~/.openclaw_ultimate_user_data`.
- Huginn, n8n, OpenClaw, Ollama, RAG, Monitoring, Remote-Zugriff, Mail-Diagnose und Persona-Systeme sind nicht mehr nur Ideen, sondern teilweise installierbar.
- Tailscale, cloudflared und lokale Bindings sind als sicherere Alternative zu offenen VPS-Ports vorgesehen.
- Tool-Metriken, Installationslogs und Diagnoseberichte schaffen eine gute Basis fuer reproduzierbare Tests.

## Ueberschneidungen und unklare Profilnamen

- `Document_AI` und `Document_Intelligence` sollten mittelfristig zusammengefuehrt oder sauber getrennt werden: `Document_AI` als leichtes OCR-/PDF-Profil, `Document_Intelligence` als RAG-/Workflow-Profil.
- `Image_Generation` und `Image_Generation_Studio` ueberschneiden sich. Empfehlung: `Image_Generation` als Minimalprofil, `Image_Generation_Studio` als GPU-/ComfyUI-/Forge-Profil.
- `Video_Generation` und `Video_Generation_Studio` analog trennen.
- `Trading_AI`, `Trading_Analysis`, `Trading_Crypto_Web3`, `Trading_Execution_Manual_Mode` brauchen eine sichtbare Safe-Mode-Klammer: Analyse und Paper-Trading ja, Live-Orders niemals als Default.
- `Security_Analyst`, `Security_DevSecOps`, `Ethical_HackerGPT`, `Cyber_Security_AI` und `Anti_Virus` sollten in der Doku als defensive Sicherheitsfamilie zusammenstehen.
- `Prompt_Engineering_Studio`, `Prompt_Engineering_Lab` und `Prompt_Generator_Studio` sollten getrennt bleiben: Studio fuer Tests/Evaluation, Lab fuer Bibliothek/Versionierung, Generator fuer konkrete Prompt-Ausgaben.

## Dokumentiert, aber noch nicht voll installierbar

- Einige Advanced-Stacks wie Dify, AnythingLLM, Open Interpreter, MLflow, DVC, Android SDK, Render-Farm/GPU-Offloading und AdGuard Home sind sinnvoll, sollten aber erst als optionale oder experimentelle Bausteine erscheinen.
- Voice-/Telefonie-/Fritz!Fon-Workflows sind konzeptionell dokumentiert, aber noch kein vollstaendiger produktiver Telefonie-Stack.
- Legal-, Health-, OSINT- und Security-Profile brauchen weiterhin klare Warnhinweise und defensive Defaults.
- K3s/GPU/Media-Stacks sollten nicht im Minimalpfad installiert werden, sondern nur nach Hardware-/Speicherpruefung.

## Profile mit Top-Level-Menue-Potenzial

- `Programmierer`
- `RAG_Wissensdatenbank`
- `Model_Router_Gateway`
- `Monitoring_Observability`
- `Security_DevSecOps`
- `Cyber_Security_AI`
- `Anti_Virus`
- `Home_Network_Security`
- `Prompt_Generator_Studio`
- `Memory_Import_Export`
- `AI_Dashboard_Builder`
- `Render_Farm_GPU_Workstation`

## Optional statt Pflichtinstallation

- GPU-/Media-Tools wie ComfyUI, Forge, Blender, RealESRGAN und Render-Farm-Komponenten.
- Browser-Automation, Scraping und OSINT.
- Web3, Trading und Wallet-nahe Tools.
- Offensive oder missverstaendliche Security-Tools; nur defensiv, nur Allowlist, nie automatisch gegen fremde Ziele.
- Watchtower/Auto-Update fuer Container nur mit Backup und bewusstem Rollback-Konzept.

## Security-Risiken

- VPS: offene Ports, Default-Logins, fehlende Auth-Middleware, direkt exponierte Dashboards.
- API-Keys: duerfen nie in `.env.example`, Markdown-Beispiele oder Logs gelangen.
- Agenten: Shell-/Browser-/Tool-Zugriff braucht Allowlist, Dry-Run und manuelle Freigabe fuer riskante Aktionen.
- Web3/Trading: keine Seed-Phrases, keine Private Keys, keine Live-Orders als Default.
- Media/Voice/Face: Rechte, Einwilligung, Voice-Clone- und Deepfake-Grenzen klar dokumentieren.
- Monitoring/Logs: Prompts, Cookies, Sessions und personenbezogene Daten redigieren.

## Prioritaeten

- P0: Doctor-Skripte, Port-/Profil-/Tool-Validierung, Secret-Scan, sichere Defaults.
- P1: stabile Profil-Matrix, klare Stable/Beta/Experimental/High-Risk-Kennzeichnung.
- P2: RAG-/Memory-/Prompt-/Evaluation-Workflows konsolidieren.
- P3: GPU/Media/Android/Render-Farm/Advanced-Netzwerk nur optional weiter ausbauen.
