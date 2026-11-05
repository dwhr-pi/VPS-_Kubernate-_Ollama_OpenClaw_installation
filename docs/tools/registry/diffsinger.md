# DiffSinger: SSH-Einstieg

[Aktuelle Audio-Chain mit Installation, Grenzen und KI-Planung](../local-audio-chain.md).

Tool-ID: `diffsinger`; Reifegrad `experimental` / `planned`.
Kein Modell-/GUI-/Dienststart und keine automatische Inferenz.
Der Quell- bzw. Buildnachweis ist keine Runtime-Abnahme.

## Registrierte Lifecycle-Pfade

- `install`: [registriertes Skript](../../../scripts/tools/diffsinger_install.sh).
- `update`: [registriertes Skript](../../../scripts/tools/diffsinger_update.sh).
- `uninstall`: [registriertes Skript](../../../scripts/tools/diffsinger_uninstall.sh).
- `doctor`: [registriertes Skript](../../../scripts/tools/diffsinger_doctor.sh).
- `status`: [registriertes Skript](../../../scripts/tools/diffsinger_status.sh).

Die Skripte erst nach Quellen-/Lizenz-/Ressourcenpruefung bewusst ausfuehren.
Alte /opt-Installationen, Medien, Modelle und globale Links bleiben erhalten.
Quelle und fester Pin stehen im Offline-Plan sowie in der aktuellen Audio-Anleitung.

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
python3 -I -B scripts/tool_commands.py show diffsinger
```

### SSH-Aktionen: `diffsinger`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`DiffSinger` (ID `diffsinger`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
