# Queue Manager fuer OpenClaw, Codex und n8n

Der Queue Manager ist ein geplanter Sicherheits- und Stabilitaetsbaustein. Er soll verhindern, dass
schwere Jobs parallel starten und WSL2, VPS oder GPU- Workstations ueberlasten.

## Ziel

- Jobs seriell oder begrenzt parallel ausfuehren
- schwere Builds und GPU-Jobs bewusst einreihen
- OpenClaw-, Codex- und n8n-Auftraege priorisieren
- Ressourcenklasse beachten
- Abbruch und Wiederaufnahme dokumentieren

## Kandidaten

| Tool           | Quelle                                       | Einsatz                        |
| -------------- | -------------------------------------------- | ------------------------------ |
| RQ             | `https://github.com/rq/rq`                   | leichte Python/Redis Queue     |
| Celery         | `https://github.com/celery/celery`           | komplexere Python Task Queue   |
| Dramatiq       | `https://github.com/Bogdanp/dramatiq`        | Python Queue                   |
| BullMQ         | `https://github.com/taskforcesh/bullmq`      | Node/Redis Queue               |
| Temporal       | `https://github.com/temporalio/temporal`     | schwere Workflow Engine        |
| Prefect        | vorhandener Tool-Kandidat                    | Daten-/Workflow-Orchestrierung |
| Argo Workflows | `https://github.com/argoproj/argo-workflows` | Kubernetes Workflows           |

## Empfohlene maximale Parallelitaet

| System          | Empfehlung                         |
| --------------- | ---------------------------------- |
| MiniPC / WSL2   | 1 Job                              |
| Oracle VPS      | 1-2 leichte Jobs                   |
| Raspberry Pi    | nur leichte Jobs                   |
| GPU Workstation | 1 schwerer Job oder 2 leichte Jobs |

## Sicherheitsregeln

- Schwere Tools starten nie automatisch.
- GPU-/Render-/Airbyte-/AutoGPT-/ComfyUI-Jobs brauchen Freigabe.
- Jobs schreiben Logs unter `~/.openclaw_ultimate_user_data/queue`.
- Secrets werden nicht in Job-Payloads gespeichert.

## Setup

```bash
bash scripts/tools/queue_manager_install.sh --dry-run
bash scripts/tools/queue_manager_install.sh --prepare
```

Dies richtet nur lokale Konfigurationsdateien ein. Eine konkrete Queue-Engine wird spaeter bewusst
ausgewaehlt.

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py list
```

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
