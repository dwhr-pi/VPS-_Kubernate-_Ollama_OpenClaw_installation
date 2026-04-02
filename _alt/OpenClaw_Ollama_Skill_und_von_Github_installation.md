Inhalt: 
+ []()
+ []()
+ [Danach: Ollama anbinden](OpenClaw_Ollama_Skill_und_von_Github_installation.md#Danach_Ollama_anbinden)
+ []()
+ []()

```bash
git clone https://github.com/openclaw/OpenClaw.git
cd OpenClaw
```

#### 🧹 Jetzt räumen wir sauber auf

Du bist hier:
```bash
~/openclaw
```

Das ist dein eigenes kleines npm-Projekt.

Wenn du wirklich das GitHub-Repo willst, dann:
```bash
cd ~
rm -rf openclaw
```

Jetzt existiert kein Konflikt mehr.

#### 🚀 Jetzt richtig klonen
```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
```

Jetzt sollte `ls -la` deutlich mehr zeigen als nur 3 Dateien.

#### 🎯 Nächster Schritt

Nachdem du das echte Repo geklont hast, sag mir:
```bash
ls -la
node -v
```

Jetzt sollte `ls -la` deutlich mehr zeigen als nur 3 Dateien.
Ist das der Fall. 
Dann bauen wir es sauber mit `pnpm` oder `npm` (je nachdem, was das Repo nutzt). 

Das ist jetzt eindeutig das echte Repo vom npm-Paket:
**openclaw**

Du siehst:

+ apps/
+ packages/
+ skills/
+ pnpm-lock.yaml
+ pnpm-workspace.yaml
+ riesiges Monorepo

Und Node:
```
v22.22.0
```

Perfekt. Mehr als ausreichend. 💪

#### 🚀 Jetzt installieren wir es korrekt

Dieses Projekt nutzt pnpm, nicht npm.

##### 1️⃣ pnpm installieren (falls noch nicht da)
```bash
npm install -g pnpm
```

Prüfen:
```bash
pnpm -v
```

##### 2️⃣ Dependencies installieren

Im Repo-Root (~/openclaw):
```bash
pnpm install
```
Das dauert ein paar Minuten.

##### 3️⃣ Build

Danach:
```bash
pnpm build
```

Wenn kein Fehler → sehr gut. (Dieser Vorgang kann recht lange dauern, Build complete erscheint mehrfach und nicht nur einmal. Danach rührt sich wieder nichts und dann gehts aufeinmal wieder weiter.)

##### 4️⃣ Dev starten (zum Testen)
```bash
pnpm dev
```
auch in diesem Teil wird noch gebaut, aber dies dauert nicht mehr so lange. 

Oder (je nach README):
```bash
pnpm start
```
<A name="Danach_Ollama_anbinden"></A>
#### 🔗 Danach: Ollama anbinden

Du willst ja:

+ Ollama
+ llama3
+ Skill gcali

Also prüfen wir als Nächstes:
```bash
ollama list
```

Die GB beziehen sich zusätzlich vorallem auch auf den freien Arbeitsspeicher RAM des Computers, den das LLM jedenfalls auch benötigt. 

Wenn `llama3` mit 4,7 GB noch nicht da ist: 
```bash
ollama pull llama3
```

Ich habe mich später für ein recht kleines Modell `llama3.2:1b` entschieden. 
Mit nur **1,3 GB Datei-Größe** und auch für den **RAM**. 
Zum Testen einfach ideal. 
```bash
ollama pull llama3.2:1b
```

Oder das große Modell `qwen2.5-coder:32b` mit 19,2 GB. 
```bash
ollama pull qwen2.5-coder:32b
```

Das LLM `glm-4.7` funktioniert leider nicht. 
```
ollama pull glm-4.7
```

##### 💡 Falls dein PC insgesamt nur 8GB RAM hat

Dann wird es eng.
Optionen:

Kleinere Modelle wie: **llama3:8b-instruct-q4**  (Funktioniert leider nicht!)
Installieren: 
```bash 
ollama pull llama3:8b-instruct-q4
```

Ausführen:
```bash
ollama run llama3:8b-instruct-q4
```

Deinstallieren: 
```bash
ollama rm llama3:8b-instruct-q4
```

Oder ausführen mit: `phi3` ist die Modellbezeichnung, siehe bei [LLM-Modelle](LLM-Modelle.md).
```bash
ollama run phi3
```


Kleinere Modelle wie: **llama3:8b**  
Installieren: 
```bash 
ollama pull llama3:8b
```

Oder **weitere Tiny-Modelle**, siehe hierzu auf [LLM-Modelle](LLM-Modelle.md)



#### 🧠 Ganz wichtiger Punkt

Bevor du OpenClaw startest:
```bash
cp .env.example .env
```

Dann öffnen:
```bash
nano .env
```

Bitte hier ganz wichtig, um die [Openclaw-Konfigurationsdatei](#Openclaw-Konfigurationsdatei) später bei Bedarf bearbeiten zu können. 


Dort musst du vermutlich setzen:
```code
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3
```
(Genauen Key schauen wir uns noch an, falls nötig.)


#######
fehlen
#######

##### 🎯 So gehen wir systematisch vor
###### 1️⃣ Prüfen der Ports

Wenn du openclaw gateway starten willst, nutzt er standardmäßig Port 18789 (lokal):
```bash
lsof -i :18789
```

Wenn da etwas anderes läuft → mit --force neu starten:
```bash
openclaw gateway --force
```

Das Webinterface ist jeweils zuerreichen mit: 
+ OpenClaw Standart
```
http://127.0.0.1:18789/
```

+ OpenClaw Canvas
```
http://127.0.0.1:18789/__openclaw__/canvas/
```

##### 2️⃣ Environment prüfen

Dev-Modus braucht .env. Kopiere erst:
```bash
cp .env.example .env
nano .env
``` 
+ LLM_PROVIDER=ollama
+ OLLAMA_BASE_URL=http://localhost:11434
+ OLLAMA_MODEL=llama3

Ohne diese Settings kann der Dev-Server nicht vollständig starten → ELIFECYCLE 1.

Bitte hier ganz wichtig, um die [Openclaw-Konfigurationsdatei](#Openclaw-Konfigurationsdatei) apäter bei Bedarf bearbeiten zu können. 

#### Openclaw-Konfigurationsdatei
**Wichtig**: Dieser Schritt ist sehr wichtig und intressant. 
Da hier diverse Konfigurationen mit der Datei recht einfach möglich sind und als solches erscheinen. 

Mit nachfolgendem Befehl kann man die Konfigurationsdatei zum nachträglichen Bearbeiten im `Openclaw`-Verzeichnis wieder aufrufen. 

```
nano .env.example .env
```

Mit dem `cd ..` Befehl kann man bei Bearf einfach zum übergeordneten Verzeichnis wieder zurück wechseln, um beispielsweise mit Ollama weiter zu machen. 
```
cd ..
```

Mit `cd openclaw` wechselt man bei Bedarf wieder in das betreffene Arbeitsverzeichnis vom Openclaw. 

```
cd openclaw
```

##### 3️⃣ Ollama / Llama3 laufen lassen
```bash
ollama list       # prüft vorhandene Modelle
ollama pull llama3
ollama run llama3
```
Dann in einem anderen Terminal:
```bash
pnpm dev
```
So kann OpenClaw sich korrekt verbinden.

##### 4️⃣ Dev Gateway isoliert testen

Wenn immer noch Fehler:
```bash
openclaw --dev gateway
```
Das startet den Gateway lokal auf Port 19001 in isoliertem State → keine Konflikte.

##### 5️⃣ Optional: Logs genauer ansehen
```
pnpm dev -- --verbose
```

Damit siehst du, wo genau der Exit-Code 1 kommt (meist ein fehlender LLM-Provider oder Port-Problem).

##### 💡 Zusammenfassung:

+ Exit 1 = nicht der Repo-Build, sondern Laufzeit / Environment
+ Setze .env korrekt
+ Starte Ollama / Llama3
+ Starte OpenClaw Gateway

Wenn nötig `--dev` oder `--force` 
