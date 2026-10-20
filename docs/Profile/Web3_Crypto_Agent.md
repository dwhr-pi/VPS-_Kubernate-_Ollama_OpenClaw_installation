# Profil: Web3_Crypto_Agent

## Zweck
Web3- und Krypto-Agent mit Portfolio-, RPC- und Simulationsfokus.

## Use Cases
- Wallet-Monitoring
- Token-Checks
- Portfolio-Analyse
- Trading-Simulation

## Enthaltene Tools
- Web3 APIs
- Exchange APIs
- Zenbot API
- Zenbot Trader
- Risk Strategy Analyzer

## Installation
```bash
scripts/profiles/Web3_Crypto_Agent_install.sh
```

## Ports
- projektabhängig

## Modelle
- Analysemodelle lokal oder hybrid

## Abhängigkeiten
- API-Zugänge optional

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: 8 GB+
- Storage: gering

## Sicherheitshinweise
- [Automaton von Conway Research](../tools/automaton.md) ist optional `planned`:
  nur Offline-Review, keine automatische Profilabhaengigkeit, keine Uebergabe
  vorhandener Wallet-Schluessel und kein autonomes Trading.
- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- Das Profil ist für Monitoring, Analyse und Simulation gedacht, nicht für autonome Finanzentscheidungen.
- keine Seed-Phrases
- keine privaten Keys im Repo
- kein Live-Trading als Default
- keine AI-gesteuerte automatische Orderausführung ohne ausdrückliche manuelle Kontrolle
- Empfohlene Trennung:
  - [Trading_Analysis.md](Trading_Analysis.md)
  - [Trading_Execution_Manual_Mode.md](Trading_Execution_Manual_Mode.md)

## Start / Stop / Status Befehle
```bash
zenbot --help || true
```

## Test-Command
```bash
bash scripts/profiles/Web3_Crypto_Agent_install.sh
```

## Deinstallation
```bash
scripts/profiles/Web3_Crypto_Agent_uninstall.sh
```
