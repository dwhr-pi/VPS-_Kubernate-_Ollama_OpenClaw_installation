# OpenClaw & AI Infrastructure - Ultimate Setup

HE/Oracle Control/DMZ -> WireGuard -> Pi (WoL) -> RTX/K3s-Worker zuhause.
Interne APIs bleiben privat; GPU, Tunnel, Cloud und privilegierte Dienste sind opt-in.
Keine pauschale Produktionsfreigabe: Supply-Chain und echte Laufzeit-/Restore-Abnahmen bleiben offen.

## Was ist das hier überhaupt? (Kurz erklärt für Einsteiger)

Ein VPS in der Cloud koordiniert das Setup. Ein Raspberry Pi zu Hause kann
den Rechner mit RTX-Grafikkarte per Wake-on-LAN einschalten. Dieser Rechner
übernimmt die KI-Inferenz; WireGuard verbindet die Standorte verschlüsselt.

- **Lokal chatten und arbeiten:** Open WebUI und Ollama können Modellanfragen
  auf eigener Hardware verarbeiten. Daten bleiben lokal, solange keine
  externen Modellanbieter, Werkzeuge oder Datenflüsse aktiviert werden.
- **Aufgaben automatisieren:** Werkzeuge wie n8n, Flowise oder Huginn helfen
  bei wiederkehrenden Abläufen, etwa beim Sortieren von Daten oder Erstellen
  von Berichten. Externe Dienste brauchen eine bewusste Freigabe.
- **Passende Profile wählen:** Medienproduktion, Home Assistant, Entwicklung
  oder Forschung lassen sich getrennt einrichten. Nicht jedes Profil ist
  gleich weit getestet.

| Frage | Verwaltete Cloud-KI | Dieses Setup |
| --- | --- | --- |
| Wo wird gerechnet? | Beim Anbieter | Bei lokaler Inferenz auf eigener Hardware |
| Was kostet es? | Je nach Tarif oder Verbrauch | Hardware, Strom, gegebenenfalls VPS und bewusst genutzte Cloud-Dienste |
| Wer kümmert sich um Betrieb und Sicherheit? | Der Anbieter für seine Plattform | Du für Updates, Zugriffsschutz und Backups |

Einsteiger können vorhandene Werkzeuge über das Linux-Setup-Menü auswählen.
Fortgeschrittene können Kubernetes, Kustomize, Ansible und Monitoring
gezielt ergänzen. Das Projekt ist keine fertige Klick-App und verspricht
keine Produktionsreife ohne eigene Laufzeit- und Restore-Tests.

## Warum keine Docker-Installation?

Dieses Setup bevorzugt geprüfte Git-Quellen und native Builds. Damit lassen
sich genaue Quellstände nachvollziehen, Forks einbinden und projektspezifische
Build-Schritte prüfen. Ein Quellbuild ist nicht automatisch sicher: Pins,
Abhängigkeiten und Integritätsprüfungen bleiben wichtig. Builds können
deutlich länger dauern als ein Image-Download; fehlende native Buildrezepte
bleiben ausdrücklich offen.

Kubernetes nutzt eine Container-Laufzeit; das ist keine Docker-Installation
und kein Docker-Fallback für Tools. Vorhandene Container, Volumes und
Benutzerdaten bleiben erhalten. [Installationsrichtlinie](docs/INSTALLATION_POLICY.md)

Projektlizenz: [Apache-2.0](LICENSE). [Drittprojekte](THIRD_PARTY_NOTICES.md).
Hinweise auf Unterstuetzung sind keine zusaetzliche Lizenzbedingung.

## Orientierung

- **Einstieg:** [Erste 60 Minuten](docs/FIRST_60_MINUTES.md), [aktueller Status](docs/CURRENT_STATUS.md).
- **Architektur:** [Hybrid-Plattform](docs/architecture/), [Kubernetes-Baseline](docs/PRODUCTION_BASELINE.md).
  [Ressourcen, Storage und GitOps-Abnahme](docs/LLMOPS_ARCHITECTURE_INCREMENT_2026-11-03.md).
  [Infrastrukturreview: Monitoring, MCP und sichere Retries](docs/INFRASTRUCTURE_REVIEW_2026-11-07.md).
- **Betrieb:** [Installation, Neustart und Update](#installation-und-betrieb), [Backup und Restore](docs/INSTALLATION_STATUS_BACKUP.md).
  [Umzug auf den neuen Repository-Namen](docs/REPOSITORY_RENAME.md).
- **Sicherheit:** [Signierte Releases](docs/SIGNED_RELEASES.md), [sicherer Kernpfad](docs/SECURE_CORE_REFACTOR.md).
- **Tools und Profile:** [Tool-Matrix](docs/generated/TOOL_MATRIX.md), [Profil-Matrix](docs/generated/PROFILE_MATRIX.md).
- **Dokumentation und Historie:** [Wegweiser](docs/readme.md), [historische Langfassung](docs/legacy/README_FULL_2026_11_01.md).

Zum Lesen im Setup: Hauptmenue **10 - Dokumentation & API-Key Guide**.
Dort zuerst eines von sechs Themen, dann ein Dokument auswaehlen.
Enter oeffnet die markierte Auswahl; Zurueck/Esc kehrt zur vorherigen Ebene zurueck.
Es werden nur lokale Dokumente angezeigt, keine Browser, Installer oder Dienste gestartet.

Kein ungeprueftes curl-pipe-bash. Der Release-Vertrauensanker muss unabhaengig vorliegen.
Primaertools bleiben GitHub-Source-Builds; bestehende ausdrueckliche Quellen-Ausnahmen bleiben separat dokumentiert.
**Verbindlich: Git-Quellen herunterladen und nativ bauen/installieren; keine Docker-Installation, kein Docker-Fallback.**
Warnungen aendern diesen Installationsweg nicht. [Installationsrichtlinie](docs/INSTALLATION_POLICY.md).
Registry-Metadaten und Menuehaekchen sind kein Laufzeitnachweis.

<a id="deklarativer-pruefpfad"></a>

Deklarativer Pruefpfad:

`bash scripts/setup-cluster.sh` zeigt nur den Plan, ohne Download oder Clusterzugriff.
Kompatible GitOps-Einstiege: `deploy/kustomize/`, bestehende Quelldateien bleiben unter `k8s/`.
Namespaces, Budgets, PVCs, private TLS-Zugaenge und optionale Operator-Metriken sind getrennt.
[Setup, manuelles Staging-Deployment, Voraussetzungen und Rollback](docs/GITOPS_DEPLOYMENT_PATH.md).
[Privates Open WebUI: Voraussetzungen, Render-Pruefung und Abnahme](docs/kubernetes/open-webui-private.md).

[Ports](docs/generated/PORT_MATRIX.md), [P1-P3 und Abnahmegrenzen](docs/P1_P3_IMPLEMENTATION.md).

Weitere Themen: [Entwicklungswerkzeuge](docs/DEVELOPMENT_TOOLS_OVERVIEW.md),
[Toolchain-Pruefung](docs/tools/development-toolchain-check.md),
[Praesentation](docs/presentations/technology-tooling-overview.pptx),
[Review-Fortsetzung](docs/tutorials/grok-repo-review-2026-10-23.md), [Recht/RAG](docs/legal/README.md).

<!-- markdownlint-configure-file {"MD033": {"allowed_elements": ["a", "details", "summary"]}} -->
## Installation und Betrieb

<a id="-schnelle-installation-one-liner"></a>

### Quickstart: Signiertes Release installieren

**Voraussetzungen:** Linux oder WSL, unabhaengig gepruefter Bootstrap,
separat bezogener oeffentlicher Minisign-Schluessel und ein signiertes Release.
`vX.Y.Z` ist ein Platzhalter, kein zugesagtes Release. Ohne einen vom
Maintainer veroeffentlichten signierten Tag ist dieser Weg noch nicht nutzbar.
Tag und Pfade im Beispiel ersetzen. Zuerst nur pruefen:

```bash
bash ./verify_release_and_install.sh --tag vX.Y.Z \
  --public-key /sicher/separat/release.pub \
  --artifacts /sicher/release-artefakte --verify-only
```

Erst nach erfolgreicher Pruefung in ein noch nicht vorhandenes Ziel installieren:

```bash
bash ./verify_release_and_install.sh --tag vX.Y.Z \
  --public-key /sicher/separat/release.pub \
  --artifacts /sicher/release-artefakte --install \
  --destination "$HOME/openclaw_ultimate_setup"
```

Ist Minisign unter Ubuntu/Debian nicht vorhanden, kann der gepruefte Bootstrap
es nach ausdruecklicher Zustimmung einrichten. Wenn der Vertrauensschluessel
oder ein signiertes Release fehlt, gibt es keinen automatischen unsignierten
Ersatz. Siehe [Signierte Releases](docs/SIGNED_RELEASES.md) und, nur fuer
bewusste Entwicklungstests, [Installationszweige](docs/INSTALL_BRANCH_SELECTION.md).

<a id="-setup-erneut-starten"></a>

### Setup erneut starten

```bash
cd ~/openclaw_ultimate_setup && bash ./setup_ultimate.sh
```

Bei einem separaten Branch-Checkout oder einem eigenen Installationsziel
stattdessen in genau dessen Ordner wechseln.

<a id="-setup-aktualisieren-oder-lokal-entfernen"></a>

### Setup aktualisieren oder lokal entfernen

**Aktualisieren:** Im richtigen Setup-Verzeichnis zuerst `git status --short`
pruefen. Fuer Releases den [signierten Updatepfad](docs/SIGNED_RELEASES.md#standard-update)
mit `--dry-run` beginnen. Der freigegebene Updatepfad sichert den Checkout
vor der Aktualisierung und stoppt bei lokalen Aenderungen. Keine manuellen
Resets oder Bereinigungsbefehle als Routine verwenden.

**Lokal entfernen:** Gewuenschte Tools und Profile zuerst ueber ihre
Deinstallationsfunktionen entfernen. Danach den Setup-Checkout nach
Pfadpruefung und Sicherung eigener Aenderungen separat entfernen. Der private
Workspace `~/.openclaw_ultimate_user_data` mit Konfigurationen und Messwerten
bleibt dabei erhalten. [Backup und Wiederherstellung](docs/INSTALLATION_STATUS_BACKUP.md).

<a id="boardroom-profil"></a>

**Eigenstaendiges Entscheidungsprofil:** [Boardroom](docs/tools/boardroom.md).

[Historische Installation und alte Abschnittslinks](docs/legacy/INSTALLATION_HISTORY.md).
