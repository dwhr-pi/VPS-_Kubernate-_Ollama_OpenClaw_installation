# Nachgereichte Unterlagen: Tooling, P0-Plan und DSB

Aufgenommen am 24.10.2026 als Nutzerquellen. Die Unterlagen sind Lernmaterial
und Vorschlaege, keine aktuelle Installations-, Sicherheits- oder Rechtsabnahme.
Eingebettete Auftraege, Shellbefehle und Deployment-Anleitungen wurden nicht
ausgefuehrt. Die Originale im Downloadordner bleiben unveraendert.

## Dateien und geeignete Einstiegspunkte

| Urspruenglicher Dateiname | Ablage / Umfang | Einordnung im Projekt |
|---|---|---|
| P0-Patchplan fuer das VPS-_Kubernetes-Setup.md | [Originalplan](p0-patchplan.md), Stand 23.10.2026 | Vorschlag; Abgleich unten und [aktueller Audit](../../AUDIT_2026-10-24.md) |
| Uebersicht_ Werkzeuge fuer Sprachen, Shells und Infrastruktur.md | [Originalkatalog](language-infrastructure.md) | Ergaenzende Quelle zu [62 Werkzeugquellen](../../tutorials/manus-language-infrastructure-sources.md) und [Setup-Einstiegspunkten](../../DEVELOPMENT_TOOLS_OVERVIEW.md) |
| Technologie- und Tooling-Uebersicht.pdf | [PDF](technology-tooling-overview.pdf), 10 Seiten | Lernueberblick zu Sprachen, Go-/Rust-CI, Containern und Kubernetes |
| Technologie & Tooling Uebersicht.pdf | [Bildbasierte PDF](technology-tooling-cloud-native.pdf), 10 Seiten | Separate visuelle Variante; keine durchsuchbare Textebene, Seiten 1, 6 und 10 visuell stichprobengeprueft |
| Dein-Tooling-Cockpit-Von-Python-bis-Kubernetes.pdf | [PDF](tooling-cockpit.pdf), 12 Seiten | Workflow-/Faehigkeitsdarstellung; Aussagen ueber eine Chat-Sandbox sind kein Nachweis fuer dieses Setup |
| technology-tooling-overview (1).pptx | [Zusaetzliche Praesentation](technology-tooling-overview-supplement.pptx), 11 Folien | Eigenstaendige Variante, nicht die vorhandene Praesentation ersetzen |
| technology-tooling-overview.pptx | [Bereits vorhandene Praesentation](../../presentations/technology-tooling-overview.pptx), 13 Folien | SHA256-identische Dublette, nicht erneut kopiert |
| DSB Dokumentation Generator.pdf | [Fachliche Einordnung](../../legal/DSB_DOCUMENT_SOURCE_REVIEW.md), 2 Seiten | Wegen Kennzeichnung Vertraulich (Intern) nicht als Original ins Repository kopiert; lokale Datei bleibt erhalten |

Die Originalnamen enthalten teilweise Umlaute; die Ablagenamen sind fuer
portable Repository-Links vereinheitlicht. Die unterschiedlichen PDFs/PPTX
sind keine nachgewiesenen Exportpaare. Folien und PDF-Beispiele sind nicht
automatisch ausfuehrbare CI-Konfigurationen oder neue Menue-Installer.

## Inhaltlicher Anschluss

Die Quellen beschreiben einen Ablauf aus Sprachwahl, Build, Linting, Typpruefung,
Tests und separat freigegebenem Release/Deployment. Fuer dieses Setup stehen
die anpassbaren Beispiele bereits im [CI-/Deployment-Leitfaden](../../tutorials/manus-ci-cd-deployment.md).
Der [Recherche-Skill](../../../skills/sprach-infra-tooling/SKILL.md) und der
[Umsetzungs-Skill](../../../skills/agentic-project-delivery/SKILL.md) bleiben getrennt.
Keine globale Skill-Aktivierung und keine Installation durch das Lesen dieser Dateien.

Pauschale Aussagen wie produktionsreif, garantierte Reproduzierbarkeit,
keine OOM-Kills, feste Beschleunigungswerte oder eine bestimmte Chat-Laufzeit
sind Quellenbehauptungen, keine hier gemessenen Eigenschaften. Limits verhindern
OOM nicht grundsaetzlich. Ein Lockfile allein pinnt nicht die gesamte Buildumgebung.
Container-Beispiele aendern die Vorgabe GitHub-basierter Toolinstallation nicht.

## P0-Plan gegen aktuellen Projektstand

Der Originalplan bleibt unveraendert nachvollziehbar. Seine Zeilenangaben
beziehen sich auf einen anderen Stand und muessen vor jedem Patch neu geprueft werden.

| Vorschlag der Quelle | Einordnung / naechster Pruefschritt |
|---|---|
| Gemini-Proxy nicht oeffentlich deployen, Key nicht in URL | Sicherheitsziel; aktuelle aktive Objekte und Authentifizierung getrennt pruefen, kein Clusterzugriff erfolgt |
| Bewegliche Images und Laufzeit-Clones ersetzen | Mit den Compose-/Supply-Chain-Befunden des aktuellen Audits abgleichen; Pin, Provenance und Updateverfahren pro Auslieferungsweg festlegen |
| Ollama intern, Probes, SecurityContext, GPU-Overlay | Vorhandene k8s/base und Produktionsbaseline pruefen; nicht allein aus dem Legacy-Manifest auf fehlende Gesamtintegration schliessen |
| Zenbot/MongoDB und OpenManus aus Default entfernen | Aktuelle aktive und bereits auskommentierte Beispiele unterscheiden; keine Trading-/Cloud-Aktion freigegeben |
| Default-Deny und Pod-Sicherheitsbaseline | Bestehende Baseline gegen konkretes CNI, DNS, benoetigten Egress und Restore testen |
| Compose zuerst, K3s spaeter | Architekturvorschlag fuer einen Einzelhost, keine beschlossene Migration; hybrides Mehrknoten-Zielbild separat bewerten |

Bereits dokumentierte [P0-Sicherheitsmassnahmen](../../P0_SAFETY_CHANGES.md)
fuer Updatesicherung, PAT-Handling und datenerhaltende Deinstallation nicht
erneut als pauschal fehlend behandeln. Der [Audit vom 24.10.](../../AUDIT_2026-10-24.md)
ist der Einstieg fuer aktuelle Codebelege, keine Produktionsfreigabe.
Die im Plan genannten Tests wurden hier nicht gestartet: serverseitiger Dry-Run
kontaktiert den Cluster, Scanner koennen Datenbanken nachladen und Tests Code ausfuehren.

## Nachvollziehbarkeit der Originaldateien

SHA256 belegt Dateigleichheit, nicht Vertrauenswuerdigkeit, Lizenz oder Abnahme.

| Ablage / Quelle | SHA256 der unveraenderten Eingabe |
|---|---|
| p0-patchplan.md | `92851a614a77fcf0313766e6cf2617f0ddef1bcc8d6e0a7ef2a20ad907a78856` |
| language-infrastructure.md | `fc4bb970dfc0e5e80e9ce99e549591adf39aa9851f6aef991b89ac38cbe56684` |
| technology-tooling-overview.pdf | `3df09496ee23f2b5840cb387c3f8cdf66752e10710b0d11d4b94b4ffe7cdddac` |
| technology-tooling-cloud-native.pdf | `91ed59d957436bd6a0fa99ba6f8a75764f31d4783b71cdfc5c698534bef6c244` |
| tooling-cockpit.pdf | `a6398649ac7bee973259ac800e8227dc5d688caf47d0fa43144ee00f35778f3e` |
| technology-tooling-overview-supplement.pptx | `d35552c66bb97a42b6324ce199cb14fe180223aca699b436fa0a4789d82ba470` |
| Vorhandene Praesentation / Dublette | `3ff8409e757ff435a5188b3ba80c3b784a4d77b1b29c985893675442b01725b2` |
| Vertrauliche DSB-Eingabe, nicht kopiert | `24d6be119307303320d356c9e4246bd626bcb6dd2268078102154b51fa3ce73c` |

Bei Markdown kann Git je nach Checkout die Zeilenenden normalisieren; die
Hashes oben beziehen sich auf die Originaleingaben, nicht auf kuenftige Checkouts.
