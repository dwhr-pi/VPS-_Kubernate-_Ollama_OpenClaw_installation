# Test Matrix

| Test | Befehl | Erwartung |
| --- | --- | --- |
| Profile | `bash scripts/check_profiles.sh` | keine Fehler |
| Tools | `bash scripts/check_tools.sh` | keine Fehler |
| Ports | `bash scripts/check_ports.sh` | keine Doppelbelegung |
| Config | `bash scripts/validate_config.sh` | JSON/YAML gueltig |
| Doctor | `bash scripts/doctor.sh` | klare Warnungen |
| Queue | `bash scripts/queue/queue_status.sh` | Status oder leere Queue |
| Secrets | `bash scripts/security/scan_secrets.sh` | keine Werte ausgeben |
| Supply Chain | `bash scripts/security/scan_supply_chain.sh` | klare Hinweise |
