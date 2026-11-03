# Nachpruefung der Claude-Reviewvorlage

Stand: 03.11.2026. Durchgefuehrt durch Codex anhand des angehaengten Auftrags; kein Aufruf
von Claude oder eines externen Modellanbieters. Keine Provider- oder Runtime-Abnahme.
Ausgangscommit lokal und oeffentliches `main`: `1e75043a8ec567d193a0fd54b174d5105ab1a97d`.
Vergleich per lesendem `git ls-remote`, kein Pull/Reset. Die Webansicht allein war gecacht und
wurde deshalb nicht als Beleg des aktuellen Heads verwendet.
Arbeitsbranch: `codex/claude-review-p0-20261103`; kein Merge nach `main`.

## 1. Verifizierte Befunde

Dateizeilen beziehen sich auf den Ausgangscommit, ausser der ausdruecklich neuen Listener-Pruefung.

| Nr. | Bewertung der Vorlage | Beleg und verbleibende Grenze |
|---|---|---|
| 1 | Erweitert | `config/tools.yml:1`, `config/profiles.yml:1`: 400 Tools, 250 Profile statt 62. Registry-Check meldet 793 Hinweise, darunter 233 fehlende Doctor- und 233 Update-Zuordnungen. Vorhandene Metadaten sind keine Lifecycle-Abnahme. |
| 2 | Teilweise bestaetigt | `docs/DIRECTORY_LAYOUT.md:1` beschreibt bestehende Verzeichnisse. Root-Datei heisst bewusst `readme.md`; keine konkurrierende Grossschreibungsdatei auf Windows erzeugen. `config`/`configs` nicht blind zusammenlegen. |
| 3 | Fuer Statusdateien widerlegt | `.gitignore:23`/`:24` ignorieren die beiden Root-Statusdateien; `git ls-files` fuehrt sie nicht. `memory/personas/anna_support/MEMORY.md:1` ist eine Vorlage. Daraus folgt keine Freigabe saemtlicher Memory-Inhalte oder der Historie; nichts pauschal loeschen. |
| 4 | Teilweise bestaetigt | `install.sh:598` sperrt unsignierten Standardzugang, `docs/SIGNED_RELEASES.md:1` beschreibt Minisign. Trotzdem fuehren `scripts/tools/foundry_install.sh:6`, `clawhub_install.sh:100`, `clawhub_cli_install.sh:84` ungepruefte Fremdskripte aus. Git-Source-Builds beibehalten; diese Einzelpfade separat migrieren. |
| 5 | Als Standard widerlegt | `scripts/security/update_verified_release.py:22` weist Dirty-Worktrees ab; vor Tag-Checkout erfolgt verifiziertes Backup. `scripts/lib/repo_safety.py:326` enthaelt dagegen noch einen abgesicherten Force-Checkout im generischen Sync-Pfad: kein pauschaler Nachweis, dass alle alten Updatepfade harmlos sind. |
| 6 | Teilweise bestaetigt | `install.sh:61` entfernt PAT-Export und benutzt private Askpass-Dateien, nicht PAT-Remote-URLs. `scripts/security/private_env.py:15` prueft private Pfade/Metadaten. Bestehende Klartext-Service-ENV, getrennte Dienst-Credentials, Windows-ACLs und echte age-Restores bleiben gesondert zu pruefen. |
| 7 | Fuer aktuelle Basis widerlegt | `k8s/base/namespace.yml:11`/`:25` enthalten Quota/LimitRange; `network-policy.yml:2` Default-Deny, `ollama.yml:83` Probes. Historische Beispiele liegen in `docs/legacy/K8S_DEPLOYMENTS_LEGACY.md:1`; keine rohe Sammeldatei als Produktionspfad wiederbeleben. |
| 8 | Teilweise widerlegt | `.github/workflows/test-install-scripts.yml:1` und `tests/` enthalten Bats und isolierte Funktions-Fixtures. Diese ersetzen keine Fresh-Host-/GPU-/CNI-/PVC-Restore-Integration. Docker/k3d nicht entgegen der Maintainer-Vorgabe automatisch installieren. |
| 9 | Nicht pauschal bestaetigt | `scripts/security/prepare_release.py:1`, `release_manifest.py:1` und Signaturworkflow sind implementiert. Ein vorhandener Prozess beweist kein wirklich publiziertes, signiertes und frisch installiertes Release. Release-Assets/Vertrauensanker hier nicht abgenommen. |
| 10 | Als Pruefbedarf bestaetigt | `config/tools.yml:1` fuehrt beispielsweise Automaton als experimental und Cosign/SOPS/age/OpenBao als planned. Keine automatische Hochstufung oder Abwertung nach Projektnamen; je Tool Quelle, Lizenz, Build und Probe einzeln belegen. |
| 11 | Fuer Root-README widerlegt | `readme.md:1`: 188 Zeilen und verlinkte Detaildokumentation. Die Zahl der Dokumente allein beweist keinen Fehler; historische Aussagen und generierte Metadaten muessen aber unterscheidbar bleiben. |

Zusaetzlicher bestaetigter P0-Befund: `setup_ultimate.sh:343-352` verwendet eine feste
`/tmp/metrics_config_edit` und laedt die editierte Konfiguration mit `source`. Nicht in diesem
Patch geaendert: Werteparser, atomischer Editor und Migration der vielen Konfigurationsvariablen
brauchen eigene Kompatibilitaetstests. Ebenso sind weitere feste Dialogdateien vorhanden.

## 2. Priorisierte Patchfolge

| Prioritaet | Paket | Aufwand | Risiko | Abnahme |
|---|---|---|---|---|
| P0-A | Listener-Audit fail-closed, TCP/UDP/IPv6, Registry-Luecken | S | Niedrig, aber neue Fehlercodes | Synthetische Fixtures; nach Freigabe echter Linux-Hostcheck |
| P0-B | Privater Messwerte-Editor ohne `source` und feste Temp-Datei | M | Mittel: Legacy-Werteformat | Shell-Injection-/Symlink-/Abbruchtests, alte Messwerte erhalten |
| P0-C | Foundry/ClawHub/Bun einzeln auf verifizierte Source-Buildvertraege | M je Tool | Mittel: Toolchains | Commit/Locks/Lizenz, nativer Build in Wegwerf-VM, kein Docker-Fallback |
| P0-D | Historische Secret-Triage und getrennte Dienst-Credentials | M | Hoch bei Migration | Keine Werte im Bericht, Provider-Rotation nur nach Maintainerentscheidung |
| P1-A | Vorhandenen Registry-Generator und readiness-Nachweise vervollstaendigen | M | Mittel | Drift-Check, echte Evidence-Dateien, keine Umbenennung aller Statuswerte |
| P1-B | Lifecycle zuerst fuer benoetigte zehn Kerntools | L | Mittel | Install/Status/Doctor/Update/Uninstall/Restore je Plattform |
| P2-A | Privater Ingress/CNI-Vertrag und Restore-Drill | L | Hoch bei Apply | Negativtests, Datenbank-Konsistenz, PVC-Wiederherstellung, gemessenes RPO/RTO |
| P2-B | WoL -> SSH -> NodeReady -> GPU -> Ollama mit Job-Lock | M | Mittel | Zeitueberschreitung, Retry, Cancel, keine Abschaltung bei aktiven Jobs |
| P3 | Ubuntu-24.04 amd64/ARM, Source-Build-/Release-Abnahme | L | Mittel | Wegwerf-VM, signierter Tag, Offline-Artefakte, Linux-/ACL-Nachweise |

`set -Eeuo pipefail` und EXIT-Traps nicht blind in alle gesourcten Helfer kopieren: globale
Shelloptionen und bestehende Traps koennen Menues/Caller veraendern. Zuerst eigene Prozesse,
gesourcte Bibliotheken und reine Exec-Wrapper unterscheiden. Die gesamte Shell-Sammlung ist
mit diesem Paket nicht als strict-mode-konform abgenommen; Verstoesse bleiben Einzelpatches.
Die rein lexikalische Sichtung umfasste 2142 Shell-Dateien; 2083 enthielten keinen woertlichen
`trap`-Eintrag mit folgendem Leerzeichen. Das umfasst auch reine Bibliotheken/Wrapper und ist kein Zaehler fuer
2083 Sicherheitsluecken. Vor einem Gesamtumbau fehlt weiterhin die toolweise semantische Abnahme.

## 3. Implementierter P0-A-Patch

- Bestehender Pfad `scripts/security/port_exposure_audit.sh` bleibt erhalten.
- Neuer Helfer `scripts/security/listener_audit.py`: standardmaessig nur Plan, `--dry-run` ohne
  Registry-/Hostzugriff; `--stdin` nur bereitgestellte Daten; `--check-host` liest lokales `ss`.
- TCP und UDP, IPv4/IPv6, Wildcards und IPv4-mapped IPv6 werden geprueft. Prozessargumente
  und Scanner-Rohdaten werden nie ausgegeben. Fehlendes `ss`, Formatfehler oder Timeout sind Fehler.
- Registry um K3s 6443 und OpenClaw 18789 ergaenzt, Port-Matrix aus Quelle regeneriert: 47 Ports.
- Nur Loopback ist standardmaessig erlaubt. Private/VPN-Adressen brauchen ausdrueckliche CIDRs;
  `0.0.0.0/0`, `::/0` und oeffentliche Freigaben werden abgelehnt. Wildcards bleiben verboten.
- Unregistrierte Ports werden gezaehlt, nicht als abgesichert ausgegeben. Keine Firewall wird
  geaendert, keine Netzwerkverbindung aufgebaut und kein Dienst gestartet.

```bash
# Nur Plan, keine Installation oder Hostabfrage:
python3 -I -B scripts/security/listener_audit.py --dry-run
# Bewusste lokale Linux-Abnahme; Beispielnetz durch den wirklichen VPN-Bereich ersetzen:
bash scripts/security/port_exposure_audit.sh --check-host --allow-cidr 10.44.0.0/24
# Rueckgabewerte: 0 kein Befund im erfassten Umfang, 1 verbotener Listener, 2 Pruefung unvollstaendig.
```

**Breaking Change:** Der alte Wrapper prueft ohne Argumente weiterhin den Host, gibt bei fehlendem
Werkzeug oder verbotenen Registry-Listenern aber nicht mehr faelschlich Erfolg zurueck.
Automationen muessen Exitcodes behandeln. Die neue Python-CLI selbst plant ohne Argumente nur.

**Grenzen:** Ein Host-Listener ist kein Beweis fuer WAN-Erreichbarkeit; Firewall/VPN-Routing sind
hier nicht gemessen. Umgekehrt sieht `ss` allein keine vollstaendige NAT-/Container-/Kubernetes-
Service-Exposition. Ein Pod darf im eigenen Netznamespace `0.0.0.0` brauchen; entscheidend sind
ClusterIP, NetworkPolicies, hostNetwork/hostPort und Ingress. Kein pauschales Umschreiben auf
127.0.0.1 innerhalb von Pods. `scripts/check_ports.sh` validiert weiterhin nur die Registry:
ein vollstaendiger Registry-/Compose-/Kubernetes-/Installer-Abgleich bleibt offen.

**Rollback:** Keine Laufzeitdateien wurden geaendert. Bei Caller-Inkompatibilitaet P0-A-Commit
gezielt revertieren, keinen Reset/Force-Push verwenden. Einen fehlgeschlagenen Portcheck nicht als
Freigabe behandeln; bis zur Korrektur manuelle Hostabnahme. Nutzdaten und Backups bleiben erhalten.

## 4. Tools und Entscheidungen

Keine zusaetzlichen Tools registriert: ArgoCD/Flux, SOPS/age, OpenBao/Vault, Restic/Velero,
Headscale und Cosign sind bereits teilweise registriert oder geplant. Die Luecke ist vor allem
verifizierter Lifecycle und Betrieb, nicht die Anzahl der Namen. Kein zweites CNI oder Storage-
System ohne Kapazitaets-/Migrationsplan installieren. LLM-Evals erst lokal ohne Providerkosten.

Vor P0-D braucht es die Maintainer-Klassifikation moeglicher historischer Secret-Treffer.
Vor Release-Abnahme fehlen unabhaengiger oeffentlicher Signierschluessel und freigegebene echte
Release-Artefakte. Keine Schluessel im Chat senden. Native Source-Builds bleiben verbindlich,
keine Docker-Installation, kein Cloud-Fallback und keine Kosten erzeugenden Tests.

Testbefehle, PR-Beschreibung und offene CI-Abnahme:
[P0-A-PR-Entwurf](audit/CLAUDE_P0_PR_DRAFT.md).
