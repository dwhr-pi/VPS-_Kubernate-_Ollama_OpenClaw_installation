# Priorisierte Sicherheitsbefunde

Stand 29.10.2026. Zehn priorisierte Befunde, **nicht zehn nachgewiesene kritische
Produktionsvorfaelle**. Quelle ist der lokale Code, keine aktive Ausnutzung. Codekorrektur bedeutet
hier `implemented`/gezielt offline `tested`; nie automatisch `staging_verified` oder
`production_verified`.

## SEC-001: Unbeschraenkte Workspace-Komplettloeschung

- Schwere/Prioritaet: hoch / P0; in diesem Arbeitsstand gesperrt.
- Datei/Beleg: `setup_ultimate.sh`, `show_user_workspace_menu`, Zweig 7; vorher
  `rm -rf "$USER_WORKSPACE_DIR"` mit konfigurierbarem Workspace.
- Reproduktion: isolierte Menuefunktion mit gemocktem `dialog`/`rm` und einem abweichenden Testpfad;
  niemals mit echtem Home oder Nutzerdaten ausfuehren.
- Verbesserung: Zweig loescht nichts und verweist auf Backup/Restore sowie datenerhaltende
  Tool-Uninstaller. Kein neuer rekursiver Loeschhelfer.
- Aufwand/Abhaengigkeit: unter 1h; keine neue Laufzeitabhaengigkeit.
- Abnahme: Regression `test_workspace_menu_never_recursively_purges_workspace`; spaetere
  Purge-Funktion braucht Ownership-, Mount-, Lock- und Restorevertrag.

## SEC-002: Pfadtraversal bei Lifecycle-Auswahl

- Schwere/Prioritaet: mittel / P0; Code korrigiert.
- Dateien: `scripts/uninstall_tool.sh`, `scripts/operations/update_all_tools.sh`; vorher freie
  Interpolation von CLI-/Statuswerten in einen Skriptpfad.
- Reproduktion: `tool_dispatch.resolve` mit `../../payload`, unbekannter ID, verlinktem Skript und
  manipuliertem Registry-Pfad in Temp-Fixtures aufrufen.
- Verbesserung: `scripts/lib/tool_dispatch.py` verlangt eindeutige Registry-ID oder Namen, festes
  Skriptmuster und nicht verlinkten Pfad unter `scripts/tools`. Updates ohne registrierten Updater
  werden nicht mehr durch Reinstall ersetzt.
- Aufwand/Abhaengigkeit: 1-2h; Python 3 und Registry.
- Abnahme: gueltige IDs/Names funktionieren, Traversal/Links/fehlende Updater scheitern vor
  Ausfuehrung. Gleichzeitige Repo-Manipulation bleibt ausserhalb dieser gleichberechtigten
  Benutzer-Vertrauensgrenze.

## SEC-003: Backup moeglicherweise exportierbar, aber nicht wieder lesbar

- Schwere/Prioritaet: mittel / P0; Code korrigiert.
- Datei: `scripts/security/credentials_backup.py`, `pack`, `read_bounded`, `recover`. Vorher galt
  32MiB sowohl fuer Klartext als auch fuer groessere Ciphertexte.
- Reproduktion: synthetische Datei mit exakt `LIMIT` Bytes packen; TAR-Metadaten vergroessern die
  Nutzlast bereits ohne age. Keine echten Zugangsdaten verwenden.
- Verbesserung: getrennte begrenzte Klartext-, TAR- und Ciphertextbudgets; Export und Restore
  pruefen dieselben Transportgrenzen.
- Aufwand/Abhaengigkeit: unter 1h; age nur fuer echten Verschluesselungs-Roundtrip.
- Abnahme: Grenzwert-Fixture passiert den gemockten Recovery-Pfad; reales age-/TAR-Restore auf
  Ubuntu bleibt separat erforderlich. Mail bleibt auf 15MiB begrenzt.

## SEC-004: Scannerfehler konnte als sauberer Secret-Scan erscheinen

- Schwere/Prioritaet: mittel / P1; Code korrigiert.
- Datei: `scripts/secret_scan.sh`; Pipeline `grep | head` unter `pipefail` konnte bei SIGPIPE in den
  Erfolgszweig fallen. Trefferwerte konnten Logs erreichen.
- Reproduktion: gemockte grep-Exitcodes 0, 1, 2 und 141 im Bash-Fixture testen.
- Verbesserung: kein Trunkierungspipe; 0 bedeutet Fund, 1 kein Patternfund, sonst Fehler. Keine
  Trefferinhalte; Gitleaks redigiert, TruffleHog ohne Credential-Verifikation und ohne Roh-Ausgabe.
- Aufwand/Abhaengigkeit: unter 1h; GNU-/kompatibles grep bzw. gepruefter Scanner.
- Abnahme: Fund => Fehler, Scanfehler => Fehler, kein Secret-Sentinel im Output. Pattern-Fallback
  ist kein vollwertiger Scanner und prueft keine Git-Historie.

## SEC-005: Feste Temp-Dateien und ausfuehrbare Konfigurationsdaten

- Schwere/Prioritaet: mittel / P1; Hauptmenue weiterhin offen.
- Datei: `setup_ultimate.sh`, `/tmp/metrics_config_edit` und weitere feste Menuepfade; bearbeitete
  Konfiguration wird spaeter `source` ausgefuehrt.
- Reproduktion: zwei gemockte Menueinstanzen in derselben Test-Temp-Umgebung verschraenken;
  Konfigurationsdaten durch einen harmlosen Marker ersetzen.
- Verbesserung: private `mktemp -d`-Verzeichnisse und Datenparser statt `source`. Der separate
  LLMOps-Konfigurationsmanager verwendet jetzt ein privates Tempdir.
- Aufwand/Abhaengigkeit: 1-2 Tage; Dialog-/Abbruch-/Sprachregressionen.
- Abnahme: parallele Dialoge beeinflussen sich nicht; Daten koennen keine Shellbefehle starten.
  Cross-User-Ausnutzbarkeit haengt von Hostschutz/Rechten ab.

## SEC-006: Stack-Konfiguration mit unzureichendem Laufzeit-/Dateivertrag

- Schwere/Prioritaet: mittel / P1; Vorlagen korrigiert, Livewirkung ungeprueft.
- Dateien: `stacks/llmops-platform/litellm-config.yaml`,
  `scripts/llmops_platform_config_manager.sh`.
- Beleg/Reproduktion: bindgemountete Dateien werden von Compose nicht intern `${...}`-interpoliert;
  vorher konnte `cp` unter umask 022 eine .env mit 0644 erzeugen.
- Verbesserung: `os.environ/NAME`, kein automatischer Cloud-Fallback, `umask 077`/`install -m 600`
  und einfache Symlink-Ablehnung.
- Aufwand/Abhaengigkeit: 1-2h plus Staging; LiteLLM-/Compose-Versionsabnahme.
- Abnahme: Master-Key greift, ohne Key keine Inferenz, Offline-Fallback bleibt lokal; 0600 auf
  Kopie. Externe Workspace-Verlagerung und alle Elternpfade weiter pruefen.

## SEC-007: Monitoring-Storage konnte beim Helm-Uninstall verloren gehen

- Schwere/Prioritaet: mittel / P1; Retentionskennzeichnung ergaenzt.
- Dateien: `charts/monitoring-lite/templates/namespace.yaml`, `workloads.yaml`.
  Argo-Prune-Annotation allein schuetzt weder Helm-PVC noch Namespace.
- Reproduktion: Chart rendern und Ownership/Retention bei uninstall in einem Wegwerfcluster pruefen;
  keine echte Installation entfernen.
- Verbesserung: `helm.sh/resource-policy: keep` auf Namespace und PVCs; langfristig extern
  verwalteter Namespace empfohlen.
- Aufwand/Abhaengigkeit: unter 1h Code, halber Tag Test; Helm und Wegwerfcluster.
- Abnahme: Daten nach Helm-Uninstall nachweislich erhalten und wieder eingebunden. Manuelles
  Namespace-Loeschen/Provisioner-Reclaim bleiben eigenstaendige Risiken.

## SEC-008: Backup-Lock ist nur ein Zeitpunktcheck

- Schwere/Prioritaet: mittel / P1; offen.
- Datei: `scripts/operations/backup_user_workspace.sh`, `.runner-lock`-Pruefung vor Restic; zwischen
  Pruefung und Backup kann ein Installer starten.
- Reproduktion: gemocktes Restic legt nach `cat config` einen Installationslock an; danach
  Backup/Retention-Aufrufe protokollieren, kein echtes Repository nutzen.
- Verbesserung: exklusives Maintenance-Lock ueber gesamten Snapshot, abgestimmt mit gemeinsamem Lock
  der Installer; keine pauschale Entsperrung.
- Aufwand/Abhaengigkeit: 1 Tag; gemeinsames Lock-Protokoll und Konkurrenztests.
- Abnahme: weder Startreihenfolge noch Prozessabbruch erlauben parallele Mutation; fehlgeschlagener
  Snapshot fuehrt nicht zu Prune. Echter Restore bleibt erforderlich.

## SEC-009: Vorhandene Agenten-Dateirechte werden nicht immer nachvalidiert

- Schwere/Prioritaet: mittel / P1; offen, kein Beleg einer Agentenausfuehrung.
- Datei: `scripts/profiles/coding_agents.py`, `private_dir`/idempotenter Schreibpfad.
- Reproduktion: identische Fixtures unter 0777/0666 oder mit Hardlinks voranlegen; Installation darf
  unsichere Ownership/Permissions nicht stillschweigend akzeptieren.
- Verbesserung: Owner, Modus und Linkzahl bei jeder Wiederholung pruefen; unsichere vorhandene
  Dateien nicht ohne Freigabe umschreiben.
- Aufwand/Abhaengigkeit: halber bis ein Tag; POSIX-Fixtures und Windows-Abgrenzung.
- Abnahme: unsichere vorhandene Rechte werden erkannt; deklarierte Agenten-Policy wird nicht als
  Betriebssystem-Sandbox ausgewiesen.

## SEC-010: Supply-Chain-/Historien-Abnahme noch nicht durchgaengig

- Schwere/Prioritaet: mittel / P1; offen.
- Dateien: `.github/workflows/secret-scan.yml`, `ci.yml`, `linkcheck.yml`,
  `.pre-commit-config.yaml`; zum Teil mutable Action-Refs und optionale Hooks.
- Reproduktion: `uses:`-Referenzen auf nicht volle Commit-Hashes pruefen; Checkout-Tiefe und
  Scanmodus (`--no-git`) von Historienpruefung unterscheiden.
- Verbesserung: gepruefte Action-Commits, Least-Privilege-Permissions, persistierte
  Checkout-Credentials abstellen, getrennte redigierte Full-History-Pruefung.
- Aufwand/Abhaengigkeit: 1 Tag; verifizierte Upstream-Hashes, Git-Historie, Scanner.
- Abnahme: kein mutable Drittcode in freigegebener CI; kontrollierte Test-Secret- Historie wird
  erkannt. Hier wurde kein vollstaendiger Historien-/CVE-Scan ausgefuehrt.
