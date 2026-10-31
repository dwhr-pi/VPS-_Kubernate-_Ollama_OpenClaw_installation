# Platform-Review: 27.10.2026

## Umfang und Ergebnis

Dies ist ein **P0-Teilpaket**, kein Abschluss aller 16 angeforderten Aufgaben und keine
Produktionsfreigabe. Bearbeitungsbranch: `codex/platform-hardening-2026-10-27`. Geprueft wurde lokal
unter Windows mit nativem Python/Git und Git Bash. Keine Installationen, Clusterzugriffe,
Cloud-Aufrufe, Modellstarts oder Zugriffe auf echte Zugangsdaten. Testschluessel/-signaturen sind
ausdrueckliche Mocks.

Die Entscheidung des Nutzers lautet: **Minisign, oeffentlicher Schluessel separat bereitgestellt**.
Es liegt hier weder ein solcher Vertrauensanker noch eine abgenommene signierte Release-Serie vor.
Daher kein freigegebener Release-Start.

## Aenderungen

| Bereich            | Implementierter Stand                                                                                                                              | Grenze                                                                            |
| --- | --- | --- |
| Release-Einstieg   | `verify_release_and_install.sh`: ausdruecklicher Tag, Minisign, SHA256, Commitvergleich, isolierter Clone                                          | Bootstrap/Pruefhelfer muessen vorher vertrauenswuerdig sein                       |
| Pruefung           | `scripts/security/release_manifest.py`: private Dateimomentaufnahme, strenger Dateivertrag, doppelte JSON-Schluessel abweisen                      | Tests mocken Minisign; keine echte Signaturabnahme                                |
| Maintainer-Export  | `scripts/security/prepare_release.py`: Metadaten/Installer/Summen aus lokalem Tag, neues externes Ziel                                             | Signiert und veroeffentlicht nichts                                               |
| Standard-Update    | `scripts/security/update_verified_release.py`: lokaler Plan, explizites Apply, verifizierte Sicherung vor Fetch, Tagvergleich, kein Force-Checkout | Kein Runtime-Migrationsnachweis; Linux-Apply nicht ausgefuehrt                    |
| Git-Isolation      | `scripts/lib/repo_safety.py`: keine globale/System-Konfiguration, keine geerbte Repo-/Index-/Config-Umleitung oder Git-Traces                      | Lokale Konfiguration wird fuer den Release-Pfad zusaetzlich eingeschraenkt        |
| Altpfade           | Direktstart von `install.sh` verlangt ausdruecklichen Legacy-Schalter; Repair bleibt getrennt                                                      | Unsignierter Altpfad weiterhin vorhanden, keine gleichwertige Sicherheitsgarantie |
| CI                 | Bekannte SHA-Pins aus dem Bestand fuer Checkout/Setup-Python vereinheitlicht, Dependabot, Trivy-Config-Gate, Release-Vertragstests                 | Nicht alle fremden Actions bereits SHA-gepinnt; kein CI-Lauf hier                 |
| Fehlersichtbarkeit | Vier `\|\| true` an Lint-/Scan-Aufrufen in `.github/workflows/ci.yml` entfernt | Bestehende Befunde koennen CI jetzt blockieren; keine Fehlerunterdrueckung |
| Anleitung          | Primaerer Einstieg im `readme.md` und [Signaturverfahren](SIGNED_RELEASES.md) angepasst                                                            | Gesamtkonsolidierung der README weiterhin offen                                   |

Nutzerdaten und die bisherige Repo-Backup-/Repair-Logik wurden nicht entfernt. Ein unveraenderter
oder ausgecheckter Versionsstand bedeutet nicht, dass die verwalteten Anwendungen installiert,
migriert oder getestet wurden.

## Nachweise

| Offline-Pruefung                                                                | Ergebnis                                                                                                                                                                |
| ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `python -B -m unittest discover -s tests -p test_signed_release.py -v`          | 16 erfolgreich: Signaturfehler, Hashabweichungen, Metadatenvertrag, Dateimomentaufnahme, Git-Umgebung, Export und Update-Reihenfolge                                    |
| `python -B -m unittest discover -s tests -p test_secure_core_refactor.py -v`    | 10 Tests: 9 erfolgreich, 1 Linux-Dateirechtetest ausgelassen                                                                                                            |
| `python -B -m unittest discover -s tests -p test_p0_safety.py -v`               | 22 Tests: 19 erfolgreich, 1 POSIX-Symlinktest ausgelassen, 2 Git-Bash-Timeouts nach jeweils 30 Sekunden; Gesamtlauf fehlgeschlagen                                      |
| `bash -n`                                                                       | Erfolgreich fuer `install.sh`, `verify_release_and_install.sh`, `scripts/update_setup_only.sh`, `scripts/check_setup_updates.sh`; weitere Syntaxchecks durch Core-Tests |
| `git diff --check`                                                              | Erfolgreich                                                                                                                                                             |
| ShellCheck, shfmt, kubeconform, kube-linter, yamllint, markdownlint             | Nicht ausgefuehrt; keine behauptete Abnahme                                                                                                                             |
| Echte Minisign-Gegenprobe, Ubuntu-24.04-VM, ARM, GitHub Actions, Trivy/Gitleaks | Nicht ausgefuehrt                                                                                                                                                       |

Die beiden Timeouts betreffen `test_uninstall_retains_files_and_never_removes_volumes` und
`test_wrong_owner_marker_is_refused`. Timeoutgrenzen und Assertions wurden nicht abgeschwaecht.
Daraus folgt weder eine bestaetigte Funktionsregression noch ein gruener P0-Gesamtnachweis. Im
gezielten Wiederholungslauf war die falsche Besitzmarkierung erfolgreich geprueft; der zweifache
datenerhaltende Uninstall erreichte erneut das 30-Sekunden-Limit. Damit bleibt dieser Nachweis
offen.

## Priorisierte Restliste

| Auftrag                              | Prioritaet / Stand                          | Noch notwendige Arbeit                                                                                                                                                  |
| ------------------------------------ | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1. Vollstaendiger Installer-Audit    | P0, teilweise                               | Gesamte manuelle Zeilenpruefung von `setup_ultimate.sh` und allen Seiteneffekten abschliessen; kein blindes globales Strict-Mode-Refactoring interaktiver Dialoge       |
| 2. Signierter Einstieg               | P0, source-ready / offline-Vertrag getestet | Unabhaengigen Public Key bereitstellen, reale Signatur-Gegenprobe, signierte Release-Assets und Ubuntu-Abnahme                                                          |
| 3. Verifizierte Updates              | P0, source-ready / offline-Vertrag getestet | Linux-Restore-/Update-Drill inklusive abgebrochenem Fetch und verschobenem Tag; Aufrufer/Menue-Abnahme                                                                  |
| 4. CI/Supply Chain                   | P0, teilweise                               | Unabhaengige SHA-Pruefung fuer Gitleaks-, Markdownlint- und Linkcheck-Actions; bestehende Befunde abarbeiten; Branch-Schutz ausserhalb dieser Offline-Arbeit einrichten |
| 5. Kustomize oracle-control/home-gpu | P1, offen                                   | Vorhandene Base/production/vps-cpu-Bausteine gegen Altmanifeste abgleichen; Ziel-Overlays und alle Workload-Policies wirklich rendern/validieren                        |
| 6. Private APIs / NetworkPolicies    | P1, offen                                   | Bestehende Regeln auf echte CNI-Wirkung und alle Pfade pruefen; API-/Gateway-Exposition mit positiven und negativen Tests absichern                                     |
| 7. TLS/Secrets opt-in                | P1, Bestand, nicht erneut abgenommen        | SOPS/age und vorhandenen Traefik-Pfad zu einem expliziten Profil zusammenfuehren; reale Schluessel bleiben ausserhalb dieser Arbeit                                     |
| 8. GitOps opt-in                     | P1, Bestand, nicht erneut abgenommen        | Vorhandenen Argo-Core-Pfad und AppProject weiterverwenden statt zweiten Controller einzufuehren; Abnahme in Wegwerf-Cluster                                             |
| 9. Backup/Restore-Drill              | P1, offen                                   | Restic-/Velero-Bestand mit isoliertem, wiederholbarem Restore-Drill verbinden; Backup-Dateien allein sind kein Nachweis                                                 |
| 10. Pi-WoL-Health-Gate               | P1, offen                                   | WoL-Bestand um SSH, NodeReady und Ollama-Readiness mit Deadline/Backoff erweitern; Idle-Abschaltung an aktive Jobs koppeln                                              |
| 11. NVIDIA/DCGM opt-in               | P1, offen                                   | Gepinnte Manifeste und getrennte Freigaben, Plattform-/GPU-Nachweis; kein automatischer Treiberwechsel                                                                  |
| 12. Alerts/externe Erreichbarkeit    | P1, offen                                   | Ein Benachrichtigungskanal, belegte Metriknamen, GPU-/Latenz-/Zertifikatsregeln und externer Pi-Heartbeat; keine Annahme eines nativen Ollama-`/metrics`                |
| 13. Top-20-Lifecycle-Vertrag         | P2, offen                                   | Bestehendes Inventar ist kein Pflichtfeldvalidator; Pins, Doctor/Update/Uninstall und ehrliche Statuswerte pro Tool ausfuellen                                          |
| 14. Fresh-Host-Smoke                 | P2, offen                                   | Vorhandene Offline-CI ist kein frisch installierter Host; isolierte Ubuntu-/ARM-Abnahme ohne persoenliche Daten                                                         |
| 15. README unter 200 Zeilen          | P2, offen                                   | Linkerhaltende Konsolidierung und historische Kennzeichnung, nicht einfach alte Inhalte loeschen                                                                        |
| 16. Queue/Worker                     | P2, offen                                   | Bestehende Queue auf cgroup-/Prozessbaumgrenzen, Neustart-Recovery, Retry/Cancel und SQLite-Parallelitaet unter Linux pruefen                                           |

## Konkrete offene Risiken

1. Unsignierte Legacy-Einstiege sind explizit erreichbar. Die neue Release-Pruefung haertet nicht
   automatisch alle darunter gestarteten Tool-Installer.
2. `.github/workflows/ci.yml`, `secret-scan.yml` und `repo-health.yml` verwenden weiter
   `gitleaks-action@v2`; Markdownlint-/Linkcheck-Actions ebenfalls mutable Tags. Ohne erlaubten
   Upstream-Abgleich werden hier keine SHAs erfunden.
3. Der neue Trivy-Config-Job und die nun verbindlichen Altpruefungen koennen vorhandene
   Konfigurations-/Dokumentationsfehler melden. CI ist nicht als gruen abgenommen, und das gesamte
   Projekt ist nicht pauschal sicherheitsgeprueft.
4. Repo-Sicherungen koennen private Inhalte enthalten. Bestehende private Dateirechte bleiben
   wichtig; diese Arbeit verschluesselt sie nicht nachtraeglich.
5. Netzwerkexposition, Restore und GPU-/WoL-Verhalten benoetigen isolierte Laufzeittests. Statische
   Dateien sind kein Beleg fuer einen sicheren Betrieb.
