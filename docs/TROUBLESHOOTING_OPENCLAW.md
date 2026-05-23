# Troubleshooting OpenClaw

## OpenClaw startet nicht

Pruefe zuerst:

```bash
which openclaw || true
openclaw --version || true
```

Wenn das Kommando fehlt, Installationslog unter `~/.openclaw_ultimate_user_data/install_logs/` ansehen.

## Token oder Konfiguration passt nicht

- Keine echten Secrets ins Repo schreiben.
- Lokale Konfiguration gehoert nach `~/.openclaw_ultimate_user_data`.
- `.env.example` ist Vorlage, echte `.env` bleibt lokal.

## Agent darf zu viel

Safe Defaults:

- Shell-Zugriff nur bewusst aktivieren.
- Schreibzugriffe auf Smart Home, Trading, Robotik oder Cloud nur mit Human Approval.
- Riskante Tools per Allowlist begrenzen.

## OpenClaw mit Ollama

Pruefen:

```bash
curl http://127.0.0.1:11434/api/tags
```

Wenn Ollama nicht erreichbar ist, zuerst Ollama reparieren, nicht OpenClaw neu installieren.

