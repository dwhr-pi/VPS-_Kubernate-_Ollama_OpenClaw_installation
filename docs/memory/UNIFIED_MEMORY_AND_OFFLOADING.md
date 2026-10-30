# Unified Memory, VRAM und Offloading im Ultimate KI Setup

[Colibri auf Letsung MiniPC und RTX 5080](../tools/colibri.md): SSD-Expert-Streaming separat von
Quantisierung bewerten, kein zusaetzlicher RAM.

Nach der Speicherplanung: [Leistung reproduzierbar messen](../tools/local-ai-benchmarks.md). Der
Speicherrechner liefert keine gemessenen Tokens/s.

**Zweck:** Groessere lokale Modelle sinnvoll planen, ohne RAM, VRAM und SSD-Speicher gleichzusetzen.
Software kann Teile einer Berechnung auslagern; sie verwandelt einen PC mit dedizierter Grafikkarte
**nicht in echte UMA**.

Stand: 20.10.2026, anhand der verlinkten Primaerquellen. Das RTX-5080-/16-GB-System ist dein
beschriebenes Beispiel, keine von uns ausgelesene Hardware. RAM, Treiber, WSL-Limits und freie
GPU-Kapazitaet sind nicht gemessen. Kein Modell, Treiber oder Dienst wird hier gestartet.

## 1. Drei verschiedene Konzepte

| Begriff                                        | Bedeutung                                                                   | Wichtige Grenze                                                        |
| ---------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Hardware-UMA / gemeinsamer physischer Speicher | CPU und integrierte GPU koennen einen gemeinsamen Speicherpool verwenden    | Pool ist endlich; Betriebssystem/Programme brauchen ebenfalls Speicher |
| Managed / Unified Virtual Memory               | Programmierschnittstelle und Speichermanagement fuer geeignete Allokationen | Kein universeller OOM-Ausweichmechanismus fuer jede Anwendung          |
| Explizites CPU-/GPU-/Disk-Offloading           | Framework verteilt oder verschiebt Modellteile                              | PCIe-/RAM-/SSD-Transfers und ggf. CPU-Rechenzeit kosten Leistung       |

Ein gemeinsamer virtueller Adressraum ist nicht automatisch gemeinsamer physischer Speicher oder
dieselbe Bandbreite. Auch UMA-Anwendungen koennen Daten intern kopieren. Aufruestbarkeit haengt vom
konkreten Geraet ab: Viele Apple-Silicon-Systeme haben nicht nachruestbaren Speicher, aber "UMA ist
immer verloetet" ist keine allgemeine Architektureigenschaft.

## 2. Wie heissen die Herstellerloesungen?

### NVIDIA: CUDA Unified Memory

CUDA Unified Memory bietet verwaltete Speicherzugriffe, je nach GPU/Plattform mit Migration und
Ueberbelegung. Anwendung, Allokation und Faehigkeitsabfragen muessen dazu passen. Normale
CUDA-Allokationen werden nicht automatisch bei jedem OOM beliebig in System-RAM umgewandelt. UVA und
Unified Memory nicht gleichsetzen.
[CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-programming-guide/04-special-topics/unified-memory.html)

**Besonders wichtig fuer WSL2:** NVIDIA dokumentiert dort fehlende volle
Managed-Memory-Unterstuetzung und weitere Grenzen, etwa bei gleichzeitigem CPU-/GPU-Zugriff und
gepinntem Hostspeicher. Native Linux-Eigenschaften nicht ungeprueft auf Windows/WSL uebertragen.
Keinen Linux-NVIDIA-Treiber in WSL "zur Reparatur" installieren.
[CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)

### AMD: ROCm / HIP Managed Memory und HMM

HIP bietet unter anderem `hipMallocManaged`; Linux HMM und unterstuetzte Geraete/Treiber
beeinflussen Migration und Zugriff. ROCm ist nicht ein allgemeiner NVIDIA-VRAM-Erweiterer. Nicht
jede Radeon, jedes Betriebssystem oder jede HIP-Allokation hat dieselben Eigenschaften. Die
dokumentierten Architektur-/Systemtabellen pruefen, keine globalen Kernel-/XNACK-Schalter blind
setzen.
[AMD Unified Memory](https://rocm.docs.amd.com/projects/HIP/en/latest/how-to/hip_runtime_api/memory_management/unified_memory.html)

### Apple: Apple Silicon UMA und Metal

CPU/GPU nutzen einen gemeinsamen physischen Pool; Metal hat dazu passende Ressourcen-Speichermodi.
Nicht den gesamten installierten RAM als garantiert frei verfuegbares GPU-Budget ansetzen.
OS-Budget, App-Nutzung und modell-/frameworkspezifische Limits beruecksichtigen.
[Apple Metal](https://developer.apple.com/documentation/metal/choosing-a-resource-storage-mode-for-apple-gpus)

**Keine dieser Architekturen wird durch einen Installer nachgeruestet.** CUDA/ROCm/Metal sind hier
Dokumentationsthemen, keine neuen automatisch installierten Setup-Treiber.

## 3. Was bedeutet das fuer Speicherbedarf?

Untergrenze fuer reine dichte Gewichte:

```text
Bytes = Gesamtparameterzahl * Bits_pro_Parameter / 8
GiB   = Bytes / 1.073.741.824
```

| Parameterzahl  | Nur rohe Gewichte bei exakt 4 Bit |
| -------------- | --------------------------------- |
| 8 Milliarden   | ca. 3,73 GiB                      |
| 14 Milliarden  | ca. 6,52 GiB                      |
| 32 Milliarden  | ca. 14,90 GiB                     |
| 70 Milliarden  | ca. 32,60 GiB                     |
| 120 Milliarden | ca. 55,88 GiB                     |

Das sind **keine Lauffaehigkeitszusagen** fuer Q4_K_M oder andere reale Formate.
Quantisierungsmetadaten, unterschiedlich quantisierte Tensoren, KV-Cache, Aktivierungen,
Kontextlaenge, parallele Requests, Ladepeaks und CPU/GPU-Duplikate kommen hinzu. Bei MoE zaehlen
fuer die Gewichtsablage die gespeicherten Gesamtparameter, nicht nur aktive Parameter pro Token.

64 oder 128 GiB RAM koennen Offloading ermoeglichen, garantieren aber weder eine bestimmte
Modellgroesse noch angenehme Geschwindigkeit. Keine feste Zusage "20 bis 30 Layer passen auf 16 GB":
Layergroessen, GPU-Belegung und Backend unterscheiden sich. GB und GiB sauber auseinanderhalten.
SSD/Swap sind kein gleich schneller RAM-Ersatz; Thrashing kann das System praktisch unbenutzbar
machen.

## 4. Neuer Offline-Speicherrechner

Ohne Installation direkt im Setup-Checkout, mit vorhandenem Python 3.10+:

```bash
python3 -B scripts/memory/offload_plan.py --parameters-b 70 --bits 4 --ram-gib 64 --vram-gib 16
```

Natives Windows, ohne WSL:

```powershell
py -3 -B scripts/memory/offload_plan.py --parameters-b 70 --bits 4 --ram-gib 64 --vram-gib 16
```

Er berechnet Gewichtsbudgets aus **deinen Eingaben**, keine Hardwareerkennung. Standardannahmen: 15
Prozent Gewichts-Overhead, 8 GiB RAM- und 2 GiB VRAM-Reserve. Diese Werte sind veraenderbar, keine
Messwerte oder ausreichende KV-Cache-Garantie. `runtime_guaranteed` bleibt immer `false`.

Fuer einen echten gemeinsamen Pool nicht RAM und GPU-Budget addieren:

```bash
python3 -B scripts/memory/offload_plan.py --parameters-b 70 --bits 4 --ram-gib 64 --mode unified
```

In diesem Modus wird der Pool nur einmal gezaehlt. Das simuliert keine Treiberfaehigkeiten. Keine
Modell-Downloads, Telemetrie, Secrets, Datei- schreiboperationen oder Aenderungen an
WSL/Swap/Treibern durch den Rechner.

## 5. Welche vorhandenen Tools nutzen?

| Tool                           | Sinnvoller Ansatz                                                                                | Nicht behaupten                                                |
| ------------------------------ | ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| Ollama                         | Vorhandenes Modell, kleine Kontext-/Parallelitaetsbudgets, Belegung pruefen                      | Jede Modellgroesse laufe fluessig in Swap                      |
| llama.cpp                      | Quantisierung und kontrolliertes Layer-Offloading                                                | VRAM/RAM seien physisch vereinigt                              |
| ComfyUI                        | Versionspassende Speicherverwaltung, kleine Aufloesung/Framezahl, VAE-Tiling bei passenden Nodes | `--highvram` spare VRAM oder jedes Flag wirke in jeder Version |
| ComfyUI_GGUF / WanVideoWrapper | Bereits vorhandene Erweiterungen gezielt pruefen                                                 | Ein Plugin garantiere die Ausfuehrbarkeit jedes Wan-Modells    |
| HF_Accelerate                  | Modellgewichte/Dispatch in passenden Python-Workflows                                            | `device_map` sei eine universelle PyTorch-Tensoroption         |
| DeepSpeed                      | Fortgeschrittene, modell-/backendabhaengige Offload-Pipelines                                    | ZeRO-Inference sei ein systemweiter UMA-Schalter               |

Ollama und llama.cpp nicht doppelt registriert. Bestehende Installationspfade und Statusangaben
bleiben unveraendert. [llama.cpp](https://github.com/ggml-org/llama.cpp),
[Ollama FAQ](https://docs.ollama.com/faq),
[Wan-/ComfyUI-Einordnung](../media_studio/HYBRID_MODELS_AND_WAN.md).

### LLMs: kontrolliert statt maximale Modellgroesse

Zuerst mit einem bereits vorhandenen kleinen Modell und einem einzelnen Request testen. Kontext
klein halten, danach GPU-Offload schrittweise messen. Bei llama.cpp definiert die installierte
Version die akzeptierten `--n-gpu-layers`-/Kontextoptionen; vor Nutzung deren Hilfe pruefen.
[Argumentquelle](https://github.com/ggml-org/llama.cpp/blob/master/common/arg.cpp)

Bei Ollama die konkrete Runtime-Version und unterstuetzte Optionen pruefen, statt `num_gpu` als
zeitlosen, ueberall gleich wirkenden UMA-Schalter zu dokumentieren. `ollama ps` kann bei einem
bereits laufenden Server die aktuelle CPU/GPU-Aufteilung zeigen; es ist kein Modellbenchmark. Keine
fremden Modelle automatisch ziehen.

### ComfyUI / Wan: Versionen machen einen Unterschied

Der aktuelle
[ComfyUI-Argumentparser](https://github.com/Comfy-Org/ComfyUI/blob/master/comfy/cli_args.py)
beschreibt DynamicVRAM und asynchrones Offloading. Dort hat `--lowvram` bei aktivem DynamicVRAM
keine Wirkung; `--highvram` haelt Modelle eher im GPU-Speicher. Alte Anleitungen nicht blind auf
neue Releases anwenden.

Tiled VAE reduziert bestimmte Aktivierungsspitzen, ersetzt aber nicht den Speicher des gesamten
Diffusionsmodells. Block-Swapping/Tiled-Diffusion sind workflow-/implementierungsabhaengig. Mit
wenigen Frames, kleiner Aufloesung, Batch 1 und einem Job beginnen; jeweils Zeit, RAM/VRAM und
Bildqualitaet messen. Preview-Dienste weiterhin nur auf Loopback binden.

## 6. Neue optionale GitHub-Quellinstaller

| Setup-Tool    | GitHub-Pin                                                       | Lizenz     | Umfang                                                     |
| ------------- | ---------------------------------------------------------------- | ---------- | ---------------------------------------------------------- |
| HF_Accelerate | huggingface/accelerate: abe3749c6274b2ffc9a99cc57ca72ff8bca72ab8 | Apache-2.0 | Gepruefter Quellcheckout, keine Python-Paketinstallation   |
| DeepSpeed     | deepspeedai/DeepSpeed: 3133d9d689a67ab1d4feebf8166f19ee28cace6a  | Apache-2.0 | Gepruefter Quellcheckout, keine nativen Extensions/Runtime |

```bash
bash scripts/tools/hf_accelerate_install.sh --dry-run
bash scripts/tools/deepspeed_install.sh --dry-run
# Erst bewusst fuer den ausgewaehlten Quellbestand:
bash scripts/tools/hf_accelerate_install.sh
bash scripts/tools/deepspeed_install.sh
```

Voraussetzungen: vorhandenes Python/Git, 1 GiB freie Disk-Reserve je Checkout sowie die gemeinsame
RAM-/Hostspeicher-Vorpruefung. Das Tools-Menue kann vorher strengere allgemeine Reserven verlangen.
Nicht innerhalb des Setup-Repos installieren. Daten unter dem externen User-Workspace in
`tools/hf_accelerate/source/` und `tools/deepspeed/source/`.

Installer haben Dry-Run, Check/Doctor, Status, Update, Reparatur und Deaktivierung. Je Tool ein
Lock, eindeutige aktuelle Logs, Speicherstand vorher/nachher, Erfolgsmarker erst nach Pruefung,
keine fremden Reset-/Loeschaktionen. Update bleibt am Pin. Keine Upstream-Skripte werden beim
Checkout ausgefuehrt.

**Installiert im Menue bedeutet Quellvorbereitung, nicht nutzbare Inferenz.** Der Marker und die
Statusausgabe sagen `runtime_ready=false`. Ein importierbares Python-Paket,
Torch/CUDA-/ROCm-Kompatibilitaet, native Extensions und Modell-Integration brauchen einen separaten,
bewusst geprueften Runtime-Schritt in einer isolierten Umgebung. Der Accelerate-Pin ist ein
Entwicklungsstand, kein versprochenes stabiles Release.

```bash
bash scripts/tools/hf_accelerate_doctor.sh
bash scripts/tools/deepspeed_status.sh
bash scripts/tools/hf_accelerate_update.sh
bash scripts/tools/deepspeed_install.sh --repair
bash scripts/tools/hf_accelerate_uninstall.sh
bash scripts/tools/deepspeed_uninstall.sh
```

Deinstallation deaktiviert nur die Setupregistrierung; Quellen, Logs und eventuell separat
installierte Runtimepakete bleiben. Ein spaeteres Loeschen erst nach Backup und Pruefung anderer
Verbraucher. Keine Shared-Dependencies, Modelle oder Trainingsdaten automatisch entfernen.

### Accelerate und DeepSpeed fachlich einordnen

`device_map="auto"` gehoert zu passenden Hugging-Face-Lade-/Dispatch-Funktionen, nicht zu beliebigem
PyTorch-Code. Accelerate kann Gewichte auf GPU, CPU und ggf. Disk platzieren; naechster
Rechenschritt und Transfers koennen trotzdem zusaetzlichen Speicher beanspruchen.
[Big Model Inference](https://huggingface.co/docs/accelerate/usage_guides/big_modeling),
[Grenzen/Mechanik](https://huggingface.co/docs/accelerate/concept_guides/big_model_inference).

DeepSpeed ZeRO-Inference beschreibt Auslagern und Nachladen von Gewichten, nicht dieselbe
Architektur wie Apple UMA. Training-ZeRO, Inferenz und die konkreten Offload-Backends nicht
verwechseln. Es ist eine Spezialoption, nicht der erste Reparaturschritt fuer einen kleinen PC.
[DeepSpeed-Quelle](https://github.com/deepspeedai/DeepSpeed),
[ZeRO-Inference-Konzept](https://www.deepspeed.ai/2022/09/09/zero-inference.html).

## 7. Vorgehen fuer dein beschriebenes System

1. Vorhandene RAM-/VRAM-/WSL-Budgets selbst erfassen; keine Hardwaredaten aus Modellnamen erraten.
   Windows-Host-Disk getrennt vom freien WSL-Mount betrachten.
2. Ein kleineres vorhandenes quantisiertes Modell als Ausgangspunkt nutzen.
3. Rechner mit echten Eingabebudgets verwenden; KV-Cache und Ladepeaks extra planen.
4. Nur einen LLM-/Videojob gleichzeitig testen, GPU nicht mit mehreren Modellservern/ComfyUI-Workern
   gleichzeitig volllegen.
5. Kontext/Frames/Batches reduzieren, bevor Swap oder experimentelle Frameworks als Allheilmittel
   eingesetzt werden.
6. Bei OOM stoppen und aktuellen Log sichern, nicht endlos neu probieren. Ergebnisse, maximalen
   Speicher und Durchsatz fuer den konkreten Workflow messen.

Keine automatische Aenderung an `.wslconfig`, Pagefile, Swap, Treibern, Kernel-/BIOS-Optionen oder
GPU-Limits. [Queue](../CODEX_TASK_QUEUE.md) und [Ressourcenplanung](../QUEUE_AND_RESOURCE_LIMITS.md)
statt unkontrollierter Parallelitaet nutzen. Keine API-Keys erforderlich, keine
Cloud-Anfragen/Modellstarts durch diese Erweiterung.

## 8. Zielhosts und Spiele

| Zielklasse                  | Einordnung                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| MiniPC / RPi5               | CPU-/iGPU-Budgets und Bandbreite begrenzen; dedizierten VRAM nicht voraussetzen             |
| Windows / WSL2              | Host-RAM, WSL-Zuweisung, GPU und Host-Disk getrennt; UVM-Grenzen beachten                   |
| Oracle VPS                  | CPU-only moeglich; GPU/RAM nie aus Anbietername ableiten                                    |
| Gaming-PC / RTX-Workstation | Dedizierter VRAM plus RAM-Offload, kein kostenloser UMA-Umbau                               |
| Dual Xeon                   | Viel RAM bedeutet nicht hohen Einzelanfrage-Durchsatz; NUMA/Bandbreite mitmessen            |
| Kubernetes                  | Pod-Limits und GPU-Zuweisung sind zusaetzliche Grenzen; kein automatischer Cluster-RAM-Pool |
| Apple Silicon               | Gemeinsamen Pool nur einmal budgetieren, GPU-Arbeitsbudget der Plattform beachten           |

UMA kann auch Spiele betreffen. GPU-Leistung, Bandbreite, API, Treiber, Aufloesung und Portierung
bleiben entscheidend. Nicht pauschal behaupten, Apple-RAM habe immer schlechtere Latenz oder ein
kleinerer dedizierter VRAM fuehre zwangslaeufig zum Absturz. Windows-Anzeige "gemeinsam genutzter
GPU-Speicher" ist kein gleichwertiger GDDR-Ersatz; Offloading verspricht keine zusaetzlichen FPS.

Zurueck zum [Tool-Index](../TOOL_INDEX.md).
