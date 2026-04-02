Die Top-Zeile in GNU nano ist nicht zu beachten. 
```nano
  GNU nano 6.2                                              .env *
```

Der original Inhalt der gesamten in einem Editor von Dir zu bearbeitende Datei: 
```
# OpenClaw .env example
#
# Quick start:
# 1) Copy this file to `.env` (for local runs from this repo), OR to `~/.openclaw/.env` (for launchd/systemd daemons).
# 2) Fill only the values you use.
# 3) Keep real secrets out of git.
#
# Env-source precedence for environment variables (highest -> lowest):
# process env, ./.env, ~/.openclaw/.env, then openclaw.json `env` block.
# Existing non-empty process env vars are not overridden by dotenv/config env loading.
# Note: direct config keys (for example `gateway.auth.token` or channel tokens in openclaw.json)
# are resolved separately from env loading and often take precedence over env fallbacks.

# -----------------------------------------------------------------------------
# Gateway auth + paths
# -----------------------------------------------------------------------------
# Recommended if the gateway binds beyond loopback.
OPENCLAW_GATEWAY_TOKEN=change-me-to-a-long-random-token
# Example generator: openssl rand -hex 32

# Optional alternative auth mode (use token OR password).
# OPENCLAW_GATEWAY_PASSWORD=change-me-to-a-strong-password

# Optional path overrides (defaults shown for reference).
# OPENCLAW_STATE_DIR=~/.openclaw
# OPENCLAW_CONFIG_PATH=~/.openclaw/openclaw.json
# OPENCLAW_HOME=~

# Optional: import missing keys from your login shell profile.
# OPENCLAW_LOAD_SHELL_ENV=1
# OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000

# -----------------------------------------------------------------------------
# Model provider API keys (set at least one)
# -----------------------------------------------------------------------------
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
# GEMINI_API_KEY=...
# OPENROUTER_API_KEY=sk-or-...
# OPENCLAW_LIVE_OPENAI_KEY=sk-...
# OPENCLAW_LIVE_ANTHROPIC_KEY=sk-ant-...
# OPENCLAW_LIVE_GEMINI_KEY=...
# OPENAI_API_KEY_1=...
# ANTHROPIC_API_KEY_1=...
# GEMINI_API_KEY_1=...
# GOOGLE_API_KEY=...
# OPENAI_API_KEYS=sk-1,sk-2
# ANTHROPIC_API_KEYS=sk-ant-1,sk-ant-2
# GEMINI_API_KEYS=key-1,key-2

# Optional additional providers
# ZAI_API_KEY=...
# AI_GATEWAY_API_KEY=...
# MINIMAX_API_KEY=...
# SYNTHETIC_API_KEY=...

# -----------------------------------------------------------------------------
# Channels (only set what you enable)
# -----------------------------------------------------------------------------
# TELEGRAM_BOT_TOKEN=123456:ABCDEF...
# DISCORD_BOT_TOKEN=...
# SLACK_BOT_TOKEN=xoxb-...
# SLACK_APP_TOKEN=xapp-...

# Optional channel env fallbacks
# MATTERMOST_BOT_TOKEN=...
# MATTERMOST_URL=https://chat.example.com
# ZALO_BOT_TOKEN=...
# OPENCLAW_TWITCH_ACCESS_TOKEN=oauth:...

# -----------------------------------------------------------------------------
# Tools + voice/media (optional)
# -----------------------------------------------------------------------------
# BRAVE_API_KEY=...
# PERPLEXITY_API_KEY=pplx-...
# FIRECRAWL_API_KEY=...

# ELEVENLABS_API_KEY=...
# XI_API_KEY=...  # alias for ElevenLabs
# DEEPGRAM_API_KEY=...
```



### OpenClaw .env example
Übersetzt heißt dies: 
```
# OpenClaw .env Beispiel
# 
# Schnellstart: 
# 1) Kopieren Sie diese Datei nach `.env` (für lokale Ausführungen aus diesem Repository) ODER nach `~/.openclaw/.env` (für launchd/systemd-Daemons). 
# 2) Tragen Sie nur die benötigten Werte ein. 
# 3) Halten Sie sensible Daten von Git fern. 
# 
# Priorität der Umgebungsvariablen (höchste -> niedrigste): 
# Prozessumgebung, ./.env, ~/.openclaw/.env, dann der `env`-Block in openclaw.json. 
# Vorhandene, nicht leere Prozessumgebungsvariablen werden beim Laden von Umgebungsvariablen mit dotenv/config nicht überschrieben. 
# Hinweis: Direkte Konfigurationsschlüssel (z. B. `gateway.auth.token` oder Kanaltoken in openclaw.json) 
# werden unabhängig vom Laden von Umgebungsvariablen aufgelöst und haben oft Vorrang vor Umgebungsvariablen-Fallbacks.
```

Ab hier werden die drei Sektionen Beschrieben. 
+ Gateway auth + paths -
  Die Gateway-Authentifizierung + Pfade
+ Model provider API keys (set at least one) -
  API-Schlüssel des Modellanbieters (mindestens einen festlegen)
+ Tools + voice/media (optional) -
  Ab hier kommen: Die Werkzeuge + Sprach-/Medien (optional).

### Datei `.env` laden

```
nano .env
```

### 1️⃣ Minimal `.env` für localhost (empfohlen)
```env
# Security token for gateway access
OPENCLAW_GATEWAY_TOKEN=8c3f7c2c0e2d7a0c0b3a4d3f8e1f9c5a7b2e6f4c1d9a0e5f7b3c2d1a6e9f0c1

# Storage directory for OpenClaw state
OPENCLAW_STATE_DIR=/home/$USER/.openclaw

# Config file location
OPENCLAW_CONFIG_PATH=/home/$USER/.openclaw/openclaw.json

# Home directory
OPENCLAW_HOME=/home/$USER

# Load environment variables from shell
OPENCLAW_LOAD_SHELL_ENV=1

# Timeout for shell env loading
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000
```

#### 💡 Für **localhost reicht das komplett aus** ist jedoch ohne Ollama.

### 2️⃣ Sicheres Gateway-Token erzeugen

Unter Linux / WSL / Ubuntu:
```bash
openssl rand -hex 32
```

Beispiel Ergebnis:
```
8c3f7c2c0e2d7a0c0b3a4d3f8e1f9c5a7b2e6f4c1d9a0e5f7b3c2d1a6e9f0c1
```

Das ersetzt du dann bei:
```
OPENCLAW_GATEWAY_TOKEN=
```

Dieses Token dient als **API-Auth zwischen Client und Gateway ist das gemeinsame Authentifizierungs-Token zwischen dem OpenClaw-Client (z. B. Webinterface oder andere Dienste) und dem Gateway**.

#### Im Webinterface / Client
Dort gibt es ein Feld wie **Gateway Token** oder **API Token**.
→ **Genau dort trägst du denselben Wert ein**.

#### Beim Verbinden

+ Client sendet Token
+ Gateway prüft Token
+ Nur wenn sie **identisch** sind → Zugriff erlaubt


### 3️⃣ Token oder Passwort?

Du kannst **nur eines** von beiden verwenden.

##### Token (empfohlen)
```
OPENCLAW_GATEWAY_TOKEN=
```

##### Vorteile:

+ besser für APIs
+ sicherer
+ ideal für Automatisierung

#### Passwort (Alternative)
```env
OPENCLAW_GATEWAY_PASSWORD=meinSuperPasswort
```

Nicht gleichzeitig mit Token verwenden.

### 4️⃣ Verzeichnisstruktur

Nach dem ersten Start erstellt OpenClaw meist:
```
~/.openclaw/
 ├── openclaw.json
 ├── state/
 ├── logs/
 └── cache/
```

Wenn du mehrere Instanzen oder Projekte planst (z.B. für dein** KI-Projekt mit Ollama**), kannst du z.B.: 
```
~/ai/openclaw/
```
nutzen. 
Dies ist gegenwärtig nicht der Fall. 

### 5️⃣ Wichtig für Ollama Integration

Wenn du **Ollama** mit OpenClaw kombinierst, solltest du zusätzlich sicherstellen:
```env
OLLAMA_HOST=http://127.0.0.1:11434
```

Dann kann OpenClaw direkt dein lokales LLM ansprechen.

### 6️⃣ Beispiel komplette `.env`

Eine typische **vollständige lokale Installation** sieht so aus:
```
OPENCLAW_GATEWAY_TOKEN=8c3f7c2c0e2d7a0c0b3a4d3f8e1f9c5a7b2e6f4c1d9a0e5f7b3c2d1a6e9f0c1

OPENCLAW_STATE_DIR=/home/daniel/.openclaw
OPENCLAW_CONFIG_PATH=/home/daniel/.openclaw/openclaw.json
OPENCLAW_HOME=/home/daniel

OPENCLAW_LOAD_SHELL_ENV=1
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000

OLLAMA_HOST=http://127.0.0.1:11434
```

### 7️⃣ Datei speichern

Speicherort meistens im Projekt:
```
openclaw/.env
```

oder global:
```
~/.env
```
### ✅ Danach starten:
```bash
openclaw start
```

oder
```bash
npm start
```
(je nach Installationsmethode)


### Gateway auth + paths
Die Gateway-Authentifizierung + Pfade

Der **Gateway-Teil** – das ist im Grunde die Sicherheits- und Systemkonfiguration von OpenClaw. Hier geht’s weniger um externe Anbieter und mehr darum, wie dein eigener Service abgesichert und gestartet wird. 🔐

#### 🔹 OPENCLAW_GATEWAY_TOKEN
```
OPENCLAW_GATEWAY_TOKEN=change-me-to-a-long-random-token
```

👉 **Sehr wichtig**, wenn dein Gateway:

+ nicht nur auf `localhost`
+ sondern z. B. auf `0.0.0.0`
+ oder auf einem Server / VPS
+ oder im Docker-Container öffentlich erreichbar ist

Dann brauchst du einen starken Token.

**Token generieren**

Im Terminal:
```
openssl rand -hex 32
```

Das erzeugt sowas wie:
```
9f3c2e8b7a4d6c1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7
```

👉 Das trägst du dann ein:
```
OPENCLAW_GATEWAY_TOKEN=9f3c2e8b7a4d6c1e0f...
```

💡 Empfehlung:
Immer setzen, sobald du nicht rein lokal arbeitest.

#### 🔹 OPENCLAW_GATEWAY_PASSWORD (Alternative)
```
OPENCLAW_GATEWAY_PASSWORD=change-me-to-a-strong-password
```

Du kannst **entweder Token ODER Passwort** verwenden – nicht beides.

Unterschied:

+ Token → besser für API / automatisierte Clients
+ Passwort → einfacher für manuelle Nutzung

Meine Empfehlung:
👉 Nimm den Token. Ist sauberer und sicherer.

#### 🔹 OPENCLAW_STATE_DIR
```
OPENCLAW_STATE_DIR=~/.openclaw
```

Hier speichert OpenClaw:

+ Sessions
+ Logs
+ temporäre Daten
+ evtl. Cache

Standard ist:
```
~/.openclaw
```

Nur ändern, wenn du:

+ Docker Volumes nutzt
+ mehrere Instanzen betreibst
+ Daten getrennt speichern willst

#### 🔹 OPENCLAW_CONFIG_PATH
```
OPENCLAW_CONFIG_PATH=~/.openclaw/openclaw.json
```

Das ist die Haupt-Konfigurationsdatei.

Ändern nur wenn:

+ du mehrere Konfigurationen parallel fahren willst
+ du ein spezielles Deployment-Setup hast

#### 🔹 OPENCLAW_HOME
```
OPENCLAW_HOME=~
```

Das definiert das Home-Verzeichnis für interne Pfade.

Normalerweise NICHT nötig zu ändern.

Nur relevant bei:

+ Docker
+ CI/CD
+ Service-Usern ohne echtes Home-Verzeichnis

#### 🔹 OPENCLAW_LOAD_SHELL_ENV
```
OPENCLAW_LOAD_SHELL_ENV=1
```

Das sagt OpenClaw:

👉 „Lade Umgebungsvariablen aus meinem Login-Shell-Profil“

Also z. B. aus:

+ `.bashrc`
+ `.zshrc`
+ `.profile`

Praktisch, wenn du API Keys dort gespeichert hast.

#### 🔹 OPENCLAW_SHELL_ENV_TIMEOUT_MS
```
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000
```

Timeout (in Millisekunden), wie lange OpenClaw wartet,  
bis deine Shell-Variablen geladen sind.

Standard: 15 Sekunden

Nur relevant, wenn:

+ dein Server langsam ist
+ SSH-Profile komplex sind

### 🔥 Typische Szenarien
#### 🖥️ Lokal nur für dich

Minimal:
```
OPENCLAW_GATEWAY_TOKEN=<random>
```
Fertig.

#### 🌍 VPS / Public Server

Unbedingt:
```
OPENCLAW_GATEWAY_TOKEN=<sehr lang>
```
Optional zusätzlich:

+ Reverse Proxy (Nginx)
+ HTTPS
+ Firewall

#### 🐳 Docker Setup

Wichtig:

+ `OPENCLAW_STATE_DIR` auf Volume mappen
+ Gateway Token setzen
+ Keine Secrets ins Image packen

#### ⚠️ Sicherheits-Realität

Wenn du `0.0.0.0` bindest ohne Token →
kann jeder auf dein Gateway zugreifen.

Und wenn da dein `OPENAI_API_KEY` drin hängt…
dann bezahlt jemand anderes mit deinem Konto.

Das willst du sicherlich nicht 😅







### Model provider API keys (set at least one)
API-Schlüssel des Modellanbieters (mindestens einen festlegen)

Das **Herzstück** 🔥 – den LLM-Providern (also den KI-Modellen selbst).

#### Ganz wichtig vorweg:
👉 Du brauchst **nur einen Anbieter**, außer du willst Fallbacks oder Load-Balancing. 

**Merke**: Ist der API-Schlüssel mit einem Fehler, wie ein falsches oder vergessenes Zeichen etc., dann wirkt es so, als sei das tägliche Limit überstiegen oder der Schlüssel usw. blockiert. 

#### 🔹 OPENAI_API_KEY
```
OPENAI_API_KEY=sk-...
```

Von OpenAI

So bekommst du ihn:

+ 1. 👉 https://platform.openai.com/
+ 2. Login
+ 3. „API Keys“
+ 4. „Create new secret key“
+ 5. Kopieren (wird nur einmal angezeigt)

Der Key beginnt mit:
```
sk-...
```

💡 Wenn du OpenClaw normal betreibst, ist das oft der Standard-Provider.

#### 🔹 ANTHROPIC_API_KEY
```
ANTHROPIC_API_KEY=sk-ant-...
```

Von Anthropic (Claude Modelle)

+ 1. 👉 https://console.anthropic.com/
+ 2. API Keys
+ 3. „Create Key“

Beginnt mit:
```
sk-ant-...
```

#### 🔹 GEMINI_API_KEY
```
GEMINI_API_KEY=...
```

Von Google (Gemini Modelle)

Du bekommst ihn über Google AI Studio:

+ 1. 👉 https://aistudio.google.com/app/apikey
+ 2. „Create API Key“
+ 3. Projekt auswählen

#### 🔹 OPENROUTER_API_KEY
```
OPENROUTER_API_KEY=sk-or-...
```

Von **OpenRouter**

OpenRouter ist praktisch, wenn du:

+ 1. viele Modelle testen willst
+ 2. mehrere Anbieter über eine API nutzen willst
+ 3. 👉 https://openrouter.ai/
+ 4. Account
+ 5. API Keys

#### 🔹 LIVE Keys (OPENCLAW_LIVE_*)
```
OPENCLAW_LIVE_OPENAI_KEY=...
OPENCLAW_LIVE_ANTHROPIC_KEY=...
OPENCLAW_LIVE_GEMINI_KEY=...
```

👉 Das sind **separate Keys für Live-Streaming / Voice / Realtime**.

Du kannst hier denselben Key eintragen wie oben –
oder einen eigenen, falls du Limits trennen willst.

#### 🔹 Mehrere API Keys (Load Balancing)
```
OPENAI_API_KEYS=sk-1,sk-2
ANTHROPIC_API_KEYS=sk-ant-1,sk-ant-2
GEMINI_API_KEYS=key-1,key-2
```

Das ist für:

+ höhere Last
+ Ratenlimits umgehen
+ automatische Rotation

Wichtig:

+ Keine Leerzeichen
+ Mit Komma trennen

Beispiel:
```
OPENAI_API_KEYS=sk-abc123,sk-def456
```

#### 🔹 GOOGLE_API_KEY
```
GOOGLE_API_KEY=...
```

Wird manchmal zusätzlich für:

+ Google Services
+ Vertex AI
+ Maps
+ spezielle Gemini Endpunkte

Erzeugt in:  
Google Cloud Console → APIs & Services → Credentials

#### 🔹 Weitere optionale Provider

Nur wenn du sie explizit nutzen willst:

**ZAI_API_KEY**  

Zhipu AI (chinesischer Provider)

**AI_GATEWAY_API_KEY**  

Falls du einen zentralen Gateway betreibst

**MINIMAX_API_KEY**  

Minimax AI (China)

**SYNTHETIC_API_KEY**  

Synthetic AI Dienste

👉 Für 90% der Setups brauchst du die nicht.

#### 🔥 Minimal-Setup Empfehlung

Wenn du es simpel willst:
```
OPENAI_API_KEY=sk-...
```
Fertig.

Oder wenn du Claude willst:
```
ANTHROPIC_API_KEY=sk-ant-...
```
Das reicht komplett.

#### ⚠️ Sicherheit

+ Niemals in GitHub pushen
+ `.env` in `.gitignore` 
+ Keine Screenshots posten
+ Nicht in Discord teilen!








### Channels (only set what you enable)
Hier die Kanäle (nur die aktivierenden Kanäle festlegen)

Du brauchst diese Tokens nur für die Dienste, die du wirklich benutzen willst. 
Wenn du z. B. nur Telegram nutzt, kannst du Discord/Slack usw. komplett ignorieren.

#### 🔹 1️⃣ Telegram Bot Token

Für:
```
TELEGRAM_BOT_TOKEN=...
```

So bekommst du ihn:

+ 1. Öffne Telegram
+ 2. Suche nach **Telegram** → `@BotFather`
+ 3. Starte den Chat und tippe:
```
/newbot
```
+ 4. Namen vergeben
+ 5. Username vergeben (muss auf `bot` enden)

Danach bekommst du:
```
123456789:ABCDEF....
```

Um das Telegram Plugin in Openclaw zu aktivieren: 
```bash
openclaw plugins enable telegram
```

Dann neu starten
```bash
openclaw stop
openclaw start
```

oder besser: (In der WSL wird leider ein: `systemctl --user unavailable`-Fehler dazu ausgegeben. Wegen fehlens der `systemd`-Kompatiblität)
```
openclaw gateway restart
```



👉 Das ist dein `TELEGRAM_BOT_TOKEN`.

#### 🔹 2️⃣ Discord Bot Token

Für:
```
DISCORD_BOT_TOKEN=...
```

So bekommst du ihn:

+ 1. Gehe zu **Discord** 
+ 2. Öffne das **Discord Developer Portal**  
👉 https://discord.com/developers/applications
+ 3. „New Application“
+ 4. Links auf **Bot**
+ 5. „Add Bot“
+ 6. „Reset Token“ → kopieren

⚠️ Wichtig:
Unter „Bot“ → Privileged Gateway Intents aktivieren (Message Content Intent).

Um das Discord Plugin in Openclaw zu aktivieren: 
```bash
openclaw plugins enable discord
```

Dann neu starten
```bash
openclaw stop
openclaw start
```

oder besser: (In der WSL wird leider ein: `systemctl --user unavailable`-Fehler dazu ausgegeben. Wegen fehlens der `systemd`-Kompatiblität)
```
openclaw gateway restart
```



#### 🔹 3️⃣ Slack Bot + App Token

Für:
```
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...
```
So bekommst du sie:

+ 1. Gehe zu **Slack**
👉 https://api.slack.com/apps
+ 2. „Create New App“
+ 3. OAuth & Permissions → Bot Token Scopes hinzufügen
+ 4. „Install to Workspace“

Nach Installation bekommst du:

+ `xoxb-...` → Bot Token
+ `xapp-...` → App-Level Token (unter „Basic Information“)

#### 🔹 4️⃣ Twitch Token

Für:
```
OPENCLAW_TWITCH_ACCESS_TOKEN=oauth:...
```

+ 1. Von **Twitch**:
👉 https://dev.twitch.tv/console/apps
+ 2. Neue App erstellen
+ 3. Client ID + Secret
+ 4. Mit OAuth-Tool Access Token generieren



### Tools + voice/media (optional)
Ab hier kommen: Die **Werkzeuge + Sprach-/Medien (optional)**. 

#### 🔹 5️⃣ Brave API Key

Für Websuche via **Brave Software**:
+ 1. 👉 https://api.search.brave.com/
+ 2. Account erstellen
+ 3. API Key generieren

Dann:
```
BRAVE_API_KEY=...
```

#### 🔹 6️⃣ Perplexity API Key

Von **Perplexity AI**:
+ 1. 👉 https://www.perplexity.ai/settings/api
+ 2. API Key erzeugen

Beginnt mit:
```
pplx-...
```

#### 🔹 7️⃣ Firecrawl API Key

Von **Firecrawl**
+ 1. 👉 https://firecrawl.dev
+ 2. Account
+ 3. API Key erstellen

#### 🔹 8️⃣ ElevenLabs (Voice)

Von **ElevenLabs**
+ 1. 👉 https://elevenlabs.io
+ 2. Profil → API Key

Dann:
```
ELEVENLABS_API_KEY=...
```
`XI_API_KEY` ist nur ein Alias – du kannst denselben Key verwenden.

#### 🔹 9️⃣ Deepgram (Speech-to-Text)

Von **Deepgram**
+ 1. 👉 https://console.deepgram.com
+ 2. API Key erstellen




#### 💡 Wichtig

In deiner .env Datei:

# entfernen

Nur die Dienste eintragen, die du brauchst und die Du fertig eingerichtet hast; sollten eingefügt werden. 
Dies halt einige Zeit in Anspruch nimmt. 
Daher der beste Weg, die geannte obrige `.env`-Datei mit der Zeit in einem Editor zu bearbeiten. 

Beispiel:
```
TELEGRAM_BOT_TOKEN=123456:ABCDEF
BRAVE_API_KEY=abc123
```
