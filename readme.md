# Hybride Kubernetes- und KI-Plattform

HE/Oracle Control/DMZ -> WireGuard -> Pi (WoL) -> RTX/K3s-Worker zuhause.
Interne APIs bleiben privat; GPU, Tunnel, Cloud und privilegierte Dienste sind opt-in.
Keine pauschale Produktionsfreigabe: Supply-Chain und echte Laufzeit-/Restore-Abnahmen bleiben offen.

Projektlizenz: [Apache-2.0](LICENSE). [Drittprojekte](THIRD_PARTY_NOTICES.md).
Hinweise auf Unterstuetzung sind keine zusaetzliche Lizenzbedingung.

## Orientierung

- **Einstieg:** [Erste 60 Minuten](docs/FIRST_60_MINUTES.md), [aktueller Status](docs/CURRENT_STATUS.md).
- **Architektur:** [Hybrid-Plattform](docs/architecture/), [Kubernetes-Baseline](docs/PRODUCTION_BASELINE.md).
  [Ressourcen, Storage und GitOps-Abnahme](docs/LLMOPS_ARCHITECTURE_INCREMENT_2026-11-03.md).
  [Infrastrukturreview: Monitoring, MCP und sichere Retries](docs/INFRASTRUCTURE_REVIEW_2026-11-07.md).
- **Betrieb:** [Installation, Neustart und Update](#installation-und-betrieb), [Backup und Restore](docs/INSTALLATION_STATUS_BACKUP.md).
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

[Ports](docs/generated/PORT_MATRIX.md), [P1-P3 und Abnahmegrenzen](docs/P1_P3_IMPLEMENTATION.md).

Weitere Themen: [Entwicklungswerkzeuge](docs/DEVELOPMENT_TOOLS_OVERVIEW.md),
[Toolchain-Pruefung](docs/tools/development-toolchain-check.md),
[Praesentation](docs/presentations/technology-tooling-overview.pptx),
[Review-Fortsetzung](docs/tutorials/grok-repo-review-2026-10-23.md), [Recht/RAG](docs/legal/README.md).

<!-- markdownlint-configure-file {"MD033": {"allowed_elements": ["a", "details", "summary"]}} -->
## Installation und Betrieb

<a id="-schnelle-installation-one-liner"></a>

### Schnelle Installation (One-Liner)

Der alte `curl | bash`-One-Liner ist gesperrt. Verwende einen unabhaengig
geprueften Bootstrap, den separat bezogenen oeffentlichen Minisign-Schluessel
und ein signiertes Release. Tag und Pfade im Beispiel ersetzen:

```bash
bash ./verify_release_and_install.sh --tag vX.Y.Z \
  --public-key /sicher/separat/release.pub \
  --artifacts /sicher/release-artefakte --verify-only
```

Erst nach erfolgreicher Pruefung `--verify-only` durch
`--install --destination "$HOME/openclaw_ultimate_setup"` ersetzen.
Ist Minisign unter Ubuntu/Debian nicht vorhanden, kann der gepruefte Bootstrap
es nach ausdruecklicher Zustimmung einrichten. Wenn der Vertrauensschluessel
oder ein signiertes Release fehlt, gibt es keinen automatischen unsignierten
Ersatz. Siehe [Signierte Releases](docs/SIGNED_RELEASES.md) und, nur fuer
bewusste Entwicklungstests, [Installationszweige](docs/INSTALL_BRANCH_SELECTION.md).

**Historischer One-Liner (nicht ausfuehren):** So lautete der fruehere
unsignierte Einstieg. Er fuehrte den Download direkt aus, ohne vorherige
Pruefung. Der aktuelle Bootstrap blockiert diesen Aufruf standardmaessig.

```text
cd ~
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

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

<details>
<summary>Historischer Installationsweg: Neustart, Update und Entfernen</summary>

**Archivtext, keine aktuelle Anleitung. Nicht ausführen.** Der folgende
Originaltext beschreibt einen älteren Setup-Stand. Die Reset-, Clean- und
Löschbefehle können lokale Änderungen und private Daten unwiederbringlich
entfernen. Maßgeblich ist der aktuelle Installations- und Updateweg oben.

**Setup erneut starten**

Wenn du das Setup-Menü erneut starten möchtest, navigiere in das Installationsverzeichnis
(standardmäßig `~/openclaw_ultimate_setup`) und führe das Hauptskript aus:

```text
cd ~/openclaw_ultimate_setup
bash ./setup_ultimate.sh
```

**Setup aktualisieren oder lokal entfernen**

Wenn es Änderungen im Repository gab und du dein bestehendes Setup aktualisieren möchtest, wird
jetzt bewusst ein **harter Repo-Abgleich** empfohlen. So bleiben keine alten Setup-Dateien halb
stehen, während dein ausgelagerter Benutzer-Workspace erhalten bleibt:

```text
cd ~/openclaw_ultimate_setup
git status --short
git fetch origin --prune
git checkout main 2>/dev/null || git checkout -b main --track origin/main
git reset --hard origin/main
git clean -fd
printf '\nDas Repository ist jetzt aktualisiert.\n'
printf 'Du kannst die aktuelle Terminal-Ausgabe jetzt in Ruhe lesen oder kopieren.\n'
read -rp "Drücke Enter, um danach das Setup-Menü zu starten ... "
bash ./setup_ultimate.sh
```

Wenn du vor dem Neustart des Menüs den angezeigten Stand erst prüfen möchtest, ist diese kleine
Pause bewusst hilfreich. So kannst du z. B. Git-Meldungen, Versionsstände oder Warnungen noch lesen
und direkt aus dem Terminal kopieren, bevor das interaktive Setup weiterläuft.

Wichtig:

- Die Pause erscheint nur dann, wenn der harte Repo-Abgleich erfolgreich war.
- `git reset --hard origin/main` und `git clean -fd` verwerfen lokale Änderungen und ungetrackte
  Zusatzdateien **im Setup-Repository**.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt dabei
  erhalten.
- Die neueren Update-Skripte legen vor dem harten Abgleich zusätzlich eine Sicherung der verworfenen
  Repo-Differenzen unter `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Wenn dabei vorher lokale Änderungen in Dateien wie `install.sh` oder `setup_ultimate.sh` auftauchen,
ist das gerade der Grund für den harten Abgleich: Das Repo soll vollständig auf `origin/main`
zurück, statt nur teilweise über `git pull` aktualisiert zu werden.

In diesem Fall gibt es jetzt zwei sichere Wege:

- im Menü den Punkt `Setup-Repository hart reparieren / auf GitHub main zurücksetzen` verwenden
- oder den One-Liner-Installer erneut starten, der bei vorhandenem Repo jetzt ebenfalls den harten
  Abgleich verwendet

Wichtig dabei:

- Es werden nur Dateien im Setup-Repository zurückgesetzt.
- Dein ausgelagerter Benutzer-Workspace unter `~/.openclaw_ultimate_user_data` bleibt erhalten.
- Vor dem harten Abgleich legt der Installer jetzt zusätzlich eine Sicherung des Repo-Zustands unter
  `~/.openclaw_ultimate_user_data/repo_update_backups` an.

Alternativ kannst du im Menü den Punkt `Setup-Update + System-Update (Repo, OS & pnpm)` nutzen.
Dieser zieht den aktuellen Repository-Stand direkt im Setup-Verzeichnis und aktualisiert danach
Ubuntu sowie `pnpm`.

Wenn danach trotzdem noch ein älterer Setup-Stand angezeigt wird, sollte zuerst geprüft werden, ob
wirklich das richtige Repository-Verzeichnis verwendet wird. Ein normaler `git pull` ist dafür nicht
mehr der empfohlene Weg.

Prüfen:

```text
cd ~/openclaw_ultimate_setup
git status
```

Wenn du den harten Repo-Abgleich lieber manuell ausführen möchtest, kannst du das Setup so direkt
auf den aktuellen GitHub-Stand zurücksetzen:

```text
cd ~/openclaw_ultimate_setup
git fetch origin --prune
git reset --hard origin/main
printf '\nDas Repository wurde hart auf GitHub main zurückgesetzt.\n'
printf 'Du kannst die aktuelle Terminal-Ausgabe jetzt in Ruhe lesen oder kopieren.\n'
read -rp "Drücke Enter, um danach das Setup-Menü zu starten ... "
bash ./setup_ultimate.sh
```

Dafür gibt es jetzt auch direkt im Menü einen eigenen Punkt:

- `Setup-Repository hart reparieren / auf GitHub main zurücksetzen`

Dieser Weg ist hilfreich, wenn trotz normalem `git pull` noch ein älterer Setup-Stand angezeigt
wird.

Wenn du ganz sauber neu anfangen willst, ist auch das weiterhin möglich:

```text
cd ~
rm -rf ~/openclaw_ultimate_setup
curl -sSL https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/main/install.sh | bash
```

Wenn du das lokale Setup wieder entfernen möchtest, hast du zwei saubere Wege:

1. Zuerst im Menü `Tools: Installieren & Deinstallieren` und
   `Profile: Installieren & Deinstallieren` alle gewünschten Komponenten wieder abwählen.
2. Danach das lokale Arbeitsverzeichnis entfernen:

```text
cd ~
rm -rf ~/openclaw_ultimate_setup
```

Wenn du zusätzlich lokal installierte Komponenten wie `Home Assistant`, `Ollama` oder einzelne Tools
vollständig entfernen willst, nutze die jeweiligen `*_uninstall.sh` Skripte im Menü oder direkt
unter `scripts/tools/`.

Wenn du zusätzlich den ausgelagerten Benutzer-Workspace mit sensiblen Daten entfernen möchtest,
kannst du das entweder im Menü über `Benutzer-Workspace verwalten` tun oder manuell:

```text
rm -rf ~/.openclaw_ultimate_user_data
```

</details>

<a id="boardroom-profil"></a>

**Eigenstaendiges Entscheidungsprofil:** [Boardroom](docs/tools/boardroom.md).

<!-- Explicit legacy anchors preserve incoming links without oversized heading navigation. -->
<details>
<summary>Historische Abschnittslinks aufklappen</summary>

Alte Kommandos, Versionen und Aussagen sind keine aktuelle Installationsempfehlung.
Die bisherigen Abschnittsanker bleiben hier erhalten; ihre Links fuehren in die historische Langfassung.

<a id="vps--kubernate--ollama--openclaw-installation---ultimate-setup-v1117"></a>
[VPS- Kubernate- Ollama & OpenClaw installation - Ultimate Setup V11.17](docs/legacy/README_FULL_2026_11_01.md#vps--kubernate--ollama--openclaw-installation---ultimate-setup-v1117)

<a id="empfohlener-sicherer-einstieg"></a>
[Empfohlener sicherer Einstieg](docs/legacy/README_FULL_2026_11_01.md#empfohlener-sicherer-einstieg)

<a id="inhaltsverzeichnis"></a>
[Inhaltsverzeichnis](docs/legacy/README_FULL_2026_11_01.md#inhaltsverzeichnis)

<a id="aktuelle-governance-dokumente"></a>
[Aktuelle Governance-Dokumente](docs/legacy/README_FULL_2026_11_01.md#aktuelle-governance-dokumente)

<a id="wichtiger-original--und-support-hinweis"></a>
[Wichtiger Original- und Support-Hinweis](docs/legacy/README_FULL_2026_11_01.md#wichtiger-original--und-support-hinweis)

<a id="empfohlener-start-he-vorne-oracle-steuert-pi-weckt-rtx-rechnet"></a>
[Empfohlener Start: HE vorne, Oracle steuert, Pi weckt, RTX rechnet](docs/legacy/README_FULL_2026_11_01.md#empfohlener-start-he-vorne-oracle-steuert-pi-weckt-rtx-rechnet)

<a id="-zielbild"></a>
[🧱 Zielbild](docs/legacy/README_FULL_2026_11_01.md#-zielbild)

<a id="quickstarts"></a>
[Quickstarts](docs/legacy/README_FULL_2026_11_01.md#quickstarts)

<a id="setup-skripte-schnell-finden"></a>
[Setup-Skripte schnell finden](docs/legacy/README_FULL_2026_11_01.md#setup-skripte-schnell-finden)

<a id="speicherplatz-und-bereinigung"></a>
[Speicherplatz und Bereinigung](docs/legacy/README_FULL_2026_11_01.md#speicherplatz-und-bereinigung)

<a id="-gegenwärtiger-status"></a>
[🟡 Gegenwärtiger Status](docs/legacy/README_FULL_2026_11_01.md#-gegenwärtiger-status)

<a id="-neue-übersichten-und-doctor-skripte"></a>
[🧭 Neue Übersichten und Doctor-Skripte](docs/legacy/README_FULL_2026_11_01.md#-neue-übersichten-und-doctor-skripte)

<a id="tool-quellen-und-github-regel"></a>
[Tool-Quellen und GitHub-Regel](docs/legacy/README_FULL_2026_11_01.md#tool-quellen-und-github-regel)

<a id="optionale-profile"></a>
[Optionale Profile](docs/legacy/README_FULL_2026_11_01.md#optionale-profile)

<a id="optional-openhiggsstack--ai-cinema-studio"></a>
[Optional: OpenHiggsStack / AI Cinema Studio](docs/legacy/README_FULL_2026_11_01.md#optional-openhiggsstack--ai-cinema-studio)

<a id="optional-gamedev-3d-studio-nextlevel"></a>
[Optional: GameDev 3D Studio NEXTLEVEL](docs/legacy/README_FULL_2026_11_01.md#optional-gamedev-3d-studio-nextlevel)

<a id="optional-cad_konstrukteur"></a>
[Optional: CAD_Konstrukteur](docs/legacy/README_FULL_2026_11_01.md#optional-cad_konstrukteur)

<a id="optional-architektur-3d-bim"></a>
[Optional: Architektur 3D BIM](docs/legacy/README_FULL_2026_11_01.md#optional-architektur-3d-bim)

<a id="optional-robotertechnik--anlagensteuerung"></a>
[Optional: Robotertechnik & Anlagensteuerung](docs/legacy/README_FULL_2026_11_01.md#optional-robotertechnik--anlagensteuerung)

<a id="optional-wissenschaftliche-science-lab-profile"></a>
[Optional: Wissenschaftliche Science-Lab-Profile](docs/legacy/README_FULL_2026_11_01.md#optional-wissenschaftliche-science-lab-profile)

<a id="-sicherheit-bei-der-nutzung"></a>
[🔐 Sicherheit bei der Nutzung](docs/legacy/README_FULL_2026_11_01.md#-sicherheit-bei-der-nutzung)

<a id="-kostenfalle-durch-cloud-apis-und-bezahldienste"></a>
[⚠️ Kostenfalle durch Cloud-APIs und Bezahldienste](docs/legacy/README_FULL_2026_11_01.md#-kostenfalle-durch-cloud-apis-und-bezahldienste)

<a id="-trading--web3--und-finanzhinweis"></a>
[⚠️ Trading-, Web3- und Finanzhinweis](docs/legacy/README_FULL_2026_11_01.md#-trading--web3--und-finanzhinweis)

<a id="-installationspfade"></a>
[🧭 Installationspfade](docs/legacy/README_FULL_2026_11_01.md#-installationspfade)

<a id="minimal-setup"></a>
[Minimal Setup](docs/legacy/README_FULL_2026_11_01.md#minimal-setup)

<a id="full-setup"></a>
[Full Setup](docs/legacy/README_FULL_2026_11_01.md#full-setup)

<a id="cluster-setup"></a>
[Cluster Setup](docs/legacy/README_FULL_2026_11_01.md#cluster-setup)

<a id="quickstart-gpu-workstation"></a>
[Quickstart GPU Workstation](docs/legacy/README_FULL_2026_11_01.md#quickstart-gpu-workstation)

<a id="quickstart-media-ai"></a>
[Quickstart Media AI](docs/legacy/README_FULL_2026_11_01.md#quickstart-media-ai)

<a id="quickstart-secure-production-like"></a>
[Quickstart Secure Production-like](docs/legacy/README_FULL_2026_11_01.md#quickstart-secure-production-like)

<a id="-dokumentation"></a>
[📖 Dokumentation](docs/legacy/README_FULL_2026_11_01.md#-dokumentation)

<a id="neue-plattformprofile"></a>
[Neue Plattformprofile](docs/legacy/README_FULL_2026_11_01.md#neue-plattformprofile)

<a id="neue-studio--und-spezialprofile"></a>
[Neue Studio- und Spezialprofile](docs/legacy/README_FULL_2026_11_01.md#neue-studio--und-spezialprofile)

<a id="-enthaltene-komponenten--tools"></a>
[🛠️ Enthaltene Komponenten & Tools](docs/legacy/README_FULL_2026_11_01.md#-enthaltene-komponenten--tools)

<a id="-profil-management"></a>
[👤 Profil-Management](docs/legacy/README_FULL_2026_11_01.md#-profil-management)

<a id="profilgruppen"></a>
[Profilgruppen](docs/legacy/README_FULL_2026_11_01.md#profilgruppen)

<a id="-codex-nachbau-und-plattformziele"></a>
[💻 Codex-Nachbau und Plattformziele](docs/legacy/README_FULL_2026_11_01.md#-codex-nachbau-und-plattformziele)

<a id="-verzeichnisstruktur"></a>
[⚙️ Verzeichnisstruktur](docs/legacy/README_FULL_2026_11_01.md#-verzeichnisstruktur)

<a id="-wichtige-hinweise"></a>
[⚠️ Wichtige Hinweise](docs/legacy/README_FULL_2026_11_01.md#-wichtige-hinweise)

<a id="ai-media-studio"></a>
[AI Media Studio](docs/legacy/README_FULL_2026_11_01.md#ai-media-studio)

<a id="start-here"></a>
[Start Here](docs/legacy/README_FULL_2026_11_01.md#start-here)

</details>
