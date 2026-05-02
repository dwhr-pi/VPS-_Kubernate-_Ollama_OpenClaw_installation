# Profil: Trading_Analysis

## Zweck
Sicherer Analysepfad für Marktbeobachtung, Backtesting, Risikoauswertung und Paper-Trading ohne automatische Live-Ausführung.

## Use Cases
- Marktanalyse
- Strategie-Vergleich
- historische Backtests
- Paper-Trading
- Alerts und Portfolio-Überwachung

## Enthaltene Tools
- `Trading_AI`
- `Trading_Crypto_Web3`
- `Web3_Crypto_Tools`
- `Backtest_Workflow`
- `Risk_Strategy_Analyzer`

## Installation
Dieses Profil ist derzeit bewusst als Dokumentations- und Sicherheitsprofil gedacht. Nutze die bestehenden Trading-/Web3-Profile nur im Analyse- und Simulationsmodus.

## Ports
- keine festen Pflicht-Ports

## Modelle
- lokale Ollama-Modelle nur für Analyse, Zusammenfassung und Auswertung
- keine autonome Orderlogik durch LLMs

## Abhängigkeiten
- optional Börsen-APIs
- optional RPC-Zugänge

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: gering bis mittel, je nach Backtests und Datensätzen

## Sicherheitshinweise
- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- Keine Anlage- oder Finanzberatung.
- Keine autonome Live-Orderausführung.
- Seed-Phrases, Private Keys und echte Exchange-Secrets niemals im Repo speichern.
- Erst Analyse, dann Simulation, dann höchstens manuelle Ausführung.

## Start / Stop / Status Befehle
```bash
zenbot --help || true
```

## Test-Command
```bash
echo "Trading_Analysis ist ein sicherer Dokumentationspfad für Analyse, Backtesting und Paper-Trading."
```

## Deinstallation
Keine eigene Deinstallation nötig. Es handelt sich um einen empfohlenen Sicherheits- und Arbeitsmodus.
