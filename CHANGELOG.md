# Changelog

## Unreleased

### 2026-10-29: Health-Ausfuehrungsrecht und explizite Overlay-Sicherheit

- Secret-Scan-Wrapper startet den Helper explizit mit Bash; 0600-Fixture
  testet Argumente und Fehlerweitergabe ohne Zugriff auf echte Zugangsdaten.
- Globale ShellCheck-Source-Aufloesung und Gitleaks-Vertraege synchronisiert;
  keine Regeln abgeschaltet. Overlay-SecurityContexts entsprechen der Basis,
  beide betroffenen Kustomize-Ausgaben bleiben bytegleich.
- Globale Lint-/Linkfehler und das alte Kubernetes-Gesamtmanifest bleiben
  Merge-Blocker; keine automatische Produktions- oder main-Freigabe.

### 2026-10-29: Zweiter CI-Reparatursatz

- Native-CLI-Fixture-Pfade auch unter macOS kanonisiert; Symlink-Sperre bleibt.
- Health-ShellCheck verfolgt Queue-Hilfsdateien statt SC1091 zu unterdruecken;
  TSV-Prioritaet und expliziter Python-Interpreter bleiben unveraendert wirksam.
- Zusaetzliche Python-Override-Tests; volle GitHub-Regression am vorherigen
  Reparatur-Commit gruen. Globale Lint-/Trivy-/Link-Befunde bleiben offen.

### 2026-10-29: Erste CI-Reparaturen vor PR-6-Abnahme

- macOS-Fixtures kanonisieren temporaere Pfade; Gitleaks erhaelt vollstaendige
  Git-Historie und einen festen Action-Commit, ohne Scan-Fehler zu ignorieren.
- Runner-unabhaengige Inventar-Fixtures und aktualisierte Source-/Statusvertraege;
  falsche Coding-Marker bleiben ungueltig, produktive Schutzpruefungen unveraendert.
- Fehlende oeffentliche Platzhalterbeispiele ausserhalb ignorierter Secret-Ordner
  ergaenzt. Shell-/Markdown-/Link- und Trivy-Befunde bleiben explizit offen.

### 2026-10-29: Linux-Registry-Verweis korrigiert

- Monitoring_Observability verweist auf die tatsaechlich kleingeschriebene
  Datei docs/Profile/monitoring_observability.md; kein Umbenennen von Nutzdaten.
- Registry-Audit prueft Dateinamen und Verzeichnisnamen jetzt auch unter
  Windows exakt auf Gross-/Kleinschreibung; plattformuebergreifende Regression.

### 2026-10-29: Dokumentations-Wegweiser und Branch-Abnahme

- docs/readme.md als Themen- und Statusuebersicht ergaenzt, ohne historische
  Dokumentation umzubenennen oder Produktionsreife aus Beschreibungen abzuleiten.
- Konkreter Abnahmeplan fuer Setup/Menue, Offline-Tests, temporaeren
  Profil-Lifecycle und getrennte echte Agenten-/Modelltests vor main.
- Lokale Link-/Testverweispruefung in CI ergaenzt; kein Main-Merge oder Deploy.

### 2026-10-29: Explizite Entwicklungs-Branch-Auswahl

- Unsignierter Opt-in-Installer bietet main, den Coding-Agenten-Featurebranch
  und frei eingegebene kuenftige Branches; kein stiller main-Fallback.
- Featurebranches erhalten getrennte Checkout-Ordner, exakte Head-/Commitpruefung
  und nur saubere Fast-Forward-Updates nach Sicherung. Nutzworkspace bleibt erhalten.
- Signierter Release-Pfad und Sperre ohne Opt-in bleiben unveraendert;
  Offline-Regressionen und Bedienungsanleitung ergaenzt. Kein Installer gestartet.

### 2026-10-29: Optionale lokale Coding-Agenten

- Belegte Bestandsmatrix fuer sieben Clients, getrennte Nachweisstufen und
  ehrliche Lizenz-/Providergrenzen statt pauschaler OSS-/Produktionszusage.
- OpenCode, Aider und Codex CLI mit gepinnten nativen Lifecycle-Vertraegen;
  OpenHands-SDK nur als Quellen, Qwen-Build unveraendert. Keine Installation.
- Fuenf unabhaengige lokale Profile und expliziter Einmalworker mit Docker-
  Netzwerkisolation, Ressourcenlimits und begrenztem Loopback-Ollama-Broker.
- Getrennte Worktrees, Read-only-Rollen, private begrenzte Ergebnisdateien,
  datenerhaltende Deaktivierung und Offline-CI; reale Build-/Modellabnahme offen.

### 2026-10-29: Belegtes Gesamtaudit und kleine Schutzmassnahmen

- Zehn Audit-Dokumente und reproduzierbares JSON-Inventar fuer Tools, Profile
  und Repository-Integrationsdateien, ohne Runtime- oder Produktionszusage.
- Unsichere Workspace-Komplettloeschung gesperrt; Update/Uninstall verlangen
  registrierte, nicht verlinkte Lifecycle-Pfade. Kein impliziter Reinstall.
- Credential-Backup-Budgets fuer Klartext/TAR/Ciphertext abgestimmt; Scanner-
  Fehler nicht mehr als sauberer Scan, keine externe Credential-Verifikation.
- Compose-LiteLLM-Environment korrigiert, automatischer Cloud-Fallback entfernt;
  private Konfigurationskopie und Retentionsmarker fuer Monitoring-Storage.
- Vorhandene Inventarpruefungen erweitert und deterministische RAG-Auswertung
  samt synthetischen ACL-/Ranking-Fixtures ergaenzt. Kein Tool installiert.

### 2026-10-29: Optionale GPU- und Betriebsbausteine

- GPU-Overlay auf bestehender Kubernetes-Basis, getrennte Agent-PVCs,
  NVIDIA-Plugin-Werte, Secret-Wrapper und offline erzeugbarer HTTPS-Ingress.
- Planbasierte, SHA256-pruefende Helm-Wege fuer NVIDIA und Monitoring;
  keine Treiberinstallation, Cluster-Aenderung oder Modelle ohne Freigabe.
- Authentifizierter ServiceMonitor und Loki-Netzwerkgrenze, kein erfundener
  Ollama-Metrikendpunkt und keine neue Promtail-Installation.
- CI baut, scannt und veroeffentlicht ein gepinntes Gateway-Image bei passendem
  Main-Push; kein automatisches Deployment. Native Installer bleiben erhalten.
- Legacy-Proxy-Key aus URL entfernt, Fallback-Streaming korrigiert und
  LoadBalancer durch ClusterIP ersetzt (Zugriffsaenderung bei erneutem Apply).
- Transaktionswrapper mit privater umask und Python-Preflight; keine
  pauschale Loesch-/Rollback-Logik fuer vorhandene Daten.

### 2026-10-28: GitOps-Planung ohne falschen Installationsfehler verschieben

- Leere, nur aus Leerzeichen bestehende und CRLF-Eingaben sowie EOF beim
  gefuehrten GitOps-Plan als Verschieben behandeln; kein Installationsmarker.
- Ungueltigen Artefakt-Dateipfad vor der zweiten Frage abweisen. Die strengen
  Inhalts-/Apply-Freigaben und die Windows-Host-Speicherreserve bleiben erhalten.
- Eingabewartezeit im Log erklaert; Offline-Regressionen ohne TTY-/Clusterzugriff.

### 2026-10-28: Gemini-Desktop-Projekte getrennt eingeordnet

- Bwendell- und Dortanes-Desktop/Legacy-Eintraege sowie separate gepinnte
  Studienquellen ohne Docker im A-Z-Tools-Menue ergaenzt.
- Gemini-Webwrapper sind keine CLI-/OpenClaw-Clients; Pflegepause, Archivierung,
  Release-Pruefung und bekannte Dortanes-Sicherheitsflags dokumentiert.
- OpenClaw-eigene Desktopansicht, Windows-/WSL-Terminalweg und Adapterplan
  beschrieben; kein automatischer Build, Login, Modell- oder EXE-Start.

### 2026-10-28: Open-WebUI-OpenAPI-Toolserver

- OpenAPI_Servers aus gepinntem GitHub-Stand im A-Z-Menue; private Linux-/WSL-
  Zeitserver-Umgebung ohne Docker, uv privat nur nach Zustimmung.
- Separate Konfiguration/Key-Anzeige und expliziter Loopback-Start mit Bearer-
  Pflicht; kein automatischer WebUI-, Filesystem-, SQL- oder Tokenzugriff.
- Einrichtung, Netzwerkraeume, CORS, Abhaengigkeits-Lock und datenerhaltende
  Deinstallation dokumentiert; Installations-/End-to-End-Abnahme offen.

### 2026-10-28: KI-GameDev, XR und Wallpaper

- Godot_Source, optionaler Godot_Build fuer Linux, Godot_XR_Tools sowie getrennte
  O3DE_Source-/Lively_Wallpaper_Source-Eintraege im Tools-Menue und in der Registry.
- Gepinnte GitHub-Quellen ohne Docker; schwere Builds nur explizit, keine GUI,
  Modelle, Headsets, Desktop-Autostarts oder automatischen SDK-Installationen.
- Anleitung zu Unity/Unreal, Valve Index/OpenXR, AR, Plattformexporten und
  Wallpaper-/Screensaver-Grenzen. Installation und Hardwarebetrieb ungeprueft.

- Plattform-Review mit P0/P1/P2-Patchplan, vollstaendigen Registry-Matrizen,
  readonly Inventarreporter und inaktiven Health-/CI-/K8s-Security-Beispielen.
  Keine produktiven Deployments, Profile oder Secrets geaendert; keine neue
  pauschale stable-/Runtime-Freigabe.

- Perplexity-SDK-Deinstallation: Schreibschutz im geprueften eigenen Runtime-
  Bestand begrenzt behandeln, keine Linkziele/fremden Eigentuemer umstellen.
  Explizites --resume-uninstall fuer unveraenderte Inventarreste nach teilweisem
  Abbruch; Nachweis erst nach erfolgreicher Entfernung loeschen, Toolchains behalten.

- Tools-Menue wieder durchgehend A-Z unterhalb der Trennlinie sortieren,
  einschliesslich Browser-/Studien-/Perplexity-Tools; Kernbereich beibehalten.
  Nutzer meldet erfolgreiche getestete Installationen; schwergewichtige Tools
  bleiben wegen Speicherplatz noch ungeprueft, keine pauschale Runtime-Freigabe.

- Perplexity Python/Node: Bazel-Output und Repo-Contents-Cache ausserhalb des
  Quell-Workspaces in getrenntem temporaerem Buildverzeichnis anlegen.
  Artefakte vor Bereinigung uebernehmen, externe Verweise ablehnen und nur
  eigene temporaere Bazel-Links entfernen. Gepruefte Toolchains beibehalten.

- Perplexity Python/Node: pnpm 11.17.0 als vollstaendiges GitHub-Release-Bundle
  statt einzelner Startdatei uebernehmen. dist/pnpm.mjs, Worker und weitere
  Begleitdateien bleiben erhalten und werden bei Wiederverwendung mitgeprueft.
  Unvollstaendige Archive vor Ausfuehrung ablehnen; Bazel-/Node-Basen erhalten.

- Browser_Use: fehlende upstream uv.lock am unveraenderten GitHub-Pin lokal
  und ausdruecklich protokolliert erzeugen, danach frozen synchronisieren.
  Lock-Herkunft/SHA256 im Installationsnachweis erfassen, fehlende/leere oder
  beim Sync geaenderte Locks ablehnen; erste Aufloesung nicht als vollstaendig
  reproduzierbaren Upstream-Lock ausgeben. Private uv-Basis bleibt erhalten.

- Qwen_Desktop_Study wie Enki als optionale GitHub-Quellen fuer Studienzwecke
  und Weiterentwicklung im Setup anbieten. Separater Linux-/Windows-Build nach
  Freigabe; Quellenstatus, Buildnachweis und Entwicklungsdaten getrennt halten.

- Perplexity Python/Node SDKs: Bazel 9.2.0, Node 26, pnpm 11.17.0 und bei Python
  uv vor dem Quellcheckout pruefen und nach Zustimmung privat bereitstellen.
  Feste offizielle Hashes/Groessen, getrennte npm-Konfiguration, keine globale
  Installation oder unkontrollierte Bazelisk-Aufloesung. Kein API-Test/Serverstart.

- Perplexity_MCP: fehlendes Node/npm nach Zustimmung privat aus geprueftem
  offiziellen Node-Archiv bereitstellen. Basispruefung vor Checkout, private
  npm-Konfigurationen und Aufloesung aus dem Kindprozess-PATH. Kein globaler
  Umbau, Serverstart oder API-Aufruf; Node-RED-Bootstrap bleibt kompatibel.

- Browser_Use: fehlendes uv nach Zustimmung privat aus fest geprueftem GitHub-
  Release bereitstellen. Python-Pruefung vor Quellen-/Bootstrap-Download und
  absoluter uv-Aufruf statt erneuter globaler PATH-Suche; bestehende Daten/Basis
  bleiben erhalten. Kein Python-/Chromium-Download oder Browser-/Agentenstart.

- Enki_Browser_Study: GitHub-Studienquellen und optionaler, freigegebener
  Linux-/Windows-Paketbuild in separater Arbeitskopie. Chromium-Binaries
  ausdruecklich gekennzeichnet, kein behaupteter Chromium-Source-Build.
  Zweck: Studien/Weiterentwicklung; kein Signieren, Installieren oder Start.

- BrowserOS_Study: separater gepinnter GitHub-Quell-Download fuer Studienzwecke
  und Weiterentwicklung; optionaler, ausdruecklich freigegebener Linux-Vollbuild
  mit separater Chromium-Kopie, Ressourcenwache und ohne Signieren/Upload/Start.
  Studienquellen und Browserartefakt getrennt ausgewiesen; eigene Arbeit erhalten.

- LiteLLM-uv-Timeout: laufende Buildausgabe/Heartbeat statt verlorener gepufferter
  Diagnose; begrenzte Cargo-/uv-Parallelitaet, explizites Zeitbudget und
  Prozessgruppen-Abbruch unter Linux. Metadaten-/Freeze-Ausgaben bleiben
  vollstaendig. Kein automatischer Retry oder falscher Erfolgsnachweis.

- LiteLLM: fehlendes Rust 1.98.0 nach Zustimmung privat bereitstellen statt
  dauerhaftem Vorpruefungsabbruch. Offizielles rustup-init 1.29.2 mit festen
  SHA256/Groessen fuer Linux amd64/arm64; isolierte Rust-/Cargo-Homes,
  Reserve, Versions-/sysroot-Nachweis und Bootstrap-Rollback. Kein System-
  Rust/PATH-/Default-Wechsel und kein Download bei Plan/Status/Doctor.

- Browser-/Perplexity-Gruppe hinter Tools A-Z: Comet mit manuellem Windows-
  Download und Wartepunkt wie Qwen Desktop; BrowserOS/Enki mit manuellen
  GitHub-Releases. Browser Use, Perplexity MCP und SDKs mit gepinnten privaten
  Paket-/Buildwegen; Cookbook als lokale Beispielsammlung. Lifecycle, Status,
  Dokumentation und Offline-Tests, kein Browser-/Serverstart oder API-Aufruf.

- Zugangsdaten-Backup: eigenstaendige Restore-Anleitung direkt im E-Mail-Text;
  Windows-/WSL-/Linux-Softwarequellen, age-Entschluesselung, manuelle TAR-Ansicht
  und kontrollierte Rueckuebernahme einzelner Dateien mit Sicherung/Rechten
  in der Dokumentation ergaenzt. Keine automatische Aktivierung oder Mailaktion.

- Getrenntes Zugangsdaten-Backup unter Optionen -> 21 -> 5: explizite
  Dateiauswahl, passphrasegeschuetztes TAR mit age, externer Windows-Export,
  isolierter Restore ohne aktive Konfigurationen zu ersetzen. Einstellungen
  verschluesselt enthalten; EML-Entwurf oder bestaetigter msmtp-Versand.
  Kein gespeichertes Passwort, kein automatischer Versand. Unsichere
  Erinnerungsfragen und Passwort-im-Mail-Risiko ausdruecklich dokumentiert.

- Installationsinventar: unabhaengiger JSON-/Markdown-Export, Importvorschau
  und datenerhaltende Wiederherstellung anhand noch vorhandener Artefakte.
  Automatische Programmliste im lokalen Backup und vor freigegebenem Main-
  Abgleich; rsync-Fehler nicht mehr als Erfolg unterdruecken. Profile/fehlende
  Tools bleiben historische Eintraege, keine erfundenen Installationen.

- Datenerhaltender Installations-Reset in Optionen und Tooldiagnose: lesende
  Pruefung, explizite Legacy-Freigabe, Archiv statt Loeschung, aktuelle Logs.
  Gemeinsame Linux-flock-Koordination mit Rollback-Runner/Tooloperationen;
  aktive oder unlesbare Prozesse blockieren. Kein Kill, WSL-Reset oder Purge.

- LiteLLM: vorhandenes Rust/Cargo 1.98.0 anhand von Version und sysroot
  erkennen, auch ausserhalb PATH; expliziter Toolchain-Pfad, isolierte
  Aktivierung und konkrete Diagnose. Kein automatischer Rust-Download.

- Node-RED: npm-Config-Kollision behoben. Getrennte leere User-/Global-Dateien
  fuer Versionsprobe und Build statt doppeltem /dev/null; vorhandene npm-
  Konfigurationen bleiben unveraendert. Probe-Staging wird auch bei Fehlern
  entfernt; kein globales npm-Update oder Dienststart.

- LiteLLM: Rust-/C/C++-Buildwerkzeuge vor Downloads pruefen, statt erst beim
  maturin-Linkerfehler abzubrechen. Fehlende build-essential/pkg-config auf
  Ubuntu 24.04 nur nach Zustimmung; kein apt-Rust, System-Python-Umbau oder
  Docker. Basiswerkzeuge bleiben bei App-Deinstallation erhalten.

- Statischer Kernplattform-Sicherheitsaudit mit priorisierten Dateibelegen und
  Zielarchitektur; NSA/CISA-Adminpruefblatt, PSS-/NetworkPolicy-/RBAC-Anleitung
  und getrennte Review-Beispiele. Lokaler Ressourcenplaner mit KV-/RAM-/CPU-/
  PVC-Modell und hypothetischer Skalierung, ohne Cluster-/API-Zugriff.
  Comet-/Perplexity-/Browserquellen als Kandidaten, nicht als neue Installer.

- Rollback-Sperre: Besitzer-PID mit Boot-/Startidentitaet fuer neue Versuche,
  rein lesendes --inspect-lock und konkrete Pfadangabe bei Konflikten.
  Alte/unklare Sperren bleiben erhalten; manuelle Freigabe nur leerer
  Legacy-Sperren nach Ausschluss laufender Installer dokumentiert.

- cAdvisor: serieller Go-Build mit weichem Prozess-GC-Budget; laufende
  Compilerlogs, PID/Heartbeat/Exitstatus und begrenzter Rueckgabepuffer.
  Signal-/Timeout-Fehlerpfade und WSL-Diagnose dokumentiert; kein behaupteter
  OOM-Nachweis oder Schutz gegen einen kompletten VM-/Hostabbruch.

- ArchiveBox: vorhandenes Python 3.13/3.14 erkennen statt ausschliesslich den
  Installer-Interpreter zu verwenden. Bei Bedarf private Python-3.13-Basis
  via uv/GitHub nach Zustimmung und mit zusaetzlicher Speicherreserve;
  kein System-Python-Umbau. Explizite Interpreter bleiben verbindlich,
  fehlgeschlagenes neues Python-Staging wird bereinigt.

- Bestehende K8s-Basis um CPU-VPS-Overlay, PVC-Retain, selektiven Agentenzugriff
  und begrenztes lokales Gateway ergaenzt. Check-/Plan-/Apply-Automation mit
  RAM-/Disk-/Swap-/Runtime-Gates und explizitem Kontext; Dashboard um p95-
  Latenz ergaenzt. SOPS-/GitOps-Betriebsanleitung, keine Live-Installation.

- Node-RED: private Node-22.23.4-/npm-10.9.9-Basis aus pruefsummengesichertem
  Node-Archiv nach Zustimmung, eigener Archivschutz und Kindprozess-PATH.
  Kein System-Node-Umbau, Docker, Flow- oder Dienststart; libatomic-Reparatur
  bleibt separat freizugeben.

- MinIO an den privaten Go-Bootstrap angebunden, Go >=1.24.8 gemaess
  konservativem Toolchain-Vertrag; Wartungswarnung am Quellpin sichtbar.
  Kein System-Go-Umbau, Serverstart, Bucketzugriff oder Docker-Fallback.

- LiteLLM an den vorhandenen privaten GitHub-uv-Bootstrap angebunden;
  Python >=3.10,<3.15 vor dem Download pruefen, Zustimmung und 256-MiB-
  Zusatzreserve. Kein Proxy, Datenbankstart oder Modell-/Provideraufruf.

- Changedetection_IO an den vorhandenen privaten GitHub-uv-Bootstrap
  angebunden; Python >=3.11 vor dem Download pruefen, Zustimmung und 256-MiB-
  Zusatzreserve. Kein Docker, Browserdownload, Watch oder Dienststart.

- cAdvisor an den privaten Go-Bootstrap angebunden, passend zur Go-1.25-
  Mindestanforderung am GitHub-Pin. Zustimmung, Integritaets-/Versionspruefung
  und isolierter Kindprozess-PATH; kein System-Go-Umbau oder Dienststart.

- ArchiveBox an den bestehenden privaten GitHub-uv-Bootstrap angebunden:
  Zustimmung, SHA256-/Versionspruefung, 256-MiB-Zusatzreserve und Python-Pruefung
  vor dem Download. Kein System-Python-Umbau, Docker oder Archivstart.

- Architekturreview vom 25.10.2026 mit aktuellen Codebelegen, vorhandenen
  K8s-/Monitoring-/Secret-Schutzbausteinen, Backup-Falsch-Erfolg und einer
  priorisierten Roadmap fuer Host, Compose, GPU und Cluster. Nur Bericht:
  [Review](docs/ARCHITECTURE_REVIEW_2026-10-25.md), keine Runtime-Aenderung.

- Zigbee2MQTT-Rueckfragen sofort als eigene Zeilen ausgeben; Zustimmung,
  leere Eingabe, Ablehnung und EOF getrennt protokollieren. Ungueltige
  Antworten erneut abfragen; kein implizites Ja bei fehlendem Terminal.

- Deutsche Repository-Frage mit ausdruecklichem `[j/N]` und oeffentlichem
  Standard; Zigbee2MQTT-Node-/pnpm-Bootstrap diagnostiziert fehlendes libatomic1
  und bietet eine separat freizugebende Ubuntu-24.04-Reparatur mit erneuter
  Versionspruefung an. Keine Paketinstallation bei Status oder Dry-Run.

- [Manus API-Key](docs/_API-Keys/manus.md) aufgenommen: offizieller Key-Weg,
  v2-Authentifizierung, sichere Ablage, offene API-Freikontingent-/Payment-/KYC-
  Bedingungen und Abgrenzung zu OpenManus/FreeLLMAPI. Keine Cloud-Aktivierung.

- Acht nachgereichte Unterlagen zu Tooling, CI/CD, P0-Plan und DSB zugeordnet:
  [Quellenregister](docs/sources/2026-10-24/README.md). Sechs Originaldateien
  uebernommen, identische Praesentation wiederverwendet, vertrauliche DSB-PDF
  nur fachlich eingeordnet. Keine Installer-, Cluster- oder Secret-Aenderung.

- Delta-Audit vom 24.10.2026 mit neu geprueften Code-/Zeilenbelegen,
  anerkannten vorhandenen P0-Schutzmassnahmen, Linux-Case-Fehler im Profilindex
  und getrennten P0-P3-PR-Vorschlaegen. Nur Dokumentation, keine Laufzeit-
  oder Secret-Aenderung: [Auditbericht](docs/AUDIT_2026-10-24.md).

- Projektweiter Offline-Audit mit Registry-/Link-/Python-Pruefung und CI-
  Regressionstests; persoenliche Dokumentationspfade repariert, Queue-Sperren,
  Dry-Run, Exit-Codes und schreibfreie Statusabfrage ergaenzt. Umfang und offene
  Punkte: [Audit 20.10.2026](docs/PROJECT_AUDIT_2026_10_20.md).

- Anbieter-Dokumentation nach docs/_API-Keys/OnlineOnKeyServices verschoben;
  zentrale API-Key-Uebersicht angelegt und beide Uebersichten in FreeLLMAPI
  verlinkt. Keine echten Credentials oder automatische Cloud-Freigabe.

- FreeLLMAPI-Anbindung fuer OnlineServices dokumentiert: OpenRouter als am Pin
  eingebauter Provider, token8341 als bedingt nutzbarer Custom-Endpunkt; getrennte
  Keys, Modellwahl, Discovery-/Probe-Kosten und doppelte Routingebenen erklaert.

- Externe KI-Dienste unter docs/tools/OnlineServices gesammelt: token8341
  verschoben, Zweck "ein Key fuer mehrere Modelle" vorangestellt und OpenRouter
  mit Vergleich, Konfiguration, Kosten-/Datenschutzgrenzen dokumentiert.

- token8341/TokenWorks als optionale Cloud-Dokumentation aufgenommen: getrennte
  Konfiguration, SDK-/Kubernetes-Beispiele ohne API-Aufruf, Betreiberwidersprueche,
  Kosten-/Zahlungspruefung und differenzierte DSGVO-/AI-Act-Hinweise. Kein Installer.

- Claude Code/Gemini CLI: vorhandene source-ready.json-Marker in die zentrale
  Menue-Statussynchronisierung aufnehmen; beide Statuslisten aktualisieren und
  nach Deaktivierung bereinigen. Quellvorbereitung bleibt von CLI-Bereitschaft getrennt.

- Embedded Debug HIL: fehlendes ensurepip/venv im aktuellen Tool-Log pruefen
  und nach Zustimmung das versionspassende Ubuntu-Paket einrichten; APT-
  Sperrenschutz und Nachpruefung vor Clone, weiterhin keine Hardwareaktionen.

- Just Dub It: fehlendes ensurepip/venv nach separater Zustimmung durch
  python3.12-venv ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Vollstaendige Lizenzanzeige und ausdrueckliche Lizenzannahme bleiben erhalten.

- Kiwi Edit: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Sparse-Checkout, Speicherwache und Workspace-Rollback bleiben unveraendert.

- Basic Pitch: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Runtime-Python-Grenzen, Speicherwache und Workspace-Rollback bleiben erhalten.

- WhisperX: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Workspace-Rollback und getrennte Runtime-Freigabe bleiben unveraendert.

- ACE-Step 1.5: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket fuer Python 3.11/3.12 ergaenzen; APT-Sperrenschutz und Nachpruefung
  vor GitHub-Clone, unveraenderte Workspace-Rollback- und GPU-Schutzlogik.

- MOSS-TTS: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Keine GPU-Runtime-/Modellfreigabe oder System-Python-Ersetzung.

- Moshi: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Keine GPU-Runtime-/Modellfreigabe oder System-Python-Ersetzung.

- AudioGen: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  AudioCraft-Legacy-Runtime bleibt gesperrt, kein System-Python-Tausch.

- AudioLDM2: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Legacy-Runtime bleibt gesperrt, kein System-Python-Tausch oder Modellstart.

- ChatTTS: fehlendes ensurepip/venv nach Zustimmung durch versionspassendes
  Ubuntu-Paket ergaenzen; APT-Sperrenschutz und Nachpruefung vor GitHub-Clone.
  Keine automatische schwere Laufzeit, Modelle oder System-Python-Ersetzung.

- Qwen3-TTS: versionspassendes Ubuntu-venv-Paket bei fehlendem ensurepip nach
  Zustimmung anbieten; APT-Sperrenschutz und erneute Modulpruefung vor Clone.
  GitHub-Pin, private venv und getrennte Freigabe schwerer Laufzeit bleiben erhalten.

- Alexandria Audiobook: fehlendes ensurepip/venv nach Zustimmung durch das
  versionspassende Ubuntu-Paket ergaenzen; aktuelle Logs, APT-Sperrenschutz
  und erneute Pruefung vor GitHub-Clone. Keine Docker-/Modellinstallation.

- Veo API SDK: versionspassendes Ubuntu-venv-Paket bei fehlendem ensurepip
  nach Zustimmung anbieten; APT-Sperrenschutz, aktuelles Log und erneute
  Modulpruefung vor Clone/Build. Kein System-Python-Tausch oder Videojob.

- Fal Client: fehlendes venv/ensurepip nach ausdruecklicher Zustimmung durch
  versionspassendes Ubuntu-Systempaket ergaenzen; APT-Sperrenschutz und erneute
  Importpruefung vor GitHub-Clone, kein System-Python-Tausch oder Cloud-Aufruf.

- SD.Next: fehlendes ensurepip/venv vor dem Clone erkennen und nach expliziter
  Zustimmung das versionspassende Ubuntu-venv-Paket mit APT-Sperrenschutz
  einrichten; Python-Pruefung im aktuellen Tool-Log, kein System-Python-Tausch.

- Installationslogs vor Speicherplatz-Vorpruefung erstellen; Abbruchgrund und
  Messwerte dem aktuellen Versuch zuordnen, Installer-Ausgabe anhaengen.
  Kein Rueckgriff auf alte Logs; Schreibfehler/volle Log-Datentraeger sichtbar
  melden. DeepFilterNet-Doku zum Erhalt gemeinsam genutzter Basiswerkzeuge.

- ComfyUI_GGUF: gefuehrter Menue-Schritt bei fehlender ComfyUI-Basis mit
  expliziter separater Basisinstallation, Source-only oder Abbruch (Standard).
  Lokaler Basischeck und erneute Pruefung; keine stille schwere Installation.

- Medien-Toolstatus: gemeinsame Marker-Erkennung fuer Basis-/Quellinstaller
  statt fehlender installed_tools-Eintraege. Gesamt-/Gruppenauswahl und
  Gruppenaktionen synchronisieren beide Listen; Batch statt Einzel-Rewrites,
  Registry-Checks auf Erfolgsmarker vereinheitlicht. Kein Loeschen von Nutzdaten.

- Embedded_Debug_HIL: expliziter GitHub-Basisinstaller fuer pygdbmi 0.11.0.0
  in privater venv ohne Docker statt documentation-first-Sperre. Quellpin,
  Preflight, Lock, Logs, Metadaten-Doctor und Statusabgleich; kein Live-Hardwarezugriff.

- Just_Dub_It: vollstaendige gepinnte LTX-2-Lizenz inklusive Attachment A
  lokal anzeigen und vor Download akzeptieren/ablehnen lassen. Standard/EOF
  ist Ablehnung, keine Annahmespeicherung. GitHub-Basispakete ohne Docker.

- ProPainter: vollstaendige gepinnte S-Lab-Lizenz vor Download anzeigen und
  interaktiv akzeptieren/ablehnen lassen; Standard/EOF ist Ablehnung.
  Explizite nichtinteraktive Freigabe bleibt moeglich; keine Annahmespeicherung.

- MOSS_TTS: vorhandenen gepinnten GitHub-Basisinstaller statt Medien-Guard
  in Registry und Menue verdrahtet, ohne Docker. Eigene Doku, transparenter
  Basis-/Laufzeitstatus und markerbasierter Menue-Abgleich ergaenzt.

- Stable Audio Open: kompatibles Python 3.10 automatisch erkennen; falls es
  fehlt, bestaetigten privaten CPython-3.10.22-GitHub-Build anbieten. Gepinnter
  Commit, Ressourcenpruefung, ein Buildjob; kein System-Python-Austausch.

- Wan21/Windmill: markerbasierter schneller Menue-Abgleich und Austragung aus
  beiden Statusdateien; leere Hauptliste nicht aus alter Kopie wiederbeleben.
  DeepFilterNet erkennt Benutzer-Cargo und bietet fehlende Build-Werkzeuge
  nach Ressourcenpruefung mit expliziter Zustimmung an; GitHub statt Docker.

- Speicherplatz-Rollback im zentralen Tool-Menue: nur explizit freigegebene,
  neu angelegte private Tool-Verzeichnisse bei belegtem Platzfehler entfernen.
  Bestehende Installationen, Erfolg, Vorab-Ablehnung und gemeinsame Plugin-Daten
  bleiben geschuetzt. Journal, Sperre, Opt-out und synthetische Tests ergaenzt.

- Sieben getrennte Coding-/Infrastruktur-Profile statt Einbau in Jarvis:
  Vorlageninstallation, Offline-Routingplan mit lokalem Default, explizite
  Cloud-Freigabe und gepinnte GitHub-Quellvorbereitung ohne Docker.
  Claude-Code-Referenzmaterial ist keine baubare Open-Source-CLI.

- YuE: eigener gepinnter GitHub-Quellinstaller fuer YuE-v1 ohne Docker.
  Keine stille Migration zu YuE2/main, Python-/GPU-Pakete oder Modelle.
  Ressourcen-/Pfadschutz, Lifecycle, Dokumentation und Offline-Tests ergaenzt.

- ACE_Step_15: GitHub-Basispaketinstallation statt Medien-Guard, ohne Docker.
  Fester Commit, private venv, Sparse-Checkout, Ressourcen-/Pfadschutz,
  Lifecycle und Offline-Tests. GPU-Runtime/Modelle bewusst nicht installiert.

- WhisperX: eigener GitHub-Installer 3.8.6 statt Medien-Guard, ohne Docker.
  Private venv, optionale Runtime mit festgehaltenem Torch-Stack,
  Ressourcen-/Pfadschutz, Logs, Lifecycle und Offline-Tests. Keine Inferenz.

- Aegisub: eigener GitHub-Quellinstaller 3.5.1 ohne Docker, optionaler
  privater Meson/Ninja-Build mit Ressourcen-/Pfadschutz und deaktiviertem
  Update-Checker. Lifecycle, Dokumentation und Offline-Tests ergaenzt.

- Basic_Pitch: GitHub-Installer 0.4.0 statt documentation-first-Guard,
  ohne Docker. Private venv, optionale Runtime mit doppeltem Opt-in,
  Ressourcen-/Pfadschutz, Lifecycle, Logs und Offline-Tests.

- Sfizz: GitHub-Engine 1.2.3 samt sechs gepinnten Unterprojekten statt
  documentation-first-Guard, ohne Docker. Optionaler privater Renderer-Build,
  Ressourcen-/Pfadschutz, Logs und Offline-Tests; keine DAW-/Audiostarts.

- AIDA_X: gepinnte GitHub-Quellen 1.1.0 samt Unterprojekten und optionalem
  privaten Standalone-CMake-Build ohne Docker; Ressourcen-/Pfadschutz,
  ELF-/Hashstatus und Offline-Tests. Kein Audio-/DAW-/Systeminstallationsstart.

- ProPainter: gepinnter GitHub-Sparse-Quellinstaller ohne Docker/Pakete/Modelle,
  mit S-Lab-Lizenz-Opt-in, Lifecycle, Disk-/Pfadschutz, Logs und Offline-Tests.
  Nicht betriebsbereite Inferenz und automatische Upstream-Gewichtsdownloads dokumentiert.

- Kiwi_Edit: gepinntes GitHub-Basispaket diffsynth 2.0.4 in privater venv,
  ohne Docker/Runtime/Modelle; Sparse-Checkout, Ressourcen-/Pfadschutz,
  Lifecycle und Tests. Remote-Code-/GPU-/Lizenzgrenzen dokumentiert.

- VOID_Model: gepinnter GitHub-Sparse-Quellinstaller ohne Docker statt
  Medien-Guard; Lifecycle, Disk-/Pfadschutz, Logs und Offline-Tests.
  Keine Pakete/Modelle/Inferenz; GPU-Bedarf und Gemini-Grenze dokumentiert.

- Just_Dub_It: gepinnte GitHub-Basispakete ltx-core/ltx-pipelines ohne Docker,
  mit Python-3.12-Pruefung, Archiv-Hinweis und Lizenz-Opt-in. Kein Modell-,
  GPU-/Dubbing-Start; Lifecycle, Dokumentation und Offline-Tests ergaenzt.

- Personnel_Documents_AI: privater CLI-Starter aus dem GitHub-Setup-Checkout
  statt Installations-Guard. Ohne Docker/Paketdownload, mit SHA-256-Pruefung,
  Diskcheck, Lock, Logs und erhaltender Deinstallation; kein Paperless-Start.

- Moshi: gepinnter GitHub-Installer fuer Python-Paket 0.2.13 aus dem
  Monorepo-Unterordner, private Basis-venv ohne Docker. Ressourcen-/Pfadschutz,
  Logs, Status/Doctor und Dokumentation; keine Modelle/Server/Mikrofonaufnahme.

- Stable Audio Open: GitHub-Installer fuer stable-audio-tools 0.0.20 mit
  Python-3.10-Pruefung, privater Basis-venv, Ressourcen-/Pfadschutz und Logs.
  Kein Docker, GPU-/Modell-Download oder automatischer WebUI-/Trainingstart.

- AudioGen: eigener GitHub-Installer fuer AudioCraft 1.3.0 in privater venv,
  ohne Docker. Basispaket ohne Legacy-Runtime/Modelle; klare Statusmeldung,
  Ressourcen-/Pfadschutz, Lifecycle-Skripte, Dokumentation und Offline-Tests.

- AudioLDM2: gepinntes GitHub-Basispaket ohne Docker und ohne Runtime-
  Abhaengigkeiten. Legacy-NumPy/Gradio, share=True-WebUI und Lizenzwiderspruch
  dokumentiert; keine CLI-/Modell-/Inferenztests oder Ports.

- ChatTTS: gepinnter GitHub-Paketinstaller ohne Docker, Standard --no-deps;
  Core-Runtime doppelt opt-in mit Torch-/torchaudio-Constraints.
  Modelllizenz nichtkommerziell und oeffentlicher WebUI-Default dokumentiert.

- Qwen3_TTS: gepinntes GitHub-Paket in privater venv ohne Docker,
  standardmaessig --no-deps. Runtime doppelt opt-in, vorhandenes Torch/
  torchaudio durch Constraints geschuetzt. Keine Modelle/Generierung/Training.

- Alexandria_Audiobook: gepinnte GitHub-Quellen und private Python-venv
  ohne Docker statt Medien-Platzhalter; keine Modelle/Adapter/Torch-/Pinokio-
  Installer ausgefuehrt. GPU-Laufzeit/Erststart und Ressourcen dokumentiert.

- Veo_API: eigener GitHub-Installer fuer google-genai 2.31.0 in privater
  venv ohne Docker, mit Ressourcenwache/Lock/Logs und Metadaten-Doctor.
  Kein lokales Veo, keine Keys, Cloud-/Upload-/Videogenerierungstests.

- Fal_Client: eigener GitHub-Installer fuer fal-client 1.0.3 aus dem
  Monorepo-Unterordner in privater Python-venv ohne Docker. Ressourcen/
  Lock/Logs, Metadatenpruefung ohne SDK-Import und ohne API-/Uploadtest.

- Windmill: gepinnter GitHub-Quellinstaller ohne Docker; optional natives
  Linux-amd64-Release mit Lizenz-Opt-in, SHA256-/ELF-Pruefung. Kein DB-/
  Server-/Workerstart. Loopback-Default explizit dokumentiert, Daten erhalten.

- SD.Next: eigener gepinnter GitHub-Quellinstaller mit privater Python-venv
  ohne Docker statt Social-Guard. Lock/Logs/Diskwache, datenbewahrende
  Deaktivierung und Doku zum separaten, schweren WebUI-Erststart.

- Pinokio: eigener nativer GitHub-Release-Downloadassistent v8.2.0 statt
  Social-Platzhalter; Browser nur mit Freigabe, Wartepause und manuelle
  Bestaetigung ohne falschen Installationsnachweis. Windows-Hash dokumentiert.

- TGI: gepinnte GitHub-Quellinstallation ohne Docker, optional nativer
  Launcher-Build mit doppeltem Opt-in, Lock/Logs/Ressourcen und Hashchecks.
  Maintenance Mode und fehlende Router-/Python-/GPU-Inferenzlaufzeit klar getrennt.

- ViDubb: gepinnter GitHub-Sparse-Quellinstaller ohne Docker; keine .env/
  Medien/Gewichte im Arbeitsbaum, kein Import/Paket-/Appstart. Legacy-Pins,
  Importinstallationen, oeffentliches Gradio und loeschende Verarbeitung
  dokumentiert: Quellinstallation ist noch keine betriebsbereite Dubbing-Laufzeit.

- ComfyUI-GGUF: eindeutige bekannte ComfyUI-Pfade und venv/.venv erkennen,
  registrierte Ziel-/Python-Pfade wiederverwenden. Mehrdeutige Funde abbrechen;
  fehlende Basisdateien konkret nennen, keine ungefragte schwere Basisinstallation.

- HF_Hub: eigener GitHub-Client-/CLI-Installer fuer 2.2.0 in privater venv
  statt Planned-Guard. Ressourcen/ensurepip, Lock/Logs, hf-Entrypoint-Metadaten;
  hf-xet nur Wheel. Kein Docker, Login, Transfer oder Cloudjob beim Installieren.

- HF_Datasets: eigener GitHub-Source-Installer fuer 5.1.0 in privater venv
  statt documentation-first-Guard. Ressourcen/ensurepip, Lock/Logs und
  datenerhaltende Deaktivierung; Wheels fuer Arrow/NumPy/pandas, keine
  schweren Extras, Datensatz-/Modell-Downloads oder Trainingsjobs.

- AudioSeal: eigener gepinnter GitHub-Paketinstaller mit privater CPU-venv
  statt planned-Guard; Ressourcen/venv-Reparatur, Lock/Logs, Metadatenchecks
  und datenbewahrende Deaktivierung. Kein Docker, Modell-/Audiozugriff oder
  Echtheitsurteil; unsicheres Checkpoint-Unpickling dokumentiert.

- DeepFilterNet: eigener GitHub-Rust-CPU-Installer fuer v0.5.6 statt
  documentation-first-Guard; kein Docker/Python. Ein Buildjob, Lock/Logs,
  Ressourcenpruefung, Binary-Hash/Versioncheck, datenbewahrende Deaktivierung.
  GitHub-Modell wird eingebettet, keine Audiobearbeitung beim Installieren.

- Qwen Code: Gesamt-RAM und aktuell verfuegbaren RAM getrennt pruefen;
  8-GB-Geraeteklasse ab 7168 MiB gesamt und 5120 MiB verfuegbar zulassen.
  pnpm-Installationsparallelitaet begrenzen; Disk-/WSL-Reserven bleiben erhalten.

- Qwen Desktop: nach Browser-Uebergabe auf Enter und manuelle Abschlussbestaetigung
  warten. Tools-Menue unterscheidet bestaetigt/verschoben/Browserfehler, statt
  erfolgreiche Browser-Uebergaben pauschal als Installationsfehler zu melden.

- Microsoft Agent Framework: venv/ensurepip vor GitHub-Download pruefen;
  fehlendes versioniertes Ubuntu-/Debian-venv-Paket mit sudo und APT-Sperrenschutz
  nachinstallieren. Repair erhaelt Quellen/venv; System-Python bleibt unveraendert.

- Pyannote_Audio: eigener GitHub-Source-Installer fuer Release 4.0.4 statt
  Audio-Review-Platzhalter; optionale private CPU-Laufzeit mit Torch/Audio/
  Codec-Pins, Ressourcencheck und doppeltem Opt-in. Keine Modelle/Token/
  Pipeline-/Audioaktionen; Offline-Doctor, Telemetrie-Hinweise und Marker-Deaktivierung.

- FILM: eigener gepinnter GitHub-Quellinstaller statt Hybrid-Platzhalter,
  ohne Docker. Archivierten TensorFlow-2.6.2-Pfad und Ausgabe-Loeschverhalten
  dokumentiert; keine blinde Runtime-/Modellinstallation. Offline-Pruefungen,
  Disk-Reserve, Lock/Logs und datenerhaltende Deaktivierung.

- SUPIR: eigener gepinnter GitHub-Quellinstaller statt Hybrid-Platzhalter,
  ohne Docker/Modelle. Lizenzgrenzen und belegten Pydantic-Konflikt dokumentiert;
  keine blinde Legacy-/GPU-Paketinstallation. Source-Status, Offline-Doctor,
  Disk-Reserve, Lock/Logs und datenerhaltende Deaktivierung.

- ComfyUI_GGUF: eigener gepinnter GitHub-Custom-Node-Installer statt Hybrid-
  Platzhalter, ohne Docker. Vorhandenes ComfyUI/venv pruefen, gguf bei Bedarf
  ohne Upgrade bestehender Pakete ergaenzen, verwalteter Node-Link; keine
  Modelle/Serverstarts. Source-only, Lock/Logs, Offline-Doctor und sicherer Unlink.

- Wan21: eigener gepinnter GitHub-Quellinstaller statt Hybrid-Platzhalter,
  ohne Docker/Modelle. Schwere CUDA-12.8-/PyTorch-/Flash-Attention-Pakete
  nur mit doppeltem Opt-in und Preflight; Quell- und Runtime-Marker getrennt.
  Offline-Doctor, Lock/Logs und datenerhaltende Deaktivierung.

- Cline: Hybrid-Platzhalter durch eigenen GitHub-Release-VSIX-Pfad ersetzt,
  v4.1.25 mit SHA-256/Publisher-Pruefung, Lock, Logs und Offline-Doctor.
  Paketbereitstellung ohne Docker; Editor-Installation separat und klar
  vom Paketstatus getrennt, keine IDE-/Provider-/Agentenaktionen.

- Qwen_Desktop: offizielle Windows-Downloadseite nach freiwilliger
  [(j)a/(N)ein]-Bestaetigung im Browser oeffnen; explizit --open-download
  moeglich. Kein Download/Installerstart oder falscher Installationsstatus.

- Karaoke_Formats: bisher ins Leere laufende Menue-Installation durch privaten
  CLI-Starter aus dem vorhandenen GitHub-Setup-Checkout ersetzt. Ohne Docker,
  Pakete oder zweiten Clone; SHA-256, Disk-Reserve, Operations-Lock, Logs,
  Offline-Status/Doctor und datenerhaltende Deinstallation.

- Microsoft_Agent_Framework: geplanten Platzhalter durch optionalen GitHub-
  Source-Installer fuer Python-Core 1.22.0 ersetzt. Private venv, fester Commit,
  Ressourcencheck, Lock, Logs und Offline-Doctor; kein Docker/Agentenstart.
  Deinstallation deaktiviert die Erfolgsmarkierung und erhaelt Daten/venv.

- Qwen_Code: fehlendes Node/npm privat via GitHub-nvm bereitstellen, Corepack
  0.34.0 in privatem npm-Prefix und pnpm 11.24.0 mit Upstream-Hash im eigenen
  Corepack-Cache. Kein globales Update, Login, Agent oder Docker. Opt-out:
  QWEN_CODE_AUTO_RUNTIME=0; Doctor/Dry-Run ohne Downloads.

- Automaton: private automatische Node-22/npm- und pnpm-10.28.1-Bereitstellung
  nach Ressourcencheck/Lock, nur bei ausdruecklicher Installation/Repair.
  Kein System-Node-/globales pnpm-Update, keine Downloads bei Status/Doctor,
  kein Agentenstart. Mit AUTOMATON_AUTO_RUNTIME=0 deaktivierbar.

- FreeLLMAPI: fehlendes/inkompatibles Node/npm bei expliziter Installation oder
  Repair automatisch privat ueber vorhandenen GitHub-nvm-Helfer bereitstellen.
  Ressourcen/Lock/Log vor Bootstrap; kompatible Runtimes weiterverwenden,
  Status/Doctor/Start ohne Downloads, System-Node/Shellprofile unveraendert.

- Qwen_Code vom allgemeinen Hybrid-Platzhalter auf eigenen gepinnten GitHub-
  CLI-Source-Build ohne Docker umgestellt; kein Login/Start/Modell-Download.
- FreeLLMAPI-Installer gibt Source-Revision aus; Tutorial zum Erkennen des
  alten Docker-Skripts ergaenzt. Lokale Aenderungen sind noch kein GitHub-Update.

- Automaton: optionaler gepinnter GitHub-Source-Build ohne Docker mit pnpm,
  Ressourcenchecks, privatem Buildlog, Lock und datenerhaltender Deaktivierung.
  Kein Agentenstart, Wallet-Zugriff, globale CLI oder Dienst; Offline-Review bleibt separat.

- FreeLLMAPI auf gepinnten GitHub-Source-Build ohne Docker umgestellt:
  npm ci/build, lokaler SQLite-Smoke-Test, Lock/Logs/Ressourcenchecks.
  Start separat im Vordergrund mit localhost-Zwang und sicher gelesenem ENV;
  alte Containerdaten bleiben unberuehrt, keine automatische Migration.

- Qwen_Desktop (Qwen Code Desktop) als manueller Windows-GUI-Pfad ergaenzt:
  offizieller Desktop-Download, sichere Erstnutzung, lokaler Hash-/Signaturcheck.
  CLI/Chat/Studio/QwenWork getrennt, keine pauschale Open-Source-/Free-Tier-Zusage.
- Hybrid-Katalog fuer Modellfamilien/Wan und sieben geplante Tools
  vervollstaendigt; keine aktiven Modelldownloads, 8K- oder VRAM-Versprechen.

- Defensiver Audio-Review: drei planned-Kandidaten und bestehende Audioquellen
  verknuepft, Originalerhalt, Separation/Diarisierung und Wasserzeichen-Grenzen
  dokumentiert. Fehlerhafte Ausloeschungs-/Echtheitsversprechen korrigiert;
  keine Herkunftsverschleierung, Modellinstallation oder Audioverarbeitung.

- Social-Avatar-Stack: acht geplante Tool-/Cloud-Kandidaten, bestehendes
  AI_Influencer-Profil und AvatarAgent erweitert. Lokaler Einsteigerleitfaden,
  Lizenz-/Ressourcengrenzen, Workflowvertrag und inaktive Budgetvorlage.
  Keine Installation, Cloud-Fallbacks oder automatische Veroeffentlichung.

- Hugging-Face-Video-Datenpfad: HF_Datasets/HF_Hub/Video2Dataset planned in
  Registry/Menue; Dataset_Curator optional erweitert. Quellenkatalog,
  Streaming-/Lizenz-/Speicherwarnungen und inaktives Freigabeprotokoll ergaenzt.
  Keine Installation, Downloads oder Trainingsstarts.

- Audio-/Video-Nachbearbeitung: 20 planned-Kandidaten, Quellen-/Ressourcenkatalog,
  Hoerbuch-/Dubbing-/Karaoke-/MIDI-Leitfaeden und planned-Profil. Offline-SRT/LRC-
  Konverter mit explizitem Export; keine Modell-/Runtime-Installation.

- Agentic-Coding-Leitfaden, Auftragsvorlagen und planned-Profil ergaenzt; vorhandene Coding-Tools mit Quellen/Doku verknuepft. Microsoft Agent Framework als optionaler planned-Kandidat, AutoGen-Maintenance-Hinweis, aktuelle OpenCode-Quelle. Keine Autonomie-/Kosten-/Stabilitaetsgarantie, keine Aufhebung der Automaton-Sperren.

- Personalaktenpfade werden vom allgemeinen unverschluesselten Workspace-Backup ausgeschlossen und mit Warnung ausgewiesen; separater verschluesselter Akten-Backupjob ist vor Produktivbetrieb verpflichtend einzuplanen.

- Personalakten_Local_First (planned) und Personnel_Documents_AI (experimental): Offline-Validierung und explizite lokale Ollama-Vorschlaege, kein Paperless-Schreiben/RAG. Paperless-Installer ohne feste Passwoerter, localhost-Bindung, private ENV/DB-Volumes, Opt-in und datenbewahrendem Stop; /opt-Altinstallationen brauchen bewusste Migration. Datenschutz-/GoBD-/ACL-/Restore-Grenzen dokumentiert.

- Automaton von Conway Research als planned/high-risk im Tool-Menue registriert: Offline-Vorschlagspruefer, gesperrte Runtime-Aktionen, Quellenstand und Zenbot/OpenClaw-Integrationsplan. Wallet-Speicherung und Survival-Behauptungen korrigiert; keine Keys, Zahlungen oder WSL-Eingriffe.

- Embedded_Debug_HIL als geplantes Tool/Profil mit nutzbarem Offline-Registerbericht, PATH-Doctor, Agentenregeln und lokalen OpenOCD-/pyOCD-Beispielen. Live-MCP, Hardwarezugriff und Source-Installer bewusst noch nicht freigegeben; keine Flash-/Reset-Automatik.

- FreeLLMAPI optional/experimental im Tool-Menue, Registry und Portmatrix: GHCR v0.14.2, localhost 3011, explizites Docker-Opt-in, private User-ENV und datenbewahrende Deinstallation. Tutorial fuer Claude Code/OpenClaw mit Kosten-, Datenschutz- und Offline-Grenzen; kein automatischer Client-Umbau.

- Lokaler age-verschluesselter ENV-Tresor im User-Backupverzeichnis, Optionen-Menue 19, Tool-/Feldzuordnungen und standardmaessige Vorschau; generierte Klartext-ENV nicht im normalen Workspace-Backup, verschluesselter Tresor separat enthalten.

- Node Exporter korrigiert erneut: kein Root-Mount im Standardprofil, weil Docker rprivate beim Root-Bind ablehnen kann. Begrenzte /proc-/sys-Collector-Auswahl; root/rslave nur explizit.

- OpenTelemetry bietet fehlende Docker-/Compose-Pakete nach explizitem Opt-in an; vorhandene Clients werden nicht durch zweite Engines ersetzt, Paketfamilien und --no-remove schuetzen vor Konfliktbereinigung.

- Promptfoo nutzt gemeinsame Node/nvm-Bereitstellung mit Puppeteer und installiert npm 11.11.0 bei Bedarf privat im User-Workspace statt System-npm zu ersetzen; Dry-Run bleibt ohne Installation.

- Puppeteer laedt vorhandenes nvm oder stellt bei Bedarf nvm v0.40.8/Node 22 samt npm im Benutzerkonto bereit; kein System-Node-Ersatz, keine Downloads im Dry-Run.

- RIFE kann fehlendes Python nach Opt-in und Disk-Pruefung als isoliertes CPython 3.11.17 aus GitHub bauen; Dry-Run ohne Build, explizite Interpretervorgaben bleiben verbindlich.

- Supabase laedt Images seriell und wiederholt erkannte Netzwerkabbrueche maximal dreimal mit Backoff; Start erst nach erfolgreichem Pull, keine Cache-/Datenloeschung.

- Whisper_CPP-Deinstallation nutzt nach fester Pfadpruefung sudo statt des unprivilegierten Node-Helfers; Dry-Run, Fehlerstatus und Regressionstest ergaenzt.

- Tool-Menue entfernt veraltete Ollama-Haekchen aus beiden Statusdateien, wenn kein ausfuehrbarer Ollama-Befehl vorhanden ist; verhindert Wiederherstellung durch Legacy-Statusmigration.

- Kustomize ersetzt apt durch GitHub-Release v5.8.2 mit SHA256 fuer amd64/arm64; Dry-Run, Client-Test und Binary-Deinstallation ergaenzt, Registry verdrahtet.

- Mosquitto entfernt die ungenutzte WebSocket-Freigabe 9001, bindet MQTT an localhost und erlaubt MOSQUITTO_HOST_PORT. Neue Config verweigert anonyme Clients; bestehende Config bleibt erhalten.

- MusicGen: Python 3.10/3.11, FFmpeg-Entwicklungspakete fuer PyAV, GitHub-Tag v1.3.0, fruehe Disk-Sperre und Backup inkompatibler venv.

- Node Exporter nutzt standardmaessig rprivate statt rslave fuer WSL-kompatible Root-Mounts und bindet 9100 an localhost. Git-Docker-Helfer setzt bei Compose-Fehler keinen Installiert-Status.

- OpenTelemetry nutzt den Docker-Compose-sudo-Fallback, prueft Speicher vor Installation, bindet neue OTLP-Ports an localhost und erhaelt bestehende Konfigurationen. Kein automatischer Docker-/Gruppenumbau.

- Promptfoo prueft Node >=22.22.0 und den Upstream-CI-Pin npm 11.11.0 vor Installation; npm ci, Build und CLI-Smoke-Test muessen erfolgreich sein. Keine apt-Node-Installation und kein fehlerverdeckender npm-Fallback.

- Puppeteer prueft Node >=22.12.0 vor Installation, stellt unzip vor Chrome-Download bereit und testet Paket/Browserdatei; Node-Helfer erzwingt Engine-Anforderungen.

- RIFE prueft Python 3.10/3.11 vor Installation, sichert inkompatible .venv und verhindert den NumPy-Source-Build unter Python 3.12; CPU-PyTorch als Standard, GPU-Quelle optional.

- Syft ersetzt den fehlenden apt-Pfad durch feste Anchore-GitHub-Releases mit SHA256 fuer amd64/arm64; Binary-Deinstallation, Doku und Registry angepasst.

- Velero-404 behoben: korrekte versionsgebundene GitHub-Assets, SHA256 aus CHECKSUM, amd64/arm64 und CLI-Dry-Run; Registry ergaenzt.

- Stable Diffusion WebUI prueft Python 3.10/3.11, sichert inkompatible venv und nutzt Upstream-Vorbereitung; fehlgeschlagene Pillow-/tokenizers-Installationen werden nicht mehr als Erfolg gemeldet.

- Forge ersetzt den fehlerhaften Repo-Root-Editable-Install durch Upstream-`launch.py --exit`, Python-3.10/3.11-Pruefung und separate venv; alte `.venv` bleibt erhalten.

- K9s verwendet feste offizielle GitHub-Releases mit SHA256-Pruefung statt Ubuntu-apt; Binary-Deinstallation und Registry ergaenzt.

- Kubectl ersetzt den fehlenden Ubuntu-apt-Pfad durch offizielle, SHA256-gepruefte Releases fuer amd64/arm64; Registry und Binary-Deinstallation angepasst.

- Kubectx/Kubens entfernt den geprueften `/opt/kubectx`-Ordner mit sudo; Fehler werden als fehlgeschlagene Deinstallation erfasst.

- n8n prueft Node >=22.22.0 vor Clone/Basisinstallation, respektiert die pnpm-Version des Checkouts und aktiviert strikte Engine-/Lockfile-Pruefung. Mosquitto/Node-RED als Nutzer des gemeinsamen sudo-Deinstallationsfixes dokumentiert.

- Airbyte prueft Ressourcen vor apt/Messwertinitialisierung, bietet `--check`/`--dry-run` und zeigt fehlenden RAM; Docker wird ueber den gemeinsamen Helfer statt als festes `docker.io` bereitgestellt.

- Supabase startet Compose ueber den sudo-faehigen Docker-Helfer; vorhandene `.env` bleibt erhalten und Docker-Paketfamilien werden nicht mehr fest erzwungen.

- Whisper.cpp verwendet einen CMake-CPU-Build mit expliziten Compiler-/CMake-Abhaengigkeiten, zwei Build-Jobs und CLI-Smoke-Test statt des Node-Installationshelfers.

- Zotero und zentrale Basisabhaengigkeiten warten begrenzt auf apt/dpkg-Sperren; leere Paketnamen loesen keine Paketinstallation mehr aus.

- Gemeinsame Git/Docker-Deinstallation (u. a. Metabase) entfernt gepruefte `/opt`-Toolordner mit sudo und meldet Stop-/Loeschfehler statt Erfolg.

- AutoGPT prueft Host-Speicher und RAM/Swap vor Clone und Docker-Installation; `--check`/`--dry-run` bieten eine reine Host-Pruefung mit konkreten Fehlmengen.

- Governance-Dokument fuer Fork-Support, genehmigte Support-Branches, signierte Support-Freigaben und sichere Rueckfuehrung in `main` ergaenzt.
- README und Integritaets-Tutorial auf das neue Fork-/Support-Modell verlinkt.
- HE/Oracle/WireGuard/Homecluster-Zielarchitektur als Einsteiger-Tutorial, Security-Doku, K3s-Hinweise, Wake-on-LAN-Skripte und sichere Beispiel-Stacks ergaenzt.
- Stalwart Mail als optionalen Mailserver-Kern mit HE-DNS-Doku, Oracle-VPS-Hardening, OpenClaw/Ollama-Mail-Agent, Control-Panel-Plan und sicheren Setup-Wrappern ergaenzt.
- AutoGPT-Installer um Diagnose fuer Frontend-`pnpm build`/`ELIFECYCLE`-Fehler, Edge-Runtime-Warnungen und Docker-Git-Metadatenwarnungen erweitert.
- AutoGPT-Installer erkennt RabbitMQ-Compose-Startfehler jetzt getrennt vom Frontend-Build und gibt passende Docker-Compose-Diagnosebefehle aus.
- AutoGPT-Installer prueft vor dem schweren Build/Start jetzt Linux-/WSL-Speicher, Windows-C:-Speicher, Docker-Root-Speicher sowie RAM+Swap.
- Tool- und Profiluebersichten starten jetzt standardmaessig im Schnellmodus; Zeit-/Speichermesswerte werden bei grossen Listen automatisch ausgeblendet.
- Clawhub-Installer installiert fehlende Bun-Basisabhaengigkeiten wie `unzip`, bevor `bun.sh/install` gestartet wird.
- Docker-Stack-Installer wie Langfuse, LiteLLM und Open WebUI fallen bei fehlender Docker-Socket-Berechtigung jetzt auf `sudo docker compose` zurueck.
- Docker-Compose-Stack-Helper gibt seine Revision im Installationslog aus, damit alte WSL-Kopien sofort erkennbar sind.
- Llama_CPP_Toolchain nutzt fuer den CMake-Build jetzt `--parallel "$(nproc)"`, damit keine quotierte `-j`-Zahl an CMake uebergeben wird.
- GitHub Contribution-, Security-, CODEOWNERS-, PR-/Issue-Template- und Branch-Protection-Dokumentation professionalisiert.
- WebsiteFactory / WebBuild-Agent als neuer lokaler Workflow-Prototyp ergaenzt: Astro/Tailwind-Projektgenerator, Ollama-Default, JSON-Queue, Queue-Worker, Setup-Wrapper und Beispielbriefing.

## V11.16

- neue Review- und Roadmap-Doku
- neue Profile für DevOps, Data, Document AI, Voice Assistant, Web3, Compliance, Personal Knowledge und Repo-Maintenance
- neue Security-Audits
- neues Gesamt-Healthcheck-Skript
- neuer Ressourcen-Estimator
- neue Tool-Installer für Maintainer-, Voice-, Web3- und Compliance-Bausteine
- Menü- und Profilintegration erweitert

## V11.15

- Registry-Grundlagen, Audit-Doku, Matrixen und zusätzliche Studio-Profile
## 2026-05-30 - Voice Studio und AI Singer erweitert

- Neue Voice-Profile fuer Voice Studio, AI Singer, AI Choir, Voice Clone, Podcast, Hoerbuch, Dubbing und Voice Laboratory ergaenzt.
- Voice-Studio-Tools als GitHub-/Open-Source-Quellen registriert: StyleTTS2, OpenVoice, RVC, Seed-VC, DiffSinger, OpenUtau, NNSVS, UVR5 und Audacity.
- AI Choir System, Trainings-Tutorials, VoiceStudioAgent und n8n/Home-Assistant-Workflow-Vorlagen dokumentiert.
- Sicherheitsregeln ergaenzt: nur eigene oder freigegebene Stimmen, Kennzeichnung von KI-Stimmen, keine Rohdaten oder Modelle im Repo, keine automatische Veroeffentlichung.
## 2026-05-30 - AI Media Production Studio erweitert

- Neue Profile fuer virtuelle Personen, Broadcast-Rollen, Dubbing, Podcast, Radio, Filmregie, Casting und Voice Direction ergaenzt.
- Character Library, AI Actor Studio, Broadcast Studio, Newsroom, Film Studio, Dubbing Studio, LipSync Studio und Ressourcenklassen dokumentiert.
- Avatar-, LipSync- und TTS-Tools als geplante GitHub-Quellen registriert: Fish Speech, MeloTTS, Kokoro TTS, Spark-TTS, Hallo2, MuseTalk, LivePortrait, SadTalker, EMO, SkyReels-A1 und Wav2Lip.
- Sicherheitsregeln fuer KI-Kennzeichnung, Einwilligung echter Personen, DSGVO-nahe Ablage und keine automatische Veroeffentlichung ergaenzt.
## 2026-05-30 - Media Studio Unterverzeichnisse strukturiert

- Neue Dokumentationsstruktur fuer Media, Voice, Singer, Choir, Broadcasting, Film, Avatar, Agenten, Workflows und Tutorials angelegt.
- Media-Profile nach `docs/profiles/media/`, Agenten nach `docs/agents/media/`, Workflows nach `docs/workflows/media/` und Tutorials nach `docs/tutorials/media/` gespiegelt.
- `config/tools.yml` um strukturierte Kategorien `voice_tools`, `singing_tools`, `avatar_tools`, `audio_tools` und `broadcast_tools` erweitert.
- Sichere Stub-Installer unter `scripts/tools/media/` angelegt; sie dokumentieren den geplanten Installationspfad, starten aber keine schweren Builds.
## 2026-05-30 - Coqui TTS Python-Kompatibilitaet dokumentiert

- Coqui TTS in `config/tools.yml` als `experimental` mit Python-Anforderung `>=3.9,<3.12` markiert.
- Ubuntu-24.04-/Python-3.12-Abbruch als erwarteten Schutz dokumentiert.
- Piper als stabilen lokalen TTS-Fallback in Voice-Studio-Doku hervorgehoben.
- Neue Kompatibilitaetsseite `docs/voice_studio/COQUI_TTS_COMPATIBILITY.md` ergaenzt.

## 2026-05-30 - Next Improvements Audit Queue Checks

- Audit docs/SETUP_AUDIT_2026_NEXT_IMPROVEMENTS.md ergaenzt.
- Neue planned/documentation-first Profile fuer Queue, MCP Gateway, Secrets, Observability, RAG, Backup, Netzwerk, Mail, Android und Model Router ergaenzt.
- Tool-Katalog um GitHub-Kandidaten mit Status, Ressourcen, Risiko, Ports, Secrets, Doctor und Uninstaller-Spalten erweitert.
- SQLite-basierte Queue-Minimalvariante unter scripts/queue/ vorbereitet.
- Neue Checks fuer Secrets, Ressourcenbudget, Queue, Mail-DNS und Observability angelegt.
## 2026-05-30 - dbt Installer auf GitHub-Unterordner korrigiert

- `scripts/tools/dbt_install.sh` installiert dbt-core nicht mehr aus dem Repository-Root, sondern aus dem Unterordner `core`.
- Der bekannte setuptools-Fehler `Multiple top-level packages discovered in a flat-layout` wird dadurch vermieden.
- `docs/DBT_INSTALLATION_NOTES.md` mit Ursache, Korrektur und Adapter-Hinweis ergaenzt.
## 2026-05-30 - Next Level Profile und Codex Task Queue

- Neue planned/documentation-first Profile fuer Betrieb, KI/Agenten, Security, Infrastruktur, Medien, Android und Projektsteuerung ergaenzt.
- `docs/CODEX_TASK_QUEUE.md` und TSV-basierte Minimalqueue unter `scripts/queue/` angelegt.
- Next-Level-Dokumente fuer Setup Review, Missing Profiles/Tools, Deployment Matrix, Security, HE/Oracle-DDoS, Backup/Restore, Beginner Wizard und Test Matrix ergaenzt.
- Security-Wrapper `scripts/security/scan_secrets.sh` und `scripts/security/scan_supply_chain.sh` ergaenzt.
