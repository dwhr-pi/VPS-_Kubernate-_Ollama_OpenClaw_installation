# Plattform-Review und priorisierter Patch-Plan

Stand: **26.10.2026**, lokaler HEAD
`9fba38e6f97cf653fb8075c0b9d077015d4220db`.
Repository: [dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation).
**Statischer Review, keine Produktionsfreigabe.** Nutzer meldet erfolgreiche
Installationen der getesteten Tools; grosse Builds bleiben wegen Speicher offen.
Installationserfolg ist kein Beleg fuer Auth, Isolation, Restore oder Inferenz.

## 1. Wichtigste Befunde

| Prio | Befund und konkrete Fundstelle | Konsequenz / vorgeschlagener Patch |
|---|---|---|
| P0 vor Nutzung des optionalen Compose-Stacks | [Stack-env-Beispiel](../../stacks/llmops-platform/.env.example), Zeilen 6-31: bekannte Passwort-/Key-Platzhalter; [Compose](../../stacks/llmops-platform/docker-compose.yml), Zeile 48 uebernimmt den DB-Wert | Vor Start/Plan bekannte Platzhalter und leere Pflichtwerte ablehnen; Dienst-Secrets getrennt. Vorhandene Loopback-Bindings bleiben erhalten |
| P0 vor Mehrdienstbetrieb | Dieselbe Compose-Datei, Zeilen 6, 18, 66, 79: komplette gemeinsame env-Datei in mehrere Dienste | Jede Anwendung bekommt nur eigene benoetigte Secrets; kein Router-/DB-/Storage-Key im jeweils fremden Container |
| P0 vor gemeinsamem Profil-Uninstall | [Studio-Uninstall](../../scripts/profiles/Image_Generation_Studio_uninstall.sh):5, [DevSecOps-Uninstall](../../scripts/profiles/Security_DevSecOps_uninstall.sh):5 | Tool-Uninstaller ohne hier sichtbare Referenzpruefung; Fehler teils unterdrueckt, danach Profilmarker entfernt. Besitzer-/Nutzerliste, Plan und Fehlerweitergabe zuerst, keine automatischen Tool-Loeschungen bei Alias-Migration |
| P1 | [Doctor](../../scripts/doctor.sh):119-153 nutzt u.a. `npx --yes`, Netzwerk und Warnungs-Fallbacks; Registry-Fehler am Anfang koennen nachfolgende Checks verhindern | Offline-, Host- und Runtime-Modi trennen; kein Paketdownload durch Diagnose, aggregierte Fehler-/Skip-Codes statt pauschal gruener Abschluss |
| P1 | [CI](../../.github/workflows/ci.yml):20-65 wiederholt Pruefungen mit abweichenden Formatregeln, teilweise Fehlerunterdrueckung; Lifecycle ohne strict | Required Checks vereinheitlichen, neue Fehler blockieren, Altlasten datiert baselinen. CI-Erfolg allein ist keine Deployment-Freigabe |
| P1 | [Deployment](../../scripts/operations/deploy_vps_baseline.sh):49-67 prueft Pins, Schema, Kontext und bestaetigtes Apply, aber keinen signierten Staging-/Restore-Nachweis | Bestehenden Schutz erhalten, zusaetzlich revisionsgebundenes Security-/Restore-Gate. Manuelles Direkt-Apply bleibt separat organisatorisch/technisch abzusichern |
| P1 | [install.sh](../../install.sh):493, 511, 518 nutzt main als Ausfuehrungsstand | Bereits vorhandene Backup-/FF-only-/Hard-Sync-Bestaetigungen erhalten; reviewed Ref und verifizierte Artefakte statt beweglichem Produktionsstand |
| P1 | [Compose](../../stacks/llmops-platform/docker-compose.yml):3,15,33,63,76 ff. nutzt main/latest; :128-131 Netdata mit SYS_PTRACE/AppArmor-Ausnahme | Gepruefte Digests und Migrations-/Restorevertrag; privilegiertes Monitoring als begruendete Ausnahme, nicht neuer Default |
| P1 | [LiteLLM](../../k8s/base/litellm.yml):4,36,65,90 und [Production-Overlay](../../k8s/overlays/production/kustomization.yml):10: feste ConfigMap, env-Secret, eine Replik mit Recreate | Config-/Secret-Rotation muss Pod-Rollout ausloesen; Single-Replica-Wartungsfenster oder getesteter HA-Pfad, nicht blind Replikzahl erhoehen |
| P2 | Viele Registry- und Profilluecken, lange Hauptdokumentation, ueberlappende Kataloge | Erst zentrale Lifecycle-/Alias-Semantik, danach Navigation/Toolausbau; nicht noch mehr ungepruefte Default-Dienste |

P0 ist hier eine **Freigabesprioritaet fuer die betreffenden Betriebswege**,
kein Nachweis einer oeffentlich erreichbaren oder bereits kompromittierten Installation.
Compose/Kubernetes/Ansible sind alternative, optionale Pfade; ihr Vorhandensein
bedeutet nicht, dass install.sh sie automatisch ausgerollt hat.

## 2. Inventur und Nachweisgrenzen

Gelesen: README, Bootstrap/Setup, Registry, Doctor/CI, relevante Installer und
Profile, Ansible, K8s-Baseline/Overlays, Compose, Monitoring, SOPS-/Backup- und
Deployment-Pruefpfade. Vollstaendig erfasst wurden **Registry-Metadaten**, nicht
der semantische Inhalt jedes einzelnen der hunderten Installer. Kein Live-Cluster,
Provider, WSL, systemd, Firewall oder produktiver Datenbestand wurde abgefragt.
Beim ersten Test des Healthcheck-Mocks wurde unter Windows versehentlich reales
curl statt des Dateishims aufgerufen: fuenf begrenzte Loopback-GETs liefen in
Timeouts. Der Test wurde auf eine vorrangige Shellfunktion umgestellt; kein
Modellaufruf, Login, Dienststart oder Schreibzugriff erfolgte dabei.

- [Alle 385 Tools](2026-10-26-tools-matrix.md): Install-Skript/Zielhinweis,
  Abhaengigkeiten, Ports, Ressourcenklasse, Check-/Health-/Smoke-/Version-/Logs-
  Mapping, Uninstall, Test-/Reifestand, Risiko.
- [Alle 245 Profile](2026-10-26-profiles-matrix.md): dieselben Achsen und
  Reviewklasse fuer jedes Profil.
- Fehlende Angaben bleiben **not-declared/not-mapped/not-assessed** statt
  erfundener Ports, Speicherwerte oder gruener Healthchecks.
- Reviewklasse ist konservative **Abnahmeplanung**: bestehende stable/beta-
  Deklarationen bleiben als solche sichtbar; planned bleibt planned;
  experimental/optional/ohne Status werden ohne weiteren Beleg planned.
  documentation-only/deprecated werden nur bei entsprechender Deklaration bzw.
  eindeutig fehlendem Install-Mapping als Dokumentationspfad verwendet.
  Kein Profil wird dadurch in config/profiles.yml veraendert oder produktionsreif.
- Ein Pfadcheck prueft bestenfalls Artefakte, kein laufendes Gateway. Ein Port
  beweist weder Authentifizierung noch die Identitaet des antwortenden Dienstes.

| Deklaration | Tools | Profile |
|---|---:|---:|
| stable | 2 | 0 |
| beta | 1 | 21 |
| experimental | 146 | 17 |
| optional | 12 | 0 |
| planned | 149 | 169 |
| ohne Status | 75 | 38 |
| Gesamt | 385 | 245 |

Die stable-Labels betreffen DuckDB/Grype, nicht die Gesamtplattform.
Zentrale Tools-Mappings fehlen fuer **240 Doctor, 240 Update und 222 Docs**;
254 Eintraege deklarieren keinen source_commit. Installer koennen trotzdem
intern gepinnt sein. 105 Profile haben kein zentrales Install-/Uninstall-Mapping.
Gesonderte Check-Dateinamen und zentrale Registry-Felder sind unterschiedliche
Pruefachsen. Die Registry hat bislang kein durchgaengiges Health-/Smoke-/Logs-Schema.

Ausgefuehrt: `repository_audit.py --section registry`: **0 strukturelle Fehler,
815 Hinweise**, 44 Port-Eintraege. Kein Beweis, dass alle 44 Ports konfliktfrei
oder alle genannten Dienste erreichbar sind. `doctor.sh` wurde wegen seiner
Seiteneffekte nicht ausgefuehrt. Historische Audits bleiben erhalten.

Reproduzierbar, ohne Netzwerk-/Runtime-Zugriff:

```bash
python3 -B scripts/quality/platform_inventory.py
python3 -B scripts/quality/platform_inventory.py --markdown --kind profiles
python3 -B scripts/quality/repository_audit.py --section registry
```

Der neue Reporter schreibt nur stdout und liest die zwei Registry-Dateien
sowie referenzierte Dateimetadaten; keine Keys oder persoenlichen env-Dateien.
Matrix-Snapshots gelten fuer den genannten Commit, nicht automatisch fuer morgen.

## 3. Zielarchitektur und Profilkonsolidierung

```text
Internet -> HE/Domain -> TLS/Auth-Edge auf VPS/DMZ
                              |
                       WireGuard / Tailscale
                              |
                     Steuerung / WoL zum Pi
                              |
     UI -> Gateway -> LiteLLM -> Ollama / optionaler GPU-Worker
            |                    |
      getrennte Agenten      persistente Modellgewichte
            |
       freigegebene Tools -> RAG (Qdrant ODER pgvector/Chroma)
            |
       redigierte Metriken/Logs/Traces -> Monitoring
            |
       konsistente Backups -> separates verschluesseltes Ziel
```

Base -> Runtime -> Model Gateway -> Agent Layer -> Memory/RAG -> Tool Layer ->
UI bleibt fachlich erhalten; Monitoring/Security sind Querschnitt, keine erst
am Ende eingeschalteten Zusatzmodule. Oracle/VPS steuert, Pi weckt, RTX rechnet;
ein ausgeschalteter Worker braucht eindeutigen Offline-/Queue-Zustand statt
unbegrenzter Retries oder ungenehmigtem Cloud-Fallback.

| Familie | Kern / optionale Varianten | Migration ohne Datenverlust |
|---|---|---|
| Runtime/Gateway | Ollama + bewusst konfigurierter LiteLLM; OpenClaw getrennt vom Host-Admin | Bestehende Ports/UIDs/Modelldaten inventarisieren; keine zweite Runtime am selben Port starten |
| Image_Generation / Image_Generation_Studio / Visual_Creator | Gemeinsamer Medienkern, Varianten fuer Bild, Video und externe Dienste | Keine identischen Aliase: Fooocus/InvokeAI versus GFPGAN/Rembg und unterschiedliche SD-/Video-/API-Pfade. Erst Vereinigungs-/Differenzmatrix; Legacy-IDs als deprecated-Kandidaten, nicht ungefragt entfernen |
| Security_Analyst / Security_DevSecOps / Ethical_HackerGPT | Defensiver Offline-Kern, gesondertes autorisiertes Auditprofil | Security_Analyst fehlt als Registry-ID; Ethical-Hacker-Opt-in/Allowlist erhalten. Kein Angriffsscan als Default; keine blinde Umleitung auf DevSecOps |
| Coding | Aider, OpenHands, Continue, Claude/Qwen/Gemini als getrennte Clients | Eigene Repos/Profiles/Secrets, kein gemeinsamer Admin-Home-/Docker-Socket-Zugang |
| RAG | Erst eine Vector-DB, Postgres nur wenn benoetigt | Keine automatische Qdrant-/Chroma-/pgvector-Migration; eigene Export-/Import-/Restore-Abnahme |
| Observability | Ein Collector und ein Logpfad; Tracing optional | Kein paralleler Vollstack aus Prometheus, Netdata, Alloy, OTel, Tempo, Jaeger und zwei LLM-Tracern als Default |

Konkrete Registry/Installer-Abweichungen: Studio nennt ControlNet nicht,
[Installer](../../scripts/profiles/Image_Generation_Studio_install.sh):5 installiert es.
[DevSecOps](../../scripts/profiles/Security_DevSecOps_install.sh):5 und Registry
weichen bei CrowdSec/UFW versus Grype/Syft/Fail2Ban ab.
[Ethical_HackerGPT](../../scripts/profiles/Ethical_HackerGPT_install.sh):112
installiert Pakete trotz defensivem Default/ENABLED=false; dieser Schalter ist
kein genereller Nicht-Installieren-Schalter.
Der [Aliascheck](../../scripts/check_profile_registry_sync.sh):33,87-100 warnt
bereits, implementiert aber keinen verbindlichen Migrationsresolver.

Vorgeschlagene Hierarchie in einer spaeteren PR:
Kernprofile `base`, `runtime-local`, `gateway-local`, `backup-local`;
Optionen `rag-qdrant`, `ui`, `monitoring-light`, `voice-local`, `documents`;
experimentell `gpu-heavy`, `agent-browser`, `cluster-ha`, `security-lab`.
Das sind **Zielnamen**, keine bereits installierbaren neuen Profil-IDs.

## 4. Lifecycle und Doctor-Vertrag

Jedes installierbare Tool benoetigt einen versionierten Vertrag mit:
install, check, healthcheck, smoke-test, version, logs, uninstall und update/repair.

| Aktion | Vertrag |
|---|---|
| install | Plan vor Mutation; Voraussetzungen/Pins/Reserve, eigene Sperre, aktuelles Log, Erfolg erst nach Artefaktpruefung |
| check | Readonly, lokal, kein Download/Start; installierte Identitaet/Version statt beliebigem Marker |
| healthcheck | Separates opt-in; Liveness, Readiness und benoetigte Abhaengigkeiten getrennt |
| smoke-test | Default Offline-Fixtures; echte lokale Inferenz nur nach Auswahl, Cloud nur mit erzwungenem Budget/Turn-/Retry-Limit und Zustimmung |
| version | Gepruefte Binary, keine Bazelisk/Corepack/Npx-Shim-Nachinstallation durch --version |
| logs | Aktueller Versuch/Tool/Phase/Exit-Code, redigiert; keine env-/Tokenausgabe oder globalen alten Logs als aktuelles Ergebnis |
| uninstall | Inventar-/Besitzpruefung, Referenzen geteilter Tools beachten; Daten/Secrets/Toolchains standardmaessig behalten |
| update/repair | Gleichen Pin idempotent pruefen; Pinwechsel separat reviewen; Backup/Restore und Datenmigration getrennt von Code-Rollback |

Doctor-Ziel: `--offline` fuer ShellCheck/shfmt, JSON/YAML, lokale Markdown-Links,
redigierten Secret-Scan, Compose config und gerenderte K8s-Schemata; benoetigte
Tools vorher bewusst bereitstellen, fehlende Tools als SKIP/Fehler ausgeben.
`--host` fuer RAM/Disk/WSL-Host/Ports; `--local-live` fuer begrenzte Loopback-
Probes. Kein automatisches npm/npx/pip/apt. Alle Ergebnisse sammeln, dann
Exitcode: 0 nur alle geforderten Checks bestanden, 1 Befund, 2 unvollstaendig.

Mindestens fuenf konkrete Beispiele:
[healthchecks.sh.example](../proposals/platform-review-2026-10-26/healthchecks.sh.example).
Default ist nur Plan; `--local-live` fuehrt begrenzte GETs ausschliesslich an
127.0.0.1 aus, ohne Browser, Modellgenerierung, Redirects, Proxy oder Credentials.
Ports sind Beispiele und muessen dem eigenen Portvertrag entsprechen.

| Dienst | Probe | Nicht dadurch belegt |
|---|---|---|
| Ollama | GET /api/tags | Modelle geladen, VRAM frei, Tokenleistung oder richtige Modelllizenz |
| OpenClaw | GET /healthz | Readiness/Autorisierung/Tools; /readyz fuer versionsgerechte Abnahme separat pruefen |
| LiteLLM | GET /health/liveliness | DB/Provider/Modelle; insbesondere kein /health-Modelltest als kostenlose Probe voraussetzen |
| Prometheus | GET /-/ready | Alle Targets/Rules/Alertzustellung korrekt |
| Grafana | GET /api/health | Login/RBAC und jede Datasource getestet |

Primaerquellen: [OpenClaw Health](https://docs.openclaw.ai/gateway/health),
[LiteLLM Health](https://docs.litellm.ai/docs/proxy/health),
[Prometheus Management](https://prometheus.io/docs/prometheus/latest/management_api/),
[Grafana Health](https://grafana.com/docs/grafana/latest/developers/http_api/other/).
Aktuelle Doku ersetzt nicht die Pruefung am jeweils installierten Pin.
Ollama-Dokupfad /api/version lieferte bei Recherche 404; /api/tags ist bereits
im lokalen Doctor enthalten. Kein Endpunkt gegen einen laufenden Dienst getestet.

## 5. Sicherheitsbaseline und Grenzen

Bereits vorhanden: Loopback-env-Beispiele, externe User-Daten, SOPS/Restic,
Default-Deny/PSS in k8s/base, Secret-Referenzen, Ressourcen/Probes, deaktivierter
ServiceAccount-Token-Mount und bestaetigte Deploymentpfade. Das darf durch
einen zweiten vermeintlichen Standard nicht unbemerkt ersetzt werden.

Beispiel fuer einen **neuen Staging-Namespace**:
[security-baseline.yaml.example](../proposals/platform-review-2026-10-26/security-baseline.yaml.example).
Namespace/PSS restricted, Default-Deny, begrenztes DNS, read-only Beobachter-
RBAC ohne Secrets/exec und Quota. Das SA-Token wird nicht automatisch gemountet;
explizite authentifizierte Beobachtung braucht einen separat freigegebenen Weg.
DNS-Labels/NodeLocalDNS und Kubernetes-Minor >=1.34 pruefen, nicht blind ausrollen.
Keine App-Kommunikation ist dadurch freigegeben: konkrete Gateway->Modell-/DB-
Flows erst nach Port-/Namespace-/Labelvertrag ergaenzen und negative Tests ausfuehren.

[workload-security.patch.yaml.example](../proposals/platform-review-2026-10-26/workload-security.patch.yaml.example)
zeigt non-root, Seccomp RuntimeDefault, Capabilities drop ALL, keine Privilege-
Escalation, read-only Root-FS und begrenztes /tmp. **Merge-Fragment, kein
allein deploybares Deployment.** UID/GID, Schreibpfade und Image muessen passen;
GPU-Workloads/Modell-PVCs benoetigen eigene getestete Ausnahmen.

NetworkPolicies brauchen einen durchsetzenden CNI. Pod-internes 0.0.0.0 ist
nicht automatisch eine oeffentliche Hostfreigabe. Fuer Hostdienste gelten
Loopback oder feste VPN-IP und explizite Firewallregeln; im Cluster ClusterIP,
kein unkontrollierter NodePort/hostNetwork/HostPort. Ingress 80/443 nur TLS/Auth,
Kubernetes API 6443 nur Control-/VPN-Netz. Ollama 11434, OpenClaw 18789, DBs,
Storage, Home Assistant 8123, ComfyUI 8188 und Whisper-HTTP-Pfade nicht ins WAN.
Alle Listener inklusive IPv6 und Tunnel-/Reverse-Proxy-Weiterleitungen testen.
Tailscale/WireGuard ersetzt keine Agentenberechtigung; Cloudflare-Tunnel braucht
Access-Policy/Origin-Absicherung, nicht bloss einen versteckten Port.

Quellen: [PSS](https://kubernetes.io/docs/concepts/security/pod-security-standards/),
[NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
Keine vorhandene Firewall oder Clusterpolicy wurde veraendert.

## 6. Fehlende Tools: gezielt statt neuer Vollstack

Vorhanden meint Registry/Installer oder Baseline, nicht laufend/funktional abgenommen.
Ressourcenklasse ist ein Planungsbudget: L ca. 0,1-0,5 GiB RAM, M ca. 0,5-2 GiB,
H mehrere GiB bzw. modell-/datenabhaengig. **Keine Hersteller-Minimalanforderungen.**
Speicher, Retention und Last sind auf Staging zu messen; CPU/ARM/GPU nicht gleichsetzen.
Keine dieser Empfehlungen fuehrt eine Installation aus.

| Tool / Quelle | Ist / Prio | Nutzen / Alternative | Ressourcenplanung | Sicherheitsrisiko / Integrationspfad | Default-Ziel |
|---|---|---|---|---|---|
| [OTel Collector](https://github.com/open-telemetry/opentelemetry-collector) | planned / P1 | Ein Telemetrie-Eingang statt vieler Agents; alternativ Alloy | L-M mit Batch/Memory-Limiter | OTLP nur intern, Prompts/Keys redigieren, Exportziele allowlisten | Standard optional, Production nach Abnahme |
| [Loki](https://github.com/grafana/loki) | Installer vorhanden / P1 | Zentrale Logs; alternativ journald auf Minimal | M-H nach Retention | Personen-/Tokeninhalte, ungeschuetzte Push-API; eigener Datenpfad | Standard optional |
| [Tempo](https://github.com/grafana/tempo) | kein eigener Registry-Eintrag / P2 | Tracebackend fuer OTel; alternativ Jaeger | M-H | Sampling/Retention/PII; nur mit echtem Tracebedarf | experimentell |
| [Jaeger](https://github.com/jaegertracing/jaeger) | kein eigener Registry-Eintrag / P2 | Alternative zu Tempo, nicht parallel als Default | M-H | Ingest/UI privat; Abhaengigkeiten separat | optional |
| [Langfuse](https://github.com/langfuse/langfuse) | Installer vorhanden / P1 | LLM-Traces/Promptversionierung/Evals; alternativ Phoenix | H inklusive benoetigter Backends | Traceinhalte koennen Secrets enthalten; Versions- und DB/Storage-Vertrag pruefen | optional, nicht Minimal |
| [Phoenix](https://github.com/arize-ai/phoenix) | kein eigener Registry-Eintrag / P2 | Alternative fuer LLM-Observability, nicht Doppelung | M-H | Gleiches PII-/Auth-Risiko, eigenes Probe-/Persistenzprofil | optional |
| [KEDA](https://github.com/kedacore/keda) | kein eigener Registry-Eintrag / P2 | Queue-basierte Skalierung statt CPU-allein | L-M plus Worker | Operator-RBAC, min/max/Queuebudget; weckt keine physisch ausgeschaltete GPU von selbst | experimentell, nach messbarer Queue |
| [Kyverno](https://github.com/kyverno/kyverno) | kein eigener Registry-Eintrag / P1 | Zulassungsregeln/Images; alternativ Gatekeeper | M | Webhook-Ausfall, Ausnahmen/GitOps; erst Audit, dann Enforce in Staging | Production-Kandidat |
| [OPA Gatekeeper](https://github.com/open-policy-agent/gatekeeper) | kein eigener Registry-Eintrag / P2 | Alternative bei Rego-Kenntnis | M | Dieselben Admission-/Ausnahmerisiken | nicht zusaetzlich zu Kyverno |
| [Falco](https://github.com/falcosecurity/falco) | planned / P2 | Runtime-Signale, kein praeventiver Sandbox-Ersatz | M plus Kernelanforderungen | Privilegien/eBPF/Kernel, WSL/ARM eigens pruefen | gezielt optional |
| [Renovate](https://github.com/renovatebot/renovate) | planned / P1 | Updates als PR statt automatischem main-Upgrade | CI-Budget | Schreibrechte/Token nur benoetigt; kein Autodeploy/Auto-Merge von Modellen/Schemawechseln | Wartungsdienst optional |
| [Cosign](https://github.com/sigstore/cosign) | planned / P1 | Signatur/Identitaetspruefung fuer eigene Artefakte | CI L-M | Issuer/Subject/Trust Root pruefen, Signatur allein kein Sicherheitsbeweis | Production-Gate |
| [Syft](https://github.com/anchore/syft) | experimental / P1 | SBOM je GitHub-Build/OCI-Artefakt | CI M | SBOM kann interne Pfade verraten; redigierte Artefakte | Release-Gate |
| [Grype](https://github.com/anchore/grype) | stable deklariert / P1 | CVE-Pruefung zur SBOM; alternativ Trivy | CI M, DB-Disk | DB-Alter dokumentieren, befristete Exceptions statt Fehlerunterdrueckung | Release-Gate |
| [pgBackRest](https://github.com/pgbackrest/pgbackrest) | kein eigener Registry-Eintrag / P1 bei Postgres | WAL/PITR statt heisser Rohdateikopie | M plus WAL/Backup-Disk | DB-/Objektstore-Rechte; versionierter Restoretest | Production-DB optional erforderlich |
| [Restic](https://github.com/restic/restic) | vorhanden / P1 | Verschluesselter Transport/Versionen, kein DB-Konsistenzzauber | CPU/Disk nach Daten | Separates Ziel/Passwort, Restore verifizieren; pgBackRest-/Qdrant-Snapshots danach sichern | Standard/Production |
| [promptfoo](https://github.com/promptfoo/promptfoo) | experimental / P1 | Prompt-/Routing-Regressionen; alternativ eigene Fixtures | CI M plus Inferenz | Default nur Mocks, echte API erst nach Budget/Opt-in; kein Redteam gegen Fremdziele | optionales Quality-Gate |
| [Aider](https://github.com/Aider-AI/aider) | vorhanden / P2 | Schlanker separater Coding-CLI-Pfad | Modellabhaengig | Patch-/Command-Freigaben und getrennte Credentials | optional |
| [OpenHands](https://github.com/OpenHands/OpenHands) | vorhanden / P2 | Isolierte Coding-Aufgaben statt Host-Admin-Agent | H | Sandbox-/Runtimevertrag, kein globaler Docker-Socket; kein Docker-freies Komplettpaket unterstellen | experimentell |
| [Continue](https://github.com/continuedev/continue) | vorhanden / P2 | IDE-Pfad statt zweitem Server | L-M plus Modell | Workspacezugriff/Telemetry/Cloud bewusst konfigurieren | optional |
| [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) | experimental / P2 | Dokumentablage/OCR; nicht PDF-Editor-Ersatz | M-H fuer OCR | Dokumente/Exports/Backups sensibel, eigener User/Datenpfad | optional |
| [Stirling PDF](https://github.com/Stirling-Tools/Stirling-PDF) | experimental / P2 | PDF-Verarbeitung; ergaenzt Paperless | M-H | Unvertrauenswuerdige PDFs isolieren, Uploadlimits/Timeouts, keine offene UI | optional |
| [Syncthing](https://github.com/syncthing/syncthing) | vorhanden / P2 | Datei-Sync zwischen eigenen Geraeten | Datenabhaengig | Sync repliziert auch Loeschungen, ist kein Backup; GUI nur lokal/VPN | optional |
| [Rclone](https://github.com/rclone/rclone) | vorhanden / P2 | Gezielter Export ins Backupziel; alternativ Restic direkt | Datenabhaengig | Remote-Credentials, sync/delete getrennt von copy; Dry-Run vor Mutation | optional |
| [Whisper.cpp](https://github.com/ggml-org/whisper.cpp) | vorhanden / P2 | Lokales STT auf CPU/ARM; alternativ faster-whisper | Modellabhaengig | Aufnahmen schuetzen, Modelle bewusst laden, API nicht oeffentlich | optional lokal |
| [faster-whisper](https://github.com/SYSTRAN/faster-whisper) | vorhanden / P2 | GPU-/CPU-STT mit eigenem Pythonvertrag | Modell/GPU-abhaengig | Keine zweite unkontrollierte CUDA-/Python-Laufzeit | optional |
| [Piper](https://github.com/OHF-Voice/piper1-gpl) | Legacy-Quelle rhasspy/piper im Registry-Eintrag / P2 | Lokales TTS statt Cloud-TTS | Stimme/CPU-abhaengig | Nachfolgeprojekt/Lizenz und Stimmenrechte getrennt pruefen, kein stiller Repo-Austausch | optional; Migrations-PR |

Die Quellen belegen den jeweiligen Projektzweck, nicht die Installierbarkeit
auf allen Zielgeraeten. Fuer neue Installer erst GitHub-Pin/Lizenz/Buildvertrag,
Linux/ARM-Pruefung, Check/Health/Uninstall und getestete Ressourcen erfassen.
Primare Hosttools bleiben GitHub-Source-Builds; apt nur Dependencies, gepruefte
Buildwerkzeug-Ausnahmen weiterhin offen kennzeichnen. Keine neuen Docker-Fallbacks.
K3s verwendet trotzdem OCI-Workloads: eigene Images aus freigegebenem Source-Pin
bauen/signieren; bestehende Compose-Beispiele sind ein anderer, optionaler Pfad.

Promtail ist laut [Grafana](https://grafana.com/docs/loki/latest/send-data/promtail/)
seit **02.03.2026 EOL**. Kein neuer Default; Alloy/anderer gepflegter Collector
mit vorhandener Logkonfiguration parallel pruefen, nicht ungefragt deinstallieren.

## 7. Minimal, Standard und Production

Planungsziele, keine garantierten Modell-/Hardware-Minima:

| Pfad | Voraussetzungen / Reihenfolge | Validierung und Rueckweg | Grenzen |
|---|---|---|---|
| Minimal | Ubuntu/WSL, z.B. 2 CPU/8 GiB plus Modell-Disk; Base -> ein lokaler Ollama-Pfad -> einzelner Client | Offline-/Port-/Hostcheck, dann bewusst kleiner lokaler Modelltest; private Konfiguration/Inventar exportieren, alten Pin erhalten | Keine Cloud-Keys, kein K3s/DB/Tracing-Zwang; WSL-Host-Disk begrenzt grosse Builds |
| Standard | Z.B. 4 CPU/16 GiB fuer Control/App plus eigener Modell-/GPU-Worker; Base -> VPN -> Ollama -> LiteLLM -> OpenClaw -> eine RAG-DB -> Monitoring/Backup | Loopback/VPN/Auth/Negativtests, eigene Service-UIDs, wiederholte Installation ohne Mutation, verschluesselter Restore auf separatem Ziel | Kein HA-Versprechen, keine drei Vector-DBs oder unkontrollierte Cloud-Fallbacks |
| Production | Abgenommene Ubuntu-24.04-VM, K3s-/CNI-/Storagevertrag, getrenntes Staging, externe Backups, GitOps/Secrets, Messbudgets | Exakte Digests/SBOM/Signaturen, Restorebeleg, Netz/RBAC/PSS, Rollout/Negativtests, Freigabe je Commit/Artefakt; erst dann kontrolliertes Apply | Single K3s-Server/PVC-local-path ist nicht HA; GPU-PVC/WoL/ARM und Schemawechsel separat |

Ollama-Modellcache als persistentes Volume; keine Modell-Pulls auf jedem Start.
`num_ctx`, parallele Anfragen, KV-Cache und keep_alive an gemessene RAM/VRAM-
Budgets binden; 16 GiB VRAM ist kein universelles Freigabekriterium fuer ein
bestimmtes Modell. Kalte/grosse Modelle bekommen Startup-Probes, nicht haeufige
Liveness-Neustarts wegen langer Inferenz. KEDA/HPA ohne spare GPU erhoeht Kapazitaet nicht.

Backups: keine laufenden Postgres-Rohdateien blind mit Restic sichern. Die
vorhandene [Wartungsbackup-Logik](../../scripts/backup_stateful_services.sh)
setzt bereits separates Ziel, sichere env-Datei und Downtime-Freigabe voraus.
Fuer Online-Backup pgBackRest/WAL oder geeignete konsistente Snapshots, fuer
Qdrant eigene Snapshot-/Restore-API und fuer Chroma/MinIO versionsgerechten
Konsistenzvertrag festlegen. [Postgres-Hinweise](https://www.postgresql.org/docs/current/backup-file.html).
RPO/RTO erst nach Restore-Messung festlegen; Modellgewichte ggf. durch gepinnte
Manifeste reproduzieren statt jedes grosse Gewicht taeglich doppelt zu kopieren.

## 8. PR-Reihenfolge und betroffene Dateien

| PR | Prio / konkrete Dateien | Akzeptanzkriterium |
|---|---|---|
| 0 | Dieser Report, Vollmatrizen, neuer readonly platform_inventory.py und dessen Tests | Vollstaendige 385/245 Registry-Zeilen, keine Mutation/Runtime-Probes; heute umgesetzt |
| 1 | P0: scripts/llmops_platform_config_manager.sh, neuer scripts/quality/stack_security_preflight.py, stacks/llmops-platform/.env.example und Compose | Leere/Platzhalter-Secrets blockieren; Least-Privilege-env; Beispielwerte nie als produktive Freigabe akzeptieren |
| 2 | P0: scripts/profiles/*_uninstall.sh, scripts/lib/profile_dependencies.*, config/profile_aliases.* | Gemeinsame Tools/Nutzdaten bleiben; Dry-Run; Alias-Konflikte statt doppelter Loeschung; Fehler loeschen keinen Profilmarker |
| 3 | P1: config/tools.yml / profiles.yml, Lifecycle-Schema und scripts/doctor.sh | Alle neuen Tools mit 7 Aktionen; Altlasten transparent; Offline Doctor ohne Netz/Paketdownload und mit aggregiertem Exitcode |
| 4 | P1: .github/workflows/ci.yml / repo-health.yml / test-install-scripts.yml, Lint-/Scan-Pins | Einheitliche Required Checks, fehlender Scanner blockiert Freigabe, keine Fehlerunterdrueckung fuer neue Security-Gates, keine Prod-Secrets auf PR-Runnern |
| 5 | P1: scripts/operations/deploy_vps_baseline.sh, k8s/overlays/staging und production | Artefakt-/Staging-/Restorebelege an Commit/Digest binden; Inputs nicht bloss per Boolean abnicken; kein generisches Produktions-Apply aus PR |
| 6 | P1: k8s/base/litellm.yml, NetworkPolicies, Secrets-Rotation, monitoring/ | Config-Rollout, Auth/Negativtests, alertbare SLOs, Wartungsfenster oder gemessenes HA |
| 7 | P1: backup_stateful_services.sh / Restore-Runbook / pgBackRest-Kandidat | Verschluesselter externer Restore erfolgreich, RPO/RTO und Schema-Rollback pruefbar |
| 8 | P2: readme.md, docs/START_HERE.md, Docs-Archiv, optionale Tool-Integrationen | Root-README <=150 Zeilen, alte Links/IDs weiter erreichbar, keine zusaetzlichen ungeprueften Defaults |

Neue Dateinamen mit Stern/Platzhalter in dieser Tabelle sind **PR-Vorschlaege**,
keine bereits existierenden Dateien. Produktionspfade und Registry wurden in
diesem Auftrag nicht entsprechend umgebaut.

Beispiel-Workflow: [ci-gate.yml.example](../proposals/platform-review-2026-10-26/ci-gate.yml.example).
Liegt absichtlich nicht in .github/workflows: fehlende gepruefte Lint-/Scan-
Werkzeuge fuehren zum Fehler, nicht zu automatischem Download. Die Vorlage
braucht vor Aktivierung ein freigegebenes GitHub-basiertes CI-Toolset.
Manifest-Schemavalidierung kann externe Schemas abrufen; fuer wirklich offline
muessen Schema-/Policy-Bundles vorher geprueft lokal bereitliegen.
Das production-hold endet bewusst mit Fehler, bis echte Staging-/Restore-
Nachweise implementiert sind; kein vermeintlich fertiger Deploy-Workflow.

## 9. Staging- und Produktionsflow

1. PR auf unprivilegiertem gehostetem Runner: Lint/Registry/Links/redigierte
   Secrets/Schema/Offline-Fixtures, keine Fork-Secrets und keine Cloud-Inferenz.
2. Freigegebenen Source-Commit bauen, SBOM erzeugen, Artefaktdigest und passende
   Signaturidentitaet verifizieren. Downloads/Baurechte/Budgets vorher festlegen.
3. Nur diesen Digest in isoliertem Staging deployen; keine produktiven Keys,
   Volumes oder Accounts. Zweite Installation muss idempotent sein.
4. Auth/Ingress/RBAC/PSS/CNI-Negativtests, RAM/VRAM/Disk, Alerts, Restore und
   explizit freigegebene lokale Evals ausfuehren. Kein Produktionsscan als CI-Test.
5. Nachweis enthaelt Commit, Artefaktdigests, Umgebung, Zeit/Geltungsdauer,
   Pruefresultate und signierte Herkunft. Ein benutzereditierbares passed=true
   oder eine lokale Datei ohne Vertrauensanker genuegt nicht.
6. Geschuetzte Production-Umgebung mit manueller Freigabe; Vorgaengerdigest und
   verifizierter Datenbackup vorhalten. Kubernetes-Apply serverseitig bleibt
   eine produktionskritische Aktion und ist kein nebenwirkungsfreier Check.
7. Readiness/Rollout, begrenzter Service-Smoke und SLOs pruefen; bei Fehlern
   Apply stoppen. Code zurueckrollen nur bei kompatiblem Datenschema, sonst
   getesteten Restore-/Migrationspfad nutzen. Keine automatischen PVC-Loeschungen.

## 10. README-Struktur und Datenmigration

Zielbudget Root-README **120-150 physische Zeilen**, ausfuehrliche Inhalte
vorher unter docs/archivieren. Vorgeschlagene Struktur mit Zeilenbudget:

| Abschnitt | Budget |
|---|---:|
| Zweck, Reifegrad und Sicherheitswarnung | 15 |
| Architektur (ein Textdiagramm) | 15 |
| Minimal/Standard/Production-Auswahl | 20 |
| Voraussetzungen und sichere Offline-Pruefung | 20 |
| Setup-Plan / bewusste Installation | 15 |
| Betrieb/Update/Backup/Restore/Uninstall als Runbook-Links | 20 |
| Troubleshooting und Staging-/Freigabegrenzen | 15 |
| Beitragen/Quellen/Lizenz | 10 |
| Gesamtziel | 130 |

Nicht jetzt die lange README abschneiden: alte Anker, externe Links und
Historie zuerst kartieren; neue Einstiegsseite verlinken, dann Archiv und
Kompatibilitaetsanker. Ein Benutzer-Backup ist keine Repo-Sicherheitskopie.

Migration je bestehender Installation:

1. Nur lesendes Inventar/Plan exportieren; installierte Programme, Versionen,
   Datenpfade, UID/GID, Ports und Profilreferenzen separat verifizieren.
2. Installationsstatus plus verschluesselte ENV-/API-Key-Backups gesondert
   exportieren; Entschluesselung/Restore in isoliertem Ziel pruefen.
3. Alte IDs/Marker/Dateien erhalten; schema-versionierte Aliaszuordnung mit
   Konfliktmeldung statt stiller Umbenennung. Keine Rekonstruktion geloeschter
   Programme nur aus einer Statusliste.
4. Neue Profile parallel auf getrennten Pfaden/Ports vorbereiten; keine
   bestehenden Daten oder Secrets ueberschreiben. Besitzer gemeinsam genutzter
   Tools erfassen, automatisches Entfernen standardmaessig deaktivieren.
5. Nach Staging-/Restorebeleg Umschalten mit Wartungsfenster; altes Inventar
   und Runtime fuer vereinbarten Rueckweg behalten. Erst spaeter explizites Cleanup.
6. ~/.openclaw_ultimate_user_data bleibt ausserhalb von Git; kein rm/reset/
   automatisches Rotieren privater Daten. PAT weiterhin ohne Token-in-URL.

## 11. Lieferumfang und noch offene Abnahme

Umgesetzt wurden Report, vollstaendige Metadatenmatrizen, readonly Reporter,
Offline-Fixtures und inaktive Vorschlagsdateien. Keine schweren Toolchains,
Modelle, neuen Cloud-Anbindungen, Registry-Umbauten oder produktiven Deployments.
Die Beispiele sind keine Sandbox und kein getesteter Produktionsstack.
Pruefergebnis dieses Auftrags: 22 Tests fuer neue Inventar-/Vorschlags-Fixtures und
bestehende Lifecycle-Inventar-Fixtures bestanden; statischer Codecheck ohne Fehler
oder Hinweise. Bash-Syntax und lokale Links/Tabellen
geprueft. YAML-Parser, Docker und kubeconform waren hier nicht verfuegbar;
keine vollstaendige YAML-/Kubernetes-Schemavalidierung oder CI-Ausfuehrung behauptet.
Ubuntu-24.04-VM-/ARM-/GPU-/CNI-/Restore-Abnahme und echte Health-/Inferenztests
bleiben offen. Der Sicherheitsreview ist begrenzt und kein formaler Penetrationstest.
