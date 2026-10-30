# Quellenbericht: Anmeldung, Zahlung und Identitaet

Pruefdatum: **2026-10-23**. Anlass: offizielle Wege zum API-Schluessel, kostenloses Kontingent,
Kreditkarte/PayPal/Klarna/Krypto, Mindesteinzahlung und moegliche Identitaetsnachweise fuer die
Webseiten des Setup-Katalogs.

Ergebnis: [Anbieterleitfaden](../REGISTRATION_BILLING_AND_IDENTITY.md) und
[Dienst-/OAuth-/lokale Tokens](../SERVICE_TOKEN_REGISTRATION.md). Die dort bei den jeweiligen
Aussagen erhaltenen offiziellen URLs sind die nachlesbaren Belege; keine oeffentlich geteilten
API-Keys wurden verwendet.

## Konkrete Befunde

- Cerebras: 5 USD Trial, 30 Tage, verifiziertes Zahlungsmittel; keine Zahlung fuer das Trial selbst
  laut [FAQ](https://inference-docs.cerebras.ai/support/rate-limits).
- Together: mindestens 15 USD erster Credit-Kauf, kein Standard-Free-Trial;
  [Credits](https://docs.together.ai/docs/billing-credits) und
  [Karte/ACH](https://docs.together.ai/docs/billing-payment-methods) getrennt.
- OpenRouter: 5 USD Mindestkauf laut [AGB](https://openrouter.ai/terms); 10 USD fuer hoeheres
  Free-Modell-Limit ist eine andere Schwelle. [Support](https://openrouter.ai/support) nennt USDC
  und PayPal in Arbeit. Free-Modellbeschreibungen/AGB sind nicht durch einen Accounttest
  abgeglichen.
- token8341: [Homepage](https://www.token8341.com/en) wirbt weiter mit 0,5 CNY Trial und Bonus ab 5
  CNY. Konkrete Zahlarten und KYC bleiben offen; Endpunktwidersprueche werden durch diese Werbung
  nicht aufgeloest.
- Gemini: aktuelles [Billing](https://ai.google.dev/gemini-api/docs/billing) beschreibt bei
  Prepay-Zuweisung mindestens 5 USD, teilweise Postpay. Keine pauschale Gleichsetzung mit dem
  Google-Cloud-Free-Trial.
- Alibaba Model Studio:
  [Freiquota](https://www.alibabacloud.com/help/en/model-studio/new-free-quota) fuer teilnehmende
  Singapore/International-Modelle, 90 Tage; Free Quota Only standardmaessig aus, daher moeglicher
  PAYG-Uebergang.
- Hugging Face: aktuelle
  [Inference-Preistabelle](https://huggingface.co/docs/inference-providers/pricing) nennt fuer Free
  Users keine monatlichen Credits. Alte 0,10-USD-Angaben nicht ungeprueft weiterfuehren.
- Firecrawl: aktuelle [Preisseite](https://www.firecrawl.dev/pricing) nennt 1.000 Credits/Monat ohne
  Karte; alte einmalige 500-Credit-Angaben nicht als heutigen Standard uebernehmen.
- Brave: [API-Seite](https://brave.com/search/api/) nennt 5 USD Gratis-Credits monatlich, aber Karte
  zur Missbrauchsabwehr.
- Deepgram: [Preisseite](https://deepgram.com/pricing) nennt 200 USD Startguthaben ohne Kreditkarte.
- Anthropic:
  [ID-Verifizierung](https://support.claude.com/en/articles/14328960-identity-verification-on-claude)
  kann amtlichen Ausweis/Selfie/Firmenangaben umfassen; nicht jeder Konto-/API-Zugang ist damit als
  generell KYC-pflichtig belegt.

## Grenzen dieser Pruefung

Oeffentliche Seiten und Dokumentation, keine Anmeldung oder Checkout. Kein Key-Erzeugen, keine
API-Anfrage, Zahlung, Karten-/KYC-Pruefung, Installation, Automationsaenderung oder Cloud-Freigabe.
UB-Felder bleiben offen; keine Vollstaendigkeitsbehauptung zu allen Laendern, Sondervertraegen,
Zahlungsarten oder Identitaetsanforderungen.

Einige Seiten lieferten 403/404 oder nur dynamische Inhalte. W&B-Authorize leitete auf CoreWeave
Forge weiter. Diese Luecken sind im Leitfaden erhalten, nicht in ein vermeintliches Nein zu
Zugang/Zahlung umgewandelt. Zugriffsquellen aus bisherigen datierten Berichten bleiben erhalten.
