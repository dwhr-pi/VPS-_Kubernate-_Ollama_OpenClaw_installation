# Profil: Web3_Crypto_Tools

## Zweck
Profil für Wallet-Analyse, RPC-Tests, Token- und Contract-Checks mit lokalen Tools.

## Use Cases
- Smart-Contract-Analyse
- RPC- und Wallet-Diagnose
- Web3-Entwicklung ohne automatische Finanzaktionen

## Enthaltene Tools
- Foundry
- Hardhat
- Ethers.js
- Web3.py

## Installation
```bash
scripts/profiles/Web3_Crypto_Tools_install.sh
```

## Ports
- keine festen Ports nötig

## Modelle
- optional lokale LLMs für Contract-Review

## Abhängigkeiten
- Node.js
- Python

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: ab 10 GB

## Sicherheitshinweise
- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- keine Seed-Phrases oder Private Keys im Repo
- keine automatische Trading- oder Finanzberatung
- Paper-/Dry-Run zuerst
- keine Live-Order-Automation durch KI oder Agenten
- Wallet-, RPC- und Contract-Zugänge immer als Hochrisiko-Zugang behandeln
- Empfohlene Trennung:
  - [Trading_Analysis.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/Trading_Analysis.md:1)
  - [Trading_Execution_Manual_Mode.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profile/Trading_Execution_Manual_Mode.md:1)

## Start / Stop / Status Befehle
```bash
foundryup --version 2>/dev/null || true
hardhat --version 2>/dev/null || true
```

## Test-Command
```bash
bash scripts/profiles/Web3_Crypto_Tools_install.sh
```

## Deinstallation
```bash
scripts/profiles/Web3_Crypto_Tools_uninstall.sh
```
