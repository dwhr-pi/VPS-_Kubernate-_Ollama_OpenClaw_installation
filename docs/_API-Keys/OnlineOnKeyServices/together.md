# Together AI API

## Sinn und Zweck

Optionaler externer Inferenzanbieter, keine lokale Modellinstallation.
Ollama bleibt Standard; kein automatischer Cloud-Fallback.

## Pruefstand und Kosten

Gezielte Quellenpruefung **11.11.2026**, keine Anmeldung oder Inferenz.
Die [Billing-Dokumentation](https://docs.together.ai/docs/billing-credits)
ordnet Self-Service als **paid-prepaid** ein: kein allgemeiner Free Trial,
mindestens 15 USD Erstkauf je Organisation, spaeter mindestens 5 USD.
Scale-/Enterprise-Vertraege koennen abweichen. Kein automatisches Aufladen
aktivieren; Credit-Ablauf, Zahlungsmittel, Preise und Quoten vor Kauf pruefen.

Eigener `TOGETHER_API_KEY`, getrennt von MiniMax oder OpenRouter, nur ausserhalb
von Git im [ENV-Tresor](../../ENV_VAULT.md) ablegen. Die Dokumentation ist kein
Live-Nachweis einer Setup-Integration und aktiviert keinen Provider.

## Datenfreigabe

Laut [Datenschutzdokumentation](https://docs.together.ai/docs/privacy-and-security)
werden Prompts und Antworten standardmaessig gespeichert. Training ist separat
opt-in; Passthrough ist standardmaessig aktiv und kann Daten an Drittanbieter
weitergeben. ZDR und Passthrough bewusst auf Organisationsebene pruefen;
persoenliche Kontoeinstellungen sind kein Ersatz. Vor Nutzung Modell-ID,
Kosten und Datenfreigabe bestaetigen. Kein pauschales Datenschutzversprechen.

Zurueck zu [API-Zugaengen](../README.md) und zum
[Hybrid-/MCP-Review](../../HYBRID_CLOUD_MCP.md).
