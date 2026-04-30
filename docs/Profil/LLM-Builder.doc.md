# Profilquelle: LLM-Builder

Quelle: Benutzerauftrag für ein realistisches lokales Modellbau-Setup auf Basis von GitHub-Quellen.

## Ziel

Dieses Profil beschreibt ein vollständiges Setup, mit dem man eigene lokale LLMs bauen, anpassen, fine-tunen, quantisieren, als GGUF exportieren und anschließend mit Ollama verwenden kann.

Wichtig:
Es geht ausdrücklich nicht darum, ein Foundation Model vollständig von Null zu trainieren. Ziel ist ein realistischer lokaler Workflow auf Basis vorhandener Open-Source-Modelle.

## Realistischer Workflow

1. vorhandenes Open-Source-Modell auswählen
2. eigene Daten vorbereiten
3. Dataset bereinigen und strukturieren
4. LoRA/QLoRA Fine-Tuning durchführen
5. Modell testen
6. Modell mergen oder Adapter separat nutzen
7. nach GGUF exportieren
8. mit llama.cpp quantisieren
9. mit Ollama per Modelfile einbinden
10. eigenes Modell lokal nutzen

## Pflicht-Komponenten

- Ollama
- Unsloth
- LLaMA Factory
- Axolotl
- Data Juicer
- llama.cpp
- OpenClaw als optionaler Orchestrator

## Empfohlene GitHub-Quellen

- `https://github.com/unslothai/unsloth`
- `https://github.com/hiyouga/LLaMA-Factory`
- `https://github.com/axolotl-ai-cloud/axolotl`
- `https://github.com/modelscope/data-juicer`
- `https://github.com/ggml-org/llama.cpp`

## Ollama-Aufgaben

- Ollama installieren oder prüfen
- Modelle laden
- eigene Modelfiles erzeugen
- eigenes GGUF-Modell importieren
- Systemprompt, Parameter und Template definieren

Hinweis:
Die Modelfiles selbst sollten möglichst lokal außerhalb des Git-Repositories gepflegt werden, idealerweise im Benutzer-Workspace des Setups.

## Beispielkommandos

```bash
ollama create mein-llm -f Modelfile
ollama run mein-llm
```

## Beispielmodelle für Ollama

```bash
ollama pull llama3.2:3b
ollama pull qwen2.5:7b
ollama pull mistral:7b
```

Für Coding- oder Agentenbezug zusätzlich:

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen3-coder:30b
ollama pull devstral:24b
```

## Beispielprompts

```txt
Wähle für diesen Anwendungsfall ein offenes Basismodell aus, begründe die Wahl und erstelle einen LoRA/QLoRA-Trainingsplan für lokale Hardware.
```

```txt
Bereinige meinen Fine-Tuning-Datensatz, strukturiere ihn als Chat- oder Instruktionsformat und zeige mir die Schritte bis zum GGUF-Export.
```

```txt
Erzeuge aus dem feinjustierten Modell ein Ollama-Modelfile mit Systemprompt, Temperatur und Template für lokale Nutzung.
```
