# Personnel Documents AI

Lokaler Prototyp fuer Metadaten-Vorschlaege aus OCR-Text. Keine Personalakte,
kein Factorial-Ersatz, keine automatische DSGVO-/GoBD-Konformitaet.

[Deutsche Anleitung und Grenzen](../../docs/tools/personnel-documents.md).

`pipeline.py plan` und `validate --input <proposal.json>` laufen offline.
`manage.py install` installiert einen privaten, pruefsummengesicherten
Starter aus diesem GitHub-Checkout ohne Docker/Paketdownload. `status`,
`doctor`, `update` und `uninstall` verwalten nur diesen Starter; Paperless,
Modelle und persoenliche Akten bleiben unberuehrt. Der Checkout muss erhalten bleiben.
`infer` braucht eine bewusst angegebene Datei, lokales Modell und
`--allow-local-inference`. Kein Paperless-Schreiben, RAG, Cloud-Fallback oder
automatischer Modell-Download. Ausschliesslich synthetische Daten fuer Tests.
