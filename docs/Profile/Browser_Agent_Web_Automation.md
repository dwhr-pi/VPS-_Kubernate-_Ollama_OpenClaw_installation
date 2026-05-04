# Browser_Agent_Web_Automation

## Zweck
Lokale Browser-Agenten, Web-Automatisierung, Screenshot-Workflows, Web-Tests, strukturierte Seitenauswertung und sicheres Research auf `127.0.0.1`.

## Typische Aufgaben
- UI- und Smoke-Tests
- Formular-Automatisierung
- Website-Analyse und Text-Extraktion
- kontrolliertes Crawling und Archivierung

## Empfohlene Tools
Playwright, Browser Use, Firecrawl, Trafilatura, ArchiveBox, changedetection.io, SearXNG.

## Optionale Tools
wget, curl, Puppeteer, Zotero.

## Benötigte Ports
`5000`, `8000`, `8888`

## Ressourcenbedarf
Mindestens 4 GB RAM, 2 CPU-Kerne, Docker für die Archiv-/Monitoring-Dienste.

## Sicherheitsrisiken
Browser-Automation kann Logins, Sessions und sensible Inhalte berühren. Externe Ziele nur bewusst freigeben und keine produktiven Konten als Default verwenden.

## Ollama/OpenClaw-Fit
Sehr gut für agentische Web-Recherche, Browser-Task-Ausführung und Test-Automation.

## LiteLLM/Open WebUI-Fit
Gut für Browser-nahe Assistenz-Workflows und Tool-Aufrufe, aber nicht als öffentlich freigegebene Default-Oberfläche.

## Quickstart
`bash scripts/profiles/Browser_Agent_Web_Automation_install.sh`

## Deinstallation
`bash scripts/profiles/Browser_Agent_Web_Automation_uninstall.sh`

## Sinnvolle lokale Modelle
`qwen2.5-coder`, `devstral`, `llama3.1`, kleine Vision- oder Browser-Planungsmodelle hinter LiteLLM.

## Grenzen und Warnhinweise
Keine Intrusion-, Credential- oder Doxxing-Anwendungsfälle. Web-Automatisierung nur legal, nachvollziehbar und mit Safe-Mode.
