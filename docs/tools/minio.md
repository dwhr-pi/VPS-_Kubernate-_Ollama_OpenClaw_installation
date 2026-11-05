# MinIO: GitHub-Source-Build und private Go-Basis

MinIO bietet S3-kompatiblen Objektspeicher. Dieser Installer baut nur das Programm aus GitHub; er
startet keinen Server und erstellt oder migriert keine Buckets, Benutzer, Zugangsdaten oder
Datenverzeichnisse.

**Wichtige Wartungsgrenze:** Die
[README am gepinnten Stand](https://github.com/minio/minio/blob/7aac2a2c5b7c882e68c1ce017d8256be2feea27f/README.md)
kennzeichnet das Community-Repository ausdruecklich als nicht mehr gepflegt. Ein Source-Build macht
diesen Stand nicht automatisch sicher oder gewartet. Kein Einsatz als neuer produktiver Speicher
ohne gesonderte Security-/Restore- Abnahme und Wartungsentscheidung. Die dort genannten
AIStor-Angebote sind andere Produkte und werden hier weder installiert noch als gleichwertiger
Open-Source-Ersatz ausgegeben. Die Community-Quelle steht unter AGPLv3; Lizenzbedingungen vor
Weitergabe/Betrieb pruefen.

## Fehler vom 25.10.2026: Go fehlt

Das Log um 02:41 zeigt fehlendes Go vor dem Build. Die Speicherpruefung war erfolgreich. Der
Installer kann nun nach Zustimmung dieselbe private Go-Basis wie die anderen freigegebenen nativen
Go-Werkzeuge bereitstellen.

Nach Uebernahme der aktualisierten Setup-Dateien und Lesen der Wartungsgrenze:

```bash
bash scripts/tools/minio_install.sh --dry-run
# Explicit consent for private Go; builds the application but starts no server:
bash scripts/tools/minio_install.sh --install-build-deps
bash scripts/tools/minio_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`. Enter, EOF oder fehlende Zustimmung genehmigt
keinen Download. Dry-Run bleibt auch mit Flag schreibfrei; die Build-Aktivierung laedt kein
fehlendes Go still nach.

## Go-Vertrag und Quellen

Die
[go.mod am Pin](https://github.com/minio/minio/blob/7aac2a2c5b7c882e68c1ce017d8256be2feea27f/go.mod)
nennt `go 1.24.0` und `toolchain go1.24.8`. Unser Installer akzeptiert konservativ **Go >=1.24.8**.
Passendes vorhandenes Go wird bevorzugt. Andernfalls kann der vorhandene Bootstrap nach Zustimmung
**go1.27.3** aus dem offiziellen Go-Archiv mit fester Groesse/SHA256 privat bereitstellen. Dies ist
eine binaere Buildwerkzeug-Ausnahme, kein Source-Build von Go. System-Go, globaler PATH und
Shellprofile bleiben unveraendert. Pruefwerte und Plattformen:
[private_go.py](../../scripts/tools/helpers/private_go.py).

Private Toolchain: `~/.openclaw_ultimate_user_data/tools/minio/toolchain/`. Nur Build-Kindprozesse
erhalten PATH/GOROOT. `GOTOOLCHAIN=local` verhindert einen stillen Toolchainwechsel. Go-Module
werden ueber den konfigurierten Modulproxy mit Pruefsummenkontrolle geladen; kein ausschliesslicher
GitHub- Download fuer alle Dependencies zugesichert. MinIO selbst stammt aus dem gepinnten lokalen
Checkout, nicht aus einem Docker-Image.

## Speicher und Datenerhalt

Tool-Startreserve bleibt **8192 MiB**, unter WSL auch auf dem Windows-Host. Der Go-Helper prueft
separat mindestens 4 GiB freien Zielspeicher; die Grenzen sind nicht zu 12 GiB zu addieren.
Vorpruefungen garantieren keinen ausreichenden Platz fuer jeden Build. Bestehende Speicherwaechter
bleiben aktiv.

Ein fehlgeschlagener Bootstrap erzeugt keinen erfolgreichen App-Buildnachweis. Bereits fertige
private Toolchain bleibt bei spaeterem App-Fehler und App- Deinstallation erhalten. Alte Container,
Volumes, /opt-Installationen und Objektdaten bleiben unberuehrt. Kein automatisches Docker, sudo
oder Daten-Purge.

## Vor einem spaeteren Betrieb

Der Installer prueft nur `--version`, nicht S3-Lesbarkeit oder Datenintegritaet. Echte Buckets
niemals als Build-/Smoke-Testverzeichnis verwenden. Separat klaeren: Dienstbenutzer, Datenpfade und
Rechte, TLS/interne Listener, eigene geschuetzte Credentials, Kapazitaet, Backup und getestetes
Restore. Keine Upstream-Beispielpasswoerter fuer den Betrieb uebernehmen. Ein Backup darf nicht
ausschliesslich auf demselben MinIO/Datentraeger liegen, dessen Ausfall oder Wartung abgesichert
werden soll.

Offline-Fixtures pruefen Zustimmung, private Aktivierung und Fehlerpfade. Ein echter
Ubuntu-/WSL-Build oder S3-/Bucket-Test wurde hier nicht ausgefuehrt. Siehe
[Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).

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
python3 -I -B scripts/tool_commands.py show minio
```

### SSH-Aktionen: `minio`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run minio --action status
python3 -I -B scripts/tool_commands.py run minio --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run minio --action install --apply --confirm minio:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run minio --action update --apply --confirm minio:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run minio --action uninstall --apply --confirm minio:uninstall
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
