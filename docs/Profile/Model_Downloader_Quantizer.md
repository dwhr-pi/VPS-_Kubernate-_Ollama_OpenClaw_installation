# Model_Downloader_Quantizer

## Zweck
Modellquellen, Quantisierungen und lokale Speicherorte nachvollziehbar planen.

## Typische Aufgaben
- Geeignete Quantisierung fuer RAM/VRAM auswaehlen.
- Downloadquellen dokumentieren.
- GGUF-/llama.cpp-Pfade vorbereiten.

## Empfohlene Tools
llama.cpp, Ollama, Hugging-Face-kompatible Downloads, checksum/sha256, rclone optional.

## Hardwarebedarf und Status
Hardware: mittel bis GPU. Status: experimental. Installationsart: local, GPU, VPS nur fuer kleine Modelle.

## Datenschutz und Sicherheit
Nur Quellen mit klarer Lizenz und Herkunft nutzen. Keine privaten Modelle in oeffentliche Buckets kopieren.

## Beispiel-Prompt
`Welche Quantisierung passt fuer 16 GB RAM und lokale Coding-Aufgaben, ohne GPU?`

## Modelle
Ollama/GGUF: kleine Q4/Q5-Varianten von Llama/Qwen/Mistral.

## Grenzen
Keine automatische Lizenzannahme und keine ungeprueften Modellspiegel.
