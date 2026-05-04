# Profil: Browser_Automation_Agent

## Zweck

Kontrollierte Browser-Automation fuer Tests, Screenshots, UI-Pruefungen und legale Web-Analysen.

## Installierbare Kern-Tools

- `playwright`
- `puppeteer`
- `open_webui`

## Optionale / noch nicht sauber verdrahtete Tools

- `browser-use`
- `Firecrawl` oder vergleichbare Crawl-Layer
- dedizierte Screenshot-/Archive-Workflows

## Hardware / Plattform

- gut fuer `WSL2`, `Workstation`, `VPS`
- moderater CPU-/RAM-Bedarf

## Risiken und Grenzen

- keine ungefragte Account- oder Formularautomation
- Scraping, Login-Flows und Erfassung personenbezogener Daten nur mit klarer Rechtsgrundlage

## Quickstart

```bash
bash scripts/profiles/Browser_Automation_Agent_install.sh
```
