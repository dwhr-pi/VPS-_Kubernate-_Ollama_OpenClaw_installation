# VPS, Kubernetes, Olama & OpenClaw-Installation



### ChatGPT.com

Auch wenn [ChatGPT.com](https://chatgpt.com/) als verrufen gilt, habe ich es gerne in der Verwendung, um damit meine Linux Probleme zu lösen. Natürlich andere AIs eigenen sich dazu auch.  
Dies rate ich Ihnen auch an, falls bei der Installation etwas schief geht oder widererwartend abläuft.  
Einfach alles ab dem problematischen Vorgang, dessen Befehl und alles nachfolgende aus dem Terminal markieren und kopieren und in ChatGPT.com einfügen. Sinngemäß stelle ich zuvor noch die gestellte Frage zu dem Problem, wie beispielsweie: "Das dauert auch schon fast ewig und wird nicht fertig. Wie lange kann das normal dauern? Was kann der Fehler an der man-db sein?: sudo apt remove gcalcli -y
 Removing gcalcli (4.3.0-1) ... Processing triggers for man-db (2.10.2-1) ..." 

```
Ah, classic Debian/Ubuntu-Moment 😅
Wenn es bei

Processing triggers for man-db (2.10.2-1) ...


hängen bleibt, wirkt es wie eingefroren – ist es aber oft gar nicht.

🕒 Wie lange ist „normal“?

Der Trigger von man-db aktualisiert die Manpage-Daten....
```
Macht man so weiter, hilft ChatGPT.com tatsächlich bei den Problemen weiter...  
Anfänglich hatte es auch nicht so recht bei mir geholfen. 
Doch danke ChatGPT kam ich dem Fehler endlich auf die Schliche. 
Bei mir musste `snapd` wieder entfernt werden. Damit die man-db beim update und upgrade wieder funktioniert. Nunja!... 
Linus Torwald hat ganze Arbeit geleistet. Ohne Chatgpt.com wäre Linux nur einfacher mißt und nicht zu bedienen. 
In einigen Fällen ist es besser, die weiteren Empfelungen von ChatGPT.com zu übersprigen und somit zu ignorieren. 
In dem man nach dem Ausführen des ersten Schrittes besser gleich sofort die Ausgabe im Terminal ChatGPT.com postet. 
Dann wird in der neuen Auswertung dessen schonmal festgestellt, das es noch an etwas anderes liegt und von daher sich der obrige Schritt 2 nur deshalb erübrigt hat. Später könnte dieser deshalb fehlende Schritt 2 noch mal von ChatGPT.com genannt werden und wird somit erst an geeignter Stelle erst angewendet. 
In meinem Fall klammerte sich `snapd` als Endlosschleife an das `systemd`, somit der `dbus` versucht, `systemd` zu triggern – **WSL hat aber kein richtiges systemd**, also hängt alles bei `apt/dpkg` 
Mit ChatGPT könnte man zusammen zum med. Linux Chirugen werden. 
**Merke**: Immer wenn eine Meldung oder unerwartes Verhalten von Linux einem Fragwürdig vorkommt. Rein damit in ChaptGPT.com. Das hat geholfen! 

### Schritt 1 – Prüfen der WSL-Version

#### PowerShell (Admin):
```
wsl --version
```

Du solltest sehen:

+ WSL Version (2.x)
+ Kernel-Version
+ Build

Wenn die Version < 1.2 oder veraltet ist → Update nötig.

### ✅ Schritt 2 – WSL Kernel Update erzwingen

PowerShell (Admin):
```
wsl --update
wsl --shutdown
```

### ✅ Schritt 3 – WSL systemd deaktivieren

Bei Beadarf bitte zwischenzeitlich wieder einschalten. 
In der Regel ist dieses systemd für den zuvor oben eingangs beschrieben Fehler mit der man-db verantwortlich. 
Einzeitweise oder dauerhaftes deaktivieren hilft weiter. 

Hier blieb die man-db fest: 
```
Processing triggers for man-db (2.10.2-1) ...
```

#### Wir deaktivieren systemd in WSL.
Für 99 % der WSL-Setups brauchst du es nicht.

##### Schritt 1: systemd in WSL deaktivieren

In WSL:
```
sudo nano /etc/wsl.conf
```

Falls da drin steht:
```
[boot]
systemd=true
```

👉 Ändere es zu:
```
[boot]
systemd=false
```

Oder lösche die ganze `[boot]` Sektion komplett.

Speichern und schließen.

##### Schritt 2: WSL komplett stoppen

In PowerShell:
```
wsl --shutdown
```

Dann Ubuntu wieder starten.
```
wsl
```

##### Schritt 3: Paketmanager reparieren

Jetzt in WSL:
```
sudo dpkg --configure -a
sudo apt -f install
```

Jetzt sollte `dbus` nicht mehr versuchen, `systemd` zu reloaden – und der Fehler mit dem Trigger in der `man-db` verschwindet endlich.


In meinem Fall habe ich dann mit der Deinstalltion bzw. Installation der `gcalcli-Version` weitergemacht, dem Skill für den Google Kalender.  
Siehe bei [Python gcalcli](readme.md#Python_gcalcli)


### ✅ Schritt 3 – Alle verfügbaren Distros prüfen
```
wsl --list --online
```

Du solltest jetzt Ubuntu-Varianten wie Ubuntu-22.04 LTS sehen.

Wenn ja, dann:
```
wsl --install -d Ubuntu-22.04
```


```
wsl: Es wird die Legacy-Verteilungsregistrierung verwendet. Erwägen Sie, stattdessen eine TAR-basierte Verteilung zu verwenden.
Herunterladen: Ubuntu 22.04 LTS
[                           0,0%                           ]
```

Ahhh, jetzt wird’s richtig spannend 😄

Der Hinweis:
```
Es wird die Legacy-Verteilungsregistrierung verwendet. Erwägen Sie, stattdessen eine TAR-basierte Verteilung zu verwenden.
```

ist nur ein Warnhinweis, kein Fehler.
WSL lädt gerade die Distro herunter (der Fortschrittsbalken zeigt 0,0 %).  

####⚡Wichtig:

+ Der Download kann mehrere Minuten dauern, je nach Internetverbindung.
+ Bei sehr langsamer Verbindung bleibt der Balken lange auf 0,0 %.

#### ✅ Wenn der Download hängt

1. Prüfe Internetzugang in PowerShell
```
ping archive.ubuntu.com
```

→ Antwort sollte kommen.

2. Falls Proxy oder Firewall aktiv: temporär deaktivieren oder WSL durchlassen.

3. Alternativ **manuell die TAR-Datei installieren**:

+ Lade Ubuntu 22.04 LTS als **TAR** herunter:
[Ubuntu WSL Releases](https://cloud-images.ubuntu.com/releases/jammy/release/)

+ Dann in PowerShell:
```
wsl --import Ubuntu-22.04 C:\WSL\Ubuntu2204 C:\Pfad\zur\Ubuntu22.04.tar --version 2
```

So überspringst du den Microsoft Store.

#### Kurzfassung

+ 0,0 % Fortschritt = Download läuft oder hängt.
+ Legacy-Warnung = nur Hinweis, kein Problem.
+ Wenn es **nach >5–10 Minuten** immer noch 0 % ist → besser TAR-Variante installieren.








###### systemd
```
wsl: Failed to start the systemd user session for 'ubuntu'. See journalctl for more details.
```
bedeutet:  

WSL läuft, aber **systemd ist nicht korrekt aktiviert oder sauber gestartet**.
Das ist nach Neuinstallationen relativ häufig.

**Anmerkung**: Laut einigen Berichten, srbeitet die WSL ohne **systemd**.
Diese Fehlermeldung ist also normal. 

##### Schritt 1 – Prüfen ob Ubuntu trotzdem läuft

Gib ein:
```
ls
```

Wenn du Dateien siehst → Ubuntu läuft ganz normal.
Die systemd-Meldung ist dann erstmal nur ein Warnhinweis.

##### Schritt 2 – systemd sauber aktivieren (wichtig für Ollama!)

Öffne:
```
sudo nano /etc/wsl.conf
```

Falls die Datei nicht existiert → neu anlegen.

Inhalt:
```
[boot]
systemd=true
```

Speichern.

##### Schritt 3 – WSL komplett neu starten

In PowerShell (nicht in Ubuntu!):
```
wsl --shutdown

```
Dann wieder starten:
```
wsl
```
##### Prüfen ob systemd jetzt läuft

In Ubuntu:
```
systemctl
```

Wenn du jetzt keine Fehlermeldung bekommst → alles gut.

#### ⚠️ Wenn Fehler bleibt

Dann ist vermutlich dein WSL-Kernel noch veraltet. 

In PowerShell (Admin):
```
wsl --update
wsl --shutdown
```
Warum das wichtig ist

Ollama nutzt systemd für:

Service-Management

Port 11434 sauber binden

Background-Prozesse

Ohne **systemd** gibt es später wieder mysteriöse Fehler. 
Da die WSL dieses Problem vorgeben hat, muss es so bleiben. 

#### systemd läuft.
Das lange systemctl-Listing zeigt, dass alles korrekt gestartet ist.

Die Warnung:
```
Failed to start the systemd user session for 'ubuntu'
```

ist bei WSL manchmal ein kosmetischer Bug.
Solange systemctl funktioniert (und das tut es), ist alles okay.

Du bist also stabil unterwegs ✅


### Jetzt sauber weitermachen

**Wichtig:**
Du bist aktuell hier:
```
/mnt/c/Users/danie
```

Das ist das Windows-Dateisystem.
Für Node/Ollama/OpenClaw bitte NICHT dort arbeiten.

#### ✅ Wechsel ins Linux-Home
```
cd ~
pwd
```

Es sollte stehen:
```
/home/ubuntu
```

#### ✅ Jetzt die Node sauber installieren (über NVM)

Falls noch nicht gemacht:
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
```

Test:

```
node -v
npm -v
```

#### ✅ Dann für Ollama die zstd
```
sudo apt-get install zstd
```

#### ✅ Dann Ollama
```
curl -fsSL https://ollama.com/install.sh | sh
```

Test:
```
ollama --version
```

Gibt zurück: 
```
ollama version is 0.16.0
```


✅ OpenClaw diesmal lokal (nicht global oder im User)

KEIN sudo npm install -g

Stattdessen:
```
mkdir ~/openclaw
cd ~/openclaw
npm init -y
npm install openclaw
```

#### allerdings gab es diese Fehlermelung, 

die zuvor behandelt werden sollte. 

```
mkdir ~/openclaw
cd ~/openclaw
npm init -y
npm install openclaw
Wrote to /home/ubuntu/openclaw/package.json:

{
  "name": "openclaw",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}



npm warn deprecated node-domexception@1.0.0: Use your platform's native DOMException instead
npm warn deprecated are-we-there-yet@3.0.1: This package is no longer supported.
npm warn deprecated npmlog@6.0.2: This package is no longer supported.
npm warn deprecated gauge@4.0.4: This package is no longer supported.
npm warn deprecated tar@6.2.1: Old versions of tar are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 672 packages, and audited 673 packages in 8m

127 packages are looking for funding
  run npm fund for details

4 high severity vulnerabilities

To address all issues, run:
  npm audit fix

Run npm audit for details.
```

Sehr gut 👍 erstmal tief durchatmen — das ist kein Installationsfehler.

Das hier:
```
deprecated ...
4 high severity vulnerabilities
```

bedeutet NICHT:

+ ❌ dein System ist kaputt

+ ❌ OpenClaw läuft nicht

+ ❌ du hast etwas falsch gemacht

**Es bedeutet nur:**

+ 👉 Einige Abhängigkeiten von OpenClaw verwenden ältere npm-Pakete.
+ 👉 Das ist aktuell bei vielen Node-Projekten normal.

##### Wegen der 4 „High Severity Vulnerabilities“

Du kannst prüfen mit:
```
npm audit
```

Aber:

##### ⚠️ Nicht blind `npm audit fix --force` ausführen,
das kann OpenClaw kaputtpatchen.

In 90% der Fälle betrifft das nur Dev-Dependencies oder CLI-Tools.

#####💡Warum diese Warnungen erscheinen

OpenClaw zieht u.a.:

+ glob
+ tar
+ gauge
+ npmlog

Diese sind alt, aber weit verbreitet.

Das ist eher ein „Maintainer muss irgendwann updaten“-Thema.


#### Teste jetzt Openclaw mit:
```
npx openclaw --version
```

Wenn eine Version wie 
```
2026.2.9
```
angezeigt wird → alles gut.

Dann starten mit:
```
npx openclaw gateway
```

Das ist viel stabiler als global installieren.

Nach einiger Zeit sollte OpenClaw endlich starten und gibt einen noch unwichtigen Konfigurationsfehler aus. 


#### 🚀 Nächster Schritt: Ollama verbinden

Stelle sicher:
```
ollama serve
```

In neuem Terminal:
```
ollama pull llama3
```
llama3 dauert im Download recht lange. es sind rund 4,7 GB. 


Dann config erstellen:
```
mkdir -p ~/.openclaw
nano ~/.openclaw/config.json
```

Inhalt:
```
{
  "LLM_PROVIDER": "ollama",
  "LLM_BASE_URL": "http://localhost:11434/v1",
  "LLM_MODEL": "llama3"
}
```

Speichern.

Dann:
```
npx openclaw gateway
```


```
mkdir -p ~/.openclaw
nano ~/.openclaw/config.json
ubuntu@Letsung-MiniPC1:~/openclaw$ npx openclaw gateway

🦞 OpenClaw 2026.2.9 (33c75cb) — I can't fix your code taste, but I can fix your build and your backlog.

23:01:51 Missing config. Run `openclaw setup` or set gateway.mode=local (or pass --allow-unconfigured).
ubuntu@Letsung-MiniPC1:~/openclaw$
```

das bedeutet: OpenClaw selbst läuft, aber es findet die Runtime-Config nicht.

Der Hinweis:
```
Missing config. Run `openclaw setup` or set gateway.mode=local (or pass --allow-unconfigured)
```

zeigt, dass OpenClaw die `~/.openclaw/config.json` nicht automatisch erkennt oder sie evtl. einen kleinen Fehler hat. 

#### ✅ Prüfen, dass die config korrekt ist

Prüfen, dass die Datei existiert:
```
ls -l ~/.openclaw/config.json
```

Ergebnis sollte so aussehen:
```
-rw-r--r-- 1 ubuntu ubuntu 123 Feb 13 23:00 /home/ubuntu/.openclaw/config.json
```

Inhalt prüfen:
```
cat ~/.openclaw/config.json
```

Es sollte exakt so aussehen (angepasst auf dein Modell):
```
{
  "LLM_PROVIDER": "ollama",
  "LLM_BASE_URL": "http://localhost:11434/v1",
  "LLM_MODEL": "llama3"
}
```

Tipp: Keine Kommentare (//) einfügen, JSON erlaubt nur Key-Value. 



#### ✅ Starten mit lokalem Modus (falls Config noch nicht erkannt wird)

Dies ist sinnvoll, bevor das Setup gestartet wird zu testen: 
```
npx openclaw gateway --allow-unconfigured

oder Neu: funktioniert nicht
pass --allow-unconfigured
```

oder

```
npx openclaw gateway --mode local

oder Neu: funktioniert nicht
set gateway.mode=local
```

Damit überspringt OpenClaw die Config-Prüfung und startet trotzdem. 
Das ignoriert die fehlende Konfiguration. Für dauerhaftes Setup aber lieber sauber konfigurieren.

Eventuell gibt es hierbei den Fehler zurück: 
```
error: unknown option '--mode'
```

#### Warum das überhaupt kommt

Neuere Versionen blockieren den Start, wenn kein Modus definiert ist —
damit man den Gateway nicht versehentlich offen ins Internet stellt.

Eigentlich eine sinnvolle Sicherheitsmaßnahme.

Läuft das bei dir rein lokal auf dem Rechner oder auf einem Server/VPS? 
Dies ist wegen der Sicherheit wichtig zu berücksichtigen. 

#### Einmal den local Modus setzen:
```
npx openclaw config set gateway.mode local
```

Danach starten:
```
npx openclaw gateway
```

Damit ist alles korrekt konfiguriert.

#### OpenClaw Token

##### Schritt 1: Token festlegen

Du kannst einfach irgendeinen sicheren String nehmen, wie z. B.:  
```
my-local-dev-token-123
```

Oder etwas Zufälliges generieren:  

macOS / Linux
```
openssl rand -hex 32
```

Windows (PowerShell)
```
[guid]::NewGuid().ToString()
```

##### 🔧 Schritt 2: Token beim Server setzen
(normal hier nicht für lokal wichtig)
Wenn du den OpenClaw-Server startest, musst du dort das gleiche Token konfigurieren, z. B. über eine Umgebungsvariable:

macOS / Linux
```
export OPENCLAW_GATEWAY_TOKEN=my-local-dev-token-123
npx openclaw server
```

Windows (PowerShell)
```
$env:OPENCLAW_GATEWAY_TOKEN="my-local-dev-token-123"
npx openclaw server
```

##### 🚪 Schritt 3: Gateway mit demselben Token starten

In einem zweiten Terminal:
```
export OPENCLAW_GATEWAY_TOKEN=my-local-dev-token-123
npx openclaw gateway
```

Oder direkt: (Dieser ist für lokal innerhalb von Ubuntu wichtig und sollte den gleichen vorherigen Token haben.)
```
npx openclaw gateway --token my-local-dev-token-123
```

Es wird sich die Windows Firewall melden. 
Bitte gestatte der nodes.js den Zugriff auf das Netzwerk. 

##### 🧠 Wichtig

Server und Gateway müssen exakt dasselbe Token verwenden.
Wenn sie unterschiedlich sind → Auth-Fehler.


#### 🔧 Optional: Setup-Assistent nutzen

OpenClaw bietet ein Setup-Tool, das die Config automatisch erstellt:

```
npx openclaw setup
```

Dann folgst du den Eingaben:

+ LLM-Provider → ollama
+ Base URL → http://localhost:11434/v1
+ Modell → llama3

Nach dem Setup sollte `npx openclaw gateway` ohne Fehlermeldung starten.

#### 💡 Kurzfassung:

+ Config existiert → JSON prüfen (keine Kommentare, korrektes Format)
+ Config wird nicht gefunden → `--allow-unconfigured` oder `npx openclaw setup` nutzen
+ Danach Gateway starten → läuft stabil

### 1️⃣ Ollama-Service starten

Zuerst in einem eigenen Terminal:
```
ollama serve
```

Damit läuft der lokale Ollama-Server auf Port 11434. 

Eventuell gibt es den Fehler: 
```
Error: listen tcp 127.0.0.1:11434: bind: address already in use
```
Lass dieses Terminal offen, sonst kann OpenClaw nicht verbinden.

Testen:
```
curl http://localhost:11434/v1/models
```

Du solltest eine Liste der verfügbaren Modelle sehen.

```
{"object":"list","data":[{"id":"llama3:latest","object":"model","created":1770936854,"owned_by":"library"}]}
```

Wenn `llama3` geladen ist → perfekt.

### 2️⃣ OpenClaw Setup starten

Im anderen Terminal, in deinem Projektordner:
```
npx openclaw setup
```

Folge den Eingaben:

+ LLM Provider: ollama
+ Base URL: http://localhost:11434/v1
+ Modell: llama3

Damit erzeugt OpenClaw automatisch eine saubere ~/.openclaw/config.json. 

```
Need to install the following packages:
openclaw@2026.2.9
Ok to proceed? (y) 
```

Mit `y` bestätigen. 
Danach wird downgeladen und installiert. 

Es werden leider einige 
`npm warn deprecated` ausgegeben. 
Dies nicht weiter problematisch ist. 

#### 3️⃣ Config prüfen

Optional:
```
cat ~/.openclaw/config.json
```

Es sollte so aussehen:
```
{
  "LLM_PROVIDER": "ollama",
  "LLM_BASE_URL": "http://localhost:11434/v1",
  "LLM_MODEL": "llama3",
  "ENABLE_SKILLS": true,
  "SKILL_AUTOLOAD": true
}
```

+ "ENABLE_SKILLS": true → Skills wie Kalender, GitHub etc. werden aktiviert.
+ "SKILL_AUTOLOAD": true → Lädt automatisch beim Start.

Eventuell wird erst die Installation der Skills benötigt und danach die Eintragung in der Konfigurationsdatei vornehmen. 
Damit die letzten beiden Eintragungen auch wirksam werden, es können dort auch andere Skills notiert stehen. 

SCHRITT 4

#### 5️⃣ Skills installieren

Von dieser Seite: [Clawhub](https://clawhub.ai/) installieren Sie beliebige Skill-Ordner auf einmal mit: 
```
npx clawhub@latest install sonoscli
```

Mit `y`bestätigen. 
Es wird hingewiesen, das der Skill `sonocli` möglicherweise als Virus identifiziert wird. 
Diesen bitte als zulässig einstufen. 
Und in der Zwischenzeit nicht anderweitig surfen. 
Also erst Windows 11 Virenscan nach der Installation durchführen lassen und als `Zulässige Bedrohung` zulassen und genehmigen. 
Es wird darauf hingewiesen, das man `Bitte lesen Sie den Skill-Code vor der Verwendung.` von sonoscli ansieht, da dieser : `Kryptoschlüssel, externe APIs, eval, usw.` beinhaltet. 

+ Weitere Informationen zu Skills: [Openclaw Skills](https://docs.openclaw.ai/tools/skills)  
+ Offizielle Skills auf GitHub: [Clawhub](https://github.com/openclaw/clawhub)  
+ Weitere auf GitHub: [Skills](https://github.com/openclaw/skills)  
[Google Suche](https://www.google.com/search?q=openclaw+Skills+GitHub&sca_esv=d7358c9ad4b11281&sxsrf=ANbL-n7bWw8yLdceBkxPqsASYJjne14zSQ%3A1771083612391&ei=XJeQabC9F56A9u8Px-2CkAw&biw=887&bih=719&ved=0ahUKEwiw29XMqNmSAxUegP0HHce2AMIQ4dUDCBM&uact=5&oq=openclaw+Skills+GitHub&gs_lp=Egxnd3Mtd2l6LXNlcnAiFm9wZW5jbGF3IFNraWxscyBHaXRIdWIyChAhGKABGMMEGApIwUJQmjhYzT1wAngBkAEAmAHFAaABlQKqAQMxLjG4AQPIAQD4AQGYAgSgAu8CwgIKEAAYsAMY1gQYR5gDAIgGAZAGCJIHBTMuMC4xoAepBbIHBTEuMC4xuAezAsIHBzItMi4xLjHIBz-ACAA&sclient=gws-wiz-serp)

**Anmerkung**: Die ungeübte Verwendung von Skills kann das System schädigen. 
Je nach Skills kann der Assistent OpenClaw beispielsweise Emails löschen, Kalendereinträge ändern, Daten auf der Festplatte löschen und vieles mehr. 
Es ist anzuraten, erste geh'Versuche auf sicheren Systemen zu versuchen. 
Vorallem ist nicht sichergestellt, das die bereitgestellten Skills nicht wirklich vertrauenswürdig sind. 
Da grade diese `Kryptoschlüssel, externe APIs, eval, usw.` auslesen und an Datendiebe weiter leiten können. 

Dies Bedeutet: 
**Disclaimer**: Benutzung auf eigene Gefahr! 


#### 5️⃣ Skills aktivieren (optional)
DIES FUNKTIONIERT noch NICHT!
Wenn du z. B. Kalender oder GitHub Skills nutzen willst:
```
npx openclaw skill install calendar
npx openclaw skills install github
```
funktioniert nicht in der Version **OpenClaw 2026.2.15 (3fe22ea)**, weil **Skills nicht per CLI installiert werden**.

Für GitHub: logge dich mit deinem GitHub-Token ein, wenn danach gefragt wird.

Skills werden im Config-Ordner abgelegt, sauber von OpenClaw verwaltet.
DIES FUNKTIONIERT noch NICHT!

**Wahrscheinlich, weil man diese Skills noch gegenwärtig manuell downloaden muss.**
**Und im richtigen Verzeichnis zu platzieren hat.**

##### So findest du die Skills und installierst diese zur Zeit
```
npx openclaw skills list

🦞 OpenClaw 2026.2.15 (3fe22ea) — I read logs so you can keep pretending you don't have to.

Skills (6/49 ready)
┌───────────┬──────────────────┬─────────────────────────────────────────────────────────────────┬────────────────────┐
│ Status    │ Skill            │ Description                                                     │ Source             │
├───────────┼──────────────────┼─────────────────────────────────────────────────────────────────┼────────────────────┤
│ ✗ missing │ 🔐 1password      │ Set up and use 1Password CLI (op). Use when installing the      │ openclaw-bundled   │
│           │                  │ CLI, enabling desktop app integration, signing in (single or    │                    │
│           │                  │ multi-account), or reading/injecting/running secrets via op.    │                    │
│ ✗ missing │ 📝 apple-notes    │ Manage Apple Notes via the `memo` CLI on macOS (create, view,   │ openclaw-bundled   │
│           │                  │ edit, delete, search, move, and export notes). Use when a user  │                    │
│           │                  │ asks OpenClaw to add a note, list notes, search notes, or       │                    │
│           │                  │ manage note folders.                                            │                    │
│ ✗ missing │ ⏰ apple-         │ Manage Apple Reminders via the `remindctl` CLI on macOS (list,  │ openclaw-bundled   │
│           │ reminders        │ add, edit, complete, delete). Supports lists, date filters,     │                    │
│           │                  │ and JSON/plain output.                                          │                    │
│ ✗ missing │ 🐻 bear-notes     │ Create, search, and manage Bear notes via grizzly CLI.          │ openclaw-bundled   │
│ ✗ missing │ 📰 blogwatcher    │ Monitor blogs and RSS/Atom feeds for updates using the          │ openclaw-bundled   │
│           │                  │ blogwatcher CLI.                                                │                    │
│ ✗ missing │ 🫐 blucli         │ BluOS CLI (blu) for discovery, playback, grouping, and volume.  │ openclaw-bundled   │
│ ✗ missing │ 🫧 bluebubbles    │ Use when you need to send or manage iMessages via BlueBubbles   │ openclaw-bundled   │
│           │                  │ (recommended iMessage integration). Calls go through the        │                    │
│           │                  │ generic message tool with channel="bluebubbles".                │                    │
│ ✗ missing │ 📸 camsnap        │ Capture frames or clips from RTSP/ONVIF cameras.                │ openclaw-bundled   │
│ ✗ missing │ 📦 clawhub        │ Use the ClawHub CLI to search, install, update, and publish     │ openclaw-bundled   │
│           │                  │ agent skills from clawhub.com. Use when you need to fetch new   │                    │
│           │                  │ skills on the fly, sync installed skills to latest or a         │                    │
│           │                  │ specific version, or publish new/updated skill folders with     │                    │
│           │                  │ the npm-installed clawhub CLI.                                  │                    │
│ ✓ ready   │ 🧩 coding-agent   │ Run Codex CLI, Claude Code, OpenCode, or Pi Coding Agent via    │ openclaw-bundled   │
│           │                  │ background process for programmatic control.                    │                    │
│ ✗ missing │ 🎮 discord        │ Discord ops via the message tool (channel=discord).             │ openclaw-bundled   │
│ ✗ missing │ 🎛️ eightctl      │ Control Eight Sleep pods (status, temperature, alarms,          │ openclaw-bundled   │
│           │                  │ schedules).                                                     │                    │
│ ✗ missing │ ♊️ gemini        │ Gemini CLI for one-shot Q&A, summaries, and generation.         │ openclaw-bundled   │
│ ✗ missing │ 🧲 gifgrep        │ Search GIF providers with CLI/TUI, download results, and        │ openclaw-bundled   │
│           │                  │ extract stills/sheets.                                          │                    │
│ ✗ missing │ 🐙 github         │ Interact with GitHub using the `gh` CLI. Use `gh issue`, `gh    │ openclaw-bundled   │
│           │                  │ pr`, `gh run`, and `gh api` for issues, PRs, CI runs, and       │                    │
│           │                  │ advanced queries.                                               │                    │
│ ✗ missing │ 🎮 gog            │ Google Workspace CLI for Gmail, Calendar, Drive, Contacts,      │ openclaw-bundled   │
│           │                  │ Sheets, and Docs.                                               │                    │
│ ✗ missing │ 📍 goplaces       │ Query Google Places API (New) via the goplaces CLI for text     │ openclaw-bundled   │
│           │                  │ search, place details, resolve, and reviews. Use for human-     │                    │
│           │                  │ friendly place lookup or JSON output for scripts.               │                    │
│ ✓ ready   │ 📦 healthcheck    │ Host security hardening and risk-tolerance configuration for    │ openclaw-bundled   │
│           │                  │ OpenClaw deployments. Use when a user asks for security         │                    │
│           │                  │ audits, firewall/SSH/update hardening, risk posture, exposure   │                    │
│           │                  │ review, OpenClaw cron scheduling for periodic checks, or        │                    │
│           │                  │ version status checks on a machine running OpenClaw (laptop,    │                    │
│           │                  │ workstation, Pi, VPS).                                          │                    │
│ ✗ missing │ 📧 himalaya       │ CLI to manage emails via IMAP/SMTP. Use `himalaya` to list,     │ openclaw-bundled   │
│           │                  │ read, write, reply, forward, search, and organize emails from   │                    │
│           │                  │ the terminal. Supports multiple accounts and message            │                    │
│           │                  │ composition with MML (MIME Meta Language).                      │                    │
│ ✗ missing │ 📨 imsg           │ iMessage/SMS CLI for listing chats, history, watch, and         │ openclaw-bundled   │
│           │                  │ sending.                                                        │                    │
│ ✗ missing │ 📦 mcporter       │ Use the mcporter CLI to list, configure, auth, and call MCP     │ openclaw-bundled   │
│           │                  │ servers/tools directly (HTTP or stdio), including ad-hoc        │                    │
│           │                  │ servers, config edits, and CLI/type generation.                 │                    │
│ ✗ missing │ 📊 model-usage    │ Use CodexBar CLI local cost usage to summarize per-model usage  │ openclaw-bundled   │
│           │                  │ for Codex or Claude, including the current (most recent) model  │                    │
│           │                  │ or a full model breakdown. Trigger when asked for model-level   │                    │
│           │                  │ usage/cost data from codexbar, or when you need a scriptable    │                    │
│           │                  │ per-model summary from codexbar cost JSON.                      │                    │
│ ✗ missing │ 🍌 nano-banana-   │ Generate or edit images via Gemini 3 Pro Image (Nano Banana     │ openclaw-bundled   │
│           │ pro              │ Pro).                                                           │                    │
│ ✗ missing │ 📄 nano-pdf       │ Edit PDFs with natural-language instructions using the nano-    │ openclaw-bundled   │
│           │                  │ pdf CLI.                                                        │                    │
│ ✗ missing │ 📝 notion         │ Notion API for creating and managing pages, databases, and      │ openclaw-bundled   │
│           │                  │ blocks.                                                         │                    │
│ ✗ missing │ 💎 obsidian       │ Work with Obsidian vaults (plain Markdown notes) and automate   │ openclaw-bundled   │
│           │                  │ via obsidian-cli.                                               │                    │
│ ✗ missing │ 🖼️ openai-image- │ Batch-generate images via OpenAI Images API. Random prompt      │ openclaw-bundled   │
│           │ gen              │ sampler + `index.html` gallery.                                 │                    │
│ ✗ missing │ 🎙️ openai-       │ Local speech-to-text with the Whisper CLI (no API key).         │ openclaw-bundled   │
│           │ whisper          │                                                                 │                    │
│ ✗ missing │ ☁️ openai-       │ Transcribe audio via OpenAI Audio Transcriptions API (Whisper). │ openclaw-bundled   │
│           │ whisper-api      │                                                                 │                    │
│ ✗ missing │ 💡 openhue        │ Control Philips Hue lights/scenes via the OpenHue CLI.          │ openclaw-bundled   │
│ ✗ missing │ 🧿 oracle         │ Best practices for using the oracle CLI (prompt + file          │ openclaw-bundled   │
│           │                  │ bundling, engines, sessions, and file attachment patterns).     │                    │
│ ✗ missing │ 🛵 ordercli       │ Foodora-only CLI for checking past orders and active order      │ openclaw-bundled   │
│           │                  │ status (Deliveroo WIP).                                         │                    │
│ ✗ missing │ 👀 peekaboo       │ Capture and automate macOS UI with the Peekaboo CLI.            │ openclaw-bundled   │
│ ✗ missing │ 🗣️ sag           │ ElevenLabs text-to-speech with mac-style say UX.                │ openclaw-bundled   │
│ ✗ missing │ 📜 session-logs   │ Search and analyze your own session logs (older/parent          │ openclaw-bundled   │
│           │                  │ conversations) using jq.                                        │                    │
│ ✗ missing │ 🗣️ sherpa-onnx-  │ Local text-to-speech via sherpa-onnx (offline, no cloud)        │ openclaw-bundled   │
│           │ tts              │                                                                 │                    │
│ ✓ ready   │ 📦 skill-creator  │ Create or update AgentSkills. Use when designing, structuring,  │ openclaw-bundled   │
│           │                  │ or packaging skills with scripts, references, and assets.       │                    │
│ ✗ missing │ 💬 slack          │ Use when you need to control Slack from OpenClaw via the slack  │ openclaw-bundled   │
│           │                  │ tool, including reacting to messages or pinning/unpinning       │                    │
│           │                  │ items in Slack channels or DMs.                                 │                    │
│ ✗ missing │ 🌊 songsee        │ Generate spectrograms and feature-panel visualizations from     │ openclaw-bundled   │
│           │                  │ audio with the songsee CLI.                                     │                    │
│ ✓ ready   │ 📦 sonoscli       │ Control Sonos speakers (discover/status/play/volume/group).     │ openclaw-workspace │
│ ✗ missing │ 🎵 spotify-player │ Terminal Spotify playback/search via spogo (preferred) or       │ openclaw-bundled   │
│           │                  │ spotify_player.                                                 │                    │
│ ✗ missing │ 🧾 summarize      │ Summarize or extract text/transcripts from URLs, podcasts, and  │ openclaw-bundled   │
│           │                  │ local files (great fallback for “transcribe this YouTube/       │                    │
│           │                  │ video”).                                                        │                    │
│ ✗ missing │ ✅ things-mac     │ Manage Things 3 via the `things` CLI on macOS (add/update       │ openclaw-bundled   │
│           │                  │ projects+todos via URL scheme; read/search/list from the local  │                    │
│           │                  │ Things database). Use when a user asks OpenClaw to add a task   │                    │
│           │                  │ to Things, list inbox/today/upcoming, search tasks, or inspect  │                    │
│           │                  │ projects/areas/tags.                                            │                    │
│ ✓ ready   │ 🧵 tmux           │ Remote-control tmux sessions for interactive CLIs by sending    │ openclaw-bundled   │
│           │                  │ keystrokes and scraping pane output.                            │                    │
│ ✗ missing │ 📋 trello         │ Manage Trello boards, lists, and cards via the Trello REST API. │ openclaw-bundled   │
│ ✗ missing │ 🎞️ video-frames  │ Extract frames or short clips from videos using ffmpeg.         │ openclaw-bundled   │
│ ✗ missing │ 📞 voice-call     │ Start voice calls via the OpenClaw voice-call plugin.           │ openclaw-bundled   │
│ ✗ missing │ 📱 wacli          │ Send WhatsApp messages to other people or search/sync WhatsApp  │ openclaw-bundled   │
│           │                  │ history via the wacli CLI (not for normal user chats).          │                    │
│ ✓ ready   │ 🌤️ weather       │ Get current weather and forecasts (no API key required).        │ openclaw-bundled   │
└───────────┴──────────────────┴─────────────────────────────────────────────────────────────────┴────────────────────┘

Tip: use `npx clawhub` to search, install, and sync skills.
```

So installierst du Skills richtig

1️⃣ Nach einem Calendar-Skill suchen

```
npx clawhub search calendar
``` 

#### Meine Empfehlung

Wenn du Google Workspace / Gmail nutzt →
gog-calendar installieren, weil es sauber ins OpenClaw-Ökosystem passt.

Installieren mit:
```
npx clawhub install gog-calendar
```

Danach:
```
npx openclaw skills check
```

Wenn du ein schlankes CLI willst und nichts mit **Workspace** brauchst →
```
npx clawhub install gcalcli-calendar
```

💡 Kleiner Reality-Check:
Beide Varianten werden danach OAuth-Login von Google verlangen (Browser-Auth, Token speichern etc.).


##### 👉 Nimm: gcalcli-calendar

Der ist für private Google-Konten in der Regel unkomplizierter als die Workspace-Variante.

###### 1️⃣ Installieren
```
npx clawhub install gcalcli-calendar
```

###### 2️⃣ Danach prüfen
```
npx openclaw skills check
```

Sehr wahrscheinlich bekommst du dann Hinweise wie:

+ gcalcli nicht installiert
+ Google OAuth nicht eingerichtet

Falls gcalcli fehlt

Auf Ubuntu: Bitte nicht diese Version versuchen, systemd verursacht später Fehler. 
```
sudo apt install gcalcli
```

Falls es nicht im Repo ist: Bitte nur diese Version verwenden. 
```
pip install gcalcli
```

##### Beim ersten Login

Beim ersten Zugriff öffnet sich normalerweise:

+ ein Browserfenster zur Google-Anmeldung
+ danach wird ein Token lokal gespeichert

Das ist normal 👍

Wenn du willst, gehen wir es jetzt Schritt für Schritt durch.
Installier erstmal `gcalcli-calendar` und zeig mir dann die Ausgabe von:

```
npx openclaw skills check
```


#### Du bist nicht eingeloggt, deshalb greift das sehr niedrige anonyme Rate-Limit.

👉 Jetzt einfach einloggen:
```
npx clawhub login
```

Das öffnet normalerweise:

entweder einen Browser zur Authentifizierung

oder zeigt dir einen Login-Link / Code an

Einmal bestätigen — fertig.


#### Danach nochmal:
```
npx clawhub install gcalcli-calendar
```

Dann sollte das Rate-Limit-Problem verschwinden.

Wenn beim Login irgendwas Komisches passiert (z. B. kein Browser öffnet sich), sag mir Bescheid — dann machen wir es manuell.

Ich habe manuell vorgezogen und mich ersteinaml auf ClawHub vernüftig in Ubuntu angemeldet. 
```
npx clawhub login 
```

lieferte dieses Ergebnis: 
```
Opening browser: https://clawhub.ai/cli/auth?redirect_uri=http%3A%2F%2F127.0.0.1%3A36663%2Fcallback&label_b64=Q0xJIHRva2Vu&state=f899e3973b02f6234a69f85503fb node:events:497 throw er; // Unhandled 'error' event ^ Error: spawn xdg-open ENOENT at ChildProcess._handle.onexit (node:internal/child_process:285:19) at onErrorNT (node:internal/child_process:483:16) at process.processTicksAndRejections (node:internal/process/task_queues:90:21) Emitted 'error' event on ChildProcess instance at: at ChildProcess._handle.onexit (node:internal/child_process:291:12) at onErrorNT (node:internal/child_process:483:16) at process.processTicksAndRejections (node:internal/process/task_queues:90:21) { errno: -2, code: 'ENOENT', syscall: 'spawn xdg-open', path: 'xdg-open', spawnargs: [ 'https://clawhub.ai/cli/auth?redirect_uri=http%3A%2F%2F127.0.0.1%3A36663%2Fcallback&label_b64=Q0xJIHRva2Vu&state=f899e3973b02f6234a69f85503fb' ] } Node.js v22.22.0
```

kein ClawHub-Problem — das ist ein Linux-Minimal-Setup-Problem 😄

Fehlermeldung:
```
Error: spawn xdg-open ENOENT
``` 

Heißt ganz simpel:
`xdg-open` ist **nicht installiert**, also kann kein Browser automatisch geöffnet werden.

Du arbeitest offenbar in einer eher schlanken Ubuntu-Umgebung (WSL oder Server?), richtig?

##### ✅ Schnellste Lösung (manuell öffnen)

Kopiere einfach diesen Link aus deiner Ausgabe:
``` 
https://clawhub.ai/cli/auth?redirect_uri=...
``` 

Und öffne ihn **manuell im Browser** (auf deinem normalen Desktop-System).

Login durchführen → danach sollte das CLI automatisch den Callback bekommen.

Falls der Callback nicht funktioniert (bei WSL manchmal so), sag Bescheid — dann machen wir Token manuell.

##### ✅ Saubere Lösung: xdg-open installieren

Falls du möchtest, dass so etwas künftig automatisch funktioniert:
``` 
sudo apt update
sudo apt install xdg-utils
``` 

Danach sollte `npx clawhub login` den Browser in Ubuntu korrekt öffnen.

##### 🔎 Kleine Frage

Läuft das:

+ in WSL?
+ direkt auf Ubuntu Desktop?
+ oder auf einem Headless-Server?

Das entscheidet, ob wir es „Desktop-komfortabel“ oder „Server-clean“ konfigurieren sollten.


#### Warum du die Webseite nicht im Windows Browser erreichen kannst.  

Das **Callback läuft lokal** auf `127.0.0.1`. Das heißt:

ClawHub startet einen **lokalen Webserver**, um das Token automatisch abzuholen.

Bei WSL oder headless Linux (MiniPC ohne echten Desktop/Browser) funktioniert das nicht, weil der Browser auf deinem Linux selbst versucht zu öffnen.

Deswegen siehst du nur eine URL wie:
```
http://127.0.0.1:36663/callback#token=…
```

Du kannst diese URL nicht einfach in einem normalen Browser öffnen, weil 127.0.0.1 auf deinem Linux, nicht auf deinem Windows-Browser zeigt.

✅ Lösung: Token manuell setzen

1. Kopiere alles nach **#token=** bis zum Ende, bis vor **&registry**.
In deinem Fall:

```
clk_PsA0t378gTOD95gyAB-zMHZ3lRibxTX7hdvpasN-vkE
```

2. Dann manuell beim CLI einloggen:

```
npx clawhub login --token clk_PsA0t378gTOD95gyAB-zMHZ3lRibxTX7hdvpasN-vkE
```

Damit bist du eingeloggt **ohne Browser**. 
Und liefert 

```
✔ OK. Logged in as @BeinName
```

##### Danach: Skill installieren

1. Skill installieren
Bitte bedenke die richtige Version zu installieren. Siehe bei [Python gcalcli](Python_gcalcli)
```
npx clawhub install gcalcli-calendar
```

sollte sofort klappen, ohne Rate-Limit oder Browserprobleme. 
Wenn alles glatt geht, bekommst du eine Bestätigung, dass der Skill installiert ist.
Diese sieht in etwa aus wie:

```
✔ OK. Installed gcalcli-calendar -> /home/ubuntu/.openclaw/workspace/skills/gcalcli-calendar
```

2. Prüfen, ob alles bereit ist
```
npx openclaw skills check
```

Das zeigt dir z. B. ob:

+ gcalcli installiert ist
+ Google OAuth eingerichtet ist
+ sonstige Abhängigkeiten fehlen

Wenn alles mit ✓ markiert ist → Skill ist einsatzbereit. 

Bei mir wurde dieser als letzter aufgelistet, es sind einige standartmäßig schon aeingerichtet. 
Diese Liste intressant ist. 

3. `gcalcli` installieren (falls noch nicht installiert)

Ubuntu/WSL: Diese Version bitte nicht, verursacht schwere Fehler mit der `systemd. 
```
sudo apt install gcalcli
```

<A name="Python_gcalcli">
##### Python Gcalcli
Oder über Python: Dies ist die kompatible bessere Version.

```
pip install gcalcli
```




#### Google OAuth einrichten

Beim ersten Zugriff auf den Calendar-Skill öffnet sich ein Browser-Login (oder du bekommst einen URL-Code, wenn du Headless arbeitest).

+ Browser-Login → bei deinem Privat-Google-Account anmelden
+ Berechtigungen für den Zugriff auf deinen Kalender erlauben
+ Token wird gespeichert → danach kannst du Termine lesen/schreiben über OpenClaw

##### 5️⃣ Skill testen

Beispiel:
```
npx openclaw skills info gcalcli-calendar
```

Oder direkt eine kleine Abfrage: Diese funktionert nur nicht, query ist zur Zeit unbekannt. 
```
npx openclaw query "Zeige mir meine nächsten Termine im Kalender"
```

Wenn alles klappt, hast du jetzt einen voll funktionsfähigen Google Calendar Skill. 
Allerdings ist diese Abfrage altmodisch und out of date, daher lieber die nachfolgenden neueren versuchen. ✅


#### 1️⃣ Prüfe, welche Skills einsatzbereit sind
```
npx openclaw skills check
```

Hier siehst du, ob gcalcli-calendar bereit ist (✓ ready) oder noch Setup braucht (OAuth, CLI).


##### 2️⃣ Infos zum Skill anzeigen
```
npx openclaw skills info gcalcli-calendar
```

Dort stehen z. B. Befehle, die du für Termine nutzen kannst.

##### 3️⃣ Termine abrufen / hinzufügen

Mit gcalcli direkt (wenn CLI installiert):
```
gcalcli agenda
```

oder für die nächsten 7 Tage:
```
gcalcli agenda --days 7
```

Falls du den Skill in OpenClaw nutzen willst, geht das über Agent-Skripte, z. B.:
```
npx openclaw run gcalcli-calendar --command "show next 5 events"
```
npx openclaw run gcalcli-calendar today-only
(Exakte Syntax hängt vom Skill ab; `skill info gcalcli-calendar` zeigt sie.)


##### 💡 Kurz gesagt:

`query` → veraltet / existiert nicht

`skills info` + `run <skill>` → neuer Weg


#### ✅ So machst du die Kofiguartionsdatei sauber

Öffne die Config:
```
nano ~/.openclaw/config.json
```

Passe sie an, z. B. so:
```
{
  "LLM_PROVIDER": "ollama",
  "LLM_BASE_URL": "http://localhost:11434/v1",
  "LLM_MODEL": "llama3",
  "ENABLE_SKILLS": true,
  "SKILL_AUTOLOAD": true
}
```

Speichern und schließen:

CTRL+O → Enter → CTRL+X

Prüfen:
```
cat ~/.openclaw/config.json
```

Jetzt sollten die beiden Zeilen endlich sichtbar sein.


SCHRITT 6



SCHRITTE die noch FEHLEN

openclaw doctor         # check for config issues
openclaw status         # gateway status
openclaw dashboard      # open the browser UI

1. Die Bindung von OpenClaw von dev zu openclaw muss noch erstellt werden. 

#### 3. 🛠️ Optional (sehr empfohlen)
```
openclaw doctor
```

Das fixt:

+ Ports
+ fehlende Tools
+ WSL-Eigenheiten

#### 4. Nächster Schritt: Windows-Desktop-Verknüpfung  

##### Ziel

Klick auf Desktop →
PowerShell öffnet sich →
WSL startet →
`openclaw` läuft.

Kommando (fertig):
```
wsl -d Ubuntu -e bash -lc "openclaw --profile dev gateway"
```

##### Desktop-Verknüpfung erstellen

2. Rechtsklick Desktop → Neu → Verknüpfung

2. Ziel:
```
C:\Windows\System32\wsl.exe -d Ubuntu -e bash -lc "openclaw --profile dev gateway"
```

3. Starten in (optional):
```
C:\Users\danie
```

4. Name z.B.:
```
OpenClaw Gateway
```


3. Online mein OpenClaw beinhaltet die gesuchten Screenshots auf Github und ist etwas anders. 


4. Die Android App mit Android Studio bauen. Quellcode ist hier innenliegend. 

5. Eine Brücke zu HomeAssistent und Amazon Alexa bauen.

Bitte fortfahren

#### OpenManus_General_AI_Agents 
[OpenManus_General_AI_Agents ](https://github.com/dwhr-pi/OpenManus_General_AI_Agents)


#### chatgpt-to-markdown
[chatgpt-to-markdown](https://github.com/dwhr-pi/chatgpt-to-markdown)

#### ai-chat-to-markdown
[ai-chat-to-markdown](https://github.com/dwhr-pi/ai-chat-to-markdown)

#### GenAI_Agents
[GenAI_Agents](https://github.com/dwhr-pi/GenAI_Agents)

#### awesome-ai-music-generation
[awesome-ai-music-generation](https://github.com/dwhr-pi/awesome-ai-music-generation)

#### AI-on-the-edge-device 
[AI-on-the-edge-device](https://github.com/dwhr-pi/AI-on-the-edge-device)

#### openai-agents-js
[openai-agents-js](https://github.com/dwhr-pi/openai-agents-js)

#### openclaw
[openclaw](https://github.com/dwhr-pi/openclaw)

#### clawhub
[clawhub](https://github.com/dwhr-pi/clawhub) 

#### OpenClaw HomeAssistant
[OpenClawHomeAssistant](https://github.com/dwhr-pi/OpenClawHomeAssistant)
oder direkt mit Alexa verbinden. 

Bitte fortfahren


[Google Suche: openclaw auf windows installieren](https://www.google.com/search?q=openclaw+auf+windows+installieren&oq=openclaw+auf+windows&gs_lcrp=EgZjaHJvbWUqBwgCECEYoAEyBggAEEUYOTIHCAEQIRigATIHCAIQIRigATIHCAMQIRigAdIBCTE5ODQzajBqN6gCCLACAfEFdSD3kA_gYh4&sourceid=chrome&ie=UTF-8)  
[YouTube: Installing OpenClaw on Windows 10/11 – Step-by-Step Guide](https://www.youtube.com/watch?v=nDdPMVNzv4s)  
[Heise: OpenClaw im Selbstversuch: Erste Schritte mit dem Super-KI-Agenten](https://www.heise.de/ratgeber/OpenClaw-im-Selbstversuch-Erste-Schritte-mit-dem-Super-KI-Agenten-11167211.html)  
[TikTok: Rin OpenClaw on a MicroPC: A Step by Step guide](https://www.tiktok.com/@adamstewartmarketing/video/7604098695574981909)  


[OpenClaw Install](https://docs.openclaw.ai/install)









### OpenClaw-Konfiguration 

Die OpenClaw Konfiguration vollständig noch mal durch gehen. 
Da Fehler eventuell im Webinterface aufgefallen sind.  

Wenn im Webinterface schon Dinge komisch wirken, macht ein kompletter „Reset & sauber neu konfigurieren“-Durchlauf absolut Sinn.

#### 🔍 1. Prüfen, was aktuell wirklich läuft

Erst mal sicherstellen, dass nichts Altes im Hintergrund hängt:
```
ps aux | grep openclaw
```

Falls da noch ein Gateway läuft → beenden:
```
pkill -f openclaw
```
#### 🧹 2. Alte Konfiguration komplett sichern und entfernen

Wir machen ein sauberes Reset, aber mit Backup (man weiß ja nie 😉):
```
mv ~/.openclaw ~/.openclaw_backup_$(date +%F_%H-%M)
```
Jetzt existiert **keine** Konfiguration mehr.

#### 🚀 3. Gateway komplett neu initialisieren

Jetzt ohne Altlasten starten:
```
npx openclaw gateway
```

##### ⚠️ Wichtig: diesmal nicht **--allow-unconfigured** verwenden.  

Beim ersten Start sollte OpenClaw:

+ neue Config anlegen
+ neues Auth-Token erzeugen
+ saubere Struktur aufbauen

Mit dem Befehl start das Setup von OpenClaw. 
```
npx openclaw setup
```


Beobachte die Logs genau – es darf kein Fehler beim Schreiben der Config kommen.

#### 🔑 4. Token direkt prüfen (sauberer Weg)

Jetzt sollte funktionieren:
```
cat ~/.openclaw/openclaw.json
```

Oder besser:
```
jq . ~/.openclaw/openclaw.json

Kontrolliere:

"gateway": {
  "auth": {
    "token": "..."
  }
}
```

Wenn hier **kein Token** steht, dann ist genau das dein Kernproblem.

#### 1️⃣ Gateway Mode setzen

Füge in deine `~/.openclaw/openclaw.json` folgendes hinzu:
```
{
  "gateway": {
    "mode": "local"
  }
}
```

Da deine Datei aktuell so aussieht:
```
{
  "agents": {...},
  "commands": {...},
  "meta": {...}
}
```

muss sie danach so aussehen: 
```
{
  "agents": {
    "defaults": {
      "workspace": "/home/ubuntu/.openclaw/workspace"
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true
  },
  "gateway": {
    "mode": "local"
  },
  "meta": {
    "lastTouchedVersion": "2026.2.19-2",
    "lastTouchedAt": "2026-02-19T22:28:28.243Z"
  }
}
```

Bei `meta` wird es andere Eintragungen als in diesem Beispiel geben. 
Bitte pass das auf Deine Angaben entsprechend hin an. 







Editiere dies mit: 
```
nano ~/.openclaw/openclaw.json
```

Prüfe ob es richtig gepsiechert wurde mit: 
```
cat ~/.openclaw/openclaw.json
```


#### 2️⃣ Gateway neu starten
```
npx openclaw gateway
```

Jetzt sollte:

+ Gateway starten
+ automatisch `gateway.auth.token` erzeugen
+ Token in der Config speichern

#### 3️⃣ Prüfen

Danach:
```
cat ~/.openclaw/openclaw.json
```

Du solltest jetzt zusätzlich sehen:
```
"gateway": {
  "mode": "local",
  "auth": {
    "token": "irgendein-langer-string"
  }
}
```


#### 🌐 5. Webinterface sauber verbinden

Im Browser:
```
http://127.0.0.1:18789
```

Dann:

Einstellungen → Gateway/Auth → Token der bei `irgendein-langer-string` steht bei **Gateway Token** einfügen. 
Bitte nicht mit **Password (not stored)** oder **Default Session Key** verwechseln. 
Der Browser möchte gerne hier dies als Benutzer speichern, daher ist Vorsicht mit dem Speichern im Browser geboten, weil dies Fehler verursachen kann. In dem dieser den Token als Benutzer einfach überschreibt. 

Danach Browser einmal hart neu laden (Strg+F5).


#### 🧪 6. Wenn weiterhin Fehler auftreten

Bitte mir dann zeigen:

1. Den kompletten neuen Start-Log
2. Den Inhalt von ~/.openclaw/openclaw.json (Token darfst du anonymisieren)
3. Welche Fehlermeldung exakt im Webinterface steht

#### 💡 Typische Ursachen für Webinterface-Fehler

Nur damit du weißt, worauf wir achten:

+ alter Token im Browser gespeichert (LocalStorage)
+ Port 18789 doppelt belegt
+ falsches Protokoll (http vs https)
+ Browser-Cache
+ Config-Datei schreibgeschützt
+ Node-Version inkompatibel


### Der Openclaw-Workspace
```
ls ~/.openclaw/workspace
```

Listet die vorhanden Konfigurations-Dateien auf. 
```
AGENTS.md  BOOTSTRAP.md  HEARTBEAT.md  IDENTITY.md  SOUL.md  TOOLS.md  USER.md
```

Sieht es genauso aus, ist alles gut. 

### 🩺 Was macht openclaw doctor?

Im Prinzip:

+ prüft deine Config
+ prüft Gateway-Status
+ prüft Model-Zugriff
+ prüft Ports
+ prüft Abhängigkeiten (Node, Browser-Service usw.)
+ zeigt dir Inkonsistenzen

Also ein kompletter Gesundheits-Check.

#### 🚀 So startest du ihn

Probier einfach:
```
npx openclaw doctor
```

Falls `npx` bei dir alles startet (was es bisher tut), sollte das funktionieren.

##### 🧠 Was du erwarten kannst

Typische Checks:

+ ✔ Config valid
+ ✔ Gateway reachable
+ ✔ Token configured
+ ✔ Model reachable
+ ✔ Workspace writable
+ ✔ Browser service available

Oder eben rote Warnungen wie:

+ ⚠ gateway.mode not set
+ ⚠ auth token missing
+ ⚠ model not reachable
+ ⚠ port conflict

##### 📌 Wichtig

Falls du:

+ Gateway laufen hast → Doctor prüft Live-Zustand
+ Gateway nicht laufen hast → Doctor prüft nur Konfiguration

Beides ist okay, aber mit laufendem Gateway bekommst du mehr Infos.

💡 Kleiner Bonus-Tipp

Wenn du volle Details willst:
```
npx openclaw doctor --verbose
```
Das gibt dir tiefere Infos (hilfreich, wenn man wirklich debuggen will). 





### 🔑 1️⃣ Gemini API-Key bekommen

Der Key kommt von Google AI Studio:

#### 👉 Geh zu:
```
https://aistudio.google.com/app/apikey
```

XXXXXXEntfernen
AIzaSyCBKBBHQZUSjyfKWLt6vRsTQ82y9dWbWsw

Dort:

1. Mit deinem Google-Account anmelden
2. „Create API key“ klicken
3. Key kopieren

Das ist dein GEMINI_API_KEY.


#### 🧠 2️⃣ API-Key in WSL setzen

In deiner Ubuntu-WSL:

Temporär (nur für aktuelle Session):
```
export GEMINI_API_KEY="dein_key_hier"
```

Dauerhaft (empfohlen):
```
echo 'export GEMINI_API_KEY="dein_key_hier"' >> ~/.bashrc
source ~/.bashrc
```

Danach prüfen:
```
echo $GEMINI_API_KEY
```



Wenn der Key ausgegeben wird → passt.

#### ⚙️ 3️⃣ Gemini in OpenClaw konfigurieren

Jetzt sagst du OpenClaw, dass es Gemini nutzen soll.
ALT
##### Variante A (empfohlen, sauber):
```
openclaw auth add --provider gemini
```

Dann:
```
openclaw memory status --deep
```

##### Variante B (direkt per Config setzen)

Falls du Memory Search mit Gemini willst:
```
openclaw config set agents.defaults.memorySearch.provider gemini
```

Falls du ein bestimmtes Modell setzen willst (z. B. embedding-Modell):
```
openclaw config set agents.defaults.memorySearch.model text-embedding-004
```

##### 🧩 4️⃣ Wichtig: Embeddings bei Gemini

Für Semantic Memory brauchst du ein Embedding-Modell.

Google bietet aktuell:
```
text-embedding-004
```

Also falls Memory Search aktiviert bleiben soll:
```
openclaw config set agents.defaults.memorySearch.enabled true
openclaw config set agents.defaults.memorySearch.provider gemini
openclaw config set agents.defaults.memorySearch.model text-embedding-004
```

Dann nochmal:
```
openclaw memory status --deep
```

##### 🐧 WSL-Spezialtipp

Falls du OpenClaw mal als root gestartet hast und jetzt als ubuntu-User:

Prüf mal:
```
whoami
```
Wenn das unterschiedlich war, kann es sein, dass du zwei .openclaw-Ordner hast.


NEU 
#### 3️⃣ OpenClaw sagen, dass Gemini verwendet werden soll

Jetzt:
```
npx openclaw config set agents.defaults.llm.provider gemini
```
#####🔹 2️⃣ Gemini als LLM nutzen

In dieser OpenClaw-Version wird der Provider automatisch erkannt,
wenn GEMINI_API_KEY gesetzt ist.

Du musst keinen llm.provider setzen.

OpenClaw priorisiert:

+ OPENAI_API_KEY
+ GEMINI_API_KEY
+ andere Provider

Wenn nur Gemini gesetzt ist → wird Gemini genutzt.

#####🔹 3️⃣ Memory Search mit Gemini konfigurieren

Das ist der einzige Teil, den du wirklich setzen musst:
```
npx openclaw config set agents.defaults.memorySearch.provider gemini
npx openclaw config set agents.defaults.memorySearch.model embedding-001
npx openclaw config set agents.defaults.memorySearch.enabled false
```

Das ist easy:
```
mkdir -p ~/.openclaw/workspace/memory
```

Dann prüfen:
```
mkdir -p ~/.openclaw/workspace/memory
npx openclaw memory index
npx openclaw memory status --deep
```

Wenn dort Gemini + embedding-001 steht → läuft.

Speichern → neu starten → npx openclaw doctor





