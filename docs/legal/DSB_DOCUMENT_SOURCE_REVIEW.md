# DSB-Unterlage: Einordnung fuer die RAG-Dokumentation

Nutzerquelle: DSB Dokumentation Generator.pdf, zwei Seiten, Dokument-ID
DOC-DSGVO-RAG-2026-V1, Quelldatum 21.10.2026. Aufgenommen am 24.10.2026.
Die PDF ist als Vertraulich (Intern) gekennzeichnet. Ihr Original wird deshalb
nicht in das GitHub-Repository uebernommen; es verbleibt lokal beim Nutzer.
Dateifingerabdruck und Zuordnung: [Quellenregister](../sources/2026-10-24/README.md).

## Sinn und Verwendung

Die Unterlage beschreibt eine Uebergabeakte fuer einen RAG-Dienst: Systemzweck,
Datenfluesse und PII-Verarbeitung, Loeschung, Rollen, Audit-Integritaet,
Monitoring, Export und Freigabe. Diese Gliederung kann als Review-Checkliste
fuer das [DSB-Uebergabetemplate](templates/DSB_HANDOVER.md) verwendet werden.
Sie ist weder ein installierbarer Generator noch der Nachweis eines implementierten
oder abgenommenen RAG-Systems. Die genannten Exporter, Trigger und Testskripte
sind durch die PDF allein nicht als vorhandene Repository-Funktionen belegt.

## Abgleich statt ungepruefter Uebernahme

| Aussage / Abschnitt der Quelle | Behandlung in der Projektakte |
|---|---|
| Vollstaendige Einhaltung von DSGVO, AI Act, ISO und GoBD | Nicht als bestaetigte Compliance uebernehmen; Geltungsbereich, Anforderungen und einzelne Nachweise fachlich pruefen lassen |
| Maskierung und Hashing schliessen Re-Identifizierung aus | Nicht als Anonymitaetsnachweis verwenden; Personenbezug, Zuordnungswissen und Bedrohungsmodell dokumentieren |
| Atomare, unwiderrufliche Loeschung aller Daten | Quellsysteme, Embeddings, Replikate, Caches, Exporte und Backups separat inventarisieren und Restore-/Loeschverhalten nachweisen |
| Trigger und Hash-Kette machen Logs unveraenderlich | Privilegierte Zugriffe und externe Vergleichswerte beruecksichtigen; Integritaetspruefung nicht mit absoluter Manipulationssicherheit gleichsetzen |
| Ephemere Runner garantieren Zero Data Retention | Artefakte, Caches, Logs, Host-Volumes und externe Dienste zusaetzlich pruefen; Runner-Loeschung ist kein Gesamtnachweis |
| DSB-Unterschrift bestaetigt vollstaendige Konformitaet | Fachliche Pruefung und Betreiberfreigabe unterscheiden; keine vorweggenommene Unterschrift oder Zertifizierung |

Diese Einordnung verweist auf die bereits dokumentierten Grenzen und Quellen in
[RAG-Compliance-Architektur](RAG_COMPLIANCE_ARCHITECTURE.md) und
[Recht / Governance](README.md). Sie ersetzt keine neue juristische Pruefung.
Keine personenbezogenen Daten, produktiven Logs, Unterschriften oder Secrets
wurden fuer diese Ergaenzung verarbeitet oder ins Repository uebernommen.

## Naechster manueller Schritt

Das Template mit tatsaechlichem Systemstand, Verantwortlichen, Datenkategorien,
Zugriffsrechten, Fristen und Testbelegen ausfuellen. Offene Punkte als offen
belassen und fachlich abnehmen lassen. Eine spaetere Veroeffentlichung des
Originals setzt eine ausdrueckliche Freigabe seiner Vertraulichkeit voraus.
