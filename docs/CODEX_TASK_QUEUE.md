# Codex Task Queue

## Ziel

Codex-, OpenClaw-, n8n- und Setup-Auftraege sollen nicht parallel das System ueberlasten. Die Queue
ist standardmaessig FIFO und startet maximal einen Job gleichzeitig.

## Gepruefte Grenzen und Sperren (20.10.2026)

- Alle Worker fuer denselben `QUEUE_HOME` verwenden eine gemeinsame `flock`- Worker-Sperre. `flock`
  aus util-linux muss bereits vorhanden sein; bei Fehlen wird kein ungesicherter Worker gestartet.
  Parallelitaet >1 wird abgelehnt.
- Eine zweite, kurze Metadatensperre verhindert verlorene TSV-Eintraege. Sie wird waehrend der
  Jobausfuehrung freigegeben, damit neue Jobs eingereiht und wartende Jobs pausiert/abgebrochen
  werden koennen.
- TSV wird im gleichen Verzeichnis atomar ersetzt. Spalte 8 enthaelt den letzten Exit-Code; alte
  sieben-spaltige Zeilen bleiben lesbar. SQLite erhaelt bei der naechsten veraendernden Aktion eine
  `exit_code`-Spalte, ohne Jobs zu verwerfen.
- `queue_status.sh` liest nur bestehende Daten, fuehrt `config.env` nicht aus und zeigt keine
  Rohkommandos an. Die veraendernden Befehle laden weiterhin deine lokale Shell-Konfiguration: nur
  vertrauenswuerdige eigene Config nutzen.
- Alle CLI-Einstiege akzeptieren `--dry-run` als **erstes** Argument ohne Dateiaenderung, auch
  Worker/Pause/Resume. Explizites Ausfuehren eines Workers bleibt eine Freigabe zur Ausfuehrung
  deiner eingereihten Shell-Kommandos.
- Pause/Resume betreffen nur wartende Jobs, nicht einen laufenden Prozess. Cancel markiert nur
  wartende TSV-Jobs; kein Stoppen laufender Prozessbaeume und kein SQLite-Cancel implementiert. Nach
  einem Absturz werden `running`- Jobs nicht automatisch erneut gestartet: erst moegliche
  Restprozesse pruefen.
- Der Job-Timeout eskaliert nach weiteren 10 Sekunden auf Kill. Absichtlich abgekoppelte
  Daemons/Prozessbaeume sind dadurch nicht verlaesslich eingegrenzt; dafuer bleiben
  Prozessgruppen-/cgroup-Regeln ein gesonderter Ausbaupunkt.

RAM, Load und freier Platz im Queue-Dateisystem werden vor einem Job geprueft. `MIN_DISK_FREE_MB`
ist standardmaessig 1024. Das ersetzt **nicht** den Tool- Preflight fuer dessen Zielverzeichnis oder
die Windows-/WSL-VHDX-Hostplatte. Es sind Start-Gates, keine harten CPU-/RAM-/GPU-/Netzwerkgrenzen.
Diese sowie cgroups, Wiederanlauf und vollstaendige Retry-/Abbruchsteuerung bleiben offen. Alle
Zugriffe auf dieselbe Queue muessen denselben `QUEUE_HOME` nutzen. Die minimalen
Sperr-/Umbenennungsregeln setzen ein lokales Dateisystem voraus.

TSV ist der einfache Einstieg; `queue_add.sh` legt dessen Beispielkonfiguration an.
`queue_submit.sh` verwendet bei vorhandenem/konfiguriertem TSV denselben Pfad; ohne TSV bleibt der
bestehende SQLite-Pfad erhalten. Backends nicht manuell mischen. Weder ein kontinuierlicher Dienst
noch die globale Umleitung aller schweren Setup-Jobs wird durch diese Skripte automatisch
eingerichtet.

Tests/Grenzen: [Projektqualitaet](REPOSITORY_QUALITY.md).

## Minimalmodus

- Format: TSV-Datei unter `~/.openclaw/job-queue/jobs.tsv`.
- Config: `~/.openclaw/job-queue/config.env`.
- Logs: `~/.openclaw/job-queue/logs/`.
- Parallelitaet: `MAX_PARALLEL_JOBS=1`.
- Prioritaeten: `low`, `normal`, `high`.
- Status: `queued`, `running`, `done`, `failed`, `paused`, `cancelled`.

## Befehle

```bash
bash scripts/queue/queue_add.sh --priority normal -- "echo Hallo"
bash scripts/queue/queue_status.sh
bash scripts/queue/queue_run_next.sh
bash scripts/queue/queue_cancel.sh <job_id>
bash scripts/queue/queue_worker.sh
```

## Schwere Jobs

Diese Jobs sollen spaeter nur ueber Queue laufen:

- n8n-Monorepo-Build
- Blender-Build
- Airbyte
- ComfyUI
- grosse Modell-Downloads
- Kubernetes-/K3s-Deployments
- Media-/Avatar-/RVC-/DiffSinger-Renderjobs

## Opt-in Flags

- `QUEUE_ENABLE_WORKER=1`
- `INSTALL_HEAVY_TOOLS=1`
- `MEDIA_INSTALL_MODE=full`
- `SECURITY_INSTALL_SCANNERS=1`

## Sicherheitsregeln

- Keine API-Keys oder Tokens in Queue-Kommandos schreiben.
- Jeder Job braucht Timeout und Log.
- Bei Low-RAM/Low-Disk keine neuen Jobs starten.
- Fehler erzeugen Diagnose statt Endlosschleifen.
