# Dataset_Curation_Labeling

## Zweck
Datensätze sammeln, bereinigen, deduplizieren, annotieren und für Fine-Tuning oder RAG vorbereiten.

## Typische Aufgaben
- Datensichtung und Labeling
- Datenversionierung
- SQL- und Metadaten-Exploration
- Dokument- und Text-Vorbereitung

## Empfohlene Tools
DVC, Label Studio, Argilla, DuckDB, Datasette, Docling, Unstructured.

## Optionale Tools
`jq`, `yq`, Cleanlab, Datatrove.

## Benötigte Ports
`6900`, `8080`

## Ressourcenbedarf
8 GB RAM und ausreichender SSD-Speicher für Rohdaten empfohlen.

## Sicherheitsrisiken
Trainings- und Dokumentdaten können personenbezogen oder urheberrechtlich sensibel sein. Vor Nutzung prüfen und minimieren.

## Ollama/OpenClaw-Fit
Gut für lokale RAG- und Fine-Tuning-Vorbereitung.

## LiteLLM/Open WebUI-Fit
Nicht zentral, aber hilfreich für spätere Evaluations- und Chat-Testschleifen.

## Quickstart
`bash scripts/profiles/Dataset_Curation_Labeling_install.sh`

## Deinstallation
`bash scripts/profiles/Dataset_Curation_Labeling_uninstall.sh`

## Sinnvolle lokale Modelle
Kleine Extraktions-, Clustering- und Bewertungsmodelle für Label-Support.

## Grenzen und Warnhinweise
Keine ungeprüfte Massenübernahme fremder Inhalte. Datenherkunft, Lizenzen und PII klar dokumentieren.
