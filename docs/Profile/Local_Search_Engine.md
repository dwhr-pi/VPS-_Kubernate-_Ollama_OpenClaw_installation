# Local_Search_Engine

## Zweck
Lokale Suche ueber Dokumente, Notizen, Logs und Web-Exporte.

## Typische Aufgaben
- Meilisearch/SearXNG/DuckDB-Suchpfade planen.
- Indexe aktualisieren und sensible Quellen ausschliessen.
- Suchqualitaet testen.

## Empfohlene Tools
Meilisearch, SearXNG, DuckDB, Apache Tika, Docling, Qdrant.

## Hardwarebedarf und Status
Hardware: mittel. Status: planned. Installationsart: local, Home-Server, VPS nur mit Auth.

## Datenschutz und Sicherheit
Suchindexe enthalten Textfragmente. Keine oeffentliche Suche ueber private Daten.

## Beispiel-Prompt
`Entwirf eine lokale Suchstruktur fuer Markdown, PDFs und Setup-Logs mit Ausschluss sensibler Pfade.`

## Modelle
Ollama: `llama3.1:8b`.

## Grenzen
Keine ungefilterte Indexierung von Secrets, Mailboxen oder Browserprofilen.
