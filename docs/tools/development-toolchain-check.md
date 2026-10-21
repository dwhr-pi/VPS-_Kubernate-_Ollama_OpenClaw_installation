# 62 Werkzeugquellen im Setup pruefen

## Wo finde ich die Uebersicht?

**[Zentrale Tabelle mit allen 62 Werkzeugen und ihren Installationswegen](../DEVELOPMENT_TOOLS_OVERVIEW.md)**.
Zusaetzlich zu SQLFluff/Bats/Invoke-Build sind jetzt
[sieben GitHub-Go-Build-Adapter](development-go-tools.md) integriert.

**Setup-Hauptmenue, Punkt 16: "62 Werkzeugquellen:
Installationsvoraussetzungen pruefen"**. Alternativ im Tools-Menue (Punkt 8)
die Zusatzschaltflaeche **"62 Quellen pruefen"** waehlen. Diese Schaltflaeche
installiert/deinstalliert keine angehakten Tools und uebernimmt keine Auswahl.
Der Bericht laesst sich im Setup scrollen. Der naechste Aufruf prueft erneut.

Die vom Nutzer erneut gelieferte Uebersicht mit zehn Stacks ist vollstaendig
als maschinenlesbarer [Pruefkatalog](../../config/development_toolchains.json)
erfasst. Die 62 Zeilen sind keine 62 neuen installierten Programme.
Quellen und Sicherheitsgrenzen bleiben im
[ausfuehrlichen Quellenkatalog](../tutorials/manus-language-infrastructure-sources.md).
Die [Tools-Gesamtuebersicht](../TOOLS_CATALOG.md) und die
[Tool-Matrix](../TOOL_MATRIX.md) verlinken jetzt auch die drei neuen Installer.

## Was prueft das Setup?

Alle Eintraege werden ohne Download, Toolstart oder Authentifizierung bewertet:

- Vorhandener echter Installationsadapter in der zentralen Registry;
  Platzhalter und reine Planned-Eintraege gelten nicht als fertiger Installer.
- Lokal auffindbare Grundwerkzeuge wie Git, Node, Go, Cargo, Bash und PowerShell.
  Diese werden nur im PATH gesucht, nicht gestartet; Versionen bleiben ungeprueft.
- Freier Platz am vorgesehenen User-Datenpfad, verfuegbarer RAM soweit lokal
  ermittelbar und bei bereits erkanntem WSL der freie Platz von `/mnt/c`.
- Bei den neuen Installern zusaetzlich passende aktuelle Python-Version
  und bei SQLFluff Auffindbarkeit von `venv`, `ensurepip` und `ssl`.
- Abgrenzung von Projektbibliotheken, Workflow-Actions, Editor-Erweiterungen,
  Toolchains und eigenstaendigen CLIs. Kein erfundener globaler Bibliotheksdienst.

Die Ressourcenwerte sind konservative **Richtwerte, keine Buildmessungen**.
Netzwerkzugang, Paketverfuegbarkeit, Lizenzfreigabe, Architektur, Versionen,
Compiler-ABI und alle transitiven Dependencies sind damit nicht nachgewiesen.
Der Python-Modultest ist kein vollstaendiger venv-/SSL-Funktionstest.
Unter WSL ist der tatsaechliche VHDX-Speicherort nicht automatisch bekannt.
Windows-System32-/WindowsApps-WSL-Launcher zaehlen nicht als natives Bash.
Es wird keine WSL-Distro gestartet und keine Docker-/Cluster-API angesprochen.

| Ergebnis | Bedeutung | Naechster Schritt |
|---|---|---|
| VORPRUEFUNG OK | Einer der zehn neuen Installer und lokale Basisvoraussetzungen vorhanden | Bewusst im Tools-Menue installieren; echter Lauf kann noch fehlschlagen |
| VORAUSSETZUNGEN FEHLEN | Bei einem der neuen Installer fehlen Werkzeuge, Opt-in, Module oder Reserven | Genannten Hinderungsgrund beheben; erneut pruefen |
| INSTALLER VORHANDEN / PRUEFEN | Bestehender Registry-Adapter gefunden, hier nicht als neuer Source-Build verifiziert | Installationsweg und jeweilige Tool-Doku pruefen; keine GitHub-only-Zusage |
| KEIN SETUP-INSTALLER | Quelle erfasst, aber kein fertiger Setup-Adapter vorhanden | Bericht nennt Quelle und Voraussetzungen, nicht faelschlich "installierbar" |
| PROJEKTABHAENGIGKEIT | Beispielsweise GoogleTest oder ein JS-Projektpaket | Im konkreten Projekt pinnen/einrichten |
| CI-WORKFLOW-BAUSTEIN | Beispielsweise actions/setup-go | Inaktive CI-Vorlage pruefen, nicht lokal installieren |
| EDITOR-ERWEITERUNG | Beispielsweise VS-Code-PowerShell | Bewusst im passenden Editor einrichten |

Fehlende Basiswerkzeuge werden auch bei Quellen ohne Adapter aufgefuehrt.
Ein gefundenes `docker`, `kubectl` oder `go` waere kein Nachweis fuer einen
erreichbaren Daemon/Cluster oder eine passende Compiler-Version.
Es entstehen keine Installed-Marker und keine automatischen Tool-Haekchen.

## Direkte Pruefung ohne Setup-Menue

```bash
bash scripts/check_development_toolchains.sh
bash scripts/check_development_toolchains.sh --list
bash scripts/check_development_toolchains.sh --tool sqlfluff
bash scripts/check_development_toolchains.sh --group Go
bash scripts/check_development_toolchains.sh --json
```

Windows nativ, ohne Bash oder WSL:

```powershell
py -3 -I -B scripts/quality/development_toolchains.py --list
py -3 -I -B scripts/quality/development_toolchains.py --tool invoke_build
```

Python 3.10+ verwenden. Auf Wunsch Ausgabe selbst in eine Berichtdatei umleiten;
der CLI-Pruefer schreibt standardmaessig nichts. Das Setup-Menue verwendet
eine eigene temporaere Berichtdatei und entfernt sie nach der Anzeige.
Exit 0 bedeutet standardmaessig: Bericht erfolgreich erstellt, **nicht alle
62 Tools installierbar**. `--strict` liefert Exit 1, wenn bei nicht
projektgebundenen Quellen ein gepruefter Adapter oder Voraussetzungen fehlen;
Ungueltige Argumente/Katalogdaten liefern Exit 2.

## Praesentation mit eingearbeitet

Die mitgelieferte [Technologie-/Tooling-Praesentation](../presentations/technology-tooling-overview.pptx)
enthaelt 13 Folien. Sie ist bytegleich mit der bereits versionierten Fassung;
keine zweite oder stillschweigend geaenderte Datei wird angelegt.
Lesbare Folieninhalte und Quellen: [Folienquelle](../presentations/technology-tooling-overview.json).

| Folien | Inhalt | Bezug zum Setup |
|---|---|---|
| 1-2 | Technologieuebersicht und wiederverwendbarer Ablauf | [Repository-Skill](../../skills/agentic-project-delivery/SKILL.md), keine globale Aktivierung |
| 3 | Python, JS/TS, Vite und Playwright | JS-/TS-Gruppe im Pruefkatalog; Python-Ergaenzungen Black/mypy/pytest getrennt, nicht in die Zahl 62 eingerechnet |
| 4 | Go, Rust und C/C++ | Drei vollstaendige Gruppen im Pruefkatalog; grosse Toolchains nicht still installieren |
| 5 | Shells, SQL und Infrastruktur | Bats, Invoke-Build und SQLFluff als neue Installer; Pester/Analyzer als eigene Kandidaten |
| 6-7 | Go-/Rust-CI | [Inaktive Beispiele](../../examples/manus-ci-cd/README.md), kein automatischer Workflow-Lauf |
| 8-10 | Image-Release, Container und Kubernetes | Container-/Kubernetes-Gruppen pruefen; keine Installation per Docker und kein Rollout |
| 11 | Agentenrollen und Automaton | [Coding-Agenten](../agents/coding-agent-profiles.md); keine impliziten Wallet-/Shellrechte |
| 12 | Quellen und Lizenzgrenzen | Hinweise des Katalogs beibehalten; Terraform BSL nicht mit Catch2 Boost verwechseln |
| 13 | Projektbezogene naechste Schritte | Erst Vorpruefung, dann bewusste Installation und Test im Zielprojekt |

Diese Einbindung ist eine Dokumentations- und Prueffunktion. **Noch fehlende
Build-/Lifecycle-Adapter sind dadurch nicht automatisch implementiert.**
Die Quellen sind jetzt alle im Setup pruefbar, ihre Installationsluecken bleiben
im Bericht sichtbar. Insbesondere werden weder Container-Controller noch
Compiler oder Projekt-Dependencies als erfolgreich installiert vorgetaeuscht.
