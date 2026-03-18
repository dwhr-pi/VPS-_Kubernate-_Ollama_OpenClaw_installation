# 🔑 API-Key & Port-Analyse Guide (V3)

Dieses Dokument ist der zentrale Leitfaden für die Einrichtung der notwendigen Schnittstellen und die Sicherstellung der Erreichbarkeit Ihres hybriden Setups.

---

## 🛠️ API-Keys: Woher und Wie?

| Dienst | Zweck | Link | Modell / Empfehlung |
| :--- | :--- | :--- | :--- |
| **Google Gemini** | Primäres LLM (Cloud) | [AI Studio](https://aistudio.google.com/) | `gemini-1.5-flash` (kostenlos) |
| **Ollama (Lokal)** | Fallback & Privacy | [Ollama.com](https://ollama.com) | `llama3.2:1b` (ressourcenschonend) |
| **HE.net (DNS)** | Dynamische IP-Auflösung | [dns.he.net](https://dns.he.net) | Hostname + DDNS-Passwort |
| **Google Calendar** | `gcali` Skill / Home Assistant | [Google Cloud Console](https://console.cloud.google.com/) | `credentials.json` (OAuth2) |
| **Exchange APIs** | Zenbot Trading | Binance, Kraken, etc. | API Key + Secret (ReadOnly empfohlen) |

---

## 📡 Port-Analyse & Routing

Um Konflikte zu vermeiden und das **Gemini-Ollama-Fallback** sicherzustellen, nutzen wir folgende Port-Struktur:

| Dienst | Standard-Port | Alternative (bei Konflikt) | Zweck |
| :--- | :--- | :--- | :--- |
| **Ollama** | 11434 | 11435 | Lokales KI-Backend |
| **OpenClaw Gateway** | 18789 | 19001 (`--dev`) | Hauptschnittstelle |
| **Home Assistant** | 8123 | 8124 | Smart Home Dashboard |
| **Cloudflared** | Dynamisch | N/A | Sicherer Alexa-Tunnel |
| **Zenbot Web** | 8080 | 8081 | Trading-Dashboard |

### ⚠️ Wichtig: Das Routing-Problem
Wenn Gemini ausfällt oder das Limit erreicht ist, muss das System auf Ollama (`llama3.2:1b`) umschalten. Dies wird in der `.env` von OpenClaw wie folgt konfiguriert:

```env
# Primär: Gemini
LLM_PROVIDER=gemini
GEMINI_API_KEY=dein_key
GEMINI_MODEL=gemini-1.5-flash

# Fallback: Ollama (muss lokal laufen!)
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:1b
FALLBACK_TO_OLLAMA=true
```

---

## 🏠 Alexa & Home Assistant Integration

1.  **Alexa Skill:** Erstellen Sie einen "Custom Skill" im Amazon Developer Portal.
2.  **Endpoint:** Nutzen Sie die HTTPS-URL Ihres Cloudflare-Tunnels.
3.  **Skill-ID:** Tragen Sie die `amzn1.ask.skill...` ID in die Konfiguration von Home Assistant ein.

---

## 📅 Der `gcali` Skill (Google Kalender)

1.  Aktivieren Sie die **Google Calendar API** in der Google Cloud Console.
2.  Laden Sie die `credentials.json` herunter.
3.  Platzieren Sie diese in `~/openclaw/skills/gcali/` und führen Sie die Erstauthentifizierung durch.
