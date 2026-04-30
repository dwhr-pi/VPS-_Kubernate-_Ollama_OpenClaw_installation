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
- Default ist Paper-Trading
- kein Live-Trading ohne explizite Aktivierung
- Wallets und Keys nie im Repo speichern

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
