# 🚀 Vollautomatisches GitHub-basiertes KI- & Home-Setup V2 (WSL2 & Kubernetes)

Dieses Projekt ermöglicht ein hybrides Setup aus einem lokalen **Letsung MiniPC** (unter Windows WSL2) und einem **VPS-Cluster mit Kubernetes**. Das Ziel ist ein kosteneffizientes, weitgehend kostenloses System für den Betrieb von KI-Modellen (Ollama & Gemini), Agenten (**OpenClaw RL**, OpenManus), Smart Home (**Home Assistant**, Alexa, Google Kalender) und Trading-Bots (Zenbot).

---

## 🏗️ Systemarchitektur

Das System ist darauf ausgelegt, **direkt aus GitHub-Quellen** zu kompilieren und zu installieren, um maximale Kontrolle und Unabhängigkeit von Docker-Images zu gewährleisten.

1.  **Lokal (Letsung MiniPC):** Dient als primärer Rechenknoten für lokale KI-Modelle (Ollama), Smart Home (Home Assistant) und den **OpenClaw RL** Agenten.
2.  **Cloud (VPS):** Ein Kubernetes-Cluster (K3s), der Steuerungsaufgaben übernimmt, Web-Interfaces hostet und als Fallback dient.

---

## 🛠️ Phase 1: Vorbereitung & DNS (Hurricane Electric)

Da der MiniPC eine dynamische IP hat, nutzen wir Hurricane Electric als Dynamic DNS Anbieter.

### Schritte:
1.  Erstellen Sie ein Konto bei [dns.he.net](https://dns.he.net).
2.  Richten Sie einen Hostnamen für Ihre aktuelle IP ein.
3.  **Automatisierung:** Ein Bash-Skript auf dem MiniPC aktualisiert regelmäßig die IP bei HE.net. (Wird im Installationsskript automatisch eingerichtet).

---

## 🏠 Phase 2: Lokales Setup (WSL2 auf Letsung MiniPC)

Wir installieren Linux (Ubuntu) unter WSL2 und richten die KI-Infrastruktur ein.

### 1. WSL2 & Ubuntu Installation
Öffnen Sie die PowerShell als Administrator:
```powershell
wsl --install -d Ubuntu
```

### 2. Automatisches Installationsskript (`install_all_github_v2.sh`)
Führen Sie das beigefügte Skript in Ihrer Ubuntu-Konsole aus:
```bash
chmod +x install_all_github_v2.sh
./install_all_github_v2.sh
```
Das Skript installiert:
*   **Ollama:** (Modell: Llama3.2) für lokale KI.
*   **Gemini:** (Modell: Gemini-1.5-Flash) für erweiterte KI-Agenten.
*   **OpenClaw RL:** Die Reinforcement Learning Version von OpenClaw, direkt aus GitHub geklont und kompiliert.
*   **OpenManus:** KI-Agent direkt aus GitHub geklont.
*   **Home Assistant Core:** Manuelle Installation ohne Docker, inklusive **Google Kalender** und Alexa-Skill-Vorbereitung.
*   **Zenbot:** Trading-Bot direkt aus GitHub geklont und mit lokaler MongoDB installiert.
*   **DDNS Update-Skript:** Für Hurricane Electric (via Crontab).

---

## ☁️ Phase 3: Cloud Setup (Kubernetes auf VPS)

Wir nutzen **K3s** (ein leichtgewichtiges Kubernetes) auf einem kostenlosen VPS (z.B. Oracle Cloud Always Free).

### 🚀 K3s Installation auf dem VPS:
Führen Sie das Skript `install_vps_k8s_github.sh` auf Ihrem VPS aus. Es installiert K3s und konfiguriert die Umgebung automatisch, wobei Code direkt von GitHub in Pods geladen wird.

---

## 📅 Smart Home & Skills

### Google Kalender Integration
Home Assistant wird mit den notwendigen Python-Bibliotheken für Google Kalender installiert. Sie müssen lediglich Ihre `credentials.json` in den Konfigurationsordner legen.

### Alexa Skill (Ohne Nabu Casa)
Um Alexa ohne kostenpflichtiges Abonnement zu nutzen, wird im Skript `cloudflared` installiert. Dies ermöglicht einen sicheren HTTPS-Tunnel zu Ihrem lokalen Home Assistant.

### OpenClaw RL
Der OpenClaw RL Agent läuft als Hintergrunddienst (Systemd) und lernt durch Interaktionen mit dem Benutzer (Reinforcement Learning).

---

## 🔑 API-Key Verwaltung
Während der Installation werden Sie nach folgenden Keys gefragt:
*   **Google Gemini API Key:** Für die Haupt-KI-Logik (Modell: Gemini-1.5-Flash).
*   **Hurricane Electric DDNS Key:** Für die Erreichbarkeit Ihres MiniPC.
*   **Exchange API Keys:** Für den Live-Handel mit Zenbot.

---

## 📄 Beigefügte Dateien
1.  `install_all_github_v2.sh`: Erweitertes Installationsskript für den MiniPC (WSL2).
2.  `install_vps_k8s_github.sh`: Installationsskript für den VPS (Kubernetes).
3.  `FINAL_GITHUB_SETUP_GUIDE_V2.md`: Diese Dokumentation.
