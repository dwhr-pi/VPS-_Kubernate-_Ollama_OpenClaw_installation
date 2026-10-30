# Zehn priorisierte Integrationsluecken

Kein Eintrag bedeutet automatisch "Tool fehlt". Status ist durch Codebelege begrenzt;
Datenbank-/Hardware-/Netzwerkzugriff erfolgte nicht.

| ID / Prioritaet | Beleg und Luecke                                                                                                                                       | Massnahme / Aufwand                                                                                   | Abhaengigkeit und Abnahme                                                                                                     |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| INT-001 / P1    | `scripts/profiles/RAG_Wissensdatenbank_install.sh` installiert Komponenten, `config/profiles.yml` bildet nicht alle sechs Abhaengigkeiten ab           | Registry/Installer abgleichen und einen Ingest->Embedding->Qdrant->Retrieval-Weg definieren; 2-3 Tage | Lokales Embeddingmodell, Fixture-Dokumente; Quellen/ACL/Loeschung reproduzierbar pruefen                                      |
| INT-002 / P2    | `docs/memory/ultimate-jarvis-memory.md` bezeichnet persistentes DB-Memory als geplant; `profiles/ultimate-jarvis/docker-compose.override.yml` ist leer | Vorhandene Persona-Dateien mit genau einem Persistenzadapter verbinden; 2-4 Tage                      | Session-/Mandantenmodell; Neustart, Zugriffssperre und Restore testen                                                         |
| INT-003 / P1    | `config/agents/coding_agents.json` ist Policy, keine technische Sandbox                                                                                | Approval-Wrapper vor Host-/Publikations-/Zahlungs-Tools; 2-3 Tage                                     | Identitaet, Tool-Allowlist, Timeout; Bypass-/Prompt-Injection-Fixtures ablehnen                                               |
| INT-004 / P1    | `scripts/operations/backup_user_workspace.sh` sichert Dateien ohne Restore-Abnahmenachweis                                                             | Quiesce-/Lockvertrag und isolierte Wiederherstellung; 1-2 Tage                                        | Externes Ziel und getrennte Recovery-Secrets; Hash-/Applikationspruefung nach Restore                                         |
| INT-005 / P2    | `stacks/llmops-platform/docker-compose.yml` startet Monitoring ohne vollstaendige Scrape-/Datasource-Verdrahtung                                       | Bestehende `monitoring/`-Provisionierung kontrolliert wiederverwenden; 1 Tag                          | Authentifizierter Gateway-Metrikendpoint; Token-/Latenzpanel zeigt reale Daten                                                |
| INT-006 / P2    | `k8s/monitoring/` enthaelt Loki, aber keinen abgenommenen Log-Collector/Alarmempfaenger                                                                | Alloy und Alert-Routing getrennt konfigurieren; 1-2 Tage                                              | Redigierung/Retention; Testalarm und synthetische Logkorrelation nachweisen                                                   |
| INT-007 / P1    | `ansible/playbooks/core_ai_setup.yml`: `daemon_reload` plus `state: started` aktiviert keinen geaenderten Prozess                                      | Explizit freizugebender Restart nach erfolgreicher Build-/Config-Pruefung; 1 Tag                      | Serviceversion/Healthcheck; alter Prozess bleibt bis Freigabe, danach neue Version                                            |
| INT-008 / P2    | `k8s/overlays/gpu/` benoetigt Runtime, Label und Device Plugin; `local-path` ist nodegebunden                                                          | GPU-Worker- und Failure-Runbook statt blindem HPA; 1-2 Tage                                           | Echte NVIDIA-/K3s-Testmaschine; VRAM, Pending, Nodeausfall und Cache testen                                                   |
| INT-009 / P2    | `scripts/tools/gamedev_3d_studio_install.sh` und neue Engine-Tools haben getrennte Lebenszyklen                                                        | Gepinnte Projekt-/Asset-Pipeline mit Exporttests; 2-5 Tage                                            | Asset-Rechte, Engine-Pin; Headlessszene, glTF, Streaming, Export einzeln testen                                               |
| INT-010 / P1    | `scripts/quality/platform_inventory.py`: Dateiexistenz ersetzt keine Service-/Plattformabnahme                                                         | Sechs Reifestufen, zugeordnete Tests und datierte Evidenz pflegen; laufend                            | `[planned, documented, implemented, tested, staging_verified, production_verified]` pro Umfang, kein automatisches Hochstufen |

## Reproduktionsvertrag

INT-001 bis INT-009 zuerst durch Lesen der genannten Einstiegspfade und der dort ausgefuehrten
Konfiguration reproduzieren, nicht durch unkontrolliertes Starten aller Installer. Danach isolierte
Fixtures und ausdrueckliche Staging-Abnahme. INT-010 ist offline mit dem Inventargenerator und
dessen Tests reproduzierbar.

## RAG-Qualitaetsgate

`scripts/benchmarks/rag_evaluate.py` wertet gelieferte Rankings ohne Datenbank-/LLM- Aufruf aus:
Precision@k, Recall@k, MRR@k sowie verbotene Mandanten-/Versionshits. Die fuenf Fragen in
`tests/fixtures/rag_retrieval/` sind **synthetische Fixtures**, keine gemessenen Qdrant-Ergebnisse.
Vollstaendigkeit und doppelte IDs werden geprueft.

```bash
python3 -B scripts/benchmarks/rag_evaluate.py \
  --dataset tests/fixtures/rag_retrieval/dataset.json \
  --predictions tests/fixtures/rag_retrieval/predictions.json --k 3
```

Das Beispiel beweist die Auswertelogik, nicht Antwortqualitaet, Halluzinationsfreiheit oder
ACL-Durchsetzung im Datastore. Fuer Staging dieselben IDs mit echten, autorisierungsgefilterten
Rankings fuellen und Ergebnis samt Modell-/Index-/Chunking- Version sichern. Verbotene Treffer
muessen null bleiben; Recall-/Latenzziele vor Messung festlegen. Ragas/DeepEval oder ein LLM-Judge
sind optional, kein Ersatz fuer Quellen-/Tenant-/Loeschtests und kein Anlass fuer ungefragte
Provider-Kosten.
