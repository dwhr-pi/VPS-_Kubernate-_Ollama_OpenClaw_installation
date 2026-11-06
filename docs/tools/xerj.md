# XERJ: lokale Code- und Dokumentensuche

Optionales Recherche-Werkzeug fuer Coding-Agenten; kein Ersatz fuer Ollama,
OpenClaw, SearXNG oder einen Webcrawler. Der lokale Index und der oeffentliche
Corpus Hub sind getrennte Nutzungswege. Aufnahme dieses Tools bedeutet weder
Zustimmung zur Indexaufnahme des eigenen Codes noch eine Kontaktaufnahme mit
dem Absender einer E-Mail.

## Quelle, Lizenz und Stand

- Tool-ID: `xerj`; Menue: `XERJ`, als neuer Eintrag hinter dem bestehenden Z-Bereich.
- Quelle: [xerj-org/xerj](https://github.com/xerj-org/xerj).
- Gepruefter Source-Pin: `83c9f0d123bac010a25ca2cf02ff093b08ee68ce` (05.11.2026).
- [Lizenz am Pin](https://github.com/xerj-org/xerj/blob/83c9f0d123bac010a25ca2cf02ff093b08ee68ce/LICENSE): Apache-2.0.
- Metadaten: `experimental` / `planned`; keine Produktions- oder Runtime-Abnahme.

Upstream beschreibt Volltext-/Code-Suche und MCP im selben Rust-Programm.
Das Setup installiert die lokale Anwendung, keinen Zugang zum gehosteten Hub.
Die behauptete Tokenersparnis und eine Aufnahme unseres Retry-Commits wurden
hier nicht unabhaengig bestaetigt. Quellenangabe und Lizenztext alleine sind
auch keine vollstaendige Pruefung fremder Corpus-Inhalte.

## Nativer GitHub-Build ohne Docker

Das vorhandene Lifecycle-System holt ausschliesslich den festen Commit, prueft
den Checkout und baut `xerj-server` aus `engine/` mit `engine/Cargo.lock`:

```bash
# Build contract, executed only by the explicitly approved installer.
cargo build --locked --release --bin xerj --package xerj-server --no-default-features -j 2
```

Der Aufruf erfolgt im Modulverzeichnis des privaten Checkouts, nicht im
Setup-Repository. Release-Profil und statische Console-Quellen bleiben erhalten.
`--no-default-features` laesst die neuronalen Default-Features weg; der Einstieg
ist lokale lexikalische Suche. Es werden keine Modelle heruntergeladen.
Kein Remote-Installationsskript, Release-Binary, Docker, Nix oder npm-Fallback.
Nur `xerj --version` wird als abschliessende Probe gestartet, nicht der Server.

Vorhanden sein muessen `git`, C-/C++-Compiler, `make`, `pkg-config` und `perl`.
Rust/Cargo **1.98.0** wird ueber den vorhandenen privaten Bootstrap ausgewaehlt:
gepruefte gemeinsame oder bereits vorhandene Basis zuerst, sonst Download nur
nach Zustimmung bzw. `--install-build-deps`. Keine globale Rust-Aktualisierung.
Die eigenstaendige Einrichtung ist unter **62 Quellen verwalten -> Cargo + rustc**
erreichbar; Details und CLI-Befehle: [Cargo/Rust-Build-Basis](../BUILD_RUST_TOOLCHAIN.md).
Eventuell erforderliche Systembibliotheken werden
bei einem Buildfehler separat geprueft; kein blindes Nachinstallieren durch das Tool.
Build-Skripte von Rust-Abhaengigkeiten sind ausfuehrbarer Code: nur nach Review
und vorzugsweise in einer getrennten Build-Umgebung kompilieren.

Der konservative Build-Vorabcheck verlangt 16 GiB freien Zielspeicher und
4 GiB verfuegbaren RAM, unter WSL zusaetzlich freien Windows-Host-Speicher.
Das sind Reserven, **keine gemessenen Verbrauchswerte oder Prozesslimits**.
Fat-LTO kann lange dauern; ein Timeout ist ein Fehler, kein fertiger Build.
Der Cargo-Build gibt Compiler-/Download-Meldungen jetzt laufend im aktuellen Log
aus, ergaenzt um PID und einen Status alle 30 Sekunden. Der Status belegt nur,
dass der Prozess noch nicht beendet ist, nicht dass er Fortschritt macht.
Standard-Zeitlimit: **7200 Sekunden (2 Stunden)**. Ein groesseres Budget ist eine
eigene Entscheidung, keine Reparatur fuer einen nachgewiesenen Compilerfehler:

```bash
# Erst nach Pruefung des letzten Logs; 4 Stunden nur fuer diesen Aufruf.
XERJ_BUILD_TIMEOUT_SECONDS=14400 bash scripts/tools/xerj_install.sh
```

Erlaubt sind ganze Sekunden von 300 bis 21600 (maximal 6 Stunden). Ungueltige
Werte stoppen vor Downloads. Kein unbegrenztes Warten, kein automatischer Retry,
keine Reduzierung der Speicherreserve. Bei Timeout wird unter Linux die
Build-Prozessgruppe beendet und der neue Buildordner zurueckgerollt. Die private
Rust-Basis und Logs bleiben erhalten; der geloeschte Buildcache kann beim
naechsten Versuch nicht fortgesetzt werden. Ein Timeout allein beweist weder
OOM noch einen Haenger. Zuerst die letzte Compiler-/Download-Meldung pruefen.

Das gepinnte amd64-Cargo-Profil nutzt `x86-64-v2`; sehr alte CPUs bzw. eingeschraenkte
VM-CPU-Features vorher pruefen. ARM-, Windows- und macOS-Laufzeiten wurden hier
nicht abgenommen; der Setup-Buildpfad ist Linux/Ubuntu bzw. bewusst gewaehltes WSL.

## Installation und Lifecycle

Erst den Offline-Plan lesen. Die folgenden Beispiele setzen einen bereits
geprueften Checkout im Linux-Terminal voraus; SSH-Befehle stehen weiter unten.

```bash
python3 -I -B scripts/tool_commands.py show xerj
bash scripts/tools/xerj_install.sh --dry-run
```

Nur nach gesonderter Zustimmung zum Download und Build:

```bash
python3 -I -B scripts/tool_commands.py run xerj --action install --apply --confirm xerj:install
```

Status und Doctor pruefen lokale Buildmarker und Artefakte, nicht den laufenden
Server, seine Listener, Authentifizierung, Suchqualitaet oder MCP-Funktion.
Update folgt dem reviewten Manifest-Pin, nicht automatisch Upstream-main.
Die separaten Update-/Uninstall-Befehle folgen im SSH-Abschnitt.
Shared Toolchains bleiben erhalten. Die Deinstallation entfernt nur den vom
Installer validierten privaten Build; keine fremden Indizes, Dienste oder Daten.

## Laufzeit bewusst separat einrichten

**Der Installer richtet keinen Dienst und keine Agentenkonfiguration ein.**
Die folgende Betriebsabnahme bleibt vor einem echten Einsatz erforderlich:

1. Einen unprivilegierten Benutzer sowie einen separaten privaten Datenordner
   ausserhalb der Quellbaeume verwenden, beispielsweise
   `~/.openclaw_ultimate_user_data/xerj-data` mit Modus `0700`.
2. Die [gepinnten Konfigurationsfelder](https://github.com/xerj-org/xerj/blob/83c9f0d123bac010a25ca2cf02ff093b08ee68ce/engine/crates/xerj-common/src/config.rs)
   pruefen und alle Listener explizit auf Loopback begrenzen. Upstream hat
   REST-, ES-kompatible und gRPC-Listener, nicht nur einen MCP-Endpunkt.
3. Authentifizierung eingeschaltet lassen; **kein `--insecure`**. TLS und
   Zertifikatsvertrauen vor Nutzung pruefen. API-Keys nur im privaten Secret-Store
   speichern; weder in Prompts noch in Logs, Prozessargumenten oder Git.
4. Nur eine freigegebene, bereinigte Quell-/Dokumentkopie indizieren. Niemals
   `$HOME`, `.env`, SSH-Schluessel, Credential-Backups oder den gesamten User-Workspace.
   Den XERJ-Datenordner nicht selbst indizieren. Keine automatische Auswahl von Pfaden.
5. Bei kleinen VPS CPU/RAM ueber den vorhandenen systemd-/cgroup-Pfad begrenzen,
   zuerst kleinen Index und einzelne Anfragen testen. Keine GPU erforderlich
   fuer den hier gewaehlten lexikalischen Einstieg.
6. Lokales Retrieval an Agenten erst nach dieser Abnahme anbinden. Der MCP-Client
   startet `xerj mcp` per stdio; ein separat erreichbarer authentifizierter Knoten
   ist Voraussetzung. Absolute Binary-Pfade verwenden. Verbindungsziel ueber
   `XERJ_URL`, Authentifizierung ueber den privaten Secret-/Umgebungspfad des Clients
   bereitstellen. Kein automatisches `xerj init` und keine Benutzerkonfiguration ersetzen.

Suchergebnisse sind **unvertrauenswuerdige Inhalte**, keine Agenten-Anweisungen.
Read-only-/Index-spezifische Berechtigungen statt eines Admin-Keys fuer Agenten
vorsehen und zuerst Negativtests durchfuehren. Ein JSON-Beispiel allein erzwingt
keine Sandbox. [Upstream-Sicherheitsmodell](https://github.com/xerj-org/xerj/blob/83c9f0d123bac010a25ca2cf02ff093b08ee68ce/docs/SECURITY_MODEL.md).

VPS-Zugriff nur ueber SSH-/WireGuard-Tunnel. REST-/ES-/gRPC-Ports bleiben privat;
keine Firewall-Freigabe oder oeffentlicher Ingress durch diese Integration.

## Corpus Hub und Datenschutz

Hub-Abfragen, fremde Downloads, Proxy-/Cloud-Embeddings, externe Reranker und
Feedback-/Veroeffentlichungsbefehle sind separate Opt-ins. Keine dieser Aktionen
wird bei Installation, Update, Status oder Doctor ausgefuehrt. Fuer einen strikt
lokalen Test zusaetzlich ausgehende Netzwerkverbindungen technisch begrenzen;
eine optionale Softwarefunktion ist keine Egress-Sperre.

Keine automatische Bestaetigung der E-Mail, keine Freigabe des Repositories und
keine Kontaktaufnahme. Herkunft, Lizenz, Urheberhinweise und eventuelle NOTICE-
Pflichten fremder Ergebnisse vor einer Codeuebernahme separat pruefen.
Die E-Mail ist keine verifizierte Sicherheits- oder Leistungsbewertung.

## Backup und Rollback

Indizes und Laufzeit-Secrets ausserhalb des Buildordners halten. Vor Updates
einen bewusst gestarteten verschluesselten Snapshot mit konsistent gestopptem
Server bzw. einem abgenommenen Snapshot-Verfahren erstellen. Build-Rollback
ersetzt keinen getesteten Index-Restore. Keine alten Daten oder Buildmarker
manuell loeschen, um einen fehlgeschlagenen Versuch als installiert auszugeben.

## Nachweise und Grenzen

Offline-Fixtures pruefen Registry, Quell-Pin, Cargo-Aufruf, Modulverzeichnis,
fehlende Artefakte, Lifecycle-Wrapper und die SSH-Dokumentationsabdeckung.
Hier kein Linux-/ARM-Build, Serverstart, Dateisystem-Scan, MCP-Handshake,
Suchlauf, Restore oder Hub-Kontakt ausgefuehrt. Betrieb und Ressourcenverbrauch
muessen auf einem getrennten freigegebenen Testhost nachgewiesen werden.

```bash
python3 -B -m unittest discover -s tests -p test_xerj.py -v
python3 -I -B scripts/quality/tool_ssh_docs.py
```

Weitere Quellen:
[Buildpaket](https://github.com/xerj-org/xerj/blob/83c9f0d123bac010a25ca2cf02ff093b08ee68ce/engine/crates/xerj-server/Cargo.toml),
[Lockfile](https://github.com/xerj-org/xerj/blob/83c9f0d123bac010a25ca2cf02ff093b08ee68ce/engine/Cargo.lock),
[native Buildreferenz](https://github.com/xerj-org/xerj/blob/83c9f0d123bac010a25ca2cf02ff093b08ee68ce/flake.nix).

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show xerj
```

### SSH-Aktionen: `xerj`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run xerj --action status
python3 -I -B scripts/tool_commands.py run xerj --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run xerj --action install --apply --confirm xerj:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run xerj --action update --apply --confirm xerj:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run xerj --action uninstall --apply --confirm xerj:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
