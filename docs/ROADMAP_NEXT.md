# Naechste Schritte nach dem Audit vom 23.10.2026

**Fortschritt nach Freigabe:** Das [P0-Codepaket](P0_SAFETY_CHANGES.md) fuer
Update-Sicherung, PAT und datenerhaltenden Compose-Uninstall ist lokal umgesetzt
und mit Fixtures geprueft. Ubuntu-24.04-VM-Abnahme und Merge bleiben offen;
die unten stehende Planung dokumentiert den vorherigen Auditstand.

Basis: [Audit mit Befunden und Pruefgrenzen](AUDIT_2026-10-23.md).
**Plan fuer die aktiven Installationspfade, keine erstellte PR-Serie.**
Zuerst die offenen Audit-Pruefungen abschliessen. Danach kleine Pakete in der
folgenden Reihenfolge; P0-P3 bezeichnen Prioritaet, nicht pauschale CVSS-Schwere.

## Nachpruefung des erneut angehaengten Auftrags

Die [Nachpruefung im Audit](AUDIT_2026-10-23.md#nachpruefung-des-erneut-angehaengten-haertungsauftrags)
ergaenzt A18-A23 und einen
[Gitleaks-Metadatenbericht ohne Secret-Werte](audit-evidence/2026-10-23/gitleaks-summary.json).
Dieser Arbeitsschritt aendert ausschliesslich Berichte, keine Installer oder Dienste.
Die getrennte [Produktions-Baseline](PRODUCTION_BASELINE.md) ist inzwischen
vorhanden, aber weder in die alten Installer migriert noch deployed. Die unten
stehenden urspruenglichen Nicht-Umsetzungen beziehen sich auf deren aktive
Betriebspfade; vorhandene optionale Dateien sind kein Abnahmenachweis.

Vorgezogene Reihenfolge fuer die ersten einzeln reviewbaren Pakete:

| Paket | Zweck / Bezug | Tests vor Merge | Rollback / Freigabe |
|---|---|---|---|
| 00 Secret-Triage | A19: 31 Historien- und 8 Arbeitsbaumtreffer nach echten Credentials, Beispielen und oeffentlichen Hashes unterscheiden. Echte exponierte Schluessel zuerst widerrufen/rotieren; keine Live-Validierung durch Coding-Agenten. | Redigierter Vollhistorien-Scan und Arbeitsbaumscan; enge dokumentierte False-Positive-Ausnahmen. Keine Secret-Werte in Fixtures oder Reports. | Widerrufene Schluessel nicht wiederverwenden. History-Rewrite nur nach gesonderter Freigabe, Backup und Abstimmung der Klone/Forks. |
| 01a Update-/Uninstall-Datenschutz | A18/A01/A03: `auto_update_hard.sh` und `install.sh` gemeinsam absichern; keine Reset-/Clean-/Volume-Loeschung ohne vollstaendiges verifiziertes Backup und ausdrueckliche Freigabe. Standard Dry-run/Erhalt der Daten. | Git-Fixtures mit staged, unstaged, untracked und lokalen Commits; Backup-Fehler/ENOSPC stoppt vor Mutation; Restore in isoliertes Ziel; Compose-Daten bleiben ohne separate Freigabe erhalten. | Nur Codepatch zuruecknehmen; Backups und Nutzerdaten nie automatisch loeschen. Unsicheren Altpfad nicht als empfohlenen Rollback ausfuehren. |
| 01b Funktionierende lokale Gates | A20/A21: gueltige read-only Pre-commit-Hooks, einheitliche Formatter-Optionen und gepinnte Werkzeuge. Keine Massenformatierung zusammen mit P0-Fixes. | Hook-Initialisierung in temporaerem HOME, Fixture mit absichtlichem Syntaxfehler, Formatdrift und synthetischem Secret muss fehlschlagen. Danach Linux-CI auf sauberem Checkout. | Einzelnes Gate gezielt zuruecknehmen, kein globales `|| true`, keine pauschalen Secret-Ausnahmen fuer Dokumentation. |
| 02 Signierte Release-/Lock-Kette | A23: Release-Artefakt, unabhaengiger Vertrauensanker, Manifest mit Hashes/Commits/Digests und Vollstaendigkeitspruefung. Bewegliches `main` ist kein Produktions-Updateziel. | Manipuliertes Artefakt, falscher Signer, fehlender Lock-Eintrag oder Digest muessen vor Ausfuehrung scheitern. | Vorheriges ebenfalls verifiziertes Release; Schluesselrotation mit dokumentierter Betreiberfreigabe. |

**Nicht als erledigt markieren:** gruene Gesamt-CI, vollstaendiger ShellCheck-/
Bash-Lauf, 2x echte Installation/Idempotenz, Datenbank-Restore und externe
Port-Abnahme sind weiterhin offen. Die lokalen Zeitlimits und 6 uebersprungenen
Backup-Fixtures werden nicht durch das Vorhandensein eines Workflows erfuellt.

Die folgende urspruengliche PR-Serie konkretisiert die weiteren Pakete P0 bis P3.

Ergaenzung aus dem [Grok-Review](tutorials/grok-repo-review-2026-10-23.md):
Current Status, 60-Minuten-Einstieg und ein read-only Top-20-Metadateninventar
sind dokumentiert/implementiert. Die zwanzig operativen Lifecycle-Vertraege,
physische README-Kuerzung, Profil-Aliasmigration und Linux/WSL/ARM-Smoke-Abnahme
sind weiterhin offen. Keine neuen Doctors oder Installer allein fuer eine gruene Liste.

## PR-Serie

| Paket | Prioritaet / Aufwand | Konkrete Dateien und Zweck | Testnachweis vor Merge | Rollback |
|---|---|---|---|---|
| 01 Sichere Verwaltung | P0 / M | `install.sh`, `setup_ultimate.sh`: PAT aus URL/Remote entfernen; Hard-Sync ohne pruefbare Inhaltssicherung sperren. Gemeinsamen Compose-Helper gegen fremde/unsichere Pfade schuetzen; Deinstallation standardmaessig ohne Volumen-/Datenloeschung. | Fixtures fuer untracked/binaer/staged/ignored Dateien, Sicherungsfehler, Symlinks und fremde `TOOL_DIR`; kein Secret in Args/Logs/Remote; Dry-run schreibt nichts. | Alten Quellstand nur offline wiederherstellen; gesicherte Daten nie automatisch zurueckloeschen. |
| 02 Verifizierte Releases | P0 / L | Neuer Release-Bootstrap, `config/versions.lock`, Verifikationsskript und Release-CI; GitHub-Release-Tag plus Commit, Artefakthash und Signatur. `readme.md` erst nach vorhandenem signiertem Release umstellen. | Falscher Hash/Signer, Redirect, Downloadabbruch und unbekannte Version muessen vor Ausfuehrung scheitern; bekannte Version reproduzierbar. | Vorheriges ebenfalls verifiziertes Release; kein Rueckfall auf unverifiziertes `main`. |
| 03 Private Dienste / Cloud opt-in | P1 / M | Prometheus-/Grafana-Installer, `stacks/llmops-platform/`, Proxy-Manifest: interne Bindings, Auth, begrenzte Requests/Timeouts, Cloud-Fallback ohne explizite Freigabe aus, Budget-/Rate-Limit-Konfiguration. | Compose-Konfigurations- und HTTP-Fixtures: kein Wildcard-Publishing, ohne Token keine Anfrage, ohne Cloud-Opt-in keine Provider-Verbindung, Budgetfehler stoppt statt Schleife. | Konfiguration atomar zur vorherigen validierten Version; Dienste nur mit explizitem Apply neu starten. |
| 04 Backup wirklich verifizieren | P1 / M | `scripts/operations/backup_run.sh`, neue Backup-Service/Timer-Dateien und Restore-Doctor: rsync-Fehler weiterreichen, private Rechte, konsistente Exporte, verschluesseltes Offsite, Retention und getrennte Recovery-Keys. | ENOSPC/rsync-Teilfehler erzeugen Fehlerstatus; Restore in leeres Wegwerfziel, Datenbankintegritaet und Pruefsummen; kein Schreiben in Live-Ziele. | Timer deaktivieren, Konfiguration zuruecksetzen; vorhandene Archive bleiben erhalten. |
| 05 K3s-Basis und GPU | P1 / L | Neue `deploy/kustomize/base/` und Overlays `vps`, `homelab`, `gpu`; bisheriges `scripts/k8s_deployments.yaml` erst nach Migration abloesen. Namespaces, RBAC, Policies, PSS, Secrets-Encryption, GPU-Plugin, Affinity, Probes, Requests/Limits und explizite Storage-Entscheidung. | Kustomize rendern, kubeconform/kube-linter, CNI-Verbindungspruefung, Non-root-PVC-Rechte, ARM/x86 und schlafender GPU-Node; keine produktiven Manifeste im PR-Test anwenden. | Vorheriger gerenderter Stand; PVCs behalten; keine automatische Storage-Migration oder Downgrade bestehender Datenbanken. |
| 06 Agentenbetrieb | P1 / M | Getrennter OpenClaw-Gateway-Service, Queue-Unit/Executor und Konfigurationsvalidator: Dienstidentitaet, erlaubte Werkzeuge/Egress, Secrets getrennt, Laufzeit-/Ressourcenlimits, ausdrueckliche Freigaben fuer destruktive/externe Aktionen. | Sandbox-Ausbruch-/Policy-Fixtures, keine Docker-Socket-/Admin-Kubeconfig-Zugriffe, Token fehlt -> Start verweigert; Gateway/Ollama-Test nur isoliert und freigegeben. | Service stoppen, vorherige Konfiguration; Workspaces und Logs bleiben unveraendert erhalten. |
| 07 Wirksames Monitoring | P1 / M | Prometheus-Konfiguration, optional DCGM-Exporter/kube-state-metrics, Alertmanager-Regeln, begrenzte Loki-/Container-Retention, ntfy/E-Mail erst nach Zustimmung. | Regeltests fuer Disk/RAM/GPU/Backup-Alter/Node-Ausfall, Testalarm in isolierten Empfaenger, keine Prompt-/Token-Inhalte in Metriken/Logs. | Neue Scrapes/Alerts deaktivieren; keine Messdaten automatisch loeschen. |
| 08 CI als Merge-Gate | P2 / M | `.github/workflows/`, `.pre-commit-config.yaml`, Registry-Schemas: shellcheck/shfmt/Bats, Manifestvalidator, Trivy mit wirksamem Exitcode, Gitleaks mit redigiertem Report und klarer History-Abdeckung; Actions nach SHA pinnen. | Absichtlich kaputtes Manifest/Secret-Fixture muss CI scheitern lassen; Runner ohne Secrets und ohne privilegierte Host-Installation; Branchschutz separat nachweisen. | Einzelnes Gate gezielt revertieren; keine globale Fehlerunterdrueckung. |
| 09 Quelle der Wahrheit / Abnahme | P2 / L | `config/{tools,profiles,ports}.yml`, Menuegenerator und Dokumentationsgenerator; stabiles Statusschema mit Testdatum/CI-Beleg. Native Installer in Wegwerf-VMs Ubuntu 22.04/24.04 und separater WSL-Abnahme testen. | Schema, eindeutige IDs/Ports, erzeugte Dateien ohne Drift, 2x Install ohne Aenderung beim zweiten Mal, Uninstall erhaelt Nutzerdaten; planned bleibt erkennbar. | Generierte Artefakte und alte IDs als Migrationsadapter behalten; keine grosse Umbenennung. |
| 10 Optionale Module | P3 / je S-L | Nur belegte Integrationsluecken schliessen: SSO, GitOps, CSI/Velero, RuntimeClass, IaC/Ansible, Inferenzalternativen und Eval-Pipelines. Zuerst pruefen, ob bereits als Tool oder Profil vorhanden. | Je Modul Offline-/Wegwerf-Test, Ressourcenbudget, Dry-run, Idempotenz und dokumentierte Deinstallation. | Optionales Modul deaktivieren, keine Entfernung geteilter Basiswerkzeuge oder Daten. |

## Bewusst noch nicht umgesetzt

- Keine Installer-/Firewall-/Kubernetes-Aenderungen vor Abschluss der Analysephase.
  Die im Audit dokumentierten Risiken bleiben bis zu den entsprechenden Patches bestehen.
- Kein Git-Commit, PR oder Push; jede spaetere PR muss einen eigenen Testnachweis
  und nachvollziehbare Migration statt eines Sammel-Patches enthalten.
- Keine Lizenzwahl oder Verzeichnis-/Repository-Umbenennung ohne Betreiberentscheidung.
- Keine erfundenen Signaturen: Ein vom selben Downloadserver bezogener Hash ist
  kein unabhaengiger Herkunftsnachweis. Vertrauensanker fuer minisign/cosign erst
  festlegen und Schluessel/CI-Identitaet ausserhalb des Artefakts pruefen.
- Kein pauschales UID-1000-, Longhorn-, GPU-Operator-, RKE2- oder Mesh-Rollout:
  Image-Rechte, Hardware, CSI, WAN-Latenz und Betriebsaufwand zuerst messen.
- Keine neue automatische Wochen-/Monatsaufgabe angelegt. Backup-/Restore-Timer
  werden erst nach Auswahl von Ziel, Recovery-Key-Aufbewahrung und Freigabe aktiviert.
- Keine Aussage ueber sichere Live-Trades: Zenbot-Manifest und Upstream-Pflegezustand
  separat pruefen; Automaton-Wrapper sperrt den Agentenstart bereits. Tests duerfen
  keine Wallets, Boersenzugaenge oder reale Zahlungen verwenden.

## Noch offene Abnahme

- Vollstaendige Syntax-/Testpruefung in nativer Linux-CI auf sauberem Checkout
  nachholen. Der lokale Gesamtlauf endete im Zeitlimit; der Aegisub-Test A17
  scheitert separat reproduzierbar und muss vor einer Gruen-Meldung eingeordnet werden.
- Vollstaendige Git-Historie mit Gitleaks pruefen; nur redigierten Ergebnisbericht
  speichern. Fehlende Scanner sind kein Befund 'keine Secrets'.
- Externe Portpruefung nur gegen ausdruecklich zugeordnete eigene Hosts;
  IPv4/IPv6, Host-/Provider-Firewall und Docker-Publishing gemeinsam pruefen.
- Restore-Ziele, RPO/RTO und Budgetgrenzen gemeinsam festlegen, dann technisch testen.
- Jede verwendete externe Quelle und Ausnahme im Lock-/Provenienzschema abbilden;
  'alle Quellen gepinnt' erst nach automatischem Vollstaendigkeitsnachweis bestaetigen.

Bis dahin gelten die Produktions-Abnahmekriterien als **offen**, nicht als erfuellt.
