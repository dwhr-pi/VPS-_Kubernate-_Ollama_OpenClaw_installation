# Webinar-Stack mit dem Ultimate KI Setup

Stand: **22.10.2026**. Ueberarbeitete Einordnung des eingefuegten Webinar- Textes, kein Nachweis
einer fertig eingerichteten Gesamtplattform.

## Sinn und Zweck

Ein Webinar-Stack verbindet **Inhalt und Folien, Anmeldung, Teilnehmer- Kommunikation, Aufnahme
beziehungsweise Live-Ausstrahlung und Auswertung**. Deine KI kann Entwuerfe und Programmierarbeit
uebernehmen. Betrieb, Rechte, Freigaben, Mailzustellung und fachliche Qualitaet entstehen nicht
automatisch.

Fuer dein Setup ist ein schrittweiser Eigenbau sinnvoll: lokale Modelle fuer Entwuerfe, Marp fuer
Folien, WebsiteFactory fuer einen Landingpage-Entwurf, listmonk **oder** Mautic fuer
Teilnehmerkommunikation und ein bewusst ausgewaehlter Video-/Streamingpfad. Keine Docker-Pflicht,
kein zwangslaufiges Cloud-Abo und keine Garantie fuer einen kostenlosen oder datenschutzkonformen
Gesamtbetrieb. Hosting, Domains, Mailzustellung, Speicher und Wartung bleiben.

```text
Briefing und fachlich geprueftes Angebot
  -> KI-Entwurf fuer Skript und Folien -> menschliche Inhaltsfreigabe
  -> Landingpage-Entwurf -> Registrierungsbackend + Testanmeldung
  -> bestaetigte Anmeldung -> passende Service-/Marketingkommunikation
  -> Live-Veranstaltung ODER klar bezeichnete Aufzeichnung
  -> manuell freigegebener Replay-/Angebotsversand
  -> Abmeldung, Auswertung, Aufbewahrung und Bereinigung
```

## Werkzeuge und tatsaechlicher Stand im Setup

| Aufgabe                           | Werkzeug / offizielle Quelle                                         | Status und Grenze                                                                                          |
| --------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Skript, Gliederung, Mailentwuerfe | [Ollama](https://github.com/ollama/ollama), vorhandener Coding-Agent | Registriert beziehungsweise separat einrichtbar; gewaehltes Modell, Toolzugriff und Cloud-Fallback pruefen |
| Folien aus Markdown               | [Marp CLI](https://github.com/marp-team/marp-cli)                    | MIT; eigener GitHub-Releaseinstaller im Tools-Menue                                                        |
| Landingpage-Projekt               | [WebsiteFactory im Repository](../tools/websitefactory.md)           | Projektgenerator/Prototyp; Kontaktformular-UI ist kein fertiges Anmeldesystem                              |
| Newsletter und Kampagnen          | [listmonk](https://github.com/knadh/listmonk)                        | AGPL-3.0; eigener Installer, PostgreSQL und SMTP separat                                                   |
| Umfangreichere Kampagnen          | [Mautic](https://github.com/mautic/mautic)                           | GPL-3.0-or-later, **nicht AGPL**; eigener Vollpaketinstaller, PHP/DB/Webserver separat                     |
| Aufnahme und Live-Produktion      | [OBS Studio](https://github.com/obsproject/obs-studio)               | Open Source; hier als zusaetzlicher Kandidat dokumentiert, kein neuer OBS-Installer hinzugefuegt           |
| Interaktive Konferenz             | [Jitsi Meet](https://github.com/jitsi/jitsi-meet)                    | Open Source; alternativer Konferenzpfad, hier kein neuer Jitsi-Installer oder Server eingerichtet          |
| Schnitt, Untertitel, kurze Assets | [vorhandene Medienplanung](../media_studio/README.md)                | Werkzeuge/Modelle einzeln pruefen; keine fertig verkabelte Webinarpipeline                                 |

Installer und Betrieb nicht verwechseln: **Marp, listmonk und Mautic sind im Setup installierbar**,
dadurch aber nicht nachweislich auf jedem Zielrechner installiert. Die Installer aktivieren keine
Datenbank, SMTP-Verbindung, Marketingkampagne, PHP-Anwendung oder oeffentlichen Webserver.
[Installations- und Plattformanleitung](../tools/webinar-tools.md).

Fuer komplexe Automationsstrecken bietet Mautic mehr Marketinglogik als ein reiner Newsletterpfad;
es ist trotzdem nicht pauschal jedes Vertriebs-CRM. Die Lizenzkorrektur stammt aus der
[Mautic-Lizenz](https://github.com/mautic/mautic/blob/HEAD/LICENSE.txt). Die korrekte
listmonk-Quelle ist **knadh/listmonk**, nicht eine Google-Suche oder ein angenommenes
listmonk/listmonk-Repository.

## Phase 1: Thema, Skript und Folien

Beginne mit Zielgruppe, Lernziel, konkretem Angebot und belegbaren Aussagen. Die im Ausgangstext
genannte Verkaufsformel ist nur eine moegliche Struktur, kein technischer Standard und kein
Erfolgsnachweis.

Eigener Prompt fuer Ollama/Qwen oder einen anderen bewusst gewaehlten Agenten:

```text
Erstelle einen ENTWURF fuer ein 45-minuetiges Webinar zu [Thema].
Zielgruppe: [Zielgruppe]. Lernziel: [konkretes Ergebnis].
Angebot und belegte Fakten: [Angaben, keine personenbezogenen Kundendaten].

Gliedere: Einstieg 5 Min., Lerninhalte 25 Min., Angebot 5 Min., Fragen 10 Min.
Erstelle Sprecherhinweise und einen Folienentwurf in Marp-Markdown.
Kennzeichne offene Fakten und Quellenbedarf. Erfinde keine Testimonials,
Erfolgsgarantien, Preise, Zertifizierungen oder kuenstliche Verknappung.
Bei einer Aufzeichnung: Q&A als vorbereitete Fragen kennzeichnen, nicht als
aktuell eingehende Publikumsfragen. Noch nichts versenden/veroeffentlichen.
```

Marp verarbeitet den Markdown-Entwurf lokal. Reihenfolge: Text freigeben, HTML-Vorschau pruefen,
erst danach PDF/PPTX exportieren. PDF/PPTX benoetigt einen passenden Browser; normaler PPTX-Export
besteht aus gerenderten Folien, nicht automatisch einzeln bearbeitbaren PowerPoint-Objekten.
[Offizielle Marp-Exportoptionen](https://github.com/marp-team/marp-cli#usage). Fuer ungepruefte
KI-Folien keine feste Exportzeit oder professionelle Gestaltungsqualitaet versprechen.

## Phase 2: Landingpage und echte Registrierung

[WebsiteFactory](../tools/websitefactory.md) kann als Ausgangspunkt ein Landingpage-Projekt
erzeugen. Nutze nachvollziehbare Inhalte: Thema, Referent, Termin mit Zeitzone, Dauer,
Live-/Replay-Status, Teilnahmebedingungen, Kontakt und benoetigte Datenschutzhinweise. Countdown nur
fuer einen echten Termin verwenden, nicht als bei jedem Besuch neu startende Verkaufsfrist.

Ein HTML-Formular allein speichert oder bestaetigt keine Anmeldung. Noch gesondert einzurichten sind
unter anderem:

- Ein serverseitiger Registrierungsendpunkt mit Eingabepruefung und Rate-Limit.
- Dokumentierter Teilnahme-/Einwilligungsstatus und nachvollziehbare Zeitpunkte;
  Veranstaltungsnachrichten und optionale Werbung nicht gleichsetzen.
- Bestaetigungsprozess, Fehlerbehandlung, Abmeldung und Schutz vor doppelten Jobs.
- Eine gepruefte API-Anbindung an **ein** gewaehltes Mailingwerkzeug.
- HTTPS, Secret-Verwaltung, Zugriffsschutz und ein vorab getesteter Datenpfad.

API-/SMTP-Schluessel gehoeren nie in ausgeliefertes HTML oder Browser-JavaScript. Ein oeffentlicher
Anmeldeendpunkt braucht eigene Absicherung, nicht einfach einen anonym erreichbaren
Admin-/Kampagnen-Webhook. Ein Reverse Proxy und TLS koennen nativ betrieben werden; Docker ist
dafuer keine Voraussetzung. Nichts davon wird durch diesen Leitfaden automatisch deployt.

## Phase 3: Aufnahme, Grafiken und optionale KI-Medien

Fuer das erste Webinar **eigene Stimme plus Bildschirm-/Folienaufnahme** verwenden.
[OBS Studio](https://github.com/obsproject/obs-studio) dient zur Aufnahme und Live-Produktion;
KI-Avatar und generatives Video sind optional. Mit Testaufnahme Tonverstaendlichkeit, Schriftgroesse
und Sprecherzeiten pruefen.

ComfyUI/Wan/LTX allenfalls fuer kurze, vorher gepruefte Grafiken oder Clips ergaenzen, nicht als
Pflicht fuer einen durchgaengig generierten 45-Minuten-Film. Mit den bekannten **16 GB VRAM** deiner
RTX 5080 konservativ planen: ein GPU-Job gleichzeitig, kleine Vorschauen, nicht Video, LLM und TTS
gleichzeitig im VRAM halten. Linux-Speicher und Windows-Speicher am VHDX- Standort getrennt pruefen;
Modell-/Cachebedarf kommt hinzu.
[Bearbeitbare Videorezepte und Grenzen](../media_studio/EDITABLE_VIDEO_WORKFLOWS.md).

Code auf GitHub macht Modellgewichte und Stimmen nicht automatisch fuer kommerzielle Werbung frei.
XTTS oder beliebige LipSync-Gewichte deshalb nicht pauschal empfehlen; genaue Modelllizenz und
Personen-/Stimmrechte pruefen.
[Vorhandene Medien-/Lizenzhinweise](../media_studio/SOCIAL_AVATAR_AUTOMATION.md).

## Phase 4: Teilnehmerkommunikation

Fuer einen schlanken Start **listmonk** waehlen, bei benoetigten komplexen Kampagnenverzweigungen
**Mautic** evaluieren. Nicht beide installieren muessen, um ein Webinar anbieten zu koennen.
listmonk benoetigt PostgreSQL:
[offizielle Installationsbeschreibung](https://listmonk.app/docs/installation/).

Die KI schreibt Entwuerfe; Versand wird separat freigegeben. Beispielablauf:

| Zeitpunkt / Ereignis             | Nachricht                                 | Pruefung vor Aktivierung                                        |
| -------------------------------- | ----------------------------------------- | --------------------------------------------------------------- |
| Anmeldung bestaetigt             | Termin/Zugang und gegebenenfalls Workbook | Richtiger Empfaenger, Zweck, Zeit und Link                      |
| 24 Stunden vor Termin            | Erinnerung                                | Nur wenn noch zukuenftig; Zeitzone/Sommerzeit beachten          |
| 1 Stunde vor Termin              | Kurze Erinnerung                          | Abmeldung, Absage und Terminverschiebung beruecksichtigen       |
| Nach Ende                        | Replay, falls vorgesehen                  | Aufnahme-/Freigabestatus und echte Gueltigkeit                  |
| Separat vorgesehene Werbesequenz | Angebot                                   | Passender Freigabe-/Einwilligungsstatus; keine falsche Deadline |

Ein terminrelativer Reminder fuer jeden Teilnehmer braucht Zeitsteuerung; eine Newsletterkampagne
allein ist noch keine vollstaendige Reminder-Engine. Bei Wiederholungen denselben Versandauftrag
wiederaufnehmen statt nach jedem Timeout eine weitere Mail ausloesen. Versandjournal,
Abmelde-/Sperrliste, Bounce-Verarbeitung und kontrollierte Retries vorsehen. Zuerst eine eigene
Testadresse, keine echten Kontaktlisten importieren.

SMTP-Zustellbarkeit und Domainkonfiguration gehoeren zum Betrieb. SPF, DKIM, DMARC und
gegebenenfalls rDNS passend einrichten und testen; ein lokal laufendes Programm garantiert keine
Inbox-Zustellung. Kosten und externe Datenfluesse des ausgewaehlten SMTP-Anbieters beruecksichtigen.

## Phase 5: Live oder transparentes Replay

**Live mit Rueckfragen:** Jitsi Meet kann ein Konferenzbaustein sein. Moderation,
Teilnehmendenrechte und Last separat testen; kein pauschales Versprechen fuer beliebig grosse
Zuschauerzahlen. [Offizielles Jitsi-Repository](https://github.com/jitsi/jitsi-meet).

**Live-Broadcast:** OBS erzeugt das Ausgangssignal. Ein Streaming-/Medienserver oder externer
Empfangsdienst und ein geeigneter Player kommen hinzu. Eine Nginx-Seite mit Basic Auth ist weder
automatisch ein Streamingbackend noch eine individuelle Webinar-Zugangsverwaltung.

**Replay/On-Demand:** Aufnahme deutlich als solche bezeichnen. Server/Player, Zugangsschutz,
Bandbreite, Untertitel und Ablaufdatum testen. Ein Computer, der ausgeschaltet ist, hostet kein
jederzeit verfuegbares Replay. Keine simulierten Zuschauer, erfundenen Live-Nachrichten oder
gefaelschten Testimonials. Vorbereitete FAQ oder eine echte asynchrone Fragefunktion koennen
transparent angeboten werden.

Traffic ist eine eigene Arbeitsstrecke: KI kann Posts und Anzeigenentwuerfe vorbereiten; Werbekonto,
Tracking, Budget und Veroeffentlichung werden nicht automatisch freigegeben. Keine zugesagten Leads,
Conversions oder Einnahmen.

## Zustaendigkeiten im eigenen Setup

| Umgebung           | Sinnvoller Einsatz                                            | Nicht automatisch erledigt                                                   |
| ------------------ | ------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Windows            | Marp, Aufnahme/Schnitt und Desktop-Coding-Agent               | Kein automatischer produktiver Mautic-Webserver                              |
| Ubuntu/WSL         | Getrennte Tools/Entwicklung und lokale Integrationstests      | Kein garantierter 24/7-Dienst oder oeffentlicher Webzugang                   |
| MiniPC             | Leichte Planung und bei geeigneter Konfiguration Koordination | Kein Ersatz fuer die GPU bei schweren Videomodellen                          |
| RTX-Host           | Lokale Modelle und kurze Medienjobs                           | Keine Zusage fuer Modellpassung, Renderzeit oder freien Speicher             |
| Eigener Server/VPS | Bewusst bereitgestellte oeffentliche Webseite/Dienste         | DNS, TLS, Mail, Monitoring, Datenschutz und Backups bleiben Betriebsaufgaben |

Im Tools-Menue **Ubuntu / Windows** fuer Marp, listmonk oder Mautic waehlen, dann Werkzeug und
Aktion. Plan ist Standard; Windows- und Linux-Status sind getrennt. Details, Pins und Deinstallation
nicht doppelt hier pflegen: [Webinar-Werkzeuge installieren](../tools/webinar-tools.md).

## Kleine Abnahme vor der ersten Veroeffentlichung

1. Ein Thema und wenige Folien mit Testdaten erstellen, Inhalt freigeben.
2. Kurze eigene Aufnahme mit verstaendlichem Ton und lesbaren Folien pruefen.
3. Anmeldeseite und Backend mit eigener Testadresse verbinden; keine echten Kontakte importieren.
   Doppelanmeldung und ungueltige Eingaben pruefen.
4. Bestaetigung, Terminverschiebung, Abmeldung und Versandwiederholung testen.
5. Replay-/Live-Zugang mit getrenntem Testnutzer sowie unberechtigtem Zugriff testen.
6. Rechte, Hinweise, Loesch-/Aufbewahrungsplan und Restore-Test abnehmen.
7. Erst dann getrennt Hosting, Mailversand oder Anzeigen freigeben.

Selfhosting allein bestaetigt keine DSGVO-Konformitaet. Fuer die konkrete Konfiguration,
Empfaengerkommunikation, Aufzeichnung und Datenverarbeitung eine passende fachliche/rechtliche
Pruefung vorsehen. Der Leitfaden ersetzt keine Beratung und keine Abnahme. Primaerquelle fuer eine
solche Pruefung:
[DSGVO im EU-Amtsblatt](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de).

**Nicht durch diese Dokumentation ausgefuehrt:** Installation, WSL-/GPU-Start, Formularbetrieb,
Datenbankmigration, SMTP-Konfiguration, Mailversand, Aufnahme, Streaming, Tracking, Werbung oder
Publikation. Verlinkte Tools und Prototypen bilden noch keinen end-to-end getesteten Webinar-Funnel.

## CI-Quellenabgleich (30.10.2026)

Die Alt-Adressen bleiben als Herkunftsbeleg erhalten. Die neuen Nachweise wurden anonym mit HTTP 200
abgerufen und anhand von Titel und CELEX bzw. offizieller Projektquelle zugeordnet.
EU-Metadatensaetze belegen die jeweilige Originalveroeffentlichung, nicht eine aktuelle
konsolidierte Rechtspruefung. Keine Anmeldung und keine Provider-Inferenz.

| Alt-Adresse (Abruf fehlgeschlagen)                        | Erreichbarer Nachweis                                                                                                      |
| --------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `https://eur-lex.europa.eu/eli/reg/2016/679/oj?locale=de` | [Primaerquelle](https://op.europa.eu/en/publication-detail/-/publication/3e485e15-11bd-11e6-ba9a-01aa75ed71a1/language-de) |
