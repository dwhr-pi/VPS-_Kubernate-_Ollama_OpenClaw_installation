# Manus-Ergaenzung: Skill, Go-/Rust-CI und kontrolliertes Deployment

**Sinn und Zweck:** Den bisher beschriebenen Prozess wiederholen koennen:
Auftrag eingrenzen, passende Werkzeuge waehlen, patchen, pruefen und ein
nachvollziehbares Ergebnis liefern. CI automatisiert vereinbarte Checks;
Veroeffentlichung und produktives Deployment bleiben eigene Entscheidungen.
Stand: 21.10.2026. Kein offizieller Manus-Code, kein Konto und keine Cloud-API
erforderlich. Fuer eigene Projekte ist der Ablauf unabhaengig vom Modell nutzbar.

## 1. Wiederverwendbare Faehigkeit

Fuer vorgelagerte Recherche/Toolauswahl gibt es seit 22.10.2026 zusaetzlich
[sprach-infra-tooling](../../skills/sprach-infra-tooling/SKILL.md).
Der [neue Interviewabgleich](manus-interview-2026-10-22.md) erklaert die
Abgrenzung zum Umsetzungs-Skill sowie die nicht vorliegenden Manus-Originaldateien.

Der neue Repository-Skill
[agentic-project-delivery](../../skills/agentic-project-delivery/SKILL.md)
enthaelt den konkreten Ablauf und verweist nur bei Bedarf auf Quellen und
CI-Beispiele. Er ist **nicht global installiert oder automatisch aktiviert**.
Ein Agent kann ihn nach ausdruecklichem Auftrag aus diesem GitHub-Checkout lesen.
Eine spaetere Kopie in den Skill-Ordner eines Clients braucht eigene Zustimmung;
die relativen Repository-Referenzen muessen dort mitgenommen oder angepasst werden.

Beispielauftrag:

```text
Nutze skills/agentic-project-delivery/SKILL.md fuer das freigegebene Projekt.
Pruefe den Git-Status und vorhandene Tests. Erstelle einen kleinen Patch und
einen Bericht mit echten Exit-Codes. Maximal drei Korrekturrunden.
Keine Paketinstallation, WSL-Aktion, Cloud-Abfrage, Wallet, Commit oder Push.
Fuehre nur die fuer diesen Auftrag separat freigegebenen Projektchecks aus.
```

Skill-Anweisungen ersetzen keine Sandbox oder Rechtekontrolle. Die Datei
macht aus OpenClaw/Automaton keinen bereits eingerichteten CI-Runner. Bestehende
System-, Hardware-, Wallet- und Netzgrenzen gelten unveraendert weiter.

## 2. Konkrete GitHub-Actions-Beispiele

Die vollstaendigen, **inaktiven Vorlagen** stehen unter
[examples/manus-ci-cd](../../examples/manus-ci-cd/README.md).
Sie werden nicht automatisch nach `.github/workflows/` kopiert.

| Vorlage | Schritte | Freigabe-/Sicherheitsgrenze |
|---|---|---|
| [Go CI](../../examples/manus-ci-cd/go-ci.yml.example) | Projekt-Go vorbereiten, gofmt-Pruefung, Module verifizieren, vet, Race-/Coverage-Tests, ./cmd/server bauen, Artefakt | Read-only Repository-Token, keine Projekt-Secrets; Tests/Dependencies brauchen Netzwerk und Codeausfuehrung |
| [Rust CI](../../examples/manus-ci-cd/rust-ci.yml.example) | Genaues rust-toolchain.toml pruefen, Toolchain/Komponenten laden, fmt, Clippy, Tests, app bauen, Artefakt | --locked ist kein Offline-/Sandbox-Modus; kein pauschales --all-features |
| [Go Image Release](../../examples/manus-ci-cd/go-release.yml.example) | Manueller main-Aufruf, erneute Go-CI, geschuetztes Environment, digest-gepinnter Containerbuild, GHCR-Push, Digest-Bericht | Zusatztor ENABLE_MANUS_RELEASE und publish=true; keine Kubeconfig oder Clusteraktion |

Beide CI-Vorlagen begrenzen Jobdauer und parallele Buildarbeit. Das sind keine
harten RAM-Limits. Race-Tests auf Ubuntu brauchen CGO/Compiler; fuer andere
Architekturen eigene Matrix und Smoke-Tests ergaenzen. Artefakte enthalten nur
ausgewaehlte Binary-/Coverage-Dateien; vor oeffentlicher Freigabe auf sensible
Pfade/Buildinformationen pruefen. Kein gruener CI-Nachweis wird hier behauptet:
die Vorlagen wurden lokal geprueft, nicht auf GitHub gestartet.

CI ist nicht CD: Ein bestandener Test laedt kein Image in Produktion. Der
separate Release-Workflow zeigt eine konkrete **Continuous-Delivery-Stufe mit
manueller Freigabe**, keinen automatisch konfigurierten Produktionsrollout.
GitHub-Environment-Schutzregeln muessen ausserhalb des YAML wirklich eingerichtet
sein. Unbekannte PRs niemals auf privaten KI-/Wallet-Hosts testen.

Primaerquellen: [Go mit GitHub Actions](https://docs.github.com/en/actions/tutorials/build-and-test-code/go),
[Setup Go](https://github.com/actions/setup-go),
[GitHub Actions: sichere Nutzung](https://docs.github.com/en/actions/reference/security/secure-use).

## 3. Docker-Best-Practices fuer diese Projekte

Deine Vorgabe bleibt: **Tools aus GitHub statt per Docker installieren**.
Container sind hier nur ein optionales Auslieferungsformat fuer eine eigene
Go-/Rust-Anwendung. Kein Docker-Daemon oder Desktop wird eingerichtet.

- Multi-Stage-Build: Compiler und Buildcache nicht ins Laufzeitimage uebernehmen.
  Gepruefte Basis-Images per Digest pinnen und mit kontrollierten Updates erneuern.
- `.dockerignore` vor `COPY . .` pruefen; keine Wallets, persoenlichen Dokumente,
  Git-Credentials oder `.env` in den Buildkontext. Build-Secrets nicht per ARG.
- Non-Root-Nutzer und minimale Runtime; libc, CA-Zertifikate, DNS und Zielarchitektur
  passend zum Binary pruefen. Go ohne CGO ist nicht auf Rust/gnu uebertragbar.
- Images nach Build testen/scannen; SBOM und Provenance zum exakten Digest
  speichern. Scans sind keine vollstaendige Sicherheitsgarantie und brauchen
  passende Scanner-/Datenbankversionen sowie kontrollierten Netzwerkzugriff.
- Container stoppen sauber per SIGTERM; Health-/Readiness-Endpunkte implementieren.
  Logs ohne Secrets, keine unbeschraenkten Restart-/Fehlerloops.
- Lokal nur explizite Loopback-Portfreigaben. Kein Docker-Socket fuer Agenten,
  kein privilegierter Container, kein Mount des ganzen Home-/Root-Dateisystems.

Primaerquelle: [Docker Build Best Practices](https://docs.docker.com/build/building/best-practices/).
Das [Go-Dockerfile](../../examples/manus-ci-cd/Dockerfile.go.example) verlangt zwei
echte freigegebene Image-Digests und ist deshalb nicht mit erfundenen Digests
als angeblich startfertig ausgefuellt.

## 4. Kubernetes-Best-Practices

Die [Manifest-Vorlage](../../examples/manus-ci-cd/kubernetes.yml.example)
enthaelt Deployment, ClusterIP-Service und NetworkPolicy. Sie hat bewusst
ein nicht abrufbares Platzhalterimage; kein automatischer Clusterzugriff.

- Exakten Image-Digest aus dem freigegebenen Release verwenden, nicht `latest`.
  Namespace, Kontext, RBAC und eventuelle private Pull-Credentials zuerst pruefen.
- CPU-/RAM-Requests und Limits messen; Beispielwerte nicht auf LLM/GPU-Workloads
  uebertragen. Mehrere Replikate brauchen entsprechend mehr Ressourcen.
- Non-Root, read-only Root-FS, kein Privilege-Escalation, Capabilities entfernen,
  RuntimeDefault-Seccomp und kein automatisch gemountetes ServiceAccount-Token.
- Startup-, Readiness- und Liveness-Probes unterscheiden. Ein kaputtes externes
  Backend nicht blind als Liveness-Ausfall behandeln und Restart-Stuerme erzeugen.
- NetworkPolicy mit passendem CNI: nur notwendige Verbindungen, DNS/DB gezielt
  freigeben. Kein oeffentlicher Zugriff auf Ollama, Datenbanken oder Cluster-API.
- Secret-Management getrennt; Kubernetes-Secrets sind nicht automatisch durch
  Base64 verschluesselt. Keine echten Keys in Beispielen, Git oder Folien.
- Erst Testnamespace und Smoke-Test, dann kontrollierter Rollout mit Timeout.
  Image-Rollback ist kein Datenbank-Restore; Migrationen/Backups separat planen.

Primaerquellen: [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/),
[Probes](https://kubernetes.io/docs/concepts/workloads/pods/probes/).
`kubectl --dry-run=server`, diff und Rolloutstatus kontaktieren den Cluster;
dafuer bleiben Kontext- und Ausfuehrungsfreigabe notwendig.

## 5. Deployment nach dem Image-Release

Nach Tests und Review den ausgegebenen Digest in einem separaten Manifest-/GitOps-
Pull-Request eintragen. Genau einen zustaendigen GitOps-Controller waehlen oder
einen bewusst manuellen Rollout planen. Ein Auto-Sync kann bereits das Merge
ausrollen: Controllerregeln und Wartungsfenster vorher pruefen. In diesem Auftrag
werden weder Cluster-Credentials erzeugt noch Sync/Apply/Push ausgefuehrt.

## 6. Praesentation und Quellen

Weitere PDF-/PowerPoint-Varianten und der Original-Sprachenkatalog sind im
[Quellenregister vom 24.10.2026](../sources/2026-10-24/README.md) eingeordnet.
Die erneut gelieferte 13-Folien-Datei ist bytegleich mit der folgenden
Praesentation und wird nicht doppelt abgelegt. Die 11-Folien-Variante bleibt separat.

Die [Praesentation](../presentations/technology-tooling-overview.pptx) fasst
Technologiestacks, Skill, CI/CD und die Freigabegrenzen zusammen.
Die [Folieninhalte](../presentations/technology-tooling-overview.json) enthalten
Quellen und Sprecherhinweise; sie sind keine Laufzeitkonfiguration.

Der [Generator](../../scripts/docs/build_manus_presentation.mjs) nutzt ausschliesslich
den bereitgestellten Artifact-Tool-Desktop-Runtime und installiert keine Pakete.
Fuer einen erneuten Build `RUNTIME_NODE_MODULES`, `RUNTIME_PYTHON` und
`PRESENTATIONS_SKILL_DIR` aus der Runtime-Erkennung setzen und einen neuen
Ausgabepfad als erstes Argument angeben. Vorhandene finale Dateien werden nicht
ueberschrieben. Private Renderbilder/Pruefberichte liegen in `.codex-build/`
und gehoeren nicht zur veroeffentlichten Dokumentation. Kein PowerPoint-Livetest.

## Lokaler Pruefumfang

Offline-Tests pruefen Action-Pins, Trigger-/Berechtigungsgrenzen, Shell-Syntax,
die eingebetteten Python-Schritte mit Temp-Fixtures, Skill-Metadaten/-Referenzen
und editierbare Folien/Quellenhinweise. Das ersetzt keine vollstaendige GitHub-
Workflow-Schemapruefung oder einen echten Go-/Rust-Build. Der mitgelieferte
Skill-Standardvalidator konnte mangels PyYAML nicht laufen; Struktur und Links
wurden separat getestet. Es wurde kein Paket dafuer nachinstalliert. PyYAML
ist keine Laufzeitvoraussetzung fuer das Lesen/Verwenden dieses Skills.

Weiter: [Erster Quellenkatalog](manus-development-sources.md),
[Sprachen/Infrastruktur](manus-language-infrastructure-sources.md),
[Vorhandene Queue](../CODEX_TASK_QUEUE.md).
