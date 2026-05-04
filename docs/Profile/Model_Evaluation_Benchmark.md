# Model_Evaluation_Benchmark

## Zweck
Lokale Modelltests, Prompt-Evaluation, Kosten-/Tokenvergleich und Qualitätsvergleiche für LLM-, Agenten- und RAG-Setups.

## Typische Aufgaben
- Benchmarks gegen Standardaufgaben
- Prompt-Regressionen
- RAG-Qualitätsvergleich
- Tracing und Testdaten-Auswertung

## Empfohlene Tools
Promptfoo, LM Evaluation Harness, Ragas, DeepEval, TruLens, Langfuse.

## Optionale Tools
OpenLIT, OpenAI-Evals-kompatible Strukturen, eigene Benchmark-Datasets.

## Benötigte Ports
`3003`

## Ressourcenbedarf
8 GB RAM empfohlen; mehr bei größeren lokalen Benchmarks.

## Sicherheitsrisiken
Prompts, Datasets und Eval-Outputs können sensible Inhalte enthalten. Telemetrie und Logs geschützt halten.

## Ollama/OpenClaw-Fit
Sehr gut für lokale Modellvergleiche und agentische Qualitätskontrolle.

## LiteLLM/Open WebUI-Fit
LiteLLM erleichtert Provider-Vergleiche. Open WebUI kann als manuelle Prüfoberfläche dienen.

## Quickstart
`bash scripts/profiles/Model_Evaluation_Benchmark_install.sh`

## Deinstallation
`bash scripts/profiles/Model_Evaluation_Benchmark_uninstall.sh`

## Sinnvolle lokale Modelle
Gemischte Testpalette aus kleinen Coder-, Generalisten- und RAG-freundlichen Modellen.

## Grenzen und Warnhinweise
Benchmarks messen nicht alles. Ergebnisse immer mit realen Tasks und Sicherheitsfällen ergänzen.
