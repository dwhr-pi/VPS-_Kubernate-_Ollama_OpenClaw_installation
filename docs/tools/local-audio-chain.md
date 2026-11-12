# Lokale KI-Audio-Chain: Arrangement bis Export

[Lyrics vorbereiten und Reim-/Silbenvorgaben pruefen](../CREATIVE_LYRICS.md):
optionaler vorgeschalteter Offline-Schritt, kein automatisches Audio-Rendering.

Die sechs gewuenschten Tools waren bereits registriert. Diese Ergaenzung nutzt
die vorhandenen IDs und das Profil **AI_Singer**, ohne doppelte Tools oder einen
automatischen Modell-/GPU-/Dienststart einzufuehren. Docker wurde auf Nutzerwunsch
als zweiter Betriebsweg eingeordnet, bleibt aber **kein Installer-Standard oder Fallback**.

## Bestand und tatsaechlicher Installationsumfang

| Tool-ID | Aufgabe | Setup-Umfang | Noch nicht abgenommen |
| --- | --- | --- | --- |
| `openutau` | Arrangement, Noten, Lyrics | Gepinnter privater GitHub-Quellcheckout | .NET-/GUI-Build, Voicebanks, Headless-Renderer |
| `diffsinger` | KI-Gesang | Gepinnter privater GitHub-Quellcheckout | Python-/GPU-Runtime, Modell, Phoneme, Inferenz |
| `rvc` | Timbre-Konvertierung | Vorhandenen gepinnten Quellcheckout beibehalten | Runtime, freigegebenes Stimmenmodell, Inferenz |
| `seed_vc` | Alternative Timbre-Konvertierung | Gepinnter privater GitHub-Quellcheckout | Runtime, Modelle, Referenzstimme, Inferenz |
| `uvr5` | Stimm-/Instrumententrennung | Vorhandenen gepinnten Quellcheckout beibehalten | GUI/Engine, Separationsmodelle, Inferenz |
| `ffmpeg` | Mixdown, Messung und Export | Neuer privater gepinnter CPU-Source-Build | Echter Linux-Build und Audio-Abnahme |

**Ein Quellcheckout ist keine einsatzbereite Anwendung.** Status/Doctor bestaetigen
die jeweiligen Dateien und Quell-Pins, nicht funktionierende Gesangsmodelle.
Die Reifegrade bleiben `experimental` / `planned`. Kein automatisches Training,
keine nachgeladenen Modellgewichte und keine ungeprueften `infer.py`-Aufrufe.

## Weg A: nativ aus GitHub, Standard

| Tool | Quelle | Fester Pin / Lizenzstand |
| --- | --- | --- |
| OpenUtau | [openutau/OpenUtau](https://github.com/openutau/OpenUtau) | `f920e2423113f9a936ec77eebf1f192e02a7ea6a`, MIT |
| DiffSinger | [openvpi/DiffSinger](https://github.com/openvpi/DiffSinger) | `cb7869b8733a3882679c328994ee162845092cff`, Apache-2.0 |
| Seed-VC | [Plachtaa/seed-vc](https://github.com/Plachtaa/seed-vc) | `51383efd921027683c89e5348211d93ff12ac2a8`, GPL-3.0 |
| RVC | [RVC-Project](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) | Bisheriger Registry-Pin bleibt erhalten; Lizenz/Modelle vor Runtime pruefen |
| UVR5 | [Ultimate Vocal Remover](https://github.com/Anjok07/ultimatevocalremovergui) | Bisheriger Registry-Pin bleibt erhalten; Modellrechte separat pruefen |
| FFmpeg | [FFmpeg/FFmpeg](https://github.com/FFmpeg/FFmpeg) | `8105ae2afe2c4182a4ad44b1b9c45a3146f0c0b1`; Build ohne GPL-/Nonfree-Zusatzschalter |

Die alte Adresse `stakira/OpenUtau` verweist inzwischen auf `openutau/OpenUtau`.
`open-mmlab/OpenUtau` aus dem eingefuegten Docker-Entwurf ist nicht die verwendete Quelle.
Lizenznachweise am Pin:
[OpenUtau](https://github.com/openutau/OpenUtau/blob/f920e2423113f9a936ec77eebf1f192e02a7ea6a/LICENSE.txt),
[DiffSinger](https://github.com/openvpi/DiffSinger/blob/cb7869b8733a3882679c328994ee162845092cff/LICENSE),
[Seed-VC](https://github.com/Plachtaa/seed-vc/blob/51383efd921027683c89e5348211d93ff12ac2a8/LICENSE).
Code-Lizenzen sind keine pauschale Lizenz fuer Datensaetze, Voicebanks, Modelle oder Referenzaufnahmen.

Quell-Installationen laufen ueber den vorhandenen Gap-Helper. Beispielsweise,
zuerst nur lesen:

```bash
bash scripts/tools/openutau_install.sh --dry-run
bash scripts/tools/diffsinger_install.sh --dry-run
bash scripts/tools/seed_vc_install.sh --dry-run
```

Erst nach Review bewusst **ein einzelnes** Tool installieren:

```bash
bash scripts/tools/openutau_install.sh
```

DiffSinger/Seed-VC/RVC/UVR5 analog ueber ihren eigenen Installer. Die Quellpfade
liegen unter `~/.openclaw_ultimate_user_data/tools/TOOL_ID/runtime`; SHA und
Besitz-/Inventarmarker werden geprueft. Reserve fuer die drei neuen Quellpfade:
je 2048 MiB, keine gemessene Runtime-Groesse. Geaenderte oder fremde Dateien werden
bei Update/Deinstallation nicht ungefragt verworfen. Basis-Toolchains bleiben erhalten.
Update folgt dem Manifest-Pin, nicht automatisch dem aktuellen Upstream-Branch.

### FFmpeg-Migration ohne Legacy-Loeschung

FFmpeg wird nicht mehr ungepinnt unter `/opt` gebaut oder global verlinkt.
Die bisherigen `/opt/ffmpeg-github`-Dateien, Systempakete, Symlinks und Medien
bleiben unberuehrt. Auch ein altes `command -v ffmpeg` ist kein Nachweis fuer den
neuen Build. Der neue Pfad ist:

```text
~/.openclaw_ultimate_user_data/tools/ffmpeg/native-github/app/bin/ffmpeg
~/.openclaw_ultimate_user_data/tools/ffmpeg/native-github/app/bin/ffprobe
```

Konservativer Vorabcheck: 8 GiB freier Buildspeicher, 2 GiB verfuegbarer RAM,
unter WSL zusaetzlich freie Windows-Host-Kapazitaet. Build mit `make -j2`,
`--disable-autodetect`, `--disable-network`, ohne externe Codec-Autodetektion und
ohne x86-Assembler/NVENC. `bash`, C-Compiler, `make` und `pkg-config` vorher separat
bereitstellen; apt nur fuer diese Build-Abhaengigkeiten, nicht fuer FFmpeg selbst.
Der bewusst kleinere CPU-Build ist kein Ersatz fuer jede bisherige Codec-Konfiguration.

Diese Umstellung aendert den Installationsort. Rollback: Anwendung nicht starten,
geprueften frueheren Build/Checkout wieder waehlen; keine globalen Links automatisch
ersetzen und keine neuen Indizes/Medien loeschen. Native Deinstallation betrifft
nur den validierten neuen privaten Buildordner. Alte Installationen separat reviewen.

## Weg B: Docker, optionaler Betriebsentwurf

Dieser Weg ist **gekennzeichnet, nicht implementiert oder gestartet**. Es gibt
hier keinen neuen Dockerfile, Compose-Autostart oder Container-Installer. Er darf
erst nach einer gesonderten Runtime-/Supply-Chain-Abnahme umgesetzt werden.

| Aspekt | Nativer Standard | Separater Container-Entwurf |
| --- | --- | --- |
| App-Quelle | Gepinnte GitHub-Commits | Dieselben Pins im Build, Basis-Image zusaetzlich per Digest |
| Python | Getrennte gepruefte Umgebungen pro Engine | Nicht alle Engines ungeprueft in ein gemeinsames Image mischen |
| Ausfuehrung | Benutzerrechte, zukuenftig begrenzter Worker | Non-root, read-only Root-FS, Capabilities abwerfen, kein Docker-Socket |
| Ressourcen | Explizite cgroup-/Worker-Grenzen erforderlich | Harte CPU/RAM/PID-Limits; eine GPU-Reservation begrenzt nicht den VRAM |
| Daten | Privater externer Workspace | Nur Projekt-/Modellpfade mounten, kein HOME/SSH/Secret-Bestand |
| MCP | stdio, nur Plan-Funktion | Bevorzugt ebenfalls stdio; kein oeffentlicher Port 8000 |
| Modelle | Eigene gepruefte Dateien, opt-in | Read-only Modell-Mounts mit Lizenz und Hash; nicht ins Image kopieren |
| Netzwerk | Private Endpunkte, keine Cloud als Default | Default-Egress sperren; HTTP nur mit Auth, Origin-Pruefung und privatem Bind |

Die gelieferten Entwuerfe sind keine Produktionsvorlagen: Root-Betrieb,
`0.0.0.0:8000`, `restart: unless-stopped`, `|| true` nach Clone und ungesicherte
Modelldownloads werden nicht uebernommen. Ein `EXPOSE` implementiert weder
Authentifizierung noch einen HTTP-Transport. Kein Containerstart durch das Setup.

## Python, CUDA und RTX 5080

Keine gemeinsame offene `requirements.txt` mit `>=`-Grenzen als vermeintlich
reproduzierbare Runtime installieren. Jede Engine braucht einen eigenen geprueften
Python-/Torch-/Audio-Abhaengigkeitsvertrag mit exakten Versionen, Lock/Hashes und
separatem Modellmanifest. Die Beispielmodule wie `seed_vc.inference` oder
`uvr5/inference.py` sind hier nicht als vorhandene CLI verifiziert.

Die Beispiel-Kombination CUDA 12.1 / `cu121` ist keine geeignete Blackwell-Vorgabe.
PyTorch dokumentiert [Blackwell-Unterstuetzung ab 2.7 mit CUDA 12.8](https://pytorch.org/blog/pytorch-2-7/).
Das ist ein historischer Nachweis, **keine Empfehlung, heute blind 2.7 zu installieren**.
Aktuell passende Treiber, Torch-/Torchaudio-Paarung, GPU-Architektur und
Engine-Version auf dem Testhost pruefen. Weder ein installiertes CUDA-Toolkit
noch `torch.cuda.is_available()` beweisen allein einen erfolgreichen Gesangs-Render.
Es wird in dieser Ergaenzung kein CUDA/PyTorch/ONNX-Modellpaket installiert.

## Lokale KI-Interaktion: technisch read-only

Neu sind eine gemeinsame Projekt-JSON, ein deterministischer Python-Planer und
eine experimentelle **stdio-MCP-Fassade nur fuer Planung**. Es wird kein Modell
geladen, keine API aufgerufen und kein Backendprozess gestartet. Einwilligung
oder ein Hash im Plan ist keine Ausfuehrungsfreigabe. Es gibt absichtlich kein
MCP-Tool fuer Rendern, Shell, Pfadlesen, Modell-Download oder Dateischreiben.

```bash
python3 -I -B scripts/audio/audio_pipeline.py config/audio_project.example.json
```

Der Plan zeigt Arrangement -> DiffSinger -> optional RVC/Seed-VC -> optional
UVR5 -> FFmpeg sowie die noch fehlenden Runtime-/Modell-Abnahmen. Die vorhandenen
Profile `AI_Singer` und `AI_Choir` bleiben nutzbar und werden nicht automatisch installiert.
Die KI kann Noten/Lyrics als validierte JSON vorschlagen, aber keine beliebigen
Skriptpfade oder Kommandozeilen einschleusen. Maximal zehn Minuten Notenentwurf,
2048 Noten und ein zukuenftiger Worker gleichzeitig; noch keine GPU-/VRAM-Abnahme.

Manuell im gewaehlten MCP-Client einen Eintrag mit **absolutem Python-Pfad** und
absolutem Skriptpfad einrichten:

```text
command: absoluter Pfad zum bereits installierten Python
args: -I -B /absoluter/gepruefter/Checkout/scripts/audio/mcp_audio_server.py
transport: stdio
tool: plan_audio_project
```

`plan_audio_project` nimmt das Objekt `project` mit den Feldern des Beispiels an,
nicht einen Host-Dateipfad. Python in Windows, Linux oder macOS bewusst waehlen;
keine automatische WSL-Bruecke. Ollama allein fuehrt keine MCP-Aufrufe aus: ein
MCP-faehiger Agent/Client muss das Plan-Tool explizit anbinden. Es werden keine
vorhandenen Claude-/OpenClaw-/IDE-Konfigurationen veraendert.
Der Client beendet den stdio-Prozess; EOF oder Ctrl+C beendet ihn ebenfalls.

Die MCP-Transporte sind laut [Spezifikation](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports)
stdio und Streamable HTTP; altes HTTP+SSE ist nicht mit sicherem HTTP-Betrieb
gleichzusetzen. Hier wird kein HTTP/SSE-Port angeboten. Die Fassade ist ein
kleiner getesteter Prototyp, kein allgemeiner Ersatz fuer ein vollstaendiges MCP-SDK.

## Gegenueber dem eingefuegten Entwurf korrigiert

### Volldurchlauf und zeitgestempelte Metadaten

`scripts/audio/run_full_song.py` ist der sichere Einstieg fuer einen vollstaendigen
**Plan**, nicht die Behauptung eines gerenderten Songs:

```bash
python3 -I -B scripts/audio/run_full_song.py config/audio_project.example.json
```

Das Beispiel waehlt `mix_profile: vocal_ducking_echo`: High-Pass, EQ,
Kompression, getrennte Sidechain via `asplit`, Echo auf dem Mixzweig und
Loudness-Vorschlag. Diese Presets sind keine Hoer-/Lautheitsabnahme; ein Echo ist
nicht automatisch ein hochwertiger Faltungshall. Freie Filterstrings der KI
werden abgelehnt. `mix_profile: dry` laesst diese Klangbearbeitung weg.

Optional einen **Planbericht** in einen vorhandenen privaten externen Ordner
exportieren. `GEPRUEFTER_PLAN_HASH` durch `plan_sha256` aus genau diesem Plan
ersetzen; es ist nur die Zustimmung zum Schreiben der Metadaten:

```bash
python3 -I -B scripts/audio/run_full_song.py config/audio_project.example.json \
  --export-report "$HOME/.openclaw_ultimate_user_data/audio_jobs" \
  --apply --confirm GEPRUEFTER_PLAN_HASH
```

Den Ordner vorher bewusst privat einrichten (unter Linux `0700`, unter Windows
geeignete Benutzer-ACL). Er wird nicht automatisch erzeugt, Repository-Ziele,
Symlinks/Junctions und vorhandene Dateinamen werden nicht ueberschrieben.
Dateinamen enthalten UTC-Zeit mit Mikrosekunden **und** zufaellige Lauf-ID;
sekundengenaue Zeitstempel alleine sind kein Kollisionsschutz. Publikation
erfolgt atomar und exklusiv; Temp-Dateien werden auch bei Fehlern entfernt.

Der Bericht enthaelt den Plan-Hash, Parameter, Vorgaben und eindeutig
`status: planned`, `executed: false`, `audio_generated: false`. Modell-Hashes und
Runtime-Versionen bleiben leer, solange keine echte Abnahme existiert. Es werden
keine WAV-/FLAC-Dateien oder Dummy-Instrumentals erzeugt. `--execute` endet mit
einem Fehler, bevor etwas startet. Keine Exportfunktion im MCP-Tool.
Berichte enthalten die selbst angegebenen Lyrics/Noten: privat und verschluesselt
sichern, vor einer Weitergabe pruefen. Parameter-JSON allein beweist noch keine
Reproduzierbarkeit ohne Quellen, Modell-Hashes, Binaerversionen und Eingangsdaten.

Die gepruefte [FFmpeg-Filterreferenz am Pin](https://github.com/FFmpeg/FFmpeg/blob/8105ae2afe2c4182a4ad44b1b9c45a3146f0c0b1/doc/filters.texi)
dient als Quelle fuer Filtergraph, Verzweigung und Loudness-Verfahren.

### Noch keine autonome Render-Freigabe

- `inference_webui.py` ist kein Nachweis eines batchfaehigen RVC-Aufrufs.
- Ein `.ust`/`.ustx` ist nicht automatisch ein DiffSinger-Inferenzmanifest:
  Phonemisierung, Alignment, Voicebank und Renderer muessen zusammenpassen.
- `openutau-cli render` und `openutau-compose` werden nicht erfunden oder als installiert gemeldet.
- Kein `ffmpeg -y`: Vorschlaege nutzen `-n` und feste Argumente; hier keine Ausfuehrung.
- `-16 LUFS` ist ein Projektziel, nicht das EBU-R128-Programmziel `-23 LUFS`.
  Produktiver Export erfordert gemessene Zwei-Pass-Normalisierung, True-Peak- und Hoerpruefung.
- Fremde Stimme/Referenz nur mit belegter Einwilligung und geeigneter Lizenz;
  keine Taeuschung, kein Training oder automatisches Veroeffentlichen.

## Tests und noch offene Abnahmen

```bash
python3 -B -m unittest discover -s tests -p test_local_audio_chain.py -v
python3 -B -m unittest discover -s tests -p test_native_github_tools.py -v
python3 -I -B scripts/quality/tool_ssh_docs.py
```

Offline-Tests mit gefaelschten Artefakten bzw. JSON-RPC-Nachrichten sind keine
echte Audio-Inferenz. Offen: Linux-/ARM-/GUI-Builds, lizenzierte Voicebanks,
GPU-Worker mit harten Grenzen, produktiver MCP-Client-Handshake, echtes Mixdown,
WAV-/FLAC-Qualitaet, Ressourcenmessung und Restore konsistenter Projekte.
Ein vollautonomer Prompt-zu-fertigem-Song-Workflow ist damit **noch nicht freigegeben**.

Modelle, Projektdateien und Caches bleiben im privaten Workspace, getrennt von
den Quellcheckouts. Fuer Wiederherstellung die vorhandenen verschluesselten
Backups nutzen; keine laufenden Modell-/Projektdateien inkonsistent sichern.

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
python3 -I -B scripts/tool_commands.py show ffmpeg
python3 -I -B scripts/tool_commands.py show openutau
python3 -I -B scripts/tool_commands.py show rvc
python3 -I -B scripts/tool_commands.py show seed_vc
python3 -I -B scripts/tool_commands.py show uvr5
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

### SSH-Aktionen: `ffmpeg`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action status
python3 -I -B scripts/tool_commands.py run ffmpeg --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action install --apply --confirm ffmpeg:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action update --apply --confirm ffmpeg:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run ffmpeg --action uninstall --apply --confirm ffmpeg:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

### SSH-Aktionen: `openutau`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`OpenUtau` (ID `openutau`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

### SSH-Aktionen: `rvc`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`RVC` (ID `rvc`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

### SSH-Aktionen: `seed_vc`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Seed_VC` (ID `seed_vc`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

### SSH-Aktionen: `uvr5`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`UVR5` (ID `uvr5`) waehlen und die Einzelfreigaben lesen.
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
