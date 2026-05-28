# Local_Model_Lifecycle_Manager

## Zweck
Lokale Modelle installieren, aktualisieren, pruefen, versionieren und bei Bedarf entfernen.

## Typische Aufgaben
- Ollama-Modellbestand dokumentieren.
- Speicherverbrauch je Modell bewerten.
- Update-, Rollback- und Loeschvorschlaege vorbereiten.

## Empfohlene Tools
Ollama, llama.cpp, Open WebUI, LiteLLM, resource_estimator, setup metrics.

## Hardwarebedarf und Status
Hardware: mittel bis GPU. Status: planned. Installationsart: local, WSL2, GPU-Workstation.

## Datenschutz und Sicherheit
Modell-Downloads koennen sehr gross sein. Keine Modelle aus unbekannten Quellen ohne Hash/Quelle dokumentieren.

## Beispiel-Prompt
`Erstelle mir einen sicheren Modell-Lifecycle-Plan fuer meine lokale Ollama-Installation mit Speicherbudget 80 GB.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5:7b`, `deepseek-coder-v2:16b` falls Speicher reicht.

## Grenzen
Kein autonomes Loeschen produktiv genutzter Modelle.
