# Inaktive CI/CD- und Deployment-Beispiele

Diese Dateien liegen absichtlich **nicht** unter `.github/workflows/` und haben die Endung
`.example`. Sie starten hier keinen Workflow, Docker-Build oder Cluster. Erst fuer ein ausdruecklich
freigegebenes **Zielprojekt** anpassen und aktivieren.

| Datei                                  | Konkrete Aufgabe                                       | Voraussetzung                                                                                          |
| -------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| [Go CI](go-ci.yml.example)             | Format, vet, Race-/Coverage-Tests, Binary und Artefakt | go.mod mit gepruefter genauer Toolchain, go.sum, ./cmd/server                                          |
| [Rust CI](rust-ci.yml.example)         | Format, Clippy, Tests, Release-Binary und Artefakt     | Cargo.lock, rust-toolchain.toml mit genauem x.y.z, Binary app                                          |
| [Go Release](go-release.yml.example)   | Manueller Image-Build/Push nach erneuter Go-CI         | Go CI am unten genannten Pfad, geprueftes Dockerfile, GHCR-Rechte und geschuetztes release-Environment |
| [Go Dockerfile](Dockerfile.go.example) | Multi-Stage-Build als Non-Root-Image                   | Zwei freigegebene digest-gepinnte Basis-Images; Go-App ohne CGO                                        |
| [Dockerignore](dockerignore.example)   | Build-Kontext einschraenken                            | Zusaetzliche projektspezifische Geheimnisse/Daten explizit ausschliessen                               |
| [Kubernetes](kubernetes.yml.example)   | Deployment, ClusterIP-Service, NetworkPolicy           | Freigegebener Testnamespace, gueltiger Image-Digest, passende HTTP-Probes und CNI                      |

## Bewusste Uebernahme

Go CI im Zielprojekt als `.github/workflows/go-ci.yml` ablegen, Rust CI als
`.github/workflows/rust-ci.yml`. Beide Beispiele reagieren dann auf PRs, Pushes nach main und
manuelle Aufrufe; ausserdem sind sie per workflow_call wiederverwendbar. Das alleinige Kopieren kann
also spaeter kostenpflichtige Runner-Runs ausloesen. Keine pauschale Aktivierung dieser Dateien im
Setup-Repository.

Go braucht in go.mod eine genau gepruefte Toolchain; `actions/setup-go` liest die Projektdatei,
`GOTOOLCHAIN=local` verhindert weiteren impliziten Toolchainwechsel. Fuer Rust verlangt das Beispiel
eine numerische Version wie `x.y.z`, nicht `stable`/`nightly`. Eine aktuell passende Version bewusst
aus der [offiziellen Rust-Verteilung](https://static.rust-lang.org/dist/channel-rust-stable.toml)
waehlen. Im Rahmen der Quellenpruefung meldete diese am 21.10.2026 Rust 1.99.1; das ist kein
automatischer Upgrade-Auftrag fuer bestehende Projekte.

Die Runner sind kurzlebige GitHub-Hosts mit Ubuntu 24.04, Python 3.11+, rustup fuer Rust und
Buildwerkzeugen fuer Go-Race-Tests. Keine privaten Self-hosted-Runner fuer fremden PR-Code
einsetzen. Kein Live-CI-/Cross-Arch-Test dieser Vorlagen wurde hier ausgefuehrt. Angegebene
Actions-Pins wurden am 21.10.2026 per git ls-remote gegen die offiziellen Repositories abgeglichen.

## Manueller Go-Image-Release

Nach Freigabe das Dockerfile als `Dockerfile` und die Ignore-Datei als `.dockerignore` im
Zielprojekt verwenden; `.dockerignore` ist keine vollstaendige Secret-Erkennung. Das Beispiel ist
fuer `./cmd/server`, Port 8080 und ein CGO-freies Go-Binary ausgelegt. Eine Rust-gnu-Binary nicht
blind in ein statisches Image kopieren: libc, dynamische Bibliotheken, CA-Zertifikate und
Zielarchitektur pruefen. Das Go-Dockerfile ist kein Rust-Dockerfile.

Vor Aktivierung des Release-Workflows:

1. Go CI muss als `.github/workflows/go-ci.yml` vorhanden sein.
2. GitHub-Environment `release` mit Required Reviewers und Branchregel fuer main konfigurieren.
   `environment: release` allein **erzwingt keine Review-Regel**; deren Verfuegbarkeit haengt auch
   vom GitHub-Tarif/Repository ab.
3. Repository-Variable `ENABLE_MANUS_RELEASE` bewusst auf `true` setzen.
4. `GO_BUILDER_IMAGE` und `RUNTIME_IMAGE` auf gepruefte Registry-Referenzen mit echtem
   `@sha256:<64 Hexzeichen>` setzen. Der Suffix-Check ersetzt keine Vertrauenspruefung des
   Image-Herausgebers. Keine gefaelschten Beispiel-Digests.
5. GHCR-Paketrechte pruefen und Workflow auf main mit `publish=true` ausloesen. PRs koennen den
   Release-Workflow nicht ausloesen; keine PR-Secretsweitergabe.

Der Release baut nach gruener Go-CI erneut im Container. Eine abweichende Builder-Go-Version kann zu
anderem Verhalten fuehren; dieselbe gepruefte Toolchain im Projekt und Builder verwenden. Nur der
Publish-Job erhaelt `packages: write`. Das kurzlebige GITHUB_TOKEN kommt per stdin an docker login,
nicht als CLI-Passwort. Buildx/Daemon muessen auf dem Runner vorhanden sein; der Workflow
installiert sie nicht. SBOM-/Provenance-Erzeugung kann weitere Images/Dependencies laden. Der
Commit-Tag ist nachvollziehbar, aber der Registry- Tag bleibt technisch veraenderbar: fuer
Deployment den ausgegebenen Digest nutzen.

**Kein Kubernetes-Rollout erfolgt.** Fuer Rust den geprueften CI-Pfad und einen passenden
Rust-Containerbuild in einem gesonderten Release-Workflow verwenden, nicht nur den Dateinamen des
Go-Beispiels austauschen.

## Kubernetes erst nach Freigabe

Der Platzhalter `example.invalid/review-required@sha256:000...` ist absichtlich kein abrufbares
Image. Ohne echten Release-Digest ist die Vorlage **nicht einsatzbereit**. Testnamespace
`manus-example` separat anlegen/pruefen; bestehende Namespaces nicht automatisch umkonfigurieren.
Bei privaten Images gegebenenfalls separat verwaltete imagePullSecrets konfigurieren, keine echten
Schluessel ins YAML.

Die App muss `/healthz` und `/readyz` implementieren und innerhalb ihres Pods auf Port 8080
erreichbar sein. Pod-Bindung auf die Container-Schnittstelle ist nicht dasselbe wie eine
oeffentliche Host-Port-Freigabe. Der Service bleibt ClusterIP, ohne Ingress/NodePort/LoadBalancer.
Die Beispiel-NetworkPolicy erlaubt nur gleichnamensraeumliche Pods mit `app=approved-frontend` als
HTTP-Clients und sperrt ausgehenden Verkehr. Das wirkt nur bei einem CNI mit NetworkPolicy-Support.
DNS, Datenbank und weitere Abhaengigkeiten bei Bedarf minimal separat erlauben; sonst koennen sie
absichtlich nicht erreichbar sein. Labels/RBAC sind keine automatische Identitaetspruefung eines
Frontends.

Zwei Replikate, CPU/RAM-Werte, Probezeiten und 32-MiB-Tempvolumen sind **Beispielwerte**, keine
Messwerte. Sie koennen fuer eine reale Anwendung zu klein sein. Kein GPU-/Modell-Workload. Rollout,
Lasttest und kontrollierter Rollback erfordern eigenes Budget und Rechte; Datenbankmigrationen nicht
per Image-Rollback als geloest betrachten.

Weiter: [Tutorial und Best Practices](../../docs/tutorials/manus-ci-cd-deployment.md).
