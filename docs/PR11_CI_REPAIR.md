# PR 11: CI-Reparatur

## Ursachen und Patch

- Die beiden Offline-Regression-Laeufe (Push/PR) meldeten dieselben zwei Fehler.
  Die Recovery-Matrix enthielt XERJ und FFmpeg noch nicht. Beide erhalten explizite
  A/B-Szenarien samt zu erhaltenden Daten; der Vollstaendigkeitstest bleibt unveraendert.
- Der SSH-Linktest kombinierte synthetische Dokumentpfade mit dem echten Repository.
  Ein dort nicht vorhandener Zwischenordner scheiterte unter Linux. Der Test erstellt
  jetzt seine Zielseiten im eigenen temporaeren Dokumentationsbaum und prueft sowohl
  Repository-Grenzen als auch die Existenz aller normalisierten Linkziele.

## Abnahme und Grenzen

Abnahme: Recovery-Vollstaendigkeit, SSH-Dokumentationstests und saemtliche vorgesehenen
GitHub-Checks fuer den neuen PR-Head muessen erfolgreich sein. CI-Ergebnisse sind am
jeweiligen Commit zu pruefen, nicht von aelteren Laeufen zu uebernehmen.

Keine Installer-, Dienst-, Modell-, GPU- oder Restore-Ausfuehrung. Die Reparatur
veraendert keine Runtime und keine Sicherheitsausnahmen. Breaking Changes: keine.
Rollback: diesen reinen Dokumentations-/Testpatch gezielt revertieren; keine
Benutzerdaten oder laufenden Dienste sind davon betroffen.
