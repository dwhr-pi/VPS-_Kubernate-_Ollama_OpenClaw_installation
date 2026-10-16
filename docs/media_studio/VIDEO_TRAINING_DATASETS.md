# Video-Trainingsdaten von Hugging Face

Quellenstand: 14.10.2026. **Ja: Hugging Face hostet Video-Datensaetze,
Metadaten und Modellgewichte.** GitHub hostet haeufig den Verarbeitungscode.
Diese Anleitung installiert nichts und startet keine WSL, Downloads oder Trainings.

## 1. Was brauche ich wirklich?

- **Video erzeugen (Inferenz):** passendes Modell und dessen Gewichte.
  Ein Trainingsdatensatz ist dafuer normalerweise nicht erforderlich.
- **Eigenen Stil oder ein Motiv lernen (Fine-Tuning/LoRA):** ein kleiner,
  sorgfaeltig kuratierter und autorisierter Datensatz plus passender Trainer.
- **Ein Basismodell neu trainieren:** sehr viel mehr Daten, Rechenzeit und
  Infrastruktur; kein sinnvoller erster Schritt auf einem MiniPC.
- **Videos verstehen/analysieren:** multimodale Annotationen oder
  Frage-Antwort-Daten, nicht zwingend ein Text-to-Video-Trainingsformat.

Ein Datensatz ist kein Modell und keine Softwareinstallation. Die HF-Suche
nach Video/Text-to-Video liefert Kandidaten, keine Lizenz- oder Kompatibilitaetsfreigabe.
Ein Repo mit offenem Code ist ausserdem nicht automatisch ein uneingeschraenkt
nutzbares Modell: Code-, Gewichts- und Datenlizenzen unterscheiden.

## 2. Welche Daten gibt es?

| Datensatz / Primaerquelle | Inhalt und Bereitstellung | Einordnung fuer dieses Setup |
|---|---|---|
| [FineVideo](https://huggingface.co/datasets/HuggingFaceFV/finevideo) | Laut Karte 43.751 Videos, rund 3.425 Stunden; Parquet mit Video und strukturierten Szenen-/Transkriptmetadaten; Vollbestand etwa 600 GB | Besonders Videoverstehen/Annotation; kein fertiger universeller LoRA-Input. Karte nennt CC-BY-Herkunft, Attribution und Nutzungsbedingungen pruefen |
| [VIDGEN-1M](https://huggingface.co/datasets/Fudan-FUXI/VIDGEN-1M) | Video-Caption-Paare; Karte beschreibt aufgeteilte Videoarchive und JSON-Zuordnung | T2V-Kandidat; Apache-2.0-Kartenlabel nicht als Rechtegarantie fuer jedes Quellvideo behandeln |
| [Panda-70M](https://github.com/snap-research/Panda-70M) | CSV-Metadaten/Zeiten plus Downloader; Rohvideos nicht mit der kleinen CSV verwechseln | Upstream schaetzt Vollmaterial auf etwa 36 TB. [Lizenz](https://github.com/snap-research/Panda-70M/blob/main/LICENSE): nichtkommerzielle Forschung; keine pauschale kommerzielle Freigabe |
| [MiraData](https://huggingface.co/datasets/TencentARC/MiraData) | Metadaten, Quell-URLs, Clipgrenzen und mehrere Caption-Felder | URL-/Metadatenbereitstellung ist kein fertiger MP4-Bestand. GPL-3.0-Kartenlabel ersetzt keine Pruefung der Medienrechte |
| [VALID](https://huggingface.co/datasets/ontocord/VALID/blob/1758855b0f16da2ba0edda156099cc5a78405a94/README.md) | Gepinnte Karte beschreibt rund 720.000 CC-YouTube-Videos als Audio-/Frame-/Text-Datensaetze; Parquet und Medienarchive | Multimodales Verstehen, nicht unveraendert ein Videogenerator-Trainingsformat. Diese Kartenrevision nennt CC-BY-SA-4.0, nicht pauschal nur CC-BY; aktuelle Revision/Verfuegbarkeit vor Nutzung pruefen |

Zahlen sind Angaben der jeweiligen verlinkten Karten, keine lokal vermessenen
Downloads. Dateien, Lizenzen und Verfuegbarkeit koennen sich aendern.
Die VALID-Hauptseite war bei dieser Pruefung nicht verlaesslich abrufbar;
deshalb ist die historische Kartenrevision ausdruecklich angegeben.

Cakeify-/Crush-/Lighting-Angebote einzeln pruefen: solche Namen koennen
fertige LoRA-Gewichte, Workflow-Beispiele oder Spaces meinen statt Rohdaten.
Ohne eindeutige Dataset-ID, Karte und Rechtebeleg keine Registrierung als Trainingsdaten.

## 3. Optionale Werkzeuge

| Menue / Registry-ID | GitHub-Quelle | Aufgabe | Ressourcen / Risiko |
|---|---|---|---|
| HF_Datasets / `hf_datasets` | [huggingface/datasets](https://github.com/huggingface/datasets), [GitHub-Installer](../tools/hf-datasets.md) | experimental: Basispaket in privater venv; keine Decoder/Datensatz-Downloads | medium; spaetere Daten/Cache separat begrenzen |
| HF_Hub / `hf_hub` | [huggingface/huggingface_hub](https://github.com/huggingface/huggingface_hub) | Hub-Client und hf-CLI; Revisionen und Dateiauswahl | light fuer Client, Downloads unbegrenzt ohne externe Limits |
| Video2Dataset / `video2dataset` | [iejMac/video2dataset](https://github.com/iejMac/video2dataset) | Genehmigte Video-URLs laden, verarbeiten und paketieren | heavy; Netzwerk/CPU/SSD, unzuverlaessige und nicht vertrauenswuerdige Quellen |

Bibliothekscode: Datasets/Hub Apache-2.0, video2dataset MIT laut Upstream.
Diese Lizenzen gelten nicht automatisch fuer heruntergeladene Medien.
HF_Datasets hat einen eigenen experimentellen GitHub-Installer fuer 5.1.0;
er richtet nur das Basispaket ein, keine Datensaetze, Modelle oder Trainings.
HF_Hub und Video2Dataset bleiben **planned/documentation-first**.
Keine Docker-Pflicht und keine neuen Listener/Ports.

Fuer HF_Datasets zuerst den eigenen Plan lesen:

```bash
bash scripts/tools/hf_datasets_install.sh --dry-run
```

HF_Hub und Video2Dataset verwenden weiterhin gemeinsame sichere Guards:

```bash
bash scripts/tools/video_dataset_candidate_install.sh --dry-run
bash scripts/tools/video_dataset_candidate_doctor.sh
```

Die Guards pruefen nur die Registrierung: keine Netzwerk-/Hardware-/Modelltests.
Install/Update/Uninstall ohne Plan liefern Exit-Code 2 statt einer falschen
Erfolgsmeldung. Sie deinstallieren insbesondere keine schon vorhandenen HF-Pakete.

## 4. Sicherer erster Versuch Schritt fuer Schritt

1. Ziel aus Abschnitt 1 festlegen. Fuer reine Inferenz keine Trainingsdaten laden.
2. Dataset Card, Nutzungsbedingungen, Quelle, Attribution, Loesch-/Opt-out-Hinweise
   und Rechte an Personen/Stimmen pruefen. Oeffentlich erreichbar heisst nicht frei nutzbar.
3. Dataset-ID und konkrete Commit-SHA erfassen; Bibliotheks-/Decoder-Versionen
   getrennt pinnen. Nicht ungeprueft `main` fuer reproduzierbares Training nutzen.
4. Metadaten/Dateiliste, Shard-Groessen und Schema ansehen. Ein paar Zeilen
   koennen in einem grossen Parquet-/TAR-Shard liegen.
5. Privaten Cache-/Medienordner ausserhalb Git festlegen und ein hartes
   Byte-/Zeit-/Dateilimit planen. Auch der HF-Datasets-Paketinstaller implementiert
   keinen budgetierten Downloader; Guards starten ebenfalls keine Datenaktionen.
6. Zunaechst ein genehmigtes Beispiel manuell pruefen. Keine Vollspiegelung,
   kein rekursives Crawling und keine fremden Download-Skripte blind starten.
7. Erst danach in modellbezogene Clips/Captions konvertieren, Split und
   Qualitaet pruefen und einen begrenzten Trainer-Smoke-Test gesondert freigeben.

[Beispiel fuer ein Freigabeprotokoll](../../examples/video_datasets/review.example.json):
nur Vorlage, keine aktive Konfiguration und keine Trainingsfreigabe.
Echte Rechtebelege, personenbezogene Daten und HF-Tokens gehoeren nicht ins Repo.

### Streaming verstehen

Streaming laedt bei Bedarf statt vorab den kompletten Bestand.
Schon `next(iter(dataset))` kann Netzwerkzugriffe und Medienbytes ausloesen.
`take(1)` begrenzt Datensaetzeintraege, nicht transportierte Bytes,
Tempdateien, Cache, Decoder-Speicher oder GPU-Nutzung.
[Offizielle Streaming-Dokumentation](https://huggingface.co/docs/datasets/stream).

Das folgende Beispiel ist **eine manuell auszufuehrende Netzwerkaktion**, kein
Installer-/Doctor-Schritt. Voraussetzung: bewusst eingerichtete, gepinnte
`datasets`-Umgebung, Rechtefreigabe, privater Cache und extern ueberwachtes Budget.
Nicht fuer einen Offline-Test ausfuehren.

```python
import os
import re

if os.environ.get("VIDEO_DATASET_NETWORK_OPT_IN") != "1":
    raise SystemExit("Kein Netzwerk freigegeben.")
revision = os.environ.get("VIDEO_DATASET_REVISION", "")
if not re.fullmatch(r"[0-9a-f]{40}", revision):
    raise SystemExit("Zuerst eine gepruefte Dataset-Commit-SHA festlegen.")
if not os.environ.get("HF_HOME") or not os.path.isabs(os.environ["HF_HOME"]):
    raise SystemExit("Privaten absoluten HF_HOME-Cache ausserhalb Git festlegen.")

from datasets import load_dataset

dataset = load_dataset(
    "HuggingFaceFV/finevideo",
    revision=revision,
    split="train",
    streaming=True,
)
sample = next(iter(dataset.take(1)), None)
print("Eintrag vorhanden:", sample is not None)
# Keine kompletten Metadaten, Transkripte, Tokens oder Video-Bytes loggen.
```

Das Beispiel setzt kein hartes Downloadlimit durch und validiert den Cachepfad
nicht gegen Git/Symlinks. Diese Betriebsfreigabe und Quoten muessen vorher
separat erfolgen. `HF_HOME` allein erzeugt keine Zugriffskontrolle.
Auch `select_columns`/Filter sind keine allgemeine Garantie, keine Videos zu
uebertragen. Keine beliebigen Remote-Python-Skripte oder `trust_remote_code=True`.

MP4 sind Mediendateien, Parquet ist ein Tabellencontainer und WebDataset
ist eine Shard-/Zugriffskonvention, haeufig mit TAR-Dateien. Alle koennen
grosse Nutzdaten enthalten; Dateiendungen sagen nichts ueber Medienrechte.
URL-Listen benoetigen zusaetzlich erreichbare und genehmigte Quellen.
Ungepruefte Archive nicht mit beliebigen Pfaden entpacken; Decoder in
eingeschraenkter Umgebung betreiben. Keine DRM-/Login-/Zugriffssperren umgehen.

## 5. Passt das zu Open-Sora, CogVideoX, LTX oder Hunyuan?

| Offizieller Modellcode | Vor Training pruefen |
|---|---|
| [Open-Sora](https://github.com/hpcaitech/Open-Sora) | exakte Generation, Datenpipeline und Trainerformat |
| [CogVideoX](https://github.com/zai-org/CogVideo) | Modellgroesse, Trainer-/LoRA-Variante, Caption-/Videoformat |
| [LTX-Video](https://github.com/Lightricks/LTX-Video) | LTX-Generation, passendes Training-Repo, Video-/Audio-Anforderungen |
| [HunyuanVideo](https://github.com/Tencent-Hunyuan/HunyuanVideo) | Modellvariante, Gewichtsbedingungen, Speicherbedarf und Training-Support |

Keine pauschale Zuordnung "alle genannten Modelle wurden mit diesen
oeffentlichen Daten trainiert". Ein offener Datensatz kann geeignet sein,
ohne Teil des originalen Trainingskorpus oder direkt kompatibel zu sein.
Trainer erwarten z. B. bestimmte FPS, Frameanzahl, Aufloesung, Caption-Felder,
Latent-Caches und Audioformate. Das muss ein separater Adapter sicherstellen.

Erst unveraenderte Originale sichern, dann abgeleitete Clips erstellen.
Quell-ID, Lizenz/Attribution, SHA-256, Clipstart/-ende, FPS und Bearbeitung
nachweisen; nahe Duplikate und Clips derselben Quelle nicht ueber
Train/Validation/Test verteilen. Untertitel, Logos und synthetische
Captions auf Fehlbeschreibungen/Prompt-Injection pruefen. Niemanden allein
aufgrund von Gesichtern identifizieren oder ohne Einwilligung klonen.

## 6. Speicherwacht und Zielhosts

Vor Download: reale freie SSD am Cache-/Zielmount, Quota, RAM/Swap, CPU,
Netzwerkbudget und temporaere Dateien pruefen. Unter WSL zusaetzlich den
Windows-Datentraeger der VHDX; nicht automatisch von C: ausgehen.
Linux-Dateisystemkapazitaet ist nicht gleich freier physischer Windows-Speicher.

Budget: gewaehlte Shards + Cache/Duplikate + entpackte/geschnittene Clips +
Frames/Latents + Checkpoints + Sicherheitsreserve. Die Faktoren sind
pipelineabhaengig: erst Pilot messen, keine feste 2x- oder 20-GB-Garantie.

| Host | Sinnvoller Start | RAM / VRAM / Disk |
|---|---|---|
| MiniPC/WSL2 | Karten/Metadaten, genehmigter Einzelclip | Kein Training zugesagt; reale freie SSD und Decoderbedarf messen |
| Raspberry Pi | Freigabe-/Queue-Steuerung | Kleine Metadaten; keine schwere Decodierung/Video-Trainingsjobs |
| Oracle VPS | Control Plane, Katalog/Queue | Keine Vollkorpora oder oeffentlichen Dataset-/Admin-Endpunkte |
| GPU-Workstation | separat getestetes Fine-Tuning | RAM/VRAM vom Modell, Optimizer, Frames und Praezision abhaengig; Inferenzwerte reichen nicht |
| K3s | optionaler Worker mit Quota/PVC | Kein gemeinsamer VRAM-Pool; Storage-/Egresslimits und GPU-Zuweisung explizit |

Die vorhandene Speicherpruefung ersetzt keine fortlaufende Download-Quota.
Aktuell liefern die neuen Kandidaten-Guards keine Ressourcenfreigabe.
Fuer einen echten Installer fehlen noch versionsbezogene Abhaengigkeiten,
Preflight, Byte-/Zeitlimits, sicherer Resume, Smoke-Test und datenbewahrender Uninstaller.

## 7. OpenClaw, Ollama und n8n

Vorhandenes Profil [Dataset_Curator](../Profile/Dataset_Curator.md) erweitert,
kein zweites Doppelprofil. Ollama kann genehmigte Captions vorschlagen,
ist aber weder Videogenerator-Trainer noch Lizenzpruefer.

Geplanter Ablauf: Karte/Revision erfassen -> menschliche Rechtefreigabe ->
Budgetfreigabe -> ein begrenzter Queue-Auftrag -> lokaler Qualitaetsbericht ->
manueller Trainingsstart. Kein ausfuehrbarer OpenClaw-/n8n-Adapter enthalten.
Datensatztexte als untrusted input behandeln, keine daraus abgeleiteten Shellbefehle.
API-Tokens nur ausserhalb Git, minimal read-only falls ueberhaupt erforderlich;
Gating/Einwilligung nicht durch fremde Tokens umgehen. Keine Tokens in Queue-Argumenten.
Keine automatischen Uploads von Videos, Stimmen oder eigenen Fine-Tuning-Gewichten.
