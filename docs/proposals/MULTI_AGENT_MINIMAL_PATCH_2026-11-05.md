# Minimaler Patch-Vorschlag: Navigation und Multi-Agent-PoC

Stand: 05.11.2026. **Nicht angewendet. Kein Installer, kein lauffaehiger PoC.**
Grundlage: [Audit mit Befunden und Testbelegen](../audit/MULTI_AGENT_AUDIT_2026-11-05.md).

## Patch A: aktuelle Alltagslinks sichtbar machen

In `readme.md` unmittelbar vor `Zum Lesen im Setup:` eine kleine Tabelle einfuegen.
Die sechs vorhandenen Themenlinks und alle historischen Anker bleiben erhalten.
Kein neues grosses Inhaltsverzeichnis, keine Emojis oder vergroesserten Zwischenueberschriften.
Aktuelle Bedienung wird nicht mehr ausschliesslich unter der historischen Klappe versteckt.

```diff
--- a/readme.md
+++ b/readme.md
@@
+Schnellzugriff fuer den Alltag:
+
+| Aufgabe | Aktueller Einstieg |
+|---|---|
+| Quickstart und Voraussetzungen | [Erste 60 Minuten](docs/FIRST_60_MINUTES.md) |
+| Setup-Skripte finden | [Verzeichnisstruktur](docs/DIRECTORY_LAYOUT.md) |
+| Speicherplatz und Bereinigung | [Bereinigungsprofil](docs/Profile/Storage_Cleanup_Manager.md), [Installationsreste pruefen](scripts/cleanup_installation_residues.sh) |
+| Gegenwaertiger Status | [Aktueller Stand](docs/CURRENT_STATUS.md) |
+| Erstinstallation | [Signierter Einstieg mit Minisign](docs/SIGNED_RELEASES.md), [Branch-Auswahl](docs/INSTALL_BRANCH_SELECTION.md) |
+| Setup erneut starten | Im geprueften Checkout: `bash ./setup_ultimate.sh` |
+| Setup aktualisieren oder entfernen | [Update-Helfer](scripts/auto_update_hard.sh), [datenerhaltender Core-Uninstall](docs/P0_A_CORE_UNINSTALL.md), [Status-Backup](docs/INSTALLATION_STATUS_BACKUP.md) |
+
+Skriptlinks zeigen Quellcode, starten ihn nicht. Erst Plan/Anleitung pruefen.
+Core-Uninstall entfernt nicht automatisch alle optionalen Tools oder das ganze Setup.
+
 Zum Lesen im Setup: Hauptmenue **10 - Dokumentation & API-Key Guide**.
```

Der Diff ist ein Entwurfsfragment, kein automatisch anzuwendender Patch.
Keine Empfehlung fuer unsigniertes `curl | bash`, kein `git reset --hard` und kein
pauschales Loeschen des User-Workspace. Die kurze alte `docs/QUICKSTART.md` verweist noch
auf `bash install.sh` ohne den heutigen Freigabevertrag; sie sollte separat auf den signierten
Einstieg umgestellt werden, nicht als ungepruefter aktueller Hauptlink zurueckkehren.

Abnahme fuer Patch A: README unter 200 Zeilen, sechs Themenlinks erhalten,
historische 45 Anker unveraendert, alle Alltagseintraege ausserhalb `<details>`,
Markdownlint und relative Links gruen. Navigationstests um diese Sichtbarkeit ergaenzen.
Rueckbau: nur die neue Tabelle entfernen; keine Anker oder Benutzerdateien anfassen.

## Patch B: nur Rollen-/Workflowvertrag

Vorgeschlagene **neue** Datei `config/agents/team.example.json`:

```json
{
  "schema": 1,
  "status": "planned",
  "orchestrator": "microsoft-agent-framework",
  "execution_enabled": false,
  "backend": "native-linux-sandbox",
  "default_access": "read-only",
  "cloud_enabled": false,
  "mcp_enabled": false,
  "max_parallel_jobs": 1,
  "max_parallel_model_requests": 1,
  "max_fix_rounds": 1,
  "roles": ["planner", "explorer", "worker", "tester", "reviewer", "security"],
  "workflow": [
    "planner", "explorer", "approve-write", "worker",
    "tester", "reviewer", "security", "approve-result"
  ],
  "budgets": {
    "cpus_per_worker": 2,
    "memory_mib_per_worker": 2048,
    "pids_per_worker": 128,
    "seconds_per_role": 900,
    "total_seconds": 3600,
    "total_model_requests": 32
  },
  "automatic_commit": false,
  "automatic_merge": false,
  "deployment_enabled": false,
  "runtime_verified": false
}
```

Diese Datei allein erzwingt **keine** Sandbox oder Rechte. Sie darf vor einem technisch
durchgesetzten Backend keine Ausfuehrung aktivieren. Gesamtzeit/Requests gelten ueber alle
Rollen und Retries. Neue Profil-IDs erst gegen `config/profiles.yml` pruefen und am Ende
der bestehenden Tool-Baseline registrieren; kein vorschnelles `tested`/`stable`-Label.

## Patch C: kleinster ausfuehrbarer PoC nach Freigabe

Zukuenftige Dateigruppen, **noch nicht erstellt**:

| Pfad | Begrenzter Auftrag |
|---|---|
| `scripts/agents/team.py` | Plan/Status/Doctor standardmaessig; explizite Start-/Cancel-/Resume-Aktionen, validierte Tasks, kein freier Shellstring |
| `scripts/agents/sandbox_linux.py` | Native Namespaces, private Mounts/Umgebung, Seccomp und Cgroup-Gates; fehlende Isolation blockiert |
| `scripts/agents/team_state.py` | Atomare Run-/Artefaktzustaende, Hash-gebundene Approvals, verifizierte Lease/Recovery |
| `scripts/agents/team_metrics.py` | Redigierte Messberichte; unbekannte Token-/GPU-Werte explizit unbekannt |
| `scripts/agents/team_start.sh` und `team_stop.sh` | Duennen geprueften Controller aufrufen, keine Installation und kein pauschales PID-Kill |
| `tests/test_agent_team.py` | Uebergaenge, sechs Rollen, Budget, Approvals, kein Commit/Push |
| `tests/test_agent_team_sandbox.py` | Host-Schreibversuch, Netzwerk, Symlinks, Git-Metadatenzugriff, fehlende Cgroups/Namespaces |
| `tests/fixtures/agent_team_toy/` | Ungefaehrliches Testprojekt ohne Secrets/Netzwerk; feste Referenztests |
| `docs/agents/LOCAL_MULTI_AGENT_TEAM.md` | Bedienung, Plattformgrenzen, Doctor, Cancel/Resume, Rollback und Messprotokoll |

Bestehende `workbench.py`-Aufrufe nicht stillschweigend umdeuten. Neue Schnittstelle
zuerst additiv. Promptantworten bleiben Daten, Rollenwahl/Dateirechte/Budgets bestimmt
der vertrauenswuerdige Controller. Native CLIs aus bestehenden Git-Buildvertraegen verwenden.
Kein neuer Docker-/Kubernetes-/Cloud-Dienst als Voraussetzung oder Standard.

Testfolge: Schema/Plan ohne Seiteneffekte, Mock-Handoff, Sandbox-Negativtests, Crash/Cancel,
erst danach bestaetigter lokaler Toy-E2E mit einem vorhandenen Modell. Fuer Worker-Outputs
einen verifizierten Patch-/Snapshot-Handoff implementieren statt den Clean-Guard zu entfernen.
Nach E2E unabhaengige Referenztests und getrennte Single-/Multi-Agent-Laeufe messen.

Abnahme: Backend-Schreib-/Netzwerkgrenzen technisch bewiesen; neue Tasks nach Cancel
blockiert, bis Prozessende bestaetigt; keine automatische Patchuebernahme;
bei jeder Drift erneute Freigabe. Ohne geeigneten Linux-Testhost bleibt dieser Satz offen.

Rollback: Controller deaktivieren, keine weiteren Tasks annehmen, eigenes Prozessende
nachweisen, Reports und Worktrees erhalten. Keine automatischen Git- oder Datenbereinigungen.
Das alte Setup bleibt benutzbar. Erst nach Review einen separaten Branch/PR anlegen;
dieser Audit veraendert keine vorhandenen Branches und veroeffentlicht nichts.
