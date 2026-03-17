# n8n Installation per GitHub in WSL

**Daniel:**  
Füge n8n von Github der WSL Ubuntu installation dem Ollama und OpenClaw mit hinzu für meinen Lesung MiniPC. Bitte nicht die Docker Variante oder npm Version wählen, sondern per git clone.

**ChatGPT:**  
Alles klar 😎 wir machen das sauber per **git clone**, ohne Docker, ohne npm-Global-Install.  
Ziel: **n8n + Ollama + OpenClaw** zusammen in deiner **WSL Ubuntu** auf dem **Letsung MiniPC**, CPU-basiert.

Ich gehe davon aus:  
- Ubuntu läuft in WSL  
- Ollama ist schon installiert  
- OpenClaw läuft bereits per `pnpm dev` oder Build

---

#### 1️⃣ n8n per GitHub klonen (kein Docker, kein npm -g)

**Repository:**  
[n8n GitHub](https://github.com/n8n-io/n8n)

```bash
cd ~
mkdir projects
cd projects
git clone https://github.com/n8n-io/n8n.git
cd n8n
```



#### Ab hier geht es erst mit Nachfolgendem weiter: 
#### das ist ein klassischer falscher Package-Manager Moment 😄

Du versuchst eventuell ein Monorepo mit `pnpm` + workspaces mit normalem `npm` zu bauen.
Das kann npm nicht richtig – daher:

+ `Unsupported URL Type "workspace:"`
+ `turbo: not found`
+ lauter unknown config Warnungen (die kommen aus `.npmrc` für pnpm)

Kurz gesagt: **n8n wird nicht mit npm gebaut**.

#### 🎯 Was hier wirklich passiert

n8n verwendet:
+ **pnpm**  
+ **Turborepo**  

Workspace Dependencies (`workspace:*`)

npm versteht `workspace:*` nicht → deshalb `EUNSUPPORTEDPROTOCOL`.

#### ✅ Lösung (richtig und sauber)
#### 2️⃣ Prüfen welche Node Version du hast
```bash
node -v
```

Du brauchst **Node 18 oder 20 LTS, mitlerweile 22.22**.

Falls falsch → sag Bescheid, dann richten wir das sauber mit nvm ein. 

#### 🎯 Kurzantwort

+ 👉 Nimm Node 20 LTS.
Das ist aktuell der „Sweet Spot“.

Node 18 geht auch.
Node 22 → eher experimentell in solchen Setups, wird jedoch abverlangt.

#### 🧠 Warum Node 22 oder andere Versionen problematisch sein können

Bei Monorepos können auftreten:
+ native Module build errors
+ ESM / CJS Konflikte
+ Turborepo Probleme
+ unerklärliche Dependency Fehler

Und du willst ja nicht Debug-Hölle spielen 😅 
Es wird 22.16 oder höher 22.22 verlangt.

✅ Sauberer Weg mit nvm (empfohlen)

Falls noch nicht installiert:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

Terminal neu starten.

Dann:
```bash
nvm install 22
nvm use 22
nvm alias default 22
```

Prüfen:
```bash
node -v
```

Sollte sowas zeigen:
```bash
v22.22.x
```
#### 🔥 Danach komplett sauber neu

Im n8n Root:
```bash
cd ~/projects/n8n
rm -rf node_modules
pnpm install
```

Weil es länger dauert... Es kamen zwei Warnungen, die ignoriert werden konnten. 

Danach:
```bash
pnpm build
```

#### 3️⃣ Abhängigkeiten installieren
```bash
npm install
```

2️⃣ pnpm installieren (WICHTIG)

```bash
npm install -g pnpm
```

oder moderner:

```bash
corepack enable
corepack prepare pnpm@latest --activate
```

Dann im **n8n Hauptordner** (nicht im `packages/cli`!):
```bash
cd ~/projects/n8n
pnpm install
```

#### 3️⃣ Projekt sauber neu installieren

Im Hauptordner von n8n:
```bash
rm -rf node_modules
rm package-lock.json
pnpm install
```

Wichtig: **NICHT npm install**

#### 4️⃣ Build starten
```bash
pnpm build
```

oder explizit:
```bash
pnpm turbo run build
```

Jetzt sollte `turbo` automatisch verfügbar sein, weil pnpm es aus dem Monorepo zieht.

##### Hier hatte ich eim Build `@n8n/chat` einen kleinen Fehler, der auf Speicherplatzmangel beim letzten Build erfolgte. Daher wurde noch nachfolgendes bei mir wichtig:

Jetzt bitte exakt das hier:
```bash
cd /home/ubuntu/projects/n8n
pwd
```

Die Ausgabe MUSS sein:
```bash
/home/ubuntu/projects/n8n
```

Erst dann:
```bash
export NODE_OPTIONS="--max-old-space-size=4096"
pnpm --filter @n8n/chat build
```

Die Erweiterung des Arbeitsspeichers auf 4096 hat dazu geholfen. 
Von Hause aus, stellt Linux wohl weniger zur Verfügung.


#### 💡 Warum npm hier nicht funktioniert, war zum Thema: npm/pnpm Problem zuvor. 

Diese Einträge:
```
auto-install-peers
strict-peer-dependencies
hoist
shamefully-hoist
workspace:*
```

sind **pnpm-spezifisch**.

npm denkt:

"Was ist das? Kenn ich nicht."
  → schmeißt Warnungen
  → versteht workspace nicht
  → bricht ab


**Ab hier Fortsetzen**
#### 4️⃣ n8n bauen
```bash
npm run build
cd packages/cli
```

Du hast Linux verlassen, daher zurück und wieder rein mit: 
```
wsl
```



#### 5️⃣ n8n starten (Development Mode)
```bash
cd /home/ubuntu/projects/n8n
pwd
npm run dev
```

oder direkt
```bash
node dist/bin/n8n
```

Webinterface:  http://localhost:5678`

6️⃣ n8n dauerhaft starten (Production Mode ohne Docker)
```bash
node dist/bin/n8n start
```

7️⃣ n8n mit Ollama verbinden

Ollama läuft standardmäßig auf `http://localhost:11434`

In n8n:
+ HTTP Request Node
+ POST
+ URL: http://localhost:11434/api/generate

Body JSON:
```JSON
{
  "model": "llama3",
  "prompt": "Sag Hallo von n8n"
}
```

#### 8️⃣ n8n mit OpenClaw verbinden

OpenClaw läuft vermutlich auf `http://localhost:3000`

HTTP Node → POST:
```code
http://localhost:3000/api/chat
```
Header:
```code
Authorization: Bearer DEIN_TOKEN
```

#### 9️⃣ Optional: Autostart-Script für WSL
```bash
nano ~/start-ai-stack.sh
```

Inhalt:
```bash
#!/bin/bash
ollama serve &
cd ~/openclaw
pnpm dev &
cd ~/projects/n8n/packages/cli
node dist/bin/n8n start
```

Speicherbar und ausführbar machen:
```bash
chmod +x ~/start-ai-stack.sh
```

#### 🔥 Performance Tipps

+ Nutze kleinere Modelle wie llama3:8b-instruct-q4
+ Setze `OLLAMA_NUM_PARALLEL=1`
+ In n8n Max Execution Timeout erhöhen


#### Architektur Überblick

+ Ollama → Dein Gehirn (LLM lokal)
+ OpenClaw → KI-Router / API-Schicht
+ n8n → Automatisierungs-Motor
+ Home Assistant → Smart-Home-System
+ Nginx → Netzwerk-Türsteher (Reverse Proxy)

#### Vollautomatisches AI-Agent-Workflow Setup

+ Trigger → KI denkt → KI entscheidet → Aktion → Kontext speichern
+ Beispiel: „Mach Wohnzimmer gemütlich“
  + n8n sendet an Ollama
  + Ollama liefert JSON: `{ "intent": "licht", "aktion": "warmweiß", "helligkeit": 40 }`
  + n8n wertet aus → Home Assistant steuert Lampen

#### Home Assistant + n8n + Ollama

+ Nutzen: Sprachbefehle ohne Cloud, intelligente Automationen, Kontext, Geräteverknüpfung
+ Beispiel: Strompreis hoch + Wetter sonnig → Waschmaschine später starten

#### LAN Zugriff

+ Aktuell nur localhost
+ Ziel: Zugriff vom Handy, Laptop, WLAN
+ Lösung: WSL Port freigeben + Windows Firewall öffnen + IP nutzen

#### Reverse Proxy mit Nginx

+ Vorteile: SSL, zentrale Auth, Subdomains, Port 80/443
+ Beispiel:
  + ai.lan → OpenClaw
  + flows.lan → n8n
  + home.lan → Home Assistant

#### n8n Integrationen

+ Kategorien: Kommunikation, Smart Home, Dateien, APIs, Datenbanken, KI
+ Du nutzt nur die, die dein Agent braucht

#### Empfohlene Reihenfolge

# LAN Zugriff für n8n
# Nginx Reverse Proxy (intern)
# Home Assistant installieren
# n8n ↔ Home Assistant testen
# Ollama Workflow integrieren
# ersten AI-Agent bauen
# Kontextspeicher einbauen

#### Zielarchitektur
+ Erst LAN, dann kontrollierter Remote-Zugriff
+ MiniPC aktuell runterfahren okay
+ Planung für 24/7 Betrieb oder VPS-Ersatz

```
Internet → Router → Nginx → n8n/OpenClaw/Home Assistant → Ollama
```
+ Ollama → KI-Gehirn
+ n8n → Automatisierung
+ Home Assistant → Smart Home
+ Nginx → Sicherheits-Gateway

#### Phase 1 – LAN Zugriff

+ Starten n8n mit `N8N_HOST=0.0.0.0 N8N_PORT=5678 node dist/bin/n8n start`
+ Windows Firewall Port `5678` freigeben
+ IP des MiniPC im Browser testen

#### Phase 2 – Nginx Reverse Proxy

+ Installation: `sudo apt update && sudo apt install nginx`
+ Test: `http://192.168.x.x`
+ Nginx verteilt intern auf Subdomains

#### Phase 3 – Home Assistant Integration

+ Geräte-Backend für n8n Workflows
+ Verwaltung von Sensoren, Zigbee/Z-Wave etc.

#### Phase 4 – AI-Agent Logik

+ Input → Ollama → JSON → n8n → Home Assistant → Aktion → Kontext speichern

#### Phase 5 – Zugriff von unterwegs

+ Sicher: VPN (WireGuard/Tailscale)
+ Riskant: direkte Portweiterleitung 443
+ VPS später als Proxy möglich

#### Phase 6 – MiniPC 24/7 Betrieb

+ systemd Services: Ollama, OpenClaw, n8n, Nginx
+ Autostart → kleiner Server wie 24/7

#### Vorschlag – Jetzt starten

+ LAN Zugriff für n8n
+ Nginx Reverse Proxy intern
+ Home Assistant installieren
+ AI-Agent bauen

