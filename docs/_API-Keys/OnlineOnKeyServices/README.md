# OnlineOnKeyServices: ein API-Schluessel fuer mehrere Modelle

**Ein API-Schluessel, ein zentraler Zugang, mehrere KI-Modelle:**
API-Aggregatoren vermitteln zwischen deinem vorhandenen Client und
unterschiedlichen Modellanbietern. Du waehlst ein Modell per Modell-ID;
der Aggregator vereinheitlicht Zugang und Abrechnung.

Diese Kategorie enthaelt **Online-Dienste, keine installierbaren Setup-Tools**.
Kein Installer, Docker-Container, Konto, API-Key oder Cloud-Fallback wird durch
diese Dokumentation angelegt oder aktiviert. Ollama bleibt der lokale Standard.
Ein API-Schluessel ist keine Flatrate und kein Zugang zu jedem existierenden Modell.

| Dienst | Zweck | Einordnung |
|---|---|---|
| [token8341 / TokenWorks](token8341.md) | Ein Zugang zu mehreren Modellen, etwa DeepSeek, Qwen, Kimi, GLM und MiniMax laut Katalog | Externer Aggregator; widerspruechliche Betreiber-/Endpunktangaben vor Nutzung klaeren |
| [OpenRouter](openrouter.md) | Gemeinsame API, Modellauswahl und konfigurierbares Routing zu Modellprovidern | Externer Aggregator; Modell, Provider, Preise und Datenschutz separat pruefen |

Beide sind im Grundprinzip vergleichbar, aber nicht technisch, rechtlich oder
wirtschaftlich gleichzusetzen. Konto und Schluessel sind nicht austauschbar.
In FreeLLMAPI ist **OpenRouter bereits eingebaut**; **token8341 ist ein
grundsaetzlich anschliessbarer Custom-Endpunkt**, ohne bestaetigten Live-Test.
Die jeweiligen Seiten beschreiben Einrichtung und Grenzen am Setup-Pin.
Ein Client auf WSL, einem VPS oder Kubernetes macht Cloud-Inferenz nicht lokal.
Private Daten und Geheimnisse duerfen nicht durch einen stillen Fallback abfliessen.

Zurueck zu [Allen API-Schluesseln](../README.md),
[FreeLLMAPI](../../tools/freellmapi.md) oder dem [Tool-Index](../../TOOL_INDEX.md).
