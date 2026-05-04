# Synthetic_Data_Generator

## Zweck
Synthetische Trainingsdaten, Testdaten, Dialoge und RAG-Fragen lokal erzeugen.

## Typische Aufgaben
- Prompt-basierte Datengenerierung
- Frage-Antwort-Sets für RAG
- Dialog- und Agenten-Testfälle
- Stresstests für Policies und Prompts

## Empfohlene Tools
Distilabel, Argilla, LangChain, LlamaIndex, FastAPI, Streamlit.

## Optionale Tools
Faker, eigene Prompt-Templates, Langfuse-Datasets.

## Benötigte Ports
`6900`, `8501`

## Ressourcenbedarf
8 GB RAM empfohlen; Qualität steigt mit besseren lokalen Modellen.

## Sicherheitsrisiken
Synthetische Daten können unerwünschte Biases oder halluzinierte Fakten enthalten. Nicht ungeprüft in Produktion oder Training kippen.

## Ollama/OpenClaw-Fit
Sehr gut für lokales Prototyping, Eval-Datensätze und Agenten-Fallbacktests.

## LiteLLM/Open WebUI-Fit
Gut für Multi-Model-Vergleiche und manuelle Stichproben.

## Quickstart
`bash scripts/profiles/Synthetic_Data_Generator_install.sh`

## Deinstallation
`bash scripts/profiles/Synthetic_Data_Generator_uninstall.sh`

## Sinnvolle lokale Modelle
Stabile Generalisten und Coder-Modelle mit guter Instruktionsqualität.

## Grenzen und Warnhinweise
Synthetik ersetzt keine echten Produktionsdaten. Herkunft und Labelqualität weiterhin kontrollieren.
