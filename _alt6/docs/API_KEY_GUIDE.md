# 🔑 API-Key & Port-Analyse Guide (V4)

Dieses Dokument ist der zentrale Leitfaden für die Einrichtung der notwendigen Schnittstellen und die Sicherstellung der Erreichbarkeit Ihres hybriden Setups. Es berücksichtigt die spezifischen Anforderungen des `dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation` Repositories, inklusive `llama3.2:1b`, `gcali` Skill und dem Gemini-Ollama Fallback-Routing.

---

## 🛠️ API-Keys: Woher und Wie?

Die folgenden API-Keys sind für die volle Funktionalität Ihres Setups erforderlich. Sie werden während der Installation abgefragt oder müssen manuell in den entsprechenden Konfigurationsdateien hinterlegt werden.

| Dienst | Zweck | Bezugsquelle | Modell / Empfehlung |
| :--- | :--- | :--- | :--- |
| **Google Gemini** | Primäres LLM (Cloud) für OpenClaw | [Google AI Studio](https://aistudio.google.com/app/apikey) | `gemini-1.5-flash` (kostenlos, hohe Rate Limits) |
| **Ollama (Lokal)** | Fallback-LLM für OpenClaw auf MiniPC | [Ollama.com](https://ollama.com/library) | `llama3.2:1b` (ressourcenschonend, ca. 1.3 GB) |
| **Hurricane Electric (DNS)** | Dynamische DNS-Updates für Letsung MiniPC | [dns.he.net](https://dns.he.net) | Hostname + DDNS-Update-Key |
| **Google Calendar API** | `gcali` Skill für OpenClaw & Home Assistant | [Google Cloud Console](https://console.cloud.google.com/apis/credentials) | `credentials.json` (OAuth2 Client ID/Secret) |
| **Amazon Developer Console** | Alexa Skill Backend (Custom Skill) | [Amazon Developer Console](https://developer.amazon.com/alexa/console/ask) | Skill ID (amzn1.ask.skill...) |
| **Cloudflare Tunnel** | Sicherer Fernzugriff für Alexa & Home Assistant | [Cloudflare Dashboard](https://dash.cloudflare.com/) | Tunnel Token (UUID) |
| **Krypto-Börsen APIs** | Zenbot Trading Bot | Binance, Kraken, Coinbase Pro, etc. | API Key + Secret (ReadOnly empfohlen) |

**Wichtiger Hinweis zu Google Calendar API:**
Für den `gcali` Skill und die Home Assistant Integration müssen Sie in der Google Cloud Console ein neues Projekt erstellen, die Google Calendar API aktivieren und OAuth 2.0 Client-IDs generieren. Die heruntergeladene `credentials.json` Datei muss dann in das `skills/gcali` Verzeichnis Ihrer OpenClaw-Installation kopiert werden. Die Erstauthentifizierung erfolgt interaktiv beim ersten Start des `gcali` Skills.

---

## 📡 Port-Analyse & Routing für Hybrid-Setup

Ein zentrales Element dieses Setups ist die Vermeidung von Port-Konflikten und die Implementierung eines robusten **Gemini-Ollama-Fallback-Routings**. Das `port_check.sh` Skript hilft Ihnen, potenzielle Konflikte vor der Installation zu identifizieren.

| Dienst | Standard-Port | Alternative (bei Konflikt) | Host | Zweck |
| :--- | :--- | :--- | :--- | :--- |
| **Ollama** | `11434` | `11435` | Letsung MiniPC | Lokales LLM-Backend, Fallback für Gemini |
| **OpenClaw Gateway** | `18789` | `19001` (`--dev`) | Letsung MiniPC | Hauptschnittstelle für KI-Agenten |
| **Home Assistant** | `8123` | `8124` | Letsung MiniPC | Smart Home Dashboard & Automation |
| **Cloudflared Tunnel** | Dynamisch | N/A | Letsung MiniPC | Sicherer externer Zugriff (Alexa, HA) |
| **Zenbot Web UI** | `8080` | `8081` | Oracle VPS | Trading Bot Webinterface |
| **Gemini-Ollama Proxy** | `8000` | `8001` | Oracle VPS | API-Routing & Fallback-Logik |

### ⚠️ Das Gemini-Ollama Fallback-Routing

Die Logik für das Fallback wird primär in der `.env` Datei Ihrer OpenClaw-Installation auf dem Letsung MiniPC konfiguriert. Der `Gemini-Ollama Proxy` auf dem VPS dient dazu, Anfragen intelligent zu verteilen und bei Bedarf auf den lokalen Ollama-Dienst auf dem MiniPC umzuleiten (z.B. über einen VPN-Tunnel oder Cloudflare Tunnel).

**Beispiel `.env` Konfiguration für OpenClaw (auf MiniPC):**

```env
# Primärer LLM-Provider: Google Gemini (Cloud)
LLM_PROVIDER=gemini
GEMINI_API_KEY=IHRE_GEMINI_API_KEY_HIER
GEMINI_MODEL=gemini-1.5-flash

# Fallback-LLM-Provider: Ollama (Lokal auf MiniPC)
OLLAMA_BASE_URL=http://localhost:11434  # Oder die interne IP des MiniPCs, wenn vom VPS aus zugegriffen wird
OLLAMA_MODEL=llama3.2:1b

# Aktiviert den Fallback-Mechanismus
FALLBACK_TO_OLLAMA=true

# Optional: Konfiguration für den Gemini-Ollama Proxy auf dem VPS
# Wenn der Proxy verwendet wird, sollte LLM_PROVIDER auf 'proxy' gesetzt werden
# PROXY_URL=http://IHR_VPS_IP:8000
```

**Wichtige Überlegungen zum Routing:**
*   **Direkter Zugriff:** Wenn der MiniPC und der VPS im selben (virtuellen) Netzwerk sind, kann der VPS direkt auf `http://MINIPC_IP:11434` zugreifen.
*   **Cloudflare Tunnel:** Für den Zugriff von extern (z.B. vom VPS auf den MiniPC) ohne Port-Forwarding ist ein Cloudflare Tunnel die sicherste und einfachste Lösung.
*   **VPN:** Eine Site-to-Site VPN-Verbindung zwischen VPS und MiniPC bietet ebenfalls eine sichere Kommunikationsbrücke.

---

## 🏠 Alexa & Home Assistant Integration

Die Integration von Alexa und Home Assistant erfolgt über einen Custom Skill und einen Cloudflare Tunnel, um die Abhängigkeit von kostenpflichtigen Diensten wie Nabu Casa zu vermeiden.

1.  **Home Assistant Core Installation:** Erfolgt auf dem Letsung MiniPC. Die Konfiguration für den Google Kalender wird über die `configuration.yaml` vorgenommen, nachdem die `credentials.json` von Google platziert wurde.
2.  **Alexa Custom Skill:** Erstellen Sie einen neuen Custom Skill in der Amazon Developer Console. Der Endpoint dieses Skills muss auf die öffentliche URL Ihres Cloudflare Tunnels zeigen, der auf Ihren Home Assistant (Port 8123) oder direkt auf OpenClaw (Port 18789) auf dem MiniPC weiterleitet.
3.  **Cloudflare Tunnel:** Installieren und konfigurieren Sie `cloudflared` auf Ihrem Letsung MiniPC. Erstellen Sie einen Tunnel, der die gewünschten lokalen Dienste (HA, OpenClaw) sicher ins Internet exponiert. Dies ermöglicht Alexa, mit Ihren lokalen Diensten zu kommunizieren, ohne dass Sie Ports in Ihrer Fritzbox öffnen müssen.

---

## 📅 Der `gcali` Skill (Google Kalender)

Der `gcali` Skill für OpenClaw ermöglicht die Interaktion mit Ihrem Google Kalender. Die Installation erfolgt durch das Klonen des `dwhr-pi` Repositories und das Kopieren der Skill-Dateien in das OpenClaw-Verzeichnis.

1.  **Google Calendar API:** Stellen Sie sicher, dass die Google Calendar API in Ihrem Google Cloud Projekt aktiviert ist.
2.  **`credentials.json`:** Laden Sie die OAuth 2.0 Client-Konfigurationsdatei (`credentials.json`) von der Google Cloud Console herunter.
3.  **Platzierung:** Kopieren Sie die `credentials.json` in das Verzeichnis `/opt/openclaw/skills/gcali/` auf Ihrem Letsung MiniPC.
4.  **Erstauthentifizierung:** Beim ersten Start des `gcali` Skills (oder wenn OpenClaw ihn das erste Mal lädt) werden Sie aufgefordert, einen Browser-Link zu öffnen, um die Authentifizierung abzuschließen und den Zugriff auf Ihren Google Kalender zu autorisieren.

---

## 🧠 OpenClaw RL (Reinforcement Learning)

OpenClaw RL ist ein Framework, das auf OpenClaw aufbaut, um den KI-Agenten durch Nutzerinteraktionen zu trainieren. Die Installation erfolgt als Teil des OpenClaw-Builds, wobei die RL-spezifischen Komponenten und Skripte aus dem `dwhr-pi` Repository in die OpenClaw-Installation integriert werden. Die genaue Konfiguration und Aktivierung des RL-Agenten erfolgt über die OpenClaw-Konfigurationsdateien und erfordert möglicherweise zusätzliche Python-Bibliotheken für Reinforcement Learning, die im `hybrid_setup.sh` Skript installiert werden.

---

## 📈 Zenbot Trading Bot

Zenbot wird primär auf dem Oracle VPS als Kubernetes Deployment betrieben, um 24/7 Verfügbarkeit und Skalierbarkeit zu gewährleisten. Die Installation umfasst:

1.  **MongoDB:** Als Datenbank für Zenbot. Wird als Kubernetes StatefulSet bereitgestellt.
2.  **Zenbot Core:** Das Hauptprogramm, das die Trading-Strategien ausführt.
3.  **Zenbot UI:** Ein Webinterface zur Überwachung und Konfiguration des Bots.

Die API-Keys für Ihre Krypto-Börsen werden sicher als Kubernetes Secrets hinterlegt und von Zenbot verwendet. Achten Sie darauf, Read-Only-Keys zu verwenden, wo immer möglich, um die Sicherheit zu erhöhen.

---

## ☁️ Multi-VPS Strategie & Ressourcenoptimierung

Um die Ressourcenbeschränkungen des Letsung MiniPC (16GB RAM / 70GB Disk) und des Oracle VPS (24GB RAM) zu adressieren, wird eine Multi-VPS-Strategie verfolgt:

*   **Letsung MiniPC:** Beherbergt ressourcenintensive, lokale Dienste (Ollama, OpenClaw, Home Assistant) und dient als Edge-Gerät für lokale Interaktionen und Privacy-sensible Daten.
*   **Oracle VPS:** Dient als zentraler Cloud-Knoten für 24/7-Dienste (Zenbot, OpenManus, Kubernetes Control Plane) und als Gateway für externe Zugriffe.
*   **Zusätzliche kostenlose VPS:** Werden für nicht-kritische, aber nützliche Dienste wie Monitoring (Grafana, Prometheus) oder Backup-Lösungen genutzt, um die Haupt-VPS zu entlasten und die Ausfallsicherheit zu erhöhen.

Diese Verteilung stellt sicher, dass kein einzelnes System überlastet wird und ermöglicht eine kostengünstige und robuste Infrastruktur. Die genaue Auswahl und Konfiguration der zusätzlichen VPS hängt von Ihren Präferenzen und den verfügbaren kostenlosen Angeboten ab.
