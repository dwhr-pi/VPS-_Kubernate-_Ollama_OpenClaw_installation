# OpenRouter: ein API-Schluessel fuer mehrere KI-Modelle

**Sinn und Zweck: Mit einem OpenRouter-Konto, einem API-Schluessel und einem
gemeinsamen API-Endpunkt unterschiedliche KI-Modelle nutzen.** Dein vorhandener
Client waehlt die Modell-ID; OpenRouter vermittelt die Anfrage an einen
geeigneten Modellprovider und buendelt die Abrechnung. Du musst im normalen
Kredit-Modell nicht fuer jeden dahinterliegenden Anbieter einen eigenen Key
verwalten. OpenRouter ist ein Gateway, nicht selbst ein Sprachmodell.
Siehe [offizieller Quickstart](https://openrouter.ai/docs/quickstart).

```text
Vorhandener Client -> OpenRouter-Key + https://openrouter.ai/api/v1
                   -> gewaehltes Modell -> zulaessiger Modellprovider
```

Pruefstand: **20.10.2026**, Status **documentation-first, nicht aktiviert**.
Kein Installer oder Docker notwendig. Diese Seite richtet keinen Account,
Schluessel, SDK, kostenpflichtigen Auftrag oder automatischen Cloud-Fallback ein.
Ollama bleibt der lokale Standard. Keine WSL-/Cluster-Aenderungen ausgefuehrt.

## Welche Modelle und wozu?

Der [Modellkatalog](https://openrouter.ai/models) ist massgeblich fuer die
verfuegbaren Modell-IDs, Funktionen und Preise. Modelle unterschiedlicher
Entwickler koennen durch verschiedene Inferenzprovider angeboten werden:
**Modellhersteller und ausfuehrender Provider sind nicht dasselbe.**
Nicht aus einem Markennamen auf eine konkrete nutzbare Version schliessen.
Ein Key garantiert weder jedes Modell noch kostenlose oder unbegrenzte Nutzung.

Moegliche Aufgaben im Setup: synthetische Entwicklungstests, Vergleich
freigegebener Modelle oder ein ausdruecklich genehmigter Cloud-Fallback.
Kubernetes/VPS/WSL beherbergen dabei nur deinen Client; Prompts verlassen
deine Infrastruktur. Kein Ersatz fuer lokale Ollama-Inferenz bei Offline-Zielen.

## Vergleich mit token8341

| Aspekt | OpenRouter | token8341 / TokenWorks |
|---|---|---|
| Grundprinzip | Eine API fuer mehrere Modelle/Provider | Vergleichbares Aggregator-Prinzip laut Betreiber |
| Anmeldung und Key | Eigenes OpenRouter-Konto und eigener Key | Separates TokenWorks-Konto und separater Key |
| Endpunkt | `https://openrouter.ai/api/v1` laut Quickstart | Dokumentierte Hosts widersprechen sich; vor Key-Nutzung klaeren |
| Routing | Dokumentierte Provider-Auswahl und Filter | Keine Gleichwertigkeit der Routingregeln unterstellen |
| Kosten/Datenschutz | Modell, Provider und Kontoeinstellungen pruefen | Bedingungen und Infrastrukturangaben gesondert verifizieren |
| Setup-Installation | Keine | Keine |

Ein funktionierender OpenAI-kompatibler Client kann oft beide ansprechen;
URLs, Keys, Modell-IDs und unterstuetzte API-Funktionen sind nicht austauschbar.
Ein OpenAI-Endpunkt ist insbesondere kein automatischer Anthropic-/Claude-Code-
Adapter. Details und offene Punkte zu [token8341](token8341.md).

## Getrennte lokale Konfiguration

Nur als Beispiel fuer eine private Datei ausserhalb des Repositories,
etwa `~/.openclaw_ultimate_user_data/secrets/openrouter.env`:

```dotenv
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
OPENROUTER_API_KEY=
OPENROUTER_MODEL=
OPENROUTER_ALLOW_CLOUD=0
```

Einen eigenen OpenRouter-Key und eine aktuell bestaetigte Modell-ID nur lokal
eintragen. Dateirechte 0600, Elternordner 0700; keine Keys im Browser-Frontend,
Markdown, Git, Shell-Argument oder Log. Variablen bewusst nur in den vorgesehenen
Clientprozess injizieren; Python laedt `.env` nicht automatisch.
Keine globale Aenderung von `OPENAI_BASE_URL` und kein Wiederverwenden eines
OpenAI- oder TokenWorks-Keys fuer diesen Dienst.

### Python-Client ohne API-Aufruf

Voraussetzung ist ein bereits separat eingerichtetes `openai`-SDK in privater
Umgebung. Das Beispiel nutzt dessen `base_url`-Parameter gemaess
[OpenRouters SDK-Anbindung](https://openrouter.ai/docs/quickstart),
initialisiert nur den Client und schliesst ihn wieder. Kein Download und keine
kostenpflichtige Anfrage werden hier ausgefuehrt.

```python
import os
from openai import OpenAI

if os.environ.get("OPENROUTER_ALLOW_CLOUD") != "1":
    raise SystemExit("Cloud-Nutzung nicht freigegeben.")
base_url = os.environ["OPENROUTER_BASE_URL"].rstrip("/")
if base_url != "https://openrouter.ai/api/v1":
    raise SystemExit("Endpunkt nicht freigegeben.")
key = os.environ["OPENROUTER_API_KEY"]
if not key.strip():
    raise SystemExit("Separater OpenRouter-Key fehlt.")
client = OpenAI(base_url=base_url, api_key=key, timeout=30.0, max_retries=0)
# Kein API-Aufruf, keine Modellsuche und kein Agentenstart.
client.close()
```

Fuer spaetere Chat-Anfragen muss die freigegebene Modell-ID verwendet werden.
Die Initialisierung allein erzwingt noch keine Provider-/Datenschutzfilter.
API-Kompatibilitaet ersetzt keinen Test der benoetigten Tools, JSON-Schemas,
Streaming- oder multimodalen Funktionen.

### Kubernetes ohne neuen Dienst

Ein vorhandener Client kann den Key aus einem Kubernetes-Secret erhalten.
Nach eigener Freigabe, mit existierendem Namespace und lokaler Secret-Datei:

```bash
kubectl -n ai create secret generic openrouter-api \
  --from-env-file="$HOME/.openclaw_ultimate_user_data/secrets/openrouter.env"
```

Nur ein Ausschnitt fuer die Umgebung des bestehenden Client-Containers:

```yaml
env:
  - name: OPENROUTER_BASE_URL
    value: "https://openrouter.ai/api/v1"
  - name: OPENROUTER_ALLOW_CLOUD
    value: "0"
  - name: OPENROUTER_API_KEY
    valueFrom:
      secretKeyRef:
        name: openrouter-api
        key: OPENROUTER_API_KEY
```

Nicht ausgefuehrt; kein neues Deployment, Ingress oder Admin-Port erforderlich.
Freigabe erst nach Daten-/Kostenpruefung auf `1` setzen. Secret niemals als
YAML mit echten Werten exportieren/committen. RBAC, Verschluesselung ruhender
Secrets und begrenzten Egress separat einrichten.

## Verwendung in FreeLLMAPI

**Ja: OpenRouter ist im verwendeten FreeLLMAPI-Quellstand bereits eingebaut.**
Geprueft: `v0.14.2`, Commit `57c0669233bbe0c70a0f9f9927613192be948773`.
Die [Provider-Implementierung am Pin](https://github.com/tashfeenahmed/freellmapi/blob/57c0669233bbe0c70a0f9f9927613192be948773/server/src/providers/index.ts)
registriert `openrouter` mit `https://openrouter.ai/api/v1` und
OpenRouter-spezifischen Headers. Das ist bestaetigte Code-Unterstuetzung,
**kein Live-Nachweis fuer dein Konto oder ein bestimmtes Modell**.

Nach bewusster Einrichtung und Start von
[FreeLLMAPI](../freellmapi.md) ueber dessen Keys-Seite vorgehen:

1. Den eingebauten Provider **OpenRouter** waehlen.
2. Deinen separaten OpenRouter-Key dort hinterlegen, nicht den lokalen
   FreeLLMAPI Unified Key. Das kann Validierungs-/Quota-Kontakte ausloesen.
3. Die angebotenen Modelle pruefen und nur erlaubte aktivieren. Der
   FreeLLMAPI-Katalog ist keine automatische Freigabe aller OpenRouter-Modelle.
   Fehlende IDs erst im OpenRouter-Katalog/Konto bestaetigen; eine manuelle
   Modellregistrierung/Discovery nur mit Freigabe verwenden, wenn im eigenen
   Dashboard vorhanden. Kein Update auf `main` nur wegen abweichender UI.
4. Im vorhandenen Client die lokale Basis-URL
   `http://127.0.0.1:3011/v1`, den FreeLLMAPI **Unified Key** und die vom
   Router angezeigte Modellkennung einstellen. Nicht direkt die OpenRouter-URL
   verwenden, wenn der Auftrag durch FreeLLMAPI gehen soll.
5. Erst nach Daten-/Kostenfreigabe einen synthetischen Test ausfuehren und
   im Router sowie im OpenRouter-Konto Zielprovider und Kosten pruefen.

Die Beispiele mit `OPENROUTER_*` weiter oben sind fuer direkte Clients und
werden durch diese Dokumentation nicht automatisch ins Router-Dashboard
importiert. Ein Key verbindet Router und Anbieter, der andere Client und Router.
Keine echten Keys als CLI-Argumente, in Screenshots oder Logausgaben verwenden.

Der eingebaute Provider ist der bevorzugte Weg. OpenRouter ist technisch
auch ein OpenAI-kompatibler Custom-Endpunkt; ein zweiter Custom-Eintrag mit
demselben Key ist aber kein zusaetzliches Guthaben und kann dieselben
Anbieterlimits treffen. Nicht ungeprueft doppelt registrieren.

**Kosten und Routing bleiben relevant:** FreeLLMAPI macht bezahlte Modelle
nicht gratis. Die [Providerliste am Pin](https://github.com/tashfeenahmed/freellmapi/blob/57c0669233bbe0c70a0f9f9927613192be948773/docs/en/providers/01-supported-platforms.md)
beschreibt auch OpenRouter-`:free`-Routen; deren Limits und Datenregeln
gesondert pruefen. FreeLLMAPI-Ausweichketten und OpenRouter-Provider-Routing
sind zwei Ebenen. Beide begrenzen; automatische Fusion/weitere Modellaufrufe
nicht fuer einen ersten Einzeltest nutzen. Datenschutzfilter der folgenden
Sektion werden durch blosses Speichern eines Keys nicht automatisch gesetzt;
deren Weitergabe ueber den Router vor produktiver Nutzung gesondert pruefen.
Keine API-Livetests oder Einstellungen wurden hier ausgefuehrt.

## Routing und Datenschutz

OpenRouter dokumentiert [Provider-Auswahl](https://openrouter.ai/docs/guides/routing/provider-selection):
`only` begrenzt zulaessige Provider, `allow_fallbacks` steuert Ausweichrouting,
`require_parameters` verlangt Parameterunterstuetzung. Modell-Fallback und
Provider-Fallback sind getrennte Entscheidungen. Nur freigegebene Zielprovider
zulassen; nicht bei einem Fehler still auf andere Datenverarbeiter ausweichen.

`data_collection: "deny"` und `zdr: true` koennen laut Routing-Dokumentation
die Auswahl nach Datenrichtlinien einschraenken. Das sind keine Garantie fuer
EU-Verarbeitung, vollstaendige Netzisolation oder pauschale DSGVO-Konformitaet.
Wenn kein erlaubter Provider passt, abbrechen statt die Filter zu lockern.

Laut [OpenRouter Data Collection](https://openrouter.ai/docs/guides/privacy/data-collection)
werden Prompts/Antworten bei OpenRouter nicht standardmaessig gespeichert;
bestimmte Inhaltsnutzungen und Inhaltslogs sind Opt-in. Request-Metadaten
werden dennoch verarbeitet. Das ist eine Betreiberangabe, kein eigener Audit.
Die [Inferenzprovider haben eigene Regeln](https://openrouter.ai/docs/guides/privacy/provider-logging)
fuer Speicherung und Training; auch kostenlose Modelle gesondert pruefen.
Servertools/Plugins koennen weitere Dienste und Datenfluesse hinzufuegen.

Keine pauschale EU-Hosting-Zusage aus `openrouter.ai` ableiten. Regionale
Angebote, Vertrags-/Tarifvoraussetzungen und alle Datenfluesse gesondert pruefen;
das Beispiel aktiviert keine Regionalfunktion. Fuer produktive personenbezogene
Daten Rollen, Vertraege, Speicherorte, Unterauftragnehmer, Loeschung und
Drittlandtransfers fachlich bewerten. AI-Act-Pflichten richten sich nach der
konkreten Anwendung, nicht nach dem SDK. Bis dahin im Setup nur synthetische
oder oeffentliche, nicht vertrauliche Daten nach ausdruecklicher Freigabe.
Private Repositories, Personalakten und Secrets nicht an Agenten-Cloud-Fallbacks
uebergeben. [Weitere Datenschutzgrenzen](token8341.md#datenschutz-und-eu-ai-act).

## Kosten, Testmoeglichkeiten und Zahlungen

Die [offizielle FAQ](https://openrouter.ai/docs/faq) beschreibt nutzungsbasierte
Abrechnung und Gebuehren beim Erwerb von Credits. Eingabe, Ausgabe, Reasoning,
Bilder oder einzelne Requests koennen unterschiedlich berechnet werden.
Die exakten Preise/Einheiten im Modellkatalog und aktuelle Aufladegebuehren
vor dem Kauf pruefen; hier keine feste Preis- oder Spargarantie.

Laut FAQ werden gaengige Kreditkarten, Alipay und USDC angeboten. Tatsaechliche
Verfuegbarkeit und Gebuehren im eigenen Checkout pruefen; keine Wallet oder
Zahlungsmethode wird durch das Setup eingerichtet. Refund-Regeln gesondert
lesen; Krypto-Zahlungen sind laut FAQ nicht erstattbar.

Kostenlose Modelle/Testkontingente koennen zum Einstieg dienen, haben aber
Limits und unterschiedliche Datenbedingungen. Kein unbegrenzter Gratisbetrieb,
kein versprochenes fixes Startguthaben oder dauerhafter Modellzugang.
Getrennte Keys und Kontolimits setzen; eine Aufladung ist keine Freigabe fuer
autonome Agentenschleifen. Keine automatische Aufladung oder Affiliate-URL.

## Sicherer erster Test und Grenzen

Nach eigener Freigabe: ein synthetischer Prompt, eine bestaetigte Modell-ID,
ein erlaubter Provider, begrenzte Ausgabe, ein Job gleichzeitig, Timeout und
keine automatischen Retries. Key-/Kontobudget serverseitig begrenzen, soweit
verfuegbar, und Usage/Kosten nachpruefen. Ein Client-Timeout allein verhindert
keine Kosten beim Anbieter. Keine Zugangsdaten oder Prompt-Inhalte protokollieren.

Vorteil: einheitliche Anbindung und Modellauswahl. Nachteile: externer
Vertrauenspunkt, Abhaengigkeit von mehreren Beteiligten, variable Kosten und
zusatzliche Datenschutz-/Routingpruefungen. Keine technische oder juristische
Freigabe durch diese Dokumentation; kein API-Livetest wurde ausgefuehrt.

Verwandt: [OnlineServices](README.md), [token8341](token8341.md),
[FreeLLMAPI](../freellmapi.md), [Secrets und Keys](../../SECRETS_AND_KEYS.md).
