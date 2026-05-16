# Playwright Integration Guide

## Kurzfassung

Playwright ist ein Browser-Automation-Framework fuer Webtests, Screenshots, Crawling, Formularpruefung und kontrollierte Browser-Agenten. Es ist kein dauerhafter Dienst mit eigenem Webinterface.

Nach der Installation liegt die Python-Umgebung typischerweise in:

```bash
/opt/playwright/venv
```

Wichtig: Eine installierte Python-Bibliothek reicht bei Playwright oft noch nicht aus. Fuer echte Browserlaeufe muessen zusaetzlich die Browser-Binaries vorhanden sein.

## Installation pruefen

```bash
source /opt/playwright/venv/bin/activate
python -c "import playwright; print('Playwright Python OK')"
python -m playwright --version
```

Browser-Binaries pruefen beziehungsweise installieren:

```bash
source /opt/playwright/venv/bin/activate
python -m playwright install chromium
```

Falls Systembibliotheken fehlen:

```bash
source /opt/playwright/venv/bin/activate
python -m playwright install-deps chromium
```

Auf WSL2 oder VPS ohne Desktop laeuft Playwright normalerweise headless.

## Wofuer ist Playwright sinnvoll?

- Webseiten automatisiert testen
- Screenshots erzeugen
- Login-/Formularablaeufe im eigenen System pruefen
- lokale Open WebUI-, Huginn-, n8n- oder Grafana-UIs testen
- kontrolliertes Crawling eigener oder erlaubter Webseiten
- HTML-Inhalte fuer RAG/Recherche erfassen
- Browser-Agenten mit klarer Allowlist bauen

## Welche vorhandenen Tools koennen Playwright nutzen?

| Tool/Profil | Playwright-Nutzen | Integrationsart |
|---|---|---|
| OpenClaw | Browser-Tool fuer erlaubte Webaufgaben | Tool-/Worker-Skript |
| Browser_Automation_Agent | Kernwerkzeug fuer Tests, Screenshots, Crawling | direkt |
| OSINT_Research | Screenshots und Quellenpruefung oeffentlicher Quellen | nur legal/defensiv |
| Huginn | externer Screenshot-/Browser-Worker | Script/Webhook |
| n8n | Browser-Worker per Execute Command/Webhook | Automation-Bruecke |
| LangGraph | Browser-Knoten in kontrolliertem Graph | Worker |
| CrewAI | Tool-Agent fuer Webpruefung | Worker |
| AutoGen | Browser-Agent mit User-Proxy-Freigabe | Worker |
| Open WebUI/Grafana/Huginn/n8n | UI-Smoke-Tests | lokale Tests |

## Minimales Beispiel

Dateiidee fuer spaeter:

`scripts/playwright/screenshot_url.py`

Ziel:

```bash
source /opt/playwright/venv/bin/activate
python scripts/playwright/screenshot_url.py http://127.0.0.1:3002
```

Ergebnisordner:

```bash
~/.openclaw_ultimate_user_data/playwright/screenshots/
```

## OpenClaw-Zielbild

```text
OpenClaw Task
  -> scripts/playwright/browser_worker.py
  -> Playwright Chromium headless
  -> Screenshot/HTML/Markdown/JSON
  -> Ergebnis unter ~/.openclaw_ultimate_user_data/playwright/
  -> OpenClaw liest Ergebnis ein
```

## Sicherheitsregeln

- Nur erlaubte Domains/IPs automatisieren.
- Keine heimlichen Logins oder Session-Diebstahl.
- Keine Captcha-Umgehung.
- Keine aggressive Last, Scraping nur mit Rate-Limit.
- Keine fremden Accounts automatisieren.
- Cookies, Screenshots und HTML-Dumps koennen sensible Daten enthalten und gehoeren nicht ins Repo.
- Default fuer OpenClaw: `read-only`, Allowlist, Rate-Limit.

## TODO fuer spaeter

- [ ] `scripts/playwright/browser_worker.py` erstellen.
- [ ] `scripts/playwright/screenshot_url.py` erstellen.
- [ ] Allowlist-Konfiguration unter `~/.openclaw_ultimate_user_data/playwright/allowed_targets.txt`.
- [ ] Doctor-Check: Playwright importierbar und Chromium installiert?
- [ ] OpenClaw-Tooldefinition fuer Browser-Screenshot und HTML-Extraktion.
- [ ] n8n-/Huginn-Beispiel fuer lokalen Screenshot-Worker.
- [ ] Ergebnis-Redaction fuer Cookies, Tokens und private HTML-Inhalte.
