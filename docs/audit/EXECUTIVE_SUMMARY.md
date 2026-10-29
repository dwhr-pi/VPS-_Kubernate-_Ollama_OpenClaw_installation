# Gesamtaudit: Ergebnis und Grenzen

Stand: 29.10.2026. Grundlage ist lokales `main`, Ausgangscommit `a6ed0f3`,
einschliesslich der noch nicht committeten GPU-/Betriebsergaenzungen.
Die exakte Basis und Dateihashes stehen im [Inventar](inventory.json).
Es gab keinen Produktions-, WSL-, Provider-, Wallet- oder Credential-Zugriff.

Nachtrag zur Navigation: Das im damaligen Inventar erfasste
`scripts/k8s_deployments.yaml` ist jetzt eine
[nicht ausfuehrbare historische Referenz](../legacy/K8S_DEPLOYMENTS_LEGACY.md).
Inventar und Befunde bleiben als datierte Belege erhalten. Die Archivierung
repariert keine bestehenden Cluster und ersetzt keine Live-Abnahme.

## Tatsaechlicher Stand

399 Tools, 245 Profile und 45 registrierte Ports bilden einen umfangreichen
Installationskatalog. Ein Registry-Eintrag ist weder eine installierte Anwendung
noch eine nachgewiesene Integration. Die vorhandenen signierten Einstiegspfade,
privaten Workspaces, Rollback-Pruefungen und Offline-Tests sind wertvolle
Grundlagen. Dennoch ist **keine pauschale Produktionsfreigabe** belegbar.

Die automatisierte Bestandsaufnahme erfasst Registry und Repository-Dateien;
manuell wurden sicherheitsrelevante Einstiegspfade und repraesentative
Integrationen untersucht. Nicht jede Zeile jedes Drittinstallers wurde manuell
reviewt, nicht jede Upstream-Lizenz oder Versionskombination aktuell zertifiziert.
Historische Secret-Scans und echte Installations-/Restore-Tests bleiben eigene Gates.

## Durchgefuehrte Verbesserungen

- Direkte rekursive Workspace-Komplettloeschung im Menue gesperrt.
- Update/Uninstall nur ueber eindeutige Registry-Zuordnung, ohne Pfadtraversal;
  Batch-Update ersetzt fehlende Updater nicht mehr stillschweigend durch Installer.
- Backup-Export und Wiederherstellung mit konsistenten, begrenzten Groessenbudgets.
- Secret-Scan-Fallback behandelt Scannerfehler als Fehler und gibt keine Trefferwerte
  aus; TruffleHog verifiziert moegliche Zugangsdaten nicht bei externen Diensten.
- LiteLLM-Compose-Konfiguration nutzt Laufzeit-Environment-Lookup; automatischer
  Cloud-Fallback ist nicht mehr Standard. Konfigurationskopien erhalten 0600.
- Helm-Retentionskennzeichnung fuer Monitoring-Namespace und -PVCs; kein Ersatz
  fuer ein Backup oder fuer einen real getesteten Helm-Uninstall-/Restore-Ablauf.
- Bestehendes Inventar erweitert; Build-Caches und Windows-Junctions beim
  Repository-Scanner ausgeschlossen. Offline-Retrieval-Benchmark hinzugefuegt.

**Verhaltensaenderungen:** Menuepunkt Komplettloeschung fuehrt keine Loeschung
mehr aus; fehlende registrierte Updater ergeben einen sichtbaren Fehler statt
Reinstall; Cloud-Fallbacks muessen bewusst eingerichtet werden. Bereits laufende
Dienste und bestehende `.env` wurden nicht geaendert. Aenderungen an Vorlagen
werden erst bei einer spaeter ausdruecklich ausgefuehrten Anwendung wirksam.

## Prioritaeten

Die [zehn priorisierten Sicherheitsbefunde](SECURITY_FINDINGS.md) unterscheiden
behobene Codefehler von offenen Risiken. Besonders wichtig bleiben private
Temp-Dateien im Hauptmenue, vollstaendige Git-Historienpruefung, ein
koordiniertes Backup-Lock und die kontrollierte Aktivierung geaenderter Dienste.
Die [zehn Integrationsluecken](INTEGRATION_GAPS.md) betreffen vor allem fehlende
End-to-End-Verbindungen, nicht die Menge installierbarer Programme.

## Wegweiser

| Dokument | Inhalt |
|---|---|
| [Architektur](ARCHITECTURE_REVIEW.md) | Layer, Grenzen und Ueberschneidungen |
| [Sicherheitsbefunde](SECURITY_FINDINGS.md) | ID, Prioritaet, Beleg, Reproduktion, Abnahme |
| [Vollinventar](TOOL_INVENTORY.md) | Alle Tools und Profile; JSON mit Metadaten |
| [Werkzeugbewertung](MISSING_TOOLS.md) | Vorhandenes zuerst, begruendete Kandidaten |
| [Integrationsluecken](INTEGRATION_GAPS.md) | Zehn priorisierte Verbindungen |
| [Plattformen](PLATFORM_COMPATIBILITY.md) | Capability- und Abnahmematrix |
| [Tests](TEST_COVERAGE.md) | Ausgefuehrte Tests und ausdrueckliche Luecken |
| [Ressourcen](RESOURCE_PLANNING.md) | Platzierung, Budgets und Benchmarks |
| [Roadmap](IMPLEMENTATION_ROADMAP.md) | P0 bis P4, Gates und naechste Schritte |

Keine Produktionsberechtigung wird aus `stable`, `source_verified` oder einem
bestandenen Unit-Test abgeleitet. `tested` gilt immer nur fuer den genannten
Testumfang, niemals automatisch fuer eine gesamte Runtime.
