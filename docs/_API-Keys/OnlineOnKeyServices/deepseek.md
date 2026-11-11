# DeepSeek API

## Sinn und Zweck

Optionaler externer Modellzugang, kein lokaler [DeepSeek-R1-Build](../../tools/deepseek-r1.md).
Open-Weight-/Code-Lizenzen machen den betriebenen Cloud-Dienst nicht kostenlos
oder lokal. API-Modellnamen koennen andere Modellgenerationen bezeichnen.

## Pruefstand und Zugang

Gezielte Quellenpruefung: **11.11.2026**, keine Anmeldung, Zahlung oder Inferenz.
Die [offizielle API-Anleitung](https://api-docs.deepseek.com/) nennt einen
eigenen `DEEPSEEK_API_KEY`, die OpenAI-kompatible Base-URL
`https://api.deepseek.com` und fuer Anthropic-Kompatibilitaet
`https://api.deepseek.com/anthropic`. Nur fuer den explizit gewaehlten Client
konfigurieren, keine globalen OpenAI-/Anthropic-Keys ueberschreiben.

Vor Nutzung Modell-ID, Preise, Budget, Quoten, Trial/Promo, Credit-Ablauf und
Zahlungsmittel direkt beim Anbieter pruefen. Kein Free Tier zugesichert;
kein getesteter Setup-Connector und kein automatischer Cloud-Fallback.
Aufbewahrung, Training und Datenregion sind hier nicht abschliessend geprueft.
Keine privaten Quellen ohne ausdrueckliche Kosten-/Datenschutzfreigabe senden.
Echte Keys nur im externen [ENV-Tresor](../../ENV_VAULT.md), nie in Git oder Logs.

Zurueck zu [API-Zugaengen](../README.md).
