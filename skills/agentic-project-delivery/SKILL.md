---
name: agentic-project-delivery
description: Nutze den dokumentierten lokalen Entwicklungsablauf des Ultimate KI Setups fuer abgegrenzte Coding-Aufgaben, Go-/Rust-CI-Beispiele und gepruefte Deployment-Vorbereitung. Kein Manus-Originalagent und keine automatische System- oder Cloud-Verwaltung.
---

# Gepruefte Projektlieferung

Nutze diesen Skill, wenn ein Projekt mit Code, Tests, Bericht oder CI-Vorlagen bearbeitet werden
soll. Die Installation/Aktivierung des Skills selbst ist kein Auftrag, ein Projekt zu bauen,
Cloud-Dienste aufzurufen oder etwas zu deployen.

## Arbeitsablauf

Wenn zuerst Werkzeuge/Sprachen ausgewaehlt werden muessen, nutze den separaten
[Auswahl-Skill](../sprach-infra-tooling/SKILL.md). Dieser Umsetzungs-Skill bleibt fuer die danach
freigegebene Projektarbeit zustaendig.

1. Lies Auftrag, Projektregeln, Git-Status und vorhandene Tests. Bestimme einen konkreten
   Projektordner, Zielstack und die tatsaechlich freigegebenen Aktionen. Erhalte unabhaengige
   Nutzer-Aenderungen; arbeite nicht in einer anderen Kopie.
2. Waehle die kleinste passende Pruefkette. Lies den
   [lokalen Entwicklungsablauf](../../docs/tutorials/manus-development-workflow.md) fuer Vorschau
   und Testbericht; fuer andere Sprachen den
   [Quellenkatalog](../../docs/tutorials/manus-language-infrastructure-sources.md).
3. Pruefe vorhandene Laufzeit, Lockfiles, freien Ziel-/Temp-Speicher und bei WSL-Vorgaben die
   Hostreserve. Fehlende Werkzeuge nicht eigenmaechtig installieren. Ein WSL-Verbot bleibt bestehen:
   kein wsl.exe, kein Start oder Bearbeiten der Distro.
4. Setze einen kleinen Patch um. Fuehre nur freigegebene Checks aus und erfasse deren echte
   Exit-Codes. Linter/Tests/Buildhooks koennen Code ausfuehren. Vorschau nur auf Loopback, mit
   synthetischen Daten und anschliessendem Stoppen.
5. Begrenze automatische Fehlerkorrektur auf drei Runden pro Aufgabe. Halte bei gleichem Blocker,
   fehlenden Rechten, Platzmangel oder Budgetgrenze mit Diagnose an; keine Endlosschleife. Die
   Rundengrenze ist eine Agentenanweisung, kein technischer Sandbox- oder Timeout-Mechanismus.
6. Berichte Ergebnis, Aenderungen, Befehle/Exit-Codes, nicht ausgefuehrte Tests und offene Risiken.
   Ein Checkout oder erfolgreicher Build ist kein Beweis fuer einen gestarteten Dienst oder eine
   erfolgreiche Modell-/API-Abfrage.

## CI und Deployment

Bei Go/Rust lies [CI/CD und Deployment](../../docs/tutorials/manus-ci-cd-deployment.md) und passe
die [inaktiven Beispiele](../../examples/manus-ci-cd/README.md) an das Zielprojekt an. Pruefe dort
Laufzeit-Pins, Paketpfade und vorhandene Workflows. Kopiere nichts ohne Auftrag nach
`.github/workflows/`; das kann Runs ausloesen.

PR-Code erhaelt keine Release-/Cluster-Secrets. Verlange eine eigene Freigabe fuer
Paketinstallation, Image-Push, Git-Commit/Push, Hardware, Cloud-Ressourcen, Kubernetes-Rollout oder
Datenbankmigration. Eine Freigabe fuer eine Aktion autorisiert keine anderen Aktionen. Keine
Wallet-, Replikations- oder Autoinstallationsrechte an Automaton/OpenClaw aus dieser Skill-Nutzung
ableiten.

## Ergebnisformat

Lieferung: kurzer Ergebnisbericht, Artefaktpfade, ausgefuehrte Pruefungen mit Exit-Codes und
verbleibende TODOs. Keine Secrets oder kompletten Provider-/ Header-/State-Dumps. Nicht getestete
Zielhosts/Architekturen klar benennen.
