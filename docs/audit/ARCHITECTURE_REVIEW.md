# Architekturreview

## Layer und nachgewiesene Grenzen

```text
HE / DNS -> VPS-DMZ -> VPN -> Pi / MiniPC -> GPU-Worker
             |                 |              |
       TLS / Gateway      WOL / Queue       Ollama
             |                 |              |
             +------ Agenten -> LiteLLM -------+
                       |
                 Tools / RAG / UI
                       |
       Monitoring / Security / getrenntes Backup
```

Das Diagramm ist das Zielbild, kein Nachweis einer laufenden Installation.

| Layer | Codebeleg | Bewertung |
|---|---|---|
| Base/Runtime | `install.sh`, `scripts/quality/development_toolchains.py` | Sichere Einstiegspfade und private Toolchains vorhanden; heterogene Installer |
| Gateway | `k8s/base/litellm.yml`, `stacks/llmops-platform/litellm-config.yaml` | Zentrale API-Grenze sinnvoll; Compose und K8s nicht gleich weit integriert |
| Modellserver | `k8s/base/ollama.yml`, `k8s/overlays/gpu/` | Cache/Probes/Non-root vorhanden; GPU/TLS/CNI live nicht abgenommen |
| Agenten | `config/agents/coding_agents.json`, `scripts/profiles/coding_agents.py` | Deklarierte Rechte sind noch keine technische Sandbox |
| Memory/RAG | `docs/memory/ultimate-jarvis-memory.md`, `scripts/profiles/RAG_Wissensdatenbank_install.sh` | Komponenten und Entwurf vorhanden; durchgaengige Retrieval-/ACL-Pipeline offen |
| Tools/UI | `config/tools.yml`, `config/profiles.yml` | Umfangreich; Metadaten, Lebenszyklen und Reifegrade uneinheitlich |
| Monitoring | `monitoring/`, `charts/monitoring-lite/`, `k8s/monitoring/` | Mehrere sinnvolle Betriebsvarianten, aber keine beliebig kombinierbaren Defaults |
| Security/Backup | `scripts/security/`, `scripts/lib/install_rollback.py`, `scripts/operations/backup_user_workspace.sh` | Viele Schutzmechanismen, Restluecken siehe Sicherheitsbefunde |

## Orchestrierung und Rollen

Planner, Researcher, Developer, Reviewer, Auditor, Tester, Documentation und
Deployment sind **Berechtigungsrollen**, kein Grund fuer neun dauerhafte Agenten.
Ein Human Approval Controller muss Aktionen ausserhalb des Modells freigeben;
ein Prompt "frage vorher" allein erzwingt keine Grenze. Kritische Hostaktionen,
Veroeffentlichungen, Zahlungen und Loeschungen muessen in einem Tool-Wrapper
standardmaessig gesperrt sein, einschliesslich Rekursion/Unteragenten.

Vorhandene n8n-/Workflow- und Agentenpfade zuerst abnehmen. Eine zweite
LangGraph-/Temporal-/A2A-Steuerung erst nach Nachweis fehlender Wiederaufnahme,
Job-Idempotenz, Genehmigung und Audit-Korrelation einfuehren. MCP standardisiert
den Toolzugriff, nicht dessen Autorisierung oder Isolation.

## Ueberschneidungen

`mcp_memory` und `mcp_memory_server` verweisen auf dieselbe Upstream-Familie;
Platzhalter zaehlen nicht als zwei Speicherintegrationen. Profil-Aliase werden
bereits von `scripts/check_profile_registry_sync.sh` erkannt, aber noch nicht
ueber einen gemeinsamen Lebenszyklus zusammengefuehrt. Alte
`gamedev_3d_studio_install.sh`-Klone sind nicht mit den neuen gepinnten
Engine-Studien-/Buildpfaden gleichzusetzen. Mehrere Backup- und Monitoring-Wege
koennen Alternativen sein; erst Ziel, Zustand und Restorevertrag vergleichen,
bevor ein vermeintliches Duplikat entfernt wird.

## IaC-Migrationspfad

Interaktive Bash-Oberflaeche als Auswahl-/Planungsebene erhalten. Registry,
validierte Transaktionen und private Nutzerdaten bleiben gemeinsame Basis.
Host-Baseline ueber vorhandenes Ansible abnehmen, Workloads ueber Kustomize/Helm,
anschliessend manuelle Argo-/Flux-Synchronisierung. Kein gleichzeitiges Uebernehmen
derselben Ressourcen durch Bash, Ansible und GitOps. Dienst-Aktivierung nach
Buildwechsel explizit freigeben; `daemon_reload` startet einen Dienst nicht neu.

## GameDev und Medien

Godot/Blender, glTF und gepinnte Asset-Werkzeuge sind die sinnvolle Basis. OpenUSD,
Geodaten/GDAL/OSM, Photogrammetrie und Gaussian Splatting getrennt nach Lizenzen,
Asset-Rechten und Leistung testen. Import, Terrain, World-Streaming, LOD/HLOD,
Render-Profiling, Multiplayer und Export sind einzelne Abnahmen. Ein erfolgreicher
Headless-Versionsaufruf belegt keines davon. OSM-Datenlizenz ist nicht automatisch
die Lizenz erzeugter Texturen oder fremder Bildquellen.

Kein NPC-Backend darf direkt unbeschraenkte Host-/Shellrechte erhalten. Ein
authentifiziertes, budgetiertes Gateway und reproduzierbare Spielszenen sind vor
GPU-/XR-/Medienautomatisierung abzusichern. Keine Medienmodelle ohne
Mehrwertmessung doppelt installieren.
