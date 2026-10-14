# Agentic Coding Local First

Status: **planned / documentation-first**, keine automatische Installation.
Zielgruppe: Einsteiger und Entwickler mit einem freigegebenen Testrepository.

## Zweck und Tools

Kleine Repo-Aufgaben mit Spezifikation, gezieltem Patch, Testfeedback und Review
statt eines unbeschraenkten autonomen Prozesses. Minimal ein Coding-Client
(z. B. vorhandenes Aider) und optional vorhandenes Ollama. Continue/OpenHands/
OpenCode sind Alternativen, keine zwingende gemeinsame Toolchain.
LangGraph, CrewAI und Microsoft Agent Framework sind optionale Ausbaupfade.
AutoGen-Upstream ist im Maintenance Mode; bestehende Installationen nicht
automatisch migrieren. Automaton bleibt ein gesperrter Forschungspfad.

## Minimal-/Ausbaupfad

```bash
bash scripts/profiles/Agentic_Coding_Local_First_install.sh --dry-run
```

Das Profil beschreibt nur den Plan. Ein normaler Installationsaufruf liefert
Exit-Code 2 und darf nicht als erfolgreiche Profilinstallation gewertet werden.
Ausbau erst nach Client-/Modelltest, festem Testbefehl, Sandbox, Queue-Lock
und ausdruecklich freigegebenen Schreibrechten. Keine automatische Deinstallation
oder Loeschung von Projekten/Modellen.

## Rechte und Ressourcen

Default read-only/Plan, maximal ein Job. Nach separater Freigabe kleine Patches
im vereinbarten Arbeitsbereich; maximal drei Korrekturrunden als Zielbudget,
nicht als bereits implementierte Runner-Garantie. Keine Secrets, produktiven
Daten, Wallets, Cloud-Provisionierung, freien Shellstrings, Live-Deployments
oder autonomen Security-Aktionen. Commit/Push/PR jeweils bewusst freigeben.

RAM/VRAM/Disk haengen von Client, Modell, Browser und Build ab; keine allgemeine
Mindestzusage. WSL2 braucht Host-SSD-Reserve, MiniPC/RPi nur passende kleine Jobs,
VPS als privater Planer, GPU-Workstation optional fuer lokale Inferenz.
K3s ist nicht erforderlich und macht unsicheren Code nicht automatisch sicher.
Keine neuen oeffentlichen Ports und keine erforderliche API-Key-Variable im Profil.

## Beispiele, Ergebnisse und Tests

Beispielprompt: "Erklaere den Kontaktfilter aus TASK.md und schlage einen
minimalen Patch mit Negativtests vor. Noch nichts aendern oder ausfuehren."
Ergebnisse: bereinigter Diff-/Testbericht im freigegebenen Projekt; keine
privaten Logs oder Agentengedaechtnisse im oeffentlichen Git.
Ungeklaerte Anforderungen, fehlerhafte Baseline oder Budgetende sind Stop-Gruende.
Bei Fehlern zuerst echten Zustand und Diff pruefen, keine automatischen Resets.

[Ausfuehrliches Tutorial](../AGENTIC_CODING_GUIDE.md),
[Tools und Integrationsstatus](../tools/agentic-coding.md),
[Aufgabenvorlage](../../examples/agentic_coding/TASK.md).
