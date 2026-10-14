# FreeLLMAPI: optionaler Router fuer Coding-Agenten

Status: **experimental / optional**, kein Bestandteil der Basisinstallation.
Upstream: [tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi), MIT.
Stand der Pruefung: 14.10.2026, Server `v0.14.2`, CLI-Paket `0.8.1`.
Die Integrationsskripte sind vorbereitet; ein echter Docker-/Provider-Test steht aus.

## Was macht das Tool?

FreeLLMAPI vermittelt API-Anfragen an konfigurierte Modelle. Claude Code kann
die Anthropic-kompatible Schnittstelle verwenden; andere Clients nutzen die
OpenAI-kompatible API. Modell-Fallbacks koennen Ausfaelle abfangen, ersetzen
aber weder Provider-Limits noch eine Kostenkontrolle. Claude Code bleibt dabei
ein eigener Client: Ein lokales Modell wird nicht zum Claude-Modell.
Siehe [Client-Dokumentation](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/docs/en/clients/01-agent-clients.md).

**Nicht versprechen:** unbegrenzt kostenlose Tokens, garantierte Modellqualitaet,
eine feste Anzahl verfuegbarer Gratis-Endpunkte oder garantierten Betrieb mit
40 MB RAM. Free-Tier-Verfuegbarkeit, Konten und Nutzungsbedingungen aendern sich.
OpenRouter und andere Cloud-Anbieter sind nicht grundsaetzlich kostenlos.

## Voraussetzungen und Ressourcen

| Punkt | Dieses Setup |
|---|---|
| Host | Linux/WSL2 mit bereits bewusst eingerichteter Docker Engine und Compose v2 |
| CPU | amd64 oder arm64 laut Upstream; konkrete Images hier nicht ausgefuehrt |
| RAM | 512 MiB Planungsreserve nur fuer den Router; Last und weitere Dienste zusaetzlich einplanen |
| Disk | 2 GiB Linux-Reserve, unter WSL mindestens 10 GiB Windows-Host-Reserve |
| GPU | fuer Router nicht erforderlich; lokale Modelle separat dimensionieren |
| Host-Node | fuer Container nicht erforderlich; optionale CLI braucht Node >=20.18 und <25 sowie npm >=10 |
| Port | ausschliesslich `127.0.0.1:3011`, Container intern `3001`; Grafana belegt bereits Host-Port 3001 |

RAM-/Disk-Werte sind konservative Setup-Planungswerte, keine gemessenen
Upstream-Mindestwerte. Der Installer prueft den vorhandenen RAM und die Disk;
er installiert weder Docker noch Node und veraendert keine Gruppen/Sockets.
CLI-Node 22 mit passendem npm ist ein sinnvoller vorhandener Laufzeitpfad.
Siehe [Upstream-Installation](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/docs/en/install/01-install.md).

## Schritt 1: erst den Plan ansehen

Diese Befehle sind fuer den Nutzer auf dem Zielsystem bestimmt; sie werden durch
das Hinzufuegen der Integration nicht ausgefuehrt. Im Repository-Root starten:

```bash
bash scripts/tools/freellmapi_install.sh --dry-run
docker compose version
docker info
```

Im Tool-Menue heisst der neue Eintrag `FreeLLMAPI`. Ohne explizites Opt-in
startet auch die Menueauswahl keinen Download oder Container.

## Schritt 2: private ENV vorbereiten

Vorlage: [config/freellmapi.env.example](../../config/freellmapi.env.example).
Die echte Datei gehoert nach
`~/.openclaw_ultimate_user_data/env/freellmapi/.env`, Dateirechte `0600`.
`ENCRYPTION_KEY` muss ein eigener, kryptografisch zufaelliger Wert aus genau
64 Hex-Zeichen sein, beispielsweise lokal im Passwortmanager erzeugt.
Keine Beispielzeichenfolge als echten Schluessel verwenden.

Mit dem [ENV-Tresor](../ENV_VAULT.md), sofern age und Python eingerichtet sind:

```bash
# init nur beim ersten Anlegen des Tresors:
python3 scripts/security/env_vault.py init
python3 scripts/security/env_vault.py set freellmapi_encryption_key
python3 scripts/security/env_vault.py bind freellmapi ENCRYPTION_KEY freellmapi_encryption_key
python3 scripts/security/env_vault.py render freellmapi
python3 scripts/security/env_vault.py render freellmapi --apply
```

Der Wert wird verdeckt abgefragt, nicht als Kommandoargument uebergeben.
Bestehenden Tresor nicht neu initialisieren. Bei Speichervorgaengen die gewollte
Masterpassphrase verwenden. Alternativ die Vorlage manuell ausserhalb des Repos
bearbeiten und die Rechte setzen. Provider-Schluessel erst spaeter bewusst im
Router hinterlegen; das Setup importiert nicht automatisch alle Tresorwerte.

## Schritt 3: bewusst starten und pruefen

```bash
FREELLMAPI_ENABLE_DOCKER=1 bash scripts/tools/freellmapi_install.sh
bash scripts/tools/freellmapi_doctor.sh
```

Dashboard: `http://127.0.0.1:3011`. Erstzugang nach der Upstream-Anleitung
einrichten. Admin-Passwort und Wiederherstellungscodes wie Secrets behandeln.
Kein Admin-Panel ins Internet weiterleiten; Fernadministration nur ueber einen
bewusst eingerichteten privaten VPN-/SSH-Zugang.

`doctor`, `status` und `--check` pruefen nur `/api/ping`, weder Authentifizierung
noch Modellantworten. Ein erfolgreicher Ping ist kein Sicherheitsnachweis.
Containerdaten liegen unter `~/.openclaw_ultimate_user_data/tools/freellmapi/`.
Das Setup-Menue protokolliert den Aufruf im vorhandenen Installationslog.
Direkte Skriptaufrufe geben Diagnosen auf dem Terminal aus; keine Secrets mitloggen.

## Schritt 4: Modellpfad bewusst waehlen

Im Dashboard zuerst einen Provider bzw. Custom-Provider und ein verfuegbares
Modell waehlen. Modell-IDs aus dem eigenen Katalog nehmen, nicht aus alten Videos.
Gratis-Kontingente und kostenpflichtige Modelle getrennt freigeben.
Vor dem ersten Test pruefen, welche Quelltexte und personenbezogenen Daten an
welchen Anbieter gehen duerfen. Provider-Keys werden fuer dessen API verwendet;
sie bleiben nicht ausschliesslich im Router.

Ollama, LM Studio oder llama.cpp koennen ueber einen passenden
OpenAI-kompatiblen Endpunkt angebunden werden. **Container-localhost ist nicht
Host-localhost:** `http://127.0.0.1:11434/v1` im Container erreicht kein Ollama
auf dem Host. Auch `host.docker.internal` macht einen ausschliesslich an
Host-Loopback gebundenen Dienst nicht automatisch erreichbar.
Nicht einfach Ollama auf `0.0.0.0` oeffnen! Fuer diesen Fall eine native lokale
Router-Installation oder eine separat abgesicherte private Netzverbindung planen.
Die Compose-Vorlage fuegt absichtlich keine Hostnetz-/Firewall-Ausnahme hinzu.

**Kein Offline-Versprechen:** Der Router synchronisiert extern einen Katalog.
`FREELLMAPI_UPDATE_CHECK=off` deaktiviert nicht diese Katalogkontakte.
Strikt offline erfordert gesonderte Netzwerk-/Quellcodepruefung und einen Test
unter ausgehend gesperrtem Netz; das wird hier nicht automatisch eingerichtet.
Siehe [Katalog-Synchronisation](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/server/src/services/catalog-sync.ts).

## Schritt 5: Claude Code verbinden

Nur mit bereits installiertem Claude Code und geeigneter Node/npm-Laufzeit.
Die optionale CLI stammt aus dem npm-Paket des GitHub-Projekts, nicht aus apt;
`npx` laedt und fuehrt dieses Paket aus. Versionspruefung/Review vorher bewusst
vornehmen. Server-Release und CLI-Version sind verschieden.

```bash
read -r -s -p 'Unified API-Key aus deinem Router: ' FREELLMAPI_API_KEY
printf '\n'
export FREELLMAPI_API_KEY
export FREELLMAPI_URL=http://127.0.0.1:3011
npx --yes freellmapi@0.8.1 setup-claude --url http://127.0.0.1:3011 --dry-run
```

**Achtung:** Die Upstream-Vorschau zeigt Konfigurationsdiffs; diese koennen den
Unified API-Key enthalten. Nicht aufzeichnen, hochladen oder in Issues einfuegen.
Nach lokaler Pruefung ohne `--dry-run` wiederholen, wenn die dauerhafte
Client-Aenderung gewollt ist. Vorhandene Client-Konfiguration vorher sichern.
Claude Code verwendet die Router-Basisadresse **ohne `/v1`**.

```bash
# Nach Ende der Konfiguration/Client-Sitzung:
unset FREELLMAPI_API_KEY FREELLMAPI_URL
```

Umgebungsvariablen sind kein vollwertiger Tresor: Kindprozesse und privilegierte
Benutzer koennen darauf zugreifen. Keine Schluessel als Argument oder in der
Shell-History speichern. Hinweise zu CLI-Generatoren und dem alternativen
temporaren `launch`-Modus stehen in der
[CLI-Anleitung](https://github.com/tashfeenahmed/freellmapi/blob/v0.14.2/cli/README.md).

## Weitere Clients, OpenClaw und n8n

Die Upstream-CLI dokumentiert `setup-cline`, `setup-continue`, `setup-aider`
und `setup-openclaw`. Erst mit `--dry-run` pruefen; das Setup veraendert diese
Clients nicht automatisch. OpenAI-kompatible Clients verwenden normalerweise
`http://127.0.0.1:3011/v1`, eine gueltige Modell-ID und den Unified API-Key.

OpenClaw bleibt read-only-first: Providerwechsel geben keine Schreib-, Shell-
oder Versandberechtigung. Unbekannte Modell-Tool-Calling-Faehigkeiten erst mit
harmlosen Testaufgaben pruefen. Fuer n8n einen HTTP-/OpenAI-kompatiblen
Workflow mit Zugangsdaten im n8n-Credential-Store anlegen, niemals mit Key im
Workflow-Export. Laeuft n8n selbst im Container, gilt erneut: dessen localhost
ist nicht der Host. Keine pauschalen Portfreigaben als Abkuerzung.

Context-Handoff bleibt im Beispiel `off`. Optional `on_model_switch` erst nach
Datenschutzpruefung aktivieren: Zusammenfassungen koennen Kontext an einen
anderen Provider uebertragen und erhalten keinen vollstaendigen internen
Modellzustand. Ein erfolgreicher Fallback garantiert keine gleiche Antwortqualitaet.

## Windows, Linux, macOS und Android

Upstream bietet Desktop-/Installationswege fuer Windows, macOS und Linux.
Fuer einen lokalen Arbeitsplatz kann der native Weg einfacher sein, wenn der
Router ausschliesslich lokale Host-Loopback-Modelle erreichen soll. Offizielle
Releases und Plattformhinweise verwenden; dieses Setup automatisiert die native
Desktop-Installation nicht. Android/Termux ist ein gesonderter experimenteller
Weg, keine hier getestete Android-App. Niemals das Admin-Panel nur fuer einen
Handy-Homescreen-Link oeffentlich machen; Zugriff ausschliesslich privat absichern.

## Update, Deinstallation, Backup und Fehler

```bash
# Bleibt beim hier geprueften Versionstag; kein automatisches latest:
FREELLMAPI_ENABLE_DOCKER=1 bash scripts/tools/freellmapi_update.sh
FREELLMAPI_ENABLE_DOCKER=1 bash scripts/tools/freellmapi_uninstall.sh
```

Update/Installation ueberschreiben keine abweichende Runtime-Compose-Datei.
Bei neuer Setup-Version zuerst Diff und Backup pruefen; manuelle Migration bleibt
bei Abweichungen erforderlich. Deinstallation stoppt/entfernt Container und
Netzwerk, **nicht ENV, Datenbank oder Schluessel**; kein `down -v`.

Vor Updates den Router stoppen und Datenverzeichnis plus ENCRYPTION_KEY/ENV
zusammen verschluesselt sichern. SQLite nicht unkoordiniert im laufenden Betrieb
kopieren. Restore in isolierter Testumgebung pruefen. Schluesselverlust macht
verschluesselte Provider-Keys unbrauchbar; Key nicht einfach austauschen.

| Fehler | Sichere Reaktion |
|---|---|
| Opt-in fehlt | Doku lesen; FREELLMAPI_ENABLE_DOCKER=1 nur bewusst setzen |
| ENV/Key/Rechte fehlen | Vorlage/Tresor pruefen; chmod 600 auf der privaten ENV |
| Docker-Zugriff fehlt | bestehende Docker-Einrichtung pruefen; kein chmod 666 am Socket |
| Port belegt | Belegung pruefen; FREELLMAPI_HOST_PORT bewusst aendern und Clients anpassen |
| Ping scheitert | lokale Compose-Logs pruefen; Container kann bereits laufen; keine privaten Logs teilen |
| 401/429/Modell fehlt | Key, Providerquota und Live-Katalog pruefen, nicht Limits umgehen |

Offen: echter Linux-/ARM-/WSL-Lauf, Image-Digest/Signatur, Auth-/Fallback-Smoke-Test,
Ressourcenmessung, kontrollierter Offline-Test und Client-/Restore-Integration.

## Reproduzierbare Offline-Tests

```bash
python3 -m unittest discover -s tests -p test_freellmapi.py -v
```

Die Tests verwenden temporaere Verzeichnisse und simulierte Docker-Aufrufe:
Dry-Run ohne Schreibzugriff, Opt-in-Sperre, Wiederholung, fehlgeschlagener Pull,
Healthcheck-Fehler, Erhalt persoenlicher Dateien, Registry-/Menueverdrahtung und
lokale Doku-Links. Sie ersetzen keinen echten Installations-/Authentifizierungstest.
