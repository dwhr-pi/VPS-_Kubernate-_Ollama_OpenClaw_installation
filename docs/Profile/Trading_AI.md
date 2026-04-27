# Profil: Trading_AI

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Trading_AI.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Trading_AI.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Tradingprofil für Marktanalyse, Strategieprüfung und Bot-unterstützte Entscheidungsprozesse.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`
- Bereits als einzelne Tools installierbar:
  - Zenbot_trader unter `/opt/zenbot-trader`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Zenbot API
- Web3 APIs
- Exchange APIs
- dedizierte Risiko- und Strategieanalyse als Profilmodul

## Verantwortlichkeiten

- Märkte analysieren
- Strategien vergleichen und testen
- Trading-Bots unterstützen
- Risiken in Setups und Strategien bewerten

## Verfügbare Kommandos

```bash
scripts/tools/zenbot_trader_install.sh
scripts/tools/zenbot_trader_uninstall.sh
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
- Zusätzliche APIs und Marktdaten-Integrationen fehlen aktuell noch.

## Vergleich

### ✅ In Sync

- Ein Trading-Bot-Baustein ist mit `Zenbot_trader` bereits vorhanden.

### ⚠ Missing in Setup

- `Zenbot API`, `Web3 APIs` und `Exchange APIs` fehlen noch als eigene Integrationsmodule.
- Es gibt noch kein dediziertes Trading-Profilskript oder Backtest-Workflow-Modul.

### ❌ Missing in Docs

- Dieses Profil war lokal bislang noch nicht als eigene Zielseite vorhanden.

## Hinweise

- Das Profil ist aktuell eher analyse- und botnah, nicht als vollautomatisches Handelssystem umgesetzt.
