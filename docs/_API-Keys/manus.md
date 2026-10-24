# Manus: API-Key fuer externe Agenten-Aufgaben

**Sinn und Zweck:** Dein freigegebener Workflow kann mit einem Manus-Key
Aufgaben an den gehosteten Manus-Agenten uebergeben und Ergebnisse abrufen.
Die API verwaltet auch Projekte und Dateien. Sie ist keine lokale Installation
und kein universeller Modellrouter wie OpenRouter.
[Offizielle Webseite](https://manus.im/),
[API-Ueberblick](https://open.manus.im/docs/v2/introduction).

Recherchiert am **24.10.2026** anhand oeffentlicher Anbieterquellen.
Kein Login, Checkout oder API-Test ausgefuehrt. **UB = unbestaetigt**.

## So erhaeltst du deinen Schluessel

1. Auf der offiziellen Manus-Webseite im eigenen Konto anmelden.
2. Die **Developers settings** in der Web-App oeffnen. Den Einstieg verlinkt
   die [offizielle Authentifizierungsanleitung](https://open.manus.im/docs/v2/authentication).
3. **Create API Key** waehlen und einen Namen fuer den Einsatzzweck vergeben.
4. Den einmalig angezeigten Wert sofort im eigenen Secret-Manager sichern.
5. API-Freigabe und nutzbares Guthaben vor dem ersten Auftrag kontrollieren.

Laut Anbieter haben API-Keys vollen Kontozugriff. Ein Name beschraenkt keine
Rechte. Bei Verlust den Key in den Einstellungen widerrufen und ersetzen.
OAuth ist ein separater Zugangsweg mit eigenen Team-/App-Bedingungen.
[Quelle: Authentifizierung](https://open.manus.im/docs/v2/authentication).

## Technische Zuordnung

| Feld | Dokumentierter Stand |
|---|---|
| Umgebungsvariable | `MANUS_API_KEY`; kein automatisch angebundener Setup-Provider |
| API-Host | `https://api.manus.ai`, nicht blind aus der Produktdomain ableiten |
| API-Version | v2, etwa `/v2/task.create`; v1 ist laut Anbieter abgekuendigt |
| Header fuer v2 | `x-manus-api-key`; nicht mit dem alten v1-Header `API_KEY` mischen |

Quellen: [API v2](https://open.manus.im/docs/v2/introduction),
[Key und Header](https://open.manus.im/docs/v2/authentication).

Leere Vorlage fuer eine private Konfiguration:

```dotenv
# Store the real value outside the repository.
MANUS_API_KEY=
```

Echte Werte bleiben beispielsweise unter `~/.openclaw_ultimate_user_data/`
mit restriktiven Dateirechten oder im [ENV-Tresor](../ENV_VAULT.md).
Keine Keys in Markdown, Git, Browser-JavaScript, URL-Parametern,
Shell-History, Screenshots, Prompts oder Logs. Header nicht an andere Hosts
oder ungepruefte Weiterleitungen weitergeben.

## Gratisnutzung, Bezahlung und Identitaet

| Frage | Beleg / offener Punkt |
|---|---|
| Kostenloses Kontingent | Free-Web-App und taegliche Credits werden beschrieben; kein Nachweis eines allgemeinen kostenlosen API-Kontingents |
| API-Startguthaben | **UB**; Web-App-Boni nicht automatisch als API-Budget einplanen |
| API ohne Kreditkarte | **UB** fuer die konkrete Konto-/API-Freigabe |
| Kreditkarte / PayPal | Die Waehrungshilfe nennt Visa, Mastercard und PayPal als Beispiele; deren Verfuegbarkeit in jedem API-/Abo-Checkout ist damit nicht belegt, also **UB** |
| Klarna / Krypto | Direkte Unterstuetzung in den geprueften Quellen **UB** |
| Mindesteinzahlung | Universeller API-Mindestbetrag **UB**; Abo, Add-on und Guthabeneinzahlung unterscheiden |
| Ausweis / Selfie / KYC | Allgemeine Pflicht beziehungsweise deren Ausschluss **UB**; Konto, Region und Checkout pruefen |

Quellen: [Tarife](https://manus.im/en/pricing),
[Credit-Regeln](https://help.manus.im/en/articles/11711097-what-are-the-rules-for-credits-consumption-and-how-can-i-obtain-them),
[Waehrung und Zahlungsdienstleister](https://help.manus.im/en/articles/11711125-what-is-the-pricing-unit-for-manus-globally-can-i-pay-in-local-currency).

Credits decken laut Help Center unter anderem Modellnutzung, Cloud-Compute
und Drittanbieterzugriffe ab. Aufwand und Dauer beeinflussen den Verbrauch;
keine Token-Flatrate. Budget, Laufzeit, Abbruch und begrenzte Wiederholungen
vor einer produktiven Nutzung festlegen.
[Verbrauch](https://help.manus.im/en/articles/11711097-what-are-the-rules-for-credits-consumption-and-how-can-i-obtain-them).

## Setup und FreeLLMAPI

**Hinzugefuegt ist die Anbieter-Dokumentation, keine aktive Integration.**
Ein Connector muss Task-Erstellung, Status, Ergebnisabruf und gegebenenfalls
Webhooks implementieren und testen. Keine automatische Veroeffentlichung,
Nachricht oder Dateifreigabe. Alle Keys desselben Nutzers teilen sich die
[Benutzerlimits](https://open.manus.ai/docs/v2/rate-limits).
Nach einem Timeout nicht blind einen zweiten Auftrag anlegen.

Fuer [FreeLLMAPI](../tools/freellmapi.md) wird hier **keine eingebaute oder
getestete Manus-Anbindung zugesichert**. Das Aendern von `OPENAI_BASE_URL`
allein belegt keine Kompatibilitaet mit der Task-API. Etwaige separate
Kompatibilitaetsendpunkte versionsbezogen pruefen; den Key nicht blind
in generische Modellproviderfelder kopieren.

Manus verarbeitet extern: Ein lokaler Client macht die Cloud nicht lokal.
Datenkategorien, Aufbewahrung und Vertragsbedingungen vor Freigabe pruefen.
Keine Personalakten, Wallets, Geheimnisse oder unfreigegebenen Kundendaten testen.

Die [Manus-Interviews](../tutorials/manus-interview-2026-10-22.md) sind
Workflow-Quellen, keine API-Anbindung. OpenManus ist nicht automatisch der
gehostete Dienst manus.im und erhaelt diesen Key nicht.

Zurueck: [Alle API-Schluessel](README.md),
[Anbieterkatalog](PROVIDER_KEY_CATALOG.md),
[Registrierung und Abrechnung](REGISTRATION_BILLING_AND_IDENTITY.md).
