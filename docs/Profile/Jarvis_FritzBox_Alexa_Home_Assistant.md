# Jarvis FritzBox Alexa Home Assistant

Status: `experimental`  
Tier: `advanced`  
Kategorie: `automation`

Dieses Profil buendelt die Bausteine fuer einen lokalen Jarvis-aehnlichen Heimassistenten mit Fritz!Box/Fritz!Fon, Home Assistant, optionaler Alexa-Bridge, lokaler Spracheingabe/-ausgabe und einem Ollama/OpenClaw-basierten Brain.

## Ziel

- Fritz!Box-Anrufereignisse auswerten.
- Verpasste Anrufe als lokale Notiz oder Aufgabe speichern.
- Home-Assistant-Automationen sicher anstossen.
- Lokale STT/TTS-Pipelines fuer Sprachdialoge nutzen.
- Alexa nur optional als Trigger oder Ausgabekanal verwenden.

## Brain-Konzept

Das `Jarvis Brain` ist keine einzelne Anwendung, sondern die logische Mitte:

- `Ollama` fuer lokale LLM-Antworten.
- `OpenClaw` fuer Tool- und Agentensteuerung.
- `Home Assistant` fuer Geraete, Events und Automationen.
- `Node-RED` und `MQTT` fuer Routing.
- `Qdrant` oder `ChromaDB` fuer spaetere Memory-/RAG-Kontexte.
- `Piper` und `faster-whisper` fuer lokale Stimme.

## Empfohlene Tools

Core:

- Home Assistant
- Mosquitto
- Node-RED
- Ollama
- OpenClaw
- Piper
- faster-whisper oder Whisper.cpp

Optional:

- Qdrant oder ChromaDB
- Open WebUI
- Tailscale
- Authentik oder Authelia
- Grafana/Prometheus

Advanced:

- Fritz!Box Call Monitor
- Fritz!Box TR-064
- Alexa Media Player fuer Home Assistant
- Asterisk/SIP

## Ports

| Dienst | Port | Hinweis |
|---|---:|---|
| Home Assistant | 8123 | nur LAN/Tailscale oder Reverse Proxy mit Auth |
| Node-RED | 1880 | Admin UI schuetzen |
| MQTT/Mosquitto | 1883 | Auth aktivieren |
| Ollama | 11434 | lokal binden |
| Qdrant optional | 6333 | nicht oeffentlich exponieren |

## Sicherheit

- Keine heimliche Anrufaufzeichnung.
- Keine versteckte Raumueberwachung.
- Keine Cloud-Weitergabe privater Anrufdaten als Standard.
- Keine Notruf-, Schloss-, Alarm- oder Tueroeffner-Automation ohne manuelle Bestaetigung.
- Telefonbuch, Anruflisten und Transkripte bleiben im User-Workspace.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.

## Quickstart

```bash
bash scripts/profiles/Jarvis_FritzBox_Alexa_Home_Assistant_install.sh
```

Danach:

1. Home Assistant unter `http://127.0.0.1:8123` pruefen.
2. MQTT lokal absichern.
3. Fritz!Box-Integration in Home Assistant einrichten.
4. Ollama-Modell laden, z. B. `ollama pull llama3.2`.
5. Alexa-Bridge nur aktivieren, wenn die Cloud-Grenzen bewusst akzeptiert sind.

## Deinstallation

```bash
bash scripts/profiles/Jarvis_FritzBox_Alexa_Home_Assistant_uninstall.sh
```

Die Deinstallation entfernt nur den Profilstatus. Kernwerkzeuge werden nicht blind deinstalliert, weil sie oft von Smart-Home-, Voice- und RAG-Profilen geteilt werden.

## Ausfuehrliche Profilquelle

Siehe [docs/Profil/Jarvis_FritzBox_Alexa_Home_Assistant.doc.md](../Profil/Jarvis_FritzBox_Alexa_Home_Assistant.doc.md).
