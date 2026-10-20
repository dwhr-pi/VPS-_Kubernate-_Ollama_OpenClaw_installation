# FreeLLMAPI aus GitHub installieren, ohne Docker

## API-Schluessel und Online-Dienste

- [Alle API-Schluessel: Dokumentation und Verwaltung](../_API-Keys/README.md)
- [OnlineOnKeyServices: ein Schluessel fuer mehrere KI-Modelle](../_API-Keys/OnlineOnKeyServices/README.md)
- [Free Tiers und Trial-Credits: gepruefte GitHub-/Anbieterquellen](../_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md)

Diese Uebersichten enthalten keine echten Zugangsdaten. Anbieter-Keys bleiben
vom lokalen FreeLLMAPI Unified Key und der ENV-Tresor-Passphrase getrennt.

Ein registrierter Provider ist kein Beleg fuer ein weiterhin kostenloses
Kontingent. Die verlinkte Auswertung nennt Bedingungen, Ablauf und Quellen;
insbesondere Cerebras nicht als dauerhaftes Free Tier und Together nicht als
allgemeines kostenloses Signup-Trial einplanen. Keine automatische
Provider-/Key-/Fallback-Aenderung durch diese Dokumentation.

## Externe Aggregatoren als Upstream

Die Uebersicht [OnlineOnKeyServices](../_API-Keys/OnlineOnKeyServices/README.md)
buendelt externe Dienste nach dem Prinzip "ein API-Schluessel fuer mehrere
KI-Modelle". Dort findest du die Anbieterbeschreibungen und ihre jeweilige
FreeLLMAPI-Anbindung: eingebauter Provider oder bedingt nutzbarer Custom-
Endpunkt, einschliesslich Konfiguration, Kosten und Datenschutzgrenzen.
Host und Kompatibilitaet vor Nutzung pruefen. Die Anbieterkeys gehoeren in
den Router, der lokale Unified Key in den Client. Der Verweis aktiviert
keinen Cloud-Fallback und ist kein Nachweis einer getesteten Live-Integration.

## Alte Docker-Meldung trotz Korrektur?

Am 16.10.2026 enthielt GitHub `main` noch den Docker-Helfer mit
`FREELLMAPI_ENABLE_DOCKER=1`; der neue Source-Installer lag nur im Windows-
Arbeitsverzeichnis. Eine lokale Bearbeitung ist **keine Veroeffentlichung**.
Erst nach Commit/Review/Veroeffentlichung und erfolgreichem Setup-Update
kann eine andere Installation die neuen Dateien verwenden.

Der neue Installer meldet zu Beginn:
`FreeLLMAPI-Installer: 2026-10-16-github-source-no-docker`.
Die erweiterte Runtime-Bereitstellung meldet zusaetzlich
`FreeLLMAPI-Runtime: 2026-10-16-private-node-bootstrap`.
Nur die erste Zeile mit anschliessendem `node fehlt` stammt noch vom
Source-Installer ohne automatischen Node-Bootstrap.
Fehlt diese Zeile und erscheint stattdessen die Docker-Sperre, wird noch der
alte Helfer ausgefuehrt. Nicht durch Setzen des Docker-Flags umgehen.
Rein lesende Diagnose im tatsaechlich gestarteten Setup-Verzeichnis:

```bash
pwd
git remote -v
git log -1 --oneline
git status --short
grep -nE 'INSTALLER_REVISION|RUNTIME_REVISION|ENABLE_DOCKER' scripts/tools/helpers/freellmapi_common.sh
bash scripts/tools/freellmapi_install.sh --dry-run
```

Lokale Abweichungen vor einem Update sichern/pruefen, kein `reset --hard` oder
blindes Ueberschreiben. Codex greift fuer diese Diagnose nicht auf deine WSL zu.

Status: **experimental / optional**. Geprueft am 16.10.2026.
Quelle: [tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi),
Tag `v0.14.2`, Commit `57c0669233bbe0c70a0f9f9927613192be948773`.
[Upstream-Produktionsbuild](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/docs/en/install/01-install.md).

## Was wurde korrigiert?

Der Installer verwendet jetzt **GitHub-Quellcode und npm**, keine Images,
keine Container und keinen Compose-Helper. `FREELLMAPI_ENABLE_DOCKER=1`
wird nicht mehr benoetigt oder ausgewertet. Installation bedeutet hier:
Quellcode holen, Abhaengigkeiten/Server/CLI/Dashboard bauen und lokal pruefen.
Sie startet keinen Server und erzeugt keine Schluessel.

GitHub ist die Primaerquelle; npm laedt die im Upstream-Lockfile festgelegten
Bibliotheken. "Aus GitHub" bedeutet nicht, dass saemtliche Abhaengigkeiten
ausschliesslich von GitHub geladen werden.
`npm ci` darf native Lifecycle-Skripte ausfuehren. Nur als normaler Benutzer,
nicht mit sudo/root und nicht mit ungeprueften Fremdquellen bauen.

## Voraussetzungen und Ressourcen

| Bereich | Vorgabe dieses Installers |
|---|---|
| Ziel | Linux/WSL; Bereitstellung nur bei ausdruecklicher Installation/Repair, keine WSL-Aenderung durch Codex |
| Node | kompatibles vorhandenes 22.22+ innerhalb 22.x oder 24.x weiterverwenden; sonst private Node-22-Runtime automatisch bereitstellen |
| npm | >=10, mit Node geliefert; kein separates globales npm-Update |
| Werkzeuge | Git, Python 3, flock; fuer Healthcheck curl |
| RAM | 2 GiB Build-Planungsreserve, vorhandener RAM wird geprueft; kein gemessener Mindestwert |
| SSD | 4 GiB freie Reserve am Source-Datentraeger; WSL zusaetzlich 10 GiB Windows-Hostreserve ueber vorhandenen Check |
| Native Addons | better-sqlite3/sharp; wenn kein passendes Binary vorhanden ist, koennen Compiler/Make/Python benoetigt werden |
| GPU | Router braucht keine; lokale Modelle separat dimensionieren |
| Netzwerk | Clone/npm brauchen Internet, Serverkontakte separat freigeben |
| Adresse | ausschliesslich `127.0.0.1:3011`, kein Container-Port |

Fehlendes/inkompatibles Node/npm wird bei **Installation oder Repair** ueber
den vorhandenen nvm-Helfer bereitgestellt: nvm `v0.40.8` aus GitHub, offizielles
Node-22-Binary samt npm und nvm-Download-/Checksumpruefung. Kein Docker,
`curl|bash`, Node-Source-Build oder Ersetzen des System-Node.
Der zuletzt verfuegbare kompatible 22.x-Stand wird beim Download aufgeloest;
das ist kein Patchversions-Pin. Bereits passende Runtimes werden nicht aktualisiert.

Privates Ziel: `~/.openclaw_ultimate_user_data/tools/freellmapi/runtime/nvm`
(beachtet `OPENCLAW_USER_DATA_DIR`). Dein normales `~/.nvm`, `/usr/bin/node`,
globale npm-Pakete und Shellprofile werden nicht umgebaut. NVM wird nur fuer
den jeweiligen Installer-/Startprozess aktiviert. Doctor/Start aktivieren eine
bereits vorhandene private Runtime, **laden aber nie selbst etwas herunter**.
Deaktivierung des Tools behaelt die private Runtime zur Wiederverwendung.

Der gemeinsame Helfer kann fuer einen frischen nvm-Download unter Ubuntu
`git`, `curl`, `ca-certificates`, `tar` und `xz-utils` per apt einrichten;
dafuer kann sudo abgefragt werden. Das ist keine apt-Node-Installation.
Python, flock, Compiler, Docker und Systemdienste werden nicht automatisch
eingerichtet. Bootstrap-Fehler stoppen vor Clone/npm-Build; Ressourcenpruefung,
Lock und privates Installationsprotokoll gelten auch fuer die Bereitstellung.

Automatische Bereitstellung bewusst deaktivieren:

```bash
FREELLMAPI_AUTO_NODE=0 bash scripts/tools/freellmapi_install.sh
```

Ohne passende vorhandene/private Runtime bricht dieser Aufruf ohne Runtime-
Download ab. Dry-Run und Status laden grundsaetzlich nichts herunter.
Die Source-Installation selbst braucht weiterhin Internet fuer GitHub/npm.
ARM64/x86_64 haengen auch von den nativen Addons ab; kein pauschales
Plattformversprechen ohne echten Buildtest. Der bestehende RAM-Check misst
Gesamt-RAM; freie RAM-/Swap-Last vor grossem Build zusaetzlich kontrollieren.

## 1. Plan und Source-Installation

Im bestehenden Repository auf dem Zielsystem bewusst ausfuehren:

```bash
bash scripts/tools/freellmapi_install.sh --dry-run
bash scripts/tools/freellmapi_install.sh
bash scripts/tools/freellmapi_status.sh
```

Es wird in `~/.openclaw_ultimate_user_data/tools/freellmapi/source`
geklont. `OPENCLAW_USER_DATA_DIR` kann einen anderen privaten, absoluten,
symlinkfreien User-Datenpfad waehlen. Keine Runtime-Daten im Git-Repository.

Der Clone muss exakt zum Tag/Commit und zur offiziellen Origin passen.
Vorhandene lokale Aenderungen werden nicht zurueckgesetzt/ueberschrieben.
Ein Lock verhindert parallele Builds/Starts. Belegter Port blockiert den
Build/Start; keine fremden Prozesse werden beendet.

Installation:
1. Ressourcen, Zielpfade, Lock und Port pruefen; passende Laufzeit aktivieren
   oder fehlendes Node/npm privat bereitstellen und protokollieren.
2. Gepinnten GitHub-Tag klonen und Commit/Origin kontrollieren.
3. `npm ci --include=dev --no-audit --no-fund` mit Upstream-Lockfile.
4. `npm run build` fuer Server/CLI/UI.
5. Server-Syntax, UI-Artefakt und native SQLite-In-Memory-Verbindung pruefen.
6. Erst dann erfolgreichen Build markieren.

Wiederholtes Installieren eines vollstaendigen Builds prueft ihn erneut,
ohne automatisch neu zu installieren. Update/Repair baut bewusst neu.
Logs: `~/.openclaw_ultimate_user_data/install_logs/*_freellmapi_source_*.log`,
privat; Exit-Code, Dauer und freier Speicher vorher/nachher werden notiert.
Bei Fehlern bleibt Source zur Diagnose erhalten, aber kein neuer Erfolgsmarker.
Die private Runtime-ENV wird beim Build nicht geladen.

## 2. Private ENV erst vor dem Serverstart

Vorlage: [config/freellmapi.env.example](../../config/freellmapi.env.example).
Echte Datei:
`~/.openclaw_ultimate_user_data/env/freellmapi/.env`, Besitzer nur du,
Linux-Dateirechte `0600`. `ENCRYPTION_KEY` muss genau 64 Hex-Zeichen enthalten,
kryptografisch zufaellig im Passwortmanager/auf dem eigenen Rechner erzeugt.
Nicht aus Doku kopieren, nicht in Git/Logs speichern.

Der vorhandene [ENV-Tresor](../ENV_VAULT.md) kann das erledigen:

```bash
# Bestehenden Tresor verwenden, NICHT erneut initialisieren:
python3 scripts/security/env_vault.py set freellmapi_encryption_key
python3 scripts/security/env_vault.py bind freellmapi ENCRYPTION_KEY freellmapi_encryption_key
python3 scripts/security/env_vault.py render freellmapi
python3 scripts/security/env_vault.py render freellmapi --apply
```

Die Eingabe ist verdeckt. Ohne bestehenden Tresor dessen Anleitung zuerst lesen.
Der neue Launcher liest nur `ENCRYPTION_KEY`, `FREELLMAPI_CONTEXT_HANDOFF`
und `FREELLMAPI_UPDATE_CHECK`, kein Shell-`source`.
Doppelte/unbekannte Eintraege werden abgelehnt, ohne deren Werte auszugeben.
HOST/PORT/DB/NODE_OPTIONS nicht in diese Datei schreiben.
Provider-Keys spaeter bewusst im Router verwalten, nicht alle Tresorwerte importieren.

## 3. Server bewusst nativ starten

```bash
bash scripts/tools/freellmapi_doctor.sh
FREELLMAPI_ENABLE_NETWORK=1 bash scripts/tools/freellmapi_start.sh
```

Der Prozess laeuft **im Vordergrund**; mit `Ctrl+C` bewusst stoppen.
Kein Autostart, kein systemd, kein Hintergrundprozess/PID-Kill implementiert.
In einem zweiten Terminal kann man pruefen:

```bash
# Fuer expliziten HTTP-Test (check/status pruefen nur Build-Artefakte):
bash scripts/tools/freellmapi_start.sh --health
```

Dashboard: `http://127.0.0.1:3011`. `FREELLMAPI_HOST_PORT` kann bei Bedarf
vor dem Aufruf einen anderen lokalen Port waehlen; Clients konsistent anpassen.
Erstzugang nach Upstream einrichten. Setup-/Passwort-Reset-Codes aus dem
Terminal wie Secrets behandeln; nicht in Support-Logs veroeffentlichen.

`status`/`--check` pruefen nur Build-Marker/Artefakte. Doctor prueft zusaetzlich
Laufzeiten und ENV, startet nichts. `--health` ist ein ausdruecklicher lokaler
HTTP-Ping, kein Auth-/Modell-/Fallback-Test und kein Identitaetsbeweis des Dienstes.

Der Python-Launcher erzwingt `HOST=127.0.0.1`, Produktionsmodus und
DB unter `tools/freellmapi/native-data/freeapi.db`. Er uebernimmt keine
beliebigen Prozess-/Node-/Startup-Konfigurationen aus der Umgebung.
Kein Fallback auf `0.0.0.0`, kein Shellcode aus ENV.

## 4. Kein Offline-/Gratisversprechen

Beim Serverstart koennen Katalog-, Discovery- und Providerkontakte erfolgen.
`FREELLMAPI_ENABLE_NETWORK=1` ist dafuer bewusste Zustimmung, keine Garantie,
dass nur ein bestimmter Provider kontaktiert wird.
`FREELLMAPI_UPDATE_CHECK=off` deaktiviert nicht die Katalog-Synchronisation.
[Upstream-Katalogcode](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/server/src/services/catalog-sync.ts).
Echten Offlinebetrieb mit Egress-Sperre separat auditieren/testen.

Free-Tier-Quoten, Preise und Modellverfuegbarkeit aendern sich.
Keine garantierten 40 MB RAM oder unbegrenzten Gratis-Tokens.
Klar freigeben, welche Dateien/Prompts an welchen Provider duerfen.
Context-Handoff bleibt `off`; Wechsel koennen Informationen zu anderen
Anbietern tragen, ohne gleiche Antwortqualitaet zu garantieren.

## 5. Ollama, Coding-Clients, OpenClaw und n8n

Beim nativen Router auf **demselben Host** kann ein dort erreichbares Ollama
als Custom Provider `http://127.0.0.1:11434/v1` dienen.
Container-Clients wie n8n haben dagegen einen eigenen localhost.
Keine Ollama- oder Router-Bindung auf alle Interfaces als schnelle Loesung.

OpenAI-kompatible Clients verwenden typischerweise
`http://127.0.0.1:3011/v1`, vorhandene Modell-ID und Router-Key.
Fuer Claude Code beschreibt Upstream eine Anthropic-kompatible Basisadresse
ohne `/v1`. Das Setup aendert Clients nicht automatisch.
Die **mitgebaute GitHub-CLI** statt eines Docker-/npx-Downloads verwenden:

```bash
read -r -s -p 'Unified API-Key aus dem Router: ' FREELLMAPI_API_KEY
printf '\n'
export FREELLMAPI_API_KEY
node "$HOME/.openclaw_ultimate_user_data/tools/freellmapi/source/cli/dist/index.js" \
  setup-claude --url http://127.0.0.1:3011 --dry-run
unset FREELLMAPI_API_KEY
```

Pfad bei abweichendem User-Datenverzeichnis anpassen. Upstream-Vorschauen
koennen Keys in Diffs zeigen: nicht aufzeichnen/teilen. Vor echter
Client-Aenderung Backup und manuelle Freigabe.
[Client-Doku](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/docs/en/clients/01-agent-clients.md),
[CLI-Quelle](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/cli/README.md).
OpenClaw read-only-first, keine zusaetzlichen Shell-/Schreibrechte durch
Providerwechsel. n8n-Secrets in dessen Credential Store, nicht in Export-JSON.

## 6. Alte Docker-Installationen nicht vermischen

Die alte [Compose-Vorlage](../../stacks/freellmapi/compose.yml) bleibt nur
als historische/optionale Referenz, wird vom Installer nicht mehr verwendet.
Es gibt keinen automatischen Docker-Stop, keine Container-/Volume-Loeschung
und keine Migration. Alte `data/` und `compose.yml` bleiben unveraendert.

Vor Umstieg alten Router selbst mit dessen bisheriger Betriebsart stoppen.
Ist Port 3011 belegt, startet/baut die native Integration nicht weiter.
Native Daten liegen absichtlich unter **native-data/**; alter Adminzugang,
Provider-Keys und Unified Key erscheinen dort nicht automatisch.

Gewollte Migration separat planen: alten Router sauber stoppen, SQLite
konsistent sichern, DB samt Sidecars und bisherigem ENCRYPTION_KEY
verschluesselt sichern, Wiederherstellung isoliert testen. Keinen neuen
Verschluesselungskey fuer eine alte Datenbank verwenden. Keine laufende
SQLite-Datei blind kopieren oder Datenbank/Key automatisch rotieren.

## 7. Update / Reparatur / Deaktivierung

```bash
# Vordergrundprozess zuerst bewusst mit Ctrl+C stoppen:
bash scripts/tools/freellmapi_update.sh
bash scripts/tools/freellmapi_install.sh --repair
bash scripts/tools/freellmapi_uninstall.sh
```

Update bleibt bei dem im Setup gepinnten Commit. Eine neue Upstream-Version
braucht bewusste Pin-/Build-/Lizenzpruefung, kein `git pull latest`.
Build/Start/Deaktivierung nutzen denselben Lock.
Deinstallation benennt nur den sauberen Source-Ordner in
`source.disabled.<Zeit>.<PID>` um; keine rekursive Loeschung.
ENV, native-data, alte Containerdaten und Code bleiben erhalten.
Manuelle Source-Aenderungen blockieren auch diese Aktion.

| Fehler | Sicherer naechster Schritt |
|---|---|
| Node/npm fehlt oder unpassend | passende Laufzeit bewusst separat einrichten; kein System-Node-Umbau |
| SQLite-Smoke-Test scheitert | native Abhaengigkeiten/Node-ABI und Buildlog pruefen |
| Git-Ziel kaputt, fremd oder dirty | sichern/pruefen, nicht automatisch loeschen/resetten |
| Port oder Lock belegt | eigenen laufenden Dienst/Build bewusst beenden |
| ENV ungueltig | drei erlaubte Schluessel, Rechte/Besitz/Format pruefen |
| HTTP-Ping scheitert | Routerstart und lokales Terminal pruefen, keine Secrets teilen |
| 401/429/Modell fehlt | Router-Key, Modell/Provider und Quota pruefen; keine Limit-Umgehung |

## Tests und offene Punkte

```bash
python3 -m unittest discover -s tests -p test_freellmapi.py -v
```

Nur temporaere Dateien und simulierte Git/npm/Node-Aufrufe, keine echte
Installation/Provider-/WSL-Tests. Offen: realer Linux-/ARM-Build,
Auth-/Fallback-/Lasttest, verschluesselter Restore und optionaler
systemd-user-Betrieb. Der Server wurde durch diese Repo-Aenderung nicht gestartet.
