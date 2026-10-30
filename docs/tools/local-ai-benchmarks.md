# Lokale KI-Leistung messen und vergleichen

**Zweck:** Das eigene Setup reproduzierbar messen, Engpaesse erkennen und Vorher-/Nachher-Ergebnisse
sauber vergleichen. Es gibt keinen universellen "KI-Gesamtscore" und keine belastbare Umrechnung von
3DMark/Cinebench in Tokens/s. Quellenstand: 20.10.2026. Hier wurden keine Hardwarewerte gemessen.

## 1. Welche Messwerte brauchst du?

| Messwert                | Bedeutung                                            | Nicht verwechseln mit                               |
| ----------------------- | ---------------------------------------------------- | --------------------------------------------------- |
| Prefill / PP, Tokens/s  | Verarbeiten tatsaechlich ausgewerteter Eingabetokens | Gesamter Anfragezeit oder ungecachedem Referenzwert |
| Decode / TG, Tokens/s   | Erzeugen ausgegebener Tokens                         | Woertern/s oder Antwortqualitaet                    |
| TTFT                    | Zeit bis zum ersten relevanten Ausgabetoken          | Ladezeit oder Durchschnitt aller Tokens             |
| Gesamtdauer / Wall Time | Vom Client gemessene komplette Anfrage               | Reiner Kernel-/Modellrechenzeit                     |
| Load Time               | Berichtete Modell-Ladephase                          | Garantiert kaltem Betriebssystem-/Dateicache        |
| RAM-/VRAM-Spitze        | Ressourcenverbrauch des konkreten Laufs              | Installiertem Gesamtspeicher                        |
| Qualitaetsmessung       | Korrektheit/Nutzwert auf definierten Aufgaben        | Geschwindigkeit                                     |

Die Anzahl der Woerter in einem frei generierten 500-Woerter-Text ist kein Tokenzaehler. Tokenizer,
Sprache, Modell und vorzeitiges Ende beeinflussen die Arbeit. Ein grosser Score beweist nicht, dass
ein Modell passende Antworten liefert. Qualitaetstests getrennt dokumentieren; das vorhandene
LM_Evaluation_Harness nicht ungeprueft mit Cloud-Providern starten.

## 2. Ein Vergleichsprotokoll festlegen

Vor jedem Test festhalten:

- CPU, GPU, verfuegbarer RAM/VRAM, Betriebssystem und nativ oder WSL2.
- Runtime-/Build-Commit, Treiber-/Backendversion und CPU/GPU-Offload-Aufteilung.
- Exakte Modelldatei/Modell-Digest, Quantisierung, Tokenizer und Lizenz.
- Eingabetokenlaenge, Kontexttiefe/KV-Cache, Ausgabetokens, Batch/Parallelitaet.
- Sampling/Seed/Reasoning-Modus, Warmup, Repetitionen und Cachezustand.
- Temperatur-/Leistungszustand, Hintergrundlast, Stromversorgung und Fehler.

Gleiche Konfiguration mindestens dreimal messen, Einzelwerte und Streuung aufbewahren. Warm- und
Kaltstart getrennt auswerten. Ein Seed ist keine Garantie bitgleicher Ergebnisse auf jeder Hardware.
Nur eine Einstellung pro Vergleich veraendern. Andere GPU-/Modelljobs bewusst pausieren; unser Lock
kann fremde Clients nicht am Starten hindern. Siehe
[Ergebnisvorlage](../benchmarks/RESULT_TEMPLATE.md).

LLM-Decode bei kleiner Batch ist oft bandbreitenempfindlich, Prefill kann staerker rechenlimitiert
sein. Das heisst nicht, dass fuer jedes Token die komplette Modelldatei ueber PCIe kopiert wird.
GPU-Residenz, MoE, Quantisierung, Backend und Kontext spielen mit.
[Speicherplanung und Offloading](../memory/UNIFIED_MEMORY_AND_OFFLOADING.md).

## 3. llama-bench: das vorhandene llama.cpp gezielt nutzen

`llama-bench` ist ein Werkzeug in [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp). Keine
zweite llama.cpp-Installation noetig, wenn dein vorhandener Build das Benchmark-Binary bereits
enthaelt. Es wird hier nicht als eigenstaendiger neuer Modellserver registriert.

Wenn du bewusst aus einem vorhandenen geprueften GitHub-Checkout bauen willst, zunaechst CPU-only
und mit vorhandenen Buildwerkzeugen:

```bash
# Im freigegebenen llama.cpp-Quellordner, vorab Disk/RAM pruefen:
cmake -S . -B build-bench -DGGML_CUDA=OFF
cmake --build build-bench --target llama-bench --config Release -j 2
```

Das ist eine manuelle Build-Anleitung, kein automatisch ausgefuehrter Installer. Fuer
CUDA/Metal/Vulkan gelten die jeweiligen Build-/Hardwarevoraussetzungen. Keine Treiber oder Toolkits
automatisch nachinstallieren. Version und Hilfe deines konkreten Binaries pruefen.

Ein kleiner bewusst gestarteter CPU-Test mit **bereits vorhandener** GGUF-Datei:

```bash
./build-bench/bin/llama-bench -m /absoluter/pfad/modell.gguf -p 512 -n 128 -r 3 -ngl 0 -t 4 -o json
```

Windows-Binaries koennen in einem zusaetzlichen Release-Unterordner liegen. Ergebnisse im externen
Benutzer-Workspace speichern, nicht im Setup-Repo. Anschliessend GPU-Layer nur kontrolliert
variieren, statt blind alles auszulagern.

`-m` waehlt eine vorbereitete Modelldatei; llama-bench quantisiert das Modell nicht bei dieser
Messung. PP, TG und Kontexttiefe sind unterschiedliche Workloads. Die Messung schliesst laut
Upstream Tokenisierung und Sampling nicht ein und ist daher nicht identisch mit einer
HTTP-/Frontend-Zeit.
[Syntax, Statistik und JSON-Ausgabe](https://github.com/ggml-org/llama.cpp/blob/master/tools/llama-bench/README.md).

## 4. Neuer Ollama-Benchmark-Helfer

Datei: `scripts/benchmarks/ollama_benchmark.py`, Python 3.10+, nur Standardbibliothek.

### Standard: Nur Plan, kein Netzwerk und keine Inferenz

```bash
python3 -B scripts/benchmarks/ollama_benchmark.py ollama --model DEIN_MODELL:TAG
```

### Messung ausdruecklich freigeben

Nur mit eigenem laufenden lokalen Ollama-Server und bereits vorhandenem Modell:

```bash
python3 -B scripts/benchmarks/ollama_benchmark.py ollama --model DEIN_MODELL:TAG --execute --confirm-local-model
```

Natives Windows ohne WSL mit vorhandenem Python:

```powershell
py -3 -B scripts/benchmarks/ollama_benchmark.py ollama --model DEIN_MODELL:TAG
# Erst nach eigener Freigabe:
py -3 -B scripts/benchmarks/ollama_benchmark.py ollama --model DEIN_MODELL:TAG --execute --confirm-local-model
```

Was der Helfer macht:

1. Ohne `--execute` ausschliesslich einen Plan ausgeben, ohne Dateischreiben.
2. Nur direkte HTTP-Adressen `127.0.0.1` oder `[::1]` akzeptieren. Keine URL-Credentials, Pfade,
   Umgebungsproxies oder Redirects.
3. Vor der Messung `/api/tags` abfragen: exakter vorhandener Modellname und Digest erforderlich;
   kein Pull-Endpunkt. Offensichtliche Cloud-Namen und bekannte Remote-Felder ablehnen.
4. Mit festem nichtvertraulichem Prompt, Kontext 2048, Temperatur 0, Seed 42 und maximal 128
   Ausgabetokens pro Request messen.
5. Standardmaessig ein Warmup und drei **sequentielle** Messungen. Maximal zehn Messungen und ein
   Warmup, kein Retry bei Fehlern.
6. Private JSON-Berichte unter `~/.openclaw_ultimate_user_data/benchmarks/ollama/` anlegen. Keine
   rohen Prompts, Antworten, Zugangsdaten oder ENV-Dumps speichern.

Ein Lock begrenzt diesen Helfer im selben Workspace auf einen Lauf. Freie Disk fuer Berichte wird
geprueft; die Einhaltung des Modell-RAM-/VRAM- Budgets muss vorher anhand des konkreten Modells
geprueft werden. Die URL-Pruefung beweist nicht, dass eine beliebige lokal betriebene Proxy- oder
modifizierte Runtime garantiert nie weiterleitet. Deshalb das eigene lokale Backend mit
`--confirm-local-model` ausdruecklich bestaetigen.

Optionen: `--runs 1..10`, `--warmups 0|1`, `--num-predict 1..512`, `--timeout 1..300` Sekunden pro
HTTP-Aufruf. Bei OOM/Timeout stoppen; der Server kann nach Client-Timeout noch arbeiten. Keine
fremden Prozesse automatisch beenden. Das Modell wird mit `keep_alive=1m` angefordert und kann nach
der Messung kurz im Speicher bleiben; kein globales Server-Tuning.

### Kennzahlen und Grenzen

Ollama liefert Dauern in Nanosekunden. Berechnung:

```text
PP Tokens/s = prompt_eval_count / prompt_eval_duration * 1.000.000.000
TG Tokens/s = eval_count        / eval_duration        * 1.000.000.000
```

Es werden tatsaechliche Zaehler verwendet, nicht pauschal die angeforderten 128 Tokens.
Fehlende/ungueltige Zaehler erzeugen einen Fehler statt erfundener Messwerte. Null Token und Null
Dauer ergeben keinen messbaren Durchsatz.

Der Helfer benutzt `stream=false`: **TTFT wird nicht gemessen**. Er weist dies mit
`ttft_measured=false` bzw. `ttft_seconds=null` aus. Gleicher Prompt kann Server-Caches treffen; der
PP-Wert ist deshalb keine Garantie eines ungecacheten Prefill-Benchmarks. Median und Min/Max werden
aus den gueltigen Einzelwerten gebildet.
[Ollama Generate API](https://docs.ollama.com/api/generate).

### Bereits gespeicherte Antwort offline auswerten

```bash
python3 -B scripts/benchmarks/ollama_benchmark.py analyze /pfad/antwort.json
```

Die Eingabedatei muss eine abgeschlossene Ollama-Generate-JSON-Antwort enthalten, keinen
NDJSON-Stream und keinen Chatverlauf. Sie wird begrenzt eingelesen; Antworttext wird nicht in der
Auswertung wiedergegeben. Keine Netzwerkverbindung in diesem Modus. Echte gespeicherte
Antwortdateien koennen vertrauliche Inhalte enthalten: nicht im Repo ablegen oder hochladen.

## 5. Neues optionales Tool: Hyperfine

[Hyperfine](https://github.com/sharkdp/hyperfine) misst wiederholt die Laufzeit von CLI-Befehlen und
kann Ergebnisse exportieren. Es ist kein Tokenzaehler und misst auch Prozessstart,
Shell-/Client-Overhead und ggf. Modell-Ladezeit. Die ausgewaehlten Befehle werden wirklich
ausgefuehrt, einschliesslich ihrer Nebenwirkungen.

Setup-Eintrag **Hyperfine**: gepinnter GitHub-Quellcheckout
`c5161524980522320c7d3425e714cc0965a869a5`, MIT OR Apache-2.0.

```bash
bash scripts/tools/hyperfine_install.sh --dry-run
bash scripts/tools/hyperfine_install.sh
bash scripts/tools/hyperfine_doctor.sh
bash scripts/tools/hyperfine_status.sh
bash scripts/tools/hyperfine_update.sh
bash scripts/tools/hyperfine_uninstall.sh
```

**Standard nur Quellen, noch keine gebaute CLI.** Vorhandenes Git/Python und 1 GiB Disk-Reserve
genuegen fuer den Checkout; Tools-Menue-Guards koennen strenger sein. Lock, eindeutige Logs und
Marker erst nach Quellpruefung. Update behaelt den Pin, keine Reset-/Latest-Aktion. Die
Deinstallation deaktiviert die Setupregistrierung; Quellen und Logs bleiben.

Ein separater manueller Build im externen Quellordner ist moeglich:

```bash
# Rust-/Cargo-Voraussetzung vorher anhand Cargo.toml pruefen:
cargo build --release --locked --jobs 2
```

Am Pin verlangt
[Cargo.toml](https://github.com/sharkdp/hyperfine/blob/c5161524980522320c7d3425e714cc0965a869a5/Cargo.toml)
Rust mindestens 1.97.0. Kein automatischer Rust-Bootstrap oder Cargo-Build. Crates kommen aus
Paketregistries; der Tool-Quellcode kommt aus GitHub. Keine Docker-Installation. Source-Build und
echte Benchmarks wurden hier nicht getestet.

## 6. Klassische PC-Benchmarks richtig einordnen

| Werkzeug / Bereich          | Sinn                                    | Grenze im Setup                                                   |
| --------------------------- | --------------------------------------- | ----------------------------------------------------------------- |
| AIDA64 Memory               | RAM-Bandbreite/Latenz im konkreten Test | Proprietär; kein direkter LLM-Score, hier kein Installer          |
| Geekbench CPU               | Eigene standardisierte CPU-Workloads    | Kein Token/s-Ersatz; Version/Teiltest angeben                     |
| Cinebench                   | Rendering-Arbeitslast                   | Keine mathematische LLM-Umrechnung                                |
| 3DMark                      | Definierte Grafik-/Gaming-Arbeitslasten | Kein verlässlicher Tensor-Core-/LLM-/Wan-Geschwindigkeitsnachweis |
| Procyon AI Text Generation  | Standardisierte Textgenerierungs-Suite  | Nur gleiche Suite/Version/Scorebasis vergleichen                  |
| Procyon AI Image Generation | Separater Bildgenerierungs-Test         | Nicht mit Text- oder Videoerzeugung gleichsetzen                  |
| Procyon Computer Vision     | Bild-/Videoanalyse-Workloads            | Der historische Name AI Inference ist kein universeller LLM-Test  |

Procyon ist eine kommerzielle Suite, kein hier von GitHub installiertes Tool. Nicht als "bester
universeller Brueckenbenchmark" ausgeben.
[Text Generation](https://benchmarks.ul.com/procyon/ai-text-generation-benchmark),
[Computer Vision](https://benchmarks.ul.com/procyon/ai-computer-vision). Tests, Backends,
Modellqualitaet und Versionen bestimmen die Aussagekraft, nicht nur ein isolierter Punktwert.

XMP/EXPO, Uebertaktung oder BIOS-/NUMA-Aenderungen sind keine automatische Benchmark-Voraussetzung.
Keine Treiber-, Swap-, Pagefile- oder WSL-Aenderungen durch diese Erweiterung. WSL nutzt den
passenden Windows-GPU-Treiberpfad; keinen Linux-GPU-Treiber blind in WSL installieren.

## 7. Video-/Bildmessungen und Zielhosts

Bei ComfyUI/Wan exakt denselben Workflow-Export, Modelle, Seed, Aufloesung, Frames, Sampler,
Schritte, VAE-Tiling und Batch verwenden. Ladephase getrennt von Generierungszeit, GPU-/RAM-Spitzen
und Qualitaet beachten. LLM-Tokens/s sagen keine Video-FPS voraus.

| Zielklasse                  | Vergleichsregel                                                                 |
| --------------------------- | ------------------------------------------------------------------------------- |
| MiniPC / RPi5               | Erst kleines vorhandenes Modell, CPU-Threads und Speicherbudget notieren        |
| WSL2 / natives Windows      | Als getrennte Konfigurationen messen; WSL-RAM und Host-Disk beachten            |
| Oracle VPS / Dual Xeon      | vCPU-/NUMA-/Speicherlimits und fremde Hostlast dokumentieren                    |
| Gaming-PC / RTX-Workstation | GPU-Backend, Offload, thermischen Zustand und Hintergrundlast festhalten        |
| Kubernetes                  | Pod-Limits/GPU-Zuweisung angeben, nicht mit unbegrenztem Bare-Metal verwechseln |

Vor Lasttests [Speicherplanung](../memory/UNIFIED_MEMORY_AND_OFFLOADING.md) und
[Queue](../CODEX_TASK_QUEUE.md) verwenden. Kein automatischer Dauerlasttest, keine Garantie
bestimmter Tokens/s, keine Rangliste aus erfundenen Messwerten. Zurueck zum
[Tool-Index](../TOOL_INDEX.md).
