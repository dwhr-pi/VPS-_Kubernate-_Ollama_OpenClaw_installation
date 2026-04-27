# Profil: Programmierer

## Überblick

Dieses Profil wurde aus `readme.md`, `docs/setup_guide.md` und `scripts/profiles/Programmierer_install.sh` zusammengeführt.
Es ist aktuell auf Entwicklungs- und Automatisierungs-Workflows ausgerichtet.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `build-essential`
- Profil-Tooling:
  - Huginn unter `/opt/huginn`
  - Clawhub CLI unter `/opt/clawhub-cli`
  - symbolischer Link `/usr/local/bin/clawhub`, sofern `bin/run` vorhanden ist

## Verantwortlichkeiten

- Entwicklungsnahe Automatisierung
- CLI-gestützte Agenten-Interaktion
- Web-Workflow-Orchestrierung über Huginn

## Verfügbare Kommandos

```bash
scripts/tools/huginn_install.sh
scripts/tools/clawhub_cli_install.sh
RAILS_ENV=production bundle exec rails server -p 3000
clawhub
```

## Vergleich

### ✅ In Sync

- Huginn ist sowohl dokumentiert als auch script-seitig eingebunden.
- Clawhub CLI ist sowohl im Menü als auch im Profilskript enthalten.

### ⚠ Missing in Setup

- Das in der Doku erwähnte Coding-Modell wie DeepSeek Coder wird nicht automatisch via Ollama installiert.
- Eine echte Entwickler-Toolchain über Huginn/Clawhub hinaus fehlt.

### ❌ Missing in Docs

- Die konkrete CLI-Verlinkung nach `/usr/local/bin/clawhub` ist in der allgemeinen Doku kaum sichtbar.

## Hinweise

- Huginn benötigt manuelle `.env`-Anpassung und einen manuellen Start.
- Standardport von Huginn ist `3000` und kollidiert potenziell mit OpenClaw, Flowise, Activepieces und Zenbot.
