# Programmierung_Codex_Agents

Status: `documentation-first`

## Zweck
Lokale Coding-Agenten mit Codex/OpenClaw, Aider, OpenCode, Continue.dev und GitHub CLI planen.

## Typische Aufgaben
Code lesen, Patches vorbereiten, Tests starten, PR-Notizen schreiben.

## Empfohlene Tools
OpenClaw, Ollama, Aider, OpenCode, GitHub CLI, Continue.dev, Act.

## Erlaubte Aktionen
Read-only Analyse, Patch-Vorschlaege, lokale Tests nach Freigabe.

## Verbotene/gefaehrliche Aktionen
Kein Push, Merge, Reset oder Secret-Zugriff ohne Freigabe.

## Umgebungsvariablen
`OLLAMA_BASE_URL`, `OPENCLAW_GATEWAY_URL`, optional `GITHUB_TOKEN` nur lokal.

## Beispiel-Prompts
`Analysiere dieses Repo und erstelle einen minimalen Patch mit Tests, ohne Secrets zu lesen.`

## Modellvorschlaege
Ollama: `llama3.2:1b` fuer kurze Checks, groesseres Modell fuer Refactoring.

## Speicherort
`~/.openclaw_ultimate_user_data/reports/coding_agents`
