---
name: sprach-infra-tooling
description: Recherchiere und dokumentiere eine passende Sprach-, Shell-, Infrastruktur- oder KI-Toolchain fuer ein konkretes Projekt im Ultimate KI Setup. Verwende diesen Skill fuer Toolauswahl, Stack-Vergleiche und die Zuordnung vorhandener Go-/Rust-CI- und Deployment-Vorlagen.
---

# Sprach-, Infrastruktur- und KI-Toolauswahl

Diese Repository-Fassung rekonstruiert die im Manus-Interview beschriebene Faehigkeit. Sie ist kein
importiertes Manus-Original und wird nicht global aktiviert.

## Auswahlprozess

1. Lies Projektregeln, bestehende Konfiguration und bekannte Nutzerangaben. Verwende das
   [Tooling-Briefing](assets/tooling-brief.md) fuer Einsatzgebiet, Betriebsmodell, Hardware,
   Datenschutz, Budget, Integrationen und Bedienniveau. Frage nur nach fehlenden Angaben, die die
   Entscheidung wirklich veraendern. Kennzeichne Annahmen; frage bereits bekannten Kontext nicht
   erneut ab.
2. Suche zuerst in der [62er-Uebersicht](../../docs/DEVELOPMENT_TOOLS_OVERVIEW.md) und der
   [Tool-Registry](../../config/tools.yml). Unterscheide registriert, Buildrezept vorhanden, lokal
   installiert und tatsaechlich getestet. Ein Registry-Eintrag oder README ist kein
   Installationsnachweis.
3. Recherchiere Veraenderliches in Primaerquellen: offizielles GitHub-Repository, Buildanleitung,
   Lizenz, Releases und Provider-Dokumentation. Erfasse Datum, Quellen, offene Abrufluecken und bei
   Builds den gewaehlten Commit. Ein GitHub-Client macht den zugehoerigen Cloud-Dienst nicht Open
   Source. Bei Interviewtexten nutze die [Quellenpruefung](references/interview-source-review.md),
   um Zitate, behauptete Artefakte und echte Nachweise getrennt zu bewerten.
4. Empfiehl die kleinste passende Kombination und eine begruendete Alternative. Ordne je Werkzeug
   Aufgabe, lokaler/Cloud-Datenfluss, Lizenz, Voraussetzungen, RAM/VRAM/Disk-Budget und vorhandenen
   Installationsweg zu. Fehlende Messwerte bleiben offen. Keine pauschale Gratis-, Datenschutz- oder
   GPU-Support-Zusage.
5. Bei CI-/Containerfragen lies nur die benoetigte
   [CI-/Deployment-Referenz](references/ci-and-deployment.md). Bei einer Praesentationsfrage pruefe
   zuerst die vorhandene Praesentation; beschreibe einen fremden Manus-Link nicht als bereits
   vorliegende PPTX-Datei.
6. Liefere Auswahlmatrix, Quellen mit Pruefdatum, begruendete Annahmen und einen konkreten naechsten
   Schritt. Stelle geplante und bereits ausgefuehrte Aktionen getrennt dar. Installation,
   Aktivierung und Deployment sind eigene Auftraege.

## Projektgrenzen

Tools primaer aus GitHub statt als Docker-Installation vorbereiten. Optionale Container-Beispiele
betreffen die Auslieferung eigener Anwendungen. Bestehende WSL-Verbote, Budget-/Speichergrenzen und
Datenschutzvorgaben bleiben wirksam. Keine Cloud-Abfrage mit Nutzerdaten, globale
Skill-/Toolinstallation, aktiven Workflow, Wallet-Zugriff, Commit/Push oder Rollout aus einer
Recherche ableiten.

Fuer eine nachfolgende freigegebene Umsetzung ist
[agentic-project-delivery](../agentic-project-delivery/SKILL.md) zustaendig. Die
[Interview-Einordnung](../../docs/tutorials/manus-interview-2026-10-22.md) enthaelt den aktuellen
Bezug zu diesem Setup.
