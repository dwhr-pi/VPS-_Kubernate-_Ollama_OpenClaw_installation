# Lokale Modelle, optionale Cloud und Wan

[VRAM/RAM-Offloading und Speicherplanung](../memory/UNIFIED_MEMORY_AND_OFFLOADING.md):
kein UMA-Umbau per Software; ComfyUI-Flags/Block-Swapping versionsabhaengig.

Quellenstand: 15.10.2026. Inaktiver Quellenkatalog:
[config/model_candidates.json](../../config/model_candidates.json).
Kein Modell wird daraus geladen, heruntergeladen oder automatisch geroutet.
`config/models.yaml` behaelt seine bisherigen Standardwerte.

## Modellfamilien unterscheiden

| Familie / Primaerquelle | Passender Einstieg | Lizenz-/Hardwaregrenze |
|---|---|---|
| [DeepSeek-R1](https://github.com/deepseek-ai/DeepSeek-R1) | kleiner Distill-Checkpoint fuer lokale Versuche | R1 MIT; Basis-/Distill-Bedingungen separat. Vollmodell nicht mit 7B-Distill gleichsetzen |
| [Qwen2.5-Coder-7B](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct) | lokales Coding-Beispiel, nicht automatisch neueste Generation | dieser Checkpoint Apache-2.0; nicht alle Qwen-Modelle gleich lizenziert |
| [Wan2.1](https://github.com/Wan-Video/Wan2.1) | kleine T2V-1.3B-Probe vor schwerem 14B-Pfad | Repo nennt Apache-2.0; Aufgabe/Checkpoint/Decoder einzeln pruefen |
| [GLM-5](https://huggingface.co/zai-org/GLM-5) | Server oder bewusst gewaehlte API | Gewichtskarte MIT, [Code](https://github.com/zai-org/GLM-5) Apache-2.0; kein 16-GB-Desktop-Standard |
| [Kimi K2.6](https://huggingface.co/moonshotai/Kimi-K2.6) | Server/optionale API, nicht kleines lokales Modell | Modified MIT und Third-Party Notices beachten; sehr grosses MoE |
| [Doubao / ByteDance](https://docs.volcengine.com/docs/ark?lang=zh) | optionaler Cloud-Dienst | keine pauschale offene Doubao-Gewichtsfreigabe verifiziert |

Open weights, offener Code, kostenloser Webchat und kostenlose API sind
verschiedene Dinge. Keine feste Monatskosten-Zusage, kein "0 Latenz".
Lokal kostet Strom/Hardware/Speicher; API-Kosten haengen von Tokenmenge,
Output/Reasoning, Kontext, Wiederholungen, Provider und gegebenenfalls GPU-Mietzeit ab.
[OpenRouter-Free-Pfade](https://openrouter.ai/support/) haben Kontingente und
Verfuegbarkeitsgrenzen; kein stiller Wechsel auf Bezahlmodelle.

## Welche Tools sind dazugekommen?

Die nachfolgenden Eintraege bleiben **planned/documentation-first**, ausser
Qwen_Code: dafuer gibt es jetzt einen ausdruecklich waehlbaren
[GitHub-Source-Installer ohne Docker](../tools/qwen-code.md).
Keine automatische Toolinstallation, Modelldownloads oder Agentenstarts.

| Tool / ID | GitHub | Rolle |
|---|---|---|
| Cline / `cline` | [cline/cline](https://github.com/cline/cline) | [Eigener GitHub-VSIX-Paketinstaller](../tools/cline.md), Editor-Installation separat; Aktionen einzeln freigeben |
| Qwen_Code / `qwen_code` | [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code) | CLI; [eigener Windows-Desktop-Einstieg](../tools/qwen-desktop-windows.md) separat |
| Wan21 / `wan21` | [Wan-Video/Wan2.1](https://github.com/Wan-Video/Wan2.1) | [Eigener GitHub-Quellinstaller](../tools/wan21.md), schwere GPU-Pakete separat; keine Gewichte/Renderjobs |
| ComfyUI_GGUF / `comfyui_gguf` | [city96/ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF) | [Eigener GitHub-Node-Installer](../tools/comfyui-gguf.md) fuer vorhandenes ComfyUI; keine Gewichte/Neustarts |
| WanVideoWrapper / `wanvideo_wrapper` | [kijai/ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper) | eigener Wan-Node-/Modellpfad |
| SUPIR / `supir` | [Fanghua-Yu/SUPIR](https://github.com/Fanghua-Yu/SUPIR) | [Eigene GitHub-Quellinstallation](../tools/supir.md); Runtime-Konflikt/Lizenz beachten, kein universeller Videorefiner |
| FILM / `film` | [google-research/frame-interpolation](https://github.com/google-research/frame-interpolation) | [Eigener GitHub-Quellinstaller](../tools/film.md); archivierter TensorFlow-Pfad, keine automatische Runtime |

RIFE, ComfyUI, Continue und Ollama sind schon registriert; keine Doppelinstallation.
Continue und Cline sind unterschiedliche Coding-Oberflaechen. Qwen Code hat
CLI und Desktop, Qwen Chat/Studio und QwenWork sind davon zu unterscheiden.
Alle Lizenzen/Gewichte, Nodes und Programme vor Produktivnutzung konkret pruefen.

Fuer die weiterhin geplanten Medienkandidaten gilt der gemeinsame Guard,
kein echter Installer. Cline hat inzwischen den oben verlinkten VSIX-Paketpfad,
Qwen Code einen [eigenen Source-Installer](../tools/qwen-code.md).
Wan21 hat ebenfalls einen eigenen [Source-/GPU-Paketpfad](../tools/wan21.md)
ohne Docker; sein Quellmarker ist kein vollstaendiger Modellfunktionstest.
ComfyUI-GGUF hat einen eigenen Node-Installer; er prueft die bestehende
ComfyUI-venv und benoetigt keine neue ComfyUI-/Docker-Installation.
SUPIR hat einen eigenen Source-only-Installer. Die Legacy-GPU-Laufzeit ist
wegen Paketkonflikten nicht freigegeben; kommerzielle Lizenzgrenzen beachten.
FILM hat einen eigenen Source-only-Installer ohne Docker. Der archivierte
TensorFlow-/CUDA-Pfad ist nicht automatisch als lauffertig eingerichtet.

```bash
bash scripts/tools/hybrid_media_candidate_install.sh --dry-run
```

Beim gemeinsamen Guard liefern Install/Update/Uninstall ohne Plan Exit-Code 2,
Checks nur Registrierungsstatus. Fuer dessen Medienkandidaten fehlen reale
Installer, Pins, Preflight und Smoke-Tests weiterhin.

## Wan-Grafik: Konzept, kein ausfuehrbarer Graph

Die beigefuegte Abbildung zeigt Basis-Generierung, Frameverarbeitung,
Tiled Refinement, Decoding, Interpolation und Export. Sie ist kein
importierbares ComfyUI-JSON und belegt weder konkrete Node-Kompatibilitaet
noch "24 GB+" als ausreichendes Hardwarebudget.

Wan 2.1 wird durch Upscaling/LoRA nicht zu einer neuen Wan-Generation.
LoRA muss zu Architektur, Checkpoint und Sampling-Schedule passen.
Wan2.2-Animate nicht blind auf Wan2.1 uebertragen.
"Video-CCSR", "CausalVid"/Lightning und generische Node-Namen ohne
eindeutige Upstream-/Versionsangabe bleiben ungeklaerte Kandidaten,
keine erfundenen installierbaren Abhaengigkeiten.

Sicherer Entwurf: kleine Basis-Sequenz -> Qualitaets-/Ressourcenpruefung ->
optionaler kompatibler Spatial-Refiner -> zeitliche Konsistenz pruefen ->
optionale RIFE/FILM-Interpolation -> Export mit Herkunft/Versionen.
Die [JSON-Vorlage](../../examples/hybrid_media/wan-refinement-plan.example.json)
ist ausdruecklich nur ein Plan, kein ComfyUI-Workflow.

8K-Export ist nicht dasselbe wie nativ generierte 8K-Quelldetails.
Generatives Refinement erfindet Details, es rekonstruiert keine belegte
Wirklichkeit. Hoehere Basis-Aufloesung ist nicht prinzipiell fuer jedes
Modell unmoeglich; Architektur, Training, Pipeline und Hardware entscheiden.
Hier gibt es keinen getesteten nativen 8K-Wan-Pfad.
Attention-Speicher nicht pauschal fuer jedes Modell als quadratisch zur
Pixelzahl ausgeben; Token-/Framezahl und Implementierung zaehlen.

Tiled VAE senkt vor allem Decoding-Spitzen, nicht automatisch den gesamten
Transformer-Bedarf. Tiled Bildverarbeitung kann Naehte/zeitliches Flackern
erzeugen. RIFE/FILM fuegen Zwischenbilder hinzu und sind keine garantierten
Deflicker-/Identitaets-/Physik-Korrekturen.

## GGUF, Wrapper und Ressourcen

Zuerst **einen** offiziellen Beispielworkflow fuer exakt gepinnte Versionen
auswaehlen: native ComfyUI/City96 oder Kijai-Wrapper.
Der Node-Ausgang `MODEL` ist nicht pauschal austauschbar mit allen
Wrapper-Modelltypen. Loader, Encoder, VAE und Sampler muessen zusammenpassen.
Modelldateinamen/-ordner und Block-Swap-Felder aus dem konkreten Beispiel
uebernehmen, nicht die vermischten Pseudonodes der Vorlage.

Mehr ausgelagerte Bloecke bedeuten nicht mehr im VRAM gehaltene Bloecke.
Feldsemantik vor Aenderung nachlesen. Keine allgemeine Empfehlung
"15-20 von 40", feste GGUF-Dateinamen oder Garantie "720p in 4-7 Minuten".
RTX-5080-/Blackwell-Unterstuetzung von Treiber, Torch und Attention-Kernels
pruefen. Quantisierung veraendert Qualitaet/Speicher, garantiert kein OOM-freies 14B.

Ein Job gleichzeitig, Kontext/Frames/Batch klein beginnen, reale SSD,
RAM/Swap, VRAM und Temp-/Frame-/Checkpointbedarf messen.
Modelle fuer Ollama und Video nicht unkontrolliert gleichzeitig resident halten.
GPU-Budget ist pro Pipeline zu messen, mehrere Karten bilden keinen
automatischen gemeinsamen Speicherpool.

## Windows/WSL/Ollama sicher betreiben

Nur Dokumentation, keine WSL-/Treiber-/Service-Aenderung:
[Microsoft-Konfiguration](https://learn.microsoft.com/windows/wsl/wsl-config).
`autoMemoryReclaim` gehoert unter `[experimental]`, nicht `[wsl2]`.
WSL-Swap ist kein zusaetzlicher VRAM. Nicht pauschal alle Kerne oder
48 GB zuweisen; Windows und andere Programme brauchen Reserve.
Ein WSL-Neustart beendet laufende Jobs, deshalb nie automatisch ausloesen.

[Ollama FAQ](https://docs.ollama.com/faq): fuer den gemeinsamen GPU-Host
zunaechst eine Anfrage/ein Modell planen und ungenutzte Modelle bewusst
entladen statt dauerhaft `KEEP_ALIVE=-1`. Kontexte/Parallelitaet brauchen
zusaetzlichen Speicher. `CUDA_VISIBLE_DEVICES` waehlt Geraete,
garantiert keine erfolgreiche GPU-Ausfuehrung.
`ollama ps`, [API /ps](https://docs.ollama.com/api/ps), Logs und GPU-Messung
gemeinsam betrachten; Dateigroesse oder ein einzelner Zahlenvergleich
beweist keine feste Gesamt-RAM-/VRAM-Aufteilung. Auch KV-Cache/Workspace beachten.

Open WebUI und Ollama vorzugsweise auf demselben Host mit privatem Zugriff.
Container-`localhost` ist nicht Host-`localhost`; keine
`OLLAMA_HOST=0.0.0.0`- oder oeffentliche Docker-Portfreigabe als Standard.
Host-Gateway, Docker Desktop, native Docker-Engine und WSL-Netzwerk sind
unterschiedliche Topologien. Diagnose erst planen, kein automatischer
Docker-/NVIDIA-Toolkit-/Linux-Treiber-Umbau.

## Integration / offene Aufgaben

OpenClaw/n8n nur als spaeterer strukturierter Adapter mit Freigaben,
Queue-Sperre, Timeout/Retry-Limit und echtem Budgetschutz.
Die Vorlagen erzwingen diese Limits noch nicht. Cloud, Downloads und
Publikation bleiben aus. Zuerst Dokumentation/kurzer lokaler Test,
danach bewusst ausgewaehlte Installationsschritte.
