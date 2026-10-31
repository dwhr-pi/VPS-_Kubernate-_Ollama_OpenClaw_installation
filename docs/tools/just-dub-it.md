# Just Dub It aus GitHub, ohne Docker

**Achtung: Das urspruengliche Repository ist archiviert.** Dessen
[README](https://github.com/justdubit/just-dub-it/blob/fa4d8f8911036ba79a62f97e7e62581e39441d56/README.md)
verweist auf den neueren
[LTX-2 LipDubPipeline-Pfad](https://github.com/Lightricks/LTX-2/tree/main/packages/ltx-pipelines#10-lipdubpipeline).
Das Setup ersetzt die Quelle nicht still durch diesen Nachfolger.

`Just_Dub_It` verwendet weiterhin [justdubit/just-dub-it](https://github.com/justdubit/just-dub-it),
Commit `fa4d8f8911036ba79a62f97e7e62581e39441d56`. Status **experimental/archiviert**, nicht als
Produktionssystem getestet. Die Bibliotheken `ltx-core` und `ltx-pipelines` tragen beide Version
`0.1.0`; das ist keine Versionsnummer des Dubbing-Modells.

## Bewusste Basisinstallation

Install/Update/Repair zeigen vor jedem Download den vollstaendigen englischen Lizenztext des
gepinnten Stands einschliesslich **Attachment A** an:
[lokale Lizenzkopie](../../licenses/just-dub-it/LTX-2-Community.txt). Danach erscheint
`Lizenz akzeptieren und fortfahren? [(j)a/(N)ein = ablehnen]:`. `j`/`ja` oder `akzeptieren`
bestaetigen nur diesen Aufruf. Enter, unbekannte Antworten, Nein oder EOF brechen vor
Download/Installation ab. Die Zustimmung wird nicht dauerhaft gespeichert und ersetzt keine eigene
Lizenzpruefung. Der lange Text bleibt im Terminal zum Zurueckscrollen und im Menue-Log lesbar.

Ohne interaktives Terminal erfolgt keine automatische Zustimmung. `JUST_DUB_IT_ACCEPT_LICENSE=1`
bleibt eine bewusst gesetzte nichtinteraktive Freigabe; der Text wird auch dann angezeigt. Mit `0`
ablehnen. Fehlt die Lizenzkopie, wird auch mit `1` abgebrochen. Status/Doctor/Dry-Run/Deaktivierung
verlangen keine Annahme. Keine automatische Annahme anderer Modelllizenzen.

```bash
bash scripts/tools/just_dub_it_install.sh --dry-run
# Interaktiv: vollstaendige Lizenz lesen, dann akzeptieren oder ablehnen:
bash scripts/tools/just_dub_it_install.sh
# Erst Lizenz/Archivstatus pruefen und Bedingungen selbst akzeptieren:
JUST_DUB_IT_ACCEPT_LICENSE=1 bash scripts/tools/just_dub_it_install.sh
bash scripts/tools/just_dub_it_status.sh
bash scripts/tools/just_dub_it_doctor.sh
JUST_DUB_IT_ACCEPT_LICENSE=1 bash scripts/tools/just_dub_it_update.sh
JUST_DUB_IT_ACCEPT_LICENSE=1 bash scripts/tools/just_dub_it_install.sh --repair
```

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, flock, realpath und **Python 3.12** mit venv,
ensurepip und SSL. `JUST_DUB_IT_PYTHON_BIN` waehlt einen vorhandenen Interpreter. Die beiden
gepinnten Pakete verlangen Python >=3.12; der Installer begrenzt den Basispfad auf 3.12. Kein
System-Python-Austausch oder automatische Installation eines anderen Python.

### Fehlendes venv/ensurepip reparieren

Seit 19.10.2026 bietet der Installer fuer ein passendes Ubuntu-System-Python das Paket
`python3.12-venv` an. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine Installation.
Nach eigener Lizenzpruefung und bewusster Zustimmung zu beiden Schritten ist nichtinteraktiv
moeglich:

```bash
JUST_DUB_IT_ACCEPT_LICENSE=1 JUST_DUB_IT_INSTALL_VENV_DEPS=1 \
  bash scripts/tools/just_dub_it_install.sh --repair
```

`JUST_DUB_IT_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation. Die venv-Zustimmung ersetzt
keine Lizenzannahme. Lizenzfreigabe, Speicherpruefung, Sperre und aktuelles Tool-Log kommen vor der
Reparatur. Nur das passende System-Python unter `/usr/bin/python3.12` wird so ergaenzt; private
Interpreter, aktive venvs und SSL-/Versionsfehler erfordern separate Pruefung. APT wartet begrenzt
auf Paketverwaltungssperren, ohne Sperrdateien zu loeschen. Nach Paketinstallation wird
venv/ensurepip erneut geprueft; bei Fehlern kein Clone/Build. Just Dub It bleibt am GitHub-Pin, ohne
Docker. Keine GPU-Runtime oder Modelle werden dadurch freigegeben. Vorhandene fremde/beschaedigte
venvs werden nicht automatisch geloescht.

Der Root ist ein uv-Workspace ohne eigenes installierbares Projekt. Deshalb werden **beide lokalen
Unterpakete** `packages/ltx-core` und `packages/ltx-pipelines` mit `--no-deps` in eine private venv
installiert, nicht der Root und kein gleichnamiges PyPI-Paket. **Nur Basispakete: keine
betriebsbereite Dubbing-Laufzeit.** Kein Docker, `uv sync`, GPU-Pakete, Modelldownload, Training,
Importtest oder Dubbing-Start.

Die Anwendung stammt aus GitHub; pip kann isolierte Build-Abhaengigkeiten aus PyPI beziehen.
Upstream verwendet `uv_build>=0.9.8,<0.10.0`. Vollstaendig gehashte/offline Build-Abhaengigkeiten
bleiben offen.

## Schutz und Ressourcen

Ziel: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/just_dub_it/` mit
`source/`, `venv/`, Lock und Setup-Marker. Logs liegen im zugehoerigen `install_logs/`. Abgelehnt
werden Repo-interne Datenpfade und Symlink- Verzeichnisse. Fremde/unvollstaendige/geaenderte Quellen
werden nicht geloescht oder zurueckgesetzt. Update verwendet denselben Pin, nicht latest.

Basisreserve nur fuer Quellcode/Paketbau: 1 GiB Gesamt-RAM, 512 MiB aktuell frei, 2 GiB freie Disk
sowie bei messbarem WSL-Host 2 GiB Windows-C:-Reserve. Freier Dateisystemplatz wird vorher/nachher
protokolliert. Diese Werte reichen nicht automatisch fuer die Modelle. MiniPC/RPi/Oracle-VPS sind
hier nur Basisvorbereitung; GPU-Workstation/Kubernetes brauchen eine separate
CUDA-/VRAM-/RAM-/Diskplanung. Keine gemessene RTX-5080-Zusage.

Doctor prueft Quell-Pin und beide Paketmetadaten/Quellpfade, ohne `ltx_core`, `ltx_pipelines` oder
Torch zu importieren. Status `installed` bezeichnet nur die Basispakete; `runtime_dependencies`,
`models_checked` und `inference_tested` bleiben `false`. Das Menue setzt keinen allgemeinen
Bereitschaftseintrag. Hub-Token werden im Installer-Subprozess entfernt, Offline-Flags gesetzt; das
ist keine Netzwerksandbox.

## Noch offene Laufzeit

Der historische Pfad benoetigt LTX-2-Checkpoint, JustDubit-LoRA, Distilled-LoRA, Spatial-Upscaler
und Gemma-Textencoder. Das Setup laedt diese nicht herunter und nimmt keine Modellbedingungen
automatisch an. `JUST_DUB_IT_INSTALL_RUNTIME=1` wird mit Hinweis abgelehnt: passendes Torch/CUDA,
PyAV/FFmpeg, Modellrevisionen und Ressourcen muessen zuerst gezielt getestet werden. Keine beliebige
LTX-2.3-/LTX-2.5-/Wan- Kompatibilitaet fuer diesen archivierten Pin behaupten.

Die Pipeline erzeugt Audio und Gesichtsbewegung gemeinsam, statt nur eine beliebige externe
Audiospur als universeller LipSync-Editor anzunehmen. Uebersetzung, Sprecher-/Stimmenrechte und
Ergebnispruefung bleiben separat. Nur eigene oder freigegebene Aufnahmen verwenden, Zustimmung
dokumentieren und synthetische Synchronisation kennzeichnen. Keine echten Videos in Tests.

## Lizenz und Deinstallation

Der
[gepinnten LICENSE](https://github.com/justdubit/just-dub-it/blob/fa4d8f8911036ba79a62f97e7e62581e39441d56/LICENSE)
liegt die **LTX-2 Community License** zugrunde, nicht pauschal MIT/Apache.
Modell-/LoRA-/Gemma-Bedingungen separat pruefen. Der Lizenzschalter ist eine bewusste Bestaetigung
des Betreibers, keine Rechtspruefung oder automatische kommerzielle Freigabe durch dieses Setup.

```bash
bash scripts/tools/just_dub_it_uninstall.sh
```

Deaktiviert nur den Setup-Marker. Quellen, venv, eigene Videos/Audios, Modelle, Caches und Logs
bleiben erhalten; keine vollstaendige Dateiloeschung.

Offline-Tests pruefen Registry, Menue, Lizenz-Gate, Pfade und simulierten Paketbau. Ein echter
GitHub-Clone, Paketbau, GPU-/Modell- oder Dubbing-Test und Zugriff auf die WSL des Benutzers wurden
dabei nicht ausgefuehrt. Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
