# Profil: Trading_Crypto_Web3

## Zweck
Paper-Trading- und Web3-Profil mit Safe-Mode-Defaults und klaren Wallet-Warnungen.

## Use Cases
- Marktanalyse
- Paper-Trading
- Web3-Experimente
- Bot-Strategietests

## Enthaltene Tools
- Zenbot
- CCXT-nahe Exchange-Integrationen
- Web3 APIs

## Installation
```bash
scripts/profiles/Trading_Crypto_Web3_install.sh
```

## Ports
- projektabhängig

## Modelle
- lokal oder cloudbasiert für Analyse

## Abhängigkeiten
- API-Keys optional

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: gering

## Sicherheitshinweise
- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- Dieses Profil ist keine Finanz- oder Anlageberatung.
- Default ist Paper-Trading
- kein Live-Trading ohne explizite Aktivierung
- Wallets und Keys nie im Repo speichern
- keine autonomen Kauf-/Verkaufsentscheidungen durch LLMs oder Agenten zulassen
- empfohlen sind Analyse, Backtesting, Alerts und Simulation statt Live-Execution
- Trenne Analyse und Ausführung bewusst:
  - [Trading_Analysis.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/Trading_Analysis.md:1)
  - [Trading_Execution_Manual_Mode.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/Trading_Execution_Manual_Mode.md:1)

## Start / Stop / Status Befehle
```bash
zenbot --help || true
```

## Test-Command
```bash
bash scripts/profiles/Trading_Crypto_Web3_install.sh
```

## Deinstallation
```bash
scripts/profiles/Trading_Crypto_Web3_uninstall.sh
```
