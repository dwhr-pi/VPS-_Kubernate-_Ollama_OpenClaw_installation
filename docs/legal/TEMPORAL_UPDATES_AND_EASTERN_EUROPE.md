# Rechtsaenderungen, Zeitfilter und Osteuropa

Stand: 21.10.2026. Ergaenzung zur [RAG-Architektur](RAG_COMPLIANCE_ARCHITECTURE.md).
Keine Rechtsberatung und keine automatische Rechtsfreigabe.

## Was bereits funktioniert

Der Quellen-Doctor fuehrt jetzt auch Russland, Ukraine, Polen, Tschechien und
Slowakei. Die [Laenderliste](COUNTRY_COVERAGE.md) enthaelt weitere Staaten;
dies ist weder eine vollstaendige Osteuropa-Recherche noch ein gemeinsamer
Rechtsraum. EU-Mitgliedschaft ersetzt keine nationale Pruefung.

Die [Offline-CLI](../../tools/rag_compliance/README.md) kann lokale
Versionsmetadaten nach Rechtsstichtag, Erfassungsdatum, Jurisdiktion,
Mandant und Rolle filtern. Sie erzeugt keine Embeddings, kontaktiert keine
Rechtsportale und veraendert keinen Index. Die Beispielversionen sind frei
erfunden und enthalten keine echten Gesetzestexte.

```bash
bash scripts/check_rag_compliance.sh temporal-context tools/rag_compliance/examples/temporal-versions.json --as-of 2025-12-31 --known-on 2026-10-21 --jurisdiction RU --tenant demo --role reviewer
```

Erwartet: historische Version `v1`, obwohl deren heutiger Status `REPEALED`
lautet. Ab 2026-01-01 passt nur `v2`, jedoch nicht bei einem Wissensstand vor
deren Erfassung am 2026-01-03. Fehlende Treffer bleiben `insufficient-evidence`;
es gibt kein Ausweichen auf andere Rechtsraeume oder ungepruefte Fassungen.

## Versionsmodell und Grenzen

| Feld | Bedeutung |
|---|---|
| `source_id`, `version_id`, `chunk_id` | Stabile kombinierte Identitaet; doppelte Kombinationen werden abgelehnt |
| `valid_from`, `valid_until` | Fachlich festgelegtes Intervall: Anfang inklusive, Ende exklusiv; `null` fuer offenes Ende |
| `recorded_on`, `--known-on` | Erfassungsdatum und gewuenschter Wissensstand auf Tagesebene |
| `--as-of` | Zu untersuchender Rechtsstichtag, nicht zwingend heute |
| `review_state` | Nur als `approved` markierte Metadaten liefern Kontext; keine Rechtsfreigabe durch das Programm |
| `tenant`, `allowed_roles` | Filter vor Ausgabe; Identitaet/Rollen hier nur Selbstauskunft |
| `law_status` | ACTIVE/AMENDED/REPEALED; ersetzt nicht die historische Intervallpruefung |

Veroeffentlichung, Inkrafttreten, Anwendung und Uebergangsrecht getrennt
modellieren. Die CLI setzt ein bereits fachlich festgelegtes Intervall voraus;
sie leitet es nicht selbst aus Gesetzen ab. Inklusive gesetzliche Enddaten
muessen vor Import korrekt auf exklusive Grenzen normalisiert werden.
Keine lokale Zeitzonen-Umrechnung und kein Jahr-9999-Ersatz fuer `null`.

Dies ist **keine vollstaendige bitemporale Datenbank**: nachtraegliche Korrekturen,
Kenntniszeit-Enden, Ueberlappungen, Spezial-/Uebergangsregeln und gerichtliche
Auslegung brauchen ein erweitertes Modell. Produktionsbetrieb braucht zudem
vertrauenswuerdige Quellen-/Freigabesignaturen und serverseitige Authentisierung.
IDs allein belegen keine Herkunft. Keine produktiven Personaldaten verwenden.

Mehrere Jurisdiktionen ergeben nur `cross_jurisdiction_context=true`.
`conflict_status=not-assessed` bleibt bestehen: Ein Rechtskonflikt muss fachlich
festgestellt werden, nicht durch Zaehlen der Laender. Bei Sanktionen,
Gegensanktionen oder widerspruechlichen Pflichten an juristische Pruefung abgeben.

## Aktualisierung: kontrollierte Zielarchitektur

1. Verantwortliche Person, Rechtsraeume und amtliche Quellen festlegen. Fuer
   relevante Quellen taegliche Veroeffentlichungspruefung planen, mindestens
   woechentliche fachliche Sichtung; Frequenz am Risiko ausrichten.
2. Abrufadapter je Portal pruefen: Nutzungsbedingungen, HTTPS-Hosts, Groessenlimit,
   Timeouts, Rate Limits, ETag/Last-Modified und nachvollziehbare Abruffehler.
   Keine Zugangsschluessel an unbestaetigte Hosts/Redirects weiterreichen.
3. Originalsnapshot mit Quelle, Abrufzeit, Dokumentkennung und Inhalts-Hash
   versionieren. HTML-/Hash-Aenderung ist nur ein Pruefanlass, kein neues Gesetz.
   Bei Ausfall den alten Stand als moeglicherweise veraltet kennzeichnen.
4. Aenderung, Berichtigung, konsolidierte Fassung, Inkrafttreten und Anwendung
   fachlich vergleichen. Originalsprache aufbewahren; RU/DE/EN-Uebersetzungen
   kennzeichnen und bei entscheidenden Begriffen gegen das Original pruefen.
5. Neue Fassungen zunaechst in Quarantaene. Nur betroffene Chunks neu berechnen,
   IDs aus Dokument/Fassung/Abschnitt stabil ableiten. Niemals den kompletten
   Produktivindex per `recreate_collection` ersetzen oder Batch-Zaehler als IDs nutzen.
6. Nach Freigabe neuen Indexstand atomar veroeffentlichen, alten Stand fuer
   historische Fragen/technischen Rollback erhalten. Quelle, Fassung, Stichtag
   und Pruefdatum jeder Antwort zuordnen; sensible Antworttexte nicht pauschal loggen.

**Hier nicht implementiert/aktiviert:** Scheduler, Webcrawler, Delta-Parser,
Qdrant-/pgvector-Adapter, automatische Modell-Downloads, Embedding-Jobs oder
Policy-Aenderungen. Der vorhandene Doctor prueft nur lokale Prueffristen.
Das Skript `hitl_guardrail_gateway.py` aus der Anlage wird nicht als vorhandene
Integration vorausgesetzt. Ein Sprachmodell-Prompt ist keine Sicherheitssperre.

## Amtliche Einstiege und offene Pruefungen

| Land | Quelle | Recherchebefund / Grenze |
|---|---|---|
| Russland | [pravo.gov.ru](https://pravo.gov.ru/), [Veroeffentlichungsportal](https://publication.pravo.gov.ru/) | Beide Abrufe am 21.10.2026 mit Timeout; aktuelle Gesetze nicht verifiziert |
| Ukraine | [Verkhovna Rada](https://zakon.rada.gov.ua/laws/main?lang=en) | Amtliche Parlamentsdatenbank; Original-/Uebersetzungsstand einzeln pruefen |
| Polen | [ISAP](https://isap.sejm.gov.pl/), [ELI](https://eli.sejm.gov.pl/) | ISAP weist selbst auf den informativen Charakter vereinheitlichter Texte hin |
| Tschechien | [e-Sbirka](https://www.e-sbirka.cz/) | Amtliche Dokumente gefunden; Portal-/Fassungspruefung offen |
| Slowakei | [Slov-Lex Archiv](https://www.slov-lex.sk/ezbierky/archiv-zbierky-zakonov) | Zeitliche Fassungen und Aenderungsarchive als Rechercheeinstieg |

Fuer Russland gehoeren insbesondere 152-FZ zum Datenschutz, dessen aktuelle
Aenderungen, Art. 18 Abs. 5, Ausnahmen, grenzueberschreitende Verarbeitung und
gegebenenfalls das Zivilrecht in die fachliche Recherche. **Keine bestaetigte
Aussage zur derzeitigen Fassung:** der amtliche Abruf war nicht erfolgreich.
Keine automatische Datenuebertragung oder Speicherung in Russland aktivieren.
ConsultantPlus/Garant sind ergaenzende kommerzielle Datenbanken, nicht mit
amtlichen Portalen oder frei nutzbaren APIs gleichzusetzen; Vertrag/Lizenz pruefen.

Der [Quellenbestand](../../config/legal/sources.json) bleibt bewusst unvollstaendig.
Portalidentifikation ist weder Pruefung aller dortigen Gesetze noch dauerhafte
Aktualitaetsgarantie. Fuer produktive Loesungen sind lizensierte Datenfeeds oder
ein fachlich betreuter Quellenprozess vor einer autonomen Rechtsbewertung vorzuziehen.
