---
name: fullstack-project-bootstrapper
description: Bereite ein abgegrenztes Go- oder Rust-Projekt als API, Worker oder CLI mit Projektstruktur, Tests und Dokumentation vor. Ordne bei Bedarf bestehende inaktive CI-/Deployment-Vorlagen zu, ohne sie automatisch zu aktivieren.
---

# Go-/Rust-Projektvorbereitung

Eigene Repository-Fassung des im Meta-Interview beschriebenen Prozesses, kein gelieferter
Meta-Originalskill und nicht global installiert.

1. Bestimme aus Auftrag und vorhandenem Projekt Sprache, API/Worker/CLI und freigegebenen
   Zielordner. Lies Git-Status, Regeln und vorhandene Manifeste. Wenn eine entscheidende Angabe
   fehlt, gezielt nachfragen; kein neues Framework oder Repository allein aus einem
   Interviewbeispiel ableiten.
2. Fuer Go vorhandenes go.mod und Paketlayout erhalten; cmd/ und internal/ nur nach Projektbedarf
   anlegen. Fuer Rust vorhandene Cargo-Workspaces und Library-/Binary-Ziele beruecksichtigen. Keine
   Dateien oder Lockfiles blind ersetzen.
3. Erzeuge kleine Implementierungsschritte, synthetische Tests, README und passende Ignore-Regeln.
   Keine Modell-/API-Keys oder echte Cloud-/DB-Ziele voreintragen. HTTP-Endpunkte nur fuer eine API,
   Health-Probes passend zur App.
4. Lies bei CI-Anforderung die [vorhandenen Beispiele](../../examples/manus-ci-cd/README.md).
   Vorlagen bleiben ausserhalb .github/workflows, bis Aktivierung beauftragt ist. Go-Race-Tests
   brauchen CGO/Compiler; Cargo.lock/--locked verhindern nicht jede Nichtdeterministik oder
   Netzwerkaktivitaet. Nextest/Scans nicht als vorhanden annehmen.
5. Lies bei Container-/Kubernetes-Anforderung die
   [Deployment-Anleitung](../../docs/tutorials/manus-ci-cd-deployment.md). Das Go-Dockerfile nicht
   fuer dynamisch gelinktes Rust wiederverwenden. Ingress, Replikazahl, Ressourcen und echte
   Image-Digests gesondert bestimmen. Tools werden im Setup primaer aus GitHub statt per Docker
   installiert.
6. Nutze fuer freigegebene Tests und begrenzte Korrekturrunden den
   [Umsetzungs-Skill](../agentic-project-delivery/SKILL.md). Berichte geaenderte Dateien,
   Befehle/Exit-Codes, fehlende Voraussetzungen und nicht getestete Ziele. Keine Produktionsreife
   aus Codegenerierung, YAML-Syntax oder einem Scan ableiten.

WSL-Verbote und bestehende Freigabegrenzen bleiben wirksam. Kein Download,
Paket-/Container-/Skill-Setup, Cloud-Aufruf, Wallet, Push, CI-Start oder Rollout ist durch das
blosse Lesen des Skills autorisiert. Eine Python-Simulation ersetzt keinen nativen
Go-/Rust-/Shell-Test.

Kontext und Quellen: [Meta-Interview](../../docs/tutorials/meta-development-tooling.md). Fuer
vorgelagerte Toolauswahl: [sprach-infra-tooling](../sprach-infra-tooling/SKILL.md).
