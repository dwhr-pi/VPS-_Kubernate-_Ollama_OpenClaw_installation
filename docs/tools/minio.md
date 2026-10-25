# MinIO: GitHub-Source-Build und private Go-Basis

MinIO bietet S3-kompatiblen Objektspeicher. Dieser Installer baut nur das
Programm aus GitHub; er startet keinen Server und erstellt oder migriert keine
Buckets, Benutzer, Zugangsdaten oder Datenverzeichnisse.

**Wichtige Wartungsgrenze:** Die
[README am gepinnten Stand](https://github.com/minio/minio/blob/7aac2a2c5b7c882e68c1ce017d8256be2feea27f/README.md)
kennzeichnet das Community-Repository ausdruecklich als nicht mehr gepflegt.
Ein Source-Build macht diesen Stand nicht automatisch sicher oder gewartet.
Kein Einsatz als neuer produktiver Speicher ohne gesonderte Security-/Restore-
Abnahme und Wartungsentscheidung. Die dort genannten AIStor-Angebote sind
andere Produkte und werden hier weder installiert noch als gleichwertiger
Open-Source-Ersatz ausgegeben. Die Community-Quelle steht unter AGPLv3;
Lizenzbedingungen vor Weitergabe/Betrieb pruefen.

## Fehler vom 25.10.2026: Go fehlt

Das Log um 02:41 zeigt fehlendes Go vor dem Build. Die Speicherpruefung
war erfolgreich. Der Installer kann nun nach Zustimmung dieselbe private
Go-Basis wie die anderen freigegebenen nativen Go-Werkzeuge bereitstellen.

Nach Uebernahme der aktualisierten Setup-Dateien und Lesen der Wartungsgrenze:

```bash
bash scripts/tools/minio_install.sh --dry-run
# Explicit consent for private Go; builds the application but starts no server:
bash scripts/tools/minio_install.sh --install-build-deps
bash scripts/tools/minio_doctor.sh
```

Ohne Flag fragt ein interaktives Terminal mit `[j/N]`. Enter, EOF oder fehlende
Zustimmung genehmigt keinen Download. Dry-Run bleibt auch mit Flag schreibfrei;
die Build-Aktivierung laedt kein fehlendes Go still nach.

## Go-Vertrag und Quellen

Die [go.mod am Pin](https://github.com/minio/minio/blob/7aac2a2c5b7c882e68c1ce017d8256be2feea27f/go.mod)
nennt `go 1.24.0` und `toolchain go1.24.8`. Unser Installer akzeptiert
konservativ **Go >=1.24.8**. Passendes vorhandenes Go wird bevorzugt.
Andernfalls kann der vorhandene Bootstrap nach Zustimmung **go1.27.3**
aus dem offiziellen Go-Archiv mit fester Groesse/SHA256 privat bereitstellen.
Dies ist eine binaere Buildwerkzeug-Ausnahme, kein Source-Build von Go.
System-Go, globaler PATH und Shellprofile bleiben unveraendert.
Pruefwerte und Plattformen: [private_go.py](../../scripts/tools/helpers/private_go.py).

Private Toolchain:
`~/.openclaw_ultimate_user_data/tools/minio/toolchain/`.
Nur Build-Kindprozesse erhalten PATH/GOROOT. `GOTOOLCHAIN=local` verhindert
einen stillen Toolchainwechsel. Go-Module werden ueber den konfigurierten
Modulproxy mit Pruefsummenkontrolle geladen; kein ausschliesslicher GitHub-
Download fuer alle Dependencies zugesichert. MinIO selbst stammt aus dem
gepinnten lokalen Checkout, nicht aus einem Docker-Image.

## Speicher und Datenerhalt

Tool-Startreserve bleibt **8192 MiB**, unter WSL auch auf dem Windows-Host.
Der Go-Helper prueft separat mindestens 4 GiB freien Zielspeicher; die Grenzen
sind nicht zu 12 GiB zu addieren. Vorpruefungen garantieren keinen ausreichenden
Platz fuer jeden Build. Bestehende Speicherwaechter bleiben aktiv.

Ein fehlgeschlagener Bootstrap erzeugt keinen erfolgreichen App-Buildnachweis.
Bereits fertige private Toolchain bleibt bei spaeterem App-Fehler und App-
Deinstallation erhalten. Alte Container, Volumes, /opt-Installationen und
Objektdaten bleiben unberuehrt. Kein automatisches Docker, sudo oder Daten-Purge.

## Vor einem spaeteren Betrieb

Der Installer prueft nur `--version`, nicht S3-Lesbarkeit oder Datenintegritaet.
Echte Buckets niemals als Build-/Smoke-Testverzeichnis verwenden.
Separat klaeren: Dienstbenutzer, Datenpfade und Rechte, TLS/interne Listener,
eigene geschuetzte Credentials, Kapazitaet, Backup und getestetes Restore.
Keine Upstream-Beispielpasswoerter fuer den Betrieb uebernehmen. Ein Backup
darf nicht ausschliesslich auf demselben MinIO/Datentraeger liegen, dessen
Ausfall oder Wartung abgesichert werden soll.

Offline-Fixtures pruefen Zustimmung, private Aktivierung und Fehlerpfade.
Ein echter Ubuntu-/WSL-Build oder S3-/Bucket-Test wurde hier nicht ausgefuehrt.
Siehe [Docker-zu-GitHub-Migration](../DOCKER_TO_GITHUB.md).
