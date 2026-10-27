# PR-Entwurf: Audit und erste Quick Wins

Branch: `improve/audit-2026-10-27`. Keine PR erstellt, kein Push und keine
Installation. Dieses Paket schliesst nicht saemtliche Phasen 2 bis 6 ab.

## Aenderungsliste

| Paket | Aenderung | Nachweis |
| --- | --- | --- |
| Phase 1 | [Audit](../AUDIT_2026_10.md) mit Fundstellen, Gegenbelegen, Bewertung und priorisierter Restliste | Read-only Codepruefung und Registry-Checks |
| Phase 1 | [Vollstaendiger statischer Menueabgleich](../audits/2026-10-27-registry-drift.md) | 344 Tool-Menuekennungen inklusive nativer Allowlist; keine Runtime-Aussage |
| A04 | Automatische Loeschung/Verschiebung bestehender Quellziele bei Git-Fehlern entfernt | 6 isolierte Git-Mocktests erfolgreich |
| A11, teilweise | Auditparser liest bekannte native Registrierung mit; fuehrt keine Shell-Ausdruecke aus | 10 Offline-Fixtures erfolgreich; Registry ist noch nicht die einzige Menuequelle |
| A15 | Root-Statusdateien nur aus Git entfernt und ignoriert | Lokale Kopien erhalten; externer Workspace unberuehrt |
| A16, teilweise | Apache-2.0 nach ausdruecklicher Maintainerwahl, erste Dritthinweise, neutrales Supportwording | 4 Governance-Tests erfolgreich; keine umfassende Rechte-/SBOM-Abnahme |
| A18, teilweise | Verzeichniszwecke dokumentiert und [Kurz-README vorgeschlagen](../README_SHORT_PROPOSAL.md) | Aktive README bewusst noch nicht verschoben; alte Links bleiben erhalten |

Der Phase-1-Bericht bleibt als Ausgangsbefund erhalten. Die dort beim Audit
noch offene Lizenzentscheidung wurde anschliessend mit Apache-2.0 beantwortet.
Die Vorlage stammt aus dem [offiziellen ASF-Lizenztext](https://www.apache.org/licenses/LICENSE-2.0.txt).

## Tests

```text
python -B -m unittest discover -s tests -p test_source_preservation.py -v
python -B -m unittest discover -s tests -p test_tool_coverage_audit.py -v
python -B -m unittest discover -s tests -p test_audit_governance.py -v
bash -n scripts/tools/helpers/simple_tool_common.sh
bash scripts/validate_config.sh
bash scripts/check_tools.sh
bash scripts/check_profiles.sh
bash scripts/check_ports.sh
git diff --check
```

Die drei Testsuiten ergeben 20 erfolgreiche gezielte Tests, keinen gruenerklaerten
Gesamtlauf aller vorhandenen Tests. Fuer die Registry-Shellchecks wurde das
vorhandene gebuendelte Python nur im Kindprozess als `python3` bereitgestellt.
ShellCheck und shfmt fehlen im nativen Git-Bash-PATH; sie wurden nicht installiert
und sind **nicht abgenommen**. Ein uebergeordneter Dokumentations-Prueflauf
erreichte sein Zeitlimit; die vier Governance-Tests bestanden im separaten Lauf.
Die vier Registry-Checks wurden nach den Aenderungspaketen wiederholt;
810 Metadatenhinweise und 48 Quellenhinweise bleiben sichtbar.

## Bewusst nicht umgesetzt

- Kein automatisches Latest-Release ohne unabhaengigen Vertrauensanker. Die
  vorhandene Minisign-Pruefung bleibt bei fehlenden Artefakten gesperrt.
- Kein frei gewaehlter Upstream-Pin oder Image-Digest ohne Verifikation.
- Keine echten Installer-/Modell-/Cluster-/Provider- oder Restore-Tests und keine
  Zugriffe auf `~/.openclaw_ultimate_user_data`.
- Keine Scheinregistrierung weiterer bereits vorhandener Ansible-/GitOps-/Backup-
  oder Monitoring-Bausteine. Luecken muessen mit Lifecycle-Nachweisen geschlossen werden.
- Keine pauschale Lizenz-Neuzuordnung von Drittcode oder Annahme geklaerter Rechte
  aller historischen Beitraege. Vor Veroeffentlichung gesondert pruefen.

## Verbleibende Risiken und naechste PRs

1. A01/A02 zuerst: Legacy-LoadBalancer-Proxy, moegliches Key-Logging und direkte
   Download-in-Shell-Installer. Dieses Paket macht diese Altpfade nicht sicher.
2. Source-/Lock-Pins fuer OpenClaw, n8n und Blender; echte Dry-run-/Yes-Vertraege
   vor Tracking/APT fuer alle Kerninstaller.
3. Lokale LiteLLM-Defaults ohne automatische kostenpflichtige Cloud-Fallbacks;
   getestete harte Budget-/Rate-Limits statt blossen Konfigurationsbeispielen.
4. Compose-/Kustomize-Abnahme, Image-Pins, CI-Pins, Container-/ARM-Smokes, Restore-
   Drill und GPU-/WoL-Kette. Netzwerk-/MCP-Auth und CNI-Wirkung bleiben ungeprueft.
5. Linkerhaltende Uebernahme der Kurz-README, historische Review-Kennzeichnung
   und aus Ergebnisartefakten erzeugte Statusmatrix.

## Rollback

Die Commits sind einzeln reviewbar. Ein gezielter Revert des jeweiligen Code-/
Dokumentationscommits ersetzt keine Deinstallation und aendert keine externe
Runtime. Keine `reset --hard`-/`clean`-Anweisung zum Zurueckrollen dieses Pakets.

Vor einem Revert der Status-Entversionierung vorhandene lokale Root-Statusdateien
separat sichern: ein Revert wuerde alte versionierte Kopien wieder einfuehren.
Kein automatischer Import in den aktiven Benutzer-Workspace. Den datenerhaltenden
Git-Fix zurueckzunehmen wuerde die alte automatische Quellloeschung erneut aktivieren.

## Offene Entscheidungen

- Unabhaengig gepruefter Minisign-Public-Key und freigegebene Release-Artefakte fehlen.
- Erstes isoliertes Abnahmeziel bleibt Ubuntu 24.04 amd64; ARM/GPU/WSL2 separat.
- Lizenzwahl ist beantwortet: Apache-2.0; noch kein Rechteketten-/Drittlizenzabschluss.
