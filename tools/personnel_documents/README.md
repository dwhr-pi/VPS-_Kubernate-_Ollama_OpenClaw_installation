# Personnel Documents AI

Lokaler Prototyp fuer Metadaten-Vorschlaege aus OCR-Text. Keine Personalakte,
kein Factorial-Ersatz, keine automatische DSGVO-/GoBD-Konformitaet.

[Deutsche Anleitung und Grenzen](../../docs/tools/personnel-documents.md).

`pipeline.py plan` und `validate --input <proposal.json>` laufen offline.
`infer` braucht eine bewusst angegebene Datei, lokales Modell und
`--allow-local-inference`. Kein Paperless-Schreiben, RAG, Cloud-Fallback oder
automatischer Modell-Download. Ausschliesslich synthetische Daten fuer Tests.
