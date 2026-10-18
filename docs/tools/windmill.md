# Windmill nativ aus GitHub installieren

## Menue-Status

Ein vorhandener `source-ready`-Marker registriert die vorbereitete
Quellinstallation im Tools-Menue, auch nach einer direkten Skriptinstallation.
Damit kann sie dort wieder abgewaehlt/deaktiviert werden. Dies bestaetigt keinen
laufenden Server/Worker. Deaktivierung entfernt Marker und beide Statuszeilen;
erhaltene Quellen/Binaries allein registrieren das Tool nicht erneut.

Stand 16.10.2026. [Upstream](https://github.com/windmill-labs/windmill),
[Release v1.837.0](https://github.com/windmill-labs/windmill/releases/tag/v1.837.0),
Quell-Pin `1fe3858a6d51949327046117d9ce4c10467a3000`.

**Kein Docker. Kein automatischer Server-/Worker-Start und keine Datenbank-
Einrichtung.** Windmill ist eine Workflow-Plattform mit Code-Ausfuehrung,
nicht einfach ein einzelnes KI-Modell oder eine fertige Sandbox.

## 1. Zuerst den passenden Installationsweg waehlen

| Weg | Ergebnis | Grenze |
|---|---|---|
| Standard im Tools-Menue | gepinnte GitHub-Quellen | kein kompiliertes Programm, kein Workflow-Dienst |
| explizite Binary-Option | zusaetzlich natives Linux-amd64-Release mit SHA256-Pruefung | eigene Release-Lizenzbedingungen, DB/Runtimes noch separat |
| eigener Open-Source-Build | separat zu planen | Rust/Frontend-Build, Features und Toolchains muessen geprueft werden |

Der Platzhalter ist durch eigene Install-/Update-/Doctor-/Status-Skripte
ersetzt. Die Registry bleibt experimental, automatische Installation bleibt aus.
Das Menue behauptet nach Quellen-/Binary-Einrichtung keinen laufenden Dienst.

## 2. Quellen ohne Docker installieren

Im Setup-Verzeichnis:

```bash
bash scripts/tools/windmill_install.sh --dry-run
bash scripts/tools/windmill_install.sh
bash scripts/tools/windmill_status.sh
bash scripts/tools/windmill_doctor.sh
```

Voraussetzungen: normaler Linux-Benutzer, Git, Python 3.10+ fuer die
Metadatenpruefung, flock und Coreutils. Keine automatische apt-, Rust-,
Node- oder Docker-Installation. Keine Root-Ausfuehrung.

Ziel ausserhalb des Repositories:

```text
~/.openclaw_ultimate_user_data/tools/windmill/
  source/          gepinnter Sparse-Checkout
  source-ready     nach erfolgreicher Quellenpruefung
  bin/windmill     nur bei expliziter Binary-Auswahl
  binary-ready     nur nach erfolgreicher Hashpruefung
  operation.lock   Schutz gegen parallele Installer
~/.openclaw_ultimate_user_data/install_logs/windmill_*.log
```

Backend/Frontend/ausgewaehlte Clients und Lizenzdateien werden ausgecheckt.
Die upstream vorhandenen .env/.envrc, Agent-Konfigurationen, Hooks und
Compose-Startdateien werden nicht in den Arbeitsbaum uebernommen.
Der Git-Objektspeicher kann dennoch Upstream-Inhalte enthalten: nicht als
Secret-Vault behandeln. Kein Buildskript, Package-Hook oder Upstream-Code wird ausgefuehrt.

Vor Download werden 2 GiB freie Disk und, unter WSL soweit messbar,
2 GiB freie Windows-C:-Reserve verlangt. Vorher/nachher wird Disk gemessen.
Dry-Run erstellt keine Dateien und laedt nichts herunter.

## 3. Optional: natives GitHub-Release-Binary

**Zuerst die [Lizenzdatei am Pin](https://github.com/windmill-labs/windmill/blob/1fe3858a6d51949327046117d9ce4c10467a3000/LICENSE)
lesen:** Der ohne Enterprise-Feature aus dem Quellcode kompilierbare Teil
ist laut Upstream AGPL; bestimmte Clients sind Apache-2.0. Die fertigen
Community-Edition-GitHub-Binaries enthalten jedoch auch proprietaere,
nicht oeffentliche Komponenten. Ihre Bedingungen sind nicht mit reiner
AGPL-Nutzung gleichzusetzen; insbesondere Weiterverkauf, Managed Service,
Aendern oder Wrapping sind laut dieser Datei eingeschraenkt.

Nur wenn du **diese Release-Bedingungen bewusst akzeptierst**, die native
Linux-amd64-Datei installieren:

```bash
WINDMILL_INSTALL_BINARY=1 WINDMILL_ACCEPT_RELEASE_TERMS=1 \
  bash scripts/tools/windmill_install.sh --dry-run

WINDMILL_INSTALL_BINARY=1 WINDMILL_ACCEPT_RELEASE_TERMS=1 \
  bash scripts/tools/windmill_install.sh
```

Der Dry-Run erklaert nur den Plan; die wirkliche Installation prueft Freigabe,
Architektur und Ressourcen. Download:
`https://github.com/windmill-labs/windmill/releases/download/v1.837.0/windmill-amd64`.
Dateigroesse am Prueftag: 673147864 Bytes, ungefaehr 642 MiB.

SHA256 laut [GitHub-Asset-Metadaten](https://api.github.com/repos/windmill-labs/windmill/releases/tags/v1.837.0):

```text
5879cd22b178d8871031cc072e5de5052ab46c4bd134e3358ff8a96d25d229aa
```

Der Installer laedt per HTTPS mit Zeitlimit in eine temporaere Datei,
prueft SHA256 und ELF-Architektur und setzt erst danach das Ausfuehrungsrecht.
Er fuehrt das Binary **nicht** aus, auch nicht fuer einen Versioncheck.
Hashgleichheit ist kein Sicherheits-Audit des Upstream-Binaries.
Quellen + Binary verlangen hier 4 GiB freie Linux-Disk und messbare
Windows-C:-Reserve. Das ist keine Betriebs-/Job-Speicherzusage.

Das nicht-EE-Asset dieses Releases ist nur fuer Linux x86_64 vorhanden.
AMD64 bedeutet auch Intel-x86_64, nicht nur AMD-Prozessoren.
Unter WSL2 ist die Linux-Architektur entscheidend; ARM/RPi/Oracle-ARM,
Windows und macOS bekommen nicht versehentlich dieses Binary. Keine
automatische Emulation und kein Ausweichen auf Enterprise-Dateien.

## 4. Warum der Dienst danach noch nicht laeuft

Fuer echten Betrieb fehlen noch bewusst:

1. Separates PostgreSQL mit eigener DB/Rolle, restriktiven Rechten und Backup.
   Windmill-Start/Migrationen koennen die DB veraendern; vorher sichern.
2. Server- und Worker-Konfiguration. Im gepinnten Quellcode ist der
   Server-Bind-Default 0.0.0.0. Vor jedem Start explizit
   `SERVER_BIND_ADDR=127.0.0.1` setzen, keine oeffentliche Freigabe!
3. Ein eigener unprivilegierter Betriebssystembenutzer und die zu den
   gewaehlten Job-Sprachen passenden Laufzeiten. Windmill fuehrt Skripte aus;
   ein nativer Prozess allein ist keine Sandbox.
4. Initiale Anmeldung/Authentifizierung und sichere DB-/Admin-Secrets.
   Echte Werte nur ausserhalb des Repos, restriktive Dateirechte, keine
   ungeprueften Upstream-Defaultpasswoerter oder Tokens in Logs.
5. Einen Worker/Job gleichzeitig, Zeit-/RAM-/CPU-Limits, Netzwerkregeln und
   einen Testauftrag ohne Produktivdaten. Unsere Setup-Queue ist noch nicht
   automatisch mit Windmill-Workern verbunden.

Es wird absichtlich kein sofort ausfuehrbarer Startbefehl mit ungesicherter
Datenbank oder Default-Adminzugang erzeugt. Auch `--help`/`--version`
wird vom Installer nicht aufgerufen. Die Dateiablage ist noch keine
nachgewiesen betriebsbereite Instanz; Status meldet `runtime_ready: false`.
Es wird kein Port geoeffnet, deshalb bleibt die Registry-Portliste leer.

## 5. Ressourcen und Zielhosts

Planungswerte, keine getesteten Upstream-Minima:

| Host | Empfehlung |
|---|---|
| MiniPC / WSL2 | zuerst Quellen; fuer DB/Server/einen leichten Worker ca. 4-8 GiB RAM einplanen |
| RPi5 / Oracle ARM | kein passendes nicht-EE-Release-Asset am Pin; eigener ARM-Build bleibt offen |
| Oracle x86_64 VPS | native Datei moeglich; Admin nur localhost/VPN, DB nicht oeffentlich |
| Gaming-PC / RTX 5080 | GPU nicht fuer den Workflow-Server erforderlich; GPU-Jobs separat begrenzen |
| Dual Xeon | Parallelitaet bewusst niedrig starten, RAM/Disk pro Job budgetieren |
| Kubernetes | kein Deployment durch diesen nativen Pfad; kein Docker-Fallback |

Rust-/Frontend-Source-Builds koennen erheblich mehr CPU/RAM/Disk brauchen.
Dieser Installer startet sie nicht und behauptet keine getestete native
Buildkette. Reiner Open-Source-Build ohne proprietaere Release-Komponenten
bleibt ein separater, deutlich schwererer Integrationsschritt.

## 6. Update, Reparatur und Deinstallation

```bash
bash scripts/tools/windmill_update.sh --dry-run
bash scripts/tools/windmill_update.sh
bash scripts/tools/windmill_install.sh --repair
bash scripts/tools/windmill_uninstall.sh
```

Updates verwenden denselben Pin, nicht automatisch latest. Fuer die
Binary-Option beide Freigabevariablen wie oben setzen. Bereits passende
Dateien werden wiederverwendet; falscher Hash, fremdes Repository,
lokale Aenderungen oder unvollstaendiger Clone fuehren zum Abbruch statt
zu Reset/Loeschen. Fehlerursache beheben und erneut versuchen.

Uninstall entfernt nur die Bereitschaftsmarker. Quellen, Binary, Daten,
Datenbanken und Logs bleiben erhalten. Ein spaeter separat gestarteter
Dienst wird dadurch nicht automatisch gestoppt. Vor manuellem Loeschen
Backup und tatsaechliche Pfade pruefen.

Offen: nativer AGPL-Source-Build mit Frontend, DB-/Migrations- und Restore-Test,
separate Server-/Worker-Serviceunits, Sandbox-/Runtime-Provisionierung,
Architektur-/glibc-Kompatibilitaet und echter Workflow-Smoke-Test.

Technische Quellen:
[gepinntes Backend](https://github.com/windmill-labs/windmill/blob/1fe3858a6d51949327046117d9ce4c10467a3000/backend/src/main.rs),
[Cargo-Features](https://github.com/windmill-labs/windmill/blob/1fe3858a6d51949327046117d9ce4c10467a3000/backend/Cargo.toml).
