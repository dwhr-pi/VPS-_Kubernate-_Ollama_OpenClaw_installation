# LTX Video: lokale Quellen oder externe API

**Anbieter: Lightricks.** Das vorhandene Tool `LTX_Video` verwaltet bereits
gepinnt [Lightricks/LTX-Video](https://github.com/Lightricks/LTX-Video),
Pin `4b2d053057623ddd4d0a1d3e9cd28890e9ef487f`.
Es ist **nur Quellenverwaltung**, keine fertige Video-Runtime, kein Modell-Pull
und keine ComfyUI-Integration. Nicht mit anderen LTX-Versionen oder LTX Desktop
gleichsetzen. Code-, Gewichts- und Dienstlizenzen je Version getrennt pruefen.

Ja, es gibt auch eine [offizielle LTX API](../_API-Keys/OnlineOnKeyServices/ltx.md).
Die API wird extern betrieben und separat abgerechnet; sie macht einen
GitHub-Clone nicht zu einer lokalen einsatzbereiten Installation.

## Lifecycle und Grenzen

Python 3, Git; bestehende 2048 MiB Reserve nur fuer den Quellbestand.

```bash
bash scripts/tools/ltx_video_install.sh --dry-run
bash scripts/tools/ltx_video_install.sh
bash scripts/tools/ltx_video_doctor.sh
bash scripts/tools/ltx_video_update.sh --dry-run
bash scripts/tools/ltx_video_uninstall.sh --dry-run
```

Der bestehende Helper verwendet `scope: source` und `runtime_tested: false`.
Sein historisches `installed`-Feld bezeichnet hier nur den Quellenmarker,
**nicht eine gebaute Anwendung**. Doctor prueft Pin/Origin/Dateiinventar;
kein Render-Smoke-Test. Update bleibt beim Pin. Deinstallation ohne
`--dry-run` nur fuer unveraenderten Bestand mit Besitznachweis; Logs und
sonstige Nutzerdaten bleiben erhalten. Keine systemd-Unit fuer Quellenverwaltung,
kein Docker, API-Aufruf, Dienst- oder Modellstart. Nativer Runtime-Build,
Gewichtsverifikation, SBOM und Render-Abnahme sind weiterhin offen.
Die [Sammelanleitung](github-gap-tools.md) bleibt als historische Einordnung erhalten.

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
python3 -I -B scripts/tool_commands.py show ltx_video
```

### SSH-Aktionen: `ltx_video`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`LTX_Video` (ID `ltx_video`) waehlen und die Einzelfreigaben lesen.
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
