# RAG-System: Uebergabe- und Pruefakte

**Status: Entwurf / nicht produktiv freigegeben.**
Dieses Template bestaetigt keine DSGVO-, AI-Act-, GoBD- oder ISO-Konformitaet.
Mit synthetischen Daten ausfuellen; echte personenbezogene Falldaten und
Geheimnisse nicht in das oeffentliche Setup-Repository uebernehmen.

## 1. Verantwortlichkeit und Zweck

| Feld | Einzutragen |
|---|---|
| Dokument-ID / Version / Datum | offen |
| Verantwortlicher / Betreiber / Systemverantwortung | offen |
| Anbieter-/Betreiberrolle und Dienstleister | offen |
| Zweck, Zielgruppe und nicht erlaubte Nutzungen | offen |
| Jurisdiktionen, Zielmaerkte und Branche | offen |
| Datenkategorien, betroffene Personen, besondere Daten | offen |

## 2. Rechtspruefung und Quellen

Pro Norm: aktuelle amtliche URL, Fassung, Recherchedatum, Anwendbarkeitsgruende,
Pflichten, Verantwortlicher und offene Fragen festhalten. Rechtsgrundlage,
Auftragsverarbeitung, Drittlanduebermittlung, AI-Risikoklassifikation und eine
gegebenenfalls notwendige Datenschutz-Folgenabschaetzung fachlich bewerten.
Unzulaengliche Quellen/Entwuerfe als solche markieren.

## 3. Datenfluss und TOMs

- Quelle, erlaubte Nutzung, Lizenz/Einwilligung/Rechtsgrundlage und Herkunft.
- Parser/OCR/PII-Recognizer: Version, Sprache, Testset, Fehlerquoten, Rest-Risiken.
- Embedding-/LLM-/Vektorspeicher: lokal/extern, Zugriffsmodell, Mandantenfilter.
- Verschluesselung, TLS, Schluesselverwaltung, Rollen, Adminrechte und Updates.
- Keine pauschale Gleichsetzung von Maskierung/Pseudonymisierung mit Anonymitaet.

## 4. Loesch- und Aufbewahrungskonzept

Dokument-/Chunk-/Vektor-Mapping sowie Dateien, Cache, Exporte, Logs und Backups
erfassen. Rechtsgrundlagen/Fristen und Legal Holds klaeren. Loeschauftrag,
Bestaetigung, Ausfuehrung, Erfolgskontrolle und Wiederherstellungsregeln getrennt
dokumentieren. Keine ungedeckte Zusage "sofort atomar ueber alle Systeme".

## 5. Audit und Vorfaelle

Logfelder, Minimierung, Zugriff und Aufbewahrung festlegen. Kettenformat,
Serialisierung, Konkurrenzkontrolle, externer Anker, Schluessel-/Signaturkonzept
und dessen Grenzen dokumentieren. Vorfallbeweise nicht durch Re-Hashing ersetzen.
Monitoring-/Exportfelder und Empfaengerrechte pruefen, keine automatische
Behauptung gerichtlicher Beweiskraft oder vollstaendiger Unveraenderbarkeit.

## 6. Technische Nachweise und offene Befunde

| Pruefung | Version / Datum | Ergebnis / Beleg | Offen / Verantwortlich |
|---|---|---|---|
| PII-Qualitaet mit synthetischen mehrsprachigen Daten | offen | offen | offen |
| Retrieval-/Mandantenrechte und negative Zugriffstests | offen | offen | offen |
| Loeschabdeckung einschliesslich Restore-Prozess | offen | offen | offen |
| Auditmanipulation und externe Vergleichswerte | offen | offen | offen |
| Export-/Log-Minimierung und Secret-Scan | offen | offen | offen |
| CI-/Runner-Persistenz und Zugriffsschutz | offen | offen | offen |

## 7. Beratung, Entscheidung und Wiederpruefung

DSB-/Fachberatung mit Datum, Vorbehalten und offenen Punkten dokumentieren.
Die gesonderte Betreiberentscheidung nennt Zweck, Umfang, Restrisiken und
gueltige Version. **Keine pauschale DSB-Unterschrift als Rechtszertifizierung.**

- Fachliche Stellungnahme: offen.
- Betreiberentscheidung / Verantwortlicher: offen.
- Bedingungen vor Produktivbetrieb: offen.
- Wiederprueftermin und Aenderungsausloeser: offen.

Markdown kann nach fachlicher Pruefung in einer kontrollierten Umgebung als
PDF ausgegeben werden. Ein PDF-Layout oder eine Pruefsumme ersetzt keine
inhaltliche Freigabe, Signatur oder sichere Uebergabe.
