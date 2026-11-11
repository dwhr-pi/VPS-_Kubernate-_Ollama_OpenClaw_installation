# Qwen Coder: Modellquellen, nicht Qwen Code

Optionales Tool **Qwen_Coder**, Status `experimental` / `planned`.
[Qwen3-Coder](https://github.com/QwenLM/Qwen3-Coder) ist eine Modellfamilie;
[Qwen Code](qwen-code.md) ist der bereits vorhandene Coding-Client.
Ein installierter Client enthaelt nicht automatisch ein Sprachmodell.

Gepruefter GitHub-Pin: `33bc6aabd7791ad7b32f7e92104f11f2359ba890`.
README-SHA256: `7553f06c6f17a7ce22a76995a210b07fb6724d32a0cdc7bd4961ed2866d80fd4`.
Die [Modellkarte von Qwen3-Coder-30B-A3B-Instruct](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)
weist Apache-2.0 aus. Andere Qwen-Modelle, Daten und Pakete gesondert pruefen;
Open Weights bedeuten keine vollstaendig offengelegten Trainingsdaten.
Der gepruefte GitHub-Root hat keine separate LICENSE-Datei; die Modelllizenz
ist kein pauschaler Lizenznachweis fuer jedes Repository-Artefakt.

## Einrichtung und Grenzen

Sprachenauswahl im aktuellen Familien-Upstream: Python, JavaScript/TypeScript,
C/C++, Java, Rust, Go und weitere; auch Assembly und GAS werden genannt.
Die aktuelle Liste steht insbesondere im Next-Abschnitt und ist kein eigener
Qualitaetsnachweis fuer jeden Checkpoint. ISA, Dialekt und ABI getrennt testen.

Python 3 und Git, 2048 MiB Reserve **nur fuer den GitHub-Quellbestand**.
Kein Modell-Pull, kein Docker, Training oder automatischer Serverstart.

```bash
bash scripts/tools/qwen_coder_install.sh --dry-run
# Explicit source preparation only; no weights or inference runtime.
bash scripts/tools/qwen_coder_install.sh
bash scripts/tools/qwen_coder_status.sh
bash scripts/tools/qwen_coder_doctor.sh
bash scripts/tools/qwen_coder_update.sh --dry-run
bash scripts/tools/qwen_coder_uninstall.sh --dry-run
```

Status meldet `source_prepared`, `installed: false`, `runtime_tested: false`.
Doctor prueft Pin, Origin, README-Vertrag und Inventar, keine Coding-Faehigkeit.
Update bleibt beim Pin. Uninstall ohne `--dry-run` entfernt nur unveraenderte,
inventarisierte Quellen mit Besitznachweis unter
`~/.openclaw_ultimate_user_data/tools/qwen_coder/`; eigene Aenderungen sperren
die Entfernung. Logs, Modelle und sonstige Benutzerdaten bleiben erhalten.
Keine systemd-Unit fuer reine Quellenverwaltung; nativer Modellbetrieb,
Gewichtsmanifest/SBOM und Runtime-Smoke-Test bleiben separat abzunehmen.

Die vollstaendige [Einrichtungs- und Sprachuebersicht](../models/README.md)
beschreibt Gewichte, RAM/VRAM, lokale Inferenz und Coding-Clients.
[RAG und Herkunft](../models/WEIGHTS_RAG_AND_PROVENANCE.md) sowie
[Weitertraining und Datenmigration](../models/TRAINING_AND_EVALUATION.md)
beantworten die weiterfuehrenden Modellfragen. Assembler ist als eigener,
architektur- und dialektabhaengiger Testbereich enthalten.

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
python3 -I -B scripts/tool_commands.py show qwen_coder
```

### SSH-Aktionen: `qwen_coder`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Qwen_Coder` (ID `qwen_coder`) waehlen und die Einzelfreigaben lesen.
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
