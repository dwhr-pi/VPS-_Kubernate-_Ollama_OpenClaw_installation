# Cargo und Rust als private Build-Basis

Cargo ist bereits im Katalog **62 Quellen verwalten** enthalten. Sein GitHub-
Source-Build benoetigt jedoch selbst Cargo und rustc. Fuer die Erstinstallation
gibt es jetzt eine getrennte Aktion: **Optionen -> 16 -> Cargo + rustc: private
Build-Basis erstmals einrichten**. Auch der Button **62 Quellen verwalten** im
Tool-Management fuehrt in dieses Menue. Erst Plan lesen, dann separat bestaetigen.

## Quellen und Ausnahme

Anwendungen wie XERJ bleiben native Builds aus gepinnten GitHub-Quellen.
Der bereits fuer LiteLLM genehmigte offizielle Compiler-Bootstrap wird
wiederverwendet: rustup-init **1.29.2** mit fest hinterlegter SHA256 und Groesse
fuer Linux amd64/arm64, anschliessend Rust/Cargo **1.98.0**, Profil `minimal`.
Die Compiler kommen von `https://static.rust-lang.org`, nicht aus einem hier
selbst gebauten GitHub-Checkout. Das ist ausdruecklich eine **Basis-Toolchain-
Ausnahme**, kein vollstaendiger Rust-Source-Build. Der Installer fuehrt kein
heruntergeladenes Shellskript aus. rustup prueft die Compiler-Komponenten nach
seinem offiziellen Distributionsverfahren; die Komponenten sind nicht nochmals
mit eigenen im Repository hinterlegten Einzel-Hashes gepinnt.

Kein Docker, apt, sudo, `curl | sh`, globaler PATH-Wechsel, Shellprofil- oder
Rust-Default-Wechsel. Nicht als root starten. Andere Plattformen werden nicht
automatisch ueber WSL oder einen anderen Paketmanager eingerichtet.

## Linux und VPS ueber SSH

Auf dem Client bei einem bereits selbst eingerichteten SSH-Alias:

```bash
ssh -t vps
```

Danach im Linux-Terminal des VPS oder im eigenen Ubuntu-/WSL-Terminal im
geprueften Checkout (Branch-Pfad gegebenenfalls anpassen):

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
bash scripts/install_rust_build_tools.sh plan
```

Nur nach Pruefung und separater Download-Freigabe:

```bash
bash scripts/install_rust_build_tools.sh install --apply
```

Ohne `--apply` bleibt `install` ein Plan und liefert Exitcode 2, niemals einen
Installiert-Marker. Mindestens **6 GiB freier Zielspeicher** sind vorgesehen;
unter WSL wird auch die Windows-Host-Reserve geprueft. Das ist ein konservativer
Vorabwert, kein gemessener Verbrauch und keine Garantie fuer den spaeteren Build.

Gemeinsames Ziel:
`~/.openclaw_ultimate_user_data/tools/cargo_build_tools/toolchain/`.
Ein sicherer externer `OPENCLAW_USER_DATA_DIR` wird unterstuetzt.
Die Einrichtung meldet den absoluten Toolchain-Ordner. Status und Doctor:

```bash
bash scripts/install_rust_build_tools.sh status
bash scripts/install_rust_build_tools.sh doctor
```

Wiederholtes Installieren prueft die vorhandenen Dateien/Hashes und verwendet
denselben Pin. Veraenderte oder unvollstaendige Bestandsdateien werden nicht
automatisch ueberschrieben. Fehler bleiben Fehler; Logdateien bleiben erhalten.

## XERJ und weitere Source-Builds

XERJ und LiteLLM erkennen die gepruefte gemeinsame Basis ohne Aenderung deines
globalen PATH. XERJ weiterhin separat installieren, es wird durch den
Compiler-Bootstrap nicht mitgestartet:

```bash
bash scripts/tools/xerj_install.sh
```

Alternativ kann XERJ seine eigene private Compiler-Basis nach Zustimmung
einrichten. Der ausdrueckliche Download-Schalter lautet:

```bash
bash scripts/tools/xerj_install.sh --install-build-deps
```

Hier beginnt anschliessend auch der XERJ-Build; dessen eigene 16-GiB-Reserve
bleibt verbindlich. Fuer einen neuen werkzeugspezifischen Compiler kommen 2 GiB
Puffer hinzu. C/C++-Compiler, make, pkg-config und perl bleiben separate
Voraussetzungen. Keine automatische Systempaketinstallation fuer XERJ.

Bei `NATIVE_SOURCE_RUST_TOOLCHAIN` hat die explizite Auswahl Vorrang und muss
zum Pin passen. Die gemeinsame Erstinstallation lehnt eine solche gesetzte
Auswahl ab, statt sie still zu ersetzen. Fuer andere vorhandene Buildrezepte
kannst du `bin/` des ausgegebenen Toolchain-Ordners bewusst nur fuer das aktuelle
Terminal in den PATH aufnehmen. Die Einrichtung selbst macht das nicht.

## Update, Daten-Erhalt und Rollback

Es gibt kein automatisches `rustup update`, keinen ungeprueften Latest-Kanal und
keine automatische Entfernung der gemeinsamen Compiler. Ein neuer Compiler-Pin
braucht einen eigenen Review und ein separates Verzeichnis. Die bisherige Basis
bleibt bei Deinstallation von XERJ/LiteLLM erhalten. Gemeinsame Compiler nicht
entfernen, solange andere Builds sie benoetigen. Es gibt bewusst keinen
rekursiven Uninstall-Befehl fuer diesen gemeinsam genutzten Bootstrap.

Abgebrochene Downloads bereinigen nur ihr neues privates Staging. Nach einem
harten Prozessabbruch vorhandene Sperren oder Restverzeichnisse erst manuell
pruefen; keinen gesamten User-Workspace loeschen.

## Nachweisgrenzen

Offline-Fixtures pruefen Plan/Consent, Fehlerweitergabe, Wiederverwendung,
Hashfehler, explizite Auswahl, Guard-/PATH-Erhalt und die XERJ-Integration.
Kein echter Compiler-Download, Linux-/ARM-Build oder XERJ-Serverstart wurde
hierdurch abgenommen. Auch ein vorhandener Compiler garantiert nicht die
Kompatibilitaet aller Upstream-Abhaengigkeiten oder eine fertige Anwendung.

```bash
python3 -B -m unittest discover -s tests -p test_cargo_build_tools.py -v
python3 -B -m unittest discover -s tests -p test_litellm_rust_bootstrap.py -v
python3 -B -m unittest discover -s tests -p test_xerj.py -v
```

[XERJ](tools/xerj.md) | [Installationsrichtlinie](INSTALLATION_POLICY.md)
