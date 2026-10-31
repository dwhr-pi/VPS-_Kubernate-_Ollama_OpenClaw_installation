# Review- und Haertungsrunde: Phase 0

Stand: 31.10.2026. Gepruefte Basis: `b6202e191960f329d7ef300139d796af6a09abe0`
(`main`, anfangs sauberer Arbeitsstand). Die vier zuvor vorbereiteten Minisign-Dateien
sind in dieser Basis bereits enthalten. Dieser Bericht ist keine Produktionsfreigabe.

## Pruefumfang und Grenzen

- Windows mit nativem Git Bash; kein WSL-Zugriff, keine Container, Installer,
  Dienste, Modelle, Wallets, Provider-Aufrufe oder Produktivdeployments gestartet.
- Repository-Dateien und Metadaten gelesen; keine echten Secrets oder privaten
  User-Workspaces gelesen oder geschrieben. Keine Signierschluessel erzeugt.
- `install.sh`, Einstieg und relevante Ausfuehrungspfade von `setup_ultimate.sh`,
  Update-/Rollback-Helfer unter `scripts/lib/`, Backup-/Restore-Pfade unter
  `scripts/operations/` und die vorhandenen CI-Workflows untersucht.
- Automatische Syntax-/Lint-Abdeckung aller getrackten Shell-Dateien ist von der
  manuellen, risikobasierten Stichprobe zu unterscheiden. Nicht jede Zeile aller
  2.176 Shell-Dateien wurde manuell sicherheitsgeprueft.
- Kein aktueller Online-CI-Gesamtstatus oder Branch-Schutz abgefragt. Die fruehere
  PR-6-Abnahme ist kein Nachweis fuer diesen neuen Commit oder diesen Bericht.

## Aktueller Bestand

| Merkmal | Verifiziert | Einordnung gegenueber dem Auftrag |
| --- | ---: | --- |
| Tools | 400 | Nicht mehr 340 |
| Profile | 250 | Nicht mehr 245 |
| Ports in der Registry | 45 | Nicht mehr 44; keine Messung offener Host-Ports |
| Markdown-Dateien vor diesem Bericht | 1.185 | Nicht mehr 1.019 |
| Python-Dateien | 255 | AST-Pruefung, kein Import produktiver Module |
| Python-Testmodule | 171 | Nicht mehr 65; Anzahl ist kein Laufzeitnachweis |
| Getrackte Shell-Dateien | 2.176 | Auch Tests und Einstiegsskripte erfasst |
| Zeilen in `setup_ultimate.sh` | 5.078 | Monolith weiterhin erhebliche Wartungslast |
| Zeilen in `readme.md` | 1.403 | Kurzfassung existiert nur als separater Vorschlag |
| Tools ohne Doctor-/Update-Mapping | je 235 | Nicht mehr je 283; nicht mit fehlender Datei gleichsetzen |
| Tools ohne Status / Profile ohne Status | 73 / 38 | Zusammen 111 Statushinweise |
| Tools ohne Dokumentationsmapping | 221 | Dokument kann trotzdem an anderer Stelle existieren |
| Audit-Fehler / Metadatenhinweise | 0 / 802 | Keine Runtime- oder Sicherheitsentwarnung |

Statusverteilung der Tools: 164 `experimental`, 148 `planned`, 12 `optional`,
2 `stable`, 1 `beta`, 73 ohne Status. Diese bestehenden Aussagen wurden nicht
umgestuft oder als neu abgenommen bestaetigt.

## Tatsaechlich ausgefuehrte Pruefungen

| Pruefung | Ergebnis | Grenze |
| --- | --- | --- |
| `repository_audit.py` | Exit 0; 0 Fehler, 802 Hinweise | Registry, AST, lokale Markdown-Struktur; keine externen Quellen |
| `validate_config.sh` | Exit 0 | JSON-kompatible Registries und semantischer Registry-Check |
| `check_tools.sh` | Exit 0; 48 Quellen-Zuordnungshinweise | Quellenhinweise sind derzeit nicht fatal |
| `check_profiles.sh` | Exit 0; 250 Profile | Referenzen, nicht Installation |
| `check_ports.sh` | Exit 0; 45 eindeutige Registry-Ports | Kein Socket-/Firewalltest |
| `check_profile_registry_sync.sh` | Exit 0; 0 Fehler, 85 Warnungen | Alias-/Legacy- und Dokumentationsdrift bleibt sichtbar |
| `lifecycle_inventory.py --dry-run` | Exit 0 | Top-20-Datei-/Registryinventar, alle Runtime-Nachweise `not-tested` |
| `test_repository_audit.py` | 15 Tests bestanden | Isolierte Fixtures |
| `test_signed_release.py` | 16 Tests bestanden | Minisign gemockt, keine echte Kryptografie-Abnahme |
| `test_minisign_bootstrap.py` | 5 Tests bestanden | APT/sudo gemockt, keine echte Paketinstallation |
| `bash -n`, je getrackter Shell-Datei | 2.176 / 2.176 bestanden | Nur Syntax, keine Ausfuehrung |
| shfmt 3.8.0, alle getrackten Shell-Dateien | 1 Formatabweichung: `scripts/security/ensure_minisign.sh` | Kein automatisches Umformatieren in Phase 0 |
| ShellCheck 0.11.0 mit identischer LF-Konfiguration, alle 2.176 Dateien | 1 Plattformhinweis SC1091; 0 weitere Meldungen, keine Ausfuehrungsfehler | `/etc/os-release` fehlt unter Git Bash; keine Linux-Laufzeitabnahme |
| Lokaler Markdown-Linkaudit nach Dokumentation | 1.186 Markdown-Dateien; 0 Fehler, 0 Hinweise | Keine externen URLs abgefragt |
| Markdownlint und `git diff --check` | Bestanden | Nur geaenderte Dokumentation beziehungsweise Whitespace |

ShellCheck 0.11.0, erster Vollscan: 9.428 ausgegebene Meldungen, davon
5.740 SC1017-Fehler, 1.420 SC1091-Hinweise, 2.262 SC2034- und 6 SC2154-Warnungen.
Das sind nicht 9.428 unabhaengige Sicherheitsluecken: die mitgepruefte
`.shellcheckrc` liegt im Git-Index mit LF, lokal aber mit CRLF vor
(`git ls-files --eol .shellcheckrc`: `i/lf w/crlf`). Wiederholt geladene
Konfiguration und Helfer vervielfachen Meldungen. `.gitattributes` erzwingt
bereits LF fuer `*.sh`, aber nicht fuer `.shellcheckrc`.

Eine zweite Vollpruefung verwendet eine temporaere LF-Kopie der Konfiguration;
Bytegleichheit nach ausschliesslicher CRLF-Normalisierung wurde vorab geprueft.
Keine ShellCheck-Regel wurde entfernt. Der vollstaendige Nachlauf ueber alle
2.176 Dateien ist abgeschlossen: genau eine Meldung SC1091 in
`scripts/install-openhiggsstack.sh:31`, weil `/etc/os-release` unter dem nativen
Windows-Git-Bash fehlt. Keine weiteren Meldungen oder Ausfuehrungsfehler.
Das ist ein dokumentierter Plattformhinweis, keine nachgewiesene fehlerhafte
Ubuntu-Quelle. Ein Linux-Vollscan oder eine aktuelle gruene Gesamt-CI wird
daraus nicht abgeleitet. Der urspruengliche Konfigurationsfehler wurde nicht
durch pauschale Regeln, Severity-Filter oder Erfolgs-Exitcodes verdeckt.

Die Shell-Registrychecks liefen mit einer nur im Pruefprozess exportierten
`python3`-Funktion zum vorhandenen gebuendelten Python. Der erste direkte Versuch
traf den Windows-Store-Alias und scheiterte; die korrigierten Laeufe oben bestanden.
Kein globaler PATH und kein System-Python wurden veraendert.

`doctor.sh` wurde bewusst nur gelesen: Es fragt unter anderem Docker/Podman,
systemd und lokale HTTP-Dienste ab und prueft Pfade im echten User-Workspace
(`scripts/doctor.sh:37`, `scripts/doctor.sh:80`). Das ist laut
[Pruefanleitung](REPOSITORY_QUALITY.md) kein reiner Offline-Check. Ein gruener
Doctor-Lauf wird nicht behauptet. `actionlint` und `bats` wurden lokal nicht im
PATH gefunden; keine neuen Werkzeuge oder Container dafuer installiert.

Reproduktion auf einem geprueften Checkout mit bereits vorhandenen Werkzeugen:

```bash
python3 -B scripts/quality/repository_audit.py
bash scripts/validate_config.sh
bash scripts/check_tools.sh
bash scripts/check_profiles.sh
bash scripts/check_ports.sh
bash scripts/check_profile_registry_sync.sh
git ls-files -z -- '*.sh' | xargs -0 -n 1 bash -n
git ls-files -z -- '*.sh' | xargs -0 shellcheck -x
git ls-files -z -- '*.sh' | xargs -0 shfmt -d -i 2 -ci
```

Der lokale ShellCheck-Lauf verwendet Version 0.11.0, shfmt Version 3.8.0.
Die Windows-Pruefung teilt lange Argumentlisten in Bloecke; shfmt wird dort
mit `-l` inventarisiert. Ein leerer Befund ist erforderlich, Exit 0 von `-l`
allein bedeutet nicht Formatkonformitaet.

## Priorisierte Sicherheitsbefunde

### P0: Datenverlust bei Legacy-Deinstallation

- `scripts/tools/ollama_uninstall.sh:26` loescht `/usr/share/ollama` und
  `/var/lib/ollama` rekursiv mit sudo, ohne Dry-run oder individuellen
  Installations-/Besitznachweis. Stop-/Disable-Fehler werden zuvor unterdrueckt.
  Daten und Modelle koennen verloren gehen; ein noch laufender Prozess ist damit
  nicht verlaesslich ausgeschlossen.
- `scripts/tools/openclaw_uninstall.sh:23` akzeptiert `OPENCLAW_DIR` aus der
  Umgebung; Zeile 99 uebergibt dieses Ziel ohne kanonische Pfad-/Markerpruefung
  an `sudo rm -rf`. Die normale Zustandsloeschung ist zwar standardmaessig
  abgelehnt, `OPENCLAW_UNINSTALL_ASSUME_YES=true` erlaubt aber auch die
  destruktive Rueckfrage (`:35`, `:81`). Der Archivpfad `:72` ist ein
  unverschluesseltes TAR-GZIP, kein verschluesselter Secret-Export.
- Auch `scripts/tools/clawbake_install.sh:28` enthaelt einen rekursiven
  sudo-Loeschpfad. Kein Nachweis, dass die neuen sicheren Update-Helfer diese
  voneinander getrennten Tool-Pfade bereits absichern.

### P0: Reproduzierbarkeit und Supply Chain nur teilweise umgesetzt

- `scripts/tools/ollama_install.sh:26` und `scripts/tools/k3s_install.sh:7`
  fuehren Remote-Skripte direkt aus. Kein fester Payload-Commit/Hash an diesen
  Stellen; Service-Start durch Upstream nicht separat freigegeben.
- `scripts/tools/openclaw_install.sh:34` zieht den beweglichen Branch nach;
  `:46` verwendet `pnpm install` ohne ausdrueckliches `--frozen-lockfile`.
  Entsprechende bewegliche Git-Pfade existieren fuer n8n, ComfyUI, OpenManus und
  Clawbake. Kein Build wurde fuer diese Feststellung ausgefuehrt.
- Blender und FFmpeg nutzen `clone_or_update_github_source` in
  `scripts/tools/helpers/simple_tool_common.sh:180`: Schutz vor fremden Zielen
  ist vorhanden, aber Clone/Pull ohne festen Commit bleibt beweglich. Blenders
  `make update` laedt weitere Upstream-Abhaengigkeiten nach.
- Gegenbeispiel: `config/docker_to_github.json` enthaelt feste 40-stellige Pins
  fuer unter anderem LiteLLM, Qdrant, Grafana, Prometheus und Loki. Deshalb keine
  pauschale Behauptung, alle Installer seien ungepinnt. Ein Rezept-Pin allein
  beweist weder sichere transitive Abhaengigkeiten noch getestete Builds.
- `setup_ultimate.sh:323` initialisiert Strict-Source auf `false`.
  `validate_tool_source_policy` (`:1432`) akzeptiert im allgemeinen Fall bereits
  einen GitHub-URL-Treffer im Skripttext (`:1473`). Das ist keine Integritaets-
  oder Commitpruefung. Forgejo und Comet haben gesonderte Ausnahmevertraege.
  In den durchsuchen Tests/Workflows kein direkter Test des Strict-Schalters
  gefunden; `check_tools.sh --strict-sources` macht Quellenluecken nicht fatal.

### P1: Restore-Erfolg wird zu weitgehend behauptet

`scripts/operations/restore_test.sh:23` listet nur Verzeichnisse auf und meldet
in Zeile 24 bereits einen erfolgreichen Restore-Test. Fehlendes Backup liefert
ebenfalls Exit 0 (`:10-19`). Keine Entschluesselung, Datenruecksicherung,
Pruefsummen-/DB-/PVC-Pruefung oder Wiederanlaufabnahme. Das darf kein
`runtime-verified`-Nachweis sein. Die lexikographische Verzeichnisauswahl in
Zeile 15 kann ausserdem einen Hilfsordner wie `credentials` statt eines datierten
Workspace-Backups auswaehlen; sie validiert weder Typ noch Vollstaendigkeit.

`scripts/operations/backup_run.sh:19` und `:23` behandeln rsync-Fehler hingegen
bereits als Fehler und benennen den Teilbestand. Eine pauschale Ersetzung
angeblicher `|| true`-Backups waere hier falsch. Der lokale Workspace-Backup-
Pfad ist trotzdem nicht insgesamt verschluesselt; die Warnung zu moeglichen
weiteren Secrets steht bereits im Skript. Separater Restic- und Credential-
Export existiert, ersetzt aber keinen konsistenten Anwendungs-Restore-Drill.

### P1: Pruefgruener Code ist nicht automatisch betriebssicher

Die ShellCheck-Konfiguration braucht einen expliziten LF-Vertrag fuer Windows-
Checkouts. Das ist ein separates, kleines Qualitaetspaket zusammen mit der
einzelnen Minisign-shfmt-Abweichung, keine Begruendung zum Abschalten von Regeln.

`setup_ultimate.sh` hat keine eigene globale Strict-Mode-/Trap-Deklaration;
gesourcte Helfer koennen Shelloptionen beeinflussen. Ein blindes globales
`set -euo pipefail` waere fuer die interaktive Fehlerbehandlung riskant.
Unter anderem `next_level_dry_run_check.sh:40` prueft mit mehreren Argumenten
an `bash -n` nicht beide Dateien separat; diese Runde prueft jede Datei einzeln.

`setup_ultimate.sh --dry-run` ist kein belegter nebenwirkungsfreier Einstieg.
Bereits am Anfang werden Sprache/Workspace-Helfer geladen. Deshalb kein Start
dieses Menues auf dem echten Nutzerrechner nur wegen eines Optionsnamens.

## Abgleich der weiteren Auftragsannahmen

| Themenblock | Ist-Befund | Konsequenz |
| --- | --- | --- |
| README empfiehlt unsigniertes main | Widerlegt: sicherer Minisign-Einstieg steht oben; unsignierter Standard ist gesperrt | Sperre nicht fuer einen bequemen One-Liner entfernen |
| Update ausschliesslich reset/clean | Widerlegt fuer aktuellen zentralen Pfad: `repo_safety.py`, `auto_update_hard.sh`, signierter Updater vorhanden | Nicht neu duplizieren; separaten Legacy-Tool-Lifecycle pruefen |
| Integritaetsverfahren nur geplant | Teilweise widerlegt: Export/Pruefer/Minisign-Bootstrap vorhanden | Echte Signatur-/Fresh-Host-Abnahme und Release-Publikation bleiben offen |
| Release-Manifest automatisch erzeugt | `prepare_release.py` existiert, aber kein entsprechender Erzeugungsjob in den untersuchten Workflows gefunden | Keine automatisierte Release-Lieferkette behaupten; privater Signierschluessel bleibt ausserhalb des Repos |
| Alle Actions ungepinnt | Widerlegt: alle gefundenen externen `uses:` sind SHA-gepinnt | Actionlint/Scorecard und transitive Downloads separat behandeln |
| Zusaetzliche CI-/Governance-Gates | In den untersuchten Workflows kein actionlint- oder OpenSSF-Scorecard-Job gefunden; Branch-Schutz nicht online abgefragt | Nicht als bereits eingerichtete oder gruene Gates ausgeben |
| Kein Dependency-Bot | Widerlegt: Dependabot fuer Actions vorhanden | Docker-/Compose-Abdeckung fehlt in dieser Konfiguration |
| Keine Secret-/Config-Scans | Widerlegt: Gitleaks, Trivy fs/config und Gateway-Imagescan in CI | Keine neue Scannerinstallation oder aktuelle CI-Abnahme behauptet |
| Keine Bats-CI | Widerlegt: Bats an festen Commit gebunden, `tests/bats/install_scripts.bats` vorhanden | Ubuntu-/Debian-/ARM64-Fresh-Host-Matrix ist damit nicht belegt |
| Lifecycle voellig fehlend | Teilweise widerlegt: Standard, Inventar und viele native Doctor-/Update-Pfade vorhanden | Top-20-Luecken gezielt schliessen, keine Scheinskripte erzeugen |
| Statusmodell einfach ersetzen | Bestehender Status plus Bereitschaft/Policy in `CURRENT_STATUS.md` | Migration muss Validator und Menue beruecksichtigen; nicht pauschal umstufen |
| Keine IaC | Widerlegt fuer Ansible: `ansible/vps_bootstrap.yml`, Core-Playbook vorhanden | Keine doppelten Playbooks; Oracle-/HE-Provisioning offen, keine `.tf` gefunden |
| Keine GitOps-/Kustomize-Basis | Widerlegt: `k8s/base`, Overlays, `k8s/gitops`, Plan/Apply-Bootstrap vorhanden | Alte YAML bereits als historische Referenz archiviert; kein automatisches Apply |
| Keine K8s-Secrets-Loesung | Widerlegt: SOPS/age-/Sealed-Secrets-Pfade und Vorlagen vorhanden | Rotation, Recovery und echte Controller-Abnahme getrennt pruefen |
| Keine Ressourcen-/Netzwerkregeln | Widerlegt fuer neue Baselines: Limits, PVCs, Probes, Default-deny vorhanden | CNI/Traefik-Selektoren und Positiv-/Negativtests bleiben Live-Abnahme |
| Ein einziges Firewall-Ziel fuer alle Profile | `ansible/vps_bootstrap.yml` sieht SSH/HTTP/HTTPS vor | Generische VPS-Basis nicht mit einem ausschliesslich per WireGuard erreichbaren Hybrid-Knoten gleichsetzen |
| Modelle nach Podwechsel immer neu | Ollama-StatefulSet mit 50-Gi-PVC vorhanden | Node-lokaler Speicher ist damit nicht automatisch hochverfuegbar |
| GPU-Unterstuetzung fehlt ganz | Device-Plugin-/GPU-Overlay vorhanden | Hardware-Abnahme und WoL-bis-Ollama-Kette nicht belegt |
| WoL bereits Health-Gate | `wake-gpu-server.sh` sendet im Apply nur Magic Packet | NodeReady/GPU/Ollama-Readiness mit Timeout fehlt dort |
| Monitoring/LLM-Evaluation fehlt ganz | Monitoring-Dateien, GPU-Bausteine, RAG-/Benchmark-Werkzeuge vorhanden | Echte Latenz, Notifier-Zustellung, Guardrail-Wirkung nicht statisch beweisbar |
| Agent-Isolation nur JSON | `scripts/agents/workbench.py` erzwingt unter anderem Docker `--network none` | Nicht automatisch fuer OpenClaw/OpenManus/n8n mitbewiesen |
| Verzeichnisse einfach vereinheitlichen | `docs/Profil` und `docs/Profile` werden beide vom Setup verwendet | Umbenennung waere Migration mit Kompatibilitaetsrisiko, kein kosmetischer Fix |

Die Kustomize-Basis verweist absichtlich auf `registry.example.invalid` und
`REPLACE_WITH_REVIEWED_PIN`. Sie ist ohne private gepruefte Image-Belegung nicht
direkt produktionsfaehig. Vorhandene Dokumente/Manifeste sind kein Deploy-Nachweis.

`unknown`, `source-ready`, `runtime-verified` und `deprecated` sind derzeit keine
erlaubten `status`-Werte in `scripts/quality/repository_audit.py:16`.
Die vorgeschlagene automatische Eintragung oder Ersetzung waere deshalb eine
Schema-/Menue-Migration, keine folgenlose Metadatenkorrektur. Bereitschaft und
Registry-Reifegrad bleiben bis dahin getrennt.

## Erster vorgeschlagener Patch-Satz

Noch nicht abschliessend geprueft sind die gesamte transitive Build-Lieferkette,
alle Matrix-Generatoren/Driftvertraege, saemtliche `|| true`-Einzelstellen,
Hochrisiko-Profilbestaetigungen, Key-Budgets/Guardrails im realen Requestpfad und
die Isolierung aller Legacy-Agenten. Vorhandene risikobezogene Dokumentation
(`INSTALLATION_RISK_LEVELS.md`) ist kein Beleg technischer Erzwingung. Diese
Punkte bleiben Folgearbeiten, nicht angeblich erledigte Vollpruefungen.

**P0-A: Legacy-Uninstall datenerhaltend und fail-closed.** Separat reviewbar,
vor Supply-Chain- und Infrastrukturumbauten:

1. Ollama/OpenClaw nur ueber kanonische, eng erlaubte Programmziele mit privatem
   Installationsmarker behandeln; fremde, verlinkte oder unbelegte Ziele erhalten.
2. Dry-run als sicheren Einstieg anbieten; Dienstaktionen und Programmdateien
   separat bestaetigen. Keine pauschale Assume-Yes-Freigabe fuer Nutzerdaten.
3. Modelle, Agent-State, ENV und User-Workspace standardmaessig erhalten;
   explizite Datenloeschung gesondert planen statt still mitzuentfernen.
4. Fixtures fuer falschen Owner, Symlink, manipulierten Pfad, fehlenden Marker,
   gescheiterten Dienststopp, Abbruch und wiederholte Ausfuehrung ergaenzen.

Abnahme: kein sudo-rm auf ENV-/fremde Ziele, Dry-run ohne Seiteneffekte,
belegter Datenerhalt, Fehlerpropagierung, Bash/ShellCheck/shfmt und Fixtures gruen.
Breaking Change: unbelegte Legacy-Installationen werden nicht mehr automatisch
entfernt; keine nachtraegliche automatische Besitzuebernahme. Rollback:
Code-Commit gezielt revertieren; keine Datenmigration, alten destruktiven Pfad
nicht als Recovery ausfuehren.

Danach P0-B (Pins/Remote-Ausfuehrung), P0-C (ehrlicher Restore-Vertrag und
isolierter Drill), P0-D (Strict-Source-/CI-Vertrag). Erst nach Freigabe groessere
Registry-Generierung, Statusmigration, GitOps-/IaC- und Verzeichnisumbauten.

## Erledigt / bewusst nicht gemacht / offen

- Erledigt: aktuelle Bestandsmessung, statische Registrychecks, gezielte
  Sicherheitsanalyse, 36 Fixturetests, alle 2.176 Shell-Syntaxpruefungen,
  vollstaendiger ShellCheck-/shfmt-Befund, lokale Dokumentationspruefung,
  belegter Annahmenabgleich und dieser Bericht.
- Bewusst nicht gemacht: Doctor/Installer am echten Host, Secret-/Key-Zugriff,
  echte Backup-/Restore- oder Cloud-Aktionen, Statusumstufungen, Massenumbenennung,
  produktive Cluster-Aenderungen und Installation weiterer QA-Werkzeuge.
- Offen: LF-Vertrag fuer `.shellcheckrc`, Minisign-shfmt-Korrektur,
  actionlint/Bats lokal oder in geeigneter isolierter CI,
  echte Minisign-/Fresh-Host-Abnahme, aktueller Online-CI- und
  Branch-Schutz-Nachweis sowie die oben priorisierten P0-Reparaturen.
- Ausschliesslich ein lokaler Dokumentationscommit; kein Push, keine PR-Erstellung
  und keine Uebernahme von Laufzeitcode durch diese Phase-0-Dokumentation.
