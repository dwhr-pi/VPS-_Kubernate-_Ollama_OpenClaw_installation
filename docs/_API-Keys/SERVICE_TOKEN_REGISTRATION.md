# Dienst-Tokens: Business, Bots, OAuth und eigene Server

Ergaenzung zum [Anmelde-/Zahlungsleitfaden](REGISTRATION_BILLING_AND_IDENTITY.md),
Stand **23.10.2026**. Bezug: weitere Webseiten im
[API-Key-Katalog](PROVIDER_KEY_CATALOG.md).
Ein PAT, OAuth-Token, Bot-Token und internes App-Secret sind unterschiedliche
Credential-Arten. Kein Key-Kauf macht einen beliebigen Dienst verfuegbar.

## Geltungsbereich der Kostenangaben

Ergaenzung vom 24.10.2026: [Manus API-Key und Task-API](manus.md) mit
offiziellem Erstellungsweg und getrennten Web-App-/API-Kostenbedingungen.
Kreditkarte, PayPal, Klarna, Krypto und KYC sind dort einzeln eingeordnet.

**Fuer alle externen Dienste dieser Seite:** Sofern nicht ausdruecklich
belegt, sind Kredit-/Debitkarte, **PayPal, Klarna und Krypto**, genauer
Mindestkauf und eine allgemeine **Ausweis-/Selfiepflicht UB**.
Die verlinkte Token-Anleitung ist **kein** Nachweis fuer deren Zahlungsarten
oder einen ausweisfreien Account. Es wurden keine Checkout-/KYC-Flows betreten.

Wo ein kostenpflichtiger Plan erforderlich ist, ist dessen Abo-/Nutzungsentgelt
nicht automatisch eine Guthabeneinzahlung. Region und Vertragsart entscheiden.
Lokale Token-Erstellung hat dagegen keinen externen Payment-Checkout;
Hosting, Mail, Speicher, Domains oder angebundene Cloud-APIs koennen kosten.

## 1. Business und Dokumente

| Dienst | So erhaeltst du den Zugang / offizielle Quelle | Kostenfreier Umfang und Zahlungsgrenze | Nachweise / offener Punkt |
|---|---|---|---|
| Ahrefs | Offizielle [API-Dokumentation](https://docs.ahrefs.com/en/api/docs/introduction), dort API keys creation and management; eigenes berechtigtes Konto verwenden | API-Tarif und Quoten pruefen. Dokumentation bietet Free test queries, **keine allgemeine kostenlose produktive API** daraus ableiten; Mindesteinzahlung UB | Key-/Tarifberechtigung erforderlich; generelle Ausweisregel UB |
| Semrush | [API access](https://developer.semrush.com/api/v3/get-started/api-access/): passenden API-Vertrag aktivieren, API Key im Konto abrufen | Produkt-/API-Units separat vom allgemeinen Trial pruefen; keine kostenlose API-Einheit oder universeller Mindestkauf zugesichert | Konto-/Vertragsrechte; Kartenfreiheit und KYC UB |
| Airtable | [Personal Access Token](https://support.airtable.com/docs/creating-personal-access-tokens): Developer Hub, Create token, Scopes und konkrete Bases waehlen | PATs fuer alle Plantypen; Free-Workspace **1.000 API-Aufrufe/Monat** laut [Quoten](https://support.airtable.com/docs/managing-api-call-limits-in-airtable). Kein gesonderter Credit-Kauf fuer die Token-Erzeugung beschrieben; Kartenfreiheit der Registrierung UB | Bestehender Vorlagenname AIRTABLE_API_KEY ist Legacy: aktuellen PAT/OAuth im Client unterstuetzen, nicht alten globalen API-Key nachbauen |
| Notion | [Integration anlegen](https://www.notion.com/help/create-integrations-with-the-notion-api): eigenes Workspace, interne Integration, Token abrufen; Seiten explizit verbinden/freigeben | API-[Raten-/Workspace-Limits](https://developers.notion.com/reference/request-limits), keine allgemeine unbegrenzte API aus einem Free-Account ableiten. Kein pauschaler Guthabenkauf fuer ein Integrationstoken beschrieben | Workspace-Rechte; Ausweis-/Zahlungsbedingungen fuer Konto/Upgrade UB |
| HubSpot | [Private-App-Anleitung](https://developers.hubspot.com/docs/apps/legacy-apps/private-apps/overview): Super-Admin, passende App, Scopes, Access Token; fuer neue Plattform Apps-Flow pruefen | API-/CRM-Produkt und Limits pruefen; Token ist keine Freischaltung aller kostenpflichtigen CRM-Funktionen. Mindestbetrag UB | Die verlinkte Anleitung ist **Legacy**; kein unveraendertes Menue fuer alle neuen Konten zugesichert |
| Buffer | [Offizielle API](https://developers.buffer.com/), Get API Key im eigenen Publish-Konto; aktuelle Credential-Art fuer den Connector pruefen | API-/Publishing-Tarif und Limits vorab nachlesen; keine pauschale Gratisquota oder Mindestaufladung belegt | API-Key-Ausgabe ist nicht automatische Erlaubnis zum Posten; Konto-/KYC-Bedingungen UB |
| TikTok Ads | Nur [TikTok for Business](https://ads.tiktok.com/) und dessen offizielle Entwickler-/Marketing-API-Freigabe: App registrieren, Advertiser verbinden, OAuth-Access-Token | Anzeigenbudget ist **kein LLM-API-Guthaben**. Werbekonto-Freigabe, Mindestbudget, Zahlarten und Land im offiziellen Account klaeren; hier UB | Business-/Advertiser-Verifizierung kann fuer den gewaehlten Zugang relevant sein; konkrete Dokumentpflicht nicht live verifiziert |
| Zotero | Eigene [Key-Verwaltung](https://www.zotero.org/settings/keys): Create new private key, nur noetige Bibliotheken/Gruppe/Schreibrechte. [Web-API](https://www.zotero.org/support/dev/web_api/v3/basics) | Lokales Zotero braucht keinen Cloud-Key; API-Zugriff, Rate Limits und kostenpflichtigen Dateispeicher getrennt betrachten. Kein API-Guthabenkauf fuer das Anlegen eines Keys beschrieben | Kein Beleg fuer generelle Ausweispflicht oder deren Ausschluss |
| Weights & Biases | Siehe [Modell-/Dienstleitfaden](REGISTRATION_BILLING_AND_IDENTITY.md#2-suche-sprache-audio-und-video): offizielle Authorize-Weiterleitung derzeit klaerungsbeduerftig | Aktuelle Free-/Team-/Compute-Konditionen UB | Keine fremden Keys beschaffen; Konto-/Produktzuordnung zuerst pruefen |

## 2. Bots und OAuth

| Dienst | Eigener Token / offizielle Anleitung | Kostenlosigkeit / Einzahlung | Identitaet und Grenze |
|---|---|---|---|
| Telegram | Offiziellen BotFather im eigenen Telegram-Konto oeffnen, /newbot, Bot benennen, Token privat sichern; [Tutorial](https://core.telegram.org/bots/tutorial) | Kein Guthabenkauf fuer den normalen Bot-Erstellungsweg beschrieben. Hosting und optionale bezahlte Plattformfunktionen getrennt | Konto-/Telefon-/Sicherheitspruefungen nicht mit pauschaler Ausweisfreiheit gleichsetzen; Ausweisregel UB |
| Discord | [Developer Portal](https://docs.discord.com/developers/quick-start/getting-started): Application anlegen, Bot, Token erzeugen/zuruecksetzen, benoetigte Intents und OAuth-Scopes | Keine Token-Aufladung fuer den beschriebenen Basisweg; Rate Limits, Verifizierung und optionale Monetarisierung separat | Skalierung/Intents/App-Review koennen weitere Freigaben verlangen; allgemeine ID-Regel UB |
| Slack | Eigene App im Workspace, Berechtigungen setzen, installieren; Bot-Token und ggf. App-Level-Token separat. [Tokenarten](https://docs.slack.dev/authentication/tokens/) | Workspace-Tarif, Historie und API-Limits getrennt; kein Modell-Tokenpaket fuer einen Bot-Token kaufen | Workspace-Adminfreigabe/OAuth moeglich; Identitaets- und Upgrade-Zahlarten UB |
| Mattermost | In der eigenen [Mattermost-Instanz](https://mattermost.com/) Botkonto bzw. Personal Access Token nach Adminfreigabe anlegen | Eigener Server: keine externe Token-Einzahlung; Hosting-/Lizenz-/Cloud-Tarif getrennt | Exakte Freigaben/Features versions- und instanzabhaengig, hier keine universelle Menuefolge verifiziert |
| Zalo | [Zalo](https://zalo.me/), offiziellen Entwickler-/Official-Account-Weg waehlen, App/Account verknuepfen und passenden Token erzeugen | Aktueller Bot-/OA-Tarif, Freiquota und Mindestzahlung UB | ZALO_BOT_TOKEN aus der Vorlage belegt keinen universellen Botzugang; lokale/Business-Nachweise und API-Freigabe offen |
| Twitch | [App registrieren](https://dev.twitch.tv/docs/authentication/register-app/): Developer Console, Redirect-URI, Client-ID; danach passenden OAuth-Flow mit minimalen Scopes | Keine allgemeine Guthabeneinzahlung fuer App-Registrierung beschrieben; Hosting und optionale Dienste getrennt | Die offizielle Registrierung nennt 2FA/Accountanforderungen; diese sind kein amtlicher Identitaetsnachweis |
| Google Kalender | Google-Cloud-Projekt, Calendar API aktivieren, Consent Screen und OAuth-Client anlegen; Nutzer stimmt benoetigten Kalenderrechten zu | [Calendar-Quota](https://developers.google.com/workspace/calendar/api/guides/quota) und Cloud-Projektkosten pruefen; nicht mit bezahlter Gemini-Inferenz verwechseln | OAuth-App-Verifizierung/Workspace-Adminfreigabe ist nicht automatisch Ausweis-KYC. Client Secret ist kein Kalender-API-Key |
| GitHub | Settings, Developer settings, Personal access tokens, fine-grained Token, Repo-Rechte und Ablauf einschraenken; [PAT-Anleitung](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) | Oeffentlicher Clone braucht normalerweise keinen Key; kein PAT-Guthabenkauf. GitHub Actions/Packages/Copilot koennen eigene Kosten haben | Orgfreigabe/SSO/2FA je Konto; PAT erteilt nicht mehr Rechte als der Benutzer besitzt |
| Tailscale | Admin Console, Keys, Generate auth key; Ablauf, Tags und Wiederverwendbarkeit bewusst waehlen; [Auth keys](https://tailscale.com/docs/features/access-control/auth-keys) | Authkey ist kein Credit-Paket; konkreten Personal-/Business-Tarif und Geraetelimits pruefen, keine unbegrenzte Gratisnutzung zugesagt | SSO-/Org-Adminrechte; Karten-/ID-Anforderungen fuer bezahlten Vertrag UB |
| Cloudflare Tunnel | Im eigenen Dashboard Tunnel anlegen bzw. vorhandenen Tunnel auswaehlen und dessen Credential nutzen | Tunnelzugang ist ein anderer Credential-Typ als Workers AI. Keine automatische Uebertragung von AI-Freiquoten auf andere Cloudflare-Dienste | Domain-/Account-/Adminrechte und Tunnelrechte pruefen; Zahlungs-/ID-Bedingungen des gewaehlten Tarifs UB |
| Hurricane Electric DDNS | [DNS-Verwaltung](https://dns.he.net/): eigenen DNS-Record, Dynamic-DNS-Funktion und zugeordneten Update-Key verwenden | Kein LLM-API-Guthaben; aktueller DNS-Tarif/Zugangsweg hinter Login nicht geprueft | Record-Key eng begrenzen; aktueller Verifizierungs-/Zahlungsbedarf UB |

## 3. Lokale Tokens und nicht zugeordnete Platzhalter

**Eigener lokaler Betrieb:** keine Kreditkarte, kein PayPal/Klarna/Krypto-
Checkout und kein externer Ausweisnachweis fuer das lokale Erzeugen eines
Secrets. Das ist keine Aussage ueber Cloud-Hosting, gewerbliche Lizenzen,
SSO-Provider oder angeschlossene bezahlte Dienste.

| Baustein | So entsteht das Credential | Wichtige Unterscheidung / Quelle |
|---|---|---|
| FreeLLMAPI | Eigenen lokalen Unified Key nach der installierten Router-Version einrichten | Kein externer Guthabenkauf fuer den lokalen Key; Upstream-Anbieter koennen kosten. [Setup-Anleitung](../tools/freellmapi.md) |
| LiteLLM / LocalAI / Open WebUI | Instanz-Admin konfiguriert Authentifizierung bzw. Benutzer legt zulassigen API-Token an | Kein gemeinsamer universeller Key; Version, Rolle und aktivierte Funktionen beachten. [Katalog](PROVIDER_KEY_CATALOG.md#2-ein-schlüssel-für-mehrere-anbieter--lokale-router) |
| OpenClaw Gateway | Lokales Gateway-Token gemaess eigener Runtime-Konfiguration setzen | Kein Cloud-Modell-Key. [ENV-Anleitung](../OPENCLAW_ENV_GUIDE.md) |
| Paperless-ngx | In der eigenen Instanz einen Benutzertoken ueber die unterstuetzte Token-Verwaltung/API einrichten | PAPERLESS_SECRET_KEY ist **kein** Benutzer-API-Token. Oeffentliche [API-Doku](https://docs.paperless-ngx.com/api/) lieferte beim Abruf 403; genaue aktuelle UI-Folge hier nicht bestaetigt |
| Home Assistant | User profile, Security, Long-lived access tokens, eigenen Token anlegen | Lokaler Zugriff auf dein Zuhause, nicht an Modellrouter weiterreichen. [Authentifizierung](https://www.home-assistant.io/docs/authentication/) |
| n8n | Eigene Instanz: Settings, n8n API, Create an API key, Ablauf setzen | [API-Anleitung](https://docs.n8n.io/api/authentication/) weist darauf hin: **API nicht im Cloud-Free-Trial verfuegbar**. Eigene Installation/Edition und Cloud-Abo unterscheiden |
| Activepieces | Eigene Instanz/Plattform: Admin-/API-Key-Funktion der gewaehlten Edition pruefen | Self-hosting bedeutet nicht, dass jede API-Adminfunktion in jeder Edition frei ist. [Projekt](https://www.activepieces.com/); konkrete Key-/Tariffreigabe hier UB |
| Authentik / Penpot | Bei eigener Installation zufaellige App-Secrets erzeugen und geschuetzt konfigurieren | AUTHENTIK_SECRET_KEY/PENPOT_SECRET_KEY sind **App-Secrets**, keine gekauften Benutzer-API-Keys. [Secrets-Regeln](../SECRETS_AND_KEYS.md) |
| Legacy-OpenClaw / Datenbanken | App-/Admin-/Datenbankzugang nur fuer den tatsaechlich vorhandenen Verbraucher konfigurieren | JWT_SECRET, ADMIN_PASSWORD und DB_CONNECTION_STRING nicht als Modellanbieter-Key behandeln |
| EULLM / AI Gateway | **Kein bestimmter Anbieter festgelegt**; zuerst Betreiber und API-Vertrag auswaehlen | Deshalb kein serioeser allgemeiner Anmelde-, Free-Tier-, Zahlungs- oder KYC-Weg angebbar |
| OIDC | Beim gewaehlten eigenen oder externen Identity Provider einen Client registrieren | OIDC_CLIENT_SECRET ist ein Client-Credential; Provider/Vertrag fehlt, daher Cloud-Kosten/Zahlung/KYC offen |
| Boersen / Automaton / Web3 | Anbieterbezogene Credentials bzw. eigenstaendiges Wallet-Konzept verwenden | Private Key/Seed ist kein API-Credit-Key. Boersen-KYC und Wallet-Finanzierung sind gesondert zu pruefen; **keine Live-Trades, Finanzierung oder Key-Weitergabe** aus dieser Anleitung |
| Ollama lokal / llama.cpp / ComfyUI | Fuer lokale Inferenz normalerweise kein externer Anbieter-Key | Lokale Authentifizierung, Downloadrechte und Modelllizenz bleiben separat; nicht Cloud-Ollama und lokalen Server gleichsetzen |
| WebsiteFactory / Claude | Falls der Workflow bewusst Claude API verwendet: eigenen Anthropic-Key nach dem [Anmeldeleitfaden](REGISTRATION_BILLING_AND_IDENTITY.md) beziehen | CLAUDE_API_KEY ist nur ein toolbezogener Variablenname, kein zweiter kostenloser Claude-Zugang |
| Qwen Code / Claude Code / Gemini CLI | Im jeweiligen Client den unterstuetzten Backend-/OAuth-/API-Login auswaehlen | Clientinstallation erzeugt kein API-Guthaben; Chat-, Coding- und allgemeine API-Tarife separat behandeln |

## Offene Felder selbst klaeren, ohne versehentlich zu kaufen

Im eigenen offiziellen Konto vor einer Bestellung nachsehen:
**exaktes Produkt, Land, Freiquota und Ablauf, erforderliches Zahlungsmittel,
Mindestkauf samt Steuern/Gebuehren, automatische Aufladung/Verlaengerung,
Rueckzahlung sowie Ausweis-/Firmenpruefung**. Hinter Login angezeigte
Bedingungen nicht als allgemeine Garantie fuer andere Konten behandeln.

Nur die Bedingungen/Beleg-URL notieren, keine Keys, Karten- oder
Ausweisdaten in das Repository uebernehmen.
Zur [API-Key-Uebersicht](README.md).
