# Profil: LLM-Builder

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [LLM-Builder.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/LLM-Builder.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein realistisches lokales Modellbau-Setup für Fine-Tuning, GGUF-Export, Quantisierung und die spätere Nutzung mit Ollama.

Wichtig:
Dieses Profil zielt nicht auf das Training eines Foundation Models von Null, sondern auf einen praktikablen lokalen Workflow mit vorhandenen Open-Source-Modellen.

## Installierter Stack

- Basis: `git`, `python3`, `python3-pip`, `python3-venv`, `build-essential`, `cmake`, `ninja-build`
- Bereits als einzelne Tools installierbar:
  - `Ollama`
  - `Data_Juicer` unter `/opt/data_juicer`
  - `Unsloth` unter `/opt/unsloth`
  - `LLaMA_Factory` unter `/opt/llama_factory`
  - `Llama_CPP_Toolchain` unter `/opt/llama_cpp_toolchain`
  - `Axolotl` unter `/opt/axolotl`
  - ergänzend `MLflow`, `Weights_and_Biases`, `vLLM`, `Llama_CPP`

## Dokumentierte zusätzliche Tools

Die fachlich gewünschten Kernbausteine sind jetzt als installierbare Setup-Module vorhanden:

- `Ollama`
- `Data_Juicer`
- `Unsloth`
- `LLaMA_Factory`
- `Axolotl`
- `Llama_CPP_Toolchain`
- `Llama_CPP`
- `MLflow`
- `Weights_and_Biases`
- `vLLM`

Zusätzlich sind zur Einbettung ins übrige Setup verfügbar:

- `OpenClaw`
- `Flowise`
- `LangFlow`
- `Clawbake`
- `Docker`
- `Code_Sandbox`
- `GitHub_CLI`
- `ChromaDB`

## Verantwortlichkeiten

- offenes Basismodell auswählen
- Datensätze bereinigen und strukturieren
- LoRA/QLoRA-Fine-Tuning vorbereiten und ausführen
- Modelltests und Evaluation durchführen
- Adapter mergen oder separat weiterverwenden
- nach GGUF exportieren
- mit `llama.cpp` quantisieren
- per `Modelfile` in Ollama einbinden

## Realistischer Workflow

1. Basismodell auswählen, zum Beispiel ein offenes Instruct- oder Coding-Modell.
2. Eigene Daten vorbereiten und mit `Data_Juicer` bereinigen.
3. Datensatz in ein sauberes Chat- oder Instruktionsformat überführen.
4. Mit `Unsloth`, `LLaMA_Factory` oder `Axolotl` ein LoRA/QLoRA-Fine-Tuning planen.
5. Das Modell lokal testen und Outputs evaluieren.
6. Adapter mergen oder getrennt weiterverwenden.
7. Das Ergebnis nach GGUF exportieren.
8. Mit `Llama_CPP_Toolchain` beziehungsweise `llama.cpp` quantisieren.
9. Ein `Modelfile` für Ollama anlegen.
10. Das eigene Modell lokal mit Ollama ausführen.

## Verfügbare Kommandos

```bash
scripts/tools/ollama_install.sh
scripts/tools/data_juicer_install.sh
scripts/tools/unsloth_install.sh
scripts/tools/llama_factory_install.sh
scripts/tools/llama_cpp_toolchain_install.sh
scripts/tools/axolotl_install.sh
scripts/tools/mlflow_install.sh
scripts/tools/weights_and_biases_install.sh
scripts/tools/vllm_install.sh
scripts/tools/llama_cpp_install.sh
```

## Beispielkommandos

```bash
ollama create mein-llm -f Modelfile
ollama run mein-llm
```

```bash
cd /opt/llama_cpp_toolchain
./build/bin/llama-quantize ./modell.gguf ./modell-q4_k_m.gguf Q4_K_M
```

## Empfohlene Startmodelle für den Workflow

Diese Modelle werden bewusst nicht automatisch gepullt, damit Größe und Hardwarebedarf bei dir kontrollierbar bleiben. Für lokale Tests und den Modellbau-Workflow sind sie aber naheliegende Startpunkte:

```bash
ollama pull llama3.2:3b
ollama pull qwen2.5:7b
ollama pull mistral:7b
```

Für Code- oder agentennahe Spezialfälle im weiteren Ausbau:

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen3-coder:30b
ollama pull devstral:24b
```

## Beispielprompts

### Basismodell auswählen

```txt
Wähle für diesen Anwendungsfall ein offenes Basismodell aus, begründe die Wahl und erstelle einen lokalen Fine-Tuning-Plan mit LoRA oder QLoRA.
```

### Datensatz vorbereiten

```txt
Bereinige diesen Fine-Tuning-Datensatz, entferne Duplikate, erkenne Formatfehler und strukturiere ihn als Chat- oder Instruktionsformat für ein lokales Modell.
```

### Ollama-Einbindung

```txt
Erzeuge für mein feinjustiertes GGUF-Modell ein Ollama-Modelfile mit Systemprompt, Parametern und einem Template für lokale Nutzung.
```

## OpenClaw / Ollama Fit

- `Ollama` ist die Zielplattform für die lokale Bereitstellung des fertigen Modells.
- `OpenClaw` kann den Workflow später orchestrieren, ist aber nicht zwingend für das eigentliche Fine-Tuning.
- `Data_Juicer`, `Unsloth`, `LLaMA_Factory` und `Axolotl` decken den Trainingspfad ab.
- `Llama_CPP_Toolchain` schließt den Weg nach GGUF und Quantisierung.
- `Flowise` und `LangFlow` sind optional hilfreich, um Eingaben und Testketten visuell zu evaluieren.
- Über den neuen Ollama-Modelfile-Assistenten im Optionen-Menü kann eine lokale Modelfile-Vorlage direkt in `~/.openclaw_ultimate_user_data/modelfiles` erzeugt werden.

## Vergleich

### ✅ In Sync

- Die Pflicht-Komponenten für den realistischen lokalen Workflow sind jetzt als einzelne Setup-Module vorhanden.
- `Ollama` bleibt die lokale Zielplattform für das spätere fertige Modell.
- `llama.cpp` ist sowohl als allgemeines Modul als auch als gezielte Toolchain für GGUF und Quantisierung abbildbar.

### ⚠ Missing in Setup

- Das Profil automatisiert bewusst nicht das vollständige End-to-End-Training mit einem einzigen Knopf, weil Datensätze, Hyperparameter und Hardware stark variieren.
- Das eigentliche Basismodell wird weiterhin bewusst über den Ollama-Modell-Manager oder manuelle Auswahl geladen, nicht automatisch.

### ❌ Missing in Docs

- Dieses Profil war bisher noch nicht als eigene Zielseite im Setup vorhanden.

## Hinweise

- Die neuen Bausteine werden aus GitHub-Quellen geholt und lokal auf dem Zielsystem vorbereitet oder gebaut.
- Der Modelfile-Assistent speichert Vorlagen bewusst außerhalb des Repositories, damit eigene GGUF-Pfade, Systemprompts und Modellnamen nicht versehentlich in Git landen.
- Für echte Trainingsläufe solltest du Speicherbedarf, GPU-Verfügbarkeit und Datensatzgröße individuell prüfen.
- Für kleinere Systeme kann ein Adapter-Workflow mit LoRA/QLoRA sinnvoller sein als große Voll-Merges.
