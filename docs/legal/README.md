# Recht, KI-Governance und RAG-Datenschutz

Stand der Recherche: **21.10.2026**. Diese Integration unterstuetzt Recherche,
technische Vorpruefung und dokumentierte Entscheidungen. **Keine Rechtsberatung,
keine Zertifizierung und keine Garantie weltweiter Gesetzeskonformitaet.**
Ein Prompt kann Gesetze weder vollstaendig kennen noch technisch erzwingen.

## Einstieg im Setup

Nachgereichte Unterlage: [DSB-Dokumentation und fachlicher Abgleich](DSB_DOCUMENT_SOURCE_REVIEW.md).
Das als vertraulich gekennzeichnete PDF bleibt ausserhalb des Repositorys;
seine Aussagen sind kein Nachweis vollstaendiger Konformitaet.

Hauptmenue **18: Recht und RAG-Compliance: Offline-Pruefung** zeigt offene
Quellenpruefungen und die Laenderabdeckung. Es startet keinen Server, keinen
Cloud-Aufruf, keine Datenbankmigration und keine automatische Loeschung.

| Bestandteil | Nutzen | Umgesetzt |
|---|---|---|
| [Rechtsaenderungen und Osteuropa](TEMPORAL_UPDATES_AND_EASTERN_EUROPE.md) | Historische Fassungen, Quellenpflege und RU/UA/PL/CZ/SK | Offline-Zeit-/Zugriffsfilter; kein automatischer Rechtsimport |
| [Internationale Rechtsquellen](INTERNATIONAL_SOURCES.md) | Recht, Entwurf, Richtlinie und freiwilligen Rahmen trennen | Datierte Einstiegsrecherche, offene Pruefluecken sichtbar |
| [Laenderabdeckung](COUNTRY_COVERAGE.md) | Alle 193 UN-Mitglieder und zwei Beobachterstaaten auffuehren | Abdeckungsmatrix, keine vollstaendige nationale Rechtspruefung |
| [RAG-Architektur und Korrekturen der Anlage](RAG_COMPLIANCE_ARCHITECTURE.md) | PII, Loeschung, Audit, Monitoring und CI sicher einordnen | Architektur, Komponentenmatrix und Gefahrenanalyse |
| [Master-Prompt](prompts/GLOBAL_AI_RAG_REVIEW.md) | Codex/Qwen/OpenClaw projektbezogen zur Recherche anleiten | Vorlage, nicht global aktiviert |
| [DSB-Uebergabetemplate](templates/DSB_HANDOVER.md) | Zweck, Datenfluesse, TOMs und offene Befunde dokumentieren | Ausfuellbares Markdown, keine automatische Abnahme |
| [Lokale Pruef-CLI](../../tools/rag_compliance/README.md) | Quellenalter, Szenario, Loeschplan und Auditdatei offline pruefen | Python-Standardbibliothek, keine Installation noetig |

## Wesentliche Korrekturen gegenueber der Anlage

- **Keine weltweite Legal-Assurance-Engine:** Anwendbares Recht folgt unter
  anderem Betreiber-/Betroffenenstandort, Zielmarkt, Taetigkeit, Rolle und Branche.
  Nicht alle Gesetze aller Laender gelten gleichzeitig fuer jedes Projekt.
- **Pseudonymisierung ist keine zugesicherte Anonymisierung.** Auch Hashes,
  Maskierungen und Embeddings koennen Personenbezug behalten. Siehe
  [EDPB-Einordnung](https://www.edpb.europa.eu/topics/ai-and-technology/anonymisation-pseudonymisation_en).
- **Audit-Hashes beweisen keine absolute Unveraenderbarkeit.** DB-Administratoren,
  kompromittierte Hosts oder entfernte Kettenenden brauchen ein weitergehendes
  Bedrohungsmodell und unabhaengige Vergleichswerte.
- **Keine automatische Kettenreparatur:** Bei Manipulationsverdacht Originale
  sichern, Vorfall untersuchen und gegebenenfalls eine neue dokumentierte Epoche
  beginnen; nicht die Geschichte neu hashen und wieder "alles gueltig" melden.
- **Keine Volltext-Logs als Standard:** Prompts, Ausgaben, Namen, Tokens und
  Geheimnisse nicht pauschal aufbewahren. Minimierung, Zugriff und Fristen planen.
- Docker/WSL sind nicht automatisch Sicherheits-Sandboxes. Ein Docker-Socket
  oder privilegierter Runner kann umfassenden Hostzugriff ermoeglichen.
- Ein DSB beraet/ueberwacht; eine Unterschrift ersetzt weder Betreiberverantwortung
  noch den Nachweis einzelner Pflichten.

## Aktualitaet und Rechtsfreigabe

[sources.json](../../config/legal/sources.json) trennt `overview-reviewed`,
`retrieval-blocked`, `search-only` und `not-reviewed`. Ein erreichbarer Link
oder ein kuerzlich gepruefter Ueberblick ist keine abgeschlossene Rechtspruefung.
Der Doctor meldet nach 30 Tagen erneut faellige Ueberblickspruefungen;
ungepruefte/blockierte Quellen bleiben sofort offen. Es werden keine Daten
automatisch ins Netz geschickt und keine Rechtsstaende still aktualisiert.

Empfohlener woechentlicher Ablauf: Anwendungsfall eingrenzen, amtliche Quellen
und konsolidierte Fassungen manuell recherchieren, Aenderungen mit Datum und
Belegen dokumentieren, fachlich pruefen lassen und erst danach Policy/Code
anpassen. Fuer den Rechercheauftrag die Promptvorlage nutzen. Hier wurde
**keine wiederkehrende Automation, aktive CI oder Hintergrundrecherche eingerichtet**.
Ein manueller Doctor-Aufruf ersetzt diese Recherche nicht.

Die [vorhandenen Governance-Profile](../Profile/AI_Governance_Audit.md) und das
[Legal-Review-Profil](../Profile/Legal_Compliance_Safety_Review.md) bleiben
getrennte, nicht automatisch aktivierte Bausteine. Auch das
[Personalakten-Projekt](../tools/personnel-documents.md) erhaelt dadurch keine
Freigabe fuer echte Personalakten.
