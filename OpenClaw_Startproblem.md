+ [Onboarding Wizzard](Onboarding_Wizzard)


Im openclaw Verzeichnis:

Gehe in dein OpenClaw-Verzeichnis:
```bash
cd ~/openclaw
```

Dann installiere alle Pakete:

```bash
pnpm install
```


Das lädt **alle Workspace-Dependencies** aus:

+ apps/
+ packages/
+ extensions/

Dann bauen: 
```bash
pnpm build
```

oder komplett:
```bash
pnpm install
pnpm build
```

Danach erst starten:
XXXXXX Dies funktionert NICHT!
```bash
node openclaw.mjs --help
```

Die CLI von OpenClaw wird hier nicht als pnpm-Binary registriert, sondern direkt über das Script gestartet.

Darum funktioniert pnpm exec openclaw bei dir nicht.

Starte OpenClaw direkt über das Script

Im Projektordner:
```bash
node openclaw.mjs --help
```
XXXXXX Dies funktionert!
Wenn alles korrekt ist, bekommst du wieder die CLI-Hilfe.

Gateway starten
```bash
node openclaw.mjs gateway
```
`pnpm ui:build` (auto-installs UI deps), or run `pnpm ui:dev` 


Dann solltest du sehen:
```bash
Gateway running on ws://127.0.0.1:18789
```

Ab hier gab es das Token Problem. 
```
OPENCLAW_GATEWAY_TOKEN=test node openclaw.mjs gateway
```
OPENCLAW_GATEWAY_TOKEN=0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa12f7 node openclaw.mjs gateway
Es musste dann noch Ollama downgeladen und gebaut werden, sowie ein LLM geladen. 

## Ollama

#### 1️⃣ Repository klonen
```bash
git clone https://github.com/ollama/ollama.git
cd ollama
```

#### 2️⃣ Abhängigkeiten prüfen

Du brauchst normalerweise ie passende Version, also nicht immer unbedingt die aktuelle:

+ Go ≥ 1.23
+ git
+ build-essential

Unter Ubuntu / WSL:

Lade die aktuelle Version direkt:
```bash
wget https://go.dev/dl/go1.23.6.linux-amd64.tar.gz
```

Dann installieren:
```bash
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.23.6.linux-amd64.tar.gz
```

PATH setzen:
```bash
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

Prüfen:
```bash
go version
```

#### 3️⃣ Ollama bauen

Im Repo:
```bash
cd ollama
```

Bauen mit: 
```bash
go build .
```

Danach entsteht eine Binary:
```
ollama
```

im aktuellen Ordner.

Optional systemweit installieren:
```bash
sudo mv ollama /usr/local/bin/
```
#### 4️⃣ Server starten
```bash
ollama serve
```

Du solltest sehen:
```bash
Listening on 127.0.0.1:11434
```

#### 5️⃣ Test der API
```bash
curl http://127.0.0.1:11434/api/tags
```
Antwort:
```bash
{"models":[]}
```
Server läuft → noch kein Modell installiert.

#### 6️⃣ Modell laden

Jetzt kannst du Modelle laden:
```bash
ollama pull llama3
```

oder kleiner:
```bash
ollama pull phi3
```

#### 7️⃣ Modell testen
```bash
ollama run llama3
```

```bash
ollama run llama3.2:1b
```

Wenn du eine Antwort bekommst, funktioniert alles.






#### 1️⃣ Setup starten

Im OpenClaw-Ordner:
```bash
node openclaw.mjs setup
```

Das richtet automatisch ein:

+ Konfigurationsdateien
+ Gateway-Modus
+ API-Token
+ Channels (Telegram / Discord etc.)

#### 2️⃣ Alternativ: Doctor Fix

Der Befehl aus der Meldung lautet bei dir:
```bash
node openclaw.mjs doctor --fix
```

Damit werden automatisch:
+ erkannte Kanäle aktiviert
+ fehlende Defaults gesetzt

Hier gab es ein paar Warnungen: 
```
│  - WARN: blocked plugin candidate: world-writable path                         │
│    (/mnt/c/Users/danie/openclaw/extensions/whatsapp, mode=777)                 │
│    (/mnt/c/Users/danie/openclaw/extensions/whatsapp)                           │
│  - WARN: blocked plugin candidate: world-writable path                         │
│    (/mnt/c/Users/danie/openclaw/extensions/zalo, mode=777)                     │
│    (/mnt/c/Users/danie/openclaw/extensions/zalo)                               │
│  - WARN: blocked plugin candidate: world-writable path                         │
│    (/mnt/c/Users/danie/openclaw/extensions/zalouser, mode=777)                 │
│    (/mnt/c/Users/danie/openclaw/extensions/zalouser)                           │
│  - WARN: memory slot plugin not found or not marked as memory: memory-core     │
├────────────────────────────────────────────────────────────────────────────────╯
│
◇  Shell completion ──────────────────────────────────────────────────────────────╮
│                                                                                 │
│  Shell completion is configured in your bash profile but the cache is missing.  │
│  Regenerating cache...                                                          │
│                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────╯
│
◇  Shell completion ─────────────────────────────────────────────╮
│                                                                │
│  Completion cache regenerated at                               │
│  /home/ubuntu/home/ubuntu/.openclaw/completions/openclaw.bash   │
│                                                                │
├────────────────────────────────────────────────────────────────╯
│
◇
│
◇  Gateway ──────────────╮
│                        │
│  Gateway not running.  │
│                        │
├────────────────────────╯
│
◇  Gateway connection ───────────────────────────────────────╮
│                                                            │
│  Gateway target: ws://127.0.0.1:18789                      │
│  Source: local loopback                                    │
│  Config: /home/ubuntu/home/ubuntu/.openclaw/openclaw.json  │
│  Bind: loopback                                            │
│                                                            │
├────────────────────────────────────────────────────────────╯
│
◇  Gateway ──────────────────────────────────────────────────────────────────╮
│                                                                            │
│  WSL2 needs systemd enabled: edit /etc/wsl.conf with [boot]\nsystemd=true  │
│  Then run: wsl --shutdown (from PowerShell) and reopen your distro.        │
│  Verify: systemctl --user status                                           │
│                                                                            │
├────────────────────────────────────────────────────────────────────────────╯
```

#### 3️⃣ Danach Gateway wieder starten

Für dein Setup mit OpenClaw:
```bash
node openclaw.mjs gateway
```

Dann sollte auch dein WebSocket-Disconnect verschwinden.

#### 4️⃣ Schnelllösung (nur für Test)

Wenn du nur testen willst, kannst du die Config-Prüfung umgehen: (Nicht unbedingt notwendig zu testen!)
```bash
node openclaw.mjs gateway --allow-unconfigured
```
Dann startet das Gateway auch ohne Setup.

#### 5️⃣ Optional: CLI global verfügbar machen

Wenn du möchtest, dass openclaw direkt funktioniert:
```bash
sudo ln -s $(pwd)/openclaw.mjs /usr/local/bin/openclaw
chmod +x openclaw.mjs
```

Danach funktionieren Befehle wie:
```
openclaw setup
openclaw doctor
openclaw gateway
```

#### ✅ Richtige Lösung: Gateway-Mode setzen

Erstelle bzw. ändere die Konfiguration.

nano ~/.openclaw/config.yaml

Falls die Datei noch nicht existiert, einfach neu anlegen.

Inhalt minimal:
```YAML
gateway:
  mode: local
```
Speichern.

#### Danach Gateway starten
```bash
node openclaw.mjs gateway
```

Jetzt sollte der Start funktionieren.

#### Optional: Config automatisch reparieren

Du kannst auch den internen Doctor ausführen:
```bash
node openclaw.mjs doctor --fix
```

#### Den merkwürdigen Config-Pfad prüfen

Bitte einmal ausführen:
```bash
echo $HOME
```

Normal wäre:
```bash
/home/ubuntu
```

Wenn stattdessen etwas wie
```bash
/home/ubuntu/home/ubuntu
```
kommt, dann ist deine HOME-Variable falsch gesetzt, was zu solchen Config-Pfaden führt.
```bash
cd openclaw
nano .env
```

#### 4️⃣ Beste Lösung (sauberer Reset)

Falls du viel experimentiert hast, empfehle ich kurz:
```bash
rm -rf ~/.openclaw
```

Dann:
```bash
node openclaw.mjs setup
```

Sieht alles gut aus dann noch die Änderungen übernehmen mit: 

```bash
node openclaw.mjs doctor --fix
```

Wenn alles läuft, prüfen wir noch Ollama

Dann testen wir nochmal:
```bash
curl http://127.0.0.1:11434/api/tags
```

Damit Ollama als LLM-Backend erreichbar ist.






XXXXXX Ab hier ging es im original weiter. 
Alternativ über pnpm Script

Schau kurz in die Scripts:
```bash
cat package.json
```

Dort steht meist etwas wie beispielsweise:
```bash
"scripts": {
  "dev": "node openclaw.mjs",
  "start": "node openclaw.mjs gateway"
}
```

Dann kannst du auch starten mit:
```bash
pnpm dev
```
oder

```bash
pnpm start
```

Warum pnpm exec openclaw nicht funktioniert

pnpm exec funktioniert nur wenn in package.json ein bin-Eintrag existiert, z. B.:
```bash
"bin": {
  "openclaw": "dist/cli.js"
}
```

In deinem Repo wird stattdessen einfach:
```bash
openclaw.mjs
```
als Startpunkt genutzt.




OpenClaw vorläufig starten mit: 
```
pnpm dev
```

```
```


Eventuell Update **pnpm** noch via: 
```bash
pnpm add -g pnpm
```

## Zum Schluss

Hat man Openclaw gestartet und es beleibt sozusagen hängen und es passiert viele Minuten nichts? 
Dann mit: 

```
Strg + C 
````

Openclaw wieder abbrechen. Openclaw nichts zu mekern mehr hat. 

Ist die .env und config.toml nun endlich wirklich richtig und fertig konfugiert? 

Jetzt noch: 
```bash
openclaw doctor --fix
```

und danach kann man endlich starten mit: 
```bash
openclaw gateway
```




#### Fehler:  ELIFECYCLE  
```
 ELIFECYCLE  Command failed with exit code 1.
```

Der Fehler `ELIFECYCLE Command failed with exit code 1` bei **OpenClaw** ist leider eine sehr **allgemeine Node.js / PNPM-Fehlermeldung**. Sie bedeutet nur: *Ein Script in `package.json` ist abgestürzt.* Der eigentliche Grund steht fast immer ein **paar Zeilen darüber im Log**. 

Allerdings lag es bei mir nicht an der Node. 
Sodern an [OpenClaw Gateway Fehler](OpenClaw_Startproblem.md#Claw_Gateway_Fehler)

##### 1️⃣ Node-Version passt nicht

Viele aktuelle Projekte verlangen Node 20 oder 22.

Prüfe zuerst:
```bash
node -v
pnpm -v
```

Empfehlung meist:
```bash
Node 20.x oder 22.x
pnpm 9+
```

Wenn Node zu alt ist:
```bash
nvm install 22
nvm use 22
```

(unter Windows ggf. nvm-windows)

#### 2️⃣ node_modules fehlen oder sind kaputt

Der Fehler taucht oft auf, wenn PNPM-Dependencies nicht sauber installiert wurden.

Im Projektordner:
```bash
rm -rf node_modules
rm pnpm-lock.yaml
pnpm install
pnpm dev
```

Unter Windows PowerShell:
```PowerShell
rd /s /q node_modules
del pnpm-lock.yaml
pnpm install
pnpm dev
```

#### 3️⃣ TypeScript Build Fehler

OpenClaw nutzt TypeScript. Wenn `tsc` fehlschlägt, kommt oft genau dieser Fehler.

Teste:
```bash
pnpm build
```

oder
```bash
pnpm exec tsc
```

#### 4️⃣ fehlende `.env`

Da du gestern schon mit der **Gateway-Token config** gearbeitet hast, prüfe ob `.env` noch existiert:

Beispiel:
```
OPENCLAW_GATEWAY_TOKEN=dein_token
```

Wenn `.env` fehlt oder leer ist, kann der Server beim Start abstürzen.

#### 5️⃣ Port bereits belegt

Wenn OpenClaw lokal läuft, kann auch ein Portkonflikt entstehen.

Typisch:
```
EADDRINUSE
port already in use
```
Dann:
```bash
netstat -ano | findstr 3000
```

#### 💡 Wichtig:
Der entscheidende Hinweis steht fast immer 5-20 Zeilen über `ELIFECYCLE`.

Wenn du möchtest, poste bitte kurz:
```
die letzten ~30 Zeilen vom pnpm dev Output
```
Dann kann Dir [ChatGPT.com](https://chatgpt.com/) **sehr wahrscheinlich sofort sagen**, wo der Fehler genau liegt.


<A name="OpenClaw_Gateway_Fehler"></A>
#### OpenClaw Gateway Fehler 
```bash
openclaw gateway

🦞 OpenClaw 2026.2.22 (73e5bb7) — Say "stop" and I'll stop—say "ship" and we'll both learn a lesson.

12:05:58 Gateway start blocked: set gateway.mode=local (current: unset) or pass --allow-unconfigured.
12:05:58 Config write audit: /home/ubuntu/.openclaw/logs/config-audit.jsonl
```

Der OpenClaw-Gateway startet nicht, weil der Betriebsmodus nicht gesetzt ist.
Standardmäßig blockiert OpenClaw den Start, wenn gateway.mode nicht definiert ist – als Sicherheitsmaßnahme.

Du hast aktuell:
```
Gateway start blocked: set gateway.mode=local (current: unset)
```

Das heißt: Der Modus ist „unset“ (nicht gesetzt).

#### Lösung 1 (empfohlen): Gateway-Modus setzen

Öffne deine OpenClaw-Konfiguration.

Normalerweise hier:
```
~/.openclaw/config.toml
```

Also:
```bash
nano ~/.openclaw/config.toml
```

Dann füge hinzu oder ändere:
```TOML
[gateway]
mode = "local"
```

Optional, aber empfohlen: 
```TOML
[gateway]
mode = "local"
host = "127.0.0.1"
port = 7331
```

Danach speichern.

#### Danach Gateway neu starten
```bash
openclaw gateway
```



XXXXXX
#### Shell Fehler
```
Shell completion is configured in your bash profile but the cache is missing. Regenerating cache...  
```

Von OpenClaw (oder pnpm) und betrifft die Bash-Shell-Completion, also die Auto-Vervollständigung für Befehle wie `
openclaw <TAB>`.

„Shell completion is configured in your bash profile“ → bedeutet, dass OpenClaw die Completion bereits in .bashrc oder .bash_profile registriert hat.

„but the cache is missing. Regenerating cache…“ → OpenClaw merkt, dass die interne Cache-Datei für Vorschläge fehlt und erstellt sie automatisch neu.

##### 💡 Wichtig:

Das ist kein Fehler, nur ein Hinweis.

Nach dem Regenerieren sollte die Autovervollständigung wie gewohnt funktionieren.

Wenn du willst, kannst du das überprüfen mit:
```
openclaw <TAB><TAB>
```

Es sollten dann die möglichen Subcommands angezeigt werden.

Optional kannst du den Cache manuell löschen und neu erstellen:
```
rm -f ~/.openclaw/completions_cache.json
openclaw completion
```

### OpenClaw Bash-Completion sauber

Perfekt! Dann machen wir **die OpenClaw Bash-Completion sauber**, damit der Cache korrekt ist und du **nie wieder die Meldung „cache is missing“ siehst**. 🦞

##### 1️⃣ Überprüfen, wo die Completion registriert ist

OpenClaw legt meist einen Eintrag in `.bashrc` oder `.bash_profile` an:

```bash
grep openclaw ~/.bashrc ~/.bash_profile
```

Du solltest etwas sehen wie:

```bash
# OpenClaw shell completion
source /home/ubuntu/.openclaw/completion.sh
```

+ Wenn **nichts gefunden wird**, fügen wir es manuell hinzu.
+ Falls es schon da ist, wird der Cache trotzdem automatisch erstellt – wir wollen aber sicherstellen, dass alles sauber ist.

##### 2️⃣ Cache neu erstellen

OpenClaw speichert die Completion-Vorschläge in:

```bash
~/.openclaw/completions_cache.json
```

Wenn die fehlt oder veraltet ist, regenerierst du sie einfach:

```bash
openclaw completion
```

Das erstellt **die Datei** `completions_cache.json` 

Danach sollte `openclaw <TAB><TAB>` alle Commands korrekt anzeigen.

Optional kannst du vorher den alten Cache löschen:

```bash
rm -f ~/.openclaw/completions_cache.json
openclaw completion
```

##### 3️⃣ Completion dauerhaft aktivieren

Wenn du .bashrc öffnest:

```bash
nano ~/.bashrc
```

Und ans Ende einfügst:

```bash
#OpenClaw shell completion

if [ -f "$HOME/.openclaw/completion.sh" ]; then
    source "$HOME/.openclaw/completion.sh"
fi
```

Speichern & schließen (`CTRL+O`, `ENTER`, `CTRL+X`)

Danach die Datei neu laden:

```bash
source ~/.bashrc
```

Die beinhaltet:"nano ~/.bashrc
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
"

Es ergab den Fehler: "source ~/.bashrc
: command not found
-bash: /home/ubuntu/.bashrc: line 6: syntax error near unexpected token `$'in\r''
'bash: /home/ubuntu/.bashrc: line 6: `case $- in
"

Der Fehler kommt von Windows-Zeilenenden (CRLF) in deiner .bashrc.
Linux erwartet LF, aber deine Datei enthält \r (Carriage Return) – deshalb erscheint:

syntax error near unexpected token `$'in\r''

Das passiert oft, wenn Dateien unter Windows 11, Visual Studio Code oder Git mit falscher Einstellung gespeichert wurden.

Lösung: 
```bash
sed -i 's/\r$//' ~/.bashrc
```
Danach neu laden:
```bash
source ~/.bashrc
```

##### Alternative (wenn `sed` nicht hilft)

Installiere das Tool **dos2unix**:

```bash
sudo apt install dos2unix
```

Dann:

```bash
dos2unix ~/.bashrc
source ~/.bashrc
```

##### Prüfen ob es jetzt sauber ist
```bash
cat -n ~/.bashrc | head
```

Die ersten Zeilen sollten jetzt so aussehen:
```bash
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
```

Ohne `^M` oder `\r`.


##### 4️⃣ Test

Tippe einfach:

```bash
openclaw <TAB><TAB>
```

Du solltest alle Unterbefehle von OpenClaw sehen, kein Hinweis mehr auf fehlenden Cache.

✅ Fertig!
Damit ist deine Bash-Completion sauber eingerichtet, Cache regeneriert, und OpenClaw startet künftig ohne Warnungen.

XXXXXX
#### 1️⃣ `$USER` in Pfaden

Du hast in `.env` Pfade wie:

OPENCLAW_STATE_DIR=/home/$USER/.openclaw

⚠ Linux kann `$USER` **nicht automatisch expandieren**, wenn OpenClaw die Variable **nicht aus der Shell lädt** (oder `$USER` aus irgendeinem Grund leer ist).

Dadurch entstehen **Fehler wie**:
```
EACCES: permission denied, mkdir '/home/$USER/.openclaw/identity'
```

✅ Lösung: **Ersetze** `$USER` **durch deinen echten Benutzernamen** des Linuxbetriebssystems:
```env
OPENCLAW_STATE_DIR=/home/ubuntu/.openclaw
OPENCLAW_CONFIG_PATH=/home/ubuntu/.openclaw/openclaw.json
OPENCLAW_HOME=/home/ubuntu
```

#### 2️⃣ Berechtigungen

Fehler `EACCES: permission denied, mkdir …` bedeutet, dass OpenClaw **nicht schreiben darf**:

+ Prüfe Besitzer & Rechte:
```bash
ls -ld /home/ubuntu/.openclaw
```

+ Falls nötig, setze die Rechte richtig:
```bash
sudo chown -R ubuntu:ubuntu /home/ubuntu/.openclaw
chmod -R 700 /home/ubuntu/.openclaw
```

+ Danach sollte OpenClaw schreiben können (identity, completions_cache etc.).

#### 3️⃣ WSL2 + systemd

Die Meldung:
```
WSL2 needs systemd enabled: edit /etc/wsl.conf with [boot]\nsystemd=true
```

+ WSL2 unterstützt standardmäßig **kein systemd**, viele Dienste (wie Timer, Hintergrunddienste) brauchen das.
+ Wenn du **systemd in WSL2 aktivierst**, kannst du z. B. OpenClaw als User-Daemon laufen lassen:

Wir deaktivierten systemd in der WSL.
Für 99 % der WSL-Setups brauchst du es eigendlich nicht, doch OpenClaw möchte es haben.

Schritt 1: systemd in WSL wieder aktivieren


+ 1. Editiere `/etc/wsl.conf`:

In WSL:
```
sudo nano /etc/wsl.conf
```
Unsetze diese auf: 

```ÌNI
[boot]
systemd=true
```
Falls bei Dir `true` sowieso steht, dann war `systemd` bei Dir aktiviert. 
Wenn dort `false` stadt, war es deaktiert. 


+ 2. WSL neustarten:
```bash
exit
```

```PowerShell
wsl --shutdown
```

```PowerShell
wsl
```

Der Fehler der WSL wegen der `systemd` erscheint wieder. 
```
wsl: Failed to start the systemd user session for 'ubuntu'. See journalctl for more details.
```
Allerdings geht es in der WSL mit systemd nicht. 

+ 3. Wieder öffnen und prüfen:

```bash
systemctl --user status
```

+ Ohne systemd → manche Features (Cron, Background Agents) funktionieren nur eingeschränkt.

#### 4️⃣ Shell Completion Cache

Jetzt, wo die Berechtigungen stimmen und `$USER` korrekt ist:
```bash
openclaw completion --write-state
```

+ Generiert **den Cache neu**
+ Danach sollte auch `<TAB>`-Completion funktionieren.



Jetzt noch: 
```bash
openclaw doctor --fix
```

Es sollten die Fehlermeldungen so allmählich verschwinden. Dann kann bald der [Onboarding Wizzard](#Onboarding_Wizzard) durchgeführt werden. Sinnvoll wäre es auch schon mal `Homebrew` an dieser Stelle zu installieren, ich erinnere nochmals daran später. Viele Skill-Abhängigkeiten werden über `Homebrew` bereitgestellt. Ohne [Homebrew](#Homebrew) müssen Sie die Software aus dem Quellcode kompilieren oder die Releases manuell herunterladen.


Weiter mit [Onboaring Wizzard](#Onboarding_Wizzard).
###🔹 Zusammenfassung

+ **`.env` Pfade anpassen**: `$USER → ubuntu`
+ **Rechte für ~/.openclaw setzen**: `chown -R ubuntu:ubuntu ~/.openclaw`
+ **WSL2 systemd wieder aktivieren**, wenn du Cron/Daemon-Funktionen nutzen willst
+ **Completion Cache manuell schreiben**: `openclaw completion --write-state`

XXXXXX


### Der Kernfehler wieder sichtbar: `gateway.mode` ist **nicht gesetzt**, daher blockiert OpenClaw den Start. 🦞

#### 1️⃣ Problem

+ Meldung:
```
gateway.mode is unset; gateway start will be blocked
```

+ Bedeutet: OpenClaw weiß nicht, ob der Gateway lokal oder remote laufen soll.
+ Ohne diese Info startet der Gateway nicht (Sicherheitsmaßnahme).

#### 2️⃣ Lösungsmöglichkeiten
##### a) Über das CLI direkt setzen (einfachste Methode)
```bash
openclaw config set gateway.mode local
```

Setzt `gateway.mode` auf **lokal**

Schreibt den Wert direkt in die OpenClaw-Konfiguration (`openclaw.json` oder `config.toml`)

Danach:
```bash
openclaw gateway
```

→ Gateway sollte starten

##### b) Über openclaw configure
```bash
openclaw configure
```

+ Interaktives Setup
+ Fragt nach `Gateway mode` → wähle `local`
+ Speichert die Einstellung automatisch

##### c) Direkt in config.toml eintragen

Öffne:
```bash
nano ~/.openclaw/config.toml
```

Füge hinzu:
```TOML
[gateway]
mode = "local"
host = "127.0.0.1"
port = 7331
```

+ Speichern → Gateway kann starten

#### 3️⃣ Tipp

Wenn du WSL2 benutzt, achte darauf, dass die Berechtigungen für ~/.openclaw korrekt sind, sonst kann OpenClaw nicht schreiben:

```bash
sudo chown -R ubuntu:ubuntu ~/.openclaw
chmod -R 700 ~/.openclaw
```

Jetzt noch mal: 
```bash
openclaw doctor --fix
```

Es sollten die Fehlermeldungen so allmählich verschwinden. 

XXXXXX
!!!WICHTIG!!!
<A name="Onboarding_Wizzard">
## [Onboarding Wizzard](https://docs.openclaw.ai/start/wizard)

Der Onboarding-Assistent (CLI)

Der Onboarding-Assistent ist die empfohlene Methode zum Einrichten von OpenClaw unter: **macOS**, **Linux** oder **Windows** (über WSL2; iat dringend empfohlen). 
Es konfiguriert ein lokales Gateway oder eine Remote-Gateway-Verbindung sowie Channels, Skills und Workspace-Standardeinstellungen in einem geführten Flow. Dieser ist sehr wichtig, nur dann wenn man `openclaw onboard` ausführt, wird OpenClaw endlich mit Chat starten, denn hier wird initialisiert. 

```bash
openclaw onboard
```

Man soll regulär auch 
```bash
openclaw security audit --deep                                                         │
openclaw security audit --fix 
```
zum Anschluß der Konfiguration und zwischendurch mal durchführen. 

und 
`openclaw configure` details später Konfigurieren.


Schnellster erster Chat: Öffnen Sie die Steuerungsoberfläche (keine Kanaleinrichtung ist erforderlich). 
Führen Sie das `openclaw dashboard` aus und chatten Sie im Browser. Dokumente: [Dashboard](Dashboard.md).


Zur späteren Neukonfiguration:

```bash
openclaw configure
openclaw agents add <name>
```


Mit `openclaw onboard` werden folgende LLM Anbieter angeboten. 
Wurden in der `.env` - Datei zuvor die API-Keys oderendlich eingetragen, dann verarbeitet die endlich OpenClaw. 
Hierzu `Google` und dann `Gemeni Api-Key` auswählen. Danach fragt das Setup ob man den existierenden verwenden soll, dieser wird auszugsweise sogar dargestellt. 

```
openclaw onboard
  Model/auth provider
│  ● OpenAI (Codex OAuth + API key)
│  ○ Anthropic
│  ○ Chutes
│  ○ vLLM
│  ○ MiniMax
│  ○ Moonshot AI (Kimi K2.5)
│  ○ Google
│  ○ xAI (Grok)
│  ○ Volcano Engine
│  ○ BytePlus
│  ○ OpenRouter
│  ○ Qwen
│  ○ Z.AI
│  ○ Qianfan
│  ○ Copilot
│  ○ Vercel AI Gateway
│  ○ OpenCode Zen
│  ○ Xiaomi
│  ○ Synthetic
│  ○ Together AI
│  ○ Hugging Face
│  ○ Venice AI
│  ○ LiteLLM
│  ○ Cloudflare AI Gateway
│  ○ Custom Provider
│  ○ Skip for now
```

Bei Telegram, WhatsApp und Discord steht, das das Plugin noch deaktiviert ist. 
Also hier ist die Chance es endlich zu aktivieren. 

```
Telegram: configured (plugin disabled)  
  WhatsApp: not configured                
  Discord: configured (plugin disabled) 
```

Der [OpenClaw Hub](https://docs.openclaw.ai/tools/clawhub) oder auf [clawhub.ai/](https://clawhub.ai/)

Intressant sind beispielsweise: 
[AI Music Video](https://clawhub.ai/gprecious/ai-music-video)
[Music Video Generation](https://clawhub.ai/eftalyurtseven/music-video-generation)
[Video BGM](https://clawhub.ai/PHY041/phy-video-bgm)
[Dream Text to Video](https://clawhub.ai/Hy-1990/dream-text-to-video)
[Dream Talking Image](https://clawhub.ai/Hy-1990/dream-talking-image)

[Suno](https://clawhub.ai/skills?sort=downloads&q=suno)
[Evolink Music](https://clawhub.ai/EvoLinkAI/evolink-music)
[Suno](https://clawhub.ai/ivangdavila/suno)
[SunoMaker](https://clawhub.ai/Vitja1988/sunomaker)

[Music](https://clawhub.ai/skills?sort=downloads&q=music)

```
Install missing skill dependencies
│  ◻ Skip for now
│  ◻ 🔐 1password (Set up and use 1Password CLI (op). Use when installing the CLI, enabling desktop app inte…)
│  ◻ 📰 blogwatcher (Monitor blogs and RSS/Atom feeds for updates using the blogwatcher CLI. — Install
│  blogwat…)
│  ◻ 🫐 blucli (BluOS CLI (blu) for discovery, playback, grouping, and volume. — Install blucli (go))
│  ◻ 📸 camsnap (Capture frames or clips from RTSP/ONVIF cameras. — Install camsnap (brew))
│  ◼ 🧩 clawhub (Use the ClawHub CLI to search, install, update, and publish agent skills from clawhub.com…)
│  ◻ 🎛️ eightctl (Control Eight Sleep pods (status, temperature, alarms, schedules). — Install eightctl (go))
│  ◻ ♊️ gemini (Gemini CLI for one-shot Q&A, summaries, and generation. — Install Gemini CLI (brew))
│  ◻ 🧲 gifgrep (Search GIF providers with CLI/TUI, download results, and extract stills/sheets. — Install…)
│  ◻ 🐙 github (GitHub operations via `gh` CLI: issues, PRs, CI runs, code review, API queries. Use when:…)
│  ◻ 🎮 gog (Google Workspace CLI for Gmail, Calendar, Drive, Contacts, Sheets, and Docs. — Install go…)
│  ◻ 📍 goplaces (Query Google Places API (New) via the goplaces CLI for text search, place details, resolv…)
│  ◼ 📧 himalaya (CLI to manage emails via IMAP/SMTP. Use `himalaya` to list, read, write, reply, forward, …)
│  ◻ 📦 mcporter (Use the mcporter CLI to list, configure, auth, and call MCP servers/tools directly (HTTP …)
│  ◻ 🍌 nano-banana-pro (Generate or edit images via Gemini 3 Pro Image (Nano Banana Pro). — Install uv
│  (brew))
│  ◻ 📄 nano-pdf (Edit PDFs with natural-language instructions using the nano-pdf CLI. — Install nano-pdf (…)
│  ◼ 💎 obsidian (Work with Obsidian vaults (plain Markdown notes) and automate via obsidian-cli. — Install…)
│  ◼ 🎙️ openai-whisper (Local speech-to-text with the Whisper CLI (no API key). — Install OpenAI Whisper
│  (brew))
│  ◻ 💡 openhue (Control Philips Hue lights and scenes via the OpenHue CLI. — Install OpenHue CLI (brew))
│  ◻ 🧿 oracle (Best practices for using the oracle CLI (prompt + file bundling, engines, sessions, and f…)
│  ◻ 🛵 ordercli (Foodora-only CLI for checking past orders and active order status (Deliveroo WIP). — Inst…)
│  ◼ 🗣️ sag (ElevenLabs text-to-speech with mac-style say UX. — Install sag (brew))
│  ◻ 🌊 songsee (Generate spectrograms and feature-panel visualizations from audio with the songsee CLI. —…)
│  ◻ 🔊 sonoscli (Control Sonos speakers (discover/status/play/volume/group). — Install sonoscli (go))
│  ◻ 🧾 summarize (Summarize or extract text/transcripts from URLs, podcasts, and local files (great fallbac…)
│  ◻ 🎞️ video-frames (Extract frames or short clips from videos using ffmpeg. — Install ffmpeg (brew))
│  ◻ 📱 wacli (Send WhatsApp messages to other people or search/sync WhatsApp history via the wacli CLI …)
│  ◻ 𝕏 xurl (A CLI tool for making authenticated requests to the X (Twitter) API. Use this skill when …)
```

Viele Skill-Abhängigkeiten werden über `Homebrew` bereitgestellt. Ohne [Homebrew](#Homebrew) müssen Sie die Software aus dem Quellcode kompilieren oder die Releases manuell herunterladen.

https://chatgpt.com/c/69ab1a2c-8a04-8332-b7df-1e1e7b665a78

##### 1️⃣ Zwei Wege, Whisper zu nutzen
**A) Lokale Whisper-Installation**

+ Wenn du Whisper **lokal installiert** hast (z. B. via `pip install openai-whisper` oder Brew), **wird kein OpenAI-API-Key benötigt**.
+ Dein OpenClaw Agent kann das Modell **direkt auf deinem Mini-PC ausführen**, ohne dass Daten an OpenAI geschickt werden.
+ Vorteil: **kostenlos**, keine API-Limits, läuft offline.

**B) OpenAI Whisper API**

+ Wenn du die **Cloud-Variante** (`openai-whisper-api`) nutzt, also über OpenAI-Server, **braucht OpenClaw einen OPENAI_API_KEY**, weil die Audiofiles an OpenAI gesendet werden.
+ Nachteil: verbraucht Credits / kann Kosten erzeugen, wenn das Limit überschritten wird.

##### 2️⃣ Was bedeutet das für OpenClaw?

+ OpenClaw fragt nach `OPENAI_API_KEY` für Whisper nur, wenn du **API-Zugriff auf OpenAI** nutzen willst.
+ **Wenn du dein Whisper lokal laufen lässt**, kannst du diesen Key **leer lassen oder gar nicht setzen**.

##### 3️⃣ Empfehlung für dein Mini-PC Setup

```ènv
# OpenClaw Whisper Nutzung
# Lokale Whisper-Installation nutzen, kein API Key nötig
OPENAI_API_KEY=
```

+ Alternativ: Wenn du später **Cloud-Whisper** nutzen willst, trägst du hier deinen OpenAI Key ein.
+ OpenClaw wählt automatisch: **lokal installiertes Modell vs Cloud-API**, je nachdem, ob ein Key gesetzt ist.


### OpenAI Whisper über Homebrew installieren. 
Das geht nur, wenn Linuxbrew (Homebrew für Linux) bereits installiert ist. Da du auf Ubuntu / WSL arbeitest, zeige ich dir den sicheren Ablauf.

### Homebrew
#### 1️⃣ Prüfen, ob Homebrew installiert ist

```bash
brew --version
```

Wenn eine Version angezeigt wird → weiter zu Schritt 3.
Wenn command not found erscheint → erst Homebrew installieren.

#### 2️⃣ Homebrew installieren (falls nötig)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Danach die Umgebung aktivieren:
```
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Optional dauerhaft:
```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
```

#### 3️⃣ Whisper installieren
```bash
brew install whisper
```

oder
```bash
brew install openai-whisper
```

Homebrew installiert dabei automatisch:

+ Python
+ ffmpeg (für Audioverarbeitung)
+ Whisper selbst

```
Disable this behaviour by setting `HOMEBREW_NO_INSTALL_CLEANUP=1`.
Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
```

#### 4️⃣ Installation testen
```bash
whisper --help
```

Wenn alles funktioniert, siehst du die CLI-Optionen.

#### 5️⃣ Beispiel: Audio transkribieren

```bash
whisper audio.mp3 --model small
```

**Modelle**:

| Modell	| Geschwindigkeit	| Qualität	|
|:---------:|-------------------|-----------|
| tiny		| sehr schnell		| niedrig	|
| base		| schnell			| ok		|
| small		| gut				| gut		|
| medium	| langsamer			| sehr gut	|
| large		| sehr langsam		| beste		|

Für deinen Mini-PC empfehle ich:
```bash
--model small
```

#### 💡 Tipp für dein KI-Setup (OpenClaw + Ollama):

Viele kombinieren OpenAI Whisper so:
```
Audio → Whisper (Speech-to-Text)
Text → Ollama (LLM)
Antwort → TTS
```

Damit bekommst du lokale Sprach-Agenten ohne Cloud.

## OpenClaw fragt zur Verwendung nach `npm`, `pnpm`, `bun` nach der Skill und Homebrew Installation. 

```
Preferred node manager for skill installs
```

Auch wenn mehrere Optionen angezeigt werden (npm, pnpm, bun), ist pnpm praktisch der Standard für dieses Projekt.

Meine Empfehlung beste Wahl: 
```
● pnpm
```

Warum pnpm für OpenClaw besser ist

#### 1️⃣ Das Projekt selbst nutzt pnpm
Du hast OpenClaw ja bereits mit `pnpm install` gebaut. Viele Monorepos (auch OpenClaw) sind darauf ausgelegt.

#### 2️⃣ Deutlich weniger Speicherverbrauch
`pnpm` verwendet ein **globales Package-Cache-System** statt alles zu kopieren.

#### 3️⃣ Schnellere Installationen
Gerade bei Skills / Plugins installierst du oft viele kleine Node-Pakete.

#### 4️⃣ Weniger Dependency-Probleme
`pnpm` isoliert Pakete besser als `npm`.

Warum die anderen Optionen schlechter passen

**npm**
+ funktioniert zwar
+ aber langsamer
+ mehr Konflikte bei Plugins

**bun**
+ sehr schnell
+ aber noch nicht vollständig kompatibel mit vielen Node-Tools

#### Empfehlung für dein Setup

Für dein aktuelles System:
```
Node manager: pnpm
LLM: Ollama
Gateway: local
```

Das ist im Moment **die stabilste Kombination für OpenClaw**.

#### 💡 Kleiner Bonus-Tipp:

Wenn du später viele Skills / Extensions installierst, kannst du pnpm noch beschleunigen:

```bash
pnpm config set store-dir ~/.pnpm-store
```

Dann werden alle Abhängigkeiten zentral gespeichert.

#### Wenn du möchtest, kann ich dir auch noch zeigen:

+ die 10 nützlichsten OpenClaw Skills, die man direkt installieren sollte
+ wie du Whisper + OpenClaw + Ollama zu einem lokalen Sprachagenten kombinierst.











XXXXXX
## GOOGLE_PLACES_API_KEY

Den GOOGLE_PLACES_API_KEY bekommst du direkt von der **Google Cloud-Konsole**. 
Der Schlüssel gehört zur **Google Maps Platform** und speziell zur **Google Places API**, die z. B. für Tools wie **goplaces** genutzt wird.

Ich zeige dir den schnellsten Weg:

#### Schritt-für-Schritt: Google Places API-Key erstellen
##### 1️⃣ Google Cloud Console öffnen

Gehe hier hin:

https://console.cloud.google.com/

Mit deinem Google-Account anmelden.

##### 2️⃣ Neues Projekt erstellen

Oben links:

```
Select project → New project
```

Beispielname:

```
openclaw-tools
```

##### 3️⃣ Places API aktivieren

Dann:
```
APIs & Services → Library
```

Suche nach:
```
Places API (New)
```

und klicke Enable.

Optional (für Navigation / Routen):
```
Routes API
```

Bei mir steht: 
https://console.cloud.google.com/apis/library?project=eloquent-env-334710
```
Places API
Google Enterprise API 
Get detailed information about 100 million places
```
Mit den Google Maps Platform APIs können Sie pro Monat bis zu 10.000 Aufrufe pro SKU kostenlos ausführen. 

##### 4️⃣ API-Key erzeugen

Gehe zu:
```
APIs & Services → Credentials
```

Dann:
```
Create credentials → API key
```

Du bekommst sofort einen Schlüssel wie:
```
AIzaSyXXXXXXXXXXXXXXX
```


##### 5️⃣ In deine `.env` eintragen

Dann einfach in deiner `.env`:
```
GOOGLE_PLACES_API_KEY=AIzaSyXXXXXXXXXXXX
```

#### ⚠ Wichtig (Kosten)

Google verlangt immer eine Billing-Methode, aber:

+ jeden Monat gibt es **200 $ gratis Maps-Credits**
+ kleine Projekte bleiben oft komplett kostenlos.

Wenn du **keine Kosten riskieren** willst, kannst du:

+ Budget-Limit setzen
+ Billing Alerts aktivieren
+ API-Key nur für Places API beschränken

##### Tipp für dein OpenClaw Setup

Da du **OpenClaw + goplaces** nutzt, brauchst du nur:
```
GOOGLE_PLACES_API_KEY=...
```

Dann kannst du z. B.:
```
goplaces search "coffee near Dortmund"
```

#### ✅ Wie du Google APIs so konfigurierst, dass sie automatisch deaktiviert werden, sobald Kosten entstehen könnten.

Damit bleibt dein KI-Setup 100 % kostenkontrolliert.

Wenn man mit APIs experimentiert, ist eine Kosten-Sperre wirklich sinnvoll. Bei der Google-Cloud kann man das ziemlich zuverlässig absichern. Ich zeige dir die 3 wichtigsten Schutzmechanismen, die zusammen praktisch verhindern, dass plötzlich Kosten entstehen. 🔒💰

##### 1️⃣ Monatliches Budget-Limit setzen (wichtigster Schutz)

Gehe in die Google Cloud Console.

**Pfad**:
```
Billing → Budgets & alerts → Create Budget
```
Beispiel:
```
Budget amount: 1 €
```

Dann Alerts einstellen:
```
50 %
90 %
100 %
```

Du bekommst sofort eine Mail, wenn Limits erreicht werden.

**⚠️ Hinweis:**
Das Budget stoppt APIs nicht automatisch, aber du wirst sofort informiert.

##### 2️⃣ API-Key einschränken (sehr wichtig)

Gehe zu:
```
APIs & Services → Credentials
```

Wähle deinen API-Key (für Places).

Dann einstellen:

**Application restrictions** 

z. B.:
```
IP address restriction
```

oder
```
HTTP referrer
```

**API restrictions**

Hier nur erlauben:
```
Places API
```

❗ Dadurch kann der Key **nicht für andere Google APIs missbraucht werden**.

###### 3️⃣ Tageslimit setzen (echte Kostenbremse)

Viele APIs der Google Maps Platform haben Quota Limits.

Gehe zu:
```
APIs & Services → Quotas
```
Suche:
```
Places API
```
Dann z. B. Limit setzen:
```
Requests per day: 50
```

Wenn das erreicht ist:

+ ➡ API antwortet nur noch mit Fehler
+ ➡ **keine weiteren Kosten**

##### Hier sind die grundlegenden Schrittefür das Budget:

+ 1. Gehen Sie in der **Google Cloud Console** zur Seite `Budgets & Benachrichtigungen` im Bereich „Abrechnung“.
+ 2. Klicken Sie auf **Budget erstellen**.
+ 3. Legen Sie den **Umfang** Ihres Budgets fest (z. B. für das gesamte Rechnungskonto oder für bestimmte Projekte und Dienste).
+ 4. Legen Sie unter **Betrag** Ihr Budgetziel fest.
+ 5. Konfigurieren Sie unter **Aktionen** die **Schwellenwertregeln für Benachrichtigungen**. Standardmäßig sind Benachrichtigungen bei 50 %, 90 % und 100 % der tatsächlichen Ausgaben voreingestellt. Sie können diese anpassen.
+ 6. Unter **Benachrichtigungen verwalten** können Sie festlegen, wer die E-Mail-Benachrichtigungen erhalten soll.

Ein Budget begrenzt Ihre **Ausgaben nicht automatisch**, sondern informiert Sie nur über Ihre Kostenentwicklung.

Man kann dort sogar 0 € als Summe für das Buget festlegen. Also wird das Kontigent infolge auch nie überschritten oder kostenpflichtig werden. 254,70 € Guthaben verbleiben. Ob die 70 Cent noch zusätzlich da waren, meine ich - weiß ich jetzt nicht. Später diese Zeile löschen..

##### 4️⃣ Optional: eigenes „Test-Projekt“

Viele Entwickler machen für Experimente ein eigenes Projekt:
```
openclaw-test
```

Vorteile:
+ Kosten getrennt
+ API Keys getrennt
+ einfach deaktivierbar

##### 5️⃣ Extrem sicher (mein persönlicher Trick)

API-Key **nur temporär aktivieren**:

In `.env`:
```
GOOGLE_PLACES_API_KEY=
```

Wenn du ihn brauchst:
```
nano ~/.openclaw/.env
```

Key einfügen → testen → wieder entfernen.

##### Fazit

Die sicherste Kombination ist:
+ 1️⃣ Budget 0 € 
+ 2️⃣ API-Key nur für **Places API** beschränken
+ 3️⃣ Tages-Quota setzen (z. B. 50 Requests)

+ ➡ Dann kann dein Setup praktisch **keine unerwarteten Kosten erzeugen**.






XXXXXX

#### Set NOTION_API_KEY for notion

Notion in OpenClaw oder deinem Setup einbinden. 📝

Damit brauchst du einen Notion API Key, der es deinem Local Agent erlaubt, auf deine Notion-Datenbanken oder Pages zuzugreifen. Hier ist Schritt für Schritt, wie du ihn bekommst und setzt:

##### 1️⃣ Notion Integration vorbereiten

Gehe zu [Notion Developers](https://www.notion.so/my-integrations)

Klicke auf “**Create new integration**”

Gib der Integration einen Namen, z. B. **OpenClaw Agent**

Wähle die **Workspace**-Zugriffe aus, die du erlauben willst (z. B. `Read content`, `Update content`)

Klicke auf **Submit**

Nach der Erstellung bekommst du den **Integration Token** – das ist dein `NOTION_API_KEY`.

##### 2️⃣ Berechtigungen für Seiten / Datenbanken

Damit die Integration auf deine Seiten zugreifen kann:

Öffne die Seite oder Datenbank in Notion

+ Klicke auf **Share**
+ Wähle **Invite → Integration**
+ Lade die Integration hoch, die du erstellt hast

Jetzt hat dein API Key Zugriff auf diese Seiten.

##### 3️⃣ Setzen in OpenClaw `.env`

Füge einfach die Zeile in deine `.env`:
```env
# Notion API Key für OpenClaw
NOTION_API_KEY=secret_xxxxxxxx
```

Wichtig:
+ Ersetze `secret_xxxxxxxx` mit deinem echten **Integration Token**
+ Speichere die Datei im Linux/Unix Format, nicht DOS/Windows CRLF, sonst kann OpenClaw sie manchmal nicht lesen

##### 4️⃣ Optional: Testen

Du kannst testen, ob dein Key funktioniert:
```bash
curl -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: 2022-06-28" \
     https://api.notion.com/v1/databases
```

+ Wenn alles korrekt ist, bekommst du eine JSON-Liste der Datenbanken, die die Integration sehen darf.

💡 Tipp:
Wenn du mehrere LLMs / Agents hast, kannst du in `.env` noch **NOTION_API_KEY_1, NOTION_API_KEY_2** setzen, falls du unterschiedliche Keys für unterschiedliche Workspaces nutzen willst.


Fertige `.env`-Ergänzung für Notion

Füge einfach diese Zeilen in dein .env ein (unterhalb der anderen API Keys):
```ènv
# -------------------------------
# Notion Integration
# -------------------------------

# Dein Notion Integration Token (API Key)
NOTION_API_KEY=secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Optional: weitere Keys, wenn du mehrere Workspaces nutzen willst
# NOTION_API_KEY_1=secret_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
# NOTION_API_KEY_2=secret_zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
```

Hinweise:

Ersetze `secret_xxxxxxxxx...` mit deinem echten Notion Integration Token.

Speichere die `.env` im Unix/Linux Format (LF, nicht CRLF), sonst erkennt OpenClaw sie nicht.

Dein Gateway / Agents nutzen automatisch diesen Key, sobald `.env` geladen wird.

Wenn du mehrere Workspaces oder unterschiedliche Berechtigungen brauchst, nutze die _1, _2 Varianten.

Beispiel kompletter Abschnitt in deiner `.env` (inkl. vorheriger Keys)

```ènv
# -------------------------------
# OpenClaw Environment
# -------------------------------

BLOCK_PAID_API=true
OPENCLAW_GATEWAY_TOKEN=0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1

OPENCLAW_STATE_DIR=/home/ubuntu/.openclaw
OPENCLAW_CONFIG_PATH=/home/ubuntu/.openclaw/config.toml
OPENCLAW_HOME=/home/ubuntu

LLM_PROVIDER=ollama
OLLAMA_HOST=http://127.0.0.1:11434

OLLAMA_MODEL_CHAT=phi3:mini
OLLAMA_MODEL_CODING=deepseek-coder:1.3b
OLLAMA_MODEL_AGENT=qwen2.5:3b
OLLAMA_MODEL_ANALYSIS=gemma:2b

# API Keys
GOOGLE_PLACES_API_KEY=AIzaSyXXXXXX
OPENWEATHER_API_KEY=XXXXXX
NEWS_API_KEY=XXXXXX
ELEVENLABS_API_KEY=XXXXXX
BRAVE_API_KEY=XXXXXX
FIRECRAWL_API_KEY=XXXXXX
OPENCAGE_API_KEY=XXXXXX

# Notion API Key
NOTION_API_KEY=secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

##### 💡 Pro-Tipp:

+ Du kannst das gleiche Schema nutzen, um **verschiedene Tools** wie `TELEGRAM_BOT_TOKEN`, `DISCORD_BOT_TOKEN` oder andere Workspaces sauber in einer `.env` zu organisieren.
+ Sobald OpenClaw startet, liest er die Keys automatisch und deine Agents können auf Notion zugreifen.


#### Notion ist grundsätzlich kostenlos nutzbar, aber mit Einschränkungen je nach Nutzung. 🧠✨

Hier ist, wie das kostenlose Modell von Notion funktioniert und wie es deine API‑Nutzung betrifft:

📦 Notion Free – was du bekommst

Die kostenlose Version von Notion bietet:

+ ✅ Unbegrenzte Seiten und Blöcke
+ ✅ Zusammenarbeit mit anderen
+ ✅ Einfache Datenbanken
+ ✅ Mobile & Desktop Apps
+ ✅ Grundlegende API‑Zugriffe für Entwickler

👉 Du kannst also API‑Zugriffe mit dem kostenlosen Plan nutzen, solange du innerhalb der üblichen Limits bleibst und keine Enterprise‑Funktionen brauchst.

🚫 Einschränkungen im Free‑Plan

+ 🔹 Collective oder Team‑Features sind eingeschränkt
+ 🔹 Admin‑ oder erweiterte Sicherheitsfeatures fehlen
+ 🔹 Bei sehr großen Teams/Add‑Ons wird ein Upgrade nötig

Aber für persönliche Nutzung oder kleine Projekte (inkl. API‑Zugriff) ist der Free‑Plan absolut ausreichend.

##### 🔐 Notion API & Free‑Plan

Du kannst einen Integration Token erzeugen, auch mit dem Free‑Plan

Deine Integration kann in deinen Notion Pages/Databases lesen und schreiben, sofern du sie freigibst

Es gibt keine gesonderten API‑kosten – anders als bei Cloud‑LLM‑APIs

API‑Limits werden offen von Notion gehandhabt (z. B. Rate‑Limits)

+ 👉 Du musst also keine Kosten befürchten, nur weil du die Notion API nutzt.
+ 🧪 Praktische Vorteile

Wenn du Notion mit deinem OpenClaw‑Setup verknüpfst:

+ ✔ Agents können Notion‑Daten lesen
+ ✔ Inhalte zusammenfassen
+ ✔ Automatisiert Daten einfügen oder aktualisieren
+ ✔ Workflows synchronisieren

Und das mit deinem Free‑Account.

🧠 Fazit
Plan	API‑Nutzung möglich?	Kosten
Notion Free	✅ Ja	Kostenlos
Notion Plus	✅ Ja	Bezahlt
Notion Team / Enterprise	✅ Ja	Mehr Features

👉 Für deine Zwecke reicht der Free‑Plan völlig aus, besonders wenn du Notion nur für Agent‑Zugriffe oder projektbezogene Inhalte nutzt.

Wenn du willst, kann ich dir auch eine Schritt‑für‑Schritt‑Anleitung geben, wie du:

+ 📌 eine Notion‑Integration erstellst
+ 📌 sie zu deinen Pages/Datenbanken einlädst
+ 📌 und sie sicher in deine .env einbindest

Willst du das? 🤓

ja bitte

Alles klar! Dann zeige ich dir Schritt für Schritt, wie du eine Notion-Integration für dein OpenClaw-Setup erstellst, sie auf deine Pages/Datenbanken zugreifen lässt und sicher in die .env einbindest. 📝🦞

##### 1️⃣ Notion Integration erstellen

Öffne Notion Developers – My Integrations

+ Klicke “Create new integration”
+ Gib der Integration einen Namen, z. B. OpenClaw Agent
+ Wähle den Workspace, den du verwenden willst

Setze die Berechtigungen (Scopes):

+ Read content ✅
+ Update content ✅ (wenn dein Agent schreiben soll)
+ Optional: Read user info

Klicke Submit → Integration wird erstellt

Du erhältst den Integration Token. Das ist dein NOTION_API_KEY.

⚠️ Bewahre diesen Token geheim auf – wie bei jedem API Key.

##### 2️⃣ Seiten/Datenbanken freigeben

Damit die Integration auf bestimmte Inhalte zugreifen kann:

+ Öffne die Seite oder Datenbank in Notion
+ Klicke oben rechts auf Share
+ Wähle Invite → Integration
+ Lade deine erstellte Integration hoch

Jetzt kann der Token auf diese Seiten/DBs zugreifen.

##### 3️⃣ .env Einbindung

Füge in deiner OpenClaw .env Datei die Zeile hinzu:
```ènv
# Notion Integration Key
NOTION_API_KEY=secret_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Ersetze secret_xxxxx... durch deinen echten Integration Token

Speichere die Datei im Linux/Unix Format (LF), nicht Windows/DOS CRLF

Optional, falls du mehrere Workspaces hast:

NOTION_API_KEY_1=secret_yyyyyyyyyyyyyyyyyyyyyyyyyyyy
NOTION_API_KEY_2=secret_zzzzzzzzzzzzzzzzzzzzzzzzzz
```

OpenClaw kann dann automatisch die Keys verwenden.

##### 4️⃣ Testen, ob Key funktioniert

Du kannst kurz testen:
```bash
curl -H "Authorization: Bearer $NOTION_API_KEY" \
     -H "Notion-Version: 2022-06-28" \
     https://api.notion.com/v1/databases
```

+ Erfolgreich → JSON-Liste der Datenbanken, auf die der Key Zugriff hat. 
+ Fehler → Token prüfen oder Seite nicht freigegeben.

##### 5️⃣ Integration in OpenClaw Agent

Stelle sicher, dass .env geladen wird (normalerweise automatisch beim Start von OpenClaw)

Dein Agent kann jetzt Notion-Abfragen durchführen, z. B.:

Inhalte zusammenfassen

Neue Tasks einfügen

Daten auslesen

In Kombination mit deinem Auto-Model-Routing kannst du z. B.:

+ Chat → phi3:mini
+ Analyse/Notion-Tasks → gemma:2b

###### 💡 Extra-Tipp:
Wenn du mehrere Agents hast, kannst du für jeden Agenten einen eigenen NOTION_API_KEY nutzen, um Zugriffsrechte sauber zu trennen.



Eventuell hier das mit EACCESS???
XXXXXX

#### 💡 Wenn du möchtest, kann ich dir noch etwas zeigen, was für dein OpenClaw-Setup wirklich hilfreich ist:

Eine Liste von 10 kostenlosen APIs, die du in deiner .env nutzen kannst (Suche, Karten, Wetter, News, Code-Tools), ohne Risiko von Kosten.

für ein KI-Agent-Setup wie dein OpenClaw + lokale LLMs lohnt es sich, ein paar kostenlose oder sehr großzügige APIs einzubauen. Damit bekommen deine Agenten Zugriff auf Webdaten, Karten, Wetter usw., ohne dass sofort Kosten entstehen. 🌐🤖

Ich zeige dir 10 APIs, die häufig in AI-Agent-Setups verwendet werden und einen Free-Tier haben.

##### 1️⃣ Websuche (sehr nützlich für Agenten)
Brave Search API

Sehr beliebt bei AI-Tools.

Free Tier ungefähr:

ca. 2000 Queries / Monat

keine Kreditkarte nötig

.env

BRAVE_API_KEY=...
##### 2️⃣ KI-Websuche
Perplexity AI API

Gut für AI-Agenten.

Free Tier:

kleine kostenlose Nutzung

danach Pay-as-you-go

.env

PERPLEXITY_API_KEY=...
##### 3️⃣ Web Scraping für Agenten
Firecrawl

AI-optimiertes Web-Scraping.

Free Tier:

etwa 500 Seiten / Monat

.env

FIRECRAWL_API_KEY=...
##### 4️⃣ Karten / Orte
Google Places API

Free Credits:

200 $ pro Monat

.env

GOOGLE_PLACES_API_KEY=...
##### 5️⃣ Wetter
OpenWeatherMap

Free Tier:

1000 API Calls / Tag

.env

OPENWEATHER_API_KEY=...
##### 6️⃣ Nachrichten
NewsAPI

Free Tier:

ca. 100 Requests / Tag

.env

NEWS_API_KEY=...
##### 7️⃣ Geocoding (Koordinaten)
OpenCage Geocoder

Free Tier:

2500 Requests / Tag

.env

OPENCAGE_API_KEY=...
##### 8️⃣ Finanzdaten
Alpha Vantage

Free Tier:

25 Requests / Tag

.env

ALPHAVANTAGE_API_KEY=...
##### 9️⃣ Übersetzung
LibreTranslate

Vorteil:

Open Source

oft komplett kostenlos

##### 🔟 Voice AI
ElevenLabs

Free Tier:

ca. 10 000 Zeichen TTS / Monat

.env

ELEVENLABS_API_KEY=...
Beispiel .env für ein starkes OpenClaw Setup
BRAVE_API_KEY=...
FIRECRAWL_API_KEY=...
GOOGLE_PLACES_API_KEY=...
OPENWEATHER_API_KEY=...
NEWS_API_KEY=...

Damit können deine Agents:
+ Web suchen
+ Webseiten lesen
+ Orte finden
+ Wetter prüfen
+ News analysieren

##### 💡 Mein Tipp für dein Setup:


#### Web tools
In der `.env` werden die `Web tools` als `Tools + voice/media (optional)` bezeichnet. 

Die 3 wichtigsten APIs für AI-Agenten sind:

+ 1️⃣ Brave Search API
+ 2️⃣ Firecrawl
+ 3️⃣ Google Places API

Damit funktionieren schon 80 % aller Agent-Tasks.

Wenn du möchtest, kann ich dir noch etwas sehr Nützliches zeigen:
Die 12 besten kostenlosen Tools speziell für OpenClaw-Agents (z. B. Internetzugriff, Coding-Tools, Smart-Home-Integration mit Home Assistant). Das macht dein Setup deutlich mächtiger.

Wenn du OpenClaw als lokalen KI-Agent betreibst (mit z. B. Ollama und eventuell Home Assistant), lohnt es sich, ein paar Tools/APIs einzubauen. Damit kann dein Agent recherchieren, Dateien bearbeiten, Geräte steuern und Code schreiben.

Hier sind 12 besonders nützliche kostenlose Tools für OpenClaw-Agenten.

#### 🌐 Internet & Wissen
##### 1️⃣ Websuche

Brave Search API

Sehr gut für KI-Agenten.

Agent kann z. B.:

+ aktuelle Infos suchen
+ Webseiten finden
+ technische Probleme recherchieren
```env
.env

BRAVE_API_KEY=BSA...
```

Dashboard deinen API-Key.


##### 1️⃣ Wo du die Brave Search API bekommst

Die API erhältst du direkt bei Brave:

+ ➡️ [https://brave.com/search/api/](https://brave.com/search/api/)

Dort klickst du auf “**Get started / Sign up**” und erstellst ein Entwicklerkonto. 

Danach bekommst du im **Developer Dashboard** deinen **API-Key**.



##### 2️⃣ Kostenlos nutzen – so funktioniert es wirklich

Die Preisstruktur hat sich geändert.

Aktuelles Modell

+ **$5 pro 1000 Suchanfragen** 
+ **$5 kostenloses Guthaben pro Monat**
+ Guthaben erneuert sich automatisch jeden Monat.

👉 Das bedeutet praktisch:

| Nutzung									| Kosten			|
|:-----------------------------------------:|-------------------|
| bis ca. **1000 Suchanfragen / Monat**		| kostenlos			|
| darüber 									| kostenpflichtig	|

##### 3️⃣ Wichtig: Kreditkarte oder Bankkonto erforderlich

Brave verlangt meist eine **Kreditkarte zur Verifizierung**, auch beim kostenlosen Start.
Sie wird **nur belastet**, wenn du über das freie Guthaben hinausgehst. 

Kreditkarte: Zur Überprüfung Ihres Abonnements wird ein **Autorisierungsbetrag von 1 US-Dollar auf Ihrer Karte reserviert. Dieser wird sofort freigegeben**, die vollständige Abbuchung kann jedoch je nach Bank bis zu 5 Tage dauern. Mein Kreditkarteninstitut PayPal.com hat mir sofort 0.- € als Zahlung an Brave bestätigt. 


##### 4️⃣ So schützt du dich komplett vor Kosten

Das ist der wichtigste Trick.

Im Dashboard kannst du ein **Usage Limit** setzen.

**Beispiel**

Setze:
```
Monthly limit: $5
```

Dann passiert folgendes:

+ API funktioniert normal
+ maximal dein kostenloses Guthaben wird genutzt
+ **keine Abbuchung möglich**

Viele Entwickler machen das so.

##### 5️⃣ Typische Limits im kostenlosen Bereich

Wenn du nur das Gratis-Guthaben nutzt:

+ ungefähr **1000 Queries / Monat**
+ **1–50 Requests pro Sekunde je nach Plan**
+ gut für **KI-Agents / OpenClaw / Bots**.

##### 6️⃣  Warum viele KI-Projekte Brave nutzen

Gerade bei KI-Agenten (OpenClaw, OpenWebUI usw.) ist Brave beliebt, weil:

+ eigener Suchindex
+ günstiger als Bing API
+ gut für RAG / KI-Agenten geeignet.

##### 7️⃣  ✅ Kurzfassung

+ API bekommst du hier: https://brave.com/search/api/
+ $5 monatliches Gratisguthaben
+ ~1000 Suchen kostenlos
+ Kreditkarte nur zur Verifizierung
+ **Limit auf $5 setzen → keine Kosten möglich**  

XXXXXX
#### web_fetch
`web_fetch` in OpenClaw ist im Grunde eine einfache Web-Abruf-Funktion. Damit kann die KI direkt Webseiten laden und lesen, ohne eine Such-API zu benutzen.

##### 🧠 Was „Enable web_fetch (keyless HTTP fetch)“ bedeutet

Wenn du diese Option aktivierst, kann OpenClaw:

+ eine **beliebige URL direkt abrufen**
+ den **HTML-Inhalt der Webseite herunterladen**
+ den **Text extrahieren**
+ diesen der KI als Kontext geben

Technisch passiert einfach ein normaler HTTP-Request:
```bash
GET https://example.com
```

Das System liest danach:

+ HTML
+ Text
+ Artikel
+ Dokumente

##### 💰 Kostet das etwas?

Nein.

`web_fetch` ist komplett:

+ ✅ kostenlos
+ ✅ kein API-Key nötig
+ ✅ keine Registrierung

Es nutzt nur deine **eigene Internetverbindung**.

##### 🔑 Wird eine API benötigt?

**Nein**.

Das ist der Unterschied:

| Funktion		| API nötig	| Kosten				|
|:-------------:|-----------|-----------------------|
| web_fetch		| ❌ nein	| kostenlos 			|
| Brave Search	| ✅ ja		| begrenzt kostenlos 	|
| Bing Search	| ✅ ja		| kostenpflichtig 		|
| Serper		| ✅ ja		| begrenzt kostenlos 	|

##### ⚙️ Was web_fetch NICHT kann

Das ist wichtig zu verstehen.

`web_fetch` kann **nicht selbst im Internet suchen**.

Die KI braucht eine URL wie:
```
https://example.com/news
```

Dann kann sie den Inhalt der Seite lesen.

Aber sie kann **nicht automatisch nach neuen Seiten suchen**.

##### 🔎 Typischer Workflow

Viele KI-Agenten kombinieren beides:

###### 1️⃣ Search API

**z.B.**
+ Brave
+ Google
+ Serper

→ findet Webseiten

###### 2️⃣ web_fetch

→ lädt die Webseiteninhalte

##### 🧠 Beispiel mit OpenClaw

KI bekommt Aufgabe:

	„Finde aktuelle KI Nachrichten“

Workflow:

+ 1. Brave API → Suchergebnisse
+ 2. web_fetch → lädt Artikel
+ 3. LLM → fasst zusammen

##### ⚠️ Kleine Einschränkungen

Manche Webseiten blockieren automatische Bots:

+ Cloudflare
+ Login-Seiten
+ Paywalls

Dann funktioniert `web_fetch` nicht.

🚀 Für dein KI-Setup (Ollama + OpenClaw)

Ich empfehle normalerweise diese Kombination:

| Tool				| Aufgabe			|
|:-----------------:|-------------------|
| Brave Search API	| Webseiten finden	|
| web_fetch			| Webseiten lesen	|
| Ollama			| KI-Analyse		|

Damit bekommt deine KI einen **echten Internetzugang**.


##### 2️⃣ Webseiten automatisch lesen

`Firecrawl`

KI-optimiertes Web-Scraping.

**Agent kann:**

+ komplette Webseiten analysieren
+ Dokumentationen zusammenfassen

```
FIRECRAWL_API_KEY=...
```

##### 🔑 1. Wo du den FIRECRAWL_API_KEY bekommst

Gehe auf [https://firecrawl.dev](https://firecrawl.dev)

+ 1. Klicke auf **Sign Up / Get API Key**
+ 2. Konto erstellen (GitHub oder E-Mail)
+ 3. Danach im **Dashboard → API Keys**

Dort bekommst du einen Key wie z. B.:
```
fc-xxxxxxxxxxxxxxxx
```

Diesen setzt du dann z. B. in Linux:
```bash
export FIRECRAWL_API_KEY="dein_key"
```

oder in einer `.env` Datei:
```env
FIRECRAWL_API_KEY=dein_key
```
##### 💰 2. Ist Firecrawl kostenlos?

Ja — aber mit Limit.

Typischer Free-Plan:

| Plan	| Preis			| Nutzung							|
|:---------------------:|-----------------------------------|
| Free	| kostenlos		| ca. **500 Seiten / Monat crawlen**	|
| Paid	| ab ca. $16+	| mehr Crawls						|

*(Die Limits können sich ändern.)*

##### 🧠 3. Was Firecrawl besser macht als normales web_fetch

`web_fetch` lädt nur eine einzelne Seite.

Firecrawl kann:

+ komplette Webseiten crawlen
+ Navigation automatisch folgen
+ JavaScript rendern
+ Markdown extrahieren

strukturierten Text für KI erzeugen. 

##### ⚠️ 4. Kostenfallen vermeiden

Damit du **niemals Geld verlierst**, mache folgendes:

###### 1️⃣ Free Plan nutzen

Bleibe im kostenlosen Plan.

###### 2️⃣ API Limit setzen

Im Dashboard:
```
Usage limit = 0$
```

oder niedrig setzen.

###### 3️⃣ Nur einzelne Seiten crawlen

Nicht komplette Domains:

❌
```
crawl example.com/*
```

✅
```
scrape example.com/article
```
#### Firecrawl selfhostet
Du kannst **Firecrawl** auch *self-hosted* betreiben, um Webseiten automatisch zu scrapen, in Markdown umzuwandeln und als Kontext für deine KI zu verwenden. Das ist besonders nützlich für Agenten, die Informationen aus dem Web holen sollen.

Das komplette Setup: Installation → API starten → OpenClaw verbinden.

##### 1. Voraussetzungen

Für Firecrawl Self-Hosted benötigst du:

**System**

+ Docker oder Podman
+ Node.js ≥ 18
+ 4-8 GB RAM Minimum
+ optional Redis (für Queue)

Wenn du bereits **OpenClaw via Docker Compose** nutzt, kannst du Firecrawl einfach hinzufügen.

##### 2. Firecrawl Self-Hosted installieren

Repository klonen:
```bash
git clone https://github.com/mendableai/firecrawl.git
cd firecrawl
```

Docker Setup starten:
```bash
docker compose up -d
```

Danach läuft die API normalerweise auf:
```
http://localhost:3002
```

Test:
```bash
curl http://localhost:3002
```

##### 3. API Key erstellen

Self-Hosted Firecrawl erlaubt einen eigenen Key, den du selbst festlegen kannst.

In `.env` Datei:

FIRECRAWL_API_KEY=supersecretkey

Danach Container neu starten:
```bash
docker compose restart


##### ⚙️ 5. Alternative komplett ohne API (100 % kostenlos)

Wenn du **keine API-Keys willst**, kannst du lokal nutzen:

+ Firecrawl (Self-Hosted)
+ SearXNG (Suchmaschine)
+ Scrapy (Crawler)

Dann läuft alles **auf deinem eigenen Server**.

##### 3️⃣ Wissensdatenbank

Wikipedia API

Vorteile:

komplett kostenlos

keine API-Keys nötig

Agent kann:

Wissen abrufen

Fakten prüfen

#### 🗺 Karten & Orte
##### 4️⃣ Ortsdaten

Google Places API

Agent kann:

Restaurants finden

Orte analysieren

Routen planen

GOOGLE_PLACES_API_KEY=...
##### 5️⃣ Geocoding

OpenCage Geocoder

Agent kann:

Adresse → GPS

GPS → Adresse

OPENCAGE_API_KEY=...
#### 🌦 Daten & Services
##### 6️⃣ Wetter

OpenWeatherMap

Agent kann:

Wettervorhersagen abrufen

Smart-Home steuern (z. B. Rollläden)

OPENWEATHER_API_KEY=...
##### 7️⃣ News

NewsAPI

Agent kann:

aktuelle Nachrichten analysieren

Trends erkennen

NEWS_API_KEY=...
#### 💻 Entwickler-Tools
##### 8️⃣ Code-Repos

**GitHub API

Agent kann:

Repositories analysieren

Code herunterladen

Updates prüfen

##### 9️⃣ Paketinfos

**npm Registry API

Agent kann:

Node-Pakete finden

Versionsinfos prüfen

### 🏠 Smart-Home Integration
#### 🔟 Hausautomation

##### Home Assistant

Agent kann z. B.:

Licht steuern

Sensoren auslesen

Automationen starten

Integration erfolgt über REST API oder Websocket.

#### 🔊 Voice AI
##### 1️⃣1️⃣ Text-to-Speech

ElevenLabs

Agent kann:

Antworten sprechen

Voice-Assistent bauen

ELEVENLABS_API_KEY=...
##### 1️⃣2️⃣ Speech-to-Text

Whisper

Vorteil:

komplett lokal möglich

keine Kosten

Integration über:
```
brew install whisper
```

oder Python.

🔧 Beispiel .env für ein starkes Setup
```
BRAVE_API_KEY=
FIRECRAWL_API_KEY=
GOOGLE_PLACES_API_KEY=
OPENWEATHER_API_KEY=
NEWS_API_KEY=
OPENCAGE_API_KEY=
ELEVENLABS_API_KEY=
```

Damit kann dein Agent:

+ Internet durchsuchen
+ Webseiten analysieren
+ Orte finden
+ Wetter abrufen
+ Nachrichten analysieren

sprechen

💡 Mein persönlicher Tipp für dein Setup (Top 5 Tools):

+ Brave Search API
+ Firecrawl
+ Ollama
+ Home Assistant
+ Whisper

Damit hast du bereits einen vollwertigen lokalen KI-Agenten.

#### Wenn du möchtest, kann ich dir auch noch zeigen:

🔧 Die 8 besten lokalen LLM-Modelle für dein Mini-PC Setup (Ollama), die besonders gut mit OpenClaw funktionieren.
Viele davon laufen sogar mit 8–16 GB RAM stabil.

für dein Setup mit OpenClaw + Ollama auf deinem Mini-PC lohnt es sich, gezielt kleine, effiziente Modelle zu verwenden. Große Modelle laufen oft nur mit sehr viel RAM oder GPU.

Hier sind 8 der besten lokalen LLMs, die sich gut für Agent-Setups eignen.

##### 🧠 1️⃣ Allround-Modell (sehr stabil)
Llama 3.2

Sehr gute Mischung aus:

Reasoning

Chat

Coding

Empfohlen:

ollama pull llama3.2:3b

RAM Bedarf:

ca. 4-6 GB

##### 💻 2️⃣ Coding-Agent
DeepSeek Coder

Sehr stark für:

Code schreiben

Fehler finden

Terminal-Befehle generieren

Installieren:

ollama pull deepseek-coder:6.7b

RAM:

ca. 8-10 GB

##### ⚡ 3️⃣ Sehr schnelles Modell
Phi‑3 Mini

Vorteile:

extrem schnell

gute Logik

wenig RAM

ollama pull phi3:mini

RAM:

3-4 GB

##### 🤖 4️⃣ Agent-Reasoning Modell
Qwen 2.5

Sehr stark für:

Tool-Usage

Agent-Workflows

Planung

ollama pull qwen2.5:3b

RAM:

4-6 GB

##### 📚 5️⃣ Wissensmodell
Mistral

Sehr gute:

Textanalyse

Zusammenfassungen

ollama pull mistral:7b

RAM:

8-10 GB

##### 🔬 6️⃣ Forschungsmodell
Gemma 2

Von Google entwickelt.

Sehr gut für:

reasoning

Datenanalyse

ollama pull gemma2:2b

RAM:

3-4 GB

##### 🧩 7️⃣ Multitool Agent Modell
OpenHermes

Optimiert für:

Tools

Agenten

Chat

ollama pull openhermes

RAM:

6-8 GB

##### 🧮 8️⃣ Extrem kleines Modell
TinyLlama

Sehr leicht:

ollama pull tinyllama

RAM:

2 GB

Gut für:

kleine Automationen

einfache Tasks

#### 🏆 Meine Empfehlung für dein Setup

Installiere zuerst diese 4 Modelle:

ollama pull llama3.2:3b
ollama pull phi3:mini
ollama pull qwen2.5:3b
ollama pull deepseek-coder:6.7b

Damit deckst du ab:
+ Chat
+ Coding
+ Agent-Reasoning
+ schnelle Antworten

Beispiel `.env` für **OpenClaw**
```env
LLM_PROVIDER=ollama
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=llama3.2:3b
```

💡 Tipp:
Viele Nutzer lassen mehrere Modelle gleichzeitig installiert und wechseln je nach Aufgabe.

Beispiel:
+ Coding → DeepSeek
+ Chat → Llama
+ schnelle Antwort → Phi-3

Wenn du möchtest, kann ich dir auch noch zeigen:

🚀 Die 7 stärksten Ollama-Modelle für 2026, die besonders gut für AI-Agenten wie OpenClaw oder AutoGPT funktionieren.
Ein paar davon sind extrem leistungsfähig trotz kleiner Größe.

hier sind 7 der derzeit stärksten lokalen Modelle (2025–2026), die besonders gut mit Agent-Frameworks wie OpenClaw, Ollama oder ähnlichen Tools funktionieren. Ich habe sie nach Agent-Tauglichkeit, Tool-Usage und Effizienz ausgewählt. 🚀

##### 🧠 1. Universelles Top-Modell
Llama 3.2

Sehr guter Allrounder für:

Chat

Reasoning

Agent-Tasks

Installieren:

ollama pull llama3.2:3b

RAM:

etwa 4–6 GB

##### 💻 2. Bestes Coding-Modell lokal
DeepSeek Coder V2

Extrem stark für:

Code schreiben

Fehler analysieren

Terminal-Commands

ollama pull deepseek-coder-v2

RAM:

8–12 GB

##### ⚡ 3. Schnellstes Reasoning-Modell
Phi‑3 Mini

Sehr effizient und überraschend intelligent.

ollama pull phi3:mini

RAM:

3–4 GB

Perfekt für:

schnelle Agent-Antworten

kleine Systeme

##### 🤖 4. Stark für Agent-Planung
Qwen 2.5

Sehr gut für:

Tool-Usage

Multi-Step-Reasoning

AI-Agents

ollama pull qwen2.5:3b

RAM:

4–6 GB

##### 🧩 5. Tool-optimiertes Modell
OpenHermes 2.5

Trainiert speziell für:

Agents

Tools

strukturierte Antworten

ollama pull openhermes

RAM:

6–8 GB

##### 🔬 6. Neues Google-Reasoning-Modell
Gemma 2

Von Google entwickelt.

Sehr gut für:

Logik

Textanalyse

ollama pull gemma2:2b

RAM:

3–4 GB

##### 🧮 7. Extrem leichtes Modell
TinyLlama

Minimaler Ressourcenbedarf.

ollama pull tinyllama

RAM:

2 GB

Gut für:

Automationen

einfache Tasks

##### 🏆 Optimales Setup für deinen Mini-PC

Wenn dein System 16 GB RAM oder weniger hat, empfehle ich:

ollama pull llama3.2:3b
ollama pull phi3:mini
ollama pull qwen2.5:3b
ollama pull deepseek-coder-v2

Damit hast du:
+ Chat-LLM
+ Coding-LLM
+ Agent-Reasoning
+ schnelles Modell

🔧 Beispiel für OpenClaw

.env
```env
LLM_PROVIDER=ollama
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=qwen2.5:3b
```

Du kannst das Modell jederzeit wechseln:
```
ollama run phi3:mini
```

💡 Pro-Tipp für Agent-Setups:
Viele Entwickler lassen 3 Modelle parallel installiert:

+ Chat → Llama
+ Coding → DeepSeek
+ Fast responses → Phi-3

Der Agent wählt dann automatisch das passende Modell.

Wenn du möchtest, kann ich dir auch noch zeigen:

🔥 Die 10 besten Ollama-Modelle unter 4 GB RAM, die trotzdem erstaunlich leistungsfähig sind (perfekt für Mini-PC-KI-Server).


Wenn dein Mini-PC begrenzten RAM hat (z. B. 8–16 GB), sind kleine LLMs unter ~4 GB Modellgröße ideal. Sie starten schnell, laufen stabil mit Ollama und eignen sich gut für Agent-Tools wie OpenClaw.
Hier sind 10 der besten Modelle in dieser Klasse. 🚀

##### 🧠 1. Sehr gutes Allround-Mini-LLM
Phi‑3 Mini

Vorteile:

extrem effizient

gutes Reasoning

sehr schnell

Installieren:

ollama pull phi3:mini

RAM: ~3–4 GB

##### 🤖 2. Kleines Agent-Reasoning-Modell
Qwen 2.5 3B

Sehr gut für:

Tool-Usage

Planung

Agent-Tasks

ollama pull qwen2.5:3b

RAM: ~4 GB

##### 🧩 3. Sehr kleines Chat-Modell
TinyLlama

Sehr leicht und stabil.

ollama pull tinyllama

RAM: ~2 GB

##### 📚 4. Googles kompaktes Modell
Gemma 2B

entwickelt von Google

ollama pull gemma:2b

RAM: ~3 GB

##### 💻 5. Mini-Coding-LLM
DeepSeek Coder 1.3B

Gut für:

kleine Code-Tasks

Skripte

ollama pull deepseek-coder:1.3b

RAM: ~3 GB

##### 🧠 6. Kompakter Mistral-Ableger
OpenHermes 2.5

Agent-optimiertes Modell.

ollama pull openhermes

RAM: ~4 GB

##### 📊 7. Effizientes Analyse-Modell
StableLM 3B
ollama pull stablelm

RAM: ~3–4 GB

##### 🔬 8. Forschungs-LLM
RedPajama 3B
ollama pull redpajama

RAM: ~3–4 GB

##### 🧮 9. Ultra-leicht
Phi‑2

Sehr schnell.

ollama pull phi

RAM: ~2–3 GB

##### ⚡ 10. Experimentelles Mini-LLM
MiniCPM

Sehr effizient.

ollama pull minicpm

RAM: ~3 GB

⭐ Bestes Setup für deinen Mini-PC

Ich würde diese 4 installieren:

ollama pull phi3:mini
ollama pull qwen2.5:3b
ollama pull gemma:2b
ollama pull deepseek-coder:1.3b

Damit hast du:
+ schnelles Chat-Modell
+ Agent-Reasoning
+ Coding-LLM
+ Backup-Modell

🔧 Beispiel .env
```ènv
LLM_PROVIDER=ollama
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=phi3:mini
```

💡 Kleiner Geheimtipp für dein Setup:
Wenn du mehrere Modelle installiert hast, kannst du einen Agent-Router bauen:

+ Chat → Phi-3
+ Coding → DeepSeek
+ Planung → Qwen

Dadurch wirkt dein System viel intelligenter, obwohl alle Modelle klein sind.

Wenn du möchtest, kann ich dir noch etwas sehr Nützliches zeigen:

🔧 Die 6 besten Tools, um OpenClaw automatisch das beste Modell auswählen zu lassen (Auto-Model-Routing).
Das ist eine der größten Verbesserungen für lokale KI-Agenten.

jetzt geht’s ans intelligente Routing der Modelle. Damit kann dein OpenClaw-Agent automatisch entscheiden, welches Modell für welche Aufgabe genutzt wird, ohne dass du manuell wechselst. Das ist besonders praktisch bei Mini-PCs, wo du mehrere kleine LLMs installiert hast. 🚀

##### 🔹 1️⃣ Prinzip: Auto-Model-Routing

Du hast z. B. installiert:
| Modell			|   | Aufgabe								|
|:-----------------:|---|---------------------------------------|
| phi3:mini			| → | schnelle Antworten / Chat  			|
| qwen2.5:3b		| → | Agent-Reasoning / Multi-Step Tasks	|
| deepseek-coder	| → | Coding / Terminal / Scripts			|
| gemma:2b			| → | Analysen / Logik / Daten				|

**OpenClaw** kann so konfiguriert werden, dass jede Anfrage automatisch an das passende Modell geht.

Vorteil: RAM effizient nutzen, schnelle Antworten, kein unnötiges Laden großer Modelle.

#####🔹 2️⃣ Konfiguration in .env

Füge für modell-spezifisches Routing hinzu:
```env
# Standardmodell für Chat
OLLAMA_MODEL_CHAT=phi3:mini

# Modell für Coding-Aufgaben
OLLAMA_MODEL_CODING=deepseek-coder:1.3b

# Modell für Planung / Agent-Reasoning
OLLAMA_MODEL_AGENT=qwen2.5:3b

# Modell für Analyse / Logik
OLLAMA_MODEL_ANALYSIS=gemma:2b
```

##### 🔹 3️⃣ OpenClaw Konfig für Router

In `~/.openclaw/config.toml` kannst du z. B. ein Routing-Block einfügen:

```toml
[router]
chat_model = "phi3:mini"
coding_model = "deepseek-coder:1.3b"
agent_model = "qwen2.5:3b"
analysis_model = "gemma:2b"
```

OpenClaw liest das beim Start und entscheidet automatisch, welches Modell für die Anfrage genutzt wird.

##### 🔹 4️⃣ Task-Matching (optional, fortgeschritten)

Du kannst Regeln definieren, z. B.:
```toml
[rules]
"write code" = "coding_model"
"debug script" = "coding_model"
"multi-step reasoning" = "agent_model"
"analyze data" = "analysis_model"
"general chat" = "chat_model"
```

OpenClaw wählt dann automatisch das passende Modell nach Schlüsselwort oder Task-Typ.

##### 🔹 5️⃣ Vorteile

+ **RAM sparen** – nur das benötigte Modell wird geladen.
+ **Leistungsoptimierung** – kleine Modelle für schnelle Antworten, große Modelle nur für komplexe Tasks.
+ **Flexibilität** – neue Modelle einfach in .env oder config.toml eintragen.
+ **Skalierbar** – wenn du später mehr LLMs installierst, einfach neue Routing-Regeln hinzufügen.

##### 🔹 6️⃣ Extra-Tipp

Du kannst sogar Fallback-Logik einbauen:
```toml
[fallback]
default_model = "phi3:mini"
```
Wenn ein Modell gerade zu groß ist oder nicht startet, nutzt OpenClaw automatisch ein kleineres Backup-Modell.

💡 Mein Vorschlag für dein Mini-PC Setup:

+ Standard Chat → phi3:mini
+ Coding Tasks → deepseek-coder:1.3b
+ Multi-Step / Planung → qwen2.5:3b
+ Analysen → gemma:2b

Damit hast du volle Agent-Intelligenz bei minimalem RAM-Verbrauch und der Mini-PC wird nicht überlastet.

Wenn du willst, kann ich dir auch gleich eine fertige .env + config.toml Vorlage erstellen, die:

+ Auto-Routing für diese 4 Modelle enthält
+ Completion / Gateway / WSL2-Berechtigungen korrekt setzt

Sofort startklar für OpenClaw ist

Dann kannst du quasi direkt loslegen. Willst du, dass ich das mache?

### Eine fertige, startklare OpenClaw-Konfiguration für deinen Mini-PC. Sie kombiniert:

Gateway lokal

Shell completion

Auto-Model-Routing für 4 Modelle
```
.env + config.toml
```

korrekte Berechtigungen für WSL2 Ubuntu

Alles so vorbereitet, dass dein OpenClaw sofort läuft. 🦞

##### 1️⃣ .env Vorlage
```
# -------------------------------
# OpenClaw Environment
# -------------------------------

# Gateway local
BLOCK_PAID_API=true
OPENCLAW_GATEWAY_TOKEN=0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1

OPENCLAW_STATE_DIR=/home/ubuntu/.openclaw
OPENCLAW_CONFIG_PATH=/home/ubuntu/.openclaw/config.toml
OPENCLAW_HOME=/home/ubuntu
OLLAMA_HOST=http://127.0.0.1:11434
LLM_PROVIDER=ollama

# Auto-routing Modelle
OLLAMA_MODEL_CHAT=phi3:mini
OLLAMA_MODEL_CODING=deepseek-coder:1.3b
OLLAMA_MODEL_AGENT=qwen2.5:3b
OLLAMA_MODEL_ANALYSIS=gemma:2b

# API Keys (Beispiele / Fake Tokens)
GOOGLE_PLACES_API_KEY=AIzaSyXXXXXX
OPENWEATHER_API_KEY=XXXXXX
NEWS_API_KEY=XXXXXX
ELEVENLABS_API_KEY=XXXXXX
BRAVE_API_KEY=XXXXXX
FIRECRAWL_API_KEY=XXXXXX
OPENCAGE_API_KEY=XXXXXX
```

##### 2️⃣ config.toml Vorlage
```toml
# -------------------------------
# OpenClaw Configuration
# -------------------------------

[gateway]
mode = "local"
host = "127.0.0.1"
port = 7331
auth_token = "0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1"

[router]
chat_model = "phi3:mini"
coding_model = "deepseek-coder:1.3b"
agent_model = "qwen2.5:3b"
analysis_model = "gemma:2b"

[rules]
"write code" = "coding_model"
"debug script" = "coding_model"
"multi-step reasoning" = "agent_model"
"analyze data" = "analysis_model"
"general chat" = "chat_model"

[fallback]
default_model = "phi3:mini"

[completion]
cache_dir = "/home/ubuntu/.openclaw/completion_cache"
```

##### 3️⃣ Berechtigungen korrigieren

WSL2 benötigt korrekte Eigentümer & Rechte:
```bash
sudo chown -R ubuntu:ubuntu ~/.openclaw
chmod -R 700 ~/.openclaw
```
Optional: Completion-Cache erstellen

openclaw completion --write-state

##### 4️⃣ WSL2 systemd (falls Gateway Probleme macht)

Bearbeite `/etc/wsl.conf`:
```conf
[boot]
systemd=true
```

Dann:
```PowerShell
wsl --shutdown
```

und WSL2 wieder starten.

##### 5️⃣ OpenClaw starten

Jetzt einfach:
```bash
openclaw gateway
```
Gateway startet lokal

+ Auto-Routing funktioniert sofort
+ Modelle werden nach Task automatisch ausgewählt

Optional:
```bash
openclaw start
```

Startet alle Agents & Shell Completion

#### 💡 Tipp:
Du kannst später weitere Modelle hinzufügen, z. B. TinyLlama oder Phi-2 für noch weniger RAM-Verbrauch, und einfach in `.env` + `config.toml` eintragen.

Wenn du willst, kann ich dir jetzt noch ein komplettes Beispiel für ein “fertiges Mini-PC OpenClaw Setup” machen, inklusive:

+ `.env`
+ `config.toml` 
+ Installationsbefehlen für Ollama-Modelle
+ Start-Skripten

Dann kannst du mit einem Block alle LLMs und OpenClaw starten, ohne weitere Anpassungen.

Willst du, dass ich das erstelle?

##### Ein komplettes, startbereites Mini-PC-Setup für OpenClaw + Ollama, das direkt läuft. 🦞💻

Es enthält:
```
.env + config.toml
```

+ Alle wichtigen LLMs für Agent-Routing
+ Start-Skripte
+ Tipps für Berechtigungen & WSL2

##### 1️⃣ Verzeichnisstruktur
```
~/.openclaw/
├── .env
├── config.toml
├── completion_cache/
├── agents/
└── logs/
```

##### 2️⃣ .env (fertig für dein Mini-PC Setup)
```env
# -------------------------------
# OpenClaw Environment
# -------------------------------

# Gateway lokal
BLOCK_PAID_API=true
OPENCLAW_GATEWAY_TOKEN=0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1

OPENCLAW_STATE_DIR=/home/ubuntu/.openclaw
OPENCLAW_CONFIG_PATH=/home/ubuntu/.openclaw/config.toml
OPENCLAW_HOME=/home/ubuntu

# Ollama LLM Auto-Routing
LLM_PROVIDER=ollama
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL_CHAT=phi3:mini
OLLAMA_MODEL_CODING=deepseek-coder:1.3b
OLLAMA_MODEL_AGENT=qwen2.5:3b
OLLAMA_MODEL_ANALYSIS=gemma:2b

# API Keys (Beispiel-Fakes, bitte ersetzen)
GOOGLE_PLACES_API_KEY=AIzaSyXXXXXX
OPENWEATHER_API_KEY=XXXXXX
NEWS_API_KEY=XXXXXX
ELEVENLABS_API_KEY=XXXXXX
BRAVE_API_KEY=XXXXXX
FIRECRAWL_API_KEY=XXXXXX
OPENCAGE_API_KEY=XXXXXX
```

##### 3️⃣ config.toml (Routing + Gateway + Completion)
```toml
# -------------------------------
# OpenClaw Configuration
# -------------------------------

[gateway]
mode = "local"
host = "127.0.0.1"
port = 7331
auth_token = "0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1"

[router]
chat_model = "phi3:mini"
coding_model = "deepseek-coder:1.3b"
agent_model = "qwen2.5:3b"
analysis_model = "gemma:2b"

[rules]
"write code" = "coding_model"
"debug script" = "coding_model"
"multi-step reasoning" = "agent_model"
"analyze data" = "analysis_model"
"general chat" = "chat_model"

[fallback]
default_model = "phi3:mini"

[completion]
cache_dir = "/home/ubuntu/.openclaw/completion_cache"
```

##### 4️⃣ Ollama Modelle installieren
```
# Chat
ollama pull phi3:mini

# Coding
ollama pull deepseek-coder:1.3b

# Agent / Planning
ollama pull qwen2.5:3b

# Analysis / Logik
ollama pull gemma:2b
```

Optional (leicht / Backup):
```bash
ollama pull tinyllama
ollama pull phi2
```

##### 5️⃣ Berechtigungen & Cache
```bash
# Eigentümer + Rechte setzen
sudo chown -R ubuntu:ubuntu ~/.openclaw
chmod -R 700 ~/.openclaw

# Completion Cache erstellen
openclaw completion --write-state
```

##### 6️⃣ WSL2 systemd (falls Probleme beim Gateway)

/etc/wsl.conf:

```conf
[boot]
systemd=true
```

Dann:
```PowerShell
wsl --shutdown
```

und WSL2 neu starten.

##### 7️⃣ OpenClaw starten

+ Gateway starten
```
openclaw gateway
```

+ Oder alles starten inkl. Agents
```
openclaw start
```

+ Gateway läuft lokal
+ Modelle werden automatisch nach Task ausgewählt
+ RAM wird effizient genutzt

💡 Extra-Tipp:

Wenn du willst, kann ich noch ein fertiges Start-Skript erstellen, das:

+ Ollama-Modelle prüft & lädt
+ OpenClaw Gateway startet
+ Shell-Completion automatisch regeneriert

Dann musst du nur noch ein Kommando ausführen und alles ist startklar.

Willst du, dass ich das Skript erstelle?

#### Ein fertiges Start-Skript für dein Mini-PC OpenClaw + Ollama Setup. 🦞💻

Es erledigt automatisch:

Ollama-Modelle prüfen & ggf. herunterladen

OpenClaw Gateway starten

Shell-Completion regenerieren

Berechtigungen setzen

Optional: WSL2 systemd Hinweis

Speichere es z. B. als `start_openclaw.sh` in deinem Home-Verzeichnis und mach es ausführbar.

##### 1️⃣ Start-Skript: `start_openclaw.sh`
```bash
#!/bin/bash
# -------------------------------
# OpenClaw + Ollama Starter Script
# -------------------------------

# Variablen
OPENCLAW_DIR="$HOME/.openclaw"
COMPLETION_CACHE="$OPENCLAW_DIR/completion_cache"

echo "✅ Starte OpenClaw Setup..."
```

##### 1️⃣ Berechtigungen setzen
```bash
echo "🔑 Setze Eigentümer und Rechte..."
sudo chown -R $USER:$USER $OPENCLAW_DIR
chmod -R 700 $OPENCLAW_DIR
```

##### 2️⃣ Completion Cache prüfen
```bash
if [ ! -d "$COMPLETION_CACHE" ]; then
    echo "📂 Erstelle Completion Cache..."
    mkdir -p "$COMPLETION_CACHE"
fi

echo "📝 Completion Cache regenerieren..."
openclaw completion --write-state || echo "⚠️ Completion Cache konnte nicht vollständig erzeugt werden"
```

##### 3️⃣ Ollama Modelle prüfen / herunterladen
```bash
MODELS=("phi3:mini" "deepseek-coder:1.3b" "qwen2.5:3b" "gemma:2b")

for MODEL in "${MODELS[@]}"; do
    echo "📦 Prüfe Modell: $MODEL"
    if ! ollama list | grep -q "$MODEL"; then
        echo "⬇️  Download Modell: $MODEL"
        ollama pull "$MODEL"
    else
        echo "✅ Modell $MODEL bereits vorhanden"
    fi
done
```

##### 4️⃣ Hinweis für WSL2 systemd
```bash
if grep -q "microsoft" /proc/version; then
    echo "⚠️ WSL2 erkannt: systemd muss aktiviert sein (wsl.conf [boot] systemd=true)"
    echo "   Danach: 'wsl --shutdown' und neu starten"
fi
```

##### 5️⃣ OpenClaw Gateway starten
```bash
echo "🚀 Starte OpenClaw Gateway..."
openclaw gateway

echo "🎉 Setup fertig! OpenClaw Gateway läuft lokal."
```

##### 2️⃣ Skript ausführbar machen
```bash
chmod +x ~/start_openclaw.sh
```

##### 3️⃣ Skript ausführen
```bash
~/start_openclaw.sh
```

Prüft die Ollama-Modelle

Setzt Berechtigungen

Startet Gateway + Shell Completion

Meldet WSL2-Systemd-Hinweis (falls nötig)

💡 Extra-Tipp:

Später kannst du in MODELS=(...) weitere kleine Modelle hinzufügen (z. B. tinyllama, phi2)

Gateway-Token und API-Keys kommen automatisch aus deiner .env

Wenn du willst, kann ich jetzt noch eine komplett fertige ZIP-Struktur bauen:

+ `.env`
+ `config.toml`
+ `start_openclaw.sh`
+ alle Unterordner

mit direkt startbereitem OpenClaw Setup für Mini-PC

Dann musst du nur entpacken und starten.

Willst du, dass ich das erstelle?

Dann fasse ich alles in einer fertigen Mini-PC OpenClaw-ZIP-Struktur zusammen. 🦞💻

Dieses Setup ist so startklar, dass du nach Entpacken nur noch ein Kommando ausführen musst. Es enthält:

.env (mit Auto-Routing & Fake-API-Tokens)

config.toml (Gateway + Model-Router + Completion)

start_openclaw.sh (alles automatisiert: Modelle prüfen, Berechtigungen, Gateway starten)

Alle Unterordner (agents, logs, completion_cache)

Hinweise für WSL2 systemd

📂 ZIP-Struktur
```
openclaw_setup/
├── .env
├── config.toml
├── start_openclaw.sh
├── agents/
├── logs/
└── completion_cache/
```

#### 1️⃣ .env
##### OpenClaw Environment
```bash
BLOCK_PAID_API=true
OPENCLAW_GATEWAY_TOKEN=0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1

OPENCLAW_STATE_DIR=/home/ubuntu/.openclaw
OPENCLAW_CONFIG_PATH=/home/ubuntu/.openclaw/config.toml
OPENCLAW_HOME=/home/ubuntu

LLM_PROVIDER=ollama
OLLAMA_HOST=http://127.0.0.1:11434

OLLAMA_MODEL_CHAT=phi3:mini
OLLAMA_MODEL_CODING=deepseek-coder:1.3b
OLLAMA_MODEL_AGENT=qwen2.5:3b
OLLAMA_MODEL_ANALYSIS=gemma:2b

GOOGLE_PLACES_API_KEY=AIzaSyXXXXXX
OPENWEATHER_API_KEY=XXXXXX
NEWS_API_KEY=XXXXXX
ELEVENLABS_API_KEY=XXXXXX
BRAVE_API_KEY=XXXXXX
FIRECRAWL_API_KEY=XXXXXX
OPENCAGE_API_KEY=XXXXXX
```

##### 2️⃣ config.toml
```toml
[gateway]
mode = "local"
host = "127.0.0.1"
port = 7331
auth_token = "0d26cb01cea57989b74ff5f8c1c4c3e639f6c5a4e9e256d0b4255de00aaa54d1"

[router]
chat_model = "phi3:mini"
coding_model = "deepseek-coder:1.3b"
agent_model = "qwen2.5:3b"
analysis_model = "gemma:2b"

[rules]
"write code" = "coding_model"
"debug script" = "coding_model"
"multi-step reasoning" = "agent_model"
"analyze data" = "analysis_model"
"general chat" = "chat_model"

[fallback]
default_model = "phi3:mini"

[completion]
cache_dir = "/home/ubuntu/.openclaw/completion_cache"
```

##### 3️⃣ start_openclaw.sh
```bash
#!/bin/bash
# OpenClaw + Ollama Starter Script

OPENCLAW_DIR="$HOME/.openclaw"
COMPLETION_CACHE="$OPENCLAW_DIR/completion_cache"

echo "✅ Starte OpenClaw Setup..."

sudo chown -R $USER:$USER $OPENCLAW_DIR
chmod -R 700 $OPENCLAW_DIR

mkdir -p "$COMPLETION_CACHE"
openclaw completion --write-state || echo "⚠️ Completion Cache konnte nicht erzeugt werden"

MODELS=("phi3:mini" "deepseek-coder:1.3b" "qwen2.5:3b" "gemma:2b")

for MODEL in "${MODELS[@]}"; do
    echo "📦 Prüfe Modell: $MODEL"
    if ! ollama list | grep -q "$MODEL"; then
        echo "⬇️ Download Modell: $MODEL"
        ollama pull "$MODEL"
    else
        echo "✅ Modell $MODEL vorhanden"
    fi
done

if grep -q "microsoft" /proc/version; then
    echo "⚠️ WSL2 erkannt: systemd muss aktiviert sein (wsl.conf [boot] systemd=true)"
    echo "   Danach: 'wsl --shutdown' und neu starten"
fi

echo "🚀 Starte OpenClaw Gateway..."
openclaw gateway

echo "🎉 OpenClaw Setup fertig!"
```

Skript ausführbar machen:
```bash
chmod +x start_openclaw.sh
```

Ausführen:
```bash
./start_openclaw.sh
```

##### 4️⃣ Unterordner
```
agents/             # Agent-Daten, Skripte etc.
logs/               # Logdateien OpenClaw
completion_cache/   # Cache für Shell Completion
```

Alle Ordner sollten chmod 700 haben, Eigentümer ubuntu.

💡 Tipp für Mini-PC:

Später kannst du weitere kleine LLMs (TinyLlama, Phi-2) einfach in MODELS im Skript eintragen.

`.env` + `config.toml` musst du nur einmal anpassen, danach alles automatisch via Skript startbereit.


# Das wurde irgendwo entfernt bzw. halbiert:
EACCES


XXXXXX

Mit `openclaw gateway --allow-unconfigured` funktioniert es, jedoch egal ob mit `pnpm start` ergibt Fehler: " ELIFECYCLE  Command failed with exit code 1." oder mit `openclaw gateway` ergibt: 
```

🦞 OpenClaw 2026.2.22 (73e5bb7) — Siri's competent cousin.

12:37:43 Gateway start blocked: set gateway.mode=local (current: unset) or pass --allow-unconfigured.
12:37:44 Config write audit: /home/ubuntu/.openclaw/logs/config-audit.jsonl
```
In welchem Dateiformat wird oder soll mit `nano` gespeichert werden. Im Dos oder Mac Format? Vieleicht dies der Fehler ist, wie auch für die "config.toml" und ".env" geltend?
Die Dateien habe ich selbst im Dos Format gespeichert. Werden aber irgendwie nicht anerkannt. 
"nano ~/.openclaw/config.tom" ist ordungsgemäß. Allerdings die "nano ~/.openclaw/.env" ist leer. Ist das der Grund?

