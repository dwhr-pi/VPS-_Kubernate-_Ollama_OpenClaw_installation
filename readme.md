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
- **Betrieb:** [Installationszweige](docs/INSTALL_BRANCH_SELECTION.md), [Backup und Restore](docs/INSTALLATION_STATUS_BACKUP.md).
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

<a id="-schnelle-installation-one-liner"></a>
[🚀 Schnelle Installation (One-Liner)](docs/legacy/README_FULL_2026_11_01.md#-schnelle-installation-one-liner)

<a id="-setup-erneut-starten"></a>
[🔄 Setup erneut starten](docs/legacy/README_FULL_2026_11_01.md#-setup-erneut-starten)

<a id="-setup-aktualisieren-oder-lokal-entfernen"></a>
[🔁 Setup aktualisieren oder lokal entfernen](docs/legacy/README_FULL_2026_11_01.md#-setup-aktualisieren-oder-lokal-entfernen)

<a id="boardroom-profil"></a>
[Boardroom-Profil](docs/legacy/README_FULL_2026_11_01.md#boardroom-profil)

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
