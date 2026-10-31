# Produktionsnahe Baseline: VPS, Kubernetes, Monitoring und Backups

Stand: 23.10.2026. Diese Ergaenzung ist getrennt vom interaktiven Installer. Sie aendert keine
vorhandenen Secrets, Volumes oder produktiven Konfigurationen. Es wurde nichts installiert oder
deployed. Bestehende Audit-Befunde bleiben offen.

**Noch keine Produktionsfreigabe:** Images, StorageClass, Domain, VPN-Netz, age-Empfaenger und
Zugangsdaten sind bewusst nicht erfunden. Staging-Abnahme, Restore-Test und ein zweiter
erfolgreicher Ansible-Lauf sind erforderlich. Die
[vollstaendigen kommentierten Konfigurationen](PRODUCTION_BASELINE_CODE.md) stehen als nach fuenf
Bereichen gegliederte Code-Bloecke bereit; die Quelldateien in den unten verlinkten Verzeichnissen
sind massgeblich.

## 1. Infrastructure as Code

[Playbook](../ansible/vps_bootstrap.yml), [Collections](../ansible/requirements.yml),
[Inventarvorlage](../ansible/inventory.example.ini).

Ansible-Module beschreiben den Sollzustand statt Shell-Befehle bei jedem Lauf blind zu wiederholen.
Das Playbook unterstuetzt einen **frischen dedizierten** Ubuntu-22.04/24.04-VPS, keinen vorhandenen
K3s-/Docker-Host und kein WSL-Desktop. Es installiert Docker CE samt Compose-Plugin aus dem
signierten offiziellen Docker-APT-Repository. Das ist eine ausdrueckliche Infrastruktur-Ausnahme zur
GitHub-Quellenregel, kein Ersatz der bestehenden Tool-Installer.

Der Benutzer `llmops` erhaelt weder sudo noch Docker-Gruppenrechte; Zugriff auf den Docker-Socket
waere praktisch Root-Zugriff. Die Passwortanmeldung wird abgeschaltet, vorhandene
Administrator-SSH-Keys werden nicht entfernt. Root kann weiterhin nur per vorhandenem Key anmelden;
eine spaetere vollstaendige Root-Login-Sperre braucht einen getesteten sudo-Administrator.

Vorab Administrator-Key in einer zweiten SSH-Sitzung testen, Provider-Konsole offen halten und ein
privates Inventar/Variablendatei ausserhalb des Repos anlegen:

```yaml
# /geschuetzter/pfad/bootstrap-vars.yml; public key only, never a private key
llmops_ssh_public_key: ssh-ed25519 REPLACE_WITH_PUBLIC_KEY
bootstrap_key_access_confirmed: true
bootstrap_dedicated_host_confirmed: true
```

```bash
ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook -i /geschuetzter/pfad/inventory.ini ansible/vps_bootstrap.yml \
  --extra-vars @/geschuetzter/pfad/bootstrap-vars.yml --syntax-check
# Review first; check mode cannot simulate package installation on a fresh host.
ansible-playbook -i /geschuetzter/pfad/inventory.ini ansible/vps_bootstrap.yml \
  --extra-vars @/geschuetzter/pfad/bootstrap-vars.yml --check --diff
```

Erst nach Pruefung denselben Aufruf ohne `--check --diff` verwenden. Der Folgelauf soll ohne neue
Paketupdates unveraendert bleiben. Paketquellen und Security-Updates sind absichtlich nicht
eingefroren; fuer bitgenaue Wiederholung braucht es zusaetzlich Paketversions-Pins und einen
APT-Snapshot.

UFW erlaubt nur neue TCP-Verbindungen zu 22/80/443. Unerwartete vorhandene Regeln fuehren zum
Abbruch statt zum Reset. Das ist **keine fertige K3s-/WireGuard-Firewall**: VPN-UDP-Port und private
Clusterpfade sind vor deren Installation separat zu planen. Docker-Portfreigaben koennen UFW
umgehen; niemals daraus Schutz fuer beliebige `ports:`-Mappings ableiten.
[Docker-Firewall-Dokumentation](https://docs.docker.com/engine/network/packet-filtering-firewalls/)

## 2. Kubernetes mit Kustomize

[Basis](../k8s/base/kustomization.yml),
[Produktions-Overlay](../k8s/overlays/production/kustomization.yml),
[Traefik-Werte](../k8s/platform/traefik-values.yml).

Die CPU-Basis trennt Ollama-StatefulSet/PVC und LiteLLM-Deployment, verwendet ClusterIP statt
oeffentlichem Ollama-Port und setzt Non-Root, RuntimeDefault, Capability-Drop, Read-only-Root,
Probes, Quotas und Default-Deny-NetworkPolicies. Die GPU-Variante fordert genau eine NVIDIA-GPU mit
begrenztem CPU/RAM und ephemeral-storage. `0.0.0.0` **im Pod** ist erforderlich fuer den
Cluster-Service und nicht gleichbedeutend mit einer Host-Portfreigabe.

Voraussetzungen: NetworkPolicy-faehiges CNI, funktionierender CSI/StorageClass, NVIDIA Device Plugin
fuer das GPU-Overlay, passende Worker-Kennzeichnung sowie Traefik und cert-manager inklusive CRDs.
Traefik wird separat im Namespace `traefik` erwartet; K3s' gebuendelter Controller liegt oft in
`kube-system`. Keinen zweiten Controller daneben installieren: entweder dessen Namespace/Labels in
den Policies anpassen oder eine geplante Migration durchfuehren.

```bash
# Select reviewed chart archives and verify them before this explicit installation.
helm upgrade --install traefik /geschuetzter/pfad/traefik-REVIEWED.tgz \
  --namespace traefik --create-namespace -f k8s/platform/traefik-values.yml
# cert-manager is a separate, version-pinned prerequisite, including its CRDs.
kubectl kustomize k8s/base
kubectl kustomize k8s/overlays/production
```

In einem privaten Overlay Ollama-/LiteLLM-Images mit geprueften `@sha256:`-Digests ersetzen und den
**bereits installierten** Modellnamen setzen. Der ausgewaehlte Image-Build muss unter UID 10001 und
Read-only-Root getestet werden; nicht bei Fehlern automatisch Root oder Privilegien erlauben. Ein
Image-Digest allein belegt noch keine vertrauenswuerdige Herkunft oder Schwachstellenfreiheit.

Domain, ACME-Mail, VPN-CIDR und Label `llmops.example/gpu=true` anpassen. Die API ist
ausschliesslich unter HTTPS `/v1` erreichbar und braucht zusaetzlich einen Bearer-Key.
Management-/Metrics-Routen werden nicht veroeffentlicht. HTTP-01 erfordert oeffentlich erreichbaren
Port 80 und DNS zur Ingress-Adresse; fuer rein private Domains stattdessen einen separat
konfigurierten DNS-01-Solver oder eine interne CA nutzen. Erst mit ACME-Staging testen, dann
Production nutzen. Die HTTP-01-Solver-Pods haben eine eigene eng begrenzte NetworkPolicy.
[cert-manager HTTP-01](https://cert-manager.io/docs/configuration/acme/http01/)

```bash
set -euo pipefail
kubectl kustomize /geschuetzter/pfad/private-production-overlay \
  | python3 scripts/quality/production_preflight.py
# Only after preflight and review: server-side validation, not a side-effect-free check.
kubectl apply --dry-run=server -k /geschuetzter/pfad/private-production-overlay
```

Bewusst eine LiteLLM-Replik: Ohne gemeinsame Postgres-/Redis-Anbindung waeren mehrere Proxys mit
prozesslokalem Zustand keine verlaessliche Budget-/HA-Loesung. Diese Erweiterung erzeugt nicht
vorgeblich den gesamten bestehenden Stack neu. Open WebUI, OpenClaw, Postgres, Redis, MinIO und
Qdrant bleiben separat; vor einer K8s-Migration brauchen sie eigene Workloads, Datenmigration und
Policies. Nach Modellwechsel Probes plus eine explizit freigegebene echte Inferenz testen;
`/api/version` beweist nicht, dass das Modell vorhanden oder fachlich einsatzbereit ist.

## 3. Observability fuer Compose-VPS

[Compose](../docker-compose.monitoring.yml), [Prometheus](../monitoring/prometheus.yml),
[Grafana-Dashboard](../monitoring/grafana/dashboards/llmops.json),
[Alloy](../monitoring/config.alloy), [Loki](../monitoring/loki.yml).

**Absichtliche Korrektur:** Promtail ist seit 02.03.2026 End-of-Life. Deshalb uebernimmt Grafana
Alloy den Logtransport zu Loki.
[Offizielle Promtail-EOL-Mitteilung](https://grafana.com/docs/loki/latest/send-data/promtail/)

Ein natives Ollama-`/metrics` wird nicht vorausgesetzt. LiteLLM liefert fuer darueber geroutete
Aufrufe Token-/Request-Metriken; die Konfiguration aktiviert den Prometheus-Callback. Das Tokenpanel
verwendet den Counter `litellm_total_tokens_metric_total`; dessen Namen und Labels mit dem
gewaehlten LiteLLM-Pin am echten Endpoint pruefen. Direkte Ollama-Aufrufe werden nicht mitgezaehlt.
Der optionale Ollama-Exporter-Job bleibt ohne geprueften Exporter leer; keine erfundenen Messwerte
oder automatischen Modellabfragen.
[LiteLLM-Metriken](https://docs.litellm.ai/docs/proxy/prometheus),
[Counter-Implementierung](https://github.com/BerriAI/litellm/blob/main/litellm/integrations/prometheus.py)

Reale Werte aus [Monitoring-env-Vorlage](../monitoring/.env.example) in eine externe Datei
uebernehmen und Images per Digest pinnen. Der LiteLLM-Scrape-Host ist eine **private erreichbare**
Adresse. `host.docker.internal` macht einen Hostdienst, der nur auf 127.0.0.1 lauscht, nicht
automatisch erreichbar. Bevorzugt ein bewusst gemeinsam genutztes privates Docker-Netz oder eine
gefilterte VPN-Adresse nutzen, nicht LiteLLM ungeprueft oeffentlich binden.

Passwort-/Metrics-Token-Dateien ausserhalb des Repos anlegen. Compose-File-Secrets sind lokale
Bind-Mounts, keine automatische At-Rest-Verschluesselung; deren Host-Rechte muessen zur
Container-UID passen, z. B. root:65534/0440 fuer den Prometheus-Token und root:472/0440 fuer das
Grafana-Passwort. Uebergeordnete Verzeichnisse schuetzen und Gruppen nicht normalen Benutzern
zuweisen. Einen gesonderten Metrics-Key verwenden, soweit die gepruefte LiteLLM-Version das erlaubt;
keinen Master-Key an Browser oder Grafana geben.

```bash
python3 scripts/quality/production_preflight.py --monitoring-env /etc/llmops/monitoring.env
docker compose --env-file /etc/llmops/monitoring.env -f docker-compose.monitoring.yml config --quiet
# Explicit operator action only, not performed by this change:
docker compose --env-file /etc/llmops/monitoring.env -f docker-compose.monitoring.yml \
  --profile host-metrics up -d
```

Grafana bindet an 127.0.0.1:3030, Prometheus an 127.0.0.1:9091; Zugriff per SSH-Tunnel oder
authentifiziertem TLS-Proxy. Loki hat keine eigene Authentifizierung und bleibt nur im internen
Netz. Node-Exporter liest bewusst Host-Dateisysteme: Profil `host-metrics` nur auf einem
freigegebenen Linux-VPS aktivieren, nicht als folgenlosen Standard fuer WSL behandeln. Ohne Profil
den Node-Scrape-Job entfernen, sonst ist dessen Down-Alarm erwartbar.

Alloy sammelt nur explizit bereitgestellte, **bereits bereinigte** Dateien unter `openclaw/*.log`
und `litellm/*.log`. Bestehende Container-Stdout-/Journald-Logs werden nicht automatisch
abgegriffen. Die Anwendungen muessen sichere Dateiausgabe/Weiterleitung erhalten; keine
Prompt-Inhalte, API-Keys oder Tokens loggen. UID 10001 braucht Leserechte. Kein Docker-Socket und
kein vollstaendiges Benutzer-/Secret-Verzeichnis wird an Alloy durchgereicht.

Benannte Volumes muessen fuer UID 65534/472/10001 passend initialisiert sein; vor Start in Staging
pruefen. Prometheus speichert maximal 7 Tage/2 GB, Loki 7 Tage. Alarmregeln sind vorhanden; fuer
echte Benachrichtigungen fehlen noch Alertmanager und ein bewusst gewaehlter Receiver.
GPU/VRAM-Telemetrie braucht zusaetzlich einen geprueften NVIDIA/DCGM-Exporter und eigene Dashboards.

## 4. Secrets und konsistente Backups

[SOPS-Regel](../.sops.yaml), [Secret-Vorlage](../k8s/secrets.template.yml),
[Backup-Skript](../scripts/backup_stateful_services.sh),
[Backup-env-Vorlage](../monitoring/backup.env.example).

SOPS verschluesselt `data`/`stringData` fuer den echten **oeffentlichen** age-Empfaenger. Ohne
diesen waere eine angeblich fertige `secrets.enc.yaml` nur vorgetaeuschte Verschluesselung. Daher
ist die Vorlage Klartext mit offensichtlichen Platzhaltern, nicht Bestandteil der Kustomization.
Private age-Identitaet und Restic-Passwort separat/offline sichern.

```bash
set -euo pipefail
# Prepare real YAML in a protected directory outside Git, mode 0600.
sops --config .sops.yaml --filename-override secrets.enc.yaml \
  --encrypt /geschuetzter/pfad/secrets.plain.yaml \
  > /geschuetzter/pfad/secrets.enc.yaml
# Do not print the decrypted document; apply only after reviewing the destination.
sops --decrypt /geschuetzter/pfad/secrets.enc.yaml | kubectl apply -f -
```

SOPS schuetzt Git-/Dateispeicherung, nicht automatisch Kubernetes-etcd: dort Verschluesselung at
rest, enges RBAC und geschuetzte Cluster-Backups einrichten. Die DB-Passwort-Vorlage ist fuer eine
spaetere DB-Anbindung reserviert; sie konfiguriert noch keinen Postgres-Server. Keine echten Werte
in Beispieldateien.

Das Backup-Skript unterstuetzt **Standalone-Compose-Dienste** namens `postgres`, `minio`, `qdrant`,
jeweils mit genau einem erkannten Daten-Mount. Keine verteilten Datenbanken, externen
Tablespaces/WAL, Zusatzdatenvolumes oder K8s-PVCs. Es liest `KEY=VALUE` literal ein, niemals per
`source`/`eval`, prueft 0600 und Eigentuemer der Secret-Dateien, Mount-Zuordnung sowie ein eigenes
0700-Lock-Verzeichnis.

Standard ist ein lokaler Dry-Run ohne Docker-/S3-Aufruf. `--run` braucht `BACKUP_ALLOW_DOWNTIME=1`
und ein **externes** Ziel. Das primaere MinIO darf nicht zugleich Backup-Ziel sein: es wird
waehrenddessen gestoppt. Der Operator muss sicherstellen, dass keine weiteren Hosts/Watchdogs in
dieselben Datenpfade schreiben oder Dienste neu starten. Ein Lock blockiert nur weitere Laeufe
dieses Skripts, keinen externen Orchestrator. Fuer Live-Backups native DB-Dumps, Qdrant-Snapshots
und versionierte MinIO-Replikation gesondert entwickeln.

```bash
# Run as the owner of the protected files, with deliberate Docker and volume access.
bash scripts/backup_stateful_services.sh /etc/llmops/backup.env --dry-run
bash scripts/backup_stateful_services.sh /etc/llmops/backup.env --run
```

Nach erfolgreichem Repository-Zugriff werden die Datendienste sauber gestoppt; Exit 137 oder
unerwartete Zustandswerte verhindern das Backup. Ein EXIT-/Signal- Trap startet nur die zuvor
laufenden Dienste wieder, auch bei Restic-Fehlern. Ein fehlgeschlagener Wiederanlauf bleibt ein
Fehler. SIGKILL, Stromausfall oder Hostabsturz koennen keinen Shell-Trap ausloesen: dann ist
manuelle Wiederherstellung erforderlich. Keine automatische Repository-Initialisierung, kein Prune,
kein Loeschen von Daten und kein Aendern von `~/.openclaw_ultimate_user_data`.
[Restic-Repository und Passwortdatei](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html)

Restore zuerst auf einem getrennten Testhost: Snapshot-ID auswaehlen, `restic check`,
`restic restore ID --target /isolierter/restore-test`, Rechte pruefen und dieselben
DB-/Image-Versionen mit den wiederhergestellten Daten starten. Danach Postgres-Leseprobe,
Qdrant-Collection-Pruefung und MinIO-Objekt- Hashvergleich. Erst nach bestandenem Test RPO/RTO
festlegen und einen Timer mit genehmigtem Wartungsfenster aktivieren. Restore-Pfade niemals
ungeprueft ueber laufende Produktionsvolumes kopieren.

## 5. CI/CD und Nachweisstand

[Workflow](../.github/workflows/test-install-scripts.yml),
[Bats-Fixtures](../tests/bats/install_scripts.bats),
[Offline-Sicherheitstests](../tests/test_production_baseline.py).

Die CI startet keine Installer oder Dienste: Bats testet die vorhandenen Port-/Konfigurationsskripte
in eigenen Temp-Verzeichnissen mit gueltigen und ungueltigen Registries. Der echte semantische
Repository-Audit bleibt dabei aktiv. Der Trivy-Dateiscan stoppt bei Secret-Funden; dessen Ausgabe
zeigt nur Dateipfade/Regel-IDs, keine passenden Secret-Inhalte. Vollstaendige Action- und
Bats-Commit-Pins wurden gegen offizielle GitHub-Quellen aufgeloest.
[Trivy Secret-Scanner](https://trivy.dev/docs/latest/scanner/secret/)

Lokal bestanden: 7 Bats-Tests, Bash-Syntax, YAML-Parsing und Kustomize-Rendering fuer
Basis/Production. Die Python-Suite hat 7 plattformunabhaengige Tests; 6 POSIX-Backup-Mocktests
werden unter Windows uebersprungen und in Ubuntu-CI ausgefuehrt. Die CI selbst, Trivy,
Ansible-Idempotenz, Kubernetes-API-Schema- Validierung, tatsaechliche Containerstarts und Restore
wurden hier nicht ausgefuehrt. Die Windows-Pruefwerkzeuge lagen nur in einem temporaeren
Verzeichnis; keine Systeminstallation und keine WSL-/Docker-/Cluster-Aktion.

Die Vorlagen sind kein Nachweis fuer TLS-Ausstellung, kompatible Image-UIDs, GPU-Zugriff,
funktionsfaehige Scrapes oder erfolgreichen Wiederanlauf. Diese Abnahme erfolgt in Staging, bevor
bestehende produktive Dateien ersetzt werden.
