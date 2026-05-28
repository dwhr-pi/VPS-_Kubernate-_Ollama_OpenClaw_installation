# OpenClaw Integration

## Ziel

OpenClaw ist die lokale Agenten-Schicht fuer Codex-aehnliche Workflows, Ollama, n8n, RAG, Home Assistant und Tool-Automation.

## Gateway Start

- `gateway.mode=local`
- Host standardmaessig `127.0.0.1`
- Token nie ins Repo schreiben
- Logs nach `~/.openclaw_ultimate_user_data/logs`

## Provider

- bevorzugt: Ollama unter `http://127.0.0.1:11434`
- optional: Gemini/OpenAI/Anthropic nur mit bewusst gesetzten API-Keys und Kostenwarnung

## Typische Fehler

| Fehler | Ursache | Reparatur |
|---|---|---|
| gateway token mismatch | Token in Client/Gateway verschieden | Token neu setzen, nicht committen |
| anthropic key missing | Cloud-Provider ohne Key aktiv | lokalen Provider waehlen oder Key bewusst setzen |
| provider cooldown | Provider fehlerhaft/Rate-Limit | lokales Modell/Fallback nutzen |
| openclaw command not found | PATH/Installation fehlt | Installer/Doctor ausfuehren |
| WSL systemd Probleme | systemd nicht aktiv | WSL-Doku pruefen, User-Service nutzen |

## Beispiel-Agenten

- `local-coder`: Code lesen, Patches vorschlagen, Tests starten.
- `local-researcher`: Quellen sammeln, RAG-Dokumente erstellen.
- `marketing-writer`: lokale Textentwuerfe, keine Autoposts.
- `media-music-agent`: Prompts, Metadaten, FFmpeg-Hilfen.
- `security-doctor`: defensive Checks, keine offensiven Aktionen.
- `home-assistant-agent`: Smart Home nur mit Human Approval.
