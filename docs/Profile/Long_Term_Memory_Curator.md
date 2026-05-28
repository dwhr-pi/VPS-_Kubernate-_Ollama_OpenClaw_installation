# Long_Term_Memory_Curator

## Zweck
Langzeit-Memory kuratieren, deduplizieren und mit Datenschutzregeln versehen.

## Typische Aufgaben
- Chat- und Markdown-Exporte importfaehig machen.
- Dubletten, alte Fakten und sensible Inhalte markieren.
- Memory-Retention-Regeln definieren.

## Empfohlene Tools
Qdrant, ChromaDB, DuckDB, Open WebUI Memory, LlamaIndex.

## Hardwarebedarf und Status
Hardware: mittel. Status: planned. Installationsart: local, WSL2, Home-Server.

## Datenschutz und Sicherheit
Memory ist besonders sensibel. Loeschregeln, Exportkontrolle und lokale Speicherung sind Pflicht.

## Beispiel-Prompt
`Klassifiziere diese Memory-Eintraege nach behalten, aktualisieren, loeschen und privat.`

## Modelle
Ollama: `llama3.1:8b`.

## Grenzen
Keine dauerhafte Speicherung von Passwoertern, Tokens oder intimen Daten.
