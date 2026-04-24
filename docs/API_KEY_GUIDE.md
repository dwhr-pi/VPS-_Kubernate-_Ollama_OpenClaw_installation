```ini
# API-Key Guide, Port-Konfiguration und Sicherheitsmaßnahmen (V11)

Dieses Dokument bietet eine detaillierte Anleitung zur Beschaffung und Konfiguration aller notwendigen API-Keys, zur Port-Konfiguration und zu Sicherheitsmaßnahmen gegen DDoS-Angriffe und Bot-Attacken. Es ist entscheidend, diese Schritte sorgfältig zu befolgen, um die volle Funktionalität und Sicherheit deines Systems zu gewährleisten.

## 1. API-Keys beschaffen und konfigurieren

Die meisten KI-Dienste und externen Integrationen erfordern API-Keys. Diese sollten sicher behandelt und niemals öffentlich gemacht werden.

### 1.1 Google Gemini API-Key

*   **Zweck:** Primäres LLM für OpenClaw und andere KI-Agenten.
*   **Bezug:**
    1.  Besuche [Google AI Studio](https://aistudio.google.com/app/apikey).
    2.  Melde dich mit deinem Google-Konto an.
    3.  Klicke auf "Create API key in new project" oder "Get API key" für ein bestehendes Projekt.
    4.  Kopiere den generierten API-Key.
*   **Konfiguration:** Trage den Key in die `OPENCLAW_DIR/.env` Datei (nachdem du sie über den OpenClaw Konfigurations-Manager bearbeitet hast) und in die `config.json` ein:
    ```ini
    # .env
    GEMINI_API_KEY="DEIN_GEMINI_API_KEY_HIER"
    ```

### 1.2 Google Kalender API (für gcali Skill)

*   **Zweck:** Ermöglicht OpenClaw den Zugriff auf deinen Google Kalender über den `gcali`-Skill.
*   **Bezug:**
    1.  Besuche die [Google Cloud Console](https://console.cloud.google.com/).
    2.  Erstelle ein neues Projekt oder wähle ein bestehendes aus.
    3.  Navigiere zu "APIs & Dienste" -> "Anmeldedaten".
    4.  Klicke auf "Anmeldedaten erstellen" -> "OAuth-Client-ID".
    5.  Wähle "Webanwendung" als Anwendungstyp.
    6.  Füge unter "Autorisierte JavaScript-Ursprünge" deine OpenClaw Domain hinzu (z.B. `https://botsoft.uk`).
    7.  Füge unter "Autorisierte Weiterleitungs-URIs" die Callback-URL hinzu (z.B. `https://botsoft.uk/auth/google/callback`).
    8.  Kopiere die generierte **Client ID** und das **Client Secret**.
*   **Konfiguration:** Trage die Werte in die `OPENCLAW_DIR/.env` und `config.json` ein:
    ```ini
    # .env
    GOOGLE_CLIENT_ID="DEINE_GOOGLE_CLIENT_ID_HIER"
    GOOGLE_CLIENT_SECRET="DEIN_GOOGLE_CLIENT_SECRET_HIER"
    GOOGLE_REDIRECT_URI="https://botsoft.uk/auth/google/callback"
    ```

### 1.3 Cloudflare Tunnel Token (für Alexa Skill und sicheren externen Zugriff)

*   **Zweck:** Ermöglicht sicheren externen Zugriff auf deinen MiniPC (z.B. für Home Assistant, OpenClaw) und die Alexa Skill Integration ohne Port-Forwarding.
*   **Bezug:**
    1.  Melde dich bei deinem [Cloudflare-Konto](https://dash.cloudflare.com/) an.
    2.  Navigiere zu "Access" -> "Tunnels".
    3.  Erstelle einen neuen Tunnel. Folge den Anweisungen, um `cloudflared` auf deinem MiniPC zu installieren und den Tunnel zu konfigurieren.
    4.  Du erhältst eine **Tunnel ID** und ein **Tunnel Secret**.
*   **Konfiguration:** Trage die Werte in die `OPENCLAW_DIR/.env` und `config.json` ein:
    ```ini
    # .env
    CLOUDFLARE_TUNNEL_ID="DEIN_CLOUDFLARE_TUNNEL_ID_HIER"
    CLOUDFLARE_TUNNEL_SECRET="DEIN_CLOUDFLARE_TUNNEL_SECRET_HIER"
    ```

### 1.4 Hurricane Electric Dynamic DNS (DDNS) Key

*   **Zweck:** Aktualisiert automatisch den A-Record deiner Domain (z.B. `botsoft.uk`) bei Hurricane Electric, wenn sich die dynamische IP deines MiniPCs ändert.
*   **Bezug:**
    1.  Melde dich bei deinem [Hurricane Electric DNS-Konto](https://dns.he.net/) an.
    2.  Wähle deine Domain `botsoft.uk` aus.
    3.  Bearbeite den A-Record für deine Hauptdomain (`@` oder `botsoft.uk`).
    4.  Aktiviere "Enable Dynamic DNS" und kopiere den generierten **Update Key**.
*   **Konfiguration:** Das Setup-Skript wird dich nach diesem Key fragen, wenn du das Hybrid- oder Standalone MiniPC Setup wählst. Er wird in einem Skript auf deinem MiniPC hinterlegt.

### 1.5 Kimi 2 API-Key (Moonshot AI)

*   **Zweck:** Ermöglicht die Nutzung des Kimi 2 KI-Agenten von Moonshot AI für intelligente Interaktionen und Aufgaben.
*   **Bezug:**
    1.  Besuche die [Moonshot AI Website](https://www.moonshot.ai/) und registriere dich.
    2.  Navigiere zu den API-Key-Einstellungen und generiere einen neuen API-Key.
    3.  Kopiere den generierten API-Key.
*   **Konfiguration:** Der Kimi 2 API-Key muss in der Konfigurationsdatei von Kimi 2 oder als Umgebungsvariable hinterlegt werden. Das Installationsskript wird dich gegebenenfalls zur Eingabe auffordern oder die Konfigurationsdatei zur Bearbeitung öffnen.
    ```ini
    # Beispiel für Umgebungsvariable oder Konfigurationsdatei
    KIMI_API_KEY="DEIN_KIMI_API_KEY_HIER"
    ```

### 1.6 Hugging Face API Token (für Huge Facing - Online-Modelle und Inference API)

*   **Zweck:** Ermöglicht den Zugriff auf die Hugging Face Inference API für die Nutzung von Online-LLMs oder die Interaktion mit Modellen, die auf Hugging Face gehostet werden. Dies ist relevant, wenn du Modelle nicht lokal über Ollama betreiben möchtest.
*   **Bezug:**
    1.  Besuche [Hugging Face](https://huggingface.co/) und melde dich an.
    2.  Navigiere zu deinen Einstellungen (Profilbild oben rechts -> "Settings").
    3.  Wähle "Access Tokens" in der linken Navigation.
    4.  Klicke auf "New token" und gib einen Namen sowie die entsprechenden Berechtigungen (mindestens "read") an.
    5.  Kopiere den generierten Token.
*   **Konfiguration:** Der Hugging Face Token kann als Umgebungsvariable `HF_TOKEN` oder in der Konfiguration von Tools, die die Hugging Face API nutzen, hinterlegt werden. Das Setup-Skript wird dich gegebenenfalls zur Eingabe auffordern.
    ```ini
    # Beispiel für Umgebungsvariable
    HF_TOKEN="DEIN_HUGGING_FACE_TOKEN_HIER"
    ```

### 1.7 Weitere API-Keys (n8n, Activepieces, Zenbot-trader, etc.)

*   Für Dienste wie `n8n`, `Activepieces` oder `Zenbot-trader` musst du die jeweiligen API-Keys für die von dir verwendeten externen Dienste (z.B. Krypto-Börsen, Social Media APIs) direkt in deren Konfigurationen hinterlegen. Die Installationsskripte werden dich darauf hinweisen oder die entsprechenden Konfigurationsdateien zur Bearbeitung öffnen.

### 1.8 Tools für das Profil 'Rechtsberatung & Steuerrecht'

*   **Web-Search & Fetch:** Benötigt keine spezifischen API-Keys, nutzt Standard-Web-APIs.
*   **PDF-Reader / Document-Parser:** Benötigt keine spezifischen API-Keys.
*   **Zotero:** Benötigt keine API-Keys für die Basis-Funktionalität. Für erweiterte Integrationen (z.B. Zotero API) können Keys erforderlich sein, die manuell konfiguriert werden müssen.

## 2. OpenClaw Konfiguration (.env & config.json)

Das Setup enthält einen dedizierten OpenClaw Konfigurations-Manager (Option 3 im Hauptmenü), mit dem du die `.env`- und `config.json`-Dateien bearbeiten und anwenden kannst. Diese Dateien sind entscheidend für das Verhalten von OpenClaw.

### 2.1 Wichtige Einstellungen in .env und config.json

*   **`DOMAIN`:** Setze dies auf `https://botsoft.uk`. Dies ist die öffentliche URL, unter der OpenClaw erreichbar ist.
*   **`PRIMÄRES_LLM_ANBIETER`:** Wähle `GEMINI` für die Nutzung von Google Gemini als primäres LLM. Für reine Ollama-Installation oder wenn du nur Ollama nutzen möchtest, setze es auf `OLLAMA`.
*   **`GEMINI_API_KEY` / `GEMINI_MODEL`:** Dein Gemini API-Key und das gewünschte Modell (z.B. `gemini-1.5-flash`).
*   **`OLLAMA_HOST` / `OLLAMA_MODEL`:** Der Host deines Ollama-Servers (z.B. `http://localhost:11434` für lokal, oder die IP eines VPS, auf dem Ollama läuft) und das zu verwendende Modell (z.B. `llama3.2:1b`).
*   **`FALLBACK_TO_OLLAMA`:** Setze dies auf `true`, um Ollama als Fallback zu nutzen, wenn Gemini nicht erreichbar ist oder fehlschlägt. Dies ist besonders wichtig für die Robustheit deines Systems.
*   **`DB_CONNECTION_STRING`:** Der Verbindungsstring zu deiner MongoDB-Instanz. Für lokale Installationen `mongodb://localhost:27017/openclaw`, für VPS-Installation entsprechend anpassen.
*   **`JWT_SECRET`:** Ein langer, zufälliger String für die Sicherheit von OpenClaw. Generiere einen neuen, sicheren Schlüssel.
*   **`ADMIN_EMAIL` / `ADMIN_PASSWORD`:** Zugangsdaten für den Admin-Benutzer von OpenClaw.
*   **`CLOUDFLARE_TUNNEL_ID` / `CLOUDFLARE_TUNNEL_SECRET`:** Für die Cloudflare Tunnel Integration (siehe 1.3).
*   **`GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` / `GOOGLE_REDIRECT_URI`:** Für den Google Kalender Skill (siehe 1.2).
*   **`RL_AGENT_ENABLED` / `RL_MODEL_PATH` / `RL_TRAINING_MODE`:** Einstellungen für den OpenClaw Reinforcement Learning Agent.

## 3. Port-Konfiguration und System-Check

Ein korrektes Port-Management ist entscheidend für die Erreichbarkeit deiner Dienste und die Vermeidung von Konflikten. Das Setup bietet eine Option "System-Check & Port-Analyse" (Option 11 im Hauptmenü), die dir hilft, Port-Konflikte zu identifizieren.

### 3.1 Wichtige Ports

| Dienst             | Standard Port(s) | Beschreibung                                                               |
| :----------------- | :--------------- | :------------------------------------------------------------------------- |
| **OpenClaw**       | 3000             | Haupt-API und Web-Interface                                                |
| **Ollama**         | 11434            | LLM-API                                                                    |
| **Home Assistant** | 8123             | Smart Home Web-Interface                                                   |
| **n8n**            | 5678             | Workflow-Automatisierung Web-Interface                                     |
| **Activepieces**   | 3000             | Workflow-Automatisierung Web-Interface (kann mit OpenClaw kollidieren!)    |
| **Flowise**        | 3000             | LLM-UI Web-Interface (kann mit OpenClaw kollidieren!)                      |
| **LangFlow**       | 7860             | LLM-UI Web-Interface                                                       |
| **Huginn**         | 3000             | Agenten-System Web-Interface (kann mit OpenClaw kollidieren!)              |
| **Zenbot-trader**  | 3000             | Trading-Bot Web-Interface (kann mit OpenClaw kollidieren!)                 |
| **SSH**            | 22               | Sicherer Fernzugriff                                                       |
| **HTTP/HTTPS**     | 80/443           | Webserver (Nginx/Apache), Let's Encrypt                                    |

**Wichtiger Hinweis:** Dienste, die standardmäßig Port 3000 verwenden (OpenClaw, Activepieces, Flowise, Huginn, Zenbot-trader), können auf demselben System kollidieren. Du musst die Ports in ihren jeweiligen Konfigurationsdateien anpassen, wenn du mehrere dieser Dienste auf einem einzigen MiniPC oder VPS betreibst.

### 3.2 Firewall-Konfiguration (UFW)

Stelle sicher, dass die benötigten Ports in deiner Firewall (UFW) geöffnet sind. Das Setup-Skript wird grundlegende UFW-Regeln einrichten, aber du solltest diese bei Bedarf anpassen.

```bash
sudo ufw allow 3000/tcp # Beispiel für OpenClaw
sudo ufw reload
```

### 3.3 Nginx Rate Limiting

Wenn du Nginx als Reverse Proxy verwendest, konfiguriere Rate Limiting, um die Anzahl der Anfragen pro IP-Adresse zu begrenzen und so vor einfachen DDoS-Angriffen zu schützen.

```nginx
# In nginx.conf http-Block
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=5r/s;

# In server- oder location-Block
limit_req zone=mylimit burst=10 nodelay;
```

### 3.4 Regelmäßige Updates

Das integrierte Auto-Update-Skript (`scripts/auto_update.sh`) hilft dir, dein System und deine Software auf dem neuesten Stand zu halten, was entscheidend für die Sicherheit ist.

## 4. Schutz vor DDoS-Angriffen und Bot-Attacken (Details in `DNS_DDoS_GUIDE.md`)

Der Schutz deiner Infrastruktur ist von größter Bedeutung. Die `DNS_DDoS_GUIDE.md` enthält detaillierte Informationen zu:

*   **Cloudflare als Reverse Proxy (Empfohlen):** Für DDoS-Schutz, WAF und sicheren externen Zugriff (Cloudflare Tunnel).
*   **Fail2Ban:** Zum Blockieren von Brute-Force-Angriffen.
*   **Nginx Rate Limiting:** Zur Begrenzung von Anfragen pro IP-Adresse.

## 5. Domain botsoft.uk Konfiguration

Stelle sicher, dass deine Domain `botsoft.uk` korrekt auf deine Dienste verweist. Wenn du Cloudflare als Reverse Proxy nutzt, müssen die A-Records auf die Cloudflare-IPs zeigen. Wenn du Hurricane Electric für DDNS nutzt, muss der A-Record auf die dynamische IP deines MiniPCs zeigen.

*   **OpenClaw:** Der `DOMAIN` Parameter in der `.env` und `config.json` muss auf `https://botsoft.uk` gesetzt sein.
*   **Google Kalender Redirect URI:** Muss `https://botsoft.uk/auth/google/callback` sein.

Indem du diese Anweisungen befolgst, schützt du deine Infrastruktur und stellst sicher, dass alle Dienste reibungslos funktionieren.
```
