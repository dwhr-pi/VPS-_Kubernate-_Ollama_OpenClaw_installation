# Profil: Trading AI

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Trading_AI.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Trading_AI.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Tradingprofil für Marktanalyse, Strategieprüfung und Bot-unterstützte Entscheidungsprozesse.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`
- Bereits als einzelne Tools installierbar:
  - Zenbot_trader unter `/opt/zenbot-trader`
  - Web3_APIs unter `/opt/web3_apis`
  - Exchange_APIs unter `/opt/exchange_apis`

## Dokumentierte zusätzliche Tools

Die zuvor zusätzlich beschriebenen Trading-Bausteine sind jetzt als Setup-Module vorhanden:

- `Zenbot_API`
- `Risk_Strategy_Analyzer`
- `Backtest_Workflow`

## Verantwortlichkeiten

- Märkte analysieren
- Strategien vergleichen und testen
- Trading-Bots unterstützen
- Risiken in Setups und Strategien bewerten

## Verfügbare Kommandos

```bash
scripts/tools/zenbot_trader_install.sh
scripts/tools/web3_apis_install.sh
scripts/tools/exchange_apis_install.sh
```

## Beispielprompts

### Strategieanalyse

```txt
Analysiere meine Trading-Strategie auf Chancen, Risiken, Marktannahmen und Schwachstellen.
Gib mir eine strukturierte Bewertung und mögliche Verbesserungen.
```

### Bot-Review

```txt
Bewerte mein Zenbot-Setup hinsichtlich Marktanalyse, Risikomanagement und Testbarkeit.
Zeige mir, welche Parameter ich vor einem Backtest priorisieren sollte.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt vor allem als Analyse- und Koordinationsschicht zu OpenClaw.
- `Zenbot_trader` ist der wichtigste bereits vorhandene konkrete Baustein.
- `Web3_APIs` und `Exchange_APIs` ergänzen jetzt zusätzliche Daten- und Börsenanbindungen.

## Empfohlene LLMs für Finanzdatenanalyse

Für dieses Profil sind im aktuellen Setup besonders sinnvoll:

- `qwen3:4b`
  - für kleine lokale Systeme, Watchlists, Nachrichten und einfache Kennzahlen
- `qwen3:30b`
  - für stärkere lokale Analyse, Research-Zusammenfassungen und mehrstufige Auswertung
- `deepseek-r1:8b`
  - für Reasoning, Risikoargumentation und Backtest-Erklärungen
- `deepseek-r1:14b`
  - für komplexere Finanz- und Szenarioanalyse

GitHub-basierte Finanz-Stacks zur Weiterentwicklung:

- `FinGPT`
- `FinRobot`
- `FinRAG`

Diese GitHub-Stapel sind im Setup als optionale Module für Analyse, RAG und lokale Weiterentwicklung vorgesehen, nicht als automatische Live-Trading-Engine.

## Vergleich

### ✅ In Sync

- Ein Trading-Bot-Baustein ist mit `Zenbot_trader` bereits vorhanden.
- `Web3_APIs` und `Exchange_APIs` sind jetzt als installierbare Zusatzbausteine vorhanden.

### ⚠ Missing in Setup

- Die zuvor fehlenden Trading-Integrations- und Analysebausteine sind jetzt im Setup vorhanden.

### ❌ Missing in Docs

- Dieses Profil war lokal bislang noch nicht als eigene Zielseite vorhanden.

## Hinweise

- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- Das Profil ist bewusst eher analyse-, bot- und backtestnah gehalten, nicht als vollautomatisches Handelssystem.
- LLMs und Agenten sollen hier keine autonomen Live-Trading-Entscheidungen treffen.
- Empfohlen sind Marktanalyse, historische Tests, Paper-Trading und Risikoauswertung statt echter Ausführung.
- Seed-Phrases, Private Keys und echte Exchange-Secrets gehören niemals ins Repository.
- Empfohlene sichere Lesepfade:
  - [Trading_Analysis.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/Trading_Analysis.md:1)
  - [Trading_Execution_Manual_Mode.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/Trading_Execution_Manual_Mode.md:1)
