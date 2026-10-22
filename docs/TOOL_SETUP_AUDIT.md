# Dokumentation und Setup: Vollstaendigkeitsabgleich

Statischer Repository-Abgleich, Stand 22.10.2026. Neu erzeugen:

```text
python -B scripts/audit_tool_coverage.py --output docs/TOOL_SETUP_AUDIT.md
```

**Nein, nicht alle dokumentierten Werkzeuge sind als installierbare Tools integriert.**
Dieser Bericht liest nur Repository-Dateien, startet weder Setup noch WSL und prueft
keine tatsaechlich installierte Software, Downloads, Builds, Provider oder Dienste.

## Ergebnis

| Messwert | Anzahl |
|---|---|
| Gelesene Markdown-Dateien (Bericht selbst ausgenommen) | 955 |
| Registry-Eintraege | 362 |
| Explizite Tools-Menueeintraege | 299 |
| Registry ohne Tools-Menueeintrag | 164 |
| Tools-Menue ohne Registry-Zuordnung | 101 |
| Registry mit bekanntem Installationsplatzhalter | 160 |
| Rezepte im separaten Entwicklungskatalog | 62 |
| Quellen im Entwicklungskatalog | 62 |
| Eindeutige GitHub-Repositories in der Dokumentation | 515 |
| GitHub-Referenzen ohne direkte Quellenzuordnung | 242 |

## So sind die Ergebnisse zu lesen

- Hauptmenue 8 zeigt die explizite Tools-Liste aus setup_ultimate.sh, nicht automatisch die Registry.
- Die 62 Entwicklungsquellen sind separat ueber Hauptmenue 16 bzw. die Zusatzschaltflaeche im Tools-Menue erreichbar.
- Registry-only bedeutet nicht automatisch fehlender Installer: alternative Skripte/Projektwege separat pruefen.
- Ein vorhandenes Skript beweist weder eine vollstaendige Installation noch eine nutzbare Runtime. Source-only, VSIX, manuelle Downloads und optionale Builds bleiben unterschiedliche Modi.
- Ein bekannter Platzhalter ist kein Installer. Status planned kann aber auch bei einem echten Skript veraltet sein.
- GitHub-Referenzen umfassen Bibliotheken, Actions, Modelle, Mirrors und Beispiele. Nicht zugeordnete Referenzen sind Pruefkandidaten, keine automatische Liste fehlender Programme.
- Verglichen werden explizite Bash-Arrays/Mappings und direkte Quellen-URLs. Textnennungen ohne GitHub-Link, historische Umbenennungen und indirekte Helper-URLs sind nicht vollstaendig semantisch aufloesbar.
- Keine Installationsbereitschaft aus einem Dateinamen ableiten; diesen Bericht nicht als Live-Abnahme verwenden.

## Registry ohne Eintrag im Tools-Menue

| ID | Installationsweg | Umfang |
|---|---|---|
| lightrag | scripts/tools/lightrag_install.sh | Skript vorhanden; Runtime ungeprueft |
| crowdsec | scripts/tools/crowdsec_install.sh | Skript vorhanden; Runtime ungeprueft |
| ufw | scripts/tools/ufw_install.sh | Skript vorhanden; Runtime ungeprueft |
| tailscale | scripts/tools/tailscale_install.sh | Skript vorhanden; Runtime ungeprueft |
| cloudflared | scripts/tools/cloudflared_install.sh | Skript vorhanden; Runtime ungeprueft |
| zigbee2mqtt | scripts/tools/zigbee2mqtt_install.sh | Skript vorhanden; Runtime ungeprueft |
| esphome | scripts/tools/esphome_install.sh | Skript vorhanden; Runtime ungeprueft |
| borgbackup | scripts/tools/borgbackup_install.sh | Skript vorhanden; Runtime ungeprueft |
| appsmith | scripts/tools/appsmith_install.sh | Skript vorhanden; Runtime ungeprueft |
| budibase | scripts/tools/budibase_install.sh | Skript vorhanden; Runtime ungeprueft |
| nocodb | scripts/tools/nocodb_install.sh | Skript vorhanden; Runtime ungeprueft |
| directus | scripts/tools/directus_install.sh | Skript vorhanden; Runtime ungeprueft |
| nextcloud | scripts/tools/nextcloud_install.sh | Skript vorhanden; Runtime ungeprueft |
| clamav | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| yara | scripts/tools/yara_install.sh | Skript vorhanden; Runtime ungeprueft |
| searxng | scripts/tools/searxng_install.sh | Skript vorhanden; Runtime ungeprueft |
| haystack | scripts/tools/haystack_install.sh | Skript vorhanden; Runtime ungeprueft |
| forgejo | scripts/tools/forgejo_install.sh | Skript vorhanden; Runtime ungeprueft |
| penpot | scripts/tools/penpot_install.sh | Skript vorhanden; Runtime ungeprueft |
| pytest | scripts/tools/pytest_install.sh | Skript vorhanden; Runtime ungeprueft |
| deepeval | scripts/tools/deepeval_install.sh | Skript vorhanden; Runtime ungeprueft |
| pihole | scripts/tools/pihole_install.sh | Skript vorhanden; Runtime ungeprueft |
| adguard_home | scripts/tools/adguard_home_install.sh | Skript vorhanden; Runtime ungeprueft |
| trafilatura | scripts/tools/trafilatura_install.sh | Skript vorhanden; Runtime ungeprueft |
| reuse | scripts/tools/reuse_install.sh | Skript vorhanden; Runtime ungeprueft |
| scancode_toolkit | scripts/tools/scancode_toolkit_install.sh | Skript vorhanden; Runtime ungeprueft |
| gbox | scripts/tools/gbox_install.sh | Skript vorhanden; Runtime ungeprueft |
| ai_content_multiplier | scripts/tools/ai_content_multiplier_install.sh | Skript vorhanden; Runtime ungeprueft |
| websitefactory | scripts/tools/websitefactory_install.sh | Skript vorhanden; Runtime ungeprueft |
| stalwart_mail | scripts/tools/stalwart_mail_install.sh | Skript vorhanden; Runtime ungeprueft |
| queue_manager | scripts/tools/queue_manager_install.sh | Skript vorhanden; Runtime ungeprueft |
| tasktiger | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| rq | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| celery | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| dramatiq | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| bullmq | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| temporal | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| argo_workflows | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| swe_agent | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| cosign | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| sops | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| age | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| vaultwarden | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| suricata | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| wazuh | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| headscale | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| headplane | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| wireguard | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| frp | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| nginx_proxy_manager | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| caddy | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| traefik | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| ddclient_he | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| acme_sh | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| rspamd | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| roundcube | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| snappymail | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mailpit | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| opendkim | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| opendmarc | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| kopia | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| supabase_self_hosted | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| duplicati | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| automatic1111 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| krita_ai_diffusion | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| job_queue | scripts/tools/job_queue_install.sh | Skript vorhanden; Runtime ungeprueft |
| modelcontextprotocol_servers | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_filesystem | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_git | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_github | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_shell | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_browser | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_sqlite | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_postgres | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_fetch | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_memory | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| supervisord | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| systemd_user_units | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| tmux | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| pm2 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| lynis | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| openscap | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_filesystem_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_git_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_github_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_shell_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_browser_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_sqlite_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_postgres_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_fetch_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mcp_memory_server | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| styletts2 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| openvoice | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| rvc | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| seed_vc | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| diffsinger | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| openutau | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| nnsvs | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| audacity | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| uvr5 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| fish_speech | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| melotts | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| kokoro_tts | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| spark_tts | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| hallo2 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| musetalk | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| liveportrait | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| sadtalker | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| emo_avatar | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| skyreels_a1 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| wav2lip | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| clearer_voice_studio | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| obs | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| subtitleedit | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| openbao | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| infisical | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| glances | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| blocky | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| localai | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| browsermcp | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| docker_mcp_registry | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| pass | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| litestream | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| fastlane | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| apktool | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mitmproxy | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| radicale | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| imap_importer | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| git | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| doctor | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| wsl2 | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| voice_studio | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| podcast_studio | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| audiobook_studio | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| dubbing_studio | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| prompt_generator_studio | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| video_ai_production | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| character_library | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| voice_clone | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| ai_choir | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| android_sdk | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| gradle | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| jadx | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| arq | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| apscheduler | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| promtail | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| renovate | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| check_resource_budget | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| mkdocs | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| firejail | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| wakeonlan | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| nvidia_smi | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| ddclient | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| check_tools | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| check_profiles | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| check_ports | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| paddleocr | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| livekit | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| asterisk | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| beszel | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| zeek | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| falco | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| stalwart | scripts/tools/planned_tool_stub_install.sh | Platzhalter |
| sieve | scripts/tools/planned_tool_stub_install.sh | Platzhalter |

## Tools-Menue ohne Registry-Zuordnung

| Menueeintrag | Tatsaechliches Skript | Umfang |
|---|---|---|
| Actionlint | scripts/tools/actionlint_install.sh | Skript vorhanden; Runtime ungeprueft |
| Agent_Router | scripts/tools/agent_router_install.sh | Skript vorhanden; Runtime ungeprueft |
| Ahrefs | scripts/tools/ahrefs_install.sh | Skript vorhanden; Runtime ungeprueft |
| AI_Powered_Law_Firms | scripts/tools/ai_powered_law_firms_install.sh | Skript vorhanden; Runtime ungeprueft |
| Airtable | scripts/tools/airtable_install.sh | Skript vorhanden; Runtime ungeprueft |
| AnimateDiff | scripts/tools/animatediff_install.sh | Skript vorhanden; Runtime ungeprueft |
| AutoGPT | scripts/tools/autogpt_install.sh | Skript vorhanden; Runtime ungeprueft |
| Axolotl | scripts/tools/axolotl_install.sh | Skript vorhanden; Runtime ungeprueft |
| Backtest_Workflow | scripts/tools/backtest_workflow_install.sh | Skript vorhanden; Runtime ungeprueft |
| BPM_Analyzer | scripts/tools/bpm_analyzer_install.sh | Skript vorhanden; Runtime ungeprueft |
| Browser_Tool | scripts/tools/browser_tool_install.sh | Skript vorhanden; Runtime ungeprueft |
| Buffer_API | scripts/tools/buffer_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| Clawbake | scripts/tools/clawbake_install.sh | Skript vorhanden; Runtime ungeprueft |
| Clawhub | scripts/tools/clawhub_install.sh | Skript vorhanden; Runtime ungeprueft |
| Clawhub_CLI | scripts/tools/clawhub_cli_install.sh | Skript vorhanden; Runtime ungeprueft |
| Code_Sandbox | scripts/tools/code_sandbox_install.sh | Skript vorhanden; Runtime ungeprueft |
| ControlNet | scripts/tools/controlnet_install.sh | Skript vorhanden; Runtime ungeprueft |
| Data_Juicer | scripts/tools/data_juicer_install.sh | Skript vorhanden; Runtime ungeprueft |
| Deadline_Checker | scripts/tools/deadline_checker_install.sh | Skript vorhanden; Runtime ungeprueft |
| Docker_Compose_Plugin | scripts/tools/docker_compose_plugin_install.sh | Skript vorhanden; Runtime ungeprueft |
| Drafting_Agent | scripts/tools/drafting_agent_install.sh | Skript vorhanden; Runtime ungeprueft |
| ElevenLabs | scripts/tools/elevenlabs_install.sh | Skript vorhanden; Runtime ungeprueft |
| Emotion_Tagging | scripts/tools/emotion_tagging_install.sh | Skript vorhanden; Runtime ungeprueft |
| EnviroLLM | scripts/tools/envirollm_install.sh | Skript vorhanden; Runtime ungeprueft |
| Ethers_JS | scripts/tools/ethers_js_install.sh | Skript vorhanden; Runtime ungeprueft |
| EULLM | scripts/tools/eullm_install.sh | Skript vorhanden; Runtime ungeprueft |
| Exchange_APIs | scripts/tools/exchange_apis_install.sh | Skript vorhanden; Runtime ungeprueft |
| Fail2Ban_Analyzer | scripts/tools/fail2ban_analyzer_install.sh | Skript vorhanden; Runtime ungeprueft |
| File_System_Tool | scripts/tools/file_system_tool_install.sh | Skript vorhanden; Runtime ungeprueft |
| FinGPT | scripts/tools/fingpt_install.sh | Skript vorhanden; Runtime ungeprueft |
| Fooocus | scripts/tools/fooocus_install.sh | Skript vorhanden; Runtime ungeprueft |
| Foundry | scripts/tools/foundry_install.sh | Skript vorhanden; Runtime ungeprueft |
| GitHub_API_Tooling | scripts/tools/github_api_tooling_install.sh | Skript vorhanden; Runtime ungeprueft |
| GitHub_Research | scripts/tools/github_research_install.sh | Skript vorhanden; Runtime ungeprueft |
| Google_Analytics_API | scripts/tools/google_analytics_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| Hadolint | scripts/tools/hadolint_install.sh | Skript vorhanden; Runtime ungeprueft |
| Hardhat | scripts/tools/hardhat_install.sh | Skript vorhanden; Runtime ungeprueft |
| Hook_Detection | scripts/tools/hook_detection_install.sh | Skript vorhanden; Runtime ungeprueft |
| HubSpot | scripts/tools/hubspot_install.sh | Skript vorhanden; Runtime ungeprueft |
| Huge_Facing | scripts/tools/huge_facing_install.sh | Skript vorhanden; Runtime ungeprueft |
| Image_Upscaler_Pipeline | scripts/tools/image_upscaler_pipeline_install.sh | Skript vorhanden; Runtime ungeprueft |
| Joplin_CLI | scripts/tools/joplin_cli_install.sh | Skript vorhanden; Runtime ungeprueft |
| Kimi2 | scripts/tools/kimi2_install.sh | Skript vorhanden; Runtime ungeprueft |
| Kubectx_Kubens | scripts/tools/kubectx_kubens_install.sh | Skript vorhanden; Runtime ungeprueft |
| Kubernetes | scripts/tools/kubernetes_install.sh | Skript vorhanden; Runtime ungeprueft |
| Lawfirm | scripts/tools/lawfirm_install.sh | Skript vorhanden; Runtime ungeprueft |
| LibreOffice_Headless | scripts/tools/libreoffice_headless_install.sh | Skript vorhanden; Runtime ungeprueft |
| librosa | scripts/tools/librosa_install.sh | Skript vorhanden; Runtime ungeprueft |
| Llama_CPP_Toolchain | scripts/tools/llama_cpp_toolchain_install.sh | Skript vorhanden; Runtime ungeprueft |
| LLaMA_Factory | scripts/tools/llama_factory_install.sh | Skript vorhanden; Runtime ungeprueft |
| Make | scripts/tools/make_automation_install.sh | Skript vorhanden; Runtime ungeprueft |
| Memory_Policies | scripts/tools/memory_policies_install.sh | Skript vorhanden; Runtime ungeprueft |
| Meta_Ads_API | scripts/tools/meta_ads_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| MLflow | scripts/tools/mlflow_install.sh | Skript vorhanden; Runtime ungeprueft |
| Music2P_Pipeline | scripts/tools/music2p_pipeline_install.sh | Skript vorhanden; Runtime ungeprueft |
| NATS | scripts/tools/nats_install.sh | Skript vorhanden; Runtime ungeprueft |
| Nikto | scripts/tools/nikto_install.sh | Skript vorhanden; Runtime ungeprueft |
| Notion | scripts/tools/notion_install.sh | Skript vorhanden; Runtime ungeprueft |
| OPA | scripts/tools/opa_install.sh | Skript vorhanden; Runtime ungeprueft |
| OpenClaw_RL | scripts/tools/openclaw_rl_install.sh | Skript vorhanden; Runtime ungeprueft |
| OpenManus | scripts/tools/openmanus_install.sh | Skript vorhanden; Runtime ungeprueft |
| PDF_Parser | scripts/tools/pdf_parser_install.sh | Skript vorhanden; Runtime ungeprueft |
| Pgvector | scripts/tools/pgvector_install.sh | Skript vorhanden; Runtime ungeprueft |
| Pipedream | scripts/tools/pipedream_install.sh | Skript vorhanden; Runtime ungeprueft |
| pydub | scripts/tools/pydub_install.sh | Skript vorhanden; Runtime ungeprueft |
| Ray | scripts/tools/ray_install.sh | Skript vorhanden; Runtime ungeprueft |
| Repo_Comparison | scripts/tools/repo_comparison_install.sh | Skript vorhanden; Runtime ungeprueft |
| Rhasspy | scripts/tools/rhasspy_install.sh | Skript vorhanden; Runtime ungeprueft |
| Riffusion | scripts/tools/riffusion_install.sh | Skript vorhanden; Runtime ungeprueft |
| Risk_Agent | scripts/tools/risk_agent_install.sh | Skript vorhanden; Runtime ungeprueft |
| Risk_Scoring | scripts/tools/risk_scoring_install.sh | Skript vorhanden; Runtime ungeprueft |
| Risk_Strategy_Analyzer | scripts/tools/risk_strategy_analyzer_install.sh | Skript vorhanden; Runtime ungeprueft |
| Runway_API | scripts/tools/runway_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| Security_Workflow | scripts/tools/security_workflow_install.sh | Skript vorhanden; Runtime ungeprueft |
| SEMrush | scripts/tools/semrush_install.sh | Skript vorhanden; Runtime ungeprueft |
| SQLite | scripts/tools/sqlite_install.sh | Skript vorhanden; Runtime ungeprueft |
| SQLite_Vec | scripts/tools/sqlite_vec_install.sh | Skript vorhanden; Runtime ungeprueft |
| Stable_Diffusion_WebUI | scripts/tools/stable_diffusion_webui_install.sh | Skript vorhanden; Runtime ungeprueft |
| Suno_API | scripts/tools/suno_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| Supabase | scripts/tools/supabase_install.sh | Skript vorhanden; Runtime ungeprueft |
| SVD | scripts/tools/svd_install.sh | Skript vorhanden; Runtime ungeprueft |
| Tax_Calculator | scripts/tools/tax_calculator_install.sh | Skript vorhanden; Runtime ungeprueft |
| Tax_Law_Agent | scripts/tools/tax_law_agent_install.sh | Skript vorhanden; Runtime ungeprueft |
| Thumbnail_Pipeline | scripts/tools/thumbnail_pipeline_install.sh | Skript vorhanden; Runtime ungeprueft |
| TikTok_Ads_API | scripts/tools/tiktok_ads_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| TikTok_Score | scripts/tools/tiktok_score_install.sh | Skript vorhanden; Runtime ungeprueft |
| Trend_Monitor | scripts/tools/trend_monitor_install.sh | Skript vorhanden; Runtime ungeprueft |
| Udio_API | scripts/tools/udio_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| Unsloth | scripts/tools/unsloth_install.sh | Skript vorhanden; Runtime ungeprueft |
| Upload_Automation | scripts/tools/upload_automation_install.sh | Skript vorhanden; Runtime ungeprueft |
| Vault | scripts/tools/vault_install.sh | Skript vorhanden; Runtime ungeprueft |
| Voice_Assistant_Runtime | scripts/tools/voice_assistant_runtime_install.sh | Skript vorhanden; Runtime ungeprueft |
| VS_Code_Server | scripts/tools/vs_code_server_install.sh | Skript vorhanden; Runtime ungeprueft |
| Web3_APIs | scripts/tools/web3_apis_install.sh | Skript vorhanden; Runtime ungeprueft |
| Web3_Py | scripts/tools/web3_py_install.sh | Skript vorhanden; Runtime ungeprueft |
| Weights_and_Biases | scripts/tools/weights_and_biases_install.sh | Skript vorhanden; Runtime ungeprueft |
| Whisper | scripts/tools/whisper_install.sh | Skript vorhanden; Runtime ungeprueft |
| YT_DLP | scripts/tools/yt_dlp_install.sh | Skript vorhanden; Runtime ungeprueft |
| Zapier | scripts/tools/zapier_install.sh | Skript vorhanden; Runtime ungeprueft |
| Zenbot_API | scripts/tools/zenbot_api_install.sh | Skript vorhanden; Runtime ungeprueft |
| Zenbot_trader | scripts/tools/zenbot_trader_install.sh | Skript vorhanden; Runtime ungeprueft |

## Alle Registry-Eintraege

| ID | Tools-Menue | Status / Modus | Installationsskript / Umfang |
|---|---|---|---|
| concat | Concat | experimental / github-release-appimage | scripts/tools/concat_install.sh: Skript vorhanden; Runtime ungeprueft |
| remotion | Remotion | experimental / github-source-build | scripts/tools/remotion_install.sh: Skript vorhanden; Runtime ungeprueft |
| hyperframes | HyperFrames | experimental / github-source-build | scripts/tools/hyperframes_install.sh: Skript vorhanden; Runtime ungeprueft |
| openmontage | OpenMontage | experimental / github-python-core | scripts/tools/openmontage_install.sh: Skript vorhanden; Runtime ungeprueft |
| marp | Marp | experimental / github-release | scripts/tools/marp_install.sh: Skript vorhanden; Runtime ungeprueft |
| listmonk | Listmonk | experimental / github-release | scripts/tools/listmonk_install.sh: Skript vorhanden; Runtime ungeprueft |
| mautic | Mautic | experimental / github-release | scripts/tools/mautic_install.sh: Skript vorhanden; Runtime ungeprueft |
| gopls | Gopls | experimental / github-source-build | scripts/tools/gopls_install.sh: Skript vorhanden; Runtime ungeprueft |
| delve | Delve | experimental / github-source-build | scripts/tools/delve_install.sh: Skript vorhanden; Runtime ungeprueft |
| golangci_lint | GolangCI_Lint | experimental / github-source-build | scripts/tools/golangci_lint_install.sh: Skript vorhanden; Runtime ungeprueft |
| kubeconform | Kubeconform | experimental / github-source-build | scripts/tools/kubeconform_install.sh: Skript vorhanden; Runtime ungeprueft |
| kubelinter | KubeLinter | experimental / github-source-build | scripts/tools/kubelinter_install.sh: Skript vorhanden; Runtime ungeprueft |
| tflint | TFLint | experimental / github-source-build | scripts/tools/tflint_install.sh: Skript vorhanden; Runtime ungeprueft |
| terraform_docs | Terraform_Docs | experimental / github-source-build | scripts/tools/terraform_docs_install.sh: Skript vorhanden; Runtime ungeprueft |
| sqlfluff | SQLFluff | experimental / github-source-build | scripts/tools/sqlfluff_install.sh: Skript vorhanden; Runtime ungeprueft |
| bats_core | Bats_Core | experimental / github-scripts | scripts/tools/bats_core_install.sh: Skript vorhanden; Runtime ungeprueft |
| invoke_build | Invoke_Build | experimental / github-scripts | scripts/tools/invoke_build_install.sh: Skript vorhanden; Runtime ungeprueft |
| black | Black | experimental / github-source-build | scripts/tools/black_install.sh: Skript vorhanden; Runtime ungeprueft |
| mypy | Mypy | experimental / github-source-build | scripts/tools/mypy_install.sh: Skript vorhanden; Runtime ungeprueft |
| youtube_agent_skill | YouTube_Agent_Skill | experimental / github-skills-copy | scripts/tools/youtube_agent_skill_install.sh: Skript vorhanden; Runtime ungeprueft |
| anthropic_cli | Anthropic_CLI | experimental / github-source-build | scripts/tools/anthropic_cli_install.sh: Skript vorhanden; Runtime ungeprueft |
| agentic_os | Agentic_OS | experimental / github-source-only | scripts/tools/agentic_os_install.sh: Skript vorhanden; Runtime ungeprueft |
| colibri | Colibri | experimental / github-source-only | scripts/tools/colibri_install.sh: Skript vorhanden; Runtime ungeprueft |
| hyperfine | Hyperfine | experimental / github-source-only | scripts/tools/hyperfine_install.sh: Skript vorhanden; Runtime ungeprueft |
| hf_accelerate | HF_Accelerate | experimental / github-source-only | scripts/tools/hf_accelerate_install.sh: Skript vorhanden; Runtime ungeprueft |
| deepspeed | DeepSpeed | experimental / github-source-only | scripts/tools/deepspeed_install.sh: Skript vorhanden; Runtime ungeprueft |
| rea | REA | experimental / github-source-optional-build | scripts/tools/rea_install.sh: Skript vorhanden; Runtime ungeprueft |
| find_skills | Find_Skills | experimental / github-skill-copy | scripts/tools/find_skills_install.sh: Skript vorhanden; Runtime ungeprueft |
| claude_code | Claude_Code | experimental / source | scripts/tools/claude_code_install.sh: Skript vorhanden; Runtime ungeprueft |
| gemini_cli | Gemini_CLI | experimental / source | scripts/tools/gemini_cli_install.sh: Skript vorhanden; Runtime ungeprueft |
| qwen_desktop | Qwen_Desktop | planned / manual-windows | scripts/tools/qwen_desktop_install.sh: Skript vorhanden; Runtime ungeprueft |
| cline | Cline | experimental / github-release | scripts/tools/cline_install.sh: Skript vorhanden; Runtime ungeprueft |
| qwen_code | Qwen_Code | experimental / source | scripts/tools/qwen_code_install.sh: Skript vorhanden; Runtime ungeprueft |
| wan21 | Wan21 | experimental / source | scripts/tools/wan21_install.sh: Skript vorhanden; Runtime ungeprueft |
| comfyui_gguf | ComfyUI_GGUF | experimental / source | scripts/tools/comfyui_gguf_install.sh: Skript vorhanden; Runtime ungeprueft |
| wanvideo_wrapper | WanVideoWrapper | planned / documentation-first | scripts/tools/hybrid_media_candidate_install.sh: Platzhalter |
| supir | SUPIR | experimental / source | scripts/tools/supir_install.sh: Skript vorhanden; Runtime ungeprueft |
| film | FILM | experimental / source | scripts/tools/film_install.sh: Skript vorhanden; Runtime ungeprueft |
| pyannote_audio | Pyannote_Audio | experimental / source | scripts/tools/pyannote_audio_install.sh: Skript vorhanden; Runtime ungeprueft |
| deepfilternet | DeepFilterNet | experimental / source | scripts/tools/deepfilternet_install.sh: Skript vorhanden; Runtime ungeprueft |
| audioseal | AudioSeal | experimental / source | scripts/tools/audioseal_install.sh: Skript vorhanden; Runtime ungeprueft |
| cogvideox | CogVideoX, LTX_Video | planned / documentation-first | scripts/tools/social_media_candidate_install.sh: Platzhalter |
| ltx_video | CogVideoX, LTX_Video | planned / documentation-first | scripts/tools/social_media_candidate_install.sh: Platzhalter |
| tgi | TGI | experimental / source | scripts/tools/tgi_install.sh: Skript vorhanden; Runtime ungeprueft |
| pinokio | Pinokio | planned / manual-desktop | scripts/tools/pinokio_install.sh: Skript vorhanden; Runtime ungeprueft |
| sdnext | SD_Next | experimental / source | scripts/tools/sdnext_install.sh: Skript vorhanden; Runtime ungeprueft |
| windmill | Windmill | experimental / source | scripts/tools/windmill_install.sh: Skript vorhanden; Runtime ungeprueft |
| fal_client | Fal_Client | experimental / source | scripts/tools/fal_client_install.sh: Skript vorhanden; Runtime ungeprueft |
| veo_api | Veo_API | experimental / source | scripts/tools/veo_api_install.sh: Skript vorhanden; Runtime ungeprueft |
| hf_datasets | HF_Datasets | experimental / source | scripts/tools/hf_datasets_install.sh: Skript vorhanden; Runtime ungeprueft |
| hf_hub | HF_Hub | experimental / source | scripts/tools/hf_hub_install.sh: Skript vorhanden; Runtime ungeprueft |
| video2dataset | Video2Dataset | planned / documentation-first | scripts/tools/video_dataset_candidate_install.sh: Platzhalter |
| karaoke_formats | Karaoke_Formats | experimental / source | scripts/tools/karaoke_formats_install.sh: Skript vorhanden; Runtime ungeprueft |
| alexandria_audiobook | Alexandria_Audiobook | experimental / source | scripts/tools/alexandria_audiobook_install.sh: Skript vorhanden; Runtime ungeprueft |
| qwen3_tts | Qwen3_TTS | experimental / source | scripts/tools/qwen3_tts_install.sh: Skript vorhanden; Runtime ungeprueft |
| chattts | ChatTTS | experimental / source | scripts/tools/chattts_install.sh: Skript vorhanden; Runtime ungeprueft |
| audioldm2 | AudioLDM2 | experimental / source | scripts/tools/audioldm2_install.sh: Skript vorhanden; Runtime ungeprueft |
| audiogen | AudioGen | experimental / source | scripts/tools/audiogen_install.sh: Skript vorhanden; Runtime ungeprueft |
| stable_audio_open | Stable_Audio_Open | experimental / source | scripts/tools/stable_audio_open_install.sh: Skript vorhanden; Runtime ungeprueft |
| moshi | Moshi | experimental / source | scripts/tools/moshi_install.sh: Skript vorhanden; Runtime ungeprueft |
| moss_tts | MOSS_TTS | experimental / source | scripts/tools/moss_tts_install.sh: Skript vorhanden; Runtime ungeprueft |
| yue | YuE | experimental / source | scripts/tools/yue_install.sh: Skript vorhanden; Runtime ungeprueft |
| ace_step_15 | ACE_Step_15 | experimental / source | scripts/tools/ace_step_15_install.sh: Skript vorhanden; Runtime ungeprueft |
| whisperx | WhisperX | experimental / source | scripts/tools/whisperx_install.sh: Skript vorhanden; Runtime ungeprueft |
| aegisub | Aegisub | experimental / source | scripts/tools/aegisub_install.sh: Skript vorhanden; Runtime ungeprueft |
| basic_pitch | Basic_Pitch | experimental / source | scripts/tools/basic_pitch_install.sh: Skript vorhanden; Runtime ungeprueft |
| sfizz | Sfizz | experimental / source | scripts/tools/sfizz_install.sh: Skript vorhanden; Runtime ungeprueft |
| aida_x | AIDA_X | experimental / source | scripts/tools/aida_x_install.sh: Skript vorhanden; Runtime ungeprueft |
| propainter | ProPainter | experimental / source | scripts/tools/propainter_install.sh: Skript vorhanden; Runtime ungeprueft |
| kiwi_edit | Kiwi_Edit | experimental / source | scripts/tools/kiwi_edit_install.sh: Skript vorhanden; Runtime ungeprueft |
| void_model | VOID_Model | experimental / source | scripts/tools/void_model_install.sh: Skript vorhanden; Runtime ungeprueft |
| just_dub_it | Just_Dub_It | experimental / source | scripts/tools/just_dub_it_install.sh: Skript vorhanden; Runtime ungeprueft |
| vidubb | ViDubb | experimental / source | scripts/tools/vidubb_install.sh: Skript vorhanden; Runtime ungeprueft |
| agent_framework | Microsoft_Agent_Framework | experimental / source | scripts/tools/agent_framework_install.sh: Skript vorhanden; Runtime ungeprueft |
| personnel_documents | Personnel_Documents_AI | experimental / source | scripts/tools/personnel_documents_install.sh: Skript vorhanden; Runtime ungeprueft |
| automaton | Automaton | experimental / source | scripts/tools/automaton_install.sh: Skript vorhanden; Runtime ungeprueft |
| embedded_debug_hil | Embedded_Debug_HIL | experimental / source | scripts/tools/embedded_debug_hil_install.sh: Skript vorhanden; Runtime ungeprueft |
| freellmapi | FreeLLMAPI | experimental / source | scripts/tools/freellmapi_install.sh: Skript vorhanden; Runtime ungeprueft |
| rife | RIFE | experimental / venv | scripts/tools/rife_install.sh: Skript vorhanden; Runtime ungeprueft |
| velero | Velero | planned / binary | scripts/tools/velero_install.sh: Skript vorhanden; Runtime ungeprueft |
| k9s | K9s | planned / binary | scripts/tools/k9s_install.sh: Skript vorhanden; Runtime ungeprueft |
| ollama | Ollama | nicht angegeben / nicht angegeben | scripts/tools/ollama_install.sh: Skript vorhanden; Runtime ungeprueft |
| openclaw | OpenClaw | nicht angegeben / nicht angegeben | scripts/tools/openclaw_install.sh: Skript vorhanden; Runtime ungeprueft |
| ruflo | Ruflo | nicht angegeben / nicht angegeben | scripts/tools/ruflo_install.sh: Skript vorhanden; Runtime ungeprueft |
| litellm | LiteLLM | nicht angegeben / nicht angegeben | scripts/tools/litellm_install.sh: Skript vorhanden; Runtime ungeprueft |
| open_webui | Open_WebUI | nicht angegeben / nicht angegeben | scripts/tools/open_webui_install.sh: Skript vorhanden; Runtime ungeprueft |
| qdrant | Qdrant | nicht angegeben / nicht angegeben | scripts/tools/qdrant_install.sh: Skript vorhanden; Runtime ungeprueft |
| chromadb | ChromaDB | nicht angegeben / nicht angegeben | scripts/tools/chromadb_install.sh: Skript vorhanden; Runtime ungeprueft |
| lightrag | nein | nicht angegeben / nicht angegeben | scripts/tools/lightrag_install.sh: Skript vorhanden; Runtime ungeprueft |
| langfuse | Langfuse | nicht angegeben / nicht angegeben | scripts/tools/langfuse_install.sh: Skript vorhanden; Runtime ungeprueft |
| openlit | OpenLIT | nicht angegeben / nicht angegeben | scripts/tools/openlit_install.sh: Skript vorhanden; Runtime ungeprueft |
| prometheus | Prometheus | nicht angegeben / nicht angegeben | scripts/tools/prometheus_install.sh: Skript vorhanden; Runtime ungeprueft |
| grafana | Grafana | nicht angegeben / nicht angegeben | scripts/tools/grafana_install.sh: Skript vorhanden; Runtime ungeprueft |
| loki | Loki | nicht angegeben / nicht angegeben | scripts/tools/loki_install.sh: Skript vorhanden; Runtime ungeprueft |
| uptime_kuma | Uptime_Kuma | nicht angegeben / nicht angegeben | scripts/tools/uptime_kuma_install.sh: Skript vorhanden; Runtime ungeprueft |
| healthchecks | Healthchecks | nicht angegeben / nicht angegeben | scripts/tools/healthchecks_install.sh: Skript vorhanden; Runtime ungeprueft |
| mail_utils_msmtp | Mail_Utils_MSMTP | nicht angegeben / nicht angegeben | scripts/tools/mail_utils_msmtp_install.sh: Skript vorhanden; Runtime ungeprueft |
| trivy | Trivy | nicht angegeben / nicht angegeben | scripts/tools/trivy_install.sh: Skript vorhanden; Runtime ungeprueft |
| gitleaks | Gitleaks | nicht angegeben / nicht angegeben | scripts/tools/gitleaks_install.sh: Skript vorhanden; Runtime ungeprueft |
| semgrep | Semgrep | nicht angegeben / nicht angegeben | scripts/tools/semgrep_install.sh: Skript vorhanden; Runtime ungeprueft |
| crowdsec | nein | nicht angegeben / nicht angegeben | scripts/tools/crowdsec_install.sh: Skript vorhanden; Runtime ungeprueft |
| ufw | nein | nicht angegeben / nicht angegeben | scripts/tools/ufw_install.sh: Skript vorhanden; Runtime ungeprueft |
| tailscale | nein | nicht angegeben / nicht angegeben | scripts/tools/tailscale_install.sh: Skript vorhanden; Runtime ungeprueft |
| cloudflared | nein | nicht angegeben / nicht angegeben | scripts/tools/cloudflared_install.sh: Skript vorhanden; Runtime ungeprueft |
| authentik | Authentik | nicht angegeben / nicht angegeben | scripts/tools/authentik_install.sh: Skript vorhanden; Runtime ungeprueft |
| authelia | Authelia | nicht angegeben / nicht angegeben | scripts/tools/authelia_install.sh: Skript vorhanden; Runtime ungeprueft |
| node_red | Node_Red | nicht angegeben / nicht angegeben | scripts/tools/node_red_install.sh: Skript vorhanden; Runtime ungeprueft |
| mosquitto | Mosquitto | nicht angegeben / nicht angegeben | scripts/tools/mosquitto_install.sh: Skript vorhanden; Runtime ungeprueft |
| zigbee2mqtt | nein | nicht angegeben / nicht angegeben | scripts/tools/zigbee2mqtt_install.sh: Skript vorhanden; Runtime ungeprueft |
| esphome | nein | nicht angegeben / nicht angegeben | scripts/tools/esphome_install.sh: Skript vorhanden; Runtime ungeprueft |
| paperless_ngx | Paperless_NGX | experimental / docker | scripts/tools/paperless_ngx_install.sh: Skript vorhanden; Runtime ungeprueft |
| stirling_pdf | Stirling_PDF | nicht angegeben / nicht angegeben | scripts/tools/stirling_pdf_install.sh: Skript vorhanden; Runtime ungeprueft |
| apache_tika | Apache_Tika | nicht angegeben / nicht angegeben | scripts/tools/apache_tika_install.sh: Skript vorhanden; Runtime ungeprueft |
| docling | Docling | nicht angegeben / nicht angegeben | scripts/tools/docling_install.sh: Skript vorhanden; Runtime ungeprueft |
| pandoc | Pandoc | nicht angegeben / nicht angegeben | scripts/tools/pandoc_install.sh: Skript vorhanden; Runtime ungeprueft |
| jupyterlab | JupyterLab | nicht angegeben / pypi-venv-default-source-optional | scripts/tools/jupyterlab_install.sh: Skript vorhanden; Runtime ungeprueft |
| duckdb | DuckDB | stable / github-release-binary | scripts/tools/duckdb_install.sh: Skript vorhanden; Runtime ungeprueft |
| metabase | Metabase | nicht angegeben / nicht angegeben | scripts/tools/metabase_install.sh: Skript vorhanden; Runtime ungeprueft |
| airbyte | Airbyte | nicht angegeben / nicht angegeben | scripts/tools/airbyte_install.sh: Skript vorhanden; Runtime ungeprueft |
| minio | MinIO | nicht angegeben / nicht angegeben | scripts/tools/minio_install.sh: Skript vorhanden; Runtime ungeprueft |
| restic | Restic | nicht angegeben / nicht angegeben | scripts/tools/restic_install.sh: Skript vorhanden; Runtime ungeprueft |
| borgbackup | nein | nicht angegeben / nicht angegeben | scripts/tools/borgbackup_install.sh: Skript vorhanden; Runtime ungeprueft |
| rclone | Rclone | nicht angegeben / nicht angegeben | scripts/tools/rclone_install.sh: Skript vorhanden; Runtime ungeprueft |
| comfyui | ComfyUI | nicht angegeben / nicht angegeben | scripts/tools/comfyui_install.sh: Skript vorhanden; Runtime ungeprueft |
| stable_diffusion_webui_forge | Stable_Diffusion_WebUI_Forge | experimental / nicht angegeben | scripts/tools/stable_diffusion_webui_forge_install.sh: Skript vorhanden; Runtime ungeprueft |
| gfpgan | GFPGAN | nicht angegeben / nicht angegeben | scripts/tools/gfpgan_install.sh: Skript vorhanden; Runtime ungeprueft |
| realesrgan | RealESRGAN | nicht angegeben / nicht angegeben | scripts/tools/realesrgan_install.sh: Skript vorhanden; Runtime ungeprueft |
| rembg | Rembg | nicht angegeben / nicht angegeben | scripts/tools/rembg_install.sh: Skript vorhanden; Runtime ungeprueft |
| whisper_cpp | Whisper_CPP | nicht angegeben / nicht angegeben | scripts/tools/whisper_cpp_install.sh: Skript vorhanden; Runtime ungeprueft |
| faster_whisper | Faster_Whisper | nicht angegeben / nicht angegeben | scripts/tools/faster_whisper_install.sh: Skript vorhanden; Runtime ungeprueft |
| ffmpeg | FFmpeg | nicht angegeben / nicht angegeben | scripts/tools/ffmpeg_install.sh: Skript vorhanden; Runtime ungeprueft |
| piper | Piper | nicht angegeben / nicht angegeben | scripts/tools/piper_install.sh: Skript vorhanden; Runtime ungeprueft |
| coqui_tts | Coqui_TTS | experimental / venv | scripts/tools/coqui_tts_install.sh: Skript vorhanden; Runtime ungeprueft |
| demucs | Demucs | nicht angegeben / nicht angegeben | scripts/tools/demucs_install.sh: Skript vorhanden; Runtime ungeprueft |
| blender | Blender | nicht angegeben / nicht angegeben | scripts/tools/blender_install.sh: Skript vorhanden; Runtime ungeprueft |
| github_cli | GitHub_CLI | nicht angegeben / nicht angegeben | scripts/tools/github_cli_install.sh: Skript vorhanden; Runtime ungeprueft |
| act | Act | nicht angegeben / nicht angegeben | scripts/tools/act_install.sh: Skript vorhanden; Runtime ungeprueft |
| pre_commit | Pre_Commit | nicht angegeben / nicht angegeben | scripts/tools/pre_commit_install.sh: Skript vorhanden; Runtime ungeprueft |
| release_please | Release_Please | nicht angegeben / nicht angegeben | scripts/tools/release_please_install.sh: Skript vorhanden; Runtime ungeprueft |
| changelog_generator | Changelog_Generator | nicht angegeben / nicht angegeben | scripts/tools/changelog_generator_install.sh: Skript vorhanden; Runtime ungeprueft |
| aider | Aider | nicht angegeben / nicht angegeben | scripts/tools/aider_install.sh: Skript vorhanden; Runtime ungeprueft |
| openhands | OpenHands | nicht angegeben / nicht angegeben | scripts/tools/openhands_install.sh: Skript vorhanden; Runtime ungeprueft |
| continue_dev | Continue_Dev | nicht angegeben / nicht angegeben | scripts/tools/continue_dev_install.sh: Skript vorhanden; Runtime ungeprueft |
| langgraph | LangGraph | nicht angegeben / nicht angegeben | scripts/tools/langgraph_install.sh: Skript vorhanden; Runtime ungeprueft |
| crewai | CrewAI | nicht angegeben / nicht angegeben | scripts/tools/crewai_install.sh: Skript vorhanden; Runtime ungeprueft |
| autogen | AutoGen | nicht angegeben / nicht angegeben | scripts/tools/autogen_install.sh: Skript vorhanden; Runtime ungeprueft |
| playwright | Playwright | nicht angegeben / nicht angegeben | scripts/tools/playwright_install.sh: Skript vorhanden; Runtime ungeprueft |
| puppeteer | Puppeteer | nicht angegeben / nicht angegeben | scripts/tools/puppeteer_install.sh: Skript vorhanden; Runtime ungeprueft |
| flowise | Flowise | optional / git-pnpm | scripts/tools/flowise_install.sh: Skript vorhanden; Runtime ungeprueft |
| langflow | LangFlow | nicht angegeben / nicht angegeben | scripts/tools/langflow_install.sh: Skript vorhanden; Runtime ungeprueft |
| n8n | n8n | nicht angegeben / nicht angegeben | scripts/tools/n8n_install.sh: Skript vorhanden; Runtime ungeprueft |
| activepieces | Activepieces | nicht angegeben / nicht angegeben | scripts/tools/activepieces_install.sh: Skript vorhanden; Runtime ungeprueft |
| appsmith | nein | nicht angegeben / nicht angegeben | scripts/tools/appsmith_install.sh: Skript vorhanden; Runtime ungeprueft |
| budibase | nein | nicht angegeben / nicht angegeben | scripts/tools/budibase_install.sh: Skript vorhanden; Runtime ungeprueft |
| nocodb | nein | nicht angegeben / nicht angegeben | scripts/tools/nocodb_install.sh: Skript vorhanden; Runtime ungeprueft |
| directus | nein | nicht angegeben / nicht angegeben | scripts/tools/directus_install.sh: Skript vorhanden; Runtime ungeprueft |
| home_assistant | Home_Assistant | nicht angegeben / nicht angegeben | scripts/tools/home_assistant_install.sh: Skript vorhanden; Runtime ungeprueft |
| nextcloud | nein | nicht angegeben / nicht angegeben | scripts/tools/nextcloud_install.sh: Skript vorhanden; Runtime ungeprueft |
| llamaindex | LlamaIndex | nicht angegeben / nicht angegeben | scripts/tools/llamaindex_install.sh: Skript vorhanden; Runtime ungeprueft |
| unstructured | Unstructured | nicht angegeben / nicht angegeben | scripts/tools/unstructured_install.sh: Skript vorhanden; Runtime ungeprueft |
| marker | Marker | nicht angegeben / nicht angegeben | scripts/tools/marker_install.sh: Skript vorhanden; Runtime ungeprueft |
| meilisearch | Meilisearch | nicht angegeben / nicht angegeben | scripts/tools/meilisearch_install.sh: Skript vorhanden; Runtime ungeprueft |
| promptfoo | Promptfoo | experimental / source | scripts/tools/promptfoo_install.sh: Skript vorhanden; Runtime ungeprueft |
| syft | Syft | experimental / binary | scripts/tools/syft_install.sh: Skript vorhanden; Runtime ungeprueft |
| grype | Grype | stable / github-release-binary-checksum | scripts/tools/grype_install.sh: Skript vorhanden; Runtime ungeprueft |
| fail2ban | Fail2Ban | nicht angegeben / nicht angegeben | scripts/tools/fail2ban_install.sh: Skript vorhanden; Runtime ungeprueft |
| opentofu | OpenTofu | nicht angegeben / nicht angegeben | scripts/tools/opentofu_install.sh: Skript vorhanden; Runtime ungeprueft |
| ansible | Ansible | nicht angegeben / nicht angegeben | scripts/tools/ansible_install.sh: Skript vorhanden; Runtime ungeprueft |
| argocd_cli | ArgoCD_CLI | nicht angegeben / nicht angegeben | scripts/tools/argocd_cli_install.sh: Skript vorhanden; Runtime ungeprueft |
| grafana_alloy | Grafana_Alloy | nicht angegeben / nicht angegeben | scripts/tools/grafana_alloy_install.sh: Skript vorhanden; Runtime ungeprueft |
| netdata | Netdata | nicht angegeben / nicht angegeben | scripts/tools/netdata_install.sh: Skript vorhanden; Runtime ungeprueft |
| clamav | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| yara | nein | nicht angegeben / nicht angegeben | scripts/tools/yara_install.sh: Skript vorhanden; Runtime ungeprueft |
| searxng | nein | nicht angegeben / nicht angegeben | scripts/tools/searxng_install.sh: Skript vorhanden; Runtime ungeprueft |
| firecrawl | Firecrawl | nicht angegeben / nicht angegeben | scripts/tools/firecrawl_install.sh: Skript vorhanden; Runtime ungeprueft |
| haystack | nein | nicht angegeben / nicht angegeben | scripts/tools/haystack_install.sh: Skript vorhanden; Runtime ungeprueft |
| node_exporter | Node_Exporter | nicht angegeben / nicht angegeben | scripts/tools/node_exporter_install.sh: Skript vorhanden; Runtime ungeprueft |
| cadvisor | cAdvisor | nicht angegeben / nicht angegeben | scripts/tools/cadvisor_install.sh: Skript vorhanden; Runtime ungeprueft |
| postgres | Postgres | nicht angegeben / nicht angegeben | scripts/tools/postgres_install.sh: Skript vorhanden; Runtime ungeprueft |
| redis | Redis | nicht angegeben / nicht angegeben | scripts/tools/redis_install.sh: Skript vorhanden; Runtime ungeprueft |
| huginn | Huginn | nicht angegeben / nicht angegeben | scripts/tools/huginn_install.sh: Skript vorhanden; Runtime ungeprueft |
| forgejo | nein | nicht angegeben / nicht angegeben | scripts/tools/forgejo_install.sh: Skript vorhanden; Runtime ungeprueft |
| penpot | nein | nicht angegeben / nicht angegeben | scripts/tools/penpot_install.sh: Skript vorhanden; Runtime ungeprueft |
| tesseract | Tesseract | nicht angegeben / nicht angegeben | scripts/tools/tesseract_install.sh: Skript vorhanden; Runtime ungeprueft |
| syncthing | Syncthing | nicht angegeben / nicht angegeben | scripts/tools/syncthing_install.sh: Skript vorhanden; Runtime ungeprueft |
| pytest | nein | nicht angegeben / nicht angegeben | scripts/tools/pytest_install.sh: Skript vorhanden; Runtime ungeprueft |
| shellcheck | ShellCheck | nicht angegeben / nicht angegeben | scripts/tools/shellcheck_install.sh: Skript vorhanden; Runtime ungeprueft |
| shfmt | Shfmt | nicht angegeben / nicht angegeben | scripts/tools/shfmt_install.sh: Skript vorhanden; Runtime ungeprueft |
| deepeval | nein | nicht angegeben / nicht angegeben | scripts/tools/deepeval_install.sh: Skript vorhanden; Runtime ungeprueft |
| pihole | nein | nicht angegeben / nicht angegeben | scripts/tools/pihole_install.sh: Skript vorhanden; Runtime ungeprueft |
| adguard_home | nein | nicht angegeben / nicht angegeben | scripts/tools/adguard_home_install.sh: Skript vorhanden; Runtime ungeprueft |
| trafilatura | nein | nicht angegeben / nicht angegeben | scripts/tools/trafilatura_install.sh: Skript vorhanden; Runtime ungeprueft |
| reuse | nein | nicht angegeben / nicht angegeben | scripts/tools/reuse_install.sh: Skript vorhanden; Runtime ungeprueft |
| scancode_toolkit | nein | nicht angegeben / nicht angegeben | scripts/tools/scancode_toolkit_install.sh: Skript vorhanden; Runtime ungeprueft |
| gbox | nein | nicht angegeben / nicht angegeben | scripts/tools/gbox_install.sh: Skript vorhanden; Runtime ungeprueft |
| ai_content_multiplier | nein | nicht angegeben / nicht angegeben | scripts/tools/ai_content_multiplier_install.sh: Skript vorhanden; Runtime ungeprueft |
| websitefactory | nein | optional / nicht angegeben | scripts/tools/websitefactory_install.sh: Skript vorhanden; Runtime ungeprueft |
| stalwart_mail | nein | nicht angegeben / nicht angegeben | scripts/tools/stalwart_mail_install.sh: Skript vorhanden; Runtime ungeprueft |
| queue_manager | nein | planned / nicht angegeben | scripts/tools/queue_manager_install.sh: Skript vorhanden; Runtime ungeprueft |
| tasktiger | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| rq | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| celery | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| dramatiq | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| bullmq | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| temporal | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| argo_workflows | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| guardrails_ai | Guardrails_AI | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| opencode | OpenCode | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| swe_agent | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| cosign | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| sops | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| age | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| vaultwarden | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| suricata | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| wazuh | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| headscale | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| headplane | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| wireguard | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| frp | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| nginx_proxy_manager | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| caddy | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| traefik | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| ddclient_he | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| acme_sh | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| rspamd | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| roundcube | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| snappymail | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mailpit | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| opendkim | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| opendmarc | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| kopia | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| supabase_self_hosted | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| duplicati | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| invokeai | InvokeAI | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| automatic1111 | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| krita_ai_diffusion | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| job_queue | nein | beta / nicht angegeben | scripts/tools/job_queue_install.sh: Skript vorhanden; Runtime ungeprueft |
| modelcontextprotocol_servers | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_filesystem | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_git | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_github | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_shell | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_browser | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_sqlite | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_postgres | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_fetch | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_memory | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| supervisord | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| systemd_user_units | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| tmux | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| pm2 | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| lynis | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| openscap | nein | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| ocrmypdf | OCRmyPDF | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| zotero | Zotero | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| langchain | LangChain | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| opentelemetry | OpenTelemetry | planned / nicht angegeben | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_filesystem_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_git_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_github_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_shell_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_browser_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_sqlite_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_postgres_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_fetch_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mcp_memory_server | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| styletts2 | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| openvoice | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| rvc | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| seed_vc | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| diffsinger | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| openutau | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| nnsvs | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| audacity | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| uvr5 | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| fish_speech | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| melotts | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| kokoro_tts | nein | planned / python | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| spark_tts | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| hallo2 | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| musetalk | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| liveportrait | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| sadtalker | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| emo_avatar | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| skyreels_a1 | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| wav2lip | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| clearer_voice_studio | nein | planned / source | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| obs | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| subtitleedit | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| openbao | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| infisical | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| glances | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| blocky | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| llama_cpp | Llama_CPP | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| vllm | vLLM | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| localai | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| browsermcp | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| docker_mcp_registry | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| rabbitmq | RabbitMQ | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| pass | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| litestream | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| fastlane | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| apktool | nein | optional / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mitmproxy | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| k3s | K3s | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| helm | Helm | optional / official-release-checksum | scripts/tools/helm_install.sh: Skript vorhanden; Runtime ungeprueft |
| mcpo | MCPO | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| nmap | Nmap | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| radicale | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| trufflehog | TruffleHog | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| imap_importer | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| git | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| doctor | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| wsl2 | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| kubectl | Kubectl | planned / binary | scripts/tools/kubectl_install.sh: Skript vorhanden; Runtime ungeprueft |
| neo4j | Neo4j | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| musicgen | MusicGen | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| wyoming | Wyoming | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| openwakeword | openWakeWord | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| voice_studio | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| podcast_studio | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| audiobook_studio | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| dubbing_studio | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| prompt_generator_studio | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| video_ai_production | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| character_library | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| voice_clone | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| ai_choir | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| android_sdk | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| gradle | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| jadx | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| dbt | dbt | optional / git-subdirectory-venv | scripts/tools/dbt_install.sh: Skript vorhanden; Runtime ungeprueft |
| prefect | Prefect | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| arq | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| apscheduler | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| promtail | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| weaviate | Weaviate | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| kustomize | Kustomize | planned / binary | scripts/tools/kustomize_install.sh: Skript vorhanden; Runtime ungeprueft |
| renovate | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| check_resource_budget | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| mkdocs | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| podman | Podman | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| docker | Docker | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| firejail | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| wakeonlan | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| nvidia_smi | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| ddclient | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| markdownlint_cli | Markdownlint_CLI | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| check_tools | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| check_profiles | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| check_ports | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| paddleocr | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| livekit | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| asterisk | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| beszel | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| zeek | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| falco | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| stalwart | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| sieve | nein | planned / manual | scripts/tools/planned_tool_stub_install.sh: Platzhalter |
| finrag | FinRAG | optional / git-venv-auto-cpython311-build | scripts/tools/finrag_install.sh: Skript vorhanden; Runtime ungeprueft |
| finrobot | FinRobot | optional / git-venv-auto-cpython311-build | scripts/tools/finrobot_install.sh: Skript vorhanden; Runtime ungeprueft |
| flux_cli | Flux_CLI | optional / github-release-binary-checksum | scripts/tools/flux_cli_install.sh: Skript vorhanden; Runtime ungeprueft |

## Separater Entwicklungskatalog

Nur Rezept-/Dateizuordnung, keine Build-Abnahme. workflow-package aktiviert keine CI und editor-package keinen Editor.

| Quelle | ID | Rezeptmodus | Dateiverweise |
|---|---|---|---|
| Node.js | node_js | native-build | keine fehlenden Adapter-Dateien |
| TypeScript | typescript | node-package | keine fehlenden Adapter-Dateien |
| Prettier | prettier | node-package | keine fehlenden Adapter-Dateien |
| ESLint | eslint | node-package | keine fehlenden Adapter-Dateien |
| Vitest | vitest | node-package | keine fehlenden Adapter-Dateien |
| Vite | vite | node-package | keine fehlenden Adapter-Dateien |
| Playwright | playwright | node-package | keine fehlenden Adapter-Dateien |
| pnpm | pnpm | node-package | keine fehlenden Adapter-Dateien |
| Go | go | toolchain-build | keine fehlenden Adapter-Dateien |
| golang/tools | golang_tools | existing | keine fehlenden Adapter-Dateien |
| Delve | delve | existing | keine fehlenden Adapter-Dateien |
| golangci-lint | golangci_lint | existing | keine fehlenden Adapter-Dateien |
| Actions Checkout | actions_checkout | workflow-package | keine fehlenden Adapter-Dateien |
| Actions Setup Go | actions_setup_go | workflow-package | keine fehlenden Adapter-Dateien |
| GCC GitHub-Mirror | gcc_github_mirror | native-build | keine fehlenden Adapter-Dateien |
| LLVM | llvm | native-build | keine fehlenden Adapter-Dateien |
| CMake | cmake | native-build | keine fehlenden Adapter-Dateien |
| GoogleTest | googletest | native-build | keine fehlenden Adapter-Dateien |
| Catch2 | catch2 | native-build | keine fehlenden Adapter-Dateien |
| rustup | rustup | cargo-build | keine fehlenden Adapter-Dateien |
| Cargo | cargo | cargo-build | keine fehlenden Adapter-Dateien |
| rustfmt | rustfmt | cargo-build | keine fehlenden Adapter-Dateien |
| Clippy | clippy | cargo-build | keine fehlenden Adapter-Dateien |
| rust-analyzer | rust_analyzer | cargo-build | keine fehlenden Adapter-Dateien |
| ShellCheck | shellcheck | haskell-build | keine fehlenden Adapter-Dateien |
| shfmt | shfmt | go-build | keine fehlenden Adapter-Dateien |
| Bats-core | bats_core | existing | keine fehlenden Adapter-Dateien |
| BashDB | bashdb | native-build | keine fehlenden Adapter-Dateien |
| PowerShell | powershell | powershell-build | keine fehlenden Adapter-Dateien |
| VS-Code-PowerShell | vs_code_powershell | editor-package | keine fehlenden Adapter-Dateien |
| PSScriptAnalyzer | psscriptanalyzer | powershell-module | keine fehlenden Adapter-Dateien |
| Pester | pester | powershell-module | keine fehlenden Adapter-Dateien |
| Invoke-Build | invoke_build | existing | keine fehlenden Adapter-Dateien |
| PostgreSQL GitHub-Mirror | postgres | native-build | keine fehlenden Adapter-Dateien |
| Flyway | flyway | java-package | keine fehlenden Adapter-Dateien |
| SQLFluff | sqlfluff | existing | keine fehlenden Adapter-Dateien |
| dbt Core | dbt | python-package | keine fehlenden Adapter-Dateien |
| pgTAP | pgtap | postgres-extension-package | keine fehlenden Adapter-Dateien |
| Docker CLI | docker_cli | go-build | keine fehlenden Adapter-Dateien |
| Compose | compose | go-build | keine fehlenden Adapter-Dateien |
| Buildx | buildx | go-build | keine fehlenden Adapter-Dateien |
| BuildKit | buildkit | go-build | keine fehlenden Adapter-Dateien |
| Hadolint | hadolint | haskell-build | keine fehlenden Adapter-Dateien |
| Setup Buildx Action | setup_buildx_action | workflow-package | keine fehlenden Adapter-Dateien |
| Build Push Action | build_push_action | workflow-package | keine fehlenden Adapter-Dateien |
| Login Action | login_action | workflow-package | keine fehlenden Adapter-Dateien |
| kubectl | kubectl | native-build | keine fehlenden Adapter-Dateien |
| kind | kind | go-build | keine fehlenden Adapter-Dateien |
| Helm | helm | go-build | keine fehlenden Adapter-Dateien |
| Kustomize | kustomize | go-build | keine fehlenden Adapter-Dateien |
| Kubeconform | kubeconform | existing | keine fehlenden Adapter-Dateien |
| KubeLinter | kubelinter | existing | keine fehlenden Adapter-Dateien |
| Skaffold | skaffold | go-build | keine fehlenden Adapter-Dateien |
| Argo CD | argocd_cli | go-build | keine fehlenden Adapter-Dateien |
| Flux | flux_cli | go-build | keine fehlenden Adapter-Dateien |
| Terraform | terraform | go-build | keine fehlenden Adapter-Dateien |
| Terraform Language Server | terraform_language_server | go-build | keine fehlenden Adapter-Dateien |
| TFLint | tflint | existing | keine fehlenden Adapter-Dateien |
| Checkov | checkov | python-package | keine fehlenden Adapter-Dateien |
| terraform-docs | terraform_docs | existing | keine fehlenden Adapter-Dateien |
| Terratest | terratest | go-library | keine fehlenden Adapter-Dateien |
| Setup Terraform Action | setup_terraform_action | workflow-package | keine fehlenden Adapter-Dateien |

## Dokumentierte GitHub-Quellen

Vollstaendige Liste der erkannten Repository-URLs. Bis zu drei Fundstellen pro Quelle;
mit --format json sind alle Fundstellen verfuegbar. Leere Zuordnung ist keine Installationszusage.

| Quelle | Zuordnung | Dokumentationsfundstellen |
|---|---|---|
| [0xerr0r/blocky](https://github.com/0xerr0r/blocky) | Registry: blocky | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [2noise/chattts](https://github.com/2noise/chattts) | Registry: chattts | [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/chattts.md](tools/chattts.md) |
| [aboutcode-org/scancode-toolkit](https://github.com/aboutcode-org/scancode-toolkit) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md) |
| [ace-step/ace-step-1.5](https://github.com/ace-step/ace-step-1.5) | Registry: ace_step_15 | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/ace-step-15.md](tools/ace-step-15.md) |
| [actions/cache](https://github.com/actions/cache) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [actions/checkout](https://github.com/actions/checkout) | 62er-Katalog: actions_checkout | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [actions/runner](https://github.com/actions/runner) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [actions/setup-go](https://github.com/actions/setup-go) | 62er-Katalog: actions_setup_go | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-ci-cd-deployment.md](tutorials/manus-ci-cd-deployment.md) |
| [actions/upload-artifact](https://github.com/actions/upload-artifact) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [activepieces/activepieces](https://github.com/activepieces/activepieces) | Menue: Activepieces; Registry: activepieces | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md) |
| [adam-cad/cadam](https://github.com/adam-cad/cadam) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [adguardteam/adguardhome](https://github.com/adguardteam/adguardhome) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_INDEX.md](TOOL_INDEX.md) |
| [adrienverge/yamllint](https://github.com/adrienverge/yamllint) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [agronholm/anyio](https://github.com/agronholm/anyio) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [ai4finance-foundation/fingpt](https://github.com/ai4finance-foundation/fingpt) | Menue: FinGPT | [docs/CUSTOM_SOURCES_AND_BUILDS.md](CUSTOM_SOURCES_AND_BUILDS.md) |
| [aidadsp/aida-x](https://github.com/aidadsp/aida-x) | Registry: aida_x | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/media_studio/MIDI_SAMPLING_GUIDE.md](media_studio/MIDI_SAMPLING_GUIDE.md) |
| [aider-ai/aider](https://github.com/aider-ai/aider) | Menue: Aider; Registry: aider | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [airbytehq/abctl](https://github.com/airbytehq/abctl) | Menue: Airbyte | [docs/AIRBYTE_ABCTL_KUBERNETES_NOTES.md](AIRBYTE_ABCTL_KUBERNETES_NOTES.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [airbytehq/airbyte](https://github.com/airbytehq/airbyte) | Menue: Airbyte | [docs/AIRBYTE_ABCTL_KUBERNETES_NOTES.md](AIRBYTE_ABCTL_KUBERNETES_NOTES.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [all-hands-ai/openhands](https://github.com/all-hands-ai/openhands) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [anchore/grype](https://github.com/anchore/grype) | Menue: Grype; Registry: grype | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/GRYPE_INSTALLATION_NOTES.md](GRYPE_INSTALLATION_NOTES.md) |
| [anchore/syft](https://github.com/anchore/syft) | Menue: Syft; Registry: syft | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/SYFT_INSTALLATION_NOTES.md](SYFT_INSTALLATION_NOTES.md) |
| [anil-matcha/open-generative-ai](https://github.com/anil-matcha/open-generative-ai) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md](Profile/OpenHiggsStack_AI_Cinema_Studio.md) |
| [anjok07/ultimatevocalremovergui](https://github.com/anjok07/ultimatevocalremovergui) | Registry: uvr5 | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md) |
| [anomalyco/opencode](https://github.com/anomalyco/opencode) | Registry: opencode | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/agentic-coding.md](tools/agentic-coding.md), [docs/tools/claude-code.md](tools/claude-code.md) |
| [anthropics/anthropic-cli](https://github.com/anthropics/anthropic-cli) | Registry: anthropic_cli | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tools/anthropic-cli.md](tools/anthropic-cli.md) |
| [anthropics/claude-code](https://github.com/anthropics/claude-code) | Registry: claude_code | [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md), [docs/agents/coding-agent-profiles.md](agents/coding-agent-profiles.md), [docs/tools/anthropic-cli.md](tools/anthropic-cli.md) |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [anthropics/skills](https://github.com/anthropics/skills) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [apache/tika](https://github.com/apache/tika) | Menue: Apache_Tika; Registry: apache_tika | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [aquasecurity/trivy](https://github.com/aquasecurity/trivy) | Registry: trivy | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [argoproj/argo-cd](https://github.com/argoproj/argo-cd) | 62er-Katalog: argocd_cli; Menue: ArgoCD_CLI | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [argoproj/argo-workflows](https://github.com/argoproj/argo-workflows) | Registry: argo_workflows | [docs/tools/queue/README.md](tools/queue/README.md) |
| [asg017/sqlite-vss](https://github.com/asg017/sqlite-vss) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [asterisk/asterisk](https://github.com/asterisk/asterisk) | Registry: asterisk | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [astral-sh/ruff](https://github.com/astral-sh/ruff) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [astral-sh/ruff-action](https://github.com/astral-sh/ruff-action) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [astral-sh/uv](https://github.com/astral-sh/uv) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [asvspoof-challenge/asvspoof5](https://github.com/asvspoof-challenge/asvspoof5) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md) |
| [audacity/audacity](https://github.com/audacity/audacity) | Registry: audacity | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md) |
| [authelia/authelia](https://github.com/authelia/authelia) | Keine direkte Zuordnung; manuell pruefen | [docs/AUTH_OIDC_HELM_SECRETS_GUIDE.md](AUTH_OIDC_HELM_SECRETS_GUIDE.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [automatic1111/stable-diffusion-webui](https://github.com/automatic1111/stable-diffusion-webui) | Menue: Stable_Diffusion_WebUI; Registry: automatic1111 | [docs/Profil/Interior_RoomGPT_Designer.md](Profil/Interior_RoomGPT_Designer.md), [docs/STABLE_DIFFUSION_WEBUI_INSTALLATION_NOTES.md](STABLE_DIFFUSION_WEBUI_INSTALLATION_NOTES.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [axolotl-ai-cloud/axolotl](https://github.com/axolotl-ai-cloud/axolotl) | Menue: Axolotl | [docs/Profil/LLM-Builder.doc.md](Profil/LLM-Builder.doc.md) |
| [babelcloud/gbox](https://github.com/babelcloud/gbox) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/gbox.md](tools/gbox.md) |
| [backstage/backstage](https://github.com/backstage/backstage) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [bats-core/bats-core](https://github.com/bats-core/bats-core) | 62er-Katalog: bats_core; Registry: bats_core | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/language-quality-tools.md](tools/language-quality-tools.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [berriai/litellm](https://github.com/berriai/litellm) | Menue: LiteLLM; Registry: litellm | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tutorials/qwen-desktop-claude-local.md](tutorials/qwen-desktop-claude-local.md) |
| [bheisler/criterion.rs](https://github.com/bheisler/criterion.rs) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [bigskysoftware/htmx](https://github.com/bigskysoftware/htmx) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [biomejs/biome](https://github.com/biomejs/biome) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [biomejs/setup-biome](https://github.com/biomejs/setup-biome) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [blender/blender](https://github.com/blender/blender) | Menue: Blender; Registry: blender | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [bminor/bash](https://github.com/bminor/bash) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [bogdanp/dramatiq](https://github.com/bogdanp/dramatiq) | Registry: dramatiq | [docs/tools/queue/README.md](tools/queue/README.md) |
| [borgbackup/borg](https://github.com/borgbackup/borg) | Registry: borgbackup | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [bridgecrewio/checkov](https://github.com/bridgecrewio/checkov) | 62er-Katalog: checkov | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [browserless/browserless](https://github.com/browserless/browserless) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md) |
| [browsermcp/mcp](https://github.com/browsermcp/mcp) | Registry: browsermcp | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [caddyserver/caddy](https://github.com/caddyserver/caddy) | Registry: caddy | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [cadquery/cadquery](https://github.com/cadquery/cadquery) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [calesthio/openmontage](https://github.com/calesthio/openmontage) | Menue: OpenMontage; Registry: openmontage | [docs/tools/openmontage.md](tools/openmontage.md) |
| [canonical/microk8s](https://github.com/canonical/microk8s) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [catchorg/catch2](https://github.com/catchorg/catch2) | 62er-Katalog: catch2 | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [celery/celery](https://github.com/celery/celery) | Registry: celery | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/tools/queue/README.md](tools/queue/README.md) |
| [cheahjs/free-llm-api-resources](https://github.com/cheahjs/free-llm-api-resources) | Keine direkte Zuordnung; manuell pruefen | [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md), [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md) |
| [chroma-core/chroma](https://github.com/chroma-core/chroma) | Registry: chromadb | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md) |
| [city96/comfyui-gguf](https://github.com/city96/comfyui-gguf) | Registry: comfyui_gguf | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md), [docs/tools/comfyui-gguf.md](tools/comfyui-gguf.md) |
| [clap-rs/clap](https://github.com/clap-rs/clap) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [cli/cli](https://github.com/cli/cli) | Menue: GitHub_CLI | [docs/SETUP_MEMORY.md](SETUP_MEMORY.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [cline/cline](https://github.com/cline/cline) | Registry: cline | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md), [docs/tools/cline.md](tools/cline.md) |
| [cloudflare/cloudflared](https://github.com/cloudflare/cloudflared) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [coleam00/local-ai-packaged](https://github.com/coleam00/local-ai-packaged) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [colinhacks/zod](https://github.com/colinhacks/zod) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [comfy-org/comfyui](https://github.com/comfy-org/comfyui) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md](Profile/OpenHiggsStack_AI_Cinema_Studio.md), [docs/Profile/Video_Generation_ComfyUI_Wan.md](Profile/Video_Generation_ComfyUI_Wan.md), [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [comfyanonymous/comfyui](https://github.com/comfyanonymous/comfyui) | Menue: ComfyUI; Registry: comfyui | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [containers/podman](https://github.com/containers/podman) | Registry: podman | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [continuedev/continue](https://github.com/continuedev/continue) | Menue: Continue_Dev; Registry: continue_dev | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [conway-research/automaton](https://github.com/conway-research/automaton) | Registry: automaton | [docs/AGENTIC_CODING_GUIDE.md](AGENTIC_CODING_GUIDE.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/_API-Keys/PROVIDER_KEY_CATALOG.md](_API-Keys/PROVIDER_KEY_CATALOG.md) |
| [coqui-ai/tts](https://github.com/coqui-ai/tts) | Registry: coqui_tts | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [coveragepy/coveragepy](https://github.com/coveragepy/coveragepy) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [cpp-best-practices/cmake_template](https://github.com/cpp-best-practices/cmake_template) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [cpp-best-practices/cppbestpractices](https://github.com/cpp-best-practices/cppbestpractices) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [crewaiinc/crewai](https://github.com/crewaiinc/crewai) | Registry: crewai | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tools/agentic-coding.md](tools/agentic-coding.md) |
| [crowdsecurity/crowdsec](https://github.com/crowdsecurity/crowdsec) | Registry: crowdsec | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [cs01/pygdbmi](https://github.com/cs01/pygdbmi) | Registry: embedded_debug_hil | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/embedded-debug-hil.md](tools/embedded-debug-hil.md) |
| [data-privacy-stack/presidio](https://github.com/data-privacy-stack/presidio) | Keine direkte Zuordnung; manuell pruefen | [docs/legal/RAG_COMPLIANCE_ARCHITECTURE.md](legal/RAG_COMPLIANCE_ARCHITECTURE.md) |
| [dbt-labs/dbt](https://github.com/dbt-labs/dbt) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [dbt-labs/dbt-core](https://github.com/dbt-labs/dbt-core) | 62er-Katalog: dbt; Menue: dbt; Registry: dbt | [docs/DBT_INSTALLATION_NOTES.md](DBT_INSTALLATION_NOTES.md), [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [deepinsight/insightface](https://github.com/deepinsight/insightface) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [deepseek-ai/deepseek-r1](https://github.com/deepseek-ai/deepseek-r1) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md) |
| [deepset-ai/haystack](https://github.com/deepset-ai/haystack) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [deepspeedai/deepspeed](https://github.com/deepspeedai/deepspeed) | Registry: deepspeed | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/memory/UNIFIED_MEMORY_AND_OFFLOADING.md](memory/UNIFIED_MEMORY_AND_OFFLOADING.md) |
| [deinname/fingpt](https://github.com/deinname/fingpt) | Keine direkte Zuordnung; manuell pruefen | [docs/CUSTOM_SOURCES_AND_BUILDS.md](CUSTOM_SOURCES_AND_BUILDS.md) |
| [denoland/deno](https://github.com/denoland/deno) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [derailed/k9s](https://github.com/derailed/k9s) | Menue: K9s; Registry: k9s | [docs/K9S_INSTALLATION_NOTES.md](K9S_INSTALLATION_NOTES.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [devanasolver/awesome-free-llm-apis](https://github.com/devanasolver/awesome-free-llm-apis) | Keine direkte Zuordnung; manuell pruefen | [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md), [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md) |
| [django/django](https://github.com/django/django) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [docker-library/docs](https://github.com/docker-library/docs) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [docker/awesome-compose](https://github.com/docker/awesome-compose) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [docker/build-push-action](https://github.com/docker/build-push-action) | 62er-Katalog: build_push_action | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [docker/buildx](https://github.com/docker/buildx) | 62er-Katalog: buildx; Menue: AutoGPT | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [docker/cli](https://github.com/docker/cli) | 62er-Katalog: docker_cli | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [docker/compose](https://github.com/docker/compose) | 62er-Katalog: compose | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [docker/login-action](https://github.com/docker/login-action) | 62er-Katalog: login_action | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [docker/mcp-registry](https://github.com/docker/mcp-registry) | Registry: docker_mcp_registry | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action) | 62er-Katalog: setup_buildx_action | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [docling-project/docling](https://github.com/docling-project/docling) | Menue: Docling; Registry: docling | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [dominikh/go-tools](https://github.com/dominikh/go-tools) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [dotenv-linter/dotenv-linter](https://github.com/dotenv-linter/dotenv-linter) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [dtolnay/anyhow](https://github.com/dtolnay/anyhow) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [dtolnay/rust-toolchain](https://github.com/dtolnay/rust-toolchain) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [dtolnay/thiserror](https://github.com/dtolnay/thiserror) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [duckdb/duckdb](https://github.com/duckdb/duckdb) | Menue: DuckDB; Registry: duckdb | [docs/DUCKDB_INSTALLATION_NOTES.md](DUCKDB_INSTALLATION_NOTES.md) |
| [dwhr-pi/content-multiplier](https://github.com/dwhr-pi/content-multiplier) | Registry: ai_content_multiplier | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [dwhr-pi/mynexcloud-for-android](https://github.com/dwhr-pi/mynexcloud-for-android) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/mynextcloud/README.md](tools/mynextcloud/README.md), [docs/tools/mynextcloud/fork_review.md](tools/mynextcloud/fork_review.md), [docs/tools/mynextcloud/install_android_build.md](tools/mynextcloud/install_android_build.md) |
| [dwhr-pi/mynextcloud-server](https://github.com/dwhr-pi/mynextcloud-server) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/mynextcloud/README.md](tools/mynextcloud/README.md), [docs/tools/mynextcloud/fork_review.md](tools/mynextcloud/fork_review.md), [docs/tools/mynextcloud/install_server_vps.md](tools/mynextcloud/install_server_vps.md) |
| [dwhr-pi/vps-_kubernate-_ollama_openclaw_installation](https://github.com/dwhr-pi/vps-_kubernate-_ollama_openclaw_installation) | Registry: karaoke_formats; Registry: personnel_documents | [docs/FORK_SUPPORT_AND_UPSTREAM_GOVERNANCE.md](FORK_SUPPORT_AND_UPSTREAM_GOVERNANCE.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/PRIVATE_REPO_GUIDE.md](PRIVATE_REPO_GUIDE.md) |
| [earthtojake/text-to-cad](https://github.com/earthtojake/text-to-cad) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [electron/electron](https://github.com/electron/electron) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [encode/httpx](https://github.com/encode/httpx) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [encode/starlette](https://github.com/encode/starlette) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [encode/uvicorn](https://github.com/encode/uvicorn) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [eslint/eslint](https://github.com/eslint/eslint) | 62er-Katalog: eslint | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [expressjs/express](https://github.com/expressjs/express) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [facebook/react](https://github.com/facebook/react) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [facebookresearch/audiocraft](https://github.com/facebookresearch/audiocraft) | Menue: MusicGen; Registry: audiogen; Registry: musicgen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/MUSICGEN_INSTALLATION_NOTES.md](MUSICGEN_INSTALLATION_NOTES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md) |
| [facebookresearch/audioseal](https://github.com/facebookresearch/audioseal) | Registry: audioseal | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md), [docs/tools/audioseal.md](tools/audioseal.md) |
| [facebookresearch/demucs](https://github.com/facebookresearch/demucs) | Registry: demucs | [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md), [docs/tutorials/chatgpt-development-tooling.md](tutorials/chatgpt-development-tooling.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [fail2ban/fail2ban](https://github.com/fail2ban/fail2ban) | Registry: fail2ban | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [fal-ai/fal](https://github.com/fal-ai/fal) | Registry: fal_client | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/tools/fal-client.md](tools/fal-client.md) |
| [falcosecurity/falco](https://github.com/falcosecurity/falco) | Registry: falco | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [fanghua-yu/supir](https://github.com/fanghua-yu/supir) | Registry: supir | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md), [docs/tools/supir.md](tools/supir.md) |
| [fastapi/fastapi](https://github.com/fastapi/fastapi) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [fastapi/sqlmodel](https://github.com/fastapi/sqlmodel) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [fastify/fastify](https://github.com/fastify/fastify) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [ffmpeg/ffmpeg](https://github.com/ffmpeg/ffmpeg) | Menue: FFmpeg; Registry: ffmpeg | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [filosottile/age](https://github.com/filosottile/age) | Registry: age | [docs/ENV_VAULT.md](ENV_VAULT.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [finrandojin/alexandria-audiobook](https://github.com/finrandojin/alexandria-audiobook) | Registry: alexandria_audiobook | [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/alexandria-audiobook.md](tools/alexandria-audiobook.md) |
| [fishaudio/fish-speech](https://github.com/fishaudio/fish-speech) | Registry: fish_speech | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [flowiseai/flowise](https://github.com/flowiseai/flowise) | Menue: Flowise; Registry: flowise | [docs/FLOWISE_INSTALLATION_NOTES.md](FLOWISE_INSTALLATION_NOTES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md) |
| [flowiseai/flowisechatbot](https://github.com/flowiseai/flowisechatbot) | Keine direkte Zuordnung; manuell pruefen | [docs/FLOWISE_INSTALLATION_NOTES.md](FLOWISE_INSTALLATION_NOTES.md) |
| [flowtyone/comfyui-flowty-triposr](https://github.com/flowtyone/comfyui-flowty-triposr) | Keine direkte Zuordnung; manuell pruefen | [docs/AI_3D_STUDIO.md](AI_3D_STUDIO.md) |
| [fluxcd/flux2](https://github.com/fluxcd/flux2) | 62er-Katalog: flux_cli; Menue: Flux_CLI; Registry: flux_cli | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [flyway/flyway](https://github.com/flyway/flyway) | 62er-Katalog: flyway | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [franzdiebold/gen-ai-template](https://github.com/franzdiebold/gen-ai-template) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [freeaihub/ai-lab](https://github.com/freeaihub/ai-lab) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [freecad/freecad](https://github.com/freecad/freecad) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [freellms/awesome-freellm-apis](https://github.com/freellms/awesome-freellm-apis) | Keine direkte Zuordnung; manuell pruefen | [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md), [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md) |
| [fudan-generative-vision/hallo2](https://github.com/fudan-generative-vision/hallo2) | Registry: hallo2 | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/VIDEO_AVATAR_SYSTEMS.md](VIDEO_AVATAR_SYSTEMS.md) |
| [gcc-mirror/gcc](https://github.com/gcc-mirror/gcc) | 62er-Katalog: gcc_github_mirror | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [geopandas/geopandas](https://github.com/geopandas/geopandas) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [getsops/sops](https://github.com/getsops/sops) | Registry: sops | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp) | Registry: llama_cpp | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [ggerganov/whisper.cpp](https://github.com/ggerganov/whisper.cpp) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) | Menue: Llama_CPP_Toolchain | [docs/Profil/LLM-Builder.doc.md](Profil/LLM-Builder.doc.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/memory/UNIFIED_MEMORY_AND_OFFLOADING.md](memory/UNIFIED_MEMORY_AND_OFFLOADING.md) |
| [ggml-org/whisper.cpp](https://github.com/ggml-org/whisper.cpp) | Menue: Whisper_CPP | [docs/WHISPER_CPP_INSTALLATION_NOTES.md](WHISPER_CPP_INSTALLATION_NOTES.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [gin-gonic/gin](https://github.com/gin-gonic/gin) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [git/git](https://github.com/git/git) | Registry: git | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) | Menue: Gitleaks; Registry: gitleaks | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [giuliano-t/openai-to-freecad-workflow](https://github.com/giuliano-t/openai-to-freecad-workflow) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [go-chi/chi](https://github.com/go-chi/chi) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [go-delve/delve](https://github.com/go-delve/delve) | 62er-Katalog: delve; Registry: delve | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [go-gorm/gorm](https://github.com/go-gorm/gorm) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [goauthentik/authentik](https://github.com/goauthentik/authentik) | Keine direkte Zuordnung; manuell pruefen | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [godotengine/godot](https://github.com/godotengine/godot) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/GameDev_3D_Studio.md](Profile/GameDev_3D_Studio.md) |
| [godotengine/godot-demo-projects](https://github.com/godotengine/godot-demo-projects) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/GameDev_3D_Studio.md](Profile/GameDev_3D_Studio.md) |
| [gofiber/fiber](https://github.com/gofiber/fiber) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [golang-migrate/migrate](https://github.com/golang-migrate/migrate) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [golang-standards/project-layout](https://github.com/golang-standards/project-layout) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [golang-standards/project-template](https://github.com/golang-standards/project-template) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [golang/go](https://github.com/golang/go) | 62er-Katalog: go | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [golang/tools](https://github.com/golang/tools) | 62er-Katalog: golang_tools; Registry: gopls | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [golangci/golangci-lint](https://github.com/golangci/golangci-lint) | 62er-Katalog: golangci_lint; Registry: golangci_lint | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [golangci/golangci-lint-action](https://github.com/golangci/golangci-lint-action) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | Registry: gemini_cli | [docs/agents/coding-agent-profiles.md](agents/coding-agent-profiles.md), [docs/tools/claude-code.md](tools/claude-code.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [google-research/frame-interpolation](https://github.com/google-research/frame-interpolation) | Registry: film | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md), [docs/tools/film.md](tools/film.md) |
| [google/cadvisor](https://github.com/google/cadvisor) | Menue: cAdvisor | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [google/googletest](https://github.com/google/googletest) | 62er-Katalog: googletest | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [googleapis/python-genai](https://github.com/googleapis/python-genai) | Registry: veo_api | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/tools/veo-api.md](tools/veo-api.md) |
| [googlecontainertools/skaffold](https://github.com/googlecontainertools/skaffold) | 62er-Katalog: skaffold | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [gradio-app/gradio](https://github.com/gradio-app/gradio) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [grafana/grafana](https://github.com/grafana/grafana) | Registry: grafana | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [grafana/loki](https://github.com/grafana/loki) | Registry: loki; Registry: promtail | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [grafana/tempo](https://github.com/grafana/tempo) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [grpc/grpc-go](https://github.com/grpc/grpc-go) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [gruntwork-io/terratest](https://github.com/gruntwork-io/terratest) | 62er-Katalog: terratest | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [guoyww/animatediff](https://github.com/guoyww/animatediff) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md) |
| [hadolint/hadolint](https://github.com/hadolint/hadolint) | 62er-Katalog: hadolint; Menue: Hadolint | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [haoheliu/audioldm2](https://github.com/haoheliu/audioldm2) | Registry: audioldm2 | [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/audioldm2.md](tools/audioldm2.md) |
| [hashicorp/setup-terraform](https://github.com/hashicorp/setup-terraform) | 62er-Katalog: setup_terraform_action | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [hashicorp/terraform](https://github.com/hashicorp/terraform) | 62er-Katalog: terraform | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [hashicorp/terraform-ls](https://github.com/hashicorp/terraform-ls) | 62er-Katalog: terraform_language_server | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [helm/helm](https://github.com/helm/helm) | 62er-Katalog: helm; Menue: Helm; Registry: helm | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/HELM_INSTALLATION_NOTES.md](HELM_INSTALLATION_NOTES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [henrygd/beszel](https://github.com/henrygd/beszel) | Registry: beszel | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [hexgrad/kokoro](https://github.com/hexgrad/kokoro) | Registry: kokoro_tts | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [heygen-com/hyperframes](https://github.com/heygen-com/hyperframes) | Menue: HyperFrames; Registry: hyperframes | [docs/tools/hyperframes.md](tools/hyperframes.md), [docs/tools/openmontage.md](tools/openmontage.md) |
| [higgsfield-ai/cli](https://github.com/higgsfield-ai/cli) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md](Profile/OpenHiggsStack_AI_Cinema_Studio.md) |
| [higgsfield-ai/skills](https://github.com/higgsfield-ai/skills) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md](Profile/OpenHiggsStack_AI_Cinema_Studio.md) |
| [hiyouga/llama-factory](https://github.com/hiyouga/llama-factory) | Menue: LLaMA_Factory | [docs/Profil/LLM-Builder.doc.md](Profil/LLM-Builder.doc.md) |
| [hpcaitech/open-sora](https://github.com/hpcaitech/open-sora) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md) |
| [huggingface/accelerate](https://github.com/huggingface/accelerate) | Registry: hf_accelerate | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [huggingface/datasets](https://github.com/huggingface/datasets) | Registry: hf_datasets | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md), [docs/tools/hf-datasets.md](tools/hf-datasets.md) |
| [huggingface/diffusers](https://github.com/huggingface/diffusers) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [huggingface/huggingface_hub](https://github.com/huggingface/huggingface_hub) | Registry: hf_hub | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md), [docs/tools/hf-hub.md](tools/hf-hub.md) |
| [huggingface/text-generation-inference](https://github.com/huggingface/text-generation-inference) | Registry: tgi | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/tools/tgi.md](tools/tgi.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [huggingface/transformers](https://github.com/huggingface/transformers) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [huginn/huginn](https://github.com/huginn/huginn) | Menue: Huginn; Registry: huginn | [docs/HUGINN_REPO_REF_GUIDE.md](HUGINN_REPO_REF_GUIDE.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/_API-Keys/API_KEY_GUIDE.md](_API-Keys/API_KEY_GUIDE.md) |
| [humanaigc/emo](https://github.com/humanaigc/emo) | Registry: emo_avatar | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/VIDEO_AVATAR_SYSTEMS.md](VIDEO_AVATAR_SYSTEMS.md) |
| [hypothesisworks/hypothesis](https://github.com/hypothesisworks/hypothesis) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [hzwer/eccv2022-rife](https://github.com/hzwer/eccv2022-rife) | Menue: RIFE; Registry: rife | [docs/RIFE_INSTALLATION_NOTES.md](RIFE_INSTALLATION_NOTES.md) |
| [iejmac/video2dataset](https://github.com/iejmac/video2dataset) | Registry: video2dataset | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md) |
| [infiniflow/ragflow](https://github.com/infiniflow/ragflow) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [infisical/infisical](https://github.com/infisical/infisical) | Registry: infisical | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [invoke-ai/invokeai](https://github.com/invoke-ai/invokeai) | Menue: InvokeAI; Registry: invokeai | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [jackc/pgservicefile](https://github.com/jackc/pgservicefile) | Keine direkte Zuordnung; manuell pruefen | [docs/CLAWBAKE_INTEGRATION_GUIDE.md](CLAWBAKE_INTEGRATION_GUIDE.md), [docs/SETUP_MEMORY.md](SETUP_MEMORY.md) |
| [jackc/pgx](https://github.com/jackc/pgx) | Keine direkte Zuordnung; manuell pruefen | [docs/CLAWBAKE_INTEGRATION_GUIDE.md](CLAWBAKE_INTEGRATION_GUIDE.md) |
| [jakeschincariol/youtube-agent-skill](https://github.com/jakeschincariol/youtube-agent-skill) | Registry: youtube_agent_skill | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tools/youtube-agent-skill.md](tools/youtube-agent-skill.md) |
| [janhq/jan](https://github.com/janhq/jan) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [jestjs/jest](https://github.com/jestjs/jest) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [jitsi/jitsi-meet](https://github.com/jitsi/jitsi-meet) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/webinar-stack.md](tutorials/webinar-stack.md) |
| [jqlang/jq](https://github.com/jqlang/jq) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [juanfont/headscale](https://github.com/juanfont/headscale) | Registry: headscale | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [jub0t/concat](https://github.com/jub0t/concat) | Menue: Concat; Registry: concat | [docs/tools/concat.md](tools/concat.md) |
| [jupyter/notebook](https://github.com/jupyter/notebook) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [jupyterlab/jupyterlab](https://github.com/jupyterlab/jupyterlab) | Menue: JupyterLab; Registry: jupyterlab | [docs/JUPYTERLAB_INSTALLATION_NOTES.md](JUPYTERLAB_INSTALLATION_NOTES.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-workflow.md](tutorials/manus-development-workflow.md) |
| [justdubit/just-dub-it](https://github.com/justdubit/just-dub-it) | Registry: just_dub_it | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/just-dub-it.md](tools/just-dub-it.md) |
| [justvugg/colibri](https://github.com/justvugg/colibri) | Registry: colibri | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tools/colibri.md](tools/colibri.md) |
| [k3d-io/k3d](https://github.com/k3d-io/k3d) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [k3s-io/k3s](https://github.com/k3s-io/k3s) | Registry: k3s | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [kijai/comfyui-wanvideowrapper](https://github.com/kijai/comfyui-wanvideowrapper) | Registry: wanvideo_wrapper | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md) |
| [kitware/cmake](https://github.com/kitware/cmake) | 62er-Katalog: cmake | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [klingairesearch/liveportrait](https://github.com/klingairesearch/liveportrait) | Registry: liveportrait | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/VIDEO_AVATAR_SYSTEMS.md](VIDEO_AVATAR_SYSTEMS.md) |
| [kludex/starlette](https://github.com/kludex/starlette) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [kludex/uvicorn](https://github.com/kludex/uvicorn) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [knadh/listmonk](https://github.com/knadh/listmonk) | Registry: listmonk | [docs/tools/webinar-tools.md](tools/webinar-tools.md), [docs/tutorials/webinar-stack.md](tutorials/webinar-stack.md) |
| [koalaman/shellcheck](https://github.com/koalaman/shellcheck) | 62er-Katalog: shellcheck | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [kubernetes-sigs/kind](https://github.com/kubernetes-sigs/kind) | 62er-Katalog: kind | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [kubernetes-sigs/kustomize](https://github.com/kubernetes-sigs/kustomize) | 62er-Katalog: kustomize; Menue: Kustomize; Registry: kustomize | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/KUSTOMIZE_INSTALLATION_NOTES.md](KUSTOMIZE_INSTALLATION_NOTES.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [kubernetes/examples](https://github.com/kubernetes/examples) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [kubernetes/kubectl](https://github.com/kubernetes/kubectl) | 62er-Katalog: kubectl | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [kubernetes/kubernetes](https://github.com/kubernetes/kubernetes) | Menue: Kubectl; Registry: kubectl | [docs/KUBECTL_INSTALLATION_NOTES.md](KUBECTL_INSTALLATION_NOTES.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [kyutai-labs/moshi](https://github.com/kyutai-labs/moshi) | Registry: moshi | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/moshi.md](tools/moshi.md) |
| [kyverno/kyverno](https://github.com/kyverno/kyverno) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [labstack/echo](https://github.com/labstack/echo) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [langchain-ai/langchain](https://github.com/langchain-ai/langchain) | Registry: langchain | [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md), [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [langchain-ai/langchainjs](https://github.com/langchain-ai/langchainjs) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph) | Registry: langgraph | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tools/agentic-coding.md](tools/agentic-coding.md) |
| [langfuse/langfuse](https://github.com/langfuse/langfuse) | Menue: Langfuse; Registry: langfuse | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [langgenius/dify](https://github.com/langgenius/dify) | Keine direkte Zuordnung; manuell pruefen | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md) |
| [lightricks/ltx-2](https://github.com/lightricks/ltx-2) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/just-dub-it.md](tools/just-dub-it.md) |
| [lightricks/ltx-video](https://github.com/lightricks/ltx-video) | Registry: ltx_video | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [lincolnloop/python-qrcode](https://github.com/lincolnloop/python-qrcode) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [liquibase/liquibase](https://github.com/liquibase/liquibase) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [livekit/livekit](https://github.com/livekit/livekit) | Registry: livekit | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [lllyasviel/controlnet](https://github.com/lllyasviel/controlnet) | Keine direkte Zuordnung; manuell pruefen | [docs/Profil/Interior_RoomGPT_Designer.md](Profil/Interior_RoomGPT_Designer.md) |
| [lllyasviel/stable-diffusion-webui-forge](https://github.com/lllyasviel/stable-diffusion-webui-forge) | Menue: Stable_Diffusion_WebUI_Forge; Registry: stable_diffusion_webui_forge | [docs/FORGE_INSTALLATION_NOTES.md](FORGE_INSTALLATION_NOTES.md) |
| [llvm/llvm-project](https://github.com/llvm/llvm-project) | 62er-Katalog: llvm | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [lobehub/lobe-chat](https://github.com/lobehub/lobe-chat) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [louislam/uptime-kuma](https://github.com/louislam/uptime-kuma) | Menue: Uptime_Kuma | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [m-bain/whisperx](https://github.com/m-bain/whisperx) | Registry: whisperx | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/whisperx.md](tools/whisperx.md) |
| [mariadb/server](https://github.com/mariadb/server) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [marp-team/marp-cli](https://github.com/marp-team/marp-cli) | Registry: marp | [docs/tools/webinar-tools.md](tools/webinar-tools.md), [docs/tutorials/webinar-stack.md](tutorials/webinar-stack.md) |
| [mastra-ai/mastra](https://github.com/mastra-ai/mastra) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [matplotlib/matplotlib](https://github.com/matplotlib/matplotlib) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [mautic/mautic](https://github.com/mautic/mautic) | Registry: mautic | [docs/tools/webinar-tools.md](tools/webinar-tools.md), [docs/tutorials/webinar-stack.md](tutorials/webinar-stack.md) |
| [medahmedkrichen/vidubb](https://github.com/medahmedkrichen/vidubb) | Registry: vidubb | [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/vidubb.md](tools/vidubb.md) |
| [meilisearch/meilisearch](https://github.com/meilisearch/meilisearch) | Menue: Meilisearch | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [mendableai/firecrawl](https://github.com/mendableai/firecrawl) | Keine direkte Zuordnung; manuell pruefen | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [mermaid-js/mermaid](https://github.com/mermaid-js/mermaid) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [mesonbuild/meson](https://github.com/mesonbuild/meson) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [microsoft/agent-framework](https://github.com/microsoft/agent-framework) | Registry: agent_framework | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/agentic-coding.md](tools/agentic-coding.md), [docs/tools/microsoft-agent-framework.md](tools/microsoft-agent-framework.md) |
| [microsoft/autogen](https://github.com/microsoft/autogen) | Registry: autogen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/tools/agentic-coding.md](tools/agentic-coding.md) |
| [microsoft/playwright](https://github.com/microsoft/playwright) | 62er-Katalog: playwright | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [microsoft/playwright-github-action](https://github.com/microsoft/playwright-github-action) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [microsoft/presidio](https://github.com/microsoft/presidio) | Keine direkte Zuordnung; manuell pruefen | [docs/legal/RAG_COMPLIANCE_ARCHITECTURE.md](legal/RAG_COMPLIANCE_ARCHITECTURE.md) |
| [microsoft/pylance-release](https://github.com/microsoft/pylance-release) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [microsoft/pyright](https://github.com/microsoft/pyright) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [microsoft/typescript](https://github.com/microsoft/typescript) | 62er-Katalog: typescript | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [microsoft/typescript-node-starter](https://github.com/microsoft/typescript-node-starter) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [microsoft/vscode](https://github.com/microsoft/vscode) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [milvus-io/milvus](https://github.com/milvus-io/milvus) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [minio/minio](https://github.com/minio/minio) | Menue: MinIO; Registry: minio | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [mirror/make](https://github.com/mirror/make) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [mkdocs/mkdocs](https://github.com/mkdocs/mkdocs) | Registry: mkdocs | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [ml-explore/mlx-examples](https://github.com/ml-explore/mlx-examples) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [mnfst/awesome-free-llm-apis](https://github.com/mnfst/awesome-free-llm-apis) | Keine direkte Zuordnung; manuell pruefen | [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md), [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md) |
| [mobsf/mobile-security-framework-mobsf](https://github.com/mobsf/mobile-security-framework-mobsf) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md) |
| [moby/buildkit](https://github.com/moby/buildkit) | 62er-Katalog: buildkit | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [moby/moby](https://github.com/moby/moby) | Registry: docker | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [modelcontextprotocol/server-filesystem](https://github.com/modelcontextprotocol/server-filesystem) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [modelcontextprotocol/server-git](https://github.com/modelcontextprotocol/server-git) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [modelcontextprotocol/server-postgres](https://github.com/modelcontextprotocol/server-postgres) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [modelcontextprotocol/server-sqlite](https://github.com/modelcontextprotocol/server-sqlite) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | Registry: mcp_browser; Registry: mcp_browser_server; Registry: mcp_fetch; Registry: mcp_fetch_server; Registry: mcp_filesystem; Registry: mcp_filesystem_server; Registry: mcp_git; Registry: mcp_git_server; Registry: mcp_github; Registry: mcp_github_server; Registry: mcp_memory; Registry: mcp_memory_server; Registry: mcp_postgres; Registry: mcp_postgres_server; Registry: mcp_shell; Registry: mcp_shell_server; Registry: mcp_sqlite; Registry: mcp_sqlite_server; Registry: modelcontextprotocol_servers | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [modelscope/data-juicer](https://github.com/modelscope/data-juicer) | Menue: Data_Juicer | [docs/Profil/LLM-Builder.doc.md](Profil/LLM-Builder.doc.md) |
| [modimihir07/agentic-os](https://github.com/modimihir07/agentic-os) | Registry: agentic_os | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/agentic-os.md](tools/agentic-os.md) |
| [morluto/rea](https://github.com/morluto/rea) | Registry: rea | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tools/rea.md](tools/rea.md) |
| [mudler/localai](https://github.com/mudler/localai) | Registry: localai | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [multimodal-art-projection/yue](https://github.com/multimodal-art-projection/yue) | Registry: yue | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/yue.md](tools/yue.md) |
| [mvdan/sh](https://github.com/mvdan/sh) | 62er-Katalog: shfmt; Menue: Shfmt | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [mwaskom/seaborn](https://github.com/mwaskom/seaborn) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [myshell-ai/melotts](https://github.com/myshell-ai/melotts) | Registry: melotts | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [myshell-ai/openvoice](https://github.com/myshell-ai/openvoice) | Registry: openvoice | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [mysql/mysql-server](https://github.com/mysql/mysql-server) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | Menue: n8n; Registry: n8n | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [n8n-io/self-hosted-ai-starter-kit](https://github.com/n8n-io/self-hosted-ai-starter-kit) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [nedbat/coveragepy](https://github.com/nedbat/coveragepy) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [nestjs/nest](https://github.com/nestjs/nest) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [netdata/netdata](https://github.com/netdata/netdata) | Menue: Netdata | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [netflix/void-model](https://github.com/netflix/void-model) | Registry: void_model | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/void-model.md](tools/void-model.md) |
| [neurometricai/clawbake](https://github.com/neurometricai/clawbake) | Menue: Clawbake | [docs/CLAWBAKE_INTEGRATION_GUIDE.md](CLAWBAKE_INTEGRATION_GUIDE.md), [docs/SETUP_MEMORY.md](SETUP_MEMORY.md) |
| [nextcloud/android](https://github.com/nextcloud/android) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/mynextcloud_android.md](Profile/mynextcloud_android.md), [docs/tools/mynextcloud/README.md](tools/mynextcloud/README.md), [docs/tools/mynextcloud/fork_review.md](tools/mynextcloud/fork_review.md) |
| [nextcloud/android-library](https://github.com/nextcloud/android-library) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/mynextcloud/README.md](tools/mynextcloud/README.md), [docs/tools/mynextcloud/fork_review.md](tools/mynextcloud/fork_review.md), [docs/tools/mynextcloud/legal_branding_checklist.md](tools/mynextcloud/legal_branding_checklist.md) |
| [nextcloud/nextcloudpi](https://github.com/nextcloud/nextcloudpi) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/mynextcloud/README.md](tools/mynextcloud/README.md), [docs/tools/mynextcloud/fork_review.md](tools/mynextcloud/fork_review.md) |
| [nextcloud/server](https://github.com/nextcloud/server) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/TOOL_INDEX.md](TOOL_INDEX.md), [docs/tools/mynextcloud/README.md](tools/mynextcloud/README.md) |
| [nextest-rs/nextest](https://github.com/nextest-rs/nextest) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [nicolargo/glances](https://github.com/nicolargo/glances) | Registry: glances | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [nightroman/invoke-build](https://github.com/nightroman/invoke-build) | 62er-Katalog: invoke_build; Registry: invoke_build | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/language-quality-tools.md](tools/language-quality-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [ninja-build/ninja](https://github.com/ninja-build/ninja) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [nnsvs/nnsvs](https://github.com/nnsvs/nnsvs) | Registry: nnsvs | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [node-red/node-red](https://github.com/node-red/node-red) | Registry: node_red | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [nodejs/corepack](https://github.com/nodejs/corepack) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/qwen-code.md](tools/qwen-code.md) |
| [nodejs/node](https://github.com/nodejs/node) | 62er-Katalog: node_js | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-toolchain-check.md](tools/development-toolchain-check.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [nousresearch/hermes-agent](https://github.com/nousresearch/hermes-agent) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/hermes-jarvis-weekend.md](tools/hermes-jarvis-weekend.md), [docs/tools/jarvis-hermes-dashboard.md](tools/jarvis-hermes-dashboard.md) |
| [numpy/numpy](https://github.com/numpy/numpy) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/manus-development-workflow.md](tutorials/manus-development-workflow.md), [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [nutlope/roomgpt](https://github.com/nutlope/roomgpt) | Keine direkte Zuordnung; manuell pruefen | [docs/Profil/Interior_RoomGPT_Designer.md](Profil/Interior_RoomGPT_Designer.md) |
| [nvidia/dcgm](https://github.com/nvidia/dcgm) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-development-tooling.md](tutorials/chatgpt-development-tooling.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [nvm-sh/nvm](https://github.com/nvm-sh/nvm) | Keine direkte Zuordnung; manuell pruefen | [docs/PUPPETEER_INSTALLATION_NOTES.md](PUPPETEER_INSTALLATION_NOTES.md) |
| [obsproject/obs-studio](https://github.com/obsproject/obs-studio) | Registry: obs | [docs/tutorials/webinar-stack.md](tutorials/webinar-stack.md) |
| [ohf-voice/piper1-gpl](https://github.com/ohf-voice/piper1-gpl) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-development-tooling.md](tutorials/chatgpt-development-tooling.md) |
| [ollama/ollama](https://github.com/ollama/ollama) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md) |
| [open-policy-agent/gatekeeper](https://github.com/open-policy-agent/gatekeeper) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [open-telemetry/opentelemetry-collector](https://github.com/open-telemetry/opentelemetry-collector) | Registry: opentelemetry | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [open-webui/open-webui](https://github.com/open-webui/open-webui) | Menue: Open_WebUI; Registry: open_webui | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [openai/codex](https://github.com/openai/codex) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [openai/whisper](https://github.com/openai/whisper) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md) |
| [openbao/openbao](https://github.com/openbao/openbao) | Registry: openbao | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [openclaw/clawbake](https://github.com/openclaw/clawbake) | Keine direkte Zuordnung; manuell pruefen | [docs/CLAWBAKE_INTEGRATION_GUIDE.md](CLAWBAKE_INTEGRATION_GUIDE.md), [docs/SETUP_MEMORY.md](SETUP_MEMORY.md) |
| [openclaw/openclaw](https://github.com/openclaw/openclaw) | Menue: OpenClaw | [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md), [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md) |
| [opencv/opencv](https://github.com/opencv/opencv) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [opendevin/opendevin](https://github.com/opendevin/opendevin) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [openhands/openhands](https://github.com/openhands/openhands) | Menue: OpenHands; Registry: openhands | [docs/tools/agentic-coding.md](tools/agentic-coding.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [openinterpreter/open-interpreter](https://github.com/openinterpreter/open-interpreter) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [openlit/openlit](https://github.com/openlit/openlit) | Menue: OpenLIT | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [openmoss/moss-tts](https://github.com/openmoss/moss-tts) | Registry: moss_tts | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/moss-tts.md](tools/moss-tts.md) |
| [openocd-org/openocd](https://github.com/openocd-org/openocd) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/embedded-debug-hil.md](tools/embedded-debug-hil.md) |
| [openscad/openscad](https://github.com/openscad/openscad) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/CAD_Konstrukteur.md](Profile/CAD_Konstrukteur.md) |
| [opentalker/sadtalker](https://github.com/opentalker/sadtalker) | Registry: sadtalker | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/VIDEO_AVATAR_SYSTEMS.md](VIDEO_AVATAR_SYSTEMS.md) |
| [opentofu/opentofu](https://github.com/opentofu/opentofu) | Menue: OpenTofu | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [openvpi/diffsinger](https://github.com/openvpi/diffsinger) | Registry: diffsinger | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [oven-sh/bun](https://github.com/oven-sh/bun) | Menue: Activepieces | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [paddlepaddle/paddleocr](https://github.com/paddlepaddle/paddleocr) | Registry: paddleocr | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [pallets/flask](https://github.com/pallets/flask) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [pallets/jinja](https://github.com/pallets/jinja) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [pandas-dev/pandas](https://github.com/pandas-dev/pandas) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/manus-development-workflow.md](tutorials/manus-development-workflow.md) |
| [paperless-ngx/paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) | Registry: paperless_ngx | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md) |
| [penpot/penpot](https://github.com/penpot/penpot) | Keine direkte Zuordnung; manuell pruefen | [docs/Profil/Penpot-MCP-Integration.md](Profil/Penpot-MCP-Integration.md), [docs/Profil/UI-UX-Designer-Penpot-AI.md](Profil/UI-UX-Designer-Penpot-AI.md) |
| [penpot/penpot-mcp](https://github.com/penpot/penpot-mcp) | Keine direkte Zuordnung; manuell pruefen | [docs/Profil/Penpot-MCP-Integration.md](Profil/Penpot-MCP-Integration.md), [docs/Profil/UI-UX-Designer-Penpot-AI.md](Profil/UI-UX-Designer-Penpot-AI.md) |
| [pester/pester](https://github.com/pester/pester) | 62er-Katalog: pester | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-toolchain-check.md](tools/development-toolchain-check.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [pgvector/pgvector](https://github.com/pgvector/pgvector) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md) |
| [pi-hole/pi-hole](https://github.com/pi-hole/pi-hole) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [pinokiocomputer/pinokio](https://github.com/pinokiocomputer/pinokio) | Registry: pinokio | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/tools/pinokio.md](tools/pinokio.md) |
| [plachtaa/seed-vc](https://github.com/plachtaa/seed-vc) | Registry: seed_vc | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [plotly/plotly.py](https://github.com/plotly/plotly.py) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [pnpm/pnpm](https://github.com/pnpm/pnpm) | 62er-Katalog: pnpm | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [pola-rs/polars](https://github.com/pola-rs/polars) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [postgres/postgres](https://github.com/postgres/postgres) | 62er-Katalog: postgres | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [powershell/powershell](https://github.com/powershell/powershell) | 62er-Katalog: powershell | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-toolchain-check.md](tools/development-toolchain-check.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [powershell/psscriptanalyzer](https://github.com/powershell/psscriptanalyzer) | 62er-Katalog: psscriptanalyzer | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-toolchain-check.md](tools/development-toolchain-check.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [powershell/vscode-powershell](https://github.com/powershell/vscode-powershell) | 62er-Katalog: vs_code_powershell | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-toolchain-check.md](tools/development-toolchain-check.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [pre-commit/pre-commit](https://github.com/pre-commit/pre-commit) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [prettier/prettier](https://github.com/prettier/prettier) | 62er-Katalog: prettier | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [prisma/orm](https://github.com/prisma/orm) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-development-tooling.md](tutorials/chatgpt-development-tooling.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [prisma/prisma](https://github.com/prisma/prisma) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-development-tooling.md](tutorials/chatgpt-development-tooling.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [prometheus/node_exporter](https://github.com/prometheus/node_exporter) | Menue: Node_Exporter | [docs/NODE_EXPORTER_INSTALLATION_NOTES.md](NODE_EXPORTER_INSTALLATION_NOTES.md) |
| [prometheus/prometheus](https://github.com/prometheus/prometheus) | Registry: prometheus | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) | Menue: Promptfoo; Registry: promptfoo | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/PROMPTFOO_INSTALLATION_NOTES.md](PROMPTFOO_INSTALLATION_NOTES.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md) |
| [protocolbuffers/protobuf](https://github.com/protocolbuffers/protobuf) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [psf/black](https://github.com/psf/black) | Registry: black | [docs/tools/dev-quality.md](tools/dev-quality.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [psf/requests](https://github.com/psf/requests) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [puppeteer/puppeteer](https://github.com/puppeteer/puppeteer) | Registry: puppeteer | [docs/PUPPETEER_INSTALLATION_NOTES.md](PUPPETEER_INSTALLATION_NOTES.md) |
| [py-pdf/pypdf](https://github.com/py-pdf/pypdf) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [pyannote/pyannote-audio](https://github.com/pyannote/pyannote-audio) | Registry: pyannote_audio | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md), [docs/tools/pyannote-audio.md](tools/pyannote-audio.md) |
| [pyca/cryptography](https://github.com/pyca/cryptography) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [pydantic/pydantic](https://github.com/pydantic/pydantic) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [pydantic/pydantic-ai](https://github.com/pydantic/pydantic-ai) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [pydantic/pydantic-settings](https://github.com/pydantic/pydantic-settings) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [pymupdf/pymupdf](https://github.com/pymupdf/pymupdf) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [pyocd/pyocd](https://github.com/pyocd/pyocd) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/embedded-debug-hil.md](tools/embedded-debug-hil.md) |
| [pypa/packaging.python.org](https://github.com/pypa/packaging.python.org) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md) |
| [pypa/pip](https://github.com/pypa/pip) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/manus-development-workflow.md](tutorials/manus-development-workflow.md) |
| [pytest-dev/pytest](https://github.com/pytest-dev/pytest) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [pytest-dev/pytest-cov](https://github.com/pytest-dev/pytest-cov) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [python-openxml/python-docx](https://github.com/python-openxml/python-docx) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [python-pillow/pillow](https://github.com/python-pillow/pillow) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [python/cpython](https://github.com/python/cpython) | Menue: FinRAG; Menue: FinRobot | [docs/FINRAG_INSTALLATION_NOTES.md](FINRAG_INSTALLATION_NOTES.md), [docs/FINROBOT_INSTALLATION_NOTES.md](FINROBOT_INSTALLATION_NOTES.md), [docs/tools/stable-audio-open.md](tools/stable-audio-open.md) |
| [python/mypy](https://github.com/python/mypy) | Registry: mypy | [docs/tools/dev-quality.md](tools/dev-quality.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [pytorch/pytorch](https://github.com/pytorch/pytorch) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [pytorch/torchcodec](https://github.com/pytorch/torchcodec) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/pyannote-audio.md](tools/pyannote-audio.md) |
| [qdrant/qdrant](https://github.com/qdrant/qdrant) | Registry: qdrant | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md) |
| [qwenlm/qwen-code](https://github.com/qwenlm/qwen-code) | Registry: qwen_code; Registry: qwen_desktop | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md), [docs/tools/claude-code.md](tools/claude-code.md) |
| [qwenlm/qwen3-tts](https://github.com/qwenlm/qwen3-tts) | Registry: qwen3_tts | [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/qwen3-tts.md](tools/qwen3-tts.md) |
| [rabbitmq/rabbitmq-server](https://github.com/rabbitmq/rabbitmq-server) | Registry: rabbitmq | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [raffiihza/free-llm-coding-credits](https://github.com/raffiihza/free-llm-coding-credits) | Keine direkte Zuordnung; manuell pruefen | [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md), [docs/_API-Keys/reviews/2026-10-21.md](_API-Keys/reviews/2026-10-21.md) |
| [rclone/rclone](https://github.com/rclone/rclone) | Registry: rclone | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [react/react](https://github.com/react/react) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/manus-development-sources.md](tutorials/manus-development-sources.md), [docs/tutorials/manus-development-workflow.md](tutorials/manus-development-workflow.md) |
| [redis/redis](https://github.com/redis/redis) | Registry: redis | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [reflex-dev/reflex](https://github.com/reflex-dev/reflex) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [remotion-dev/remotion](https://github.com/remotion-dev/remotion) | Menue: Remotion; Registry: remotion | [docs/tools/openmontage.md](tools/openmontage.md), [docs/tools/remotion.md](tools/remotion.md) |
| [renovatebot/renovate](https://github.com/renovatebot/renovate) | Registry: renovate | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [restic/restic](https://github.com/restic/restic) | Registry: restic | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [rhasspy/piper](https://github.com/rhasspy/piper) | Registry: piper | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [rikorose/deepfilternet](https://github.com/rikorose/deepfilternet) | Registry: deepfilternet | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md), [docs/tools/deepfilternet.md](tools/deepfilternet.md) |
| [rq/rq](https://github.com/rq/rq) | Registry: queue_manager; Registry: rq | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/tools/queue/README.md](tools/queue/README.md) |
| [rudrabha/wav2lip](https://github.com/rudrabha/wav2lip) | Registry: wav2lip | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [run-llama/llama_index](https://github.com/run-llama/llama_index) | Registry: llamaindex | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md) |
| [rust-lang/api-guidelines](https://github.com/rust-lang/api-guidelines) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [rust-lang/cargo](https://github.com/rust-lang/cargo) | 62er-Katalog: cargo | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [rust-lang/rust](https://github.com/rust-lang/rust) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [rust-lang/rust-analyzer](https://github.com/rust-lang/rust-analyzer) | 62er-Katalog: rust_analyzer | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [rust-lang/rust-clippy](https://github.com/rust-lang/rust-clippy) | 62er-Katalog: clippy | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [rust-lang/rustfmt](https://github.com/rust-lang/rustfmt) | 62er-Katalog: rustfmt | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [rust-lang/rustup](https://github.com/rust-lang/rustup) | 62er-Katalog: rustup | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [ruvnet/ruflo](https://github.com/ruvnet/ruflo) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/ruflo.md](tools/ruflo.md) |
| [rvc-project/retrieval-based-voice-conversion-webui](https://github.com/rvc-project/retrieval-based-voice-conversion-webui) | Registry: rvc | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/media_studio/AUDIO_DEEPFAKE_REVIEW.md](media_studio/AUDIO_DEEPFAKE_REVIEW.md) |
| [scanny/python-pptx](https://github.com/scanny/python-pptx) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [scikit-learn/scikit-learn](https://github.com/scikit-learn/scikit-learn) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [scipy/scipy](https://github.com/scipy/scipy) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [sczhou/propainter](https://github.com/sczhou/propainter) | Registry: propainter | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/propainter.md](tools/propainter.md) |
| [semgrep/semgrep](https://github.com/semgrep/semgrep) | Menue: Semgrep; Registry: semgrep | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |
| [serde-rs/serde](https://github.com/serde-rs/serde) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [sfztools/sfizz](https://github.com/sfztools/sfizz) | Registry: sfizz | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/media_studio/MIDI_SAMPLING_GUIDE.md](media_studio/MIDI_SAMPLING_GUIDE.md) |
| [sfztools/sfizz-ui](https://github.com/sfztools/sfizz-ui) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/sfizz.md](tools/sfizz.md) |
| [sgl-project/sglang](https://github.com/sgl-project/sglang) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [sharkdp/hyperfine](https://github.com/sharkdp/hyperfine) | Registry: hyperfine | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tools/local-ai-benchmarks.md](tools/local-ai-benchmarks.md) |
| [showlab/kiwi-edit](https://github.com/showlab/kiwi-edit) | Registry: kiwi_edit | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/kiwi-edit.md](tools/kiwi-edit.md) |
| [significant-gravitas/autogpt](https://github.com/significant-gravitas/autogpt) | Menue: AutoGPT | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOL_INDEX.md](TOOL_INDEX.md) |
| [sigstore/cosign](https://github.com/sigstore/cosign) | Registry: cosign | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [skyworkai/skyreels-a1](https://github.com/skyworkai/skyreels-a1) | Registry: skyreels_a1 | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/VIDEO_AVATAR_SYSTEMS.md](VIDEO_AVATAR_SYSTEMS.md) |
| [snap-research/panda-70m](https://github.com/snap-research/panda-70m) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md) |
| [sparkaudio/spark-tts](https://github.com/sparkaudio/spark-tts) | Registry: spark_tts | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [spf13/cobra](https://github.com/spf13/cobra) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [spotify/basic-pitch](https://github.com/spotify/basic-pitch) | Registry: basic_pitch | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/media_studio/MIDI_SAMPLING_GUIDE.md](media_studio/MIDI_SAMPLING_GUIDE.md) |
| [sqlalchemy/alembic](https://github.com/sqlalchemy/alembic) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [sqlalchemy/sqlalchemy](https://github.com/sqlalchemy/sqlalchemy) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [sqlfluff/sqlfluff](https://github.com/sqlfluff/sqlfluff) | 62er-Katalog: sqlfluff; Registry: sqlfluff | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/language-quality-tools.md](tools/language-quality-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [sqlite/sqlite](https://github.com/sqlite/sqlite) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [sst/opencode](https://github.com/sst/opencode) | Menue: OpenCode | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [stability-ai/stable-audio-tools](https://github.com/stability-ai/stable-audio-tools) | Registry: stable_audio_open | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/stable-audio-open.md](tools/stable-audio-open.md) |
| [stackrox/kube-linter](https://github.com/stackrox/kube-linter) | 62er-Katalog: kubelinter; Registry: kubelinter | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [stakira/openutau](https://github.com/stakira/openutau) | Registry: openutau | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [stalwartlabs/stalwart](https://github.com/stalwartlabs/stalwart) | Registry: sieve; Registry: stalwart; Registry: stalwart_mail | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_INDEX.md](TOOL_INDEX.md) |
| [statsmodels/statsmodels](https://github.com/statsmodels/statsmodels) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [stirling-tools/stirling-pdf](https://github.com/stirling-tools/stirling-pdf) | Menue: Stirling_PDF | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md) |
| [streamlit/streamlit](https://github.com/streamlit/streamlit) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [sveltejs/svelte](https://github.com/sveltejs/svelte) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [swatinem/rust-cache](https://github.com/swatinem/rust-cache) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [swe-agent/swe-agent](https://github.com/swe-agent/swe-agent) | Registry: swe_agent | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [syncthing/syncthing](https://github.com/syncthing/syncthing) | Menue: Syncthing; Registry: syncthing | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/SETUP_REVIEW_2026_NEXT_ACTIONS.md](SETUP_REVIEW_2026_NEXT_ACTIONS.md) |
| [systran/faster-whisper](https://github.com/systran/faster-whisper) | Menue: Faster_Whisper; Registry: faster_whisper | [docs/GITHUB_TOOL_CANDIDATES_REVIEW.md](GITHUB_TOOL_CANDIDATES_REVIEW.md), [docs/tutorials/manus-interview-2026-10-22.md](tutorials/manus-interview-2026-10-22.md) |
| [tailscale/tailscale](https://github.com/tailscale/tailscale) | Keine direkte Zuordnung; manuell pruefen | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [tailwindlabs/tailwindcss](https://github.com/tailwindlabs/tailwindcss) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi) | Registry: freellmapi | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/_API-Keys/API_KEY_GUIDE.md](_API-Keys/API_KEY_GUIDE.md), [docs/_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md](_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md) |
| [taskforcesh/bullmq](https://github.com/taskforcesh/bullmq) | Registry: bullmq | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/tools/queue/README.md](tools/queue/README.md) |
| [tauri-apps/tauri](https://github.com/tauri-apps/tauri) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [temporalio/temporal](https://github.com/temporalio/temporal) | Registry: temporal | [docs/tools/queue/README.md](tools/queue/README.md) |
| [tencent-hunyuan/hunyuan3d-2.1](https://github.com/tencent-hunyuan/hunyuan3d-2.1) | Keine direkte Zuordnung; manuell pruefen | [docs/AI_3D_STUDIO.md](AI_3D_STUDIO.md) |
| [tencent-hunyuan/hunyuanvideo](https://github.com/tencent-hunyuan/hunyuanvideo) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md) |
| [terraform-aws-modules/terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/qwen-development-tooling.md](tutorials/qwen-development-tooling.md) |
| [terraform-docs/terraform-docs](https://github.com/terraform-docs/terraform-docs) | 62er-Katalog: terraform_docs; Registry: terraform_docs | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [terraform-linters/tflint](https://github.com/terraform-linters/tflint) | 62er-Katalog: tflint; Registry: tflint | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [tesseract-ocr/tesseract](https://github.com/tesseract-ocr/tesseract) | Registry: tesseract | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/tools/personnel-documents.md](tools/personnel-documents.md) |
| [testcontainers/testcontainers-go](https://github.com/testcontainers/testcontainers-go) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [testcontainers/testcontainers-python](https://github.com/testcontainers/testcontainers-python) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [theory/pgtap](https://github.com/theory/pgtap) | 62er-Katalog: pgtap | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [till-schaefer/jarvis](https://github.com/till-schaefer/jarvis) | Keine direkte Zuordnung; manuell pruefen | [docs/tools/jarvis-hermes-dashboard.md](tools/jarvis-hermes-dashboard.md) |
| [tmc/langchaingo](https://github.com/tmc/langchaingo) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [tmelyralab/musetalk](https://github.com/tmelyralab/musetalk) | Registry: musetalk | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md), [docs/VIDEO_AVATAR_SYSTEMS.md](VIDEO_AVATAR_SYSTEMS.md), [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [tokio-rs/axum](https://github.com/tokio-rs/axum) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [tokio-rs/tokio](https://github.com/tokio-rs/tokio) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md), [docs/tutorials/perplexity-development-tooling.md](tutorials/perplexity-development-tooling.md) |
| [traefik/traefik](https://github.com/traefik/traefik) | Registry: traefik | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [trepan-debuggers/bashdb](https://github.com/trepan-debuggers/bashdb) | 62er-Katalog: bashdb | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/manus-language-infrastructure-sources.md](tutorials/manus-language-infrastructure-sources.md) |
| [trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) | Menue: TruffleHog; Registry: trufflehog | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [typesettingtools/aegisub](https://github.com/typesettingtools/aegisub) | Registry: aegisub | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/media_studio/AUDIO_VIDEO_TOOL_CATALOG.md](media_studio/AUDIO_VIDEO_TOOL_CATALOG.md), [docs/tools/aegisub.md](tools/aegisub.md) |
| [unslothai/unsloth](https://github.com/unslothai/unsloth) | Menue: Unsloth | [docs/Profil/LLM-Builder.doc.md](Profil/LLM-Builder.doc.md) |
| [unstructured-io/unstructured](https://github.com/unstructured-io/unstructured) | Menue: Unstructured; Registry: unstructured | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md) |
| [username/huginn](https://github.com/username/huginn) | Keine direkte Zuordnung; manuell pruefen | [docs/HUGINN_REPO_REF_GUIDE.md](HUGINN_REPO_REF_GUIDE.md) |
| [vast-ai-research/comfyui-tripo](https://github.com/vast-ai-research/comfyui-tripo) | Keine direkte Zuordnung; manuell pruefen | [docs/AI_3D_STUDIO.md](AI_3D_STUDIO.md) |
| [vast-ai-research/triposr](https://github.com/vast-ai-research/triposr) | Keine direkte Zuordnung; manuell pruefen | [docs/AI_3D_STUDIO.md](AI_3D_STUDIO.md) |
| [vega/altair](https://github.com/vega/altair) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/meta-development-tooling.md](tutorials/meta-development-tooling.md) |
| [velero-io/velero](https://github.com/velero-io/velero) | Menue: Velero; Registry: velero | [docs/VELERO_INSTALLATION_NOTES.md](VELERO_INSTALLATION_NOTES.md) |
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | Registry: find_skills | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md), [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tools/find-skills.md](tools/find-skills.md) |
| [vercel/next.js](https://github.com/vercel/next.js) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [visualbruno/comfyui-hunyuan3d-2-1](https://github.com/visualbruno/comfyui-hunyuan3d-2-1) | Keine direkte Zuordnung; manuell pruefen | [docs/AI_3D_STUDIO.md](AI_3D_STUDIO.md) |
| [vitejs/vite](https://github.com/vitejs/vite) | 62er-Katalog: vite | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [vitest-dev/vitest](https://github.com/vitest-dev/vitest) | 62er-Katalog: vitest | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [vladmandic/sdnext](https://github.com/vladmandic/sdnext) | Registry: sdnext | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/tools/sdnext.md](tools/sdnext.md) |
| [vllm-project/vllm](https://github.com/vllm-project/vllm) | Registry: vllm | [docs/TOOLS_CATALOG.md](TOOLS_CATALOG.md), [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/grok-development-tooling.md](tutorials/grok-development-tooling.md) |
| [vscodium/vscodium](https://github.com/vscodium/vscodium) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md) |
| [vuejs/core](https://github.com/vuejs/core) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/chatgpt-tooling-sources.md](tutorials/chatgpt-tooling-sources.md), [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [wan-video/wan2.1](https://github.com/wan-video/wan2.1) | Registry: wan21 | [docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md](Profile/OpenHiggsStack_AI_Cinema_Studio.md), [docs/Profile/Video_Generation_ComfyUI_Wan.md](Profile/Video_Generation_ComfyUI_Wan.md), [docs/media_studio/EDITABLE_VIDEO_WORKFLOWS.md](media_studio/EDITABLE_VIDEO_WORKFLOWS.md) |
| [wan-video/wan2.2](https://github.com/wan-video/wan2.2) | Keine direkte Zuordnung; manuell pruefen | [docs/Profile/OpenHiggsStack_AI_Cinema_Studio.md](Profile/OpenHiggsStack_AI_Cinema_Studio.md), [docs/Profile/Video_Generation_ComfyUI_Wan.md](Profile/Video_Generation_ComfyUI_Wan.md) |
| [wazuh/wazuh](https://github.com/wazuh/wazuh) | Registry: wazuh | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [weaviate/weaviate](https://github.com/weaviate/weaviate) | Registry: weaviate | [docs/RECOMMENDED_TOOLS.md](RECOMMENDED_TOOLS.md) |
| [webpack/webpack](https://github.com/webpack/webpack) | Keine direkte Zuordnung; manuell pruefen | [docs/tutorials/gemini-development-tooling.md](tutorials/gemini-development-tooling.md) |
| [windmill-labs/windmill](https://github.com/windmill-labs/windmill) | Registry: windmill | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md), [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/tools/windmill.md](tools/windmill.md) |
| [yannh/kubeconform](https://github.com/yannh/kubeconform) | 62er-Katalog: kubeconform; Registry: kubeconform | [docs/DEVELOPMENT_TOOLS_OVERVIEW.md](DEVELOPMENT_TOOLS_OVERVIEW.md), [docs/tools/development-go-tools.md](tools/development-go-tools.md), [docs/tutorials/claude-development-tooling.md](tutorials/claude-development-tooling.md) |
| [yl4579/styletts2](https://github.com/yl4579/styletts2) | Registry: styletts2 | [docs/TOOL_MATRIX.md](TOOL_MATRIX.md) |
| [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | Keine direkte Zuordnung; manuell pruefen | [docs/TOOL_GAP_ANALYSIS.md](TOOL_GAP_ANALYSIS.md) |
| [zai-org/cogvideo](https://github.com/zai-org/cogvideo) | Registry: cogvideox | [docs/media_studio/SOCIAL_AVATAR_AUTOMATION.md](media_studio/SOCIAL_AVATAR_AUTOMATION.md), [docs/media_studio/VIDEO_TRAINING_DATASETS.md](media_studio/VIDEO_TRAINING_DATASETS.md) |
| [zai-org/glm-5](https://github.com/zai-org/glm-5) | Keine direkte Zuordnung; manuell pruefen | [docs/media_studio/HYBRID_MODELS_AND_WAN.md](media_studio/HYBRID_MODELS_AND_WAN.md) |
| [zeek/zeek](https://github.com/zeek/zeek) | Registry: zeek | [docs/GITHUB_TOOL_SOURCES.md](GITHUB_TOOL_SOURCES.md) |

## Strukturfehler

Doppelte Registry-IDs: keine

Doppelte Menue-Keys: keine
