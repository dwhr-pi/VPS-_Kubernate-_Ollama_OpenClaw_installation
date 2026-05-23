# Data Scraping Browser Agents

Status: `planned`  
Hardwarebedarf: `medium`  
Installationsart: lokal, VPS, Kubernetes spaeter

## Zweck

Browser-Automation, Webseitenanalyse, Crawling mit Rate-Limits und lokale Extraktion fuer RAG/Recherche.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| Playwright | robuste Browser-Automation | empfohlen |
| Firecrawl | Webseiten zu Markdown/API | optional |
| Browserless | Remote-Browser-Service | optional |
| trafilatura/newspaper4k | Artikel-Extraktion | empfohlen |

## Sicherheits- und Fairnessregeln

- Robots.txt, Rate-Limits und Nutzungsbedingungen beachten.
- Keine Login-Umgehung, kein Credential-Harvesting.
- Crawler standardmaessig mit niedriger Parallelitaet.
