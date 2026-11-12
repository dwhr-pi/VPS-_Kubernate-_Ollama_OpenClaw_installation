# Audile

Optionaler Menuepunkt **Audile**, Status `experimental` / `planned`.

## Quelle, Lizenz und Plattform

[Offizielles GitHub-Projekt](https://github.com/AudileTeam/Audile).
Gepruefter Pin (2026-11-11): `a3f225946a35fcf97f7b61d8d985b84968bbf65a`.
Lizenz: GPL-3.0. README und vorhandene Lizenzdateien werden gegen
die SHA256 im Quellenmanifest geprueft.

Android-App (ab Android 8), kein Linux-VPS-Daemon. JDK, Android SDK und Gradle werden fuer einen APK-Build separat benoetigt. AudD, ACRCloud und Shazam sind externe Erkennungsdienste; eine lokale Matching-Engine ist hier nicht belegt. Audio/Fingerprints koennen das Geraet verlassen; Anbieterbedingungen, Konten, Quoten und Einwilligung separat pruefen.

## Native Quellenverwaltung

Python 3 und Git erforderlich. 2048 MiB Reserve gelten nur fuer die Quellen,
nicht fuer Buildabhaengigkeiten, Audio-Datenbanken oder Gewichte. Kein Docker-Fallback.

```bash
bash scripts/tools/audile_install.sh --dry-run
bash scripts/tools/audile_install.sh
bash scripts/tools/audile_status.sh
bash scripts/tools/audile_doctor.sh
bash scripts/tools/audile_update.sh --dry-run
bash scripts/tools/audile_uninstall.sh --dry-run
```

Install bereitet nur Quellen vor: `source_prepared`, `installed: false`,
`runtime_tested: false`. Doctor prueft Pin, Origin, Vertragsdateien und Inventar,
keine Inferenz oder Erkennung. Update bleibt beim Pin. Uninstall ohne Dry-run
entfernt nur unveraenderte, inventarisierte Quellen mit Besitznachweis;
geaenderte Dateien, Modelle, Datenbanken, Logs und sonstige Benutzerdaten bleiben erhalten.
Keine systemd-Unit fuer reine Quellenverwaltung. Native Runtime, Dependency-Lock,
SBOM und echter End-to-End-Test bleiben offen. Kein automatischer Start/Download
von Modellen, Aufnahme, Training, API-Test oder Dienst.

## Einsatz in der Hybrid-Plattform

[Musikerkennung und Domain-Modelle](../AUDIO_RECOGNITION_AND_DOMAIN_MODELS.md)
erlaeutert Datenfluss, Modellkarten und Sicherheitsgrenzen. Auf dem VPS werden
Quellen verwaltet; Android-/Desktop-Werkzeuge laufen nicht dadurch als Server.
GPU-Inferenz gehoert auf passende lokale Worker; private Endpunkte nur ueber
WireGuard, Authentifizierung und bewusst freigegebene Clients verwenden.

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
python3 -I -B scripts/tool_commands.py show audile
```

### SSH-Aktionen: `audile`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Audile` (ID `audile`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

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
