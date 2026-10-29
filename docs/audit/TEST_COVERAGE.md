# Testumfang und Evidenz

Stand 29.10.2026. [test_results.json](test_results.json) haelt Ergebnisse mit
Datum und Quellstand fest; noch nicht gelaufene Tests gelten nicht
als bestanden. Der Bericht nennt bewusst Teilumfang, Plattform und Skips.

## Reproduzierbare Offline-Pruefungen

```bash
python3 -B scripts/quality/repository_audit.py --section all
python3 -B scripts/quality/master_audit.py --write-reports
python3 -B scripts/quality/run_master_audit_tests.py --write-report
python3 -B -m unittest discover -s tests -p test_master_audit_safety.py -v
python3 -B -m unittest discover -s tests -p test_platform_inventory.py -v
python3 -B -m unittest discover -s tests -p test_credentials_backup.py -v
```

Der vorhandene CI-Workflow `offline-regression.yml` entdeckt die neuen
`test_*.py` automatisch. `test-install-scripts.yml` prueft weitere Fixtures und
rendert Kubernetes; sein Vorhandensein beweist keinen erfolgreichen aktuellen Lauf.

Neue Schutztests: Registry-ID/Name, Traversal/Link-Ablehnung, unterbundene
Workspace-Komplettloeschung, Backup an der 32MiB-Klartextgrenze, keine automatische
Produktionshochstufung, Cache-Ausschluss, Helm-Retentionsmarker, LiteLLM-Env-Lookup,
RAG-Ranking-/ACL-Metriken und Secret-Fallback-Fehlercodes. Der Grenzwerttest
verwendet synthetische Daten und gemocktes age, keine echten Schluessel.

## Bestehende geeignete Regressionen

`test_install_rollback.py`, `test_installation_reset.py`, `test_p0_safety.py`,
`test_installation_inventory.py`, `test_signed_release.py`,
`test_repository_audit.py`, `test_tool_coverage_audit.py`,
`test_production_baseline.py`, `test_gpu_platform_blueprint.py`,
`test_vps_delivery.py`, `test_local_ai_benchmarks.py`,
`test_rag_compliance_review.py`, `test_game_engine_tools.py`.
Eine Testdatei-Zuordnung ist noch kein Code-Coverage-Prozentsatz oder Live-Smoke-Test.

## Ausdruecklich nicht nachgewiesen

- Komplettinstallation und wiederholter Source-Build aller 399 Tools.
- Alle 245 Profile als kombinierte laufende Plattform; gesamte Test-Suite auf allen OS.
- Vollstaendiger Git-Historien-Secret-Scan, aktuelle CVE-Datenbank, alle Upstream-Pins/Lizenzen.
- Image-/Helm-/Kustomize-Kompatibilitaet ohne passende lokale Werkzeuge.
- GPU-/NVIDIA-/WSL-, echte TLS-/VPN-/CNI-/RBAC-/Admission-Durchsetzung.
- Vollstaendiger age-/Restic-/Datenbank-Restore gegen echte Backupziele.
- Provider-Key-Anmeldung, API-Aufruf, Kosten-/Qualitaetsmessung, Publikation oder Zahlung.

Windows-Skips bei POSIX-Rechten/Symlinks/Bash-Fixtures sind offen auszuweisen;
es wird dafuer nicht heimlich WSL gestartet. Vor Staging zuerst Ubuntu 24.04
x86_64 in einer Wegwerf-VM mit unabhaengigen Recovery-Secrets testen.
