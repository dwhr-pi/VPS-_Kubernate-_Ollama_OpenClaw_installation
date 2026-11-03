# F01-F07: Sicherheits-Patchsatz und Abnahmegrenzen

Stand: 03.11.2026. F0 wird hier als F01-F07 des letzten Audits verstanden.
Verbindlich: [Git-Quellen, keine Docker-Installation](INSTALLATION_POLICY.md).
Keine Installation, kein Dienst-/Clusterstart, kein WSL-Zugriff und kein Zugriff auf private
User-Daten wurde zur Entwicklung dieser Patches ausgefuehrt.

## F01 und F02: Datenverlust vermeiden

`scripts/tools/k3s_uninstall.sh` und `clawbake_uninstall.sh` verwenden jetzt
`scripts/security/legacy_core_uninstall.py`. Kein Vendor-Uninstaller, kein `sudo rm -rf`,
keine ignorierten Fehler und kein falscher Entfernt-Marker. Standard/`--dry-run`: nur
Metadaten-Vorschau, Exitcode 3. `--apply` bleibt ohne belegten Besitz-/Migrationsvertrag gesperrt.
Git-Installationen werden dadurch nicht pauschal gesperrt.

Clawbakes Clone-Helfer loescht vorhandene Ziele nicht mehr. Bestehende Update-/Backup-Zweige
sind damit nicht automatisch als manipulationssicher abgenommen; eine vollstaendig gepinnte
Clawbake-Migration bleibt ein eigener Folgepatch.

Breaking Change: Automatische Legacy-Entfernung ist nicht mehr moeglich.
Rollback: Daten/Status wurden nicht veraendert. Unsichere Loeschbefehle nicht wieder einfuehren;
fuer echte Entfernung zuerst Datensicherung, Besitznachweis und einen separaten Migrationsplan erstellen.

## F03: Git-Build statt ungeprueftem Binaerdownload

ArgoCD CLI und cloudflared verwenden feste Git-Commits im nativen Build-Manifest statt
`releases/latest`, privilegiertem `curl` oder vorhersehbaren `/tmp`-DEB-Dateien.
[Buildvertrag, Quellen und Aufrufe](tools/argocd-cloudflared-native.md).
Gemeinsame Docker-Helfer und VPS-Bootstrap installieren Docker nicht mehr; Paket-Helfer
lehnen Docker als vermeintliche Basisabhaengigkeit ab. Vorhandene Runtime-Daten bleiben erhalten.

Abnahme: Pins/Rezept/Wrapper offline pruefen, danach freigegebener nativer Build auf Ubuntu
amd64/ARM und lokale CLI-Probe. Letzteres ist hier nicht ausgefuehrt. Die Entwicklungs-Commits
sind keine Release- oder Schwachstellenfreigabe. Weitere alte Fremdskript-/Buildpfade brauchen
weiterhin eine Einzelpruefung; dieser Patch behauptet keine Integritaetsabnahme aller Tools.

Breaking Change: Neue Binaries liegen privat statt in `/usr/local/bin`; alte System-Binaries
bleiben unberuehrt. PATH und Service-Units bewusst auf das neue Artefakt umstellen.

## F04: Historische Secret-Treffer

Der vorherige redigierte History-Scan meldete 33 Treffer, nicht 33 nachgewiesen gueltige Keys.
Darunter sind moegliche Platzhalter/Hashes und historische Credential-Muster. Keine Gueltigkeits-
oder Providerpruefung, kein Key-Abdruck, keine Rotation und kein Umschreiben der Git-Historie.

```bash
# Ohne --run nur Plan; mit --run nur dieses Repo, keine privaten ENV-Dateien.
python3 -I -B scripts/security/history_secret_triage.py
python3 -I -B scripts/security/history_secret_triage.py --run
```

Ausgabe nur Regel, Datei, Zeile, Commit und ungepruefter Triage-Status. Match/Secret/Scannerlogs
werden nicht ausgegeben. Exitcode 1 bedeutet offene Treffer, 2 einen unvollstaendigen Scan.
Der Scan ersetzt keine bestehenden Gitleaks-/Trivy-Gates und erzeugt keine Allowlist.

**Offen fuer den Maintainer:** Jeden Treffer lokal klassifizieren; potentiell echte Keys beim
jeweiligen Anbieter widerrufen/rotieren, Logs/Artefakte pruefen. Erst danach gegebenenfalls eine
separat abgestimmte History-Bereinigung. Keine Zugangsdaten im Issue oder Chat posten.

## F05: Private, atomische ENV-Ausgabe

Der LLMOps-Konfigurationsmanager schreibt `.env` unter
`$USER_WORKSPACE_DIR/llmops-platform/` (Standard `~/.openclaw_ultimate_user_data`), nicht ins Repo.
`private_env.py` verlangt eigene 0700-Verzeichnisse, 0600-Dateien, lehnt Symlinks/Hardlinks ab
und publiziert ueber eine exklusive temporaere Datei plus atomaren Verzeichniseintrag und `fsync`.
Vorhandene ENV nur nach ausdruecklicher Ersetzungsbestaetigung. Kein `source`/`eval` von ENV-Inhalten.
Kein Abschwaechen der Rechte fuer Windows-Dateisysteme: nativer Unix-Pfad erforderlich.

Breaking Change: Alte Repo-ENV wird nicht automatisch migriert, geloescht oder weiter aktualisiert.
Manuell auf Secret-Spuren pruefen und erst nach gesicherter Migration entfernen.
Historisches Compose teilt noch ENV-Konfigurationen; es ist kein freigegebener Neuinstallationsweg.
Fuer native Services pro Dienst eigene Credential-Dateien/LoadCredential und fuer Open WebUI
einen eingeschraenkten LiteLLM-Key statt des Master-Keys verwenden. Vollstaendige automatische
Aufteilung bestehender Benutzer-Secrets ist **nicht** Teil dieses Patches.

## F06: Native Monitoring-Konfiguration

`native_monitoring_config.py` erzeugt private Prometheus-/Alertmanager-Dateien (JSON ist YAML-kompatibel).
Explizite VPN-/Loopback-Ziele, gesondertes Metrics-Token, eigene HTTPS-Webhook-Datei,
Alertmanager auf Loopback. Keine Beispiel-Supportadresse, keine Benachrichtigung oder Reload.
Das alte LiteLLM-Platzhalterziel ist durch absichtlich leere File-Service-Discovery ersetzt;
leere Discovery ist kein erfolgreicher Scrape und kein Betriebsnachweis.

```bash
python3 -I -B scripts/security/native_monitoring_config.py
# Private 0700-Ausgabe und eigene 0600-Dateien vorbereiten; Adresse an den VPN-Listener anpassen.
python3 -I -B scripts/security/native_monitoring_config.py --apply \
  --output "$HOME/.openclaw_ultimate_user_data/monitoring-native" \
  --litellm 10.10.0.2:4000 \
  --token-file "$HOME/.openclaw_ultimate_user_data/metrics-token" \
  --receiver-file "$HOME/.openclaw_ultimate_user_data/alert-webhook-url"
promtool check config "$HOME/.openclaw_ultimate_user_data/monitoring-native/prometheus.json"
amtool check-config "$HOME/.openclaw_ultimate_user_data/monitoring-native/alertmanager.json"
```

Prometheus/Alertmanager/Exporter aus Git bauen; keine Docker-Nachinstallation.
Service-Units auf Loopback binden, Rules und Credentials nur lesbar bereitstellen.
Vor Aktivierung: Parserpruefung, Scrape mit passendem Token, Negativtest ohne Token,
kontrollierter Testalarm und Nachweis beim eigenen Empfaenger. Diese Runtime-Tests bleiben offen.
[Offizieller Webhook-Vertrag](https://prometheus.io/docs/alerting/latest/configuration/#webhook_config).

## F07: Native Backups und isolierter Restore

`native_export_backup.py` sichert nur vorbereitete konsistente Exporte fuer PostgreSQL,
Qdrant und MinIO mit Git-installiertem Restic. Keine laufenden Volume-Verzeichnisse,
kein Docker, keine automatischen Wartungs-/Stop-/Prune-Aktionen, kein Klartext-Exporttransport.
Restic verschluesselt das Repository; lokale Eingaben und Restore-Ausgaben bleiben sensible Daten.
Jeder Fehler, einschliesslich Restic-Exitcode 3 (Teilbackup), beendet den Vorgang ohne Erfolgsmeldung.
Die bisherige lokale Workspace-Kopie markiert unvollstaendige Sicherungen jetzt ausdruecklich;
erst nach allen erfolgreichen Schritten wird der Marker umbenannt. Diese lokale Kopie ist
nicht als Ganzes verschluesselt und kein erlaubter Klartext-Mail-/Windows-Export.

Private `backup.env` (0600, eigene Werte, niemals ins Repo): `RESTIC_REPOSITORY=s3:https://.../bucket`,
`RESTIC_PASSWORD_FILE=/absoluter/privater/pfad`, erforderliche `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, optional Region/Session-Token. Nur literale `KEY=VALUE`, keine Shell-Auswertung.
Separates externes S3-Ziel, eigener Backup-Account und ausreichende Reserve sind Betreiberpflicht.

Exportverzeichnis 0700 mit je eigenem `postgres/`, `qdrant/`, `minio/` und 0600-Dateien.
Erforderliche `backup-manifest.json`, ebenfalls 0600:

```json
{
  "schema": 1,
  "files": {
    "postgres/database.dump": {"size": 0, "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},
    "qdrant/collection.snapshot": {"size": 0, "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},
    "minio/objects.export": {"size": 0, "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"}
  }
}
```

Das Beispiel beschreibt bewusst leere synthetische Dateien, **keine brauchbare Datenbanksicherung**.
Echte Groessen/Hashes aus den konsistenten Exporten generieren. PostgreSQL mittels passender
`pg_dump`-Version, Qdrant ueber Snapshot-API und MinIO mit konsistentem Objekt-/Versionsinventar
exportieren. Der Aufrufer bestaetigt Konsistenz; Hashes beweisen sie nicht.

```bash
python3 -I -B scripts/security/native_export_backup.py backup
python3 -I -B scripts/security/native_export_backup.py backup --apply \
  --env-file "$HOME/.openclaw_ultimate_user_data/backup.env" \
  --exports "$HOME/consistent-exports" --confirm-consistent-exports --confirm-external-target
# Zuerst volle Snapshot-ID aus der eigenen Restic-Verwaltung ermitteln.
# restore benoetigt --snapshot mit exakt 64 Hexzeichen und einen privaten --recovery-parent.
python3 -I -B scripts/security/native_export_backup.py restore
# Erst nach eigener Freigabe; Recovery-Parent muss bereits existieren und 0700 haben:
read -r -p 'Volle Snapshot-ID (64 Hexzeichen): ' SNAPSHOT
python3 -I -B scripts/security/native_export_backup.py restore --apply \
  --env-file "$HOME/.openclaw_ultimate_user_data/backup.env" \
  --recovery-parent "$HOME/recovery-drills" --snapshot "$SNAPSHOT" \
  --confirm-consistent-exports --confirm-external-target
```

Restore nur in ein frisch erzeugtes privates Unterverzeichnis, niemals in Produktionspfade.
`restic restore --verify` und anschliessende Manifest-/Hashpruefung erzeugen nur einen
Datei-Integritaetsnachweis; Teilverzeichnisse bleiben zur Untersuchung erhalten.
[Offizielle Restic-Restore-Dokumentation](https://restic.readthedocs.io/en/stable/050_restore.html).

**Weiter offen:** echter externer Restic-Restore, Datenbankimport/Integritaetsabfragen,
MinIO-Objekt-/Versionstest, Qdrant-Abfragen sowie separater PVC-/Velero-Restore auf Testcluster.
Kein Metadaten- oder Fixture-Erfolg gilt als bestandenes Disaster-Recovery-Szenario.

## Offline-Abnahme

```bash
python3 -B -m unittest discover -s tests -p test_f01_f07_hardening.py -v
python3 -B -m unittest discover -s tests -p test_legacy_core_uninstall.py -v
python3 -B scripts/quality/repository_audit.py --section registry
```

Native POSIX-dirfd-Tests laufen auf Linux/macOS, werden auf Windows ausdruecklich uebersprungen;
kein WSL-Ersatz. Neue Tests werden von der bestehenden Offline-Regression automatisch entdeckt.
Dies ist ein lokaler Patchsatz, kein Nachweis eines Pushs oder gruener GitHub-CI.

Lokale Abnahme am 03.11.2026 (Windows, ohne WSL):

- F01-F07-Fixtures: 14 Tests, davon vier POSIX-Tests ausdruecklich uebersprungen.
- Legacy-Uninstall: 21 Tests, davon ein Symlink-Test uebersprungen;
  die anschliessend auf K3s/Clawbake erweiterten Wrapper-Tests separat erneut bestanden.
- Native Go-Vertraege: 39 Tests bestanden; native GitHub-Installer: 29 Tests bestanden.
- Dokumentnavigation: vier Tests bestanden; Produktionsbaseline: 13 Tests,
  davon sechs Linux-/POSIX-Backup-Fixtures uebersprungen.
- Registry: 400 Tools, 250 Profile, 45 Ports; null Fehler, 793 bestehende Hinweise.
- ShellCheck der geaenderten kleinen Installer/Helfer und Bash-Syntaxpruefung bestanden.

Nicht ausgefuehrt: gesamte Testsuite, neue reale Source-Builds, `promtool`/`amtool`,
Provider-/Credential-Tests, echte Restic-/Datenbank-/PVC-Restores und GitHub-CI.
Die neuen POSIX-Sicherheitsfixtures muessen vor Freigabe auf dem vorgesehenen Linux-Runner bestehen.
