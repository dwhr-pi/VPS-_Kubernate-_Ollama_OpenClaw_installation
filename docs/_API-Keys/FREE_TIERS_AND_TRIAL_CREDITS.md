# Kostenlose LLM-Zugaenge: Quellen, Trial-Credits und eigene Auswertung

**Wochenpruefung vom 26.10.2026:** [Aktueller Bericht](reviews/2026-10-26.md). Die unten datierte
Tabelle vom 21.10. bleibt als historischer Vergleich erhalten. Neu ergaenzt: Ollama-Cloud-Credits,
Together-Datenablage und Gemini-Tarifausnahmen.

| Anbieter                  | Offizielle Webseite                     | Neu dokumentierter Punkt                                                                                                                                        | Primaerbeleg                                                      |
| ------------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Ollama Cloud, nicht lokal | [ollama.com](https://ollama.com/)       | Free mit unbezifferten Starter-Credits, monatlicher Reset; gekaufte Credits gesondert. Keine unbegrenzte Cloud-Nutzung                                          | [Preise](https://ollama.com/pricing)                              |
| Together AI               | [together.ai](https://www.together.ai/) | Inhaltsablage/Produktverbesserung und Passthrough standardmaessig aktiv; Training ist separates Opt-in. Organisations-ZDR gesondert pruefen                     | [Datenregeln](https://docs.together.ai/docs/privacy-and-security) |
| Gemini                    | [ai.google.dev](https://ai.google.dev/) | Bezahlter Contributor-Preview erlaubt Produktverbesserung. Befristete Preise und angekuendigte Erhoehungen zum 01.12.2026 bzw. 01.01.2027 modellbezogen pruefen | [Preise](https://ai.google.dev/gemini-api/docs/pricing)           |

Dies ergaenzt unsere Dokumentation; der genaue Zeitpunkt einer Anbieterumstellung ist nicht
bewiesen. Kein kostenloser Router-Katalog ersetzt die aktuellen Bedingungen.

**Ergaenzung vom 23.10.2026:**
[Key-Erhalt, Mindestkaeufe, Zahlungsmittel und Identitaetspruefung](REGISTRATION_BILLING_AND_IDENTITY.md)
sowie [weiterer Dienstzugang](SERVICE_TOKEN_REGISTRATION.md). Der unten datierte Vergleich vom
21.10. bleibt nachvollziehbar erhalten; neu gelesene Belege und offene Punkte stehen im
[Bericht vom 23.10.](reviews/2026-10-23-registration-billing.md).

**Zweck:** Nachlesbar unterscheiden, welche Modellanbieter ein begrenztes Free Tier, einmaliges
Trial oder nur bezahlten Zugang anbieten und wie das zu Ollama, OpenClaw und FreeLLMAPI passt.
**Keine echten API-Keys auflisten.** Letzte inhaltliche Pruefung: **2026-10-21**; keine Konten, Keys
oder Inferenzanfragen benutzt. Dies ist keine Live-Pruefung deines Accounts.

## Konkrete GitHub-Quellen statt unbestimmter Listen-Namen

| Quelle                                                                                                                 | Was dort zu finden ist                                                                     | Quellenkritik / eigene Einordnung                                                                         |
| ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| [mnfst/awesome-free-llm-apis](https://github.com/mnfst/awesome-free-llm-apis)                                          | Anbieter und Modelltabellen, nach eigenem Anspruch fortlaufende kostenlose API-Kontingente | Community-Verzeichnis, kein Vertrag; nicht als Liste garantierter Signup-Credits behandeln                |
| [freellms/awesome-freellm-apis](https://github.com/freellms/awesome-freellm-apis)                                      | Anbieter-Verzeichnis, Key-Anmeldeseiten, Konfigurationshilfen und Kontingente              | Betreiber-/Community-Sammlung; Aktualitaetswerbung und Modellzahlen nicht ungeprueft uebernehmen          |
| [raffiihza/free-llm-coding-credits](https://github.com/raffiihza/free-llm-coding-credits)                              | Coding-bezogene Promos, einmalige Credits und Trial-Angebote                               | Zeitkritisch; jede Aktion beim Originalanbieter nachpruefen, kein Beleg fuer dauerhaft kostenlose Nutzung |
| [devanasolver/awesome-free-llm-apis](https://github.com/devanasolver/awesome-free-llm-apis)                            | Trennt dauerhafte Free Tiers, Freemium, Trials und bezahlte Angebote                       | Weitere Recherchequelle, nicht alleinige Bestaetigung einer Provider-Bedingung                            |
| [GitHub Topic free-llm-api](https://github.com/topics/free-llm-api) und [free-llm](https://github.com/topics/free-llm) | Auffinden weiterer Projekte                                                                | Suchindex ohne Qualitaets-/Seriositaetsgarantie; kein Primaernachweis fuer Preis oder Datenschutz         |

Ein pauschaler Name wie `free-llm-api-keys` ohne Repository-Eigentuemer ist keine eindeutige
Quellenangabe. Der historische Pfad `https://github.com/cheahjs/free-llm-api-resources` und dessen
rohe README lieferten bei dieser Recherche **404**. Das beweist keine dauerhafte Loeschung, aber der
Inhalt konnte nicht bestaetigt werden. Deshalb wird dieser Pfad nicht als erreichbare aktuelle
Empfehlung ausgegeben.

Zwei konkrete Warnsignale aus den gelesenen Listen: Die
[FreeLLMs-README](https://github.com/freellms/awesome-freellm-apis/blob/main/README.md) wirbt mit
taeglicher Pflege, enthielt beim Abruf aber einen Datenstand vom 09.08.2026. Die
[Coding-Credits-README](https://github.com/raffiihza/free-llm-coding-credits/blob/main/README.md)
nennt den 21.06.2026 als letztes Update und empfiehlt einen weiteren Router. Sie beschreibt selbst
Risiken einer inoffiziellen OAuth-/Cookie-Anbindung bei einem Anbieter. Daraus folgt **keine
Empfehlung oder Freigabe dieses Routers**: keine Session-Cookies, fremden Logins oder bezahlten
API-Keys an solche Bruecken uebergeben. Datums-/Werbeangaben sind kein Aktualitaetsbeweis.

## Was OpenClaw, Ollama und FreeLLMAPI tatsaechlich belegen

| Primaere Projektquelle                                                                                                                                                                     | Aussagekraft                                                                                  | Keine daraus ableitbare Garantie                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [OpenClaw Provider-Verzeichnis](https://github.com/openclaw/openclaw/blob/main/docs/providers/index.md)                                                                                    | Dokumentierte Modellanbieter und Integrationswege                                             | Nicht jeder Anbieter ist kostenlos; Konfigurationsbeispiele sind keine Guthabenzusage             |
| [Ollama README](https://github.com/ollama/ollama/blob/main/README.md)                                                                                                                      | Lokale Modelle, Cloud-Angebote und Client-Anbindungen                                         | Ollama ist keine universelle Trial-Credit-Liste; lokal bedeutet nicht kostenfreier Strom/Hardware |
| [FreeLLMAPI unterstuetzte Plattformen am Setup-Pin](https://github.com/tashfeenahmed/freellmapi/blob/57c0669233bbe0c70a0f9f9927613192be948773/docs/en/providers/01-supported-platforms.md) | Adapter fuer unter anderem Google, Groq, Cerebras, NVIDIA, Mistral, OpenRouter und Cloudflare | Vorhandener Adapter bedeutet weder aktives Free Tier noch erfolgreiche Account-Pruefung           |

Wichtig im FreeLLMAPI-Verzeichnis: `ollama` bezeichnet dort **Ollama Cloud**, nicht automatisch
deinen lokalen Ollama-Server. Fuer die konkrete Version und lokale Einrichtung gilt
[unsere FreeLLMAPI-Dokumentation](../tools/freellmapi.md). Neue Bedingungen im Internet
aktualisieren keine installierten Adapter.

## Begriffe sauber trennen

| Kategorie      | Bedeutung                                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------- |
| `free-tier`    | Begrenztes, erneuerbares kostenfreies Kontingent nach aktuellen Bedingungen; kein Anspruch auf ewige Verfuegbarkeit |
| `trial`        | Einmaliges Startguthaben oder zeitlich begrenzte Erprobung; Ablauf und Voraussetzungen nennen                       |
| `promotion`    | Befristete Aktion fuer bestimmte Modelle/Accounts; keine Standardgrundlage                                          |
| `paid-prepaid` | Vorab bezahlter Zugang; keine kostenlose Startphase unterstellen                                                    |
| `local`        | Inferenz auf eigener Hardware, ohne entsprechende Cloud-Tokengebuehren; Betriebskosten bleiben                      |
| `unverified`   | Inhalt nicht bestaetigt, widerspruechlich, nicht erreichbar oder nur hinter Account sichtbar                        |

## Eigene Anbieter-Auswertung vom 21.10.2026

Die Tabellenzeilen beruhen auf oeffentlichen Primaerquellen, nicht auf einem Key-Test. Region,
Modell, Kontozustand und spaetere Tarifwechsel koennen abweichen. RPM = Anfragen/Minute, RPD =
Anfragen/Tag.

Offizielle Webseiten und Belegseiten sind bewusst getrennt: Die Homepage dient zur Orientierung, die
Primaerquelle belegt die jeweilige Bedingung.

| Anbieter                    | Offizielle Webseite                                | Einordnung / bestaetigter Umfang                                                                            | Voraussetzungen und Grenzen                                                                                                                                  | Primaerquelle                                                                                                                                                                                                    |
| --------------------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cloudflare Workers AI       | [cloudflare.com](https://www.cloudflare.com/)      | `free-tier`: 10.000 Neurons pro Tag; keine Umrechnung in pauschale Tokenzahl                                | Tagesreset UTC; bestimmte Modelle verlangen einen bezahlten Zugangsweg; auf Paid Kosten oberhalb Freimenge                                                   | [Workers-AI-Preise](https://developers.cloudflare.com/workers-ai/platform/pricing/)                                                                                                                              |
| Google Gemini Developer API | [Google AI for Developers](https://ai.google.dev/) | `free-tier` fuer ausgewaehlte Modelle und Funktionen                                                        | Kein pauschales hohes Tageslimit fuer alle Modelle; Free-/Paid-Datenverwendung unterscheidet sich; Verfuegbarkeit und Quoten beim konkreten Modell pruefen   | [Gemini-Preise](https://ai.google.dev/gemini-api/docs/pricing)                                                                                                                                                   |
| Groq                        | [groq.com](https://groq.com/)                      | `free-tier` mit modellabhaengiger Tabelle fuer Requests, Tokens und Audio                                   | Free- und Developer-Plan unterscheiden; Modell-/Organisationslimits statt universeller RPM-Zahl; persoenliches Konto nicht geprueft                          | [Groq Rate Limits](https://console.groq.com/docs/rate-limits)                                                                                                                                                    |
| Cerebras                    | [cerebras.ai](https://www.cerebras.ai/)            | **`trial`, kein dauerhaftes Free Tier**: 5 USD Credits, Ablauf nach 30 Tagen                                | Verifiziertes Zahlungsmittel erforderlich; ohne dieses bleibt API-/Playground-Zugang inaktiv; anschliessend Credits kaufen                                   | [Cerebras Rate Limits und Trial-FAQ](https://inference-docs.cerebras.ai/support/rate-limits)                                                                                                                     |
| NVIDIA API Catalog / NIM    | [NVIDIA API Catalog](https://build.nvidia.com/)    | `trial`: rate-limitierte Erprobung statt pauschalem Credit-Paket                                            | Anbieterhinweis vom 10.09.2025: nicht mehr credit-basiert; modellabhaengige Grenzwerte im Konto pruefen; kein universelles 40-RPM-/1.000-Credits-Versprechen | [NVIDIA-Mitarbeiterantwort](https://forums.developer.nvidia.com/t/request-more-4-000-credits-option-on-build-nvidia-com/344567/2), [API Catalog Quickstart](https://docs.api.nvidia.com/nim/docs/api-quickstart) |
| OpenRouter                  | [openrouter.ai](https://openrouter.ai/)            | `free-tier` fuer kostenlose Modellrouten: 20 RPM, 50 RPD; 1.000 RPD nach Kauf von mindestens 10 USD Credits | Erhoehte Grenze hat Kaufbedingung; kein allgemeines kostenloses Signup-Guthaben belegt; fehlgeschlagene Versuche zaehlen laut Preis-Seite gegen Tageslimit   | [OpenRouter-Preise / Limits](https://openrouter.ai/pricing)                                                                                                                                                      |
| Together AI                 | [together.ai](https://www.together.ai/)            | **`paid-prepaid`, derzeit kein kostenloses Trial**; erster Credit-Kauf mindestens 15 USD                    | Allgemeine Signup-Credit-Behauptung widerspricht der aktuellen Billing-Seite; separate Sonderaktionen nur mit eigenem Beleg aufnehmen                        | [Together Credits](https://docs.together.ai/docs/billing-credits)                                                                                                                                                |
| Mistral Studio / API        | [mistral.ai](https://mistral.ai/)                  | `free-tier`: API im Free mode ohne Kreditkarte laut Quickstart                                              | Nutzungs-/Ratenlimits; gemeinsames Plan-Kontingent fuer Studio/API/Vibe; keine unbelegte pauschale Dollarzusage; PAYG und Prepaid separat                    | [Studio-Quickstart](https://docs.mistral.ai/getting-started/quickstarts/studio/activate-and-generate-api-key), [Subscriptions](https://docs.mistral.ai/admin/billing-usage/subscriptions)                        |
| Ollama lokal                | [ollama.com](https://ollama.com/)                  | `local`: bestehende lokale Modelle ohne externe Inferenzgebuehr betreiben                                   | Modelllizenz, RAM/VRAM, Disk und Energie beachten; Cloud-Modelle und Cloud-Keys sind eine andere Betriebsart                                                 | [Ollama README](https://github.com/ollama/ollama/blob/main/README.md)                                                                                                                                            |

**Schlussfolgerung fuer unser Setup:** lokal zuerst, Cloud nur explizit freigeben. Community-Listen
helfen bei der Suche, entscheiden aber nicht ueber Kosten oder Datenweitergabe. Cerebras und
Together nicht als dauerhaft kostenlos einplanen. Ein FreeLLMAPI-Adapter macht aus einem bezahlten
Provider keinen kostenlosen Provider. Ein Dollarbetrag ist keine garantierte Tokenzahl.

## API-Keys, Datenschutz und Agentenschleifen

- Die verlinkten Key-Seiten sind Anmeldestellen fuer eigene berechtigte Zugaenge, keine Quelle
  fremder oder oeffentlich geteilter Keys.
- Keine Accounts anlegen, Zahlungsmittel hinterlegen, Promos einloesen oder Keys testen, nur um
  diese Liste zu pruefen.
- Keine quota-umgehenden Mehrfachkonten, geteilten Tokens oder fremden Login-Cookies verwenden.
- Kontingent und Datenrichtlinien getrennt bewerten; keine privaten Repositories, Personalakten oder
  Secrets an einen Free-Tier-Anbieter senden, nur weil er kostenlos ist.
- Kostenpflichtigen Fallback und automatisches Aufladen nicht voraussetzen.
  Request-/Token-/Turn-/Retry-Budgets je Job festlegen; eine Kostenwarnung ist kein erzwungenes
  Kostenlimit.
- Free-/Trial-Verfuegbarkeit ist kein SLA. Ein 429/Timeout darf keine unbeschraenkte Wiederholung
  oder ungenehmigten Anbieterwechsel ausloesen.

Schluessel sicher verwalten: [API-Key-Katalog](PROVIDER_KEY_CATALOG.md),
[Secrets](../SECRETS_AND_KEYS.md), [OnlineOnKeyServices](OnlineOnKeyServices/README.md). Fuer die
Lizenzfrage des Coding-Agenten:
[Claude Code ist nicht die MIT-API-CLI ant](../tools/claude-code.md).

## Woechentliche Auswertung und Repo-Aktualisierungen

Die zu diesem Auftrag eingerichtete **Codex-Thread-Automation** ist fuer **montags 09:00 Uhr,
Europe/Berlin** vorgesehen. Sie liest zunaechst den aktuellen lokalen Commit, GitHub-`main` und
diese Quellliste. Neue GitHub- Aenderungen werden beruecksichtigt, aber kein `git pull`, Reset,
Merge, Commit oder Push automatisch ausgefuehrt. Auch ohne neuen Setup-Commit werden die
Anbieterbedingungen geprueft, weil sie sich unabhaengig aendern.

Das ist **kein bei GitHub installierter Webhook oder Actions-Workflow**. Ein Push fuehrt daher nicht
sofort eine Analyse aus; neue Repo-Aenderungen fliessen in den naechsten Wochenlauf ein. Fuer lokale
Dateien muss der ausfuehrende Rechner mit laufender App verfuegbar sein; siehe
[offizielle Automation-Dokumentation](https://learn.chatgpt.com/docs/automations?surface=app). Der
Status und naechste Termin sind in der App einsehbar, nicht in diesem Repo. Eine Kopie des
Repositorys uebertraegt diese App-Automation nicht.

Jede vollstaendige Auswertung umfasst alle oben genannten Quellen und Anbieter, nicht eine
unbeweisbare Vollstaendigkeitsgarantie fuer das Internet. Neue Funde koennen nach
Primaerquellenpruefung ergaenzt werden. Ein HTTP-200 oder neues README-Datum allein zaehlt nicht als
inhaltliche Bestaetigung. Nicht erreichbare Quellen werden als offen dokumentiert, nicht als
geprueft abgehakt. API-/Account-/Lizenz-Livetests bleiben ausgeschlossen.

Die aktuelle Uebersicht wird nachvollziehbar aktualisiert; datierte Befunde unter
[reviews/](reviews/README.md) bleiben erhalten. Die
[wiederverwendbare Pruefanweisung](FREE_TIER_REVIEW_PROMPT.md) enthaelt Pruefumfang und
Sicherheitsgrenzen, falls eine andere Codex-Instanz uebernimmt. Benachrichtigung nur bei relevanten
Aenderungen, Risiken oder Handlungsbedarf.
