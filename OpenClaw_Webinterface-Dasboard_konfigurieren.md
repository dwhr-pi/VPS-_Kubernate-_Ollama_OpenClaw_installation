Im Webinterface auf dem Dasboard von OpenClaw

Wenn man das Webinterface aufklappt und zu den gesammten Einstellungen kommt... 

Bei: `Nodes` die **Auto-allow skill CLIs** Allow skill executables listed by the Gateway. auf Enalbe schalten.



### Agenten Problem
Anthropic von Claude steht in der Fehlermelung im Webinterface Dasboard im Chat: 

```
⚠️ Agent failed before reply: No API key found for provider "anthropic". Auth store: /home/ubuntu/.openclaw/agents/main/agent/auth-profiles.json (agentDir: /home/ubuntu/.openclaw/agents/main/agent). Configure auth for this agent (openclaw agents add <id>) or copy auth-profiles.json from the main agentDir.
Logs: openclaw logs --follow
```

Das nachfolgende ergibt mit: 

```bash
openclaw agents list
```

listet zwar den richtigen Agenten auf: 
```bash
🦞 OpenClaw 2026.2.22 (73e5bb7) — Ship fast, log faster. 
Agents: 
- main (default) 
	Workspace: ~/.openclaw/workspace 
	Agent dir: ~/.openclaw/agents/main/agent 
	Model: google/gemini-3-pro-preview 
Routing rules: 0 Routing: default (no explicit rules) Routing rules map channel/account/peer to an agent. Use --bindings for full rules. Channel status reflects local config/creds. For live health: openclaw channels status --probe.
```
Doch es soll laut der Fehlermeldung im Chat `Claude / Anthropic` gestartet werden, deshalb wahrscheinlich auch die Ollama Agenten bisher nicht funktionierten. 

OpenClaw macht das so:

Agent hat ein Modell → `google/gemini-3-pro-preview` ✅

Aber wenn keine expliziten Routing-Regeln gesetzt sind, kann der „Default Provider“ oder ein anderes Modell (z. B. `Claude/Anthropic`) trotzdem ausgewählt werden.

Explizit Routing-Regel für alle Kanäle/Peers:
```bash
openclaw routing set default --agent main
```

```bash
openclaw agents list
openclaw routing list
```

Routingregeln `channel/account/peer` einem Agenten zu ordnen. Verwenden Sie `--bindings` für vollständige Regeln.

Alte Anthropic-/Claude-Fallbacks entfernen
```bash
nano ~/.openclaw/agents/main/agent/agent.json
```
Stelle sicher:
```JSON
{
  "provider": "gemini",
  "model": "google/gemini-3-pro-preview"
}
```

Keine "provider": "anthropic" oder "claude" Einträge mehr.

##### Optional: Cache / Fallbacks leeren

Manchmal merkt sich OpenClaw auch alte Auth/Provider-Kombinationen:
##### 1️⃣ Alte Sessions löschen (ersetzt oft Cache-Cleanup)
```bash
openclaw sessions clear --older-than 7d
```
Oder komplett:
```bash
openclaw sessions clear
```

##### 2️⃣ Memory kompaktieren
```bash
openclaw memory compact
```

Das entfernt alte gespeicherte Kontextdaten.

##### 3️⃣ Logs bereinigen
```bash
openclaw logs clear --older-than 7d
```

##### 4️⃣ Kompletten Zustand zurücksetzen (stärkste Variante)

```bash
openclaw reset
```

Das löscht Sessions, temporäre Daten und baut die Umgebung neu auf.

##### 5️⃣ Manuell Cache löschen (funktioniert immer)

Falls du wirklich alles bereinigen willst:
```bash
rm -rf ~/.openclaw/cache
rm -rf ~/.openclaw/sessions
```

Danach:
```bash
openclaw gateway restart
```

✅ Mein Tipp:
Bei deinem Setup mit Ollama + OpenClaw reicht meistens:
```bash
openclaw sessions clear
openclaw memory compact
```



XXXXXX
**Info**:
+ `openclaw channels status --probe` -  Der Befehl ist ein Diagnosetool, mit dem die Konnektivität und der Betriebszustand konfigurierter Messaging-Kanäle (wie WhatsApp, Telegram oder Discord) innerhalb des OpenClaw-Frameworks überprüft werden können.
+ `openclaw channels status --deep` - Fügt der Statusausgabe eine Gateway-Integritätsprüfungen hinzu (erfordert hierzu ein erreichbares Gateway).
XXXXXX

#### zwei LLMs gleichzeitig nutzen

Du willst dass dein OpenClaw zwei LLMs gleichzeitig nutzt:

+ Gemini (Google)
+ Ollama (lokal)

und beide sollen startklar sein, ohne dass `Claude/Anthropic` dazwischenfunkt. ✅

##### 1️⃣ Ollama Agent hinzufügen

`openclaw agents add ollama-agent --workspace ~/.openclaw/workspace/ollama`
Zuerst einen neuen Agenten für Ollama erstellen (z. B. ollama-agent) falls dies noch nicht gemacht wurde:
```bash
openclaw agents add ollama-agent --workspace ~/.openclaw/workspace/ollama \
  --model llama3.2:1b \
  --provider ollama \
  --base_url http://localhost:11434
```

+ `llama3.2:1b` ist nur ein Beispiel. Passe das an, falls du ein anderes Modell lokal installiert hast.
+ `--base_url` muss auf den laufenden Ollama Server zeigen.

Danach prüfen:
```bash
openclaw agents list
```

Du solltest jetzt sehen:
```
- main        Model: google/gemini-3-pro-preview
- ollama-agent Model: llama3.2:1b
```

##### 2️⃣ Routing einstellen

Damit **Anfragen gezielt zu einem Agenten gehen**, z. B. standardmäßig Gemini, aber für bestimmte Tasks Ollama:

# Standard: alles zu Gemini
```bash
openclaw routing set default --agent main

# Optional: bestimmte Channels/Accounts zu Ollama
openclaw routing set channel YOUR_CHANNEL --agent ollama-agent
```

+ `YOUR_CHANNEL` kann Slack, Discord, Terminal, etc. sein.
+ Du kannst mehrere Routing-Regeln kombinieren, damit z. B. Coding-Aufgaben immer Ollama nutzen und Knowledge Tasks Gemini.

#### 3️⃣ Agenten gleichzeitig starten

Wenn du Docker oder systemd benutzt:
```bash
openclaw start main
openclaw start ollama-agent
```

oder einfach:
```bash
openclaw start --all
```

Damit laufen **beide LLMs parallel**.

#### 4️⃣ Testen
# Interagiere direkt mit Gemini
```bash
openclaw agents interact main

# Interagiere direkt mit Ollama
openclaw agents interact ollama-agent
```

So siehst du sofort, dass beide Modelle verfügbar sind.

##### 💡 Tipp:
Wenn du willst, kann ich dir ein komplettes Beispiel-Setup schreiben, in dem **OpenClaw Gemini + Ollama + Brave Search + Firecrawl parallel läuft**, inklusive Routing-Regeln, sodass Claude/Anthropic komplett ignoriert wird.

XXXXXX
##### 2️⃣ OpenClaw Agent auf Ollama umstellen

Der schnellste Weg:
```bash
openclaw agents edit ollama-agent
```
Den Befehl gibt es bloß hierbei nicht. Daher nachfolgend. 
XXXXXX

##### 🔧 Alternative Möglichkeiten einen Agent zu ändern

###### 1️⃣ Agent-Config direkt bearbeiten (empfohlen)

OpenClaw speichert jeden Agenten als Ordner mit Config-Dateien.

Typischer Pfad:
```
$OPENCLAW_HOME/.openclaw/agents/ollama-agent/
```

oder bei dir vermutlich:
```bash
~/.openclaw/agents/ollama-agent/
```
Dann einfach:
```bash
nano ~/.openclaw/agents/ollama-agent/agent/config.json
```

```json
{
  "model": "ollama/llama3.2:1b",
  "provider": "ollama"
}
```

besser: 
```json
{
  "model": "ollama/llama3.2:1b",
  "provider": "ollama",
  "parameters": {
    "temperature": 0.7,
    "max_tokens": 1024
  }
}
```


oder die YAML
```bash
nano ~/.openclaw/agents/ollama-agent/agent/agent.yaml
```

Dort kannst du z. B. ändern:
```YAML
model: ollama/llama3.2:1b
provider: ollama
```

Danach OpenClaw neu starten.
XXXXXX

Der Befehl `openclaw agents edit ollama-agent` konnte also gar nicht funktionieren, weil kein Agent-Verzeichnis existiert.

###### 🔎 Schritt 1 – Prüfen welche Agents wirklich existieren

Bitte einmal ausführen:
```bash
openclaw agents list
```

Dort siehst du z. B.:
```
Agents:
- main (default)
```
In den meisten Installationen gibt es nur `main`.

###### 🔎 Schritt 2 – Ordnerstruktur prüfen
```bash
ls -la ~/.openclaw/agents
```
Beispiel:
```
main/
```

Wenn dort kein `ollama-agent` steht, wurde er nie erstellt.

###### 🧠 Schritt 3 – Ollama Agent korrekt erstellen

Jetzt erstellen wir ihn sauber:
```bash
openclaw agents create ollama-agent
```

Danach prüfen:
```bash
ls -la ~/.openclaw/agents
```

Jetzt sollte erscheinen:
```bash
ollama-agent/
```
###### ⚙️ Schritt 4 – Config erstellen

Dann:
```bash
nano ~/.openclaw/agents/ollama-agent/config.json
```

Inhalt:
```JSON
{
  "model": "ollama/llama3.2:1b",
  "provider": "ollama"
}
```

Wenn `~/.openclaw/agents/ollama-agent/agent/config.json` noch nicht existiert, einfach den Ordner agent erstellen:

##### 1️⃣ Agent-Ordnerstruktur
Ordnerstruktur prüfen
```bash
ls -la ~/.openclaw/agents/ollama-agent/
```

Pfad: `~/.openclaw/agents/ollama-agent/agent/`
```bash
mkdir -p ~/.openclaw/agents/ollama-agent/agent
```

##### 2️⃣ config.json für Ollama-Agent

Ordnerstruktur prüfen
```bash
ls -la ~/.openclaw/agents/ollama-agent/agent/
```

Datei: `~/.openclaw/agents/ollama-agent/agent/config.json`
```bash
nano ~/.openclaw/agents/ollama-agent/agent/config.json
```

Die Datei soll so aussehen: 
```JSON
{
  "model": "ollama/llama3.2:1b",
  "provider": "ollama"
}
```

Optional kannst du noch `parameters` hinzufügen, z. B. `temperature` oder `max_tokens` des Modells:


```JSON
{
  "model": "ollama/llama3.2:1b",
  "provider": "ollama",
  "parameters": {
    "temperature": 0.7,
    "max_tokens": 1024
  }
}
```

#### Routing


##### 3️⃣ Globales Routing einrichten

Datei:`~/.openclaw/routing.json`

Wenn sie noch nicht existiert:
```bash
nano ~/.openclaw/routing.json
```

Inhalt:
```json
{
  "rules": [
    {
      "agent": "main",
      "fallback": "ollama-agent",
      "condition": "provider_unavailable"
    }
  ]
}
```

Erklärung:

+ `agent: "main"` → dein Standard-Agent (der aktuell Google Gemini nutzt)
+ `fallback: "ollama-agent"` → wird genutzt, wenn der Haupt-Agent nicht verfügbar ist
+ `condition: "provider_unavailable"` → z. B. Rate-Limit oder Cooldown

Damit sagt OpenClaw: „Wenn Gemini gerade nicht antwortet, nimm automatisch Ollama.“


Wenn `~/.openclaw/agents/main/agent/routing.json` noch nicht existiert, einfach den Ordner agent erstellen:

```bash
mkdir -p ~/.openclaw/agents/main/agent/
nano ~/.openclaw/agents/main/agent/routing.json
```


```JSON
{
  "rules": [
    {
      "agent": "main",
      "fallback": "ollama-agent",
      "condition": "provider_unavailable"
    }
  ]
}
```


###### 🔎 Schritt 5 – Prüfen ob Ollama läuft

Der Agent funktioniert nur wenn Ollama aktiv ist:
```base_url
ollama list
```

Wenn kein Modell da ist:
```bash
ollama pull llama3
```
##### 🚀 Optional (empfohlen für dein Setup)

Da du mit OpenClaw + Ollama arbeitest, ist die bessere Struktur:
```
agents
 ├ main
 ├ ollama-coder
 ├ ollama-research
 └ cloud-reasoning
```
Dann kann OpenClaw **automatisch das richtige Modell auswählen**.

Das nennt sich **Routing Agent Setup** und ist extrem stark für KI-Dev-Systeme. 


XXXXXX

#### Lösung 1 (am schnellsten): Agent auf Gemini umstellen

Öffne die Config:
```bash
nano ~/.openclaw/agents/main/agent/config.json
```

Beispiel:
```json
{
  "model": "ollama/llama3.2:1b",
  "fallback_models": [
    "google/gemini-1.5-flash"
  ]
}
{
  "model": "google/gemini-3-pro-preview",
  "providers": {
    "google": {
      "apiKey": "$GOOGLE_API_KEY"
    }
  }
}
{
  "name": "ollama-agent",
  "model": "ollama/llama3.2:1b",
  "parameters": {
    "temperature": 0.7,
    "max_tokens": 1024
  },
  "provider": "ollama",
  "baseUrl": "http://localhost:11434",
  "description": "Ollama LLaMA 3 Agent für OpenClaw",
  "type": "llm"
}
```

Dann API-Key setzen:
```bash
export GOOGLE_API_KEY=DEIN_KEY
```







Danach OpenClaw neu starten:
```bash
openclaw restart
```

#### Lösung 2: Komplett lokal mit Ollama (empfohlen für dein Setup)

Wenn du **keine Cloud-API willst**, stelle den Agent so ein:

```bash
nano ~/.openclaw/agents/main/agent/config.json
```

```json
{
  "model": "ollama/llama3",
  "providers": {
    "ollama": {
      "baseURL": "http://localhost:11434"
    }
  }
}
```

Dann sicherstellen:

```bash
ollama serve
ollama pull llama3
```

Test:
```bash
ollama run llama3
```
##### Prüfen welcher Agent wirklich aktiv ist
```bash
openclaw agents list
```

Du solltest dann sehen:
```
Model: ollama/llama3
```

oder
```
Model: google/gemini-3-pro-preview
```

Wenn dort **anthropic/claude** steht → wird immer wieder der Fehler kommen.

#### Wenn OpenClaw trotzdem Claude startet

Dann liegt meist eine **Routing-Regel** oder **Environment Variable** vor.

Prüfe:
```bash
env | grep -i anthropic
```
oder
```bash
env | grep -i claude
```
Wenn vorhanden:
```bash
unset ANTHROPIC_API_KEY
```

##### 💡 Mein Verdacht aus deinen vorherigen Logs:
OpenClaw hat noch eine alte Claude Default-Route, deshalb wird Gemini ignoriert.


XXXXXX


###### 2️⃣ Agent löschen und neu erstellen

Falls du größere Änderungen brauchst:
```bash
openclaw agents delete ollama-agent
```
danach:
```bash
openclaw agents create ollama-agent
```

###### 3️⃣ Modell global setzen

Wenn du willst, dass **Ollama statt Gemini oder Claude verwendet wird**, kannst du auch die **Env-Variable** setzen:
```bash
export OPENCLAW_DEFAULT_MODEL=ollama/llama3
```

oder in:
```bash
openclaw.env
```
Da diese Änderungen und Ergänzugen in der `.env` der Frund waren, weswegen wir die Änderungen hier vornehmen, hat sich das mit der `.env` erledigt. 

✅ Kurz gesagt:
`openclaw agents edit` gibt es in dieser Version von OpenClaw nicht → Der Agent wird **direkt über die Config-Datei editiert**.
XXXXXX



Dann Model ändern auf z. B.:
```bash
ollama/llama3
```

oder
```bash
ollama/mistral
```

Speichern.

##### 3️⃣ Alternative: direkt per CLI setzen
```bash
openclaw agents set-model ollama-agent ollama/llama3
```

##### 4️⃣ OpenClaw neu starten
```bash
openclaw gateway restart
```
##### 5️⃣ Kontrolle
```bash
openclaw agents list
```

Dann sollte stehen:
```bash
ollama-agent
Model: ollama/llama3
```

##### 6️⃣ Optional (sehr wichtig)

Wenn du willst, dass OpenClaw automatisch Ollama nutzt, setze eine Routing-Rule:

openclaw routing add --agent ollama-agent --channel cli


Dann läuft alles lokal.
XXXXXX




#### komplettes OpenClaw-Setup für Gemini + Ollama + Brave Search + Firecrawl
Ein **komplettes OpenClaw Setup**, das **Gemini + Ollama + Firecrawl + Brave Search** parallel laufen lässt, **Claude/Anthropic wird ignoriert**, und Routing-Regeln sind sauber gesetzt. Ich gebe dir die Schritt-für-Schritt-Konfiguration. 🦾

##### 1️⃣ Ordnerstruktur

Ich gehe davon aus, dass dein Workspace in `~/.openclaw/workspace` liegt:
```
~/.openclaw/
│
├─ workspace/
│
├─ agents/
│  ├─ main/           # Gemini Agent
│  └─ ollama-agent/   # Ollama Agent
│
└─ auth-profiles.json # alle API Keys
```

##### 2️⃣ Auth-Profiles

Datei: `~/.openclaw/auth-profiles.json`
```JOSON
{
  "gemini": {
    "api_key": "DEIN_GEMINI_API_KEY"
  },
  "brave": {
    "api_key": "DEIN_BRAVE_API_KEY"
  },
  "firecrawl": {
    "api_key": "DEIN_FIRECRAWL_API_KEY"
  }
}
```

+ `Claude/Anthropic`: löschen oder nicht eintragen.

##### 3️⃣ Agenten erstellen
+🔹 Gemini Agent (main)
```bash
openclaw agents add main \
  --workspace ~/.openclaw/workspace \
  --model google/gemini-3-pro-preview \
  --provider gemini
```

+ Prüfen:
```bash
openclaw agents list

# Model: google/gemini-3-pro-preview
```
---
+ 🔹 Ollama Agent (ollama-agent)
```bash
openclaw agents add ollama-agent \
  --workspace ~/.openclaw/workspace/ollama \
  --model llama3:8b \
  --provider ollama \
  --base_url http://localhost:11434
```

+ Prüfen:
```bash
openclaw agents list

# Model: llama3:8b
```
+ 🔹 Firecrawl Agent (`firecrawl-agent`)
```bash
openclaw agents add firecrawl-agent \
  --workspace ~/.openclaw/workspace/firecrawl \
  --model firecrawl \
  --provider firecrawl
```

+ Prüfen:
```bash
openclaw agents list

# Model: firecrawl
```

---
+ 🔹 Brave Search Agent (`brave-agent`)
```bash
openclaw agents add brave-agent \
  --workspace ~/.openclaw/workspace/brave \
  --model brave \
  --provider brav
```
---

#### 4️⃣ Routing-Regeln

+ **Standard**: alles geht an Gemini
```bash
openclaw routing set default --agent main
```

+ **Ollama**: für Coding / lokale Tasks
```bash
openclaw routing set channel coding --agent ollama-agent
```

+ **Firecrawl**: für Dokumentensuche / Knowledge Tasks
```bash
openclaw routing set channel knowledge --agent firecrawl-agent
```

+ **Brave**: für Web-Fetch Tasks
```bash
openclaw routing set channel web --agent brave-agent
```
##### 5️⃣ Agenten starten
```bash
openclaw start --all
```

+ Prüfen Status:
```bash
openclaw agents list
openclaw routing list
```

+ Direkt testen:
```bash
openclaw agents interact main          # Gemini
openclaw agents interact ollama-agent  # Ollama
openclaw agents interact firecrawl-agent
openclaw agents interact brave-agent
```

###### 6️⃣ Extra Tipps

+ 1. Keine Claude/Anthropic-Fallbacks mehr
	+ Prüfe `agent.json` jeder Agenten: "provider": "claude" darf nicht drinstehen.
+ 2. **Ollama lokal vorbereiten**:

	```bash
	ollama pull llama3
	```

	+ Base URL muss passen (`http://localhost:11434`)

+ 3. **API Keys** in `auth-profiles.json` für Gemini, Brave, Firecrawl hinterlegen.
+ 4. **Autostart beim Serverstart**:
```bash
openclaw start --all --daemon
```

#### fertige Konfigurationsdateien

Die fertigen Konfigurationsdateien für alle Agenten + Routing, die du einfach übernehmen kannst. Damit läuft alles sofort: Gemini + Ollama + Firecrawl + Brave, Claude/Anthropic wird komplett ignoriert.
---
##### 1️⃣ `auth-profiles.json`

Pfad: `~/.openclaw/auth-profiles.json`

```JSON
{
  "gemini": {
    "api_key": "DEIN_GEMINI_API_KEY"
  },
  "brave": {
    "api_key": "DEIN_BRAVE_API_KEY"
  },
  "firecrawl": {
    "api_key": "DEIN_FIRECRAWL_API_KEY"
  }
}
```

	**Hinweis**: `Claude/Anthropic` muss hier **nicht** eingetragen werden.

##### 2️⃣ Gemini Agent (`main/agent/agent.json`)
```JSON
{
  "provider": "gemini",
  "model": "google/gemini-3-pro-preview",
  "workspace": "~/.openclaw/workspace",
  "routing": "default"
}
```

##### 3️⃣ Ollama Agent (ollama-agent/agent/agent.json)
```JSON
{
  "provider": "ollama",
  "model": "llama3:8b",
  "base_url": "http://localhost:11434",
  "workspace": "~/.openclaw/workspace/ollama",
  "routing": "coding"
}
```

	**Vorbereitung:**
	```bash
	ollama pull llama3
	```
##### 4️⃣ Firecrawl Agent (`firecrawl-agent/agent/agent.json`)
```JSON
{
  "provider": "firecrawl",
  "model": "firecrawl",
  "workspace": "~/.openclaw/workspace/firecrawl",
  "routing": "knowledge"
}
```

##### 5️⃣ Brave Search Agent (`brave-agent/agent/agent.json`)
```JSON
{
  "provider": "brave",
  "model": "brave",
  "workspace": "~/.openclaw/workspace/brave",
  "routing": "web"
}
```

##### 6️⃣ Routing-Tabelle (routing.json optional, oder über CLI setzen)
```JSON
{
  "default": "main",
  "coding": "ollama-agent",
  "knowledge": "firecrawl-agent",
  "web": "brave-agent"
}
```

CLI-Alternative:
```bash
openclaw routing set default --agent main
openclaw routing set channel coding --agent ollama-agent
openclaw routing set channel knowledge --agent firecrawl-agent
openclaw routing set channel web --agent brave-agent
```

##### 7️⃣ Starten aller Agenten

```bash
openclaw start --all
```

+ Prüfen:
```bash
openclaw agents list
openclaw routing list
```

+ Test:
```bash
openclaw agents interact main
openclaw agents interact ollama-agent
openclaw agents interact firecrawl-agent
openclaw agents interact brave-agent
```

✅ Mit dieser Konfiguration hast du jetzt:

+ **Gemini**: Standard für die meisten Aufgaben
+ **Ollama**: für Coding / lokale Tasks
+ **Firecrawl**: für Dokumentensuche / Knowledge Tasks
+ **Brave**: für Web-Fetch Tasks

**Claude/Anthropic wird** komplett **ignoriert**.

#### Shell-Script
Ein einfaches Shell-Skript, das **alle Agenten-Ordner**, `agent.json`**-Dateien und Routing-Regeln automatisch erstellt**. Du musst danach nur noch **deine API Keys** in `auth-profiles.json` eintragen – alles andere ist fertig. 🦾

##### 1️⃣ Script: `setup_openclaw_agents.sh`
```bash
#!/bin/bash
# OpenClaw Multi-Agent Setup: Gemini + Ollama + Firecrawl + Brave

BASE_DIR="$HOME/.openclaw"
WORKSPACE="$BASE_DIR/workspace"
AGENTS_DIR="$BASE_DIR/agents"

echo "==> Erstelle Basis-Ordner..."
mkdir -p "$WORKSPACE"
mkdir -p "$AGENTS_DIR/main/agent"
mkdir -p "$AGENTS_DIR/ollama-agent/agent"
mkdir -p "$AGENTS_DIR/firecrawl-agent/agent"
mkdir -p "$AGENTS_DIR/brave-agent/agent"

echo "==> Erstelle auth-profiles.json (API Keys eintragen)..."
cat > "$BASE_DIR/auth-profiles.json" <<EOL
{
  "gemini": {
    "api_key": "DEIN_GEMINI_API_KEY"
  },
  "brave": {
    "api_key": "DEIN_BRAVE_API_KEY"
  },
  "firecrawl": {
    "api_key": "DEIN_FIRECRAWL_API_KEY"
  }
}
EOL

echo "==> Erstelle Gemini Agent..."
cat > "$AGENTS_DIR/main/agent/agent.json" <<EOL
{
  "provider": "gemini",
  "model": "google/gemini-3-pro-preview",
  "workspace": "$WORKSPACE",
  "routing": "default"
}
EOL

echo "==> Erstelle Ollama Agent..."
cat > "$AGENTS_DIR/ollama-agent/agent/agent.json" <<EOL
{
  "provider": "ollama",
  "model": "llama3:8b",
  "base_url": "http://localhost:11434",
  "workspace": "$WORKSPACE/ollama",
  "routing": "coding"
}
EOL

echo "==> Erstelle Firecrawl Agent..."
cat > "$AGENTS_DIR/firecrawl-agent/agent/agent.json" <<EOL
{
  "provider": "firecrawl",
  "model": "firecrawl",
  "workspace": "$WORKSPACE/firecrawl",
  "routing": "knowledge"
}
EOL

echo "==> Erstelle Brave Agent..."
cat > "$AGENTS_DIR/brave-agent/agent/agent.json" <<EOL
{
  "provider": "brave",
  "model": "brave",
  "workspace": "$WORKSPACE/brave",
  "routing": "web"
}
EOL

echo "==> Setze Routing-Regeln..."
openclaw routing set default --agent main
openclaw routing set channel coding --agent ollama-agent
openclaw routing set channel knowledge --agent firecrawl-agent
openclaw routing set channel web --agent brave-agent

echo "==> Fertig! Alle Agenten erstellt. Starte jetzt:"
echo "openclaw start --all"
```

##### 2️⃣ Verwendung

1. Script speichern, z. B.:
```bash
nano setup_openclaw_agents.sh
```

2. Ausführbar machen:
```bash
chmod +x setup_openclaw_agents.sh
```

3. Ausführen:
```bash
./setup_openclaw_agents.sh
```

4. Danach nur noch **API Keys in `~/.openclaw/auth-profiles.json` eintragen**.

5. Alle Agenten starten:
```bash
openclaw start --all
```

6. Testen:
```bash
openclaw agents interact main          # Gemini
openclaw agents interact ollama-agent  # Ollama
openclaw agents interact firecrawl-agent
openclaw agents interact brave-agent
```

#### 💡 Bonus-Tipp:
Du kannst das Script später jederzeit wieder ausführen, z. B. um **neue Versionen von Ollama oder Gemini** zu aktualisieren – die Struktur wird automatisch korrekt angelegt.



