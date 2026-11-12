# MiniMax API

## Sinn und Zweck

Optionaler externer Modellanbieter mit eigenem API-Schluessel, kein lokaler Installer.
Der Cloud-Zugang ist vom [lokalen MiniMax-M3-Modellbetrieb](../../HYBRID_CLOUD_MCP.md)
zu trennen. Ollama bleibt der lokale Standard; kein automatischer Cloud-Fallback.

## Pruefstand

Gezielte Dokumentationspruefung: **11.11.2026**. Keine Installation, Anmeldung,
Zahlung, Schluesselabfrage oder Provider-Inferenz ausgefuehrt. Kein Live-Nachweis
einer Integration in OpenClaw, LiteLLM oder FreeLLMAPI.

## Konto, Key und Kosten

Auf der [offiziellen Plattform](https://platform.minimax.io/docs/guides/quickstart-preparation)
registrieren und unter API Keys einen Pay-as-you-go-Key erstellen.
Der **M Plan Subscription Key** ist getrennt: Er benoetigt zugewiesene Ressourcen,
einen Seat oder Credits. Ein erzeugter Key belegt keinen Gratiszugang.
Free Tier, Trial, Promo, Ablauf, Zahlungsmittel und Quoten sind fuer das konkrete
Konto vor Nutzung zu pruefen; hier nicht zugesichert.
Die [offizielle Preisliste](https://platform.minimax.io/docs/pricing/overview)
unterscheidet Modelle, Kontextlaengen und Service-Tiers; keine pauschale Flatrate.

## Einbindung und Datenschutz

- Native Beispiele verwenden `MINIMAX_API_KEY`.
- OpenAI-kompatible Base-URL: `https://api.minimax.io/v1`.
- Anthropic-kompatible Base-URL: `https://api.minimax.io/anthropic`.
- SDK-Aliase nur im freigegebenen Client-Prozess setzen, nicht global in der Shell
  oder systemweit; fremde OpenAI-/Anthropic-Keys nicht wiederverwenden.
- Echte Werte ausschliesslich ausserhalb von Git speichern, etwa im
  [ENV-Tresor](../../ENV_VAULT.md). Keine Keys in Prompts oder Logs.
- Vor Cloud-Nutzung Datenfreigabe, Budget und Modell-ID bestaetigen. Aufbewahrung,
  Training, Region und vertragliche Datenschutzbedingungen sind hier nicht
  abschliessend geprueft; keine Zusicherung von ZDR oder EU-Verarbeitung.

Zurueck zu [API-Zugaengen](../README.md),
[Online-Diensten](README.md) und [Anbieter-Katalog](../PROVIDER_KEY_CATALOG.md).
