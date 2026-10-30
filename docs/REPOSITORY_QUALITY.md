# Projekt pruefen, ohne etwas zu installieren

## Zweck und Grenzen

Der Offline-Projektcheck findet strukturelle Fehler und dokumentiert Altlasten. Er liest
Registry-Dateien und Repository-Quelltexte, importiert diese aber nicht. Er startet keine Installer,
Modelle, Container, Dienste, WSL oder Netzwerkabfragen. Es werden keine `.env`-Dateien oder echten
Zugangsdaten inventarisiert. Ein gruener Lauf ist **kein** Installations-, Sicherheits- oder
Funktionstest aller Tools.

## Schneller Check

Aus dem Repository mit einem vorhandenen Python >=3.10:

```bash
python3 -B scripts/quality/repository_audit.py
python3 -B scripts/quality/repository_audit.py --section registry
python3 -B scripts/quality/repository_audit.py --section links
python3 -B scripts/quality/repository_audit.py --json
```

Unter Windows funktioniert derselbe Python-Code mit `py -3 -B` statt `python3 -B`. Keine WSL
notwendig. Ohne `--json` gibt es eine kompakte Zusammenfassung; JSON auf stdout enthaelt
Dateipositionen, aber keine Quelltext-/Secret-Werte. Es wird keine Berichtsdatei automatisch
angelegt.

| Bereich    | Geprueft                                                                                                 | Nicht geprueft                                                            |
| ---------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| Registries | IDs, Statuswerte, boolesches Auto-Install, vorhandene verlinkte Dateien, Tool-Referenzen, Commit-Formate | Ob externe Quellen noch erreichbar oder Pins sicher sind                  |
| Quellpfade | Keine absoluten/ausbrechenden Registry-Dateipfade; Dateien statt Verzeichnissen                          | Vollstaendiges Sicherheitsreview eines Installers                         |
| Ports      | Ganzzahl 1..65535, keine doppelten Registry-Ports                                                        | Tatsaechliche Portbelegung oder Firewall                                  |
| Python     | AST-/Syntaxpruefung ohne Import/Ausfuehrung                                                              | Laufzeit und Abhaengigkeiten                                              |
| Markdown   | Lokale Inline-Dateilinks, Gross-/Kleinschreibung, persoenliche Windows-Pfade, offene Code-Fences         | Externe Links, alle Markdown-Erweiterungen, HTML-Links oder Heading-Anker |

Fehler liefern Exit-Code 1. Fehlende Legacy-Metadaten und lokale Linkhinweise bleiben sichtbar, sind
aber standardmaessig nicht fatal. Mit `--strict` werden auch Hinweise zum Fehler. Die Kategorien
sind **Einzelfelder**, nicht so viele verschiedene kaputte Programme. Fehlender Status wird nicht
als `stable` ersetzt.

## Bestehende Checks

```bash
bash scripts/validate_config.sh
bash scripts/check_profiles.sh
bash scripts/check_tools.sh
bash scripts/check_ports.sh
bash scripts/check_profile_registry_sync.sh
```

`validate_config.sh` bindet jetzt die semantische Registry-Pruefung ein. Geplante
`documentation-first`-Profile mit `auto_install=false` duerfen bewusst ohne Installer existieren;
eine Dokumentationsdatei wird trotzdem erwartet. Quell-/Alias-Hinweise der alten Checks bleiben
sichtbar.

`doctor.sh`, Preflight und echte Installer sind dagegen **Umgebungschecks**: Sie koennen lokale
Programme/Daemons abfragen oder weitere Aktionen ausfuehren. Sie sind nicht Teil dieses rein
statischen Audits.

## Regressionstests und CI

```bash
python3 -B -m unittest discover -s tests -p 'test_repository_audit.py'
python3 -B -m unittest discover -s tests -p 'test_queue_safety.py'
python3 -B -m unittest discover -s tests -p 'test_memory_offloading.py'
```

Diese Tests verwenden temporaere Fixtures und gemockte Werkzeugaufrufe. Die echte
`flock`-Parallelitaet wird nur auf einem POSIX-System mit vorhandenem `flock` getestet und unter
Windows ausdruecklich uebersprungen. Shell-Syntax ist separat mit `bash -n` **je Datei** zu pruefen;
mehrere Dateinamen hinter einem einzelnen `bash -n` pruefen nicht alle als separate Skripte.

Der Workflow [Offline Regression](../.github/workflows/offline-regression.yml) ergaenzt den
statischen Check und alle Python-Regressionstests auf einem GitHub-Ubuntu-Runner. Er installiert
keine Tools aus dem Setup und startet keine Produktivdienste. Testcode wird dabei ausgefuehrt: nur
gepruefte Repository-Staende testen; die Bezeichnung "offline" ist keine Betriebssystem-Sandbox. Ein
lokal geaenderter Workflow ist noch kein nachgewiesener gruener GitHub-Lauf.

Aktuelle Befunde und Prioritaeten: [Gesamtaudit](PROJECT_AUDIT_2026_10_20.md).
