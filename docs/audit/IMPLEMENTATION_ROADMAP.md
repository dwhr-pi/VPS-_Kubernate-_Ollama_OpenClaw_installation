# Priorisierte Umsetzung

## P0: Daten und Einstiegspfade

SEC-001/002/003 zuerst reviewen: keine automatische Workspace-Komplettloeschung, Registry-basierte
Lifecycle-Auswahl, wieder lesbare Backup-Grenzwerte. Keine privaten Workspaces, laufenden Services
oder Lock-Dateien pauschal reparieren. Codeaenderungen werden getrennt von produktiver Anwendung
behandelt.

Naechstes Gate: Ubuntu-VM, gueltige/ungueltige IDs, Links, zweimalige Ausfuehrung, Abbruch und
Recovery-Fixtures. Bekannte unveraenderte Nutzdatei muss jedes Update und jeden Uninstall
ueberleben. Aufwand: 1-2 Tage inklusive Review.

## P1: Zuverlaessigkeit und Nachweise

SEC-004/006/007 sind minimal im Code adressiert; aktuelles Runtimeverhalten bleibt zu testen.
SEC-005/008/009/010 abschliessen: private Temp-Dateien/Datenparser, gemeinsames Maintenance-Lock,
idempotente Rechtepruefung, immutable CI und getrennter redigierter Historien-Scan. Inventar nicht
durch frei erfundene Lizenzen/Reifestufen auffuellen. Groesse und Hashes der generierten Artefakte
in CI kontrollieren, Metadatenluecken schrittweise als Delta-Gate reduzieren.

Gate: neue Regressionen gruen, gezielte Scanner mit gepruefter Quelle, ein echter verschluesselter
Restore in isoliertem Ziel. Aufwand: 3-5 Tage; Historienbereinigung/Key-Rotation nur nach
verifiziertem Fund und gesonderter Freigabe.

## P2: Vorhandenes verbinden

INT-001 bis INT-007: genau ein lokaler RAG-Pfad, genau ein Memory-Adapter, ausserhalb des Modells
erzwungene Toolfreigaben, ein Monitoring-/Backupvertrag. Keine zweite Orchestrierungsplattform,
bevor vorhandene Workflows ihre Grenzen gezeigt haben. Modellrouting standardmaessig lokal,
Cloud-Auswahl bewusst.

Gate: Tenant-/Loeschtest, Ingest-/Retrieval-Nachweis, Alarm, Log-/Trace-Korrelation ohne
Geheimnisse, kontrollierte Serviceaktivierung nach Update. Aufwand: 1-2 Wochen.

## P3: GPU, Coding und GameDev

Erst GPU-/K3s-Testworker, dann Quellen-/Buildpfade fuer Coding/Medien abnehmen. Godot-Projekt mit
Headlessszene, Export, glTF, Streaming und Performancebudget als Referenz; XR/AR/Mobile als
getrennte Projekte, nicht universelle Zusagen. Alternativen wie vLLM/SGLang oder weitere
Eval-Frameworks nur nach Vergleichsnutzen.

Gate: reproduzierbarer Build, Lizenz/Asset-Rechte, per Modell/Hardware gemessene Qualitaet und
Leistung; neue Tools bleiben ohne Abnahme OPTIONAL/EXPERIMENTAL. Aufwand: pro Integration 2-5 Tage
plus Hardware-/Lizenzklaerung.

## P4: Optimierung und Betrieb

Cold-/Warm-Cache, TTFT, Parallelitaet, VRAM/RAM und Energie messen. WOL-/Queue- Strategie verhindert
dauerhaft laufende Grossmodelle ohne Bedarf. UI/Profil-Aliase erst nach gemeinsamem Lifecyclevertrag
zusammenfuehren. SLOs mit echten Daten festlegen und Fehlerbudgets statt einer statischen
"produktionsreif"-Kennzeichnung nutzen.

## Naechste konkrete Schritte

1. Neue Code-/Audit-Diffs auf lokalem main reviewen; bestehende GPU-Aenderungen aus dem vorherigen
   Auftrag getrennt erhalten.
2. Offline-Ergebnisse und unbekannte Metadaten im Inventar pruefen; kein Tool allein aufgrund seines
   Statuslabels hochstufen.
3. P0/P1 in Ubuntu-VM abnehmen, anschliessend echte Backup-Wiederherstellung.
4. Genau ein Profil und einen RAG-/Agentenfluss End-to-End fertigstellen.
5. Erst danach freiwillige GitOps-Synchronisierung und Hardware-Erweiterung.

Rollback: Code-Commits gezielt ruecknehmen, nicht `git reset --hard` ueber fremde Aenderungen. Keine
automatische Ruecknahme von Nutzdaten, Datenbankschemas oder PVCs. Alte
Cloud-Fallback-/Loesch-Defaults nicht ohne erneute Sicherheitsentscheidung wieder einschalten. Kein
Push oder Produktivdeployment durch dieses Audit.
