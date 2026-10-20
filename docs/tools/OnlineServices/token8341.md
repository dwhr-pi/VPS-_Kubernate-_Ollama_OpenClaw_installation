# token8341 / TokenWorks: optionales externes API-Gateway

**Sinn und Zweck: Ein API-Schluessel und ein gemeinsamer Endpunkt fuer
mehrere KI-Modelle verschiedener Anbieter.** Statt fuer jedes Modell einen
eigenen Zugang und eine eigene Abrechnung einzurichten, waehlt dein Client
ueber den Modellnamen den gewuenschten Dienst hinter diesem Gateway.

```text
Dein KI-Client -> token8341-Key + gemeinsamer API-Endpunkt
              -> DeepSeek | Qwen | Kimi | GLM | MiniMax | gpt-oss-120b
```

Das ist im Grundprinzip aehnlich wie [OpenRouter](openrouter.md): ein
API-Aggregator, nicht selbst ein Sprachmodell. Ein Schluessel bedeutet
**nicht**, dass alle Modelle kostenlos, unbegrenzt oder jederzeit verfuegbar
sind. Angebot, Modell-ID, Freischaltung und Kosten bleiben zu pruefen.
Hier wird nichts installiert: du bindest bei Bedarf einen Online-Dienst
in einen bereits vorhandenen Client ein. [Uebersicht OnlineServices](README.md).

Pruefstand: **20.10.2026**. Status: **documentation-first, nicht aktiviert**.
Diese Seite ist keine Empfehlung, Sicherheitszertifizierung oder Partnerschaft.
Keine Installation, Anmeldung, Zahlung, API-Abfrage oder Cluster-Aenderung wurde
fuer diese Dokumentation ausgefuehrt. Ollama bleibt der lokale Standard.

## Einordnung und Nutzen

TokenWorks bietet laut [API-Dokumentation](https://www.token8341.com/en/docs)
einen gemeinsamen API-Key und OpenAI-kompatibles Chat Completions an.
Das kann Anbieterwechsel, Schluesselverwaltung und Abrechnung vereinfachen.
Es ist ein **externer Cloud-Dienst**, keine auf Kubernetes installierbare
Open-Source-Inferenz und kein GitHub-/Docker-Installationsziel.
Ein eigener Kubernetes-Client macht die Verarbeitung beim Anbieter nicht lokal.

Die [Preisseite](https://www.token8341.com/en/pricing) fuehrt DeepSeek, Qwen
(Alibaba), GLM (Zhipu), Kimi (Moonshot), MiniMax und `gpt-oss-120b` auf.
Das sind Katalogangaben, kein Nachweis von Verfuegbarkeit, Modellidentitaet
oder Qualitaet. Modell-ID, Kontofreigabe und Funktionen vor jedem Einsatz
pruefen; Modellnamen nicht aus Marketingnamen ableiten.

OpenAI-Kompatibilitaet ist hier eine Betreiberangabe fuer Chat Completions,
keine Garantie fuer Responses, Tools, JSON-Schemas, Streaming, Bilder oder
alle SDK-Funktionen. Claude Code verwendet nicht einfach beliebige
OpenAI-Endpunkte; dessen Provider-/Protokolladapter separat pruefen.

## Endpunkt und getrennte Konfiguration

Die englische API-Doku nennt **`https://www.token8341.com/v1`**.
Andere [Betreiberbeispiele](https://token8341.com/ar) nennen
`https://api.token8341.com/v1`. Dieser Widerspruch ist offen: vor dem
Hinterlegen eines Keys den gueltigen Host im offiziellen Konto bestaetigen.
Nicht automatisch zwischen Hosts umleiten oder Credentials testweise verteilen.
Nur `token8341.com` ohne HTTPS/API-Pfad ist keine vollstaendige Basis-URL.

Beispiel fuer eine **separate lokale** Datei
`~/.openclaw_ultimate_user_data/secrets/token8341.env`, nicht im Repository:

```dotenv
TOKEN8341_BASE_URL=https://www.token8341.com/v1
TOKEN8341_API_KEY=
TOKEN8341_MODEL=
TOKEN8341_ALLOW_CLOUD=0
```

Key und bestaetigte Modell-ID nur lokal eintragen. Datei mit restriktiven
Rechten (0600, Elternordner 0700) schuetzen, nicht in Logs oder Tickets
uebernehmen. Kein OpenAI-Key gehoert in diesen Drittanbieter-Client.
Eine `.env` wird von Python nicht automatisch geladen: nur im bewusst
ausgewaehlten Prozess laden bzw. durch einen Secret-Manager injizieren.
Keine globale Umstellung von `OPENAI_BASE_URL` oder bestehenden Agenten.

### Python: nur Client initialisieren

Voraussetzung ist ein separat eingerichtetes `openai`-SDK in einer privaten
Umgebung. Das Beispiel installiert nichts und sendet **keine Anfrage**.
`base_url` ist ein SDK-Parameter; siehe auch die
[offizielle OpenAI-Dokumentation zum Parameter](https://developers.openai.com/api/docs/guides/private-link#6-update-application-base-urls).
Dieser Verweis bestaetigt nicht den Drittanbieter oder dessen Kompatibilitaet.

```python
import os
from urllib.parse import urlsplit
from openai import OpenAI

if os.environ.get("TOKEN8341_ALLOW_CLOUD") != "1":
    raise SystemExit("Cloud-Nutzung nicht freigegeben.")
base_url = os.environ["TOKEN8341_BASE_URL"].rstrip("/")
url = urlsplit(base_url)
if (url.scheme != "https" or url.hostname != "www.token8341.com"
        or url.port not in (None, 443) or url.path != "/v1"
        or url.username or url.password or url.query or url.fragment):
    raise SystemExit("Endpunkt nicht freigegeben; Betreiberangaben pruefen.")
key = os.environ["TOKEN8341_API_KEY"]
if not key.strip():
    raise SystemExit("Separater Anbieter-Key fehlt.")
client = OpenAI(base_url=base_url, api_key=key, timeout=30.0, max_retries=0)
# Kein API-Aufruf. Spaetere Tests nur mit synthetischen Daten und Kostenlimit.
client.close()
```

Der Host ist absichtlich auf die dokumentierte Variante begrenzt. Nach
Bestaetigung eines anderen Hosts die Allowlist bewusst aendern, nicht umgehen.
Fuer einen vorhandenen OpenAI-kompatiblen Client kann dessen **eigener Prozess**
stattdessen `OPENAI_BASE_URL` und `OPENAI_API_KEY` aus den getrennten
TOKEN8341-Werten erhalten. Keine Fallback-Nutzung eines geerbten OpenAI-Keys.
Modell und API-Methode muessen trotzdem zum Anbieter passen.

### Kubernetes: Secret referenzieren, nicht einchecken

Zuerst den vorhandenen Namespace und RBAC/Secret-Schutz pruefen. Beispiel
fuer eine manuelle Secret-Erstellung aus der lokalen, geschuetzten Datei:

```bash
kubectl -n ai create secret generic token8341-api \
  --from-env-file="$HOME/.openclaw_ultimate_user_data/secrets/token8341.env"
```

Nicht hier ausgefuehrt. Keine Secrets mit `-o yaml` ausgeben oder committen.
Im bestehenden, separat freigegebenen Client-Container nur diese Variablen
referenzieren (Manifest-Ausschnitt, kein eigenstaendiges Deployment):

```yaml
env:
  - name: TOKEN8341_BASE_URL
    value: "https://www.token8341.com/v1"
  - name: TOKEN8341_ALLOW_CLOUD
    value: "0"
  - name: TOKEN8341_API_KEY
    valueFrom:
      secretKeyRef:
        name: token8341-api
        key: TOKEN8341_API_KEY
```

Freigabe `1` erst nach Daten-/Kostenpruefung setzen. Keine Ingress-Regel,
kein Admin-Port oder Docker-Socket erforderlich. Secret nur dem notwendigen
Workload zuweisen, RBAC und Verschluesselung ruhender Secrets konfigurieren.
Egress gezielt begrenzen; einfache Kubernetes-NetworkPolicies bieten keine
allgemeine FQDN-Allowlist. Plattformfaehigkeiten vorher pruefen.

## Verwendung in FreeLLMAPI

**Grundsaetzlich ueber einen Custom-Provider moeglich, aber nicht live
bestaetigt.** Im Setup-Pin von FreeLLMAPI `v0.14.2`, Commit
`57c0669233bbe0c70a0f9f9927613192be948773`, existiert kein eigener
token8341-Adapter. Der [Providervertrag am Pin](https://github.com/tashfeenahmed/freellmapi/blob/57c0669233bbe0c70a0f9f9927613192be948773/docs/en/providers/01-supported-platforms.md)
enthaelt jedoch **Custom (OpenAI-compatible)** mit eigener Basis-URL pro Key.
Zusammen mit der vom Anbieter beworbenen Chat-Completions-Kompatibilitaet
ergibt sich ein Integrationspfad, keine Garantie fuer alle Modelle/Funktionen.

Nach bewusster Einrichtung und Start des lokalen
[FreeLLMAPI-Routers](../freellmapi.md) ueber dessen Keys-Seite konfigurieren:

| Feld / Schritt | Wert oder Handlung |
|---|---|
| Provider | Custom (OpenAI-compatible), nicht OpenRouter |
| Basis-URL | `https://www.token8341.com/v1` laut API-Doku; **zuerst Host-Widerspruch klaeren**, vorher keinen Key uebermitteln |
| Anbieter-Key | Eigener token8341-Key; nicht der lokale FreeLLMAPI Unified Key |
| Modell | Eine konkrete, im token8341-Konto bestaetigte Chat-Modell-ID eintragen; keine komplette Modellliste erfinden |
| Gruppe | Eigene Custom-Gruppe, beispielsweise `token8341`, zur Trennung von anderen Endpunkten |
| Freigabe | Nur erlaubte Modelle in eine ausdruecklich freigegebene Kette aufnehmen; keine pauschale globale Auto-/Fallback-Freigabe |

Das [Keys-Handling am Pin](https://github.com/tashfeenahmed/freellmapi/blob/57c0669233bbe0c70a0f9f9927613192be948773/server/src/routes/keys.ts)
unterstuetzt benannte Custom-Modelle und optionale Modell-Discovery.
Discovery/Validierung kann den Anbieter kontaktieren; ein Probe-Test sendet
eine echte Chat-Anfrage und kann Geld kosten. Auch ohne Discovery lassen
sich bekannte Chat-IDs eintragen. Nicht ohne Kosten-/Datenfreigabe testen.

Dein Client spricht danach **nur den lokalen Router** an, in diesem Setup
standardmaessig `http://127.0.0.1:3011/v1`, mit dessen **Unified Key** und
der im Router angezeigten Modellkennung. Die lokale Kennung kann von der
Upstream-ID abweichen. Die TOKEN8341-Env-Beispiele oben sind fuer direkte
Clients, kein automatischer FreeLLMAPI-Key-Import.

FreeLLMAPI macht kostenpflichtige Anbieter nicht kostenlos und lokale
Weiterleitung macht Datenverarbeitung nicht lokal. Budget beim Anbieter
setzen, weitere Provider/Fallbacks begrenzen und sensible Inhalte ausschliessen.
Nach Freigabe erst einen synthetischen Chat-Test, spaeter Streaming/Tools
einzeln pruefen. Keine echte Integration, Keys oder Testanfragen wurden hier
angelegt. Start-/Installationsschritte bleiben separat freizugeben.

## Trust-Faktor: Behauptung ist kein Audit

Die [AGB](https://www.token8341.com/en/terms), Stand dort 08.10.2026,
nennen Beijing Silicon-Carbon Phase Transition Intelligent Technology Co., Ltd.
als Vertragspartner und chinesisches Recht. Sie beschreiben Inferenz durch
Upstream-Anbieter; TokenWorks uebernimmt Routing, Zugang und Abrechnung.
Kein unabhaengiger Unternehmens-, Sicherheits- oder Infrastruktur-Audit liegt
dieser Integration zugrunde.

Die [Ueber-uns-Seite](https://www.token8341.com/en/about) nennt eigene
Rechenzentren, unter anderem Horinger, Hami und Zhongwei. Andere
[lokalisierte Preisseiten](https://www.token8341.com/hi/pricing) nennen
Horinger/Hohhot, Ulanqab und Zhongwei und werben mit Nicht-Reselling.
Diese Angaben sind nicht gleichlautend und keine Zusage, wo ein bestimmter
Request verarbeitet wird. Eigene Hardware schliesst Upstream-Routing nicht aus.

Die lokalisierte Preisseite wirbt mit chinesischen Umsatzsteuerrechnungen und
Firmenueberweisungen. Rechnungsausstellung beweist weder Datenschutzkonformitaet
noch bessere Verfuegbarkeit. Vertragspartner, akzeptierte Rechnung fuer die
eigene Buchhaltung, Verarbeitungsorte, Unterauftragnehmer und SLA schriftlich
klaeren. Die API-Doku beschreibt zudem nutzeruebergreifendes Prompt-Caching:
Isolation, Cache-Keys, Speicherfristen und Loeschung gesondert pruefen.
HTTPS schuetzt Transport, nicht vor Einsicht durch den verarbeitenden Anbieter.

## Datenschutz und EU AI Act

**Projektpolicy: keine personenbezogenen, vertraulichen oder besonders
schutzbeduerftigen Daten an diesen ungeprueften Dienst senden.** Das gilt auch
fuer private Repositories, Kundenlogs, Personalakten, Stimmen und RAG-Ausgaben.
Ein Coding-Client kann mehr als den sichtbaren Prompt uebertragen.

Die Aussage "In China gilt die DSGVO nicht, daher ist jede Uebermittlung
verboten" ist keine zutreffende pauschale Rechtsbewertung. Fuer erfasste
Verarbeitungen bleiben die Pflichten des Verantwortlichen bestehen;
Drittlandtransfers brauchen zusaetzlich eine tragfaehige Grundlage und
Bewertung nach Kapitel V, etwa geeignete Garantien unter den Voraussetzungen
des Art. 46. Eine Vertragsklausel allein ist keine Sicherheitsgarantie.
Siehe [DSGVO, insbesondere Art. 3, 28 und 44-49](https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=CELEX:32016R0679).

Vor Produktivfreigabe: Rechtsgrundlage, Rollen/AV-Vertrag, tatsaechliche
Verarbeitungsorte, Unterauftragnehmer, Transferbewertung, Aufbewahrung,
Training/Caching, Loeschrechte und technische Massnahmen fachlich pruefen.
Pseudonymisierung ist nicht automatisch Anonymisierung. Ohne geklaerte
Nachweise bleibt die Freigabe gesperrt; lokale Ollama-Modelle bevorzugen.
Auch lokale Verarbeitung benoetigt Rechte-, Loesch- und Sicherheitskonzepte.

Der [EU AI Act](https://eur-lex.europa.eu/legal-content/DE/TXT/?uri=CELEX:32024R1689)
ist getrennt zu betrachten: konkrete Rolle, Verwendungszweck, Risikoklasse
und anwendbare Fristen pruefen; insbesondere koennen Transparenzpflichten
relevant sein. Weder API-Kompatibilitaet noch ein bestimmter Serverstandort
beweist AI-Act-Konformitaet. Keine pauschale juristische Freigabe durch diese Seite.

## Preise, Testguthaben und Zahlung

| Punkt | Einordnung am 20.10.2026 |
|---|---|
| Trial | [Betreiberwerbung](https://token8341.com/ar) nennt 0,5 CNY Startguthaben. Vor Anmeldung im Konto bestaetigen. |
| Aufladebonus | Dort werden weitere 5 CNY ab einer Aufladung von mindestens 5 CNY beworben; Bedingungen/Anspruch nicht getestet. |
| EUR/USD | Keine geprueften Tageskurse vorhanden. Die gelieferten EUR-/USD-Naeherungen werden nicht als Oktober-2026-Kurs uebernommen. |
| Modellkosten | Eingabe, Ausgabe, Cache, Einheiten und konkrete Modell-ID in der [Preisliste](https://www.token8341.com/en/pricing) pruefen; keine Spargarantie. |
| Zahlungsmittel | Firmenueberweisung wird beworben. Visa/Mastercard, Krypto, Alipay und WeChat Pay sind hier nicht belastbar bestaetigt; beim Betreiber nachfragen. |
| Erstattung | Laut AGB sind gutgeschriebene Aufladungen grundsaetzlich nicht erstattbar, vorbehaltlich ihrer Ausnahmen und geltenden Rechts. |
| Referral | Kein verifiziertes Partnerprogramm oder Affiliate-Link integriert. Spaetere Verguetung klar kennzeichnen, nicht als neutrale Empfehlung tarnen. |

Kosten in CNY erfassen; bei spaeterer Umrechnung Datum, Kursquelle, Kursrichtung
und Zahlungsgebuehren angeben. Trial-Guthaben ist kein dauerhaft kostenloser
Betrieb. Kein Aufladen oder automatischer Wechsel aus Ollama durch dieses Setup.

## Einsatzentscheidung und begrenzter Test

| Moeglicher Nutzen | Grenze / Voraussetzung |
|---|---|
| Ein Key, mehrere Modelle | Zentraler Key vergroessert Schadensumfang; getrennte Unterkeys/Quoten pruefen. |
| Synthetische Tests und oeffentlicher Beispielcode | Kein privater Repo-Kontext; keine echten Kundendaten; ausdrueckliche Cloud-Freigabe. |
| Optionaler Fallback | Nicht still aktivieren; Modellauswahl, Kontextweitergabe und Kosten vorher freigeben. |
| Zentrale Abrechnung | Anbieterabhaengigkeit, Preise, SLA und Rechnungen selbst pruefen. |

Manueller Test erst nach Hostbestaetigung und Freigabe: eine synthetische
Chat-Anfrage, eine gepruefte Modell-ID, begrenzte Ausgabe, 30 Sekunden Timeout,
ein gleichzeitiger Job, keine automatischen Retries und ein kleines serverseitiges
Budget, falls verfuegbar. Client-Timeout und Tokenlimit allein begrenzen das
Gesamtbudget nicht. Usage/Kosten abgleichen; 401/402/404 nicht blind wiederholen,
429/5xx nur begrenzt nach eigener Freigabe behandeln. Logs ohne Keys oder Inhalte.
Kein Provider-Healthcheck oder Kubernetes-Deploy ist Bestandteil der Dokumentation.

Verwandt: [OpenRouter](openrouter.md), [FreeLLMAPI](../freellmapi.md),
[Coding-Agenten und lokale Routinggrenzen](../../agents/coding-agent-profiles.md),
[Secrets und Keys](../../SECRETS_AND_KEYS.md).
