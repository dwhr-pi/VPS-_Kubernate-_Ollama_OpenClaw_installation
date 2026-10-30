# Aktueller Projektstatus

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
