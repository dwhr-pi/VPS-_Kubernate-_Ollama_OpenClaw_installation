# Aktueller Projektstatus

## Infrastruktur-Teilsatz vom 07.11.2026

[Review und drei Diffs](INFRASTRUCTURE_REVIEW_2026-11-07.md): konsistente
Ollama-Inventar-Alerts, explizite Metrics-Auth auch fuer native Gateway-Vorlagen,
ein freigabegesteuerter read-only Audio-MCP-Launcher sowie begrenzte Retries
ausschliesslich fuer die lokale Modell-Inventar-Vorpruefung. Keine Inferenz-POST-
Retries, Cloud-Fallbacks, neuen Hintergrunddienste oder Docker-Installation.
Live-Scrape, Alarmzustellung, Client-Handshake, GPU und PVC-Restore bleiben offen;
kein allgemeines Sandbox-/Produktionsversprechen oder Registry-Readiness-Upgrade.

## Deklarative Einstiegspfade vom 03.11.2026

[GitOps-Pfad](GITOPS_DEPLOYMENT_PATH.md): additive Kustomize-Einstiege, private DNS01-/VPN-
Ingress-Option, `/api/tags`-Probes, authentifizierte Gateway-Metriken und selektierbare Operator-
Monitors/Rules. Exporter bleibt bei null Replikaten; GPU-Metriken benoetigen separate DCGM-Abnahme.
Neuer Setup-Einstieg plant standardmaessig nur. CI- und manuelles Staging sind konfiguriert,
nicht als bereits erfolgreich ausgefuehrt freigegeben. Frisches K3s-Source-Provisioning,
Live-Netz/TLS/Secret-/GPU-/Restore-Nachweise bleiben offen. Keine Docker-Installation.

## Gesamtinventar und P1-Nachvalidierung vom 03.11.2026

[Gesamtaudit](audit/EXECUTIVE_SUMMARY.md) und alle zehn Auditbereiche werden gegen den lokalen
Arbeitsstand abgeglichen. Das Inventar erfasst 400 Tools/250 Profile, Status-Skript-Mappings,
Dateihashes einschliesslich untracked Dateien und statische Testreferenzen, ohne Runtime-Hochstufung.
SEC-009-Dateimetadaten werden bei Profil-Wiederholung nachvalidiert; keine automatische chmod-/chown-
Migration. Die kuratierte Offline-Testsammlung wurde erweitert. Echte Restore-/Inferenz-/ACL-/GPU-
und Produktionsabnahmen bleiben davon getrennt offen. Keine neuen Tools, Docker-Installation oder Dienste.

## Ressourcen-/GitOps-Abgleich vom 03.11.2026

[Architekturabgleich](LLMOPS_ARCHITECTURE_INCREMENT_2026-11-03.md): Gateway, Monitoring,
SOPS-/Secret-Helfer und GitOps waren bereits vorhanden. Gezielt ergaenzt sind ein kleines
CPU-VPS-Namespace-Budget, expliziter PVC-Erhalt in der Basis sowie CPU-/RAM- und zeitlich
begrenzte Runtime-Vorpruefungen im vorhandenen Install-/Update-Pfad. Keine neuen Hintergrunddienste,
keine Docker-Installation, kein Cluster-Apply und keine Runtime-/Produktionsfreigabe.

## F01-F07-Teilsatz vom 03.11.2026

[Installationsrichtlinie](INSTALLATION_POLICY.md): Git-Quellbuilds bleiben Standard,
keine Docker-Installation und kein Docker-Fallback. [Patchsatz und Grenzen](F01_F07_IMPLEMENTATION.md):
datenbewahrender K3s-/Clawbake-Legacy-Guard, native ArgoCD-/cloudflared-Buildrezepte,
private atomische ENV-Ausgabe, redigierte History-Triage, native Monitoring-Konfiguration
und Restic-Export-/Datei-Restore-Pruefpfad. Keine echte Schluesselrotation,
Alarmzustellung, Datenbank-/PVC-Wiederherstellung oder generelle Produktionsfreigabe.

## OpenClaw-Quellenschutz und Tool-Reihenfolge vom 02.11.2026

Auch der OpenClaw-Legacy-Installer ist jetzt vor Clone/Pull, `/opt`-Aenderungen,
Paket-Hooks und Statusuebernahme gesperrt; siehe [P0-B](P0_B_CORE_SOURCES.md).
Dies ist ein Plan-/Quellenpruefpfad, kein fertig abgenommener Ersatzbuild.
Die [Tool-Sortierung](tools/TOOL_MENU_ORDER.md) umfasst wieder den gesamten
vorhandenen Menuebestand nach der Trennlinie. Neue Schluessel bleiben kuenftig
als Anhang hinter Z; die ersten drei Eintraege bleiben unveraendert.

## P0-B-Quellenschutz vom 01.11.2026

[Erster Core-Quellenschutz](P0_B_CORE_SOURCES.md): Die zwei alten Ollama-/K3s-
Direktinstaller fuehren keine veraenderlichen Internet-Skripte mehr aus.
Standard ist nur ein Plan; optionale Offline-Bytepruefung ist keine Installation.
Breaking Change: automatische Installation dieser zwei Legacy-Einstiege gesperrt.
Auch Basis-/VPS-Legacy-Assistenten delegieren vor Systemaenderungen an die Sperre;
keine Umgehung ueber deren bisherige zweite Vendor-Pipes.
Vorhandene Programme, Daten und Status bleiben erhalten. OpenClaw-Installer,
authentisierte Buildvertraege und Service-Abnahme bleiben offen. Der dort noch
offene OpenClaw-Schutz ist durch die oben genannte Fortsetzung inzwischen umgesetzt;
eine produktionsfaehige OpenClaw-Ersatzinstallation ist weiterhin nicht abgenommen.

## P1-P3-Teilsatz vom 01.11.2026

[Umsetzung und offene Abnahmen](P1_P3_IMPLEMENTATION.md): getrennte beleggebundene
Bereitschaft, generierte Registry-Matrizen, frueher Offline-Dry-Run, Datei-Restore-
und Pi/GPU-Fixtures, optionale lokale Gateway-Policy und gekuerzte README.
Kein echter Host-/Cluster-/Inferenztest und keine pauschale Produktionsfreigabe.
Der alte verzeichnislesende Restore-Test ist ersetzt; der unbelegte Idle-Shutdown
ist gesperrt. P0-Supply-Chain, Lifecycle-Vervollstaendigung und echte PVC-/DB-Restores
bleiben offen. Die folgenden datierten Befunde bleiben als Historie erhalten.

## P0-A-Schutzpatch vom 01.11.2026

[Legacy-Core-Uninstall-Schutz](P0_A_CORE_UNINSTALL.md): Ollama/OpenClaw werden
ohne belegten Besitzvertrag nicht mehr automatisch entfernt. Standard ist eine
rein lesende Vorschau; Status und Autostart bleiben erhalten. Das ist eine
bewusste Sicherheitssperre, kein fertig abgenommener neuer Uninstaller oder
Migrationspfad. Installer/Supply-Chain und andere Tools bleiben getrennte Aufgaben.

## Neue Bestandspruefung vom 31.10.2026

Basis `b6202e191960f329d7ef300139d796af6a09abe0`: 400 Tools, 250 Profile,
45 Registry-Ports; Offline-Projektcheck mit 0 Fehlern und 802 Metadatenhinweisen.
Die [Review- und Haertungsrunde, Phase 0](REVIEW_FINDINGS.md) trennt aktuelle
Codebefunde von den nachfolgenden historischen Nachweisen. Legacy-Uninstall,
bewegliche Quellinstaller und ein nur verzeichnislesender Restore-Test bleiben
prioritaere Risiken. Keine Runtime-/Produktionsfreigabe und keine automatische
Statusumstufung; groessere Registry-/GitOps-Umbauten benoetigen eine Freigabe.

[Plattform-Review vom 26.10.2026](reviews/2026-10-26-platform-patch-plan.md): 385 Tools, 245
Profile, vollstaendige Metadatenmatrizen und priorisierte PRs. Historische Nachweise unten bleiben
unveraendert; keine Runtime-Freigabe daraus.

## Nutzer-Rueckmeldung vom 26.10.2026

Der Nutzer meldet erfolgreiche Installationen der von ihm geprueften Tools. Schwergewichtige Tools
wurden wegen des freien Speicherplatzes noch nicht geprueft. Eine vollstaendige Liste mit
Pins/Plattform-/Funktionstests liegt hierzu nicht vor; keine automatische Produktionsfreigabe oder
Aenderung von Installationsmarkern. Alle Tools unterhalb der Trennlinie sind wieder A-Z einsortiert,
einschliesslich Browser-, Studien- und Perplexity-Eintraegen.

## Dokumentierter Repository-Nachweisstand

Stand: **23.10.2026**, Basis `0305ca6fcb8c349b2ea04b83a62051acdbc83e30`. Kanonischer Einstieg fuer
den **Nachweisstand**, keine automatische Umstufung der Registry und keine Aussage ueber
installierte Programme auf deinem Rechner.

## Kurzfassung

- Repository-Metadatencheck: 366 Tools, 245 Profile, 44 Port-Eintraege; 0 strukturelle Fehler, aber
  953 Hinweise. Details im [Audit](AUDIT_2026-10-23.md).
- Kein gruener vollstaendiger lokaler Testlauf: Zeitlimit und reproduzierbarer
  Aegisub-Fixture-Fehler. Neun Bash-Kernpfade syntaxgeprueft; 13 Audit-Fixtures bestanden.
- [Freigegebenes P0-Codepaket](P0_SAFETY_CHANGES.md): verifizierte Update-Sicherung, PAT ohne
  Token-URL und datenerhaltender gemeinsamer Compose-Uninstall lokal umgesetzt. 21 P0-Fixtures
  bestanden, ein POSIX-Test unter Windows uebersprungen; Ubuntu-24.04-VM-Abnahme steht aus. **Keine
  Produktionsfreigabe.**
- Historische Credential-Befunde, signierte Release-Kette und weitere Legacy- Installationspfade
  bleiben offen; das P0-Paket ist keine repo-weite Entwarnung.
- Doctor-/Update-Dateien, Source-Pins und Status fehlen bei vielen Legacy-Eintraegen. Ein
  vorhandener Installer, ein Quellcheckout oder ein Marker beweist keine Runtime.

## Drei getrennte Achsen

| Achse        | Werte und Bedeutung                                                                                                                  |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| Reifegrad    | `stable`, `beta`, `optional`, `experimental`, `planned`: Registry-Aussage, nicht automatisch neu verifiziert                         |
| Bereitschaft | `not-tested`, `source-ready`, `runtime-ready`: benoetigt einen konkreten Test-/Artefaktnachweis fuer genau die Version und Plattform |
| Policy       | manuell gewaehlt, opt-in, gesperrt: folgt Risiko und Voraussetzungen; kein automatischer Installationsauftrag                        |

`experimental` ist kein Ersatzwort fuer `source-ready`. Ein stabiler Quellcheckout kann vorhanden
sein, waehrend die Runtime fehlt. Einen Alias oder Legacy-Einstieg nicht loeschen und nicht als
zweites erfolgreich installiertes Tool zaehlen.

## Top 20 reproduzierbar pruefen

```bash
python3 -B scripts/quality/lifecycle_inventory.py --dry-run
python3 -B scripts/quality/lifecycle_inventory.py --json
python3 -B scripts/quality/lifecycle_inventory.py --tool ollama --tool openclaw --strict
```

Unter Windows ist dasselbe Skript mit vorhandenem `py -3 -B` nutzbar, ohne WSL. Alle Varianten lesen
nur Repository-Metadaten und schreiben keine Dateien. `--strict` liefert bei Luecken Exitcode 1; ein
normaler Inventarlauf darf sie anzeigen. Das ist **kein Doctor-Ersatz** und implementiert noch keine
fehlenden Update-/Uninstall-Wege.

Auswahl: Ollama, OpenClaw, WireGuard, K3s, LiteLLM, Qdrant, n8n, Flowise, Prometheus, Grafana, Loki,
OpenTelemetry, Uptime Kuma, Langfuse, Restic, Gitleaks, Trivy, ComfyUI, Whisper_CPP und Piper.

## Navigation statt widerspruechlicher Statuskopien

- [Erste 60 Minuten](FIRST_60_MINUTES.md): sicherer Offline-Einstieg.
- [Lifecycle-Vertrag](TOOL_LIFECYCLE_STANDARD.md): Pflichten und Abnahme.
- [Grok-Auswertung mit Kandidatenstatus](tutorials/grok-repo-review-2026-10-23.md).
- [P0-P3-Umsetzungspakete](ROADMAP_NEXT.md): noch offene Haertung.
- [Fruehere Testmatrix](TESTED_STATUS_MATRIX.md) und [Profilmatrix](PROFILE_STATUS_MATRIX.md):
  bisherige Einordnung, keine aktuelle Live-Abnahme.
- [Tool-Abgleich](TOOL_SETUP_AUDIT.md): Menue, Registry und Dokumentation getrennt.

Die lange README bleibt vorerst als kompatible Link-/Ankeruebersicht erhalten. Ihre vollstaendige
Kuerzung sowie Alias-/Profilmigration sind gesonderte Aufgaben; dieses Paket benennt keine alten
Profile um und entfernt keine Einstiegslinks.
