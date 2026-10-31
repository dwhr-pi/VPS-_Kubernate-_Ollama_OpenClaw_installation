# Test Matrix

| Test                    | Befehl                                                                    | Erwartung                                         |
| ----------------------- | ------------------------------------------------------------------------- | ------------------------------------------------- |
| Statischer Gesamtaudit  | `python3 -B scripts/quality/repository_audit.py`                          | keine Fehler; Metadatenhinweise separat           |
| Audit-Fixtures          | `python3 -B -m unittest discover -s tests -p 'test_repository_audit.py'`  | keine Netzwerk-/Installeraktionen                 |
| Queue-Fixtures          | `python3 -B -m unittest discover -s tests -p 'test_queue_safety.py'`      | temporaere Daten; echter flock-Test nur auf POSIX |
| Quellinstaller-Fixtures | `python3 -B -m unittest discover -s tests -p 'test_memory_offloading.py'` | Pins/Marker/Argumente ohne reale Downloads        |
| Profile                 | `bash scripts/check_profiles.sh`                                          | keine Fehler                                      |
| Tools                   | `bash scripts/check_tools.sh`                                             | keine Fehler                                      |
| Ports                   | `bash scripts/check_ports.sh`                                             | keine Doppelbelegung                              |
| Config                  | `bash scripts/validate_config.sh`                                         | JSON/YAML gueltig                                 |
| Doctor                  | `bash scripts/doctor.sh`                                                  | klare Warnungen                                   |
| Queue                   | `bash scripts/queue/queue_status.sh`                                      | Status oder leere Queue                           |
| Secrets                 | `bash scripts/security/scan_secrets.sh`                                   | keine Werte ausgeben                              |
| Supply Chain            | `bash scripts/security/scan_supply_chain.sh`                              | klare Hinweise                                    |
