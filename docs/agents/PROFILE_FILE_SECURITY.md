# Private Agentenprofil-Dateien

Stand 03.11.2026, SEC-009. `scripts/profiles/coding_agents.py` verwaltet Vorlagen und
Quellregistrierungen, startet aber keine Agenten, Dienste, Modelle oder Provider-Aufrufe.

Der Wiederholungspfad prueft vorhandene Datei-/Verzeichnistypen, Linkzahl und unter POSIX
Eigentuemer sowie 0700-Verzeichnisse/0600-Dateien. Auch identischer Inhalt macht unsichere
Metadaten nicht akzeptabel. Lesen erfolgt ueber gepruefte regulaere Dateien, begrenzt auf 1 MiB;
neue Dateien entstehen exklusiv mit Modus 0600 statt erst nachtraeglichem chmod.
Git-Quellvorbereitung bleibt moeglich; Git-Aufrufe haben nun ein 120-Sekunden-Zeitlimit.
Keine Shell-/Container-Sandbox oder komplette Lieferkettenfreigabe wird dadurch behauptet.

## Verhalten und Migration

Bestehende fremde, verlinkte, hardverlinkte oder zu offene Dateien/Verzeichnisse werden abgelehnt,
nicht automatisch geloescht, umgeschrieben oder auf andere Besitzer umgestellt.
Das kann bisher akzeptierte Linux-Workspaces mit 0755/0777 oder Dateien mit 0644/0666 betreffen.
Den privaten Workspace samt verwalteter Zwischenverzeichnisse erst nach eigener Besitz-/Backup-
Pruefung korrigieren. Keine pauschalen rekursiven chmod/chown-Kommandos auf dem Home-Verzeichnis.

Windows-ACLs sind nicht gleich POSIX-Modusbits. Windows-Fixtures pruefen Dateityp, Hardlinks,
Inhalts-/Idempotenzregeln und Abbruchverhalten; eine echte ACL-Abnahme bleibt offen.
Es gibt keinen WSL-Fallback und keinen daraus abgeleiteten Produktionsstatus.

## Abnahme und Rollback

```bash
python3 -B -m unittest discover -s tests -p test_coding_profile_metadata.py -v
python3 -B -m unittest discover -s tests -p test_coding_agent_profiles.py -v
```

Negative Fixtures: falscher Owner/Modus/Dateityp, identischer Hardlink, geaenderte Vorlage,
belegte Operationssperre und Git-Timeout. Vorlagen/Quellen/Nutzdaten muessen erhalten bleiben.
POSIX-Metadatenlogik wird auch synthetisch geprueft; echter Unix-Rechtevollzug bleibt ein
gesonderter Linux-Test. Kein Modell-/CLI- oder Drittanbieter-Login wird dafuer ausgefuehrt.

Rollback betrifft nur diesen Code-Patch. Er migriert keine Nutzdaten und veraendert keine
vorhandenen Rechte. Besser bei einem Konflikt pausieren und den Besitzvertrag pruefen,
statt die Rechtepruefung pauschal zu deaktivieren.
