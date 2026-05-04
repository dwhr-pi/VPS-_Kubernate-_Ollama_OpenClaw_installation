# Prompt_Engineering_Lab

## Zweck
Prompt-Bibliothek, Versionierung, Regressionstests und Vorlagen für lokale LLM-, Codex- und Agenten-Workflows.

## Typische Aufgaben
- Prompt-Varianten vergleichen
- Sicherheits- und Halluzinationsfälle testen
- Team-Prompt-Bibliothek pflegen
- Modell- und Prompt-Regressionsläufe dokumentieren

## Empfohlene Tools
Promptfoo, Langfuse, LiteLLM, Open WebUI, Ragas.

## Optionale Tools
DeepEval, TruLens, Markdown-Registry im Repo.

## Benötigte Ports
`3000`, `3003`, `4000`

## Ressourcenbedarf
Leicht bis mittel.

## Sicherheitsrisiken
Prompts können interne Logik, Daten und Sicherheitsregeln offenlegen. Deshalb Traces und Prompt-Sammlungen schützen.

## Ollama/OpenClaw-Fit
Sehr gut für wiederverwendbare Agenten- und Modell-Prompts.

## LiteLLM/Open WebUI-Fit
Kernnah, da beide Schichten Prompt-Läufe und Tests stark erleichtern.

## Quickstart
`bash scripts/profiles/Prompt_Engineering_Lab_install.sh`

## Deinstallation
`bash scripts/profiles/Prompt_Engineering_Lab_uninstall.sh`

## Sinnvolle lokale Modelle
Gemischte Prompt-Testpalette aus Generalisten, Coder- und RAG-Modellen.

## Grenzen und Warnhinweise
Prompt-Labs erzeugen schnell Wissensinseln. Tests und Vorlagen im Repo oder im User-Workspace klar strukturieren.
