# Known Issues

## Windows/WSL2 Dateisystem langsam

Symptom: einfache Repo-Operationen wie `git status`, `Get-ChildItem` oder Bash-Syntaxchecks koennen minutenlang haengen.

Workaround:

- WSL/Docker nach Windows-Neustart einige Minuten starten lassen.
- grosse Vollscans vermeiden.
- schnelle Dry-Runs nutzen.
- Vollchecks erst nach stabilem Systemstart.

## Python unter Windows nicht gefunden

Symptom: `Python wurde nicht gefunden... Microsoft Store`.

Workaround:

- Python App Execution Alias deaktivieren oder Python installieren.
- Fuer Repo-Checks bevorzugt WSL/Git-Bash/Python im Projektpfad nutzen.

Aktueller Teststand: Die angeforderten Check-Skripte liefen unter Git-Bash mit `|| true` durch, meldeten aber mehrfach diesen Windows-Python-Alias-Hinweis. Das ist ein Umgebungsproblem, kein Hinweis auf committed Secrets oder einen gestarteten Installer.

## Tool-Lifecycle-Audit kann unter Git-Bash langsam sein

Das Repo hat viele Tool-Skripte. Der schnelle Dry-Run verwendet Timeouts und meldet Hinweise statt hart zu blockieren.

## Aktueller Validierungsblocker bei Windows-Dateisystem

Stand 2026-05-28: Nach dem Anlegen der neuen Setup-/Config-/Profil-Dokumente haengen einzelne Dateizugriffe unter Windows zeitweise wieder, z. B. `bash -n scripts/setup.sh` und `Test-Path scripts/setup.sh`. Das deutet auf den bekannten Windows/WSL-Dateisystem-Engpass hin. Sobald das Dateisystem wieder reagiert, nachholen:

```bash
bash -n scripts/setup.sh scripts/install_ollama.sh scripts/install_openclaw.sh scripts/install_n8n_git.sh scripts/install_cloudflare_tunnel.sh scripts/install_tailscale.sh scripts/install_monitoring.sh scripts/backup.sh scripts/update_all.sh scripts/check_models.sh
bash scripts/next_level_dry_run_check.sh
git diff --check
```

Nachtest: `bash -n` fuer die neuen Wrapper und `git diff --check` liefen erfolgreich. `bash scripts/next_level_dry_run_check.sh` lief in dieser Windows/Git-Bash-Sitzung erneut in ein Timeout, vermutlich durch Registry-/Lifecycle-Scans im grossen Repo.

## 0.0.0.0 Treffer

Aktive Safe-Default-Templates wurden auf `127.0.0.1` gehaertet. Verbleibende Treffer koennen Warn-Doku, historische Reports, Original-Templates oder Kubernetes-Beispiele sein und muessen einzeln bewertet werden.
