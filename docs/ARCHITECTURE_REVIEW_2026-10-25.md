# Architekturreview: Hybrid-VPS, Kubernetes, Ollama und OpenClaw

Stand **25.10.2026**, lokal gepruefter Commit `a0d9afd3e9655052be17de2acf2ff08710c5b262`;
Arbeitsbaum zu Beginn sauber. Die oeffentliche Repository-Seite wurde konsultiert. Remote-main wurde
weder abgerufen noch als identisch bestaetigt. Massgeblich fuer Codebelege ist dieser lokale Commit.
Keine Produktionsfreigabe und keine bereits umgesetzte Roadmap.

## Ergebnis und Pruefgrenzen

**Das Repository ist ein umfangreicher modularer Werkzeugkasten mit brauchbarer Produktionsvorlage,
aber noch kein durchgaengig abgenommener Produktionspfad.** Wesentlich ist nicht, weitere Tools
wahllos hinzuzufuegen, sondern bestehende Schutzregeln in allen unterstuetzten Betriebswegen
verbindlich zu machen.

Geprueft: ausgewaehlte Host-Installer/Deinstaller, Ansible-Bootstrap, Kustomize- Basis und
Produktions-Overlay, beide Compose-Pfade, Gateway-Konfiguration, Monitoring, Backup, CI und passende
Fixtures. Nicht alle Tool-Installer oder Shell-Dateien vollstaendig auditiert. Keine realen Secrets,
Listener, Firewall- Zustaende, Cluster, Volumes oder User-Workspaces gelesen. Keine Installation,
Hardwareaktion, Cloud-Inferenz, Modellabfrage oder Remote-Mutation ausgefuehrt. Historische Befunde:
[24.10.](AUDIT_2026-10-24.md), [23.10.](AUDIT_2026-10-23.md).

## Priorisierte Befunde

P0 = vor riskanten Lifecycle-/Datenaktionen; P1 = vor Produktionsbetrieb; P2 = nach stabiler
Abnahme. Schwere bezieht sich auf Codepfade, nicht auf nachgewiesene Kompromittierung oder
oeffentlich laufende Dienste.

| ID / Prioritaet       | Datei-/Zeilenbeleg                                                                                                                         | Problem und Auswirkung                                                                                                                                               | Konkreter Vorschlag                                                                                                                   |
| --- | --- | --- | --- |
| AR25-01 / P0 kritisch | [OpenClaw-Uninstall:23](../scripts/tools/openclaw_uninstall.sh#L23), [Entfernen:98](../scripts/tools/openclaw_uninstall.sh#L98)            | ENV-bestimmtes Verzeichnis wird rekursiv mit sudo geloescht, ohne engen kanonischen Besitz-/Pfadnachweis.                                                            | Root/Home/fremde Ziele/Symlinks ablehnen; private Installationsmarker, Dry-run, Daten standardmaessig erhalten.                       |
| AR25-02 / P0 hoch     | [Ollama-Uninstall:26](../scripts/tools/ollama_uninstall.sh#L26)                                                                            | Modell-/Servicedaten werden ohne getrennte Datenfreigabe entfernt.                                                                                                   | Programm und Daten trennen; kein automatisches Purge, gesonderte Backup-/Pfadabnahme.                                                 |
| AR25-03 / P0 hoch     | [ENV-Manager:57](../scripts/llmops_platform_config_manager.sh#L57), [Kopieren:71](../scripts/llmops_platform_config_manager.sh#L71)        | ENV landet im Repo-Stack ohne expliziten 0600-/atomischen Schreibvertrag; vorhandene Werte werden ersetzt.                                                           | Externer User-Workspace, sichere atomische Ausgabe, Symlinkschutz und ausdrueckliches Replace.                                        |
| AR25-04 / P1 hoch     | [Compose:6](../stacks/llmops-platform/docker-compose.yml#L6), [Fallback:17](../stacks/llmops-platform/litellm-config.yaml#L17)             | Mehrere Dienste erhalten dieselbe ENV; lokaler Ausfall routet automatisch in Cloudanbieter. Potenzieller Secret-/Datenabfluss und Kosten.                            | Dienstbezogene Secret-Allowlist; Cloud aus im Standard, explizites Opt-in, Budget und Retry-Gates. YAML-ENV-Aufloesung am Pin testen. |
| AR25-05 / P1 hoch     | [OpenClaw-Build:31](../scripts/tools/openclaw_install.sh#L31), [pnpm:46](../scripts/tools/openclaw_install.sh#L46)                         | Bewegliche Quellen und nicht explizit frozen Dependencies; Build erzeugt keine dedizierte abgesicherte Gateway-Runtime.                                              | Commit/Lockfile-Vertrag plus eigener Non-Root-Runtime-Pfad, zugelassene Tools, geschuetzte Credentials und Netzwerkgrenzen.           |
| AR25-06 / P1 hoch     | [Ollama:26](../scripts/tools/ollama_install.sh#L26), [K3s:7](../scripts/tools/k3s_install.sh#L7)                                           | Direktes Remote-Skript in Shell; kein lokal gepruefter fester Inhalt an diesen Aufrufen.                                                                             | Gepinnter GitHub-Source-/Artefakt-Vertrag, Download und Integritaetspruefung vor Ausfuehrung; Service-Aktivierung separat.            |
| AR25-07 / P1 hoch     | [Compose-Images:3](../stacks/llmops-platform/docker-compose.yml#L3), [Netdata:128](../stacks/llmops-platform/docker-compose.yml#L128)      | Mutable Images, fehlende gemeinsame Ressourcen-/Healthcheck-Haertung; Netdata mit SYS_PTRACE und AppArmor unconfined.                                                | Digests, kompatible SecurityContexts und Limits pro Dienst; privilegiertes Hostmonitoring nur explizit opt-in.                        |
| AR25-08 / P0 hoch | [Backup:16](../scripts/operations/backup_run.sh#L16), [Erfolg:29](../scripts/operations/backup_run.sh#L29) | Beide rsync-Fehler werden mit `\|\| true` unterdrueckt; trotzdem Erfolgsmeldung. Andere Workspace-Secrets koennen unverschluesselt in der Kopie liegen. | Fehler propagieren, Teilbackup markieren, 0700/0600 und Verschluesselung vor Export; Restore pruefen. Nicht mit dem neueren Restic-Skript verwechseln. |
| AR25-09 / P1 hoch     | [Restic:75](../scripts/backup_stateful_services.sh#L75), [Abschluss:133](../scripts/backup_stateful_services.sh#L133)                      | Guter manueller Compose-Offline-Backupweg deckt nur drei Datendienste ab; kein OpenClaw-/K3s-/PVC-Gesamtbackup oder verifizierter Zeitplan.                          | Getrennte Backupklassen mit Locks, Scheduler, Fehleralarm, Offsite und echten Restore-Tests.                                          |
| AR25-10 / P1 mittel   | [Prometheus:5](../monitoring/prometheus.yml#L5), [Alarme:1](../monitoring/alerts.yml#L1), [Stack:12](../docker-compose.monitoring.yml#L12) | Scrape-Platzhalter, optionaler Node-Exporter, kein Alertmanager im Stack und keine `alerting`-Zielkonfiguration in Prometheus. GPU-/Pod-/Gateway-Alarme fehlen dort. | Echte Targets plus Alertmanager/Receiver, GPU-/Pod- und Blackbox-Metriken, synthetischen Alarm zustellen lassen.                      |
| AR25-11 / P1 mittel   | [Policy:65](../k8s/base/network-policy.yml#L65), [Traefik:1](../k8s/platform/traefik-values.yml#L1)                                        | Policy erwartet Traefik in `traefik`, nicht automatisch den K3s-Controller in kube-system; sonst fehlen Zugriffswege. OpenClaw-Clientfreigabe ist nicht enthalten.   | Einen Controllervertrag waehlen; Namespace und Labels synchronisieren; gezielte Client-/Scrape-Regeln mit Negativtests.               |
| AR25-12 / P1 mittel | [UFW:34](../scripts/security/setup-ufw.sh#L34), [Audit:8](../scripts/security/firewall_audit.sh#L8) | Vorhandene Allow-Regeln werden nicht bereinigt; Statusabfrage mit `\|\| true` ist kein verbindlicher Compliance-Test. UFW allein belegt keine Container-Portgrenze. | Ist/Soll-Regeln und IPv4/IPv6/Provider-Firewall pruefen, Ausnahmen melden, Admin-Rueckweg vor Apply sichern. |
| AR25-13 / P1 mittel   | [CI:36](../.github/workflows/ci.yml#L36), [Render:39](../.github/workflows/test-install-scripts.yml#L39)                                   | Teile der CI weichgeschaltet; Kustomize-Rendering ohne dortigen Schema-/Policy-Gate. Scanner sind aber bereits vorhanden.                                            | Verbindliche, gepinnte Checks fuer Schema/Policies und Secrets; Branch Protection separat nachweisen.                                 |

## Architektur und Betriebswege

| Weg                     | Vorhandene Eigenschaften                                                                                       | Abnahmegrenze                                                                                                      |
| ----------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Host / GitHub           | OpenClaw nach /opt/openclaw, Ollama- und K3s-Installer, WireGuard-/UFW-/Fail2ban-Skripte                       | Unterschiedliche Lifecycle-Vertraege; kein aus dem Build ableitbarer sicherer Gateway-Daemon                       |
| Aelterer LLMOps-Compose | LiteLLM, WebUI, Qdrant, Postgres, Redis, MinIO, Langfuse und Monitoring-Dienste; publizierte Ports an Loopback | Breiter Secret-Scope, mutable Images; Redis ohne Persistenzmount, nicht als persistenter Datenbestand voraussetzen |
| Kustomize-Baseline      | Nur Ollama und LiteLLM, eingeschraenkter Namespace, PVC, Probes, Default-Deny                                  | Keine vollstaendige Migration der Agenten-/Datendienste; absichtlich Platzhalterimages/-modell                     |
| Separates Monitoring    | Prometheus, Grafana, Loki, Alloy und opt-in Node-Exporter mit Limits/Loopback                                  | Externe Secret-Dateien, getestete Images/Targets und Alarmzustellung noch einzurichten                             |
| Ansible                 | Dedizierter Ubuntu-VPS, SSH-Key-only, nicht privilegierter llmops-Benutzer, UFW                                | Keine fertige Hybrid-/K3s-Rolle; Docker-Installation ist dort ausdrueckliche Infrastruktur-Ausnahme                |

Keine pauschale UID 1000 verwenden: die K8s-Basis setzt bereits UID/GID 10001
([Ollama:42](../k8s/base/ollama.yml#L42), [LiteLLM:48](../k8s/base/litellm.yml#L48)). Das ist ein
sinnvoller Entwurf, aber Kompatibilitaet und Volume-Rechte sind imagebezogen zu testen.
Systemd-/Container-Isolation ist nicht gleich Agenten- Sandboxing fuer beliebige
Shell-/Tool-Aufrufe. Die vorhandene
[Queue-Userunit](../scripts/systemd/openclaw-queue-worker.service#L5) ist kein fertiger gehaerteter
OpenClaw-Gateway-Dienst.

### Kubernetes, Persistenz und Verfuegbarkeit

- [Namespace](../k8s/base/namespace.yml#L1): Restricted-PSS, ResourceQuota und LimitRange vorhanden.
- [Ollama](../k8s/base/ollama.yml#L25): StatefulSet, eine Replik, RWO-PVC mit 50Gi, read-only
  Root-FS, Startup-/Readiness-/Liveness-Probes.
- [Production](../k8s/overlays/production/resources.yml#L9): GPU-Node-Selector und
  `nvidia.com/gpu: 1`, CPU/RAM/ephemeral-storage begrenzt.
- StorageClass/CSI und Reclaim-/Snapshot-/Backup-Vertrag sind nicht explizit festgelegt. Bei lokalem
  Node-Storage macht ein neuer Pod auf anderem Node die Modelldaten nicht automatisch verfuegbar.
  RWO ist kein HA-/Backupnachweis.
- Eine Ollama-Replik, eine GPU und ein einzelner Control-Node bleiben Ausfallpunkte. Ein PDB ersetzt
  weder einen zweiten geeigneten Worker noch Datensicherung.
- RKE2 wird nicht durch einen eigenen Installationspfad in den untersuchten Dateien belegt. K3s als
  Ziel zuerst stabilisieren statt parallel einen zweiten Kubernetes-Betriebsweg einzufuehren.

### Netzwerk und Gateway

`0.0.0.0:11434` [im Pod](../k8s/base/ollama.yml#L60) ist fuer den Service kein WAN-Beweis. Ollama
ist dort ein interner ClusterIP-Dienst mit Allowlist. Ein Binden an Pod-Loopback wuerde
Service-Zugriff verhindern. Auf dem Host dagegen Loopback oder gezielt gefilterte VPN-Adresse
verwenden; HostPorts, NodePorts, LoadBalancer, IPv6 und Provider-Firewall separat pruefen.

Die [OpenClaw-Vorlage](../scripts/config_templates/openclaw/config.json.template#L6) enthaelt
Loopback, ist aber kein Nachweis fuer das Konfigurationsschema oder die tatsaechliche
Authentifizierung einer installierten Upstream-Version. Der
[Ingress](../k8s/overlays/production/ingress.yml#L13) enthaelt TLS und VPN- Allowlist als Vorlage,
aber weder ausgestellte Zertifikate noch eine Rate-Limit- Middleware. Zuerst echten Pin,
Auth-Negativtest und VPN-Erreichbarkeit abnehmen. Keine Behauptung, das OpenClaw-Gateway sei hier
bereits oeffentlich oder root.

NetworkPolicies benoetigen ein sie durchsetzendes CNI und verschluesseln Verbindungen nicht. mTLS
ist bei zusaetzlichem Bedrohungsmodell optional, kein pauschaler Ersatz fuer VPN, API-Auth und
Toolrechte.
[Kubernetes NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
Tailscale-Exit-Nodes sind nicht automatisch erforderlich; fuer Adminzugriff nicht den gesamten
Internetverkehr unbeabsichtigt umleiten.

### Inferenz und Ressourcenplanung

Die Basis konfiguriert bereits
[Kontext 4096, Parallelitaet 1, ein Modell, Queue 16 und keep_alive 5m](../k8s/base/ollama.yml#L61).
Nicht blind Kontext oder Modellzahl erhoehen: Kontext und Parallelitaet vergroessern den
Speicherbedarf. `num_ctx` pro Anfrage und `keep_alive` koennen vom Client kommen; Gateway muss den
erlaubten Rahmen pruefen. [Ollama FAQ](https://docs.ollama.com/faq).

Eine GPU-Ressource ist keine frei waehlbare VRAM-GiB-Quote. Gleichzeitiges ComfyUI-/Wan-/LLM-Rechnen
auf der RTX benoetigt gemessene Speicherreserven und eine gemeinsame Admission-/Jobsteuerung;
Kubernetes-GPU-Limit allein begrenzt weder Agentenkosten noch alle nativen GPU-Prozesse.
CPU-/RAM-Limits verhindern OOM nicht allgemein. GPU-Treiber, Runtime und Device Plugin separat
validieren.

Modell-Warmup nur nach freigegebenem Download/Import: Modell-ID/Digest pruefen, kurze synthetische
Inferenz messen, dann bei Bedarf zeitlich begrenzt geladen halten. `/api/version` bestaetigt keinen
geladenen, antwortfaehigen Modellpfad. TTFT, Prefill/Decode, p95-Latenz, Queue, RAM/VRAM und
Cold-/Warmstart getrennt messen. Multi-Node-Routing erst nach Modellverfuegbarkeit und
Worker-Readiness aktivieren; Cloudfallback darf schlafende/offline GPU-Worker nicht still ersetzen.

## Priorisierte Patchpakete

Dies sind **Vorschlaege**, keine erstellten Remote-PRs oder aktivierten Dateien. Kein neues
Helm-Chart fuer denselben Kern parallel zur vorhandenen Kustomize-Basis.

| Phase / Paket         | Dateien aendern bzw. neu vorschlagen                                                                                         | Abnahmekriterium / Breaking Change                                                                                                                                                             |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1a Datenerhalt        | scripts/tools/openclaw_uninstall.sh, ollama_uninstall.sh, scripts/operations/backup_run.sh                                   | Fremde Pfade unveraendert, kein Purge als Standard; rsync-Fehler => Fehlerstatus. Semantik von Deinstallation aendert sich bewusst.                                                            |
| 1b Secrets            | scripts/llmops_platform_config_manager.sh, stacks/llmops-platform/docker-compose.yml, litellm-config.yaml                    | 0600/atomisch/external, keine fremden Dienstkeys, Cloud ohne Freigabe unmoeglich. Bisherige Fallback-Nutzer brauchen explizite Migration.                                                      |
| 1c Supply Chain       | scripts/tools/openclaw_install.sh, ollama_install.sh, k3s_install.sh                                                         | Quellpin/Lockfile/Integritaet vor Ausfuehrung; kein automatischer Dienststart. Source-Build-Regel und genehmigte Ausnahmen erhalten.                                                           |
| 1d Runtime / Netz     | neuer Vorschlag scripts/systemd/openclaw-gateway.service.example; scripts/security/setup-ufw.sh; k8s/base/network-policy.yml | Eigener User, geschuetzte Konfiguration, NoNewPrivileges, Capability-Drop und selektive Schreibpfade; ohne Auth 401/403, WAN-Direktports gesperrt. Nur Beispiele bis Pin-/Schemaabnahme.       |
| 2a Reproduzierbarkeit | ansible/vps_bootstrap.yml in kleine Rollen/Inventare erweitern; k8s/base und overlays/production konsolidieren               | Zweiter Lauf stabil; privates Overlay mit Image-Digests, festem Modell, CSI, Traefik-/cert-manager-Vertrag. Bestehende Host-/Compose-Installationen nicht still migrieren.                     |
| 2b GPU / WoL          | k8s/overlays/production/resources.yml, examples/k3s/gpu-node-labels.yaml, scripts/home-watcher/\*                            | Wake -> NodeReady -> GPU vorhanden -> Modell bereit -> Job; bounded Timeout, vor Schlaf Cordon/Drain. Kein unkontrolliertes Hochskalieren von GPU-Pods.                                        |
| 2c CI                 | .github/workflows/test-install-scripts.yml, ci.yml, secret-scan.yml, .pre-commit-config.yaml                                 | Gepinnte Shell-/YAML-/Schema-/Policy-/Secret-Pruefung, keine verdeckten Erfolgsmarker; echte isolierte Hooks und Required Checks testen.                                                       |
| 3a Telemetrie         | monitoring/prometheus.yml, alerts.yml, Dashboard; neue monitoring/alertmanager.yml.example und Blackbox-/GPU-Scrape-Vorlagen | CPU/RAM/Disk, Pod-Restarts/OOM, GPU/Temperatur/Power soweit Hardware erlaubt, TTFT/Latenz und Gateway-Verfuegbarkeit; Alarm am Empfaenger nachgewiesen.                                        |
| 3b Restore            | scripts/backup_stateful_services.sh; neue scripts/operations/backup_openclaw.sh.example und systemd-Timervorlage             | Getrennte verschluesselte Offsite-Ziele, Lock/Timeout/Fehleralarm, synthetische Restore-Probe; Erfolg erst nach fachlicher Lesbarkeit. Timer erst nach genehmigtem Wartungsfenster aktivieren. |
| Spaeter / P2          | optionaler GitOps-Controller, OTel, Admission-Policies und Runtime-Security                                                  | Ein Controller je Aufgabe; Telemetrie redigiert, Kernel-/Ressourcenvertrag und False-Positive-Betrieb getestet. Keine Sammelinstallation.                                                      |

## Fehlende beziehungsweise noch nicht abgenommene Bausteine

| Baustein                                                               | Nutzen / Prioritaet                         | Vorhanden vs. konkret offen                                                                                                                                 |
| ---------------------------------------------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gitleaks / Trivy                                                       | Secret-/Image-Gates, P1                     | Bereits CI/Tools vorhanden; Durchsetzung, History-Umfang und Rotation echter Altleaks separat pruefen. Keine erneute Secret-Historiensuche in diesem Audit. |
| [NVIDIA Device Plugin](https://github.com/NVIDIA/k8s-device-plugin)    | GPU-Scheduling, P1                          | Limits vorhanden; Installation, Treiber und echte Allokation im Lab offen                                                                                   |
| [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter)               | GPU-Metriken, P1                            | Im untersuchten Monitoringpfad nicht verkabelt; GeForce-/WSL-Unterstuetzung der gewaehlten Metriken zuerst pruefen                                          |
| [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) | Pod-/Deployment-Zustaende, P1               | Ergaenzt Node-Metriken; kein Ersatz fuer Kubelet-/cAdvisor-Nutzungsmetriken                                                                                 |
| [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)   | Private Gateway-/TLS-Verfuegbarkeit, P1     | Gezielte Probe-/Ziel-Allowlist, keine beliebigen Benutzer-URLs                                                                                              |
| Alertmanager                                                           | Alarmzustellung, P1                         | Regeln existieren; Receiver und End-to-End-Test fehlen im separaten Stack                                                                                   |
| Restic / Borg / Velero                                                 | Offsite-/PVC-Sicherung, P1                  | Restic-Pfad existiert; ein Verfahren je Datenklasse waehlen, Restore und Scheduler ergaenzen. Velero ersetzt keinen konsistenten DB-Backupvertrag.          |
| auditd / Dateiintegritaet                                              | Veraenderungen an Units/Config erkennen, P2 | Nur erlaubte Pfade, Regeln/Rotation/Datenschutz planen; kein Schutz vor voll privilegiertem Angreifer garantiert                                            |
| AppArmor / Seccomp                                                     | Runtime-Haertung, P1                        | RuntimeDefault in K8s vorhanden; Compose-Unconfined entfernen und natives Node-/Toolverhalten profilspezifisch testen                                       |
| OpenTelemetry / GitOps / Kyverno                                       | Traceability, Drift und Policies, P2        | Erst nach stabiler Baseline; nicht alle Alternativen gleichzeitig installieren                                                                              |

Fuer zusaetzliche Tools zuerst offizielle GitHub-Quelle, Commit/Version, Lizenz, Architektur und
Lifecycle festlegen. Keine Docker-Ausweichinstallation. Helm-/Container-Auslieferung im optionalen
Clusterprofil ist eine eigene Infrastrukturentscheidung und keine stille Aenderung der
Tool-Installationsregel. Promtail nicht neu als Standard einfuehren: seit 02.03.2026 EOL; Alloy ist
im Projekt bereits vorgesehen.
[Grafana-Mitteilung](https://grafana.com/docs/loki/latest/send-data/promtail/).

## Backup- und Topologieentscheidung

OpenClaw-State nicht mit einem Git-Checkout verwechseln. Das offizielle `openclaw backup create`
gibt es; vor Nutzung gegen den installierten Pin und dessen Help/DB-Backend pruefen. Archive koennen
Credentials enthalten: privates Staging und verschluesseltes Offsite, Restore in neues isoliertes
Ziel. Kein pauschales Sichern laufender Datenbanken per tar. Der dokumentierte Postgres-Weg kann ein
gestopptes Gateway verlangen. [OpenClaw Backup](https://docs.openclaw.ai/cli/backup).

K3s-Datastore, Server-Token und private Konfiguration benoetigen ein eigenes Recovery-Verfahren.
Default-SQLite und HA-etcd nicht gleich behandeln; ein sauberer Restore der drei
Compose-Datenverzeichnisse sichert den Cluster nicht. RPO/RTO erst nach gemessenem Restore nennen,
nicht aus Backupintervallen ableiten.

HE/Domain -> Oracle-Edge/Control -> WireGuard -> Pi/Mini-PC -> RTX bleibt ein sinnvolles Zielbild,
sofern Rollen getrennt werden. Kein etcd-Quorum ueber instabile WAN-/schlafende Nodes verteilen.
GPU-Worker duerfen schlafen, Control und State nicht ohne Verfuegbarkeitsplan. CNI-/MTU-/Routing-
und VPN-Regeln gegen die reale Topologie pruefen, Join-Tokens nur ueber geschuetzte Dateien.
[K3s-Netzanforderungen](https://docs.k3s.io/installation/requirements).

## Nachweise dieses Reviews

- Neu ausgefuehrt:
  `python -I -X utf8 -B -m unittest discover -s tests -p test_production_baseline.py -v`: 13
  ausgewaehlt, **7 bestanden, 6 POSIX-Backup-Mocktests unter Windows uebersprungen**.
- Code-/Zeilenbelege oben direkt aus dem geprueften lokalen Stand gelesen, nicht unveraendert aus
  alten Berichten uebernommen.
- Kein voller ShellCheck-/Schema-/Image-/Secret-Scan, kein Remote-CI-Nachweis, keine Hook-Downloads,
  keine Live-Ports oder GPU-/Restore-Messungen.
- Keine Aussage, dass installierte Programme oder aktuelle Produktionskonfigurationen dem Repository
  tatsaechlich entsprechen.

**Naechste Freigabeempfehlung:** zuerst 1a und 1b in kleinen getrennten PRs, danach 1c/1d. Neue
Observability-/GitOps-Tools sind kein Ersatz fuer die offenen Datenverlust- und Secret-Grenzen.
